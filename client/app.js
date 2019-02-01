// Copyright 2017, Google, Inc.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

'use strict';

const express = require('express');
const bodyParser = require('body-parser');
const session = require('express-session');

const app = express();
app.set('view engine', 'ejs');
app.use(express.static(__dirname + '/views'));
app.use(bodyParser.urlencoded({
    extended: true
}));
app.use(bodyParser.json());
app.use(session({
    secret: 'keyboard cat',
    resave: false,
    saveUninitialized: true,
    cookie: {
        maxAge: 1000 * 60 * 60
    }
}));

const url = require('url');
const ejs = require('ejs');
const https = require('https');
const fs = require('fs');
const config = require('config');
const util = require('util');

//geth rpc設定
const Web3 = require('web3');
var web3 = new Web3(new Web3.providers.HttpProvider(config.geth_url));

//gas
const gas = config.gas;
//from address
const fromAddress = config.from_address;

//contract設定
var bankContract = new web3.eth.Contract(config.contract_bank_abi,config.contract_bank_address,{from:fromAddress});

//初期値byte32
const zeroByte32 = "0x0000000000000000000000000000000000000000000000000000000000000000" ;
//レートの小数部桁数
const decimalScale = 10 ;
//レートの小数点表現用delimiter
const rateDelimiter = "p"

//一覧処理のget処理
app.get('/', async (req, res) => {

    var userId = await getUserIdParam(req) ;
    req.session.userId = userId ;
    
    res.header('Content-Type', 'text/plain;charset=utf-8');
    //パラメータを設定してejsをレンダリング
    //ejsに渡す用のパラメータをセットしてく
    var ejsParams = {};

    //userInfoを取得
    var userInfo = {} ;
    await getUserInfoFromContract(bankContract,userId,userInfo);
    ejsParams["userInfo"] = userInfo ;

    //userに関連する取引のIDを取得
    var transactionIdListObj = new Object() ;
    await getTransactionIdFromContractByUserId(bankContract,userId,0,transactionIdListObj) ;
    
    //userに関連する取引情報の取得
    var transactionInfoList = [] ;
    await getTransactionInfoFromContractByIdList(bankContract,transactionIdListObj.transactionIdList,transactionInfoList);

    ejsParams["transactionInfoList.length"] = Object.keys(transactionInfoList).length ;
    
    //userに関連する口座番号を取得
    var accountNoList= [] ;
    await getAccountNoFromContractByUserId(bankContract,userId,0,accountNoList) ;
    
    //userに関連する口座番号と取引情報を紐付けて、入出金の判断をする
    for(var i=0;i<ejsParams["transactionInfoList.length"];i++){
        //自分が出金元口座
        if(accountNoList.indexOf(transactionInfoList[i].fromAccountNo) > -1){
            //入出金両方なら換金
            if(accountNoList.indexOf(transactionInfoList[i].toAccountNo) > -1){
                transactionInfoList[i].inOutType = 3;   
            }
            //自分が出金元
            else{
                transactionInfoList[i].inOutType = 2;
            }
        }
        //自分が入金先
        else{
            transactionInfoList[i].inOutType = 1;
        }        
    }
    
    ejsParams["transactionInfoList"] = transactionInfoList;

    //express4でejsテンプレートを読み込むための呪文
    ejsParams["filename"] = "filename";
    //navbar用
    ejsParams["navActive"] = "/";
    //レンダリング
    fs.readFile('./views/index.ejs', 'utf-8', function (err, data) {
        renderEjsView(res, data, ejsParams);
    });
});

//取引詳細画面
app.get('/transactionDetail', async (req, res) => {
    res.header('Content-Type', 'text/plain;charset=utf-8');
    
    var userId = await getUserIdParam(req) ;
    req.session.userId = userId ;
    
    var url_parts = url.parse(req.url, true);
    var transactionId = url_parts.query.transactionId
    
    //userInfoを取得
    var userInfo = {} ;
    await getUserInfoFromContract(bankContract,userId,userInfo);
    
    //transactionInfoを取得
    var transactionInfo = {} ;
    await getTransactionInfoFromContractById(bankContract,transactionId,transactionInfo);
    
    var ejsParams = {} ;
    ejsParams["userInfo"] = userInfo ;
    ejsParams["transactionInfo"] = transactionInfo ;

    //express4でejsテンプレートを読み込むための呪文
    ejsParams["filename"] = "filename";
    //navbar用
    ejsParams["navActive"] = "/";
    //レンダリング
    fs.readFile('./views/transactionDetail.ejs', 'utf-8', function (err, data) {
        renderEjsView(res, data, ejsParams);
    });    
}); 

//振込入力ページ
app.get('/transfer', async (req, res) => {
    res.header('Content-Type', 'text/plain;charset=utf-8');
    if(req.session.errorMsg){
        var errorMsg = req.session.errorMsg ;        
        req.session.errorMsg = null ;
    }else{
        var errorMsg = [] ;
    }
    
    var userId = await getUserIdParam(req) ;
    req.session.userId = userId ;
    
    //userInfoを取得
    var userInfo = {} ;
    await getUserInfoFromContract(bankContract,userId,userInfo);

    //userに関連する口座番号を取得
    var accountNoList= [] ;
    await getAccountNoFromContractByUserId(bankContract,userId,0,accountNoList) ;    
    
    //口座番号の口座情報を取得
    var accountInfoList = [] ;
    await getAccountInfoFromContractByNoList(bankContract,accountNoList,accountInfoList);    
    
    var ejsParams = {} ;
    ejsParams["userInfo"] = userInfo ;
    ejsParams["accountInfoList"] = accountInfoList ;
    ejsParams["errorMsg"] = errorMsg ;
    ejsParams["errorMsg.length"] = errorMsg.length ;
    //express4でejsテンプレートを読み込むための呪文
    ejsParams["filename"] = "filename";
    //navbar用
    ejsParams["navActive"] = "/transfer";
    //レンダリング
    fs.readFile('./views/transfer.ejs', 'utf-8', function (err, data) {
        renderEjsView(res, data, ejsParams);
    });    
}); 
//振込内容を確認
app.post('/confirmTransfer', async (req, res) => {
    res.header('Content-Type', 'text/plain;charset=utf-8');
    //userInfoを取得
    var userInfo = {} ;
    var userId = req.session.userId ;
    await getUserInfoFromContract(bankContract,userId,userInfo);
    
    //post data
    var transactionInfo = {} ;
    transactionInfo.fromAccountNo = req.body.fromAccountNo;
    transactionInfo.toAccountNo = req.body.toAccountNo;
    transactionInfo.fromAccountHolderName = req.body.fromAccountHolderName;
    transactionInfo.fromPrinc = req.body.fromPrinc;
    transactionInfo.fromCurrency = req.body.fromCurrency ;
    
    //確認用データを作る
    //相手の口座情報を取得
    var toAccountInfo = {} ;
    await getAccountInfoFromContractByNo(bankContract,transactionInfo.toAccountNo,toAccountInfo);
    //自分の口座情報を取得
    var fromAccountInfo = {} ;
    await getAccountInfoFromContractByNo(bankContract,transactionInfo.fromAccountNo,fromAccountInfo)

    transactionInfo.toAccountHolderName = toAccountInfo.accountHolderName ;
    transactionInfo.toCurrency = toAccountInfo.currency ;

    //口座間の通貨が合っていることをチェック
    var errorMsg =[] ;
    if(transactionInfo.fromCurrency != transactionInfo.toCurrency){
        errorMsg.push("The currency is different between your account and counterparty account.");
    }
    //金額が足りていることをチェック
    if(fromAccountInfo.balance < transactionInfo.fromPrinc){
        errorMsg.push("Your account does not have enough balance.") ;
    }
    
    var ejsParams = {} ;
    ejsParams["userInfo"] = userInfo ;
    ejsParams["transactionInfo"] = transactionInfo ;
    //express4でejsテンプレートを読み込むための呪文
    ejsParams["filename"] = "filename";
    //navbar用
    ejsParams["navActive"] = "/transfer";

    //エラーがなければ確認ページ、あれば前ページに戻す
    if(errorMsg.length == 0){
        //レンダリング
        fs.readFile('./views/confirmTransfer.ejs', 'utf-8', function (err, data) {
            renderEjsView(res, data, ejsParams);
        });            
    }else{
        //エラーメッセージをセッションに渡してリダイレクト
        req.session.errorMsg = errorMsg ;
        res.redirect(302, "../transfer/");    
    }
    
});
//振込処理実行
app.post('/doTransfer', async (req, res) => {
    res.header('Content-Type', 'text/plain;charset=utf-8');
    //post data
    var transactionInfo = {} ;
    transactionInfo.fromAccountNo = req.body.fromAccountNo;
    transactionInfo.toAccountNo = req.body.toAccountNo;
    transactionInfo.fromAccountHolderName = req.body.fromAccountHolderName;
    transactionInfo.toAccountHolderName = req.body.toAccountHolderName;
    transactionInfo.fromCurrency = req.body.fromCurrency ;
    transactionInfo.fromPrinc = req.body.fromPrinc;
    transactionInfo.transactionType = 0;
    transactionInfo.rate = 1;
    
    //取引実行
    await exchange(bankContract,transactionInfo) ;
    
    var ejsParams = {};
    //express4でejsテンプレートを読み込むための呪文
    ejsParams["filename"] = "filename";
    //navbar用
    ejsParams["navActive"] = "/transfer";

    res.redirect(302, "../");
    
});
//両替入力ページ
app.get('/exchange', async (req, res) => {
    res.header('Content-Type', 'text/plain;charset=utf-8');
    if(req.session.errorMsg){
        var errorMsg = req.session.errorMsg ;        
        req.session.errorMsg = null ;
    }else{
        var errorMsg = [] ;
    }
    
    var userId = await getUserIdParam(req) ;
    req.session.userId = userId ;
    
    //userInfoを取得
    var userInfo = {} ;
    await getUserInfoFromContract(bankContract,userId,userInfo);

    //userに関連する口座番号を取得
    var accountNoList= [] ;
    await getAccountNoFromContractByUserId(bankContract,userId,0,accountNoList) ;    
    
    //口座番号の口座情報を取得
    var accountInfoList = [] ;
    await getAccountInfoFromContractByNoList(bankContract,accountNoList,accountInfoList);    
    
    var ejsParams = {} ;
    ejsParams["userInfo"] = userInfo ;
    ejsParams["accountInfoList"] = accountInfoList ;
    ejsParams["errorMsg"] = errorMsg ;
    ejsParams["errorMsg.length"] = errorMsg.length ;
    //express4でejsテンプレートを読み込むための呪文
    ejsParams["filename"] = "filename";
    //navbar用
    ejsParams["navActive"] = "/exchange";
    //レンダリング
    fs.readFile('./views/exchange.ejs', 'utf-8', function (err, data) {
        renderEjsView(res, data, ejsParams);
    });    
}); 
//最新のレート取得
app.post('/getRate', async (req, res) => {
    res.header('Content-Type', 'text/plain;charset=utf-8');
    var fromCurrency = req.body.fromCurrency ;
    var toCurrency = req.body.toCurrency ;

    var returnParam = {} ;
    
    //レート取得
    returnParam.rate = getRate(fromCurrency,toCurrency) ;
    if(!returnParam.rate){
        returnParam.rate = 1.00 ;
    }
    
    res.json(returnParam); 
}); 

//両替内容を確認
app.post('/confirmExchange', async (req, res) => {
    res.header('Content-Type', 'text/plain;charset=utf-8');
    //userInfoを取得
    var userInfo = {} ;
    var userId = req.session.userId ;
    await getUserInfoFromContract(bankContract,userId,userInfo);
    
    //post data
    var transactionInfo = {} ;
    transactionInfo.fromAccountNo = req.body.fromAccountNo;
    transactionInfo.toAccountNo = req.body.toAccountNo;
    transactionInfo.fromCurrency = req.body.fromCurrency ;
    transactionInfo.toCurrency = req.body.toCurrency ;

    //確認用データを作る
    //換金先の口座情報を取得
    var toAccountInfo = {} ;
    await getAccountInfoFromContractByNo(bankContract,transactionInfo.toAccountNo,toAccountInfo);
    transactionInfo.toAccountHolderName = toAccountInfo.accountHolderName ;

    //換金元の口座情報を取得
    var fromAccountInfo = {} ;
    await getAccountInfoFromContractByNo(bankContract,transactionInfo.fromAccountNo,fromAccountInfo)
    transactionInfo.fromAccountHolderName = fromAccountInfo.accountHolderName ;
    
    var errorMsg =[] ;    
    
    //レートの取得
    var rate = getRate(transactionInfo.fromCurrency,transactionInfo.toCurrency) ;
    
    //通貨ペアが存在しなかったらエラー
    if(rate){
        transactionInfo.rate = rate ; 
    }else{
        errorMsg.push("Selected currency pair does not exist");
    }
                
    //基準にする元本の判定とレートをもとにした計算
    transactionInfo.princFlag = req.body.princFlag;
    if(transactionInfo.princFlag == "from"){
        transactionInfo.fromPrinc = req.body.fromPrinc;
        transactionInfo.toPrinc = Math.floor(transactionInfo.fromPrinc * transactionInfo.rate);
    }else{
        transactionInfo.toPrinc = req.body.toPrinc;
        transactionInfo.fromPrinc = Math.floor(transactionInfo.toPrinc / transactionInfo.rate);        
    }
    
    //金額が足りていることをチェック
    if(fromAccountInfo.balance < transactionInfo.fromPrinc){
        errorMsg.push("Your account does not have enough balance.") ;
    }
    
    var ejsParams = {} ;
    ejsParams["userInfo"] = userInfo ;
    ejsParams["transactionInfo"] = transactionInfo ;
    //express4でejsテンプレートを読み込むための呪文
    ejsParams["filename"] = "filename";
    //navbar用
    ejsParams["navActive"] = "/exchange";

    //エラーがなければ確認ページ、あれば前ページに戻す
    if(errorMsg.length == 0){
        //レンダリング
        fs.readFile('./views/confirmExchange.ejs', 'utf-8', function (err, data) {
            renderEjsView(res, data, ejsParams);
        });            
    }else{
        //エラーメッセージをセッションに渡してリダイレクト
        req.session.errorMsg = errorMsg ;
        res.redirect(302, "../exchange/");    
    }
    
});
//換金処理実行
app.post('/doExchange', async (req, res) => {
    res.header('Content-Type', 'text/plain;charset=utf-8');
    //post data
    var transactionInfo = {} ;
    transactionInfo.fromAccountNo = req.body.fromAccountNo;
    transactionInfo.toAccountNo = req.body.toAccountNo;
    transactionInfo.fromAccountHolderName = req.body.fromAccountHolderName;
    transactionInfo.toAccountHolderName = req.body.toAccountHolderName;
    transactionInfo.fromCurrency = req.body.fromCurrency ;
    transactionInfo.toCurrency = req.body.toCurrency ;
    transactionInfo.fromPrinc = req.body.fromPrinc;
    transactionInfo.toPrinc = req.body.tomPrinc;
    transactionInfo.transactionType = 1;
    transactionInfo.rate = req.body.rate;
    
    //取引実行
    await exchange(bankContract,transactionInfo) ;
    
    var ejsParams = {};
    //express4でejsテンプレートを読み込むための呪文
    ejsParams["filename"] = "filename";
    //navbar用
    ejsParams["navActive"] = "/exchange";

    res.redirect(302, "../");
    
});
//口座表示
app.get('/myAccounts', async (req, res) => {
    res.header('Content-Type', 'text/plain;charset=utf-8');    
    var userId = await getUserIdParam(req) ;
    req.session.userId = userId ;
    
    //userInfoを取得
    var userInfo = {} ;
    await getUserInfoFromContract(bankContract,userId,userInfo);

    //userに関連する口座番号を取得
    var accountNoList= [] ;
    await getAccountNoFromContractByUserId(bankContract,userId,0,accountNoList) ;    
    
    //口座番号の口座情報を取得
    var accountInfoList = [] ;
    await getAccountInfoFromContractByNoList(bankContract,accountNoList,accountInfoList);    
    
    var ejsParams = {} ;
    ejsParams["userInfo"] = userInfo ;
    ejsParams["accountInfoList"] = accountInfoList ;

    //express4でejsテンプレートを読み込むための呪文
    ejsParams["filename"] = "filename";
    //navbar用
    ejsParams["navActive"] = "/myAccounts";
    //レンダリング
    fs.readFile('./views/myAccounts.ejs', 'utf-8', function (err, data) {
        renderEjsView(res, data, ejsParams);
    });    
}); 

//userIdを取得
async function getUserIdParam(req){
    //getパラメータを取得
    var url_parts = url.parse(req.url, true);

    if (url_parts.query.userId){
        var userId = url_parts.query.userId;        
    }
    //sessionからaccountを取得
    else if (req.session.userId) {
        var userId = req.session.userId;
    } 
    else {
        var userId = "";
    }
    return userId ;
}
//ContractからUserInfoを取得する
async function getUserInfoFromContract(contract,userId,userInfo){
    await bankContract.methods.getUserInfo(userId).call(function(err,result){
        //コンバージョンする
        userInfo.userId = getUint(result[0]);
        userInfo.userName = toAscii(result[1]);
        userInfo.userAddress = toAscii(result[2]);
        return ;
    }) ;
}
//Contractからユーザーに紐づく取引情報を取得する
async function getTransactionIdFromContractByUserId(bankContract,userId,startIndex,transactionIdListObj){
    await bankContract.methods.getUserTransactionIndexDesc(userId,startIndex).call(function(err,indexList){
        transactionIdListObj.transactionIdList = indexList ;
        return ;
    }) ;
}
//Contractからユーザーに紐づく口座情報を取得する
async function getAccountNoFromContractByUserId(bankContract,userId,startIndex,accountNoList){
    await bankContract.methods.getUserAccountIndexDesc(userId,startIndex).call(function(err,indexList){
        for(var i=0;i<indexList.length;i++){
            //口座番号が初期値のものは無視
            if(indexList[i] == zeroByte32){
                
            }else{
                accountNoList[i] = toAscii(indexList[i]) ;
            }
        }
        return ;
    }) ;
}
//ContractからtransactionIdListに該当する取引情報を取得する
async function getTransactionInfoFromContractByIdList(bankContract,transactionIdList,transactionInfoList){
    for(var i=0;i<transactionIdList.length;i++){
        await bankContract.methods.getTransactionInfo(transactionIdList[i]).call(function(err,resultTransactionInfo){
            var transactionInfo = {} ;
            transactionInfo.transactionId = getUint(resultTransactionInfo[0]); 
            transactionInfo.transactionStatus = getUint(resultTransactionInfo[1]) ;
            transactionInfo.transactionType = getUint(resultTransactionInfo[2]) ;
            transactionInfo.fromAccountNo = toAscii(resultTransactionInfo[3]) ;
            transactionInfo.toAccountNo = toAscii(resultTransactionInfo[4]) ;
            transactionInfo.fromAccountHolderName = toAscii(resultTransactionInfo[5]) ;
            transactionInfo.toAccountHolderName = toAscii(resultTransactionInfo[6]) ;
            transactionInfo.fromCurrency = toAscii(resultTransactionInfo[7]) ;
            transactionInfo.toCurrency = toAscii(resultTransactionInfo[8]) ;
            transactionInfo.rate = getRateFromBytes(resultTransactionInfo[9]) ;
            transactionInfo.fromPrinc = getUint(resultTransactionInfo[10]) ;
            transactionInfo.toPrinc = getUint(resultTransactionInfo[11]) ;
            transactionInfo.timestamp = getEpochTimeInt(resultTransactionInfo[12]) ;

            //idが0の場合は空なので無視
            if(transactionInfo.transactionId != 0){
                transactionInfoList.push(transactionInfo);               
            }else{
                
            }
        });
    }
}
//ContractからtransactionIdに該当する取引情報を取得する
async function getTransactionInfoFromContractById(bankContract,transactionId,transactionInfo){
    await bankContract.methods.getTransactionInfo(transactionId).call(function(err,resultTransactionInfo){
        transactionInfo.transactionId = getUint(resultTransactionInfo[0]); 
        transactionInfo.transactionStatus = getUint(resultTransactionInfo[1]) ;
        transactionInfo.transactionType = getUint(resultTransactionInfo[2]) ;
        transactionInfo.fromAccountNo = toAscii(resultTransactionInfo[3]) ;
        transactionInfo.toAccountNo = toAscii(resultTransactionInfo[4]) ;
        transactionInfo.fromAccountHolderName = toAscii(resultTransactionInfo[5]) ;
        transactionInfo.toAccountHolderName = toAscii(resultTransactionInfo[6]) ;
        transactionInfo.fromCurrency = toAscii(resultTransactionInfo[7]) ;
        transactionInfo.toCurrency = toAscii(resultTransactionInfo[8]) ;
        transactionInfo.rate = getRateFromBytes(resultTransactionInfo[9]) ;
        transactionInfo.fromPrinc = getUint(resultTransactionInfo[10]) ;
        transactionInfo.toPrinc = getUint(resultTransactionInfo[11]) ;
        transactionInfo.timestamp = getEpochTimeInt(resultTransactionInfo[12]) ;
    });
}

//ContractからaccountNoListに該当する取引情報を取得する
async function getAccountInfoFromContractByNoList(bankContract,accountNoList,accountInfoList){
    for(var i=0;i<accountNoList.length;i++){
        await bankContract.methods.getAccountInfo(web3.utils.toHex(accountNoList[i])).call(function(err,resultAccountInfo){
            var accountInfo = {} ;
            accountInfo.accountNo = toAscii(resultAccountInfo[0]) ;
            accountInfo.accountHolderName = toAscii(resultAccountInfo[1]) ;
            accountInfo.accountType = getUint(resultAccountInfo[2]) ;
            accountInfo.currency = toAscii(resultAccountInfo[3]) ;
            accountInfo.balance = getUint(resultAccountInfo[4]) ;
            accountInfo.userId = getUint(resultAccountInfo[5]) ;
            //userIdが0の場合は空なので無視
            if(accountInfo.userId != 0){
                accountInfoList.push(accountInfo);               
            }else{
                
            }
        });
    }
}
//ContractからaccountNoに該当する口座情報を取得する
async function getAccountInfoFromContractByNo(bankContract,accountNo,accountInfo){
    await bankContract.methods.getAccountInfo(web3.utils.toHex(accountNo)).call(function(err,resultAccountInfo){
        accountInfo.accountNo = toAscii(resultAccountInfo[0]) ;
        accountInfo.accountHolderName = toAscii(resultAccountInfo[1]) ;
        accountInfo.accountType = getUint(resultAccountInfo[2]) ;
        accountInfo.currency = toAscii(resultAccountInfo[3]) ;
        accountInfo.balance = getUint(resultAccountInfo[4]) ;
        accountInfo.userId = getUint(resultAccountInfo[5]) ;         
    });
}
//Contractからtransfer取引実行
async function transfer(bankContract,transactionInfo){
        await bankContract.methods.transfer(
            transactionInfo.transactionType,
            web3.utils.toHex(transactionInfo.fromAccountNo),
            web3.utils.toHex(transactionInfo.toAccountNo),
            web3.utils.toHex(transactionInfo.fromAccountHolderName),
            web3.utils.toHex(transactionInfo.toAccountHolderName),
            web3.utils.toHex(transactionInfo.fromCurrency),
            web3.utils.toHex(transactionInfo.fromCurrency),
            web3.utils.toHex(rateToByte(transactionInfo.rate)),
            transactionInfo.fromPrinc,
            transactionInfo.fromPrinc).send({"from":fromAddress,"gas":gas});
}
//Contractから換金取引実行
async function exchange(bankContract,transactionInfo){
        await bankContract.methods.transfer(
            transactionInfo.transactionType,
            web3.utils.toHex(transactionInfo.fromAccountNo),
            web3.utils.toHex(transactionInfo.toAccountNo),
            web3.utils.toHex(transactionInfo.fromAccountHolderName),
            web3.utils.toHex(transactionInfo.toAccountHolderName),
            web3.utils.toHex(transactionInfo.fromCurrency),
            web3.utils.toHex(transactionInfo.toCurrency),
            web3.utils.toHex(rateToByte(transactionInfo.rate)),
            transactionInfo.fromPrinc,
            transactionInfo.toPrinc).send({"from":fromAddress,"gas":gas});
}
//Utility
//16進Byte表現⇒Ascii文字列変換（null文字削除込み)
//ethereumのコントラクトでは、整数のみの値はintに解釈されてしまうので、現状は文字列としてdecodeすると値がおかしくなる。
function toAscii(byteStr){
	return web3.utils.hexToAscii(byteStr).replace(/\0/g,"") ;
}
//byte表現からehtereumアカウントアドレスを切り出す
function getAddressBytes(byteStr){
	return "0x"+byteStr.substr(byteStr.length-40,40) ;
}
//byte表現からuintの表現を取り出す
function getUint(byteStr){
	return parseInt(byteStr.substr(2,byteStr.length-2),16) ;
}
//byte表現からepochの日時を取得する
function getEpochTimeInt(byteStr){
	return parseInt((parseInt(byteStr.substr(2,byteStr.length-2),16)).toString().substr(0,10) + "000") ;
}
//byte表現からレートを取得する
function getRateFromBytes(byteStr){
    return parseFloat(toAscii(byteStr).replace(rateDelimiter,"."));
}
//レートを文字表現に変換
function rateToByte(rate){
    return new Number(rate).toFixed(decimalScale).replace("\.",rateDelimiter) ; 
}

//ejs render
function renderEjsView(res, data, ejsParams) {
    var view = ejs.render(data, ejsParams);
    res.writeHead(200, {
        'Content-Type': 'text/html'
    });
    res.write(view);
    res.end();
}
//read rate file
function getRate(fromCurrency,toCurrency){
    var rateList = JSON.parse(fs.readFileSync('./data/rate.json', 'utf-8')) ;
    return rateList[fromCurrency+"to"+toCurrency] ;
}

if (module === require.main) {
    // [START server]
    // Start the server
    const server = app.listen(process.env.PORT || 8081, () => {
        const port = server.address().port;
        console.log(`App listening on port ${port}`);
    });
    // [END server]
}

module.exports = app;
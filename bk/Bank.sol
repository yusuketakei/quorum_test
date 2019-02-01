contract Bank {

// --ストラクチャ定義 Start--
	// ユーザ情報
	struct UserInfo {
		// ユーザID
		uint userId;
		// ユーザ名
		bytes32 userName;
        // ユーザー住所
        bytes32 userAddress;
        // 削除フラグ
		bool delFlg;
	}

	// 口座情報
	struct AccountInfo {
		// 口座Address
		bytes32 accountNo;
		// 口座種別
		uint accountType;
		// 通貨
		bytes32 currency;
		// 残高
		uint balance;
		// ユーザID
		uint userId;
		// 作成タイムスタンプ
		uint createTimestamp;
		// 更新タイムスタンプ
		uint updateTimestamp;
        // 削除フラグ
        bool delFlg;
	}

	// 換金リクエスト情報
	struct RequestInfo {
        // リクエストID
        uint requestId;
        // ステータス（要求、応諾、拒否）
        uint requestStatus;
        // リクエスト種別（現状外為のみ）
        uint requestType;
        // キャッシュアウト口座
        bytes32 outAccountNo;
        // キャッシュイン口座
        bytes32 inAccountNo;
        // キャッシュアウト通貨
        bytes32 outCurrency;
        // キャッシュイン通貨
        bytes32 inCurrency;
        // レート（下4桁小数点）
        bytes32 rate;
        // キャッシュアウト金額
        uint outPrinc;
        // キャッシュイン金額
        uint inPrinc;
        // 要求タイムスタンプ
        uint requestTimestamp;
        // 応答タイムスタンプ
        uint replyTimestamp;
	}

	// 為替トランザクション
	struct TransactionInfo {
        // トランザクションID
        uint transactionId;
        // ステータス（現状0のみ）
        uint transactionStatus;
        // 取引種別（現状、為替のみ）
        uint transactionType;
        // 送金元口座
        bytes32 fromAccountNo;
        // 送金先口座
        bytes32 toAccountNo;
        // 送金元通貨
        bytes32 fromCurrency;
        // 送金先通貨
        bytes32 toCurrency;
        // レート
        bytes32 rate;
        // 送金元元本
        uint fromPrinc;
        // 送金先元本
        uint toPrinc;
        // タイムスタンプ
        uint timestamp;
	}
// --ストラクチャ定義 End--

// --定数定義 Start--
	// 要求ステータス-要求
	uint constant REQUESTING = 0;
	// 要求ステータス-応諾
	uint constant REQUEST_OK = 1;
	// 要求ステータス-拒否
	uint constant REQUEST_NG = 2;
    // 銀行の口座番号
    bytes32 constant BANK_ACCOUNT_NO = "0" ;
    // 銀行の顧客番号
    uint constant BANK_USER_ID = 0 ;
    // 取引種別(内為)
    uint constant TRN_TYPE_NAI = 0;
    // 取引種別(外為)
    uint constant TRN_TYPE_GAI = 1;
    
// --定数定義 End--

// --変数定義 Start--	
	mapping (uint => UserInfo) userInfoList;
	mapping (bytes32 => AccountInfo) accountInfoList;
    mapping (uint => bytes32[]) userAccountIndex;
	mapping (uint => RequestInfo) requestInfoList;
	mapping (uint => TransactionInfo) transactionInfoList;
    mapping (uint => uint[]) userRequestIndex;
    mapping (uint => uint[]) userTransactionIndex;
    uint private userCounter = 0;
	uint private requestCounter = 0;
	uint private transactionCounter = 0;
// --変数定義 End--

// --Public関数定義 Start--
    // indexリストの取得
    function getUserAccountIndexDesc(uint _userId,uint _startIndex) constant returns(bytes32[10] accountIndexList ){
        
        uint num = userAccountIndex[_userId].length;
		uint counter = 0;
		uint indexIndex = num - 1 - _startIndex;
		
		while (counter <= indexIndex) {
			if (counter >= 10) {
				 break;
			}
			
			accountIndexList[counter] = userAccountIndex[_userId][indexIndex - counter];
			
			counter++;
		}
    }
    // indexリストの取得
    function getUserRequestIndexDesc(uint _userId,uint _startIndex) constant returns(uint[10] requestIndexList ){
        
        uint num = userRequestIndex[_userId].length;
		uint counter = 0;
		uint indexIndex = num - 1 - _startIndex;
		
		while (counter <= indexIndex) {
			if (counter >= 10) {
				 break;
			}
			
			requestIndexList[counter] = userRequestIndex[_userId][indexIndex - counter];
			
			counter++;
		}
    }
    // indexリストの取得
    function getUserTransactionIndexDesc(uint _userId,uint _startIndex) constant returns(uint[10] transactionIndexList ){
        
        uint num = userTransactionIndex[_userId].length;
		uint counter = 0;
		uint indexIndex = num - 1 - _startIndex;
		
		while (counter <= indexIndex) {
			if (counter >= 10) {
				 break;
			}
			
			transactionIndexList[counter] = userTransactionIndex[_userId][indexIndex - counter];
			
			counter++;
		}
    }

	// ユーザの参照
	function getUserInfo(uint _userId) constant returns(bytes32[3] userInfo) {
			
		// ユーザ情報の参照
		userInfo[0] = bytes32(userInfoList[_userId].userId);
        userInfo[1] = userInfoList[_userId].userName;
        userInfo[2] = userInfoList[_userId].userAddress;

		return userInfo;
	}
    // ユーザの登録
	function registUserInfo(bytes32 _userName, bytes32 _userAddress) returns(uint userId) {
			
		// ユーザ情報の登録
		userCounter++;
        userInfoList[userCounter].userId = userCounter;
		userInfoList[userCounter].userName = _userName;
        userInfoList[userCounter].userAddress = _userAddress;
		userInfoList[userCounter].delFlg = false;
		
		return userInfoList[userCounter].userId;
	}
	
	// ユーザの更新
	function updateUserInfo(uint _userId,bytes32 _userName, bytes32 _userAddress) returns(bool result) {
		
		// ユーザ登録していない場合はエラーを返す
		if (checkUserExistence(_userId) == false) {
			return false;
		}
		
		// ユーザ情報の登録
		userInfoList[_userId].userName = _userName;
		userInfoList[_userId].userAddress = _userAddress;
		
		return true;
	}
	
	// ユーザの削除
	function deleteUserInfo(uint _userId) returns(bool result) {
		
		// ユーザ登録していない場合はエラーを返す
		if (checkUserExistence(_userId) == false) {
			return false;
		}
		
		// @ToDo 削除のための条件を追加
		
		
		// ユーザ情報の更新
		userInfoList[_userId].delFlg = true;
		
		return true;
	}
	// 口座の参照
	function getAccountInfo(bytes32 _accountNo) constant returns(bytes32[5] accountInfo) {
			
		// ユーザ情報の参照
		accountInfo[0] = accountInfoList[_accountNo].accountNo;
		accountInfo[1] = bytes32(accountInfoList[_accountNo].accountType);
		accountInfo[2] = accountInfoList[_accountNo].currency;
		accountInfo[3] = bytes32(accountInfoList[_accountNo].balance);
		accountInfo[4] = bytes32(accountInfoList[_accountNo].userId);

        return accountInfo;
	}	
    // 口座解説
	function registAccountInfo(bytes32 _accountNo, uint _accountType,bytes32 _currency,uint _userId) returns(bool result) {
			
		// 口座情報の登録
        accountInfoList[_accountNo].accountNo = _accountNo;
		accountInfoList[_accountNo].accountType = _accountType;
        accountInfoList[_accountNo].currency = _currency;
        accountInfoList[_accountNo].balance = 0;
        accountInfoList[_accountNo].userId = _userId;
        accountInfoList[_accountNo].createTimestamp = block.timestamp;
        accountInfoList[_accountNo].delFlg = false;
        
        userAccountIndex[_userId].push(_accountNo);
		
		return true;
	}
    
    //口座閉塞
    function deleteAccountInfo(bytes32 _accountNo) returns(bool result) {
			
		// 口座の有無確認
        if(checkAccountExistence(_accountNo) == false){
            return false ;
        }
        
        accountInfoList[_accountNo].delFlg = true;
        
		return true;
	}

    // リクエストの参照
	function getRequestInfo(uint _requestId) constant returns(bytes32[12] requestInfo) {
			
		// ユーザ情報の参照
		requestInfo[0] = bytes32(requestInfoList[_requestId].requestId);
		requestInfo[1] = bytes32(requestInfoList[_requestId].requestStatus);
		requestInfo[2] = bytes32(requestInfoList[_requestId].requestType);
		requestInfo[3] = requestInfoList[_requestId].outAccountNo;
		requestInfo[4] = requestInfoList[_requestId].inAccountNo;
		requestInfo[5] = requestInfoList[_requestId].outCurrency;
		requestInfo[6] = requestInfoList[_requestId].inCurrency;
        requestInfo[7] = requestInfoList[_requestId].rate;
		requestInfo[8] = bytes32(requestInfoList[_requestId].outPrinc);
		requestInfo[9] = bytes32(requestInfoList[_requestId].inPrinc);
		requestInfo[10] = bytes32(requestInfoList[_requestId].requestTimestamp);
		requestInfo[11] = bytes32(requestInfoList[_requestId].replyTimestamp);

        return requestInfo;
	}	
    // トランザクションの参照
	function getTransactionInfo(uint _transactionId) constant returns(bytes32[11] transactionInfo) {
			
		// ユーザ情報の参照
		transactionInfo[0] = bytes32(transactionInfoList[_transactionId].transactionId);
		transactionInfo[1] = bytes32(transactionInfoList[_transactionId].transactionStatus);
		transactionInfo[2] = bytes32(transactionInfoList[_transactionId].transactionType);
		transactionInfo[3] = transactionInfoList[_transactionId].fromAccountNo;
		transactionInfo[4] = transactionInfoList[_transactionId].toAccountNo;
		transactionInfo[5] = transactionInfoList[_transactionId].fromCurrency;
		transactionInfo[6] = transactionInfoList[_transactionId].toCurrency;
        transactionInfo[7] = transactionInfoList[_transactionId].rate;
		transactionInfo[8] = bytes32(transactionInfoList[_transactionId].fromPrinc);
		transactionInfo[9] = bytes32(transactionInfoList[_transactionId].toPrinc);
		transactionInfo[10] = bytes32(transactionInfoList[_transactionId].timestamp);

        return transactionInfo;
	}	

    //注文
	function request(bytes32 _outAccountNo,bytes32 _inAccountNo,bytes32 _outCurrency,bytes32 _inCurrency,bytes32 _rate,uint _outPrinc,uint _inPrinc) returns(bool result) {
			
		// 注文情報の登録
        requestCounter++ ;
        requestInfoList[requestCounter].requestStatus = REQUESTING;
        requestInfoList[requestCounter].outAccountNo = _outAccountNo;
        requestInfoList[requestCounter].inAccountNo = _inAccountNo;
        requestInfoList[requestCounter].outCurrency = _outCurrency;
        requestInfoList[requestCounter].inCurrency = _inCurrency;
        requestInfoList[requestCounter].rate = _rate;
        requestInfoList[requestCounter].outPrinc = _outPrinc;
        requestInfoList[requestCounter].inPrinc = _inPrinc;
        
        //ユーザインデックスの作成
        userRequestIndex[accountInfoList[_outAccountNo].userId].push(requestCounter);
	
		return true;
	}
    //応答
	function reply(uint _requestNo,bool _isOk) returns(bool result) {
			
		// 注文拒否
        if(_isOk == false){
            requestInfoList[_requestNo].requestStatus = REQUEST_NG ;
            return true ;
        }
        // 出金元の通貨チェック
        if(accountInfoList[requestInfoList[_requestNo].outAccountNo].currency != requestInfoList[_requestNo].outCurrency){
            requestInfoList[_requestNo].requestStatus = REQUEST_NG ;
            return true ;            
        }
        // 出金元の残高チェック
        if(accountInfoList[requestInfoList[_requestNo].outAccountNo].balance < requestInfoList[_requestNo].outPrinc){
            requestInfoList[_requestNo].requestStatus = REQUEST_NG ;
            return true ;            
        }

        // 応諾
        requestInfoList[_requestNo].requestStatus = REQUEST_OK ;

        //TODO 銀行からの出金チェックやトランザクション処理が必要
        //出金トランザクションの登録
        transactionCounter++;
        transactionInfoList[transactionCounter].transactionId = transactionCounter ;
        transactionInfoList[transactionCounter].transactionStatus = 0 ;
        transactionInfoList[transactionCounter].transactionType = TRN_TYPE_GAI ;

        transactionInfoList[transactionCounter].fromAccountNo = requestInfoList[_requestNo].outAccountNo ;
        transactionInfoList[transactionCounter].toAccountNo = BANK_ACCOUNT_NO ;

        transactionInfoList[transactionCounter].fromCurrency = requestInfoList[_requestNo].outCurrency ;
        transactionInfoList[transactionCounter].toCurrency = requestInfoList[_requestNo].outCurrency ;
        transactionInfoList[transactionCounter].rate = requestInfoList[_requestNo].rate ;

        transactionInfoList[transactionCounter].fromPrinc = requestInfoList[_requestNo].outPrinc ;
        transactionInfoList[transactionCounter].toPrinc = requestInfoList[_requestNo].outPrinc ;

        transactionInfoList[transactionCounter].timestamp = block.timestamp ;

        userRequestIndex[accountInfoList[requestInfoList[_requestNo].outAccountNo].userId].push(transactionCounter);
        userRequestIndex[BANK_USER_ID].push(transactionCounter);


        //入金トランザクションの登録
        transactionCounter++;
        transactionInfoList[transactionCounter].transactionId = transactionCounter ;
        transactionInfoList[transactionCounter].transactionStatus = 0 ;
        transactionInfoList[transactionCounter].transactionType = TRN_TYPE_GAI ;

        transactionInfoList[transactionCounter].fromAccountNo = BANK_ACCOUNT_NO ;
        transactionInfoList[transactionCounter].toAccountNo = requestInfoList[_requestNo].inAccountNo ;

        transactionInfoList[transactionCounter].fromCurrency = requestInfoList[_requestNo].inCurrency ;
        transactionInfoList[transactionCounter].toCurrency = requestInfoList[_requestNo].inCurrency ;
        transactionInfoList[transactionCounter].rate = requestInfoList[_requestNo].rate ;

        transactionInfoList[transactionCounter].fromPrinc = requestInfoList[_requestNo].inPrinc ;
        transactionInfoList[transactionCounter].toPrinc = requestInfoList[_requestNo].inPrinc ;

        transactionInfoList[transactionCounter].timestamp = block.timestamp ;
        
        userRequestIndex[accountInfoList[requestInfoList[_requestNo].inAccountNo].userId].push(transactionCounter);
        userRequestIndex[BANK_USER_ID].push(transactionCounter);

        //残高の増減
        accountInfoList[requestInfoList[_requestNo].outAccountNo].balance = accountInfoList[requestInfoList[_requestNo].outAccountNo].balance
         - requestInfoList[_requestNo].outPrinc;
        accountInfoList[requestInfoList[_requestNo].inAccountNo].balance = accountInfoList[requestInfoList[_requestNo].inAccountNo].balance
         + requestInfoList[_requestNo].inPrinc;
        
        
        return true;
	}
    //振込
	function transfer(bytes32 _fromAccountNo,bytes32 _toAccountNo,bytes32 _fromCurrency,bytes32 _toCurrency,bytes32 _rate,uint _fromPrinc,uint _toPrinc) returns(bool result) {
			
        // 出金元の通貨チェック
        if(accountInfoList[_fromAccountNo].currency != _fromCurrency){
            return false ;            
        }
        // 出金元の残高チェック
        if(accountInfoList[_fromAccountNo].balance < _fromPrinc){
            return false ;
        }

        //トランザクションの登録
        transactionCounter++;
        transactionInfoList[transactionCounter].transactionId = transactionCounter ;
        transactionInfoList[transactionCounter].transactionStatus = 0 ;
        transactionInfoList[transactionCounter].transactionType = TRN_TYPE_NAI ;

        transactionInfoList[transactionCounter].fromAccountNo = _fromAccountNo ;
        transactionInfoList[transactionCounter].toAccountNo = _toAccountNo ;

        transactionInfoList[transactionCounter].fromCurrency = _fromCurrency ;
        transactionInfoList[transactionCounter].toCurrency =  _toCurrency ;
        transactionInfoList[transactionCounter].rate = _rate ;

        transactionInfoList[transactionCounter].fromPrinc =  _fromPrinc ;
        transactionInfoList[transactionCounter].toPrinc =  _toPrinc ;

        transactionInfoList[transactionCounter].timestamp = block.timestamp ;

        userRequestIndex[accountInfoList[_fromAccountNo].userId].push(transactionCounter);
        userRequestIndex[accountInfoList[_toAccountNo].userId].push(transactionCounter);

        //残高の増減
        accountInfoList[_fromAccountNo].balance = accountInfoList[_fromAccountNo].balance - _fromPrinc;
        accountInfoList[_toAccountNo].balance = accountInfoList[_toAccountNo].balance + _toPrinc;
        
        return true;
	}
    
    
 
// --Public関数定義 End--

// --Private関数定義 Start--
	function checkUserExistence(uint _userId) private constant returns (bool result) {
		if (_userId != userInfoList[_userId].userId) {
			return false;
		}
		if (userInfoList[_userId].delFlg) {
			return false;
		}
		return true;
	}
	
	function checkAccountExistence(bytes32 _accountNo) private constant returns (bool result) {
		if (_accountNo != accountInfoList[_accountNo].accountNo) {
			return false;
		}
		if (accountInfoList[_accountNo].delFlg) {
			return false;
		}
		return true;
	}    
// --Private関数定義 End--
}

pragma solidity ^0.4.0;
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
        // 口座名義
        bytes32 accountHolderName;
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
        // 送金元口座名義
        bytes32 fromAccountHolderName;
        // 送金先口座名義
        bytes32 toAccountHolderName;
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
	mapping (uint => TransactionInfo) transactionInfoList;
    mapping (uint => uint[]) userTransactionIndex;
    uint private userCounter = 0;
	uint private transactionCounter = 0;
// --変数定義 End--

// --Public関数定義 Start--
    // indexリストの取得
    function getUserAccountIndexDesc(uint _userId,uint _startIndex) public constant returns(bytes32[10] accountIndexList ){
        
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
    function getUserTransactionIndexDesc(uint _userId,uint _startIndex) public constant returns(uint[10] transactionIndexList ){
        
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
	function getUserInfo(uint _userId) public constant returns(bytes32[3] userInfo) {
			
		// ユーザ情報の参照
		userInfo[0] = bytes32(userInfoList[_userId].userId);
        userInfo[1] = userInfoList[_userId].userName;
        userInfo[2] = userInfoList[_userId].userAddress;

		return userInfo;
	}
    // ユーザの登録
	function registUserInfo(bytes32 _userName, bytes32 _userAddress) public returns(uint userId) {
			
		// ユーザ情報の登録
		userCounter++;
        userInfoList[userCounter].userId = userCounter;
		userInfoList[userCounter].userName = _userName;
        userInfoList[userCounter].userAddress = _userAddress;
		userInfoList[userCounter].delFlg = false;
		
		return userInfoList[userCounter].userId;
	}
	
	// ユーザの更新
	function updateUserInfo(uint _userId,bytes32 _userName, bytes32 _userAddress) public returns(bool result) {
		
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
	function deleteUserInfo(uint _userId) public returns(bool result) {
		
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
	function getAccountInfo(bytes32 _accountNo) public constant returns(bytes32[6] accountInfo) {
			
		// ユーザ情報の参照
		accountInfo[0] = accountInfoList[_accountNo].accountNo;
        accountInfo[1] = accountInfoList[_accountNo].accountHolderName;
		accountInfo[2] = bytes32(accountInfoList[_accountNo].accountType);
		accountInfo[3] = accountInfoList[_accountNo].currency;
		accountInfo[4] = bytes32(accountInfoList[_accountNo].balance);
		accountInfo[5] = bytes32(accountInfoList[_accountNo].userId);

        return accountInfo;
	}	
    // 口座開設
	function registAccountInfo(bytes32 _accountNo,bytes32 _accountHolderName, uint _accountType,bytes32 _currency,uint _balance,uint _userId) public returns(bool result) {
			
		// 口座情報の登録
        accountInfoList[_accountNo].accountNo = _accountNo;
		accountInfoList[_accountNo].accountHolderName = _accountHolderName;
		accountInfoList[_accountNo].accountType = _accountType;
        accountInfoList[_accountNo].currency = _currency;
        accountInfoList[_accountNo].balance = _balance;
        accountInfoList[_accountNo].userId = _userId;
        accountInfoList[_accountNo].createTimestamp = block.timestamp;
        accountInfoList[_accountNo].updateTimestamp = block.timestamp;
        accountInfoList[_accountNo].delFlg = false;
        
        userAccountIndex[_userId].push(_accountNo);
		
		return true;
	}
    
    //口座閉塞
    function deleteAccountInfo(bytes32 _accountNo) public returns(bool result) {
			
		// 口座の有無確認
        if(checkAccountExistence(_accountNo) == false){
            return false ;
        }
        
        accountInfoList[_accountNo].delFlg = true;
        
		return true;
	}

    // トランザクションの参照
	function getTransactionInfo(uint _transactionId) public constant returns(bytes32[13] transactionInfo) {
			
		// ユーザ情報の参照
		transactionInfo[0] = bytes32(transactionInfoList[_transactionId].transactionId);
		transactionInfo[1] = bytes32(transactionInfoList[_transactionId].transactionStatus);
		transactionInfo[2] = bytes32(transactionInfoList[_transactionId].transactionType);
		transactionInfo[3] = transactionInfoList[_transactionId].fromAccountNo;
		transactionInfo[4] = transactionInfoList[_transactionId].toAccountNo;
		transactionInfo[5] = transactionInfoList[_transactionId].fromAccountHolderName;
		transactionInfo[6] = transactionInfoList[_transactionId].toAccountHolderName;
		transactionInfo[7] = transactionInfoList[_transactionId].fromCurrency;
		transactionInfo[8] = transactionInfoList[_transactionId].toCurrency;
        transactionInfo[9] = transactionInfoList[_transactionId].rate;
		transactionInfo[10] = bytes32(transactionInfoList[_transactionId].fromPrinc);
		transactionInfo[11] = bytes32(transactionInfoList[_transactionId].toPrinc);
		transactionInfo[12] = bytes32(transactionInfoList[_transactionId].timestamp);

        return transactionInfo;
	}	

    // 振込
	function transfer(uint _transactionType,bytes32 _fromAccountNo,bytes32 _toAccountNo,bytes32 _fromAccountHolderName,bytes32 _toAccountHolderName,bytes32 _fromCurrency,bytes32 _toCurrency,bytes32 _rate,uint _fromPrinc,uint _toPrinc) public returns(bool result) {
			
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
        transactionInfoList[transactionCounter].transactionType = _transactionType ;

        transactionInfoList[transactionCounter].fromAccountNo = _fromAccountNo ;
        transactionInfoList[transactionCounter].toAccountNo = _toAccountNo ;

        transactionInfoList[transactionCounter].fromAccountHolderName = _fromAccountHolderName ;
        transactionInfoList[transactionCounter].toAccountHolderName = _toAccountHolderName ;

        transactionInfoList[transactionCounter].fromCurrency = _fromCurrency ;
        transactionInfoList[transactionCounter].toCurrency =  _toCurrency ;
        transactionInfoList[transactionCounter].rate = _rate ;

        transactionInfoList[transactionCounter].fromPrinc =  _fromPrinc ;
        transactionInfoList[transactionCounter].toPrinc =  _toPrinc ;

        transactionInfoList[transactionCounter].timestamp = block.timestamp ;        

        //残高の増減
        accountInfoList[_fromAccountNo].balance = accountInfoList[_fromAccountNo].balance - _fromPrinc;
        accountInfoList[_fromAccountNo].updateTimestamp = block.timestamp;
        accountInfoList[_toAccountNo].balance = accountInfoList[_toAccountNo].balance + _toPrinc;
        accountInfoList[_toAccountNo].updateTimestamp = block.timestamp;
        
        //インデックスの登録
        userTransactionIndex[accountInfoList[_fromAccountNo].userId].push(transactionCounter);
        if(accountInfoList[_fromAccountNo].userId != accountInfoList[_toAccountNo].userId){
            userTransactionIndex[accountInfoList[_toAccountNo].userId].push(transactionCounter);        
        }
        
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

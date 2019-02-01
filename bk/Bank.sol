contract Bank {

// --�X�g���N�`����` Start--
	// ���[�U���
	struct UserInfo {
		// ���[�UID
		uint userId;
		// ���[�U��
		bytes32 userName;
        // ���[�U�[�Z��
        bytes32 userAddress;
        // �폜�t���O
		bool delFlg;
	}

	// �������
	struct AccountInfo {
		// ����Address
		bytes32 accountNo;
		// �������
		uint accountType;
		// �ʉ�
		bytes32 currency;
		// �c��
		uint balance;
		// ���[�UID
		uint userId;
		// �쐬�^�C���X�^���v
		uint createTimestamp;
		// �X�V�^�C���X�^���v
		uint updateTimestamp;
        // �폜�t���O
        bool delFlg;
	}

	// �������N�G�X�g���
	struct RequestInfo {
        // ���N�G�X�gID
        uint requestId;
        // �X�e�[�^�X�i�v���A�����A���ہj
        uint requestStatus;
        // ���N�G�X�g��ʁi����O�ׂ̂݁j
        uint requestType;
        // �L���b�V���A�E�g����
        bytes32 outAccountNo;
        // �L���b�V���C������
        bytes32 inAccountNo;
        // �L���b�V���A�E�g�ʉ�
        bytes32 outCurrency;
        // �L���b�V���C���ʉ�
        bytes32 inCurrency;
        // ���[�g�i��4�������_�j
        bytes32 rate;
        // �L���b�V���A�E�g���z
        uint outPrinc;
        // �L���b�V���C�����z
        uint inPrinc;
        // �v���^�C���X�^���v
        uint requestTimestamp;
        // �����^�C���X�^���v
        uint replyTimestamp;
	}

	// �בփg�����U�N�V����
	struct TransactionInfo {
        // �g�����U�N�V����ID
        uint transactionId;
        // �X�e�[�^�X�i����0�̂݁j
        uint transactionStatus;
        // �����ʁi����A�בւ̂݁j
        uint transactionType;
        // ����������
        bytes32 fromAccountNo;
        // ���������
        bytes32 toAccountNo;
        // �������ʉ�
        bytes32 fromCurrency;
        // ������ʉ�
        bytes32 toCurrency;
        // ���[�g
        bytes32 rate;
        // ���������{
        uint fromPrinc;
        // �����挳�{
        uint toPrinc;
        // �^�C���X�^���v
        uint timestamp;
	}
// --�X�g���N�`����` End--

// --�萔��` Start--
	// �v���X�e�[�^�X-�v��
	uint constant REQUESTING = 0;
	// �v���X�e�[�^�X-����
	uint constant REQUEST_OK = 1;
	// �v���X�e�[�^�X-����
	uint constant REQUEST_NG = 2;
    // ��s�̌����ԍ�
    bytes32 constant BANK_ACCOUNT_NO = "0" ;
    // ��s�̌ڋq�ԍ�
    uint constant BANK_USER_ID = 0 ;
    // ������(����)
    uint constant TRN_TYPE_NAI = 0;
    // ������(�O��)
    uint constant TRN_TYPE_GAI = 1;
    
// --�萔��` End--

// --�ϐ���` Start--	
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
// --�ϐ���` End--

// --Public�֐���` Start--
    // index���X�g�̎擾
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
    // index���X�g�̎擾
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
    // index���X�g�̎擾
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

	// ���[�U�̎Q��
	function getUserInfo(uint _userId) constant returns(bytes32[3] userInfo) {
			
		// ���[�U���̎Q��
		userInfo[0] = bytes32(userInfoList[_userId].userId);
        userInfo[1] = userInfoList[_userId].userName;
        userInfo[2] = userInfoList[_userId].userAddress;

		return userInfo;
	}
    // ���[�U�̓o�^
	function registUserInfo(bytes32 _userName, bytes32 _userAddress) returns(uint userId) {
			
		// ���[�U���̓o�^
		userCounter++;
        userInfoList[userCounter].userId = userCounter;
		userInfoList[userCounter].userName = _userName;
        userInfoList[userCounter].userAddress = _userAddress;
		userInfoList[userCounter].delFlg = false;
		
		return userInfoList[userCounter].userId;
	}
	
	// ���[�U�̍X�V
	function updateUserInfo(uint _userId,bytes32 _userName, bytes32 _userAddress) returns(bool result) {
		
		// ���[�U�o�^���Ă��Ȃ��ꍇ�̓G���[��Ԃ�
		if (checkUserExistence(_userId) == false) {
			return false;
		}
		
		// ���[�U���̓o�^
		userInfoList[_userId].userName = _userName;
		userInfoList[_userId].userAddress = _userAddress;
		
		return true;
	}
	
	// ���[�U�̍폜
	function deleteUserInfo(uint _userId) returns(bool result) {
		
		// ���[�U�o�^���Ă��Ȃ��ꍇ�̓G���[��Ԃ�
		if (checkUserExistence(_userId) == false) {
			return false;
		}
		
		// @ToDo �폜�̂��߂̏�����ǉ�
		
		
		// ���[�U���̍X�V
		userInfoList[_userId].delFlg = true;
		
		return true;
	}
	// �����̎Q��
	function getAccountInfo(bytes32 _accountNo) constant returns(bytes32[5] accountInfo) {
			
		// ���[�U���̎Q��
		accountInfo[0] = accountInfoList[_accountNo].accountNo;
		accountInfo[1] = bytes32(accountInfoList[_accountNo].accountType);
		accountInfo[2] = accountInfoList[_accountNo].currency;
		accountInfo[3] = bytes32(accountInfoList[_accountNo].balance);
		accountInfo[4] = bytes32(accountInfoList[_accountNo].userId);

        return accountInfo;
	}	
    // �������
	function registAccountInfo(bytes32 _accountNo, uint _accountType,bytes32 _currency,uint _userId) returns(bool result) {
			
		// �������̓o�^
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
    
    //������
    function deleteAccountInfo(bytes32 _accountNo) returns(bool result) {
			
		// �����̗L���m�F
        if(checkAccountExistence(_accountNo) == false){
            return false ;
        }
        
        accountInfoList[_accountNo].delFlg = true;
        
		return true;
	}

    // ���N�G�X�g�̎Q��
	function getRequestInfo(uint _requestId) constant returns(bytes32[12] requestInfo) {
			
		// ���[�U���̎Q��
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
    // �g�����U�N�V�����̎Q��
	function getTransactionInfo(uint _transactionId) constant returns(bytes32[11] transactionInfo) {
			
		// ���[�U���̎Q��
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

    //����
	function request(bytes32 _outAccountNo,bytes32 _inAccountNo,bytes32 _outCurrency,bytes32 _inCurrency,bytes32 _rate,uint _outPrinc,uint _inPrinc) returns(bool result) {
			
		// �������̓o�^
        requestCounter++ ;
        requestInfoList[requestCounter].requestStatus = REQUESTING;
        requestInfoList[requestCounter].outAccountNo = _outAccountNo;
        requestInfoList[requestCounter].inAccountNo = _inAccountNo;
        requestInfoList[requestCounter].outCurrency = _outCurrency;
        requestInfoList[requestCounter].inCurrency = _inCurrency;
        requestInfoList[requestCounter].rate = _rate;
        requestInfoList[requestCounter].outPrinc = _outPrinc;
        requestInfoList[requestCounter].inPrinc = _inPrinc;
        
        //���[�U�C���f�b�N�X�̍쐬
        userRequestIndex[accountInfoList[_outAccountNo].userId].push(requestCounter);
	
		return true;
	}
    //����
	function reply(uint _requestNo,bool _isOk) returns(bool result) {
			
		// ��������
        if(_isOk == false){
            requestInfoList[_requestNo].requestStatus = REQUEST_NG ;
            return true ;
        }
        // �o�����̒ʉ݃`�F�b�N
        if(accountInfoList[requestInfoList[_requestNo].outAccountNo].currency != requestInfoList[_requestNo].outCurrency){
            requestInfoList[_requestNo].requestStatus = REQUEST_NG ;
            return true ;            
        }
        // �o�����̎c���`�F�b�N
        if(accountInfoList[requestInfoList[_requestNo].outAccountNo].balance < requestInfoList[_requestNo].outPrinc){
            requestInfoList[_requestNo].requestStatus = REQUEST_NG ;
            return true ;            
        }

        // ����
        requestInfoList[_requestNo].requestStatus = REQUEST_OK ;

        //TODO ��s����̏o���`�F�b�N��g�����U�N�V�����������K�v
        //�o���g�����U�N�V�����̓o�^
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


        //�����g�����U�N�V�����̓o�^
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

        //�c���̑���
        accountInfoList[requestInfoList[_requestNo].outAccountNo].balance = accountInfoList[requestInfoList[_requestNo].outAccountNo].balance
         - requestInfoList[_requestNo].outPrinc;
        accountInfoList[requestInfoList[_requestNo].inAccountNo].balance = accountInfoList[requestInfoList[_requestNo].inAccountNo].balance
         + requestInfoList[_requestNo].inPrinc;
        
        
        return true;
	}
    //�U��
	function transfer(bytes32 _fromAccountNo,bytes32 _toAccountNo,bytes32 _fromCurrency,bytes32 _toCurrency,bytes32 _rate,uint _fromPrinc,uint _toPrinc) returns(bool result) {
			
        // �o�����̒ʉ݃`�F�b�N
        if(accountInfoList[_fromAccountNo].currency != _fromCurrency){
            return false ;            
        }
        // �o�����̎c���`�F�b�N
        if(accountInfoList[_fromAccountNo].balance < _fromPrinc){
            return false ;
        }

        //�g�����U�N�V�����̓o�^
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

        //�c���̑���
        accountInfoList[_fromAccountNo].balance = accountInfoList[_fromAccountNo].balance - _fromPrinc;
        accountInfoList[_toAccountNo].balance = accountInfoList[_toAccountNo].balance + _toPrinc;
        
        return true;
	}
    
    
 
// --Public�֐���` End--

// --Private�֐���` Start--
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
// --Private�֐���` End--
}

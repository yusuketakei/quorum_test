pragma solidity ^0.4.0;

import "./Auth.sol" ;

contract UserInfo {

// --ストラクチャ定義 Start--
	// ユーザ情報
	struct UserInfo {
		// ユーザID
		uint userId;
		// ユーザ名
		bytes32 userName;
        // ユーザー管理用のAccountAddress
        address userEthAddress;
        // IPFSHash(前半部)
        bytes32 userHashFirst
        // IPFSHash(後半部)
        bytes32 userHashSecond    
		// ユーザ認証ハッシュ
		bytes32 userAuthHash;
        // 削除フラグ
		bool delFlg;
	}

// --変数定義 Start--	
	mapping (uint => UserInfo) private userInfoList;
    Auth private auth ;
    
// --変数定義 End--

// --関数定義 Start--

    //AuthLogicSetter
    function setAuthAddress(address _authAddress) public returns(){
        auth = Auth(_authAddress) ;
    }

	//Accessor
	function getUserId(uint _userId) external constant returns (uint userId){
		return userInfoList[_userId].userId ;
	}
	function getUserName(uint _userId) external constant returns (bytes32 userName){
		return userInfoList[_userId].userName ;
	}
	function getUserEthAddress(uint _userId) external constant returns (address userEthAddress){
		return userInfoList[_userId].userEthAddress ;
	}
	function getUserHashFirst(uint _userId) external constant returns (bytes32 userHashFirst){
		return userInfoList[_userId].userHashFirst ;
	}
	function getUserHashSecond(uint _userId) external constant returns (bytes32 userHashSecond){
		return userInfoList[_userId].userHashSecond ;
	}
    function getUserDelFlg(uint _userId) external constant returns (bool delFlg){
        return userInfoList[_userId].delFlg ;
    }

	function setUserId(uint _userId) external (){
        userInfoList[_userId].userId = _userId ;
    }
	function setUserName(uint _userId,bytes32 _userName) external (){
        userInfoList[_userId].userName = _userId ;
    }
	function setUserEthAddress(uint _userId,address _userEthAddress) external (){
        userInfoList[_userId].userEthAddress = _userEthAddress ;
    }
	function setUserHashFirst(uint _userId,bytes32 _userHashFirst) external (){
        userInfoList[_userId].userHashFirst = _userHashFirst ;
    }
	function setUserHashSecond(uint _userId,bytes32 _userHashSecond) external (){
        userInfoList[_userId].userHashSecond = _userHashSecond ;
    }
	function setUserDelFlg(uint _userId,bytes32 _userDelFlg) external (){
        userInfoList[_userId].userDelFlg = _userDelFlg ;
    }

    //Authentication 取扱要注意
    function setUserAuthHash(uint _userId,bytes32 _hashParam1,bytes32 _hashParam2,bytes32 _hashParams3) external returns (bool){
        userInfoList[_userId].userAuthHash = auth.generateAuthHash(_hashParam1,_hashParam2,_hashParams3) ;
        return true ;
    }
    function verifyAuthHash(uint _userId,bytes32 _authHash) external constant returns(bool){
        if(userInfoList[_userId].userAuthHash == _authHash){
            return true ;
        }else{
            return false ;
        }
    }
    function generateUserAuthHash(bytes32 _hashParam1,bytes32 _hashParam2,bytes32 _hashParams3) external returns (bytes32 authHash){
        return auth.generateAuthHash(_hashParam1,_hashParam2,_hashParams3) ;
    }

}

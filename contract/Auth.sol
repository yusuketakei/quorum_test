pragma solidity ^0.4.0;

contract Auth {

// --定数定義 Start--	
uint constant private salt1 = 145 ;
uint constant private salt2 = 1086 ;

// --定数定義 End--

// --関数定義 Start--

	function generateAuthHash(bytes32 _hashParam1,bytes32 _hashParam2,bytes32 _hashParam3) public constant returns (bytes32 authHash){
        bytes32[5] memory hashParamArray ;

        hashParamArray[0] = bytes32(salt1) ;
        hashParamArray[1] = bytes32(_hashParam1) ;
        hashParamArray[2] = bytes32(_hashParam2) ;
        hashParamArray[3] = bytes32(_hashParam3) ;
        hashParamArray[4] = bytes32(salt2) ;
    
        authHash = keccak256(hashParamArray) ; 
        
        return authHash ;
	}
}
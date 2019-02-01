pragma solidity ^0.4.20;

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd
contract ERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint _tokenId, bytes data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to ""
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint _tokenId) external payable;

    /// @notice Set or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    /// @dev Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets.
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

contract ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

// contract ERC721TokenReceiver {
//     /// @notice Handle the receipt of an NFT
//     /// @dev The ERC721 smart contract calls this function on the
//     /// recipient after a `transfer`. This function MAY throw to revert and reject the transfer. Return
//     /// of other than the magic value MUST result in the transaction being reverted.
//     /// @notice The contract address is always the message sender. 
//     /// @param _operator The address which called `safeTransferFrom` function
//     /// @param _from The address which previously owned the token
//     /// @param _tokenId The NFT identifier which is being transferred
//     /// @param _data Additional data with no specified format
//     /// @return `bytes4(keccak256("onERC721Received(address,address,uint,bytes)"))`
//     /// unless throwing
//     function onERC721Received(address _operator, address _from, uint _tokenId, bytes _data) external returns(bytes4);
//  }

//contract TicketTokenInterface is ERC721 {
    /// @notice チケット共通プラットフォームが実装するべきチケットトークンのインターフェース。ERC721の拡張
//}

contract TicketToken is ERC721 {
    // TicketTokenを実装するabstract contract
    //-- ストラクチャ --
    struct Ticket {
        // ID
        uint ticketId ;
        // ID for management in internal systems
        uint ticketInternalId ;
        // ticket issuer address
        address ticketIssuer ;
        // ticket issue time
        uint issueTime ;        
        // ticket実装におけるカテゴリ（福祉、子育てなど）
        bytes32 ticketCategoryName ;
        // IPFS用ハッシュ前半32bit
        bytes32 IPFSHashFirst ;
        // IPFS用ハッシュ後半32bit
        bytes32 IPFSHashSecond ;        
        // status
        uint ticketStatus ;
    }
    Ticket[] private tickets ;
    
    // --constant--
    uint constant TICKET_STATUS_ACTIVE = 0;
    uint constant TICKET_STATUS_INACTIVE = 9;
    

    // --index--
    // チケットIDからownerを引くインデックス
    mapping (uint => address) public ticketToOwnerIndex ;
    // ownerからチケットIDを引くインデックス
    mapping (address => uint) public ownerToTicketIndex ;
    // ownerのもつチケットIDリスト
    mapping (address => uint[]) public ownedTicketList ;
    // ownerのもつチケットのIDリストにおける位置を引くインデックス
    mapping(uint => uint) private ownedTicketListIndex ;
    // チケットIDからApproved Accountを引くインデックス
    mapping (uint => address) public ticketToApprovedIndex ;
    
	// --event--
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
	
    // --support interface checking--
    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint)')) ^
        bytes4(keccak256('approve(address,uint)')) ^
        bytes4(keccak256('transfer(address,uint)')) ^
        bytes4(keccak256('transferFrom(address,address,uint)')) ^
        bytes4(keccak256('tokensOfOwner(address)')) ^
        bytes4(keccak256('tokenMetadata(uint,string)'));

    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).
    ///  Returns true for any standardized interfaces implemented by this contract. We implement
    ///  ERC-165 (obviously!) and ERC-721.
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    /// @dev チケットIDの所有者チェック
    /// @param _claimant the address we are validating against.
    /// @param _tokenId tokenId
    function _owns(address _claimant, uint _tokenId) internal view returns (bool) {
        return ticketToOwnerIndex[_tokenId] == _claimant;
    }
    
  /// @notice Internal function to add a ticket ID to the list of a given address
  /// @param _to address representing the new owner of the given ticket ID
  /// @param _ticketId uint ID of the token to be added to the ticket list of the given address
  function _addTicket(address _to, uint256 _ticketId) internal {
    ticketToOwnerIndex[_ticketId] = _to;
    uint length = _balanceOf(_to);
    ownedTicketList[_to].push(_ticketId);
    //ownedTicketListIndexは当該チケットIdのownedTicketListにおけるインデックスを表現
    ownedTicketListIndex[_ticketId] = length;
  }
 
  /// @notice Internal function to remove a ticket ID from the list of a given address
  /// @param _from address representing the previous owner of the given token ID
  /// @param _ticketId uint256 ID of the token to be removed from the tokens list of the given address
  function _removeTicket(address _from, uint256 _ticketId) internal {
    uint ticketIndex = ownedTicketListIndex[_ticketId];
    uint lastTicketIndex = _balanceOf(_from)-1;
    uint lastTicket = ownedTicketList[_from][lastTicketIndex];

    ticketToOwnerIndex[_ticketId] = 0;
    ownedTicketList[_from][ticketIndex] = lastTicket;
    ownedTicketList[_from][lastTicketIndex] = 0;
    // 削除対象のTicketと最後のチケットをスワップして、最後のチケットを初期化することによって、リストからの削除を実現している
    // 普通に要素削除しようとすると各要素のインデックスを１ずつ繰り上げる更新をしなくてはならず、
    // そうするとContractにおける計算量が増えてしまうため、あえてこういったやり方をする
    
    ownedTicketList[_from].length--;
    ownedTicketListIndex[_ticketId] = 0;
    ownedTicketListIndex[lastTicket] = ticketIndex;
  }    
    /// @dev Assigns ownership of a specific Kitty to an address.
    function _transfer(address _from, address _to, uint _tokenId) internal {
        require(_owns(_from,_tokenId));
        // transfer ownership
        _removeTicket(_from,_tokenId) ;
        _addTicket(_to,_tokenId) ;

   		// clear any previously approved ownership exchange
        delete ticketToApprovedIndex[_tokenId];
        
        // Emit the transfer event.
        //emit Transfer(_from, _to, _tokenId);
    }
    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting tickets on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _approve(uint256 _tokenId, address _approved) internal {
        ticketToApprovedIndex[_tokenId] = _approved;
    }

    /// @dev Checks if a given address currently has transferApproval for a particular Ticket.
    /// @param _claimant the address we are confirming ticket is approved for.
    /// @param _tokenId ticket id, only valid when > 0
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return ticketToApprovedIndex[_tokenId] == _claimant;
    }

    function _transferFrom(address _from,address _to,uint256 _tokenId) internal {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any tickets (except very briefly
        // after a gen0 cat is created and before it goes on auction).
        require(_to != address(this));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    function _safeTransferFrom(address _to,address _from,uint256 _tokenId,bytes data) internal {
        _transferFrom(_from,_to,_tokenId) ;
        // if (_isContract(_to)) {
        //   bytes4 tokenReceiverResponse = ERC721TokenReceiver(_to).onERC721Received.gas(50000)(
        //     _from, _tokenId, _data
        //   );
        //   require(tokenReceiverResponse == bytes4(keccak256("onERC721Received(address,uint256,bytes)")));
        // }
    }
    
    /// @notice Returns the number of Tickets owned by a specific address.
    /// @param _owner The owner address to check.
    /// @dev Required for ERC-721 compliance
    function _balanceOf(address _owner) internal view returns (uint256 count) {
        return ownedTicketList[_owner].length;
    }

    /// @notice Returns the number of Tickets owned by a specific address.
    /// @param _owner The owner address to check.
    /// @dev Required for ERC-721 compliance
    function balanceOf(address _owner) external view returns (uint256 count) {
        return _balanceOf(_owner);
    }

    function transfer(
        address _to,
        uint _tokenId
    )
        external
    {
        // Safety check to prevent against an unexpected 0x0 default. 
        require(_to != address(0));
        require(_to != address(this));

        // You can only send your own ticket.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    /// @notice Grant another address the right to transfer a specific Ticket via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Ticket that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function approve(
        address _to,
        uint256 _tokenId
    )
        external
        payable
    {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        //emit Approval(msg.sender, _to, _tokenId);
    }


    ///  @notice Gets the approved address to take ownership of a given token ID
    ///  @param _tokenId uint256 ID of the token to query the approval of
    ///  @return address currently approved to take ownership of the given token ID
    function getApproved(uint256 _tokenId) external view returns (address)
    {
        return ticketToApprovedIndex[_tokenId];
    }

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets.
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external 
    {
        /// @todo approval for operator(third party)
    }
    
    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool)
    {
        /// @todo validating approval for operator(third party)
    }

    /// @notice Transfer a Ticket owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Ticket to be transfered.
    /// @param _to The address that should take ownership of the Ticket. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Ticket to be transferred.
    /// @dev Required for ERC-721 compliance.
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
        payable
    {
        _transferFrom(_from,_to,_tokenId) ;
    }

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(
        address _from, 
        address _to, 
        uint _tokenId, 
        bytes data) external payable 
    {
        _safeTransferFrom(_from,_to,_tokenId,data) ;
    }

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to ""
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(
        address _from, 
        address _to, 
        uint _tokenId) external payable
    {
        _safeTransferFrom(_from,_to,_tokenId,"") ;
    }


    /// @notice Returns the total number of Tickets currently in existence.
    /// @dev Required for ERC-721 compliance.
    function totalSupply() public view returns (uint) {
        return tickets.length;
    }
    
    /// @notice Returns the address currently assigned ownership of a given Ticket.
    /// @dev Required for ERC-721 compliance.
    function ownerOf(uint256 _tokenId)
        external
        view
        returns (address owner)
    {
        owner = ticketToOwnerIndex[_tokenId];

        //require(owner != address(0));
    }
    
    /// @notice Returns a list of all Ticket IDs assigned to an address.
    /// @param _owner The owner whose Tickets we are interested in.
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
    ///  expensive (it walks the entire Ticket array looking for tickets belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = _balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTickets = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all cats have IDs starting at 1 and increasing
            // sequentially up to the totalTickets count.
            uint256 ticketId;

            for (ticketId = 1; ticketId <= totalTickets; ticketId++) {
                if (ticketToOwnerIndex[ticketId] == _owner) {
                    result[resultIndex] = ticketId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

    /// @notice Returns a Ticket Information of given ID
    /// @param _ticketId givenId
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
    ///  expensive (it walks the entire Ticket array looking for tickets belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function getTicketInfoById(uint _ticketId) external view returns(bytes32[7] ticketInfo) {
        //ticketIdは1から始めるので、添え字は-1
        uint ticketIndex = _ticketId-1 ;
        
        //チェック
        require(tickets[ticketIndex].ticketId != 0) ;

        ticketInfo[0] = (bytes32)(tickets[ticketIndex].ticketId) ;
        ticketInfo[1] = (bytes32)(tickets[ticketIndex].ticketInternalId) ;
        ticketInfo[2] = tickets[ticketIndex].ticketCategoryName ;
        ticketInfo[3] = tickets[ticketIndex].IPFSHashFirst ;
        ticketInfo[4] = tickets[ticketIndex].IPFSHashSecond ;
        ticketInfo[5] = (bytes32)(tickets[ticketIndex].ticketIssuer) ;
        ticketInfo[6] = bytes32(tickets[ticketIndex].issueTime) ;       

        return ticketInfo ;
    }


    /// @notice issue a ticket token 
    /// @param _ticketInternalId TicketIssuerが内部システムで管理している場合のID
    /// @param _ticketCategoryName Ticketのカテゴリ(参照情報)
    /// @param _IPFSHashFirst IPFSに格納している情報のハッシュにおける先頭32byte分
    /// @param _IPFSHashSecond IPFSに格納している情報のハッシュにおける後半32byte分
    /// @dev 基本的にはサービスプロバイダーの保有するアカウントだけがticketの発行を可能
    function issueTicket(uint _ticketInternalId,bytes32 _ticketCategoryName,bytes32 _IPFSHashFirst,bytes32 _IPFSHashSecond) external {
        // ticketIdは1からはじめる
        uint newTicketId = tickets.length + 1;
        
        // // チケット情報の作成
        Ticket memory newTicket ;
        newTicket.ticketId = newTicketId ;
        newTicket.ticketInternalId = _ticketInternalId ;
        newTicket.ticketCategoryName = _ticketCategoryName ;
        newTicket.IPFSHashFirst = _IPFSHashFirst ;
        newTicket.IPFSHashSecond = _IPFSHashSecond ;
        newTicket.ticketIssuer = msg.sender ;
        newTicket.issueTime = block.timestamp ;
        newTicket.ticketStatus = TICKET_STATUS_ACTIVE ;
        tickets.push(newTicket) ;
        
        _addTicket(msg.sender,newTicketId) ;
    }
}

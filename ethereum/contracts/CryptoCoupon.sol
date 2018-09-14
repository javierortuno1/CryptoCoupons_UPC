   pragma solidity ^0.4.18;
    
    import "./AccessControl.sol";
    import "./ERC721.sol";
    import "./SafeMath.sol";
    
    
    
    contract DetailedERC721 is ERC721 {
        function name() public view returns (string _name);
        function symbol() public view returns (string _symbol);
    }
  
    
    contract CryptoCouponFactory {
        address[] public deployedCryptoCoupons;
    
        function createCryptoCoupon(string name, address owner) public {
            address newCoupon = new CryptoCoupon(name, owner);
            deployedCryptoCoupons.push(newCoupon);
        }
    
        function getDeployedCryptoCoupons() public view returns (address[]) {
            return deployedCryptoCoupons;
        }
    }
    
    
    contract CryptoCoupon is AccessControl, DetailedERC721 {
        using SafeMath for uint256;
        address public owner;
        string public name;
        event TokenCreated(uint256 tokenId, string name, uint256 serialNumber, uint256 price, address owner);
        event TokenSold(
            uint256 indexed tokenId,
            string name,
            uint256 Price,
            address indexed oldOwner,
            address indexed newOwner
            );
    
        mapping (uint256 => address) private tokenIdToOwner;
        mapping (uint256 => uint256) private tokenIdToPrice;
        mapping (address => uint256) private ownershipTokenCount;
        mapping (uint256 => address) private tokenIdToApproved;
        //lottery
        address[] private players;
        address[] private helper;
        address private playerWinner;
        
        constructor(string _name, address _creator) public {
            owner = _creator;
            name = _name;
            ceoAddress = owner;
            cooAddress = ceoAddress;
        }
       
        struct Coupon {
            string name;
            string description;
            uint256 serialNumber;
            bool gift;
            uint8 value;
        }
    
        Coupon[] private coupons;
        uint256[] private couponsRaffle;
        uint256[] private couponsSaleCLevel;
        uint256[] private couponsSaleUser;
        uint cont = 0;
        
        
        function createToken(string _name, string _description, bool _gift, uint8 _value,
        address _owner, uint256 _price) public onlyCLevel {
            require(_owner != address(0));
    
            _createToken(_name, _description, cont, _gift, _value,
                    _owner, _price);
            
        }
        //ASSIGNED DEFAULT TOKEN TO cooAddress
        function createToken(string _name, string _description, bool _gift, uint8 _value) public onlyCEO {
            cont++;
            _createToken(_name, _description, cont, _gift, _value,
                  cooAddress, 0.01 ether);
        }
        //Se debe evaluar el gas consumido en lotes . If the remix crash, rise the gasLimit
         function createTokensBatch(string _name, string _description, bool _gift, uint8 _value, uint _numberOfTokens) public {
            for (uint i = 0; i < _numberOfTokens ; i++){
                cont++;
                _createToken(_name, _description, cont, _gift, _value,
                  cooAddress, 0.01 ether);
            }
            
        }
       
        function _createToken(string _name, string _description, uint256 _serialNumber, bool _gift,
                uint8 _value, address _owner, uint256 _price) private {
                    owner = _owner;
                    
            Coupon memory _Coupon = Coupon({
                name: _name,
                description: _description,
                serialNumber: _serialNumber,
                gift: _gift,
                value: _value
            });
            
            uint256 newTokenId = coupons.push(_Coupon) - 1;
            tokenIdToPrice[newTokenId] = _price;
        
            emit TokenCreated(newTokenId, _name, _serialNumber, _price, _owner);
            _transfer(address(0), _owner, newTokenId);
        }
        
        function getToken(uint256 _tokenId) public view returns (
            string _tokenName,
            string _tokenDescription,
            uint256 _tokenSerialNumber,
            bool _tokenGift,
            uint8 _tokenValue,
            address _owner,
            uint256 _price
            
        ) {
            _tokenName = coupons[_tokenId].name;
            _tokenDescription = coupons[_tokenId].description;
            _tokenSerialNumber = coupons[_tokenId].serialNumber;
            _tokenGift =coupons[_tokenId].gift;
            _tokenValue = coupons[_tokenId].value;
            _price = tokenIdToPrice[_tokenId];
            _owner = tokenIdToOwner[_tokenId];
        }
        
    // tabla donde cada columna es un token generado
        function getAllTokens() public view returns (
            uint256[],
            uint256[],
            address[]
        ) {
            uint256 total = totalSupply();
            uint256[] memory ids = new uint256[](total);
            uint256[] memory prices = new uint256[](total);
            address[] memory owners = new address[](total);
    
            for (uint256 i = 0; i < total; i++) {
                ids[i] = i;
                prices[i] = tokenIdToPrice[i];
                owners[i] = tokenIdToOwner[i];
            }
    
            return (ids, prices, owners);
        }
        
        function getAllCouponIds() public view returns(uint256[]){
            uint256 total = coupons.length;
            uint256[] memory ids = new uint256[](total);
    
            for (uint256 i = 0; i < total; i++) {
                ids[i] = coupons[i].serialNumber;
                
            }
    
            return (ids);
        }
        
        
        function withdrawBalance(address _to, uint256 _amount) public onlyCEO {
            require(_amount <= address(this).balance);
    
            if (_amount == 0) {
                _amount = address(this).balance;
            }
    
            if (_to == address(0)) {
                ceoAddress.transfer(_amount);
            } else {
                _to.transfer(_amount);
            }
        }
    
        function purchase(uint256 _tokenId) public payable whenNotPaused {
            require(!coupons[_tokenId].gift);
            address oldOwner = ownerOf(_tokenId);
            address newOwner = msg.sender;
            uint256 sellingPrice = priceOf(_tokenId);
            require(checkTokenIdExistsCLevel(_tokenId) || checkTokenIdExistsUser(_tokenId));
              
            require(oldOwner != address(0));
            require(newOwner != address(0));
            require(oldOwner != newOwner);
            require(!_isContract(newOwner));
            require(sellingPrice > 0);
            require(msg.value >= sellingPrice);
    
            _transfer(oldOwner, newOwner, _tokenId);
            emit TokenSold(
                _tokenId,
                coupons[_tokenId].name,
                sellingPrice,
                oldOwner,
                newOwner
            );
    
            uint256 excess = msg.value.sub(sellingPrice);
            uint256 contractCut = sellingPrice.mul(6).div(100); // 6% cut
    
            if (oldOwner != address(this)) {
                oldOwner.transfer(sellingPrice.sub(contractCut));
            }
    
            if (excess > 0) {
                newOwner.transfer(excess);
            }
            uint256 i; 
            
            if(checkTokenIdExistsCLevel(_tokenId)){
               for(i = 0; i < couponsSaleCLevel.length; i++){
                if(couponsSaleCLevel[i] ==_tokenId){
                    
                    couponsSaleCLevel[i] = couponsSaleCLevel[couponsSaleCLevel.length - 1];
                    delete couponsSaleCLevel[couponsSaleCLevel.length - 1];
                    couponsSaleCLevel.length--;
    
                }
               }
            }
            
            
            
            if(checkTokenIdExistsUser(_tokenId)){
                deleteCouponFromSaleUser(_tokenId);
            }
            
        
        }
    
        function priceOf (uint256 _tokenId) public view returns (uint256 _price) {
            return tokenIdToPrice[_tokenId];
        }    
        
        function tokensOf(address _owner) public view returns(uint256[]) {
            uint256 tokenCount = balanceOf(_owner);
            if (tokenCount == 0) {
                return new uint256[](0);
            } else {
                uint256[] memory result = new uint256[](tokenCount);
                uint256 total = totalSupply();
                uint256 resultIndex = 0;
    
                for (uint256 i = 0; i < total; i++) {
                    if (tokenIdToOwner[i] == _owner) {
                        result[resultIndex] = i;
                        resultIndex++;
                    }
                }
                return result;
            }
        }
    
        function totalSupply() public view returns (uint256 _totalSupply) {
            _totalSupply = coupons.length;
        }
    
        function balanceOf(address _owner) public view returns (uint256 _balance) {
            _balance = ownershipTokenCount[_owner];
        }
    
        function ownerOf(uint256 _tokenId) public view returns (address _owner) {
            _owner = tokenIdToOwner[_tokenId];
        }
    
        function approve(address _to, uint256 _tokenId) public whenNotPaused {
            require(_owns(msg.sender, _tokenId));
            tokenIdToApproved[_tokenId] = _to;
            emit Approval(msg.sender, _to, _tokenId);
        }
        
        function cancelApproval(address _to,uint256 _tokenId ) public whenNotPaused {
            require(_owns(msg.sender, _tokenId));
            tokenIdToApproved[_tokenId] = address(0);
            emit Approval(msg.sender, _to, _tokenId);
        }
    
        function transferFrom(address _from, address _to, uint256 _tokenId) public whenNotPaused {
            require(_to != address(0));
            require(_owns(_from, _tokenId));
            require(_approved(msg.sender, _tokenId));
    
            _transfer(_from, _to, _tokenId);
        }
        // REGALAR UN COUPON
        function transfer(address _to, uint256 _tokenId) public whenNotPaused {
            require(_to != address(0));
            require(_owns(msg.sender, _tokenId));
    
            _transfer(msg.sender, _to, _tokenId);
        }
    
        // Not usefull.
        function takeOwnership(uint256 _tokenId) public whenNotPaused {
            require(_approved(msg.sender, _tokenId));
            _transfer(tokenIdToOwner[_tokenId], msg.sender, _tokenId);
        }
    
        function name() public view returns (string _name) {
            _name = name;
        }
    
        function symbol() public view returns (string _symbol) {
            _symbol = name;
        }
    
        function _owns(address _claimant, uint256 _tokenId) private view returns (bool) {
            return tokenIdToOwner[_tokenId] == _claimant;
        }
    
        function _approved(address _to, uint256 _tokenId) private view returns (bool) {
            return tokenIdToApproved[_tokenId] == _to;
        }
    
        function _transfer(address _from, address _to, uint256 _tokenId) private {
            ownershipTokenCount[_to]++;
            tokenIdToOwner[_tokenId] = _to;
    
            if (_from != address(0)) {
                ownershipTokenCount[_from]--;
                delete tokenIdToApproved[_tokenId];
            }
    
            emit Transfer(_from, _to, _tokenId);
        }
        
        function _appendUintToString(string inStr, uint v) private pure returns (string str) {
            uint maxlength = 100;
            bytes memory reversed = new bytes(maxlength);
            uint i = 0;
            while (v != 0) {
                uint remainder = v % 10;
                v = v / 10;
                reversed[i++] = byte(48 + remainder);
            }
            bytes memory inStrb = bytes(inStr);
            bytes memory s = new bytes(inStrb.length + i);
            uint j;
            for (j = 0; j < inStrb.length; j++) {
                s[j] = inStrb[j];
            }
            for (j = 0; j < i; j++) {
                s[j + inStrb.length] = reversed[i - 1 - j];
            }
            str = string(s);
        }
        
      function burn(address _owner, uint256 _tokenId) public onlyCLevel {
        clearApproval(_owner, _tokenId);
        removeTokenFrom(_owner, _tokenId);
        emit Transfer(_owner, address(0), _tokenId);
      }
    
      function redeemCoupon(uint256 _tokenId) public {
          require(ownerOf(_tokenId)== msg.sender);
          transfer(ceoAddress, _tokenId);
      }  
      
      function reUseCoupon(uint256 _tokenId, string _name, string _description,
      bool _gift, uint8 _value, address _owner, uint256 _price) public onlyCLevel{
          require(ownerOf(_tokenId)== msg.sender);
          
          coupons[_tokenId].name = _name;
          coupons[_tokenId].description = _description;
          coupons[_tokenId].gift = _gift;
          coupons[_tokenId].value = _value;
          tokenIdToPrice[_tokenId] = _price;
          tokenIdToOwner[_tokenId] = _owner;
      }
      
      function clearApproval(address _owner, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _owner);
        if (tokenIdToApproved[_tokenId] != address(0)) {
          tokenIdToApproved[_tokenId] = address(0);
        }
      }
    
    
      function removeTokenFrom(address _from, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from);
        ownershipTokenCount[_from] = ownershipTokenCount[_from].sub(1);
        tokenIdToOwner[_tokenId] = address(0);
      }
         
        function _isContract(address addr) private view returns (bool) {
            uint256 size;
            assembly { size := extcodesize(addr) }
            return size > 0;
        }
        
        // Entering to Lottery and allowing a player to participate just once
        function enterToLottery() public {
            require(!checkPlayerExists(msg.sender));
            players.push(msg.sender);
        }
        
       function getLotteryPlayers()public view returns(address[]){
           return players;
       }
       
       function numberPlayers() public view returns(uint256){
           return players.length;
       }
        
        //to check player
        function checkPlayerExists(address player) public constant returns(bool){
          for(uint256 i = 0; i < players.length; i++){
             if(players[i] == player) return true;
          }
          return false;
       }
       
       //to check TokenId exists for Raffle
        function checkTokenIdExistRaffle(uint256 _tokenId) private view returns(bool){
          for(uint256 i = 0; i < couponsRaffle.length; i++){
             if(couponsRaffle[i] ==_tokenId) return true;
          }
          return false;
        }
        
        function getTokenToRaffle() public view returns (uint256[]){
            return couponsRaffle;
        }
       
       //generate winner of token.
        function _winnerAddress() private view onlyCLevel returns(address) {
          //it depends of the condition
          //for now Generates a number between 1 and length of players that will be the winner
          uint256 numberGenerated = block.number % players.length + 1; // This isn't secure
          return players[numberGenerated];
       }
       
       
       
        function generateWinnerOfToken(uint256 _tokenId) public onlyCLevel {
         require(checkTokenIdExistRaffle(_tokenId));
                playerWinner = _winnerAddress();
                transfer(playerWinner, _tokenId);
                // Should we clean the array
                players = helper;
                // delete tokenID from Raffle
                for(uint256 i = 0; i < couponsRaffle.length; i++){
                    if(couponsRaffle[i] ==_tokenId){
                        couponsRaffle[i] = couponsRaffle[couponsRaffle.length - 1];
                        delete couponsRaffle[couponsRaffle.length - 1];
                        couponsRaffle.length--;
                    }
    
                }
            
       }
       
       function clearPlayerList() public onlyCLevel{
           players = helper;
       }
       
       function getLastWinner() public view returns(address){
           return playerWinner;
       }
       
       function getSummary() public view returns (
          string, uint, uint, address
          ) {
            return (
              name,
              address(this).balance,
              coupons.length,
              owner
            );
        }
    
        function getCouponsSaleCount() public view returns (uint) {
            return couponsSaleCLevel.length;
        }
        
        function getCouponsRaffleCount() public view returns (uint) {
            return couponsRaffle.length;
        }
        
         //Set Coupon for SALE onlyClevel
        function setCouponToSaleCLevel(uint256 _tokenId, uint256 _newPrice) public onlyCLevel {
            require(!coupons[_tokenId].gift);
            require(!checkTokenIdExistRaffle(_tokenId));
            require(ownerOf(_tokenId) == msg.sender);
            for(uint256 i = 0; i < couponsSaleCLevel.length; i++){
                if(couponsSaleCLevel[i] ==_tokenId)
                    return;
            }
             couponsSaleCLevel.push(_tokenId);
             
             if(_newPrice > 0){
                 tokenIdToPrice[_tokenId] = _newPrice;
             }
       
        }
        
         //Delete Coupon for SALE onlyClevel
         function deleteCouponFromSaleCLevel(uint256 _tokenId) public onlyCLevel {
           require(ownerOf(_tokenId)== msg.sender);
           require(!checkTokenIdExistsCLevel(_tokenId));
            for(uint256 i = 0; i < couponsSaleCLevel.length; i++){
                if(couponsSaleCLevel[i] ==_tokenId){
                    
                    couponsSaleCLevel[i] = couponsSaleCLevel[couponsSaleCLevel.length - 1];
                    delete couponsSaleCLevel[couponsSaleCLevel.length - 1];
                    couponsSaleCLevel.length--;
    
                }
            }
             
        }
        
         function getTokenToSellClevel() public view returns(uint256[]){
            return couponsSaleCLevel;
        }
        
        
        //Set Coupon for SALE User
        function setCouponToSaleUser(uint256 _tokenId, uint256 _newPrice) public  {
            require(ownerOf(_tokenId) == msg.sender);
            require(!coupons[_tokenId].gift);
            for(uint256 i = 0; i < couponsSaleUser.length; i++){
                if(couponsSaleUser[i] ==_tokenId){
                    return;
                }
            }
             couponsSaleUser.push(_tokenId);
             
             if(_newPrice > 0){
                 tokenIdToPrice[_tokenId] = _newPrice;
             }
       
        }
        
        function deleteCouponFromSaleUser(uint256 _tokenId) public  {
            require(ownerOf(_tokenId) == msg.sender);
            require(!checkTokenIdExistsUser(_tokenId));
            for(uint256 i = 0; i < couponsSaleUser.length; i++){
                if(couponsSaleUser[i]==_tokenId){
 
                    couponsSaleUser[i] = couponsSaleUser[couponsSaleUser.length - 1];
                    delete couponsSaleUser[couponsSaleUser.length - 1];
                    couponsSaleUser.length--;
                }
            }
             
        }
        
        
        
        function getTokenToSellUser() public view returns(uint256[]){
            return couponsSaleUser;
        }
        
        
        //to check TokenId exists for SALE onlyClevel
        function checkTokenIdExistsCLevel(uint256 _tokenId) public constant returns(bool){
          for(uint256 i = 0; i < couponsSaleCLevel.length; i++){
             if(couponsSaleCLevel[i] ==_tokenId) return true;
          }
          return false;
        }
        
        //to check TokenId exists for SALE User
        function checkTokenIdExistsUser(uint256 _tokenId) public constant returns(bool){
          for(uint256 i = 0; i < couponsSaleUser.length; i++){
             if(couponsSaleUser[i] == _tokenId) return true;
          }
          return false;
        }
        
         function setCouponToRaffle(uint256 _tokenId) public onlyCLevel {
            require(!checkTokenIdExistsCLevel(_tokenId));
            require(ownerOf(_tokenId) == msg.sender);
            for(uint256 i = 0; i < couponsRaffle.length; i++){
                if(couponsRaffle[i]==_tokenId)
                    return;
            }
             couponsRaffle.push(_tokenId);
       
        }
        
        function deleteCouponFromRaffle(uint256 _tokenId) public onlyCLevel{
           require(ownerOf(_tokenId) == msg.sender);
            for(uint256 i = 0; i < couponsRaffle.length; i++){
                if(couponsRaffle[i] ==_tokenId){
                    couponsRaffle[i] = couponsRaffle[couponsRaffle.length - 1];
                    delete couponsRaffle[couponsRaffle.length - 1];
                    couponsRaffle.length--;

                }
            }
        
       
        }
        
       
    
    }
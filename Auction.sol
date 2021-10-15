//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract CreateAuction{
    Auction[] public auctions;
    
    function createAuction() public{
        Auction newAuction = new Auction(msg.sender);
        auctions.push(newAuction);
    }
}

contract Auction{
    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    string ipfsHash;
    
    mapping(address => uint) public bidders;
    
    enum State{Running, Started, Ended, Canceled}
    State public auctionState;
    
    uint public highestBindingBid;
    address payable public highestBidder;
    
    uint incrementBid;
    
    constructor(address eoa){
        startBlock =  block.number;
        endBlock = startBlock + 4;
        owner = payable(eoa);
        ipfsHash = "";
        incrementBid = 1 ether;
        auctionState = State.Running;
        
    }
    
    modifier notOwner(){
        require(msg.sender != owner);
        _;
    }
    
    modifier afterStart(){
        require(block.number >= startBlock);
        _;
    }
    
    modifier beforeEnd(){
        require(block.number <= endBlock);
        _;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    function min(uint a, uint b) pure public returns(uint){
        if(a < b){
            return a;
        }else
            return b;
    }
    
    function placeBid() payable public notOwner afterStart beforeEnd{
        require(auctionState == State.Running);
        require(msg.value >= 100);
        
        uint currentBid = bidders[msg.sender] + msg.value;
        require(currentBid > highestBindingBid);
        
        bidders[msg.sender] = currentBid;
        if(currentBid <= bidders[highestBidder]){
            highestBindingBid = min(currentBid + incrementBid, bidders[highestBidder]);
        } else {
            highestBindingBid = min(currentBid, bidders[highestBidder] + incrementBid);
            highestBidder = payable(msg.sender);
        }
        
    }
    
    function cancelAuction() public onlyOwner(){
        auctionState = State.Canceled;
    }
    
    
    function finalizeAuction() payable public{
        require(auctionState == State.Canceled || block.number > endBlock);
        require(msg.sender == owner || bidders[msg.sender] > 0);
        
        address payable recipient;
        uint value;
        
        if(auctionState == State.Canceled){
            recipient = payable(msg.sender);
            value = bidders[msg.sender];
        }else {
            if(msg.sender == owner){
                recipient = owner;
                value = highestBindingBid;
            }else{
                if(msg.sender == highestBidder){
                    recipient = highestBidder;
                    value = bidders[highestBidder] - highestBindingBid;
                }else{
                    recipient = payable(msg.sender);
                    value = bidders[msg.sender];
                }
            }
        }
        
        bidders[msg.sender] = 0;
        recipient.transfer(value);
    }
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}
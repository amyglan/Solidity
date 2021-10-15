// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


interface cETH {
    
    // define functions of COMPOUND we'll be using
    
    function mint() external payable; // to deposit to compound
    function redeem(uint redeemTokens) external returns (uint); // to withdraw from compound
    
    //following 2 functions to determine how much you'll be able to withdraw
    function exchangeRateStored() external view returns (uint); 
    function balanceOf(address owner) external view returns (uint256 balance);
}


contract SmartBankAccount {


    uint totalContractBalance = 0;
    
    address COMPOUND_CETH_ADDRESS = 0x859e9d8a4edadfEDb5A2fF311243af80F85A91b8;
    cETH ceth = cETH(COMPOUND_CETH_ADDRESS);

    function getContractBalance() public view returns(uint){
        return totalContractBalance;
    }
    
    mapping(address => uint) balances;
    mapping(address => uint) depositTimestamps;
    
    function addBalance() public payable {
        uint256 cEthOfContractBeforeMinting = ceth.balanceOf(address(this)); //this refers to the current contract
        
        // send ethers to mint()
        ceth.mint{value: msg.value}();
        
        uint256 cEthOfContractAfterMinting = ceth.balanceOf(address(this)); // updated balance after minting
        
        uint cEthOfUser = cEthOfContractAfterMinting - cEthOfContractBeforeMinting; // the difference is the amount that has been created by the mint() function
        balances[msg.sender] = cEthOfUser;
        
    }
    
    function getBalance(address userAddress) public view returns(uint256) {
        return ceth.balanceOf(userAddress) * ceth.exchangeRateStored() / 1e18;
    }
    
    function withdraw() public payable {
        ceth.redeem(balances[msg.sender]);
        balances[msg.sender] = 0;
    }
    
    function addMoneyToContract() public payable {
        totalContractBalance += msg.value;
    }

    function getUserCethBalance() public view returns(uint){
        return balances[msg.sender];
    }
        
}
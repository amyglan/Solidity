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

contract SmartBankAccount{
    
    address COMPOUND_CETH_ADDRESS = 0x859e9d8a4edadfEDb5A2fF311243af80F85A91b8;
    cETH ceth = cETH(COMPOUND_CETH_ADDRESS);

    
    mapping(address => uint) balances;
   
    function addBalance() public payable {
        uint256 balanceBefore = ceth.balanceOf(address(this));
        ceth.mint{value: msg.value}();   //Now we need to deposit balance to compound to earn interest
        uint256 balanceAfter = ceth.balanceOf(address(this));
        uint difference = balanceAfter - balanceBefore; //to know the balance of a userAddress
        balances[msg.sender] = difference;
    }
    
    function getBalance(address userAddress) public view returns(uint) {
        return ceth.balanceOf(userAddress) * ceth.exchangeRateStored() / 1e18;
    }
    
    function withdraw() public payable {
        require(ceth.redeem(balances[msg.sender]) == 0, "Enter correct cTokens for redeeming");  
        uint ethToWithdraw = address(this).balance;

        payable(msg.sender).transfer(ethToWithdraw); //transfer to userAddress

        balances[msg.sender] = 0;
    }
    
     function getCethBalanceOfUser(address userAddress) public view returns(uint256) {
        return balances[userAddress];
    }
    
    function getExchangeRate() public view returns(uint256){
        return ceth.exchangeRateStored();
    }
    
    receive() external payable {
    }
    
    function getContractbalance() public view returns(uint){
        return address(this).balance;
    }
}
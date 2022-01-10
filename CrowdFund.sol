//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract CrowdFunding{
    mapping(address => uint) public contributors;
    address public admin;
    uint public noOfContributors;
    uint public minAmount;
    uint public goal;
    uint public amountRaised;
    uint public deadline;
    struct Request{
        string description;
        uint value;
        uint noOfVoters;
        address payable recipeint;
        bool completed;
        mapping(address => bool) voters;
    }
    
    mapping(uint => Request) requests;
    uint public numOfRequests;

    event ContributeEvent(address _sender, uint _value);
    event CreateRequestEvent(string _description, address _recipient, uint _value);
    event MakePaymentEvent(address _recipient, uint _value);
    
    constructor(uint _goal, uint _deadline){
        goal = _goal;
        deadline = block.timestamp + _deadline;
        minAmount = 1000;
        admin = msg.sender;
        
    }
    
    function contribute() public payable{
        require(block.timestamp < deadline);
        require(msg.value >= minAmount);
        
        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }
        
        contributors[msg.sender] +=  msg.value;
        amountRaised += msg.value;

        emit ContributeEvent(msg.sender, msg.value);
    }
    
    receive() payable external{
         contribute();
     }
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    function getRefund() public{
        require(block.timestamp > deadline && amountRaised < goal);
        require(contributors[msg.sender] > 0);
        
        address payable recipeint = payable(msg.sender);
        uint value = contributors[msg.sender];
        
        recipeint.transfer(value);
        contributors[msg.sender] = 0;
        
    }
    
    modifier onlyAdmin{
        require(msg.sender == admin);
        _;
    }
    
    function createRequest(string memory _description, address payable _recipeint, uint _value) public onlyAdmin{
    require(block.timestamp >= deadline, "Campaign has not finished yet!");
    require(amountRaised >= goal);
    
    Request storage request = requests[numOfRequests];
    numOfRequests++;

    request.description = _description;
    request.recipeint = _recipeint;
    request.value = _value;
    request.completed = false;
    request.noOfVoters = 0;

    emit CreateRequestEvent(_description, _recipeint, _value);
  }

    function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender] > 0);
        Request storage thisRequest = requests[_requestNo];

        require(thisRequest.voters[msg.sender] == false);
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }  

    function makePayment(uint _requestNo) public onlyAdmin{
        require(amountRaised >= goal);
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed == false);
        require(thisRequest.noOfVoters > noOfContributors / 2);

        thisRequest.recipeint.transfer(thisRequest.value);
        thisRequest.completed = true;

        emit MakePaymentEvent(thisRequest.recipeint, thisRequest.value);
    }
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract crowdFund{
    mapping(address => uint) public contributors; //0*00 => 0
    address public manager;
    uint public minContribution;
    uint public target;
    uint public deadline;
    uint public raiseAmount;
    uint public noOfcontributors;

    struct request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfvoters;
        mapping(address=>bool) voters;
    }
    mapping(uint=>request) public requests;
    uint public numrequest;

    constructor(uint _target,uint _deadline){
        target = _target;
        deadline = block.timestamp + _deadline;
        minContribution = 100 wei;
        manager = msg.sender;
    }

    function sendEth() public payable{
     require(block.timestamp < deadline,"Deadline has passed!");
     require(msg.value >= minContribution,"Not enough funds");
     if(contributors[msg.sender]==0){
        noOfcontributors++;
     }
     contributors[msg.sender]+=msg.value;
     raiseAmount+=msg.value;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function refund() public{
      require(block.timestamp > deadline && raiseAmount < target,"You are not elegible to refund") ;
      require(contributors[msg.sender]>0);
      address payable user = payable(msg.sender);
      user.transfer(contributors[msg.sender]);
      contributors[msg.sender] = 0;
    }

    modifier onlyManager(){
        require(msg.sender==manager,"only manager can call this function");
        _;
    }

    function createRequest(string memory _description,address payable _recipient,uint _value) public onlyManager{
        request storage newRequest = requests[numrequest];
        numrequest++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfvoters = 0;

    }

    function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender]>0,"You must ba a contributor");
        request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfvoters++;
        }

    function makePayment(uint _requestNo) public onlyManager{
        require(raiseAmount>=target);
        request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed==false,"This request has been completed");
        require(thisRequest.noOfvoters >  noOfcontributors/2,"Majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;

    }


}
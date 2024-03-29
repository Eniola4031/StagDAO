// SPDX-License-Identifier: GPL-3.0;
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";


contract TimeLockedWallet {
    address public creator;
    address public owner;
    uint256 public unlockDate = 365 days;
    uint256 public createdAt;
    address public constant presaleToken = "0x68E374F856bF25468D365E539b700b648Bf94B67"; // Using DAI from testnet, replace this with real token address CHANGE THIS

    event Received(address _from, uint _amount);
    event Withdrew(address _to, uint _amount);
    event WithdrewTokens(address _tokenContract, address _to, uint _amount);
    
    modifier onlyOwner {
        require(msg.sender == owner);
            _;
    }
    receive() external payable{
        emit Received(msg.sender, msg.value);
    }
    constructor (address _creator, address _owner /*uint _unlockDate*/) {
        creator = _creator;
        owner = _owner;
       // unlockDate = _unlockDate;
        createdAt = block.timestamp;
    }
    
    function info() public view returns(address, address, uint, uint) {
        return (creator, owner, unlockDate, createdAt);
    }
    //withdraw from contract to msg.sender 
    function withdraw() onlyOwner public {
        require(block.timestamp >= unlockDate);
        payable(msg.sender).transfer(address(this).balance);
        emit Withdrew(msg.sender, address(this).balance);
    }
    
    function withdrawTokens(address _tokenContract) onlyOwner public {
        require(_tokenContract != address(0), "Token not found");
        require(block.timestamp >= unlockDate);
        IERC20 token = IERC20(_tokenContract);
        uint tokenBalance = token.balanceOf(address(this));
        token.transfer(msg.sender, tokenBalance);
       emit WithdrewTokens(_tokenContract, msg.sender, tokenBalance);
    }
    
    function deposit(address _tokenContract, uint _amount) public {
        require(_amount > 0, "invalid value");
        IERC20 token = IERC20(_tokenContract);
        token.transferFrom(msg.sender, address(this), _amount);
    }
    
    function balanceOf(address _tokenContract) public view returns(uint){
        IERC20 token = IERC20(_tokenContract);
        uint tokenBalance = token.balanceOf(address(this));
        return tokenBalance;
    }
         function checkUpkeep(bytes calldata /* checkData */) external override view returns (bool /* upkeepNeeded */, bytes memory /*performData*/) {
        bool upkeepNeeded;
        upkeepNeeded = block.timestamp >= unlockDate;
        return (upkeepNeeded, bytes(""));
    }
    
    function performUpkeep(bytes calldata /* performData */) external override {
        lastTimeStamp = block.timestamp;
        withdraw();  
        withdrawToken(presaleToken);
          }


}
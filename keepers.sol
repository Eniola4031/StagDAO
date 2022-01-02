// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@chainlink/contracts/src/v0.7/KeeperCompatible.sol";
import "./staking.sol";

interface IStagStaking{
    function rebase() external;
}

contract KeeeperBridge is KeeperCompatibleInterface {
    /* Public stagStakingAddress variable
    */
    address public stagStakingAddress;

    /* Use an interval in seconds and a timestamp to slow execution of Upkeep
    */
    uint public immutable interval;
    uint public lastTimeStamp;

    constructor(uint updateInterval, address _stagstakingAddress) {
        interval = updateInterval;
        stagStakingAddress = _stagstakingAddress;
        lastTimeStamp = block.timestamp;

    }

     function checkUpkeep(bytes calldata /* checkData */) external override view returns (bool /* upkeepNeeded */, bytes memory /*performData*/) {
        uint32 endTime;
        bool upkeepNeeded;
        (,,,endTime) = StagStaking(stagStakingAddress).epoch();
        upkeepNeeded = endTime <= block.timestamp;
        return (upkeepNeeded, bytes(""));
    }
    
    function performUpkeep(bytes calldata /* performData */) external override {
        lastTimeStamp = block.timestamp;
        callRebase();
    }

    function callRebase() internal {
        IStagStaking(stagStakingAddress).rebase();
    }
}
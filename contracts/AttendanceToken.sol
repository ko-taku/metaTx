// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AttendanceToken is ERC20Permit, Ownable {
    uint private limitTime;
    uint private maxCallsPerDay;

    struct UserCallData {
        uint lastCallDay;
        uint callCount;
    }

    mapping(address => UserCallData) public userCallData;

    modifier dailyLimit(address _caller) {
        if (_caller != owner()) {
            UserCallData storage data = userCallData[_caller];
            uint today = (block.timestamp + 32400) / limitTime;

            if (data.lastCallDay != today) {
                data.lastCallDay = today;
                data.callCount = 0;
            }

            require(
                data.callCount < maxCallsPerDay,
                "Limit reached. Please try again later."
            );
            data.callCount += 1;
        }
        _;
    }

    constructor()
        ERC20("RocketBoostToken", "RBT")
        ERC20Permit("RocketBoostToken")
        Ownable(msg.sender)
    {
        _mint(msg.sender, 1000000 * 10 ** decimals());
        limitTime = 86400; // 1 day
        maxCallsPerDay = 1; // 1 call
    }

    function attendance(
        address student,
        uint256 amount
    ) public onlyOwner dailyLimit(student) {
        _transfer(msg.sender, student, amount);
    }

    function setLimitTime(uint _limitTime) public onlyOwner {
        require(
            _limitTime >= 1 minutes,
            "Limit time must be at least 1 minute."
        );
        limitTime = _limitTime;
    }

    function setMaxCallsPerDay(uint _maxCallsPerDay) public onlyOwner {
        require(
            _maxCallsPerDay > 0,
            "Max calls per day must be greater than 0"
        );
        maxCallsPerDay = _maxCallsPerDay;
    }

    function resetCallCount(address user) public onlyOwner {
        require(user != address(0), "Invalid address");
        userCallData[user].callCount = 0;
    }

    function getMaxCallsPerDay() public view returns (uint) {
        return maxCallsPerDay;
    }

    function getLimitTime() public view returns (uint) {
        return limitTime;
    }
}

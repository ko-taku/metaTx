// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract QuestionList is Ownable {
    address public attendanceToken;
    uint256 public constant QUESTION_FEE = 1 ether;

    address[] public allStudents;
    mapping(address => string[]) public questions;

    constructor(address _attendanceToken) Ownable(msg.sender) {
        attendanceToken = _attendanceToken;
    }

    event Question(address student, string _question);
    event WithDraw(uint256 amount);

    function question(
        address student,
        string memory _question
    ) public onlyOwner {
        require(student != address(0), "Zero address not allowed");
        require(bytes(_question).length > 0, "No questions available.");

        IERC20 token = IERC20(attendanceToken);
        bool success = token.transferFrom(student, address(this), QUESTION_FEE);
        require(success, "Token transfer failed");

        if (questions[student].length == 0) {
            allStudents.push(student);
        }

        questions[student].push(_question);
        emit Question(student, _question);
    }

    function getQuestions(
        address student
    ) public view returns (string[] memory) {
        return questions[student];
    }

    function getAllStudents() public view returns (address[] memory) {
        return allStudents;
    }

    function withDrawToken() public onlyOwner {
        IERC20 token = IERC20(attendanceToken);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "Insufficient balance.");

        bool success = token.transfer(owner(), balance);
        require(success, "Token transfer failed");

        emit WithDraw(balance);
    }
}

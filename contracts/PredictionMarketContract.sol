// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract PredictionMarketContract {
    address public owner = msg.sender;

    mapping(uint256 => Questions) public questions;
    uint256 public totalQuestions = 1;

    struct Questions {
        uint256 id;
        string question;
        uint256 timestamp;
        address createdBy;
        string creatorImageHash;
        mapping(address => AmountAdded) yesCount;
        AmountAdded[] noCount;
        uint256 totalAmount;
    }

    struct AmountAdded {
        address user;
        uint256 amount;
        uint256 timestamp;
    }

    event QuestionCreated(
        uint256 id,
        string question,
        uint256 timestamp,
        address createdBy,
        string creatorImageHash,
        AmountAdded[] yesCount,
        AmountAdded[] noCount,
        uint256 totalAmount
    );

    function createQuestion(
        string memory _question,
        address _createdBy,
        string memory _creatorImageHash
    ) public {
        AmountAdded[] memory yesCount;
        AmountAdded[] memory noCount;
        uint256 timestamp = block.timestamp;

        Questions storage question = questions[totalQuestions++];

        question.id = totalQuestions;
        question.question = _question;
        question.timestamp = timestamp;
        question.createdBy = _createdBy;
        question.creatorImageHash = _creatorImageHash;
        question.totalAmount = 0;

        emit QuestionCreated(
            totalQuestions,
            _question,
            timestamp,
            _createdBy,
            _creatorImageHash,
            yesCount,
            noCount,
            0
        );
        totalQuestions++;
    }
}

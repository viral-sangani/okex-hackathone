// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract PredictionMarketContract {
    address public owner = msg.sender;

    mapping(uint256 => Questions) public questions;
    uint256 public totalQuestions = 0;

    struct Questions {
        uint256 id;
        string question;
        uint256 timestamp;
        address createdBy;
        string creatorImageHash;
        mapping(address => AmountAdded) yesCount;
        mapping(address => AmountAdded) noCount;
        uint256 totalAmount;
        uint256 totalYesAmount;
        uint256 totalNoAmount;
        bool wining;
        mapping(address => WinningAmount) winingYesCount;
        mapping(address => WinningAmount) winningNoCount;
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
        uint256 totalAmount,
        uint256 totalYesAmount,
        uint256 totalNoAmount
    );

    function createQuestion(
        string memory _question,
        string memory _creatorImageHash
    ) public {
        AmountAdded[] memory yesCount;
        AmountAdded[] memory noCount;
        uint256 timestamp = block.timestamp;

        Questions storage question = questions[totalQuestions++];

        question.id = totalQuestions;
        question.question = _question;
        question.timestamp = timestamp;
        question.createdBy = msg.sender;
        question.creatorImageHash = _creatorImageHash;
        question.totalAmount = 0;
        question.totalYesAmount = 0;
        question.totalNoAmount = 0;

        emit QuestionCreated(
            totalQuestions,
            _question,
            timestamp,
            msg.sender,
            _creatorImageHash,
            yesCount,
            noCount,
            0,
            0,
            0
        );
    }

    function addYesBet(uint256 _questionId) public payable {
        Questions storage question = questions[_questionId];
        AmountAdded storage amountAdded = question.yesCount[msg.sender];
        amountAdded.timestamp = block.timestamp;
        amountAdded.user = msg.sender;
        amountAdded.amount = msg.value;
        question.totalYesAmount += msg.value;
        question.totalAmount += msg.value;
    }

    function addNoBet(uint256 _questionId) public payable {
        Questions storage question = questions[_questionId];
        AmountAdded storage amountAdded = question.noCount[msg.sender];
        amountAdded.timestamp = block.timestamp;
        amountAdded.user = msg.sender;
        amountAdded.amount = msg.value;
        question.totalNoAmount += msg.value;
        question.totalAmount += msg.value;
    }

    event DeclareWinner(
        uint256 id,
        bool winner
    );

    event Exception(
        address adrs,
        string reason
    );

    struct WinningAmount {
        address user;
        uint256 amount;
        uint256 timestamp;
    }


    function declareWinnerForQuestion(uint256 _questionId, bool winner) public payable {
        Questions storage question = questions[_questionId];
        question.wining = winner;

        emit DeclareWinner(
            question.id,
            question.wining
        );
    }

    function distributeWinningAmount(uint256 _questionId) public payable {
        Questions storage question = questions[_questionId];
        if (question.wining) {
            uint256 winningRatio = question.totalYesAmount / question.totalAmount; //Check for floating type values Int currently
            AmountAdded storage amountAdded = question.yesCount[msg.sender];

            if (amountAdded == 0) {
                emit Exception(
                    adrs = msg.sender,
                    reason = "No bet placed for user!"
                );
            }

            WinningAmount storage winningAmount = question.winingYesCount[msg.sender];
            winningAmount.user = msg.sender;
            winningAmount.amount = amountAdded * winningRatio;
            winningAmount.timestamp = block.timestamp;

            question.yesCount[msg.sender] = 0;
        } else {
            uint256 winningRatio = question.totalNoAmount / question.totalAmount; //Check for floating type values Int currently
            AmountAdded storage amountAdded = question.noCount[msg.sender];

            if (amountAdded == 0) {
                emit Exception(
                    adrs = msg.sender,
                    reason = "No bet placed for user!"
                );
            }

            WinningAmount storage winningAmount = question.winningNoCount[msg.sender];
            winningAmount.user = msg.sender;
            winningAmount.amount = amountAdded * winningRatio;
            winningAmount.timestamp = block.timestamp;

            question.noCount[msg.sender] = 0;
        }
    }

}

// "Will Modi win?", "abcd"

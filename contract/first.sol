// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DynamicCashPool {
    using SafeERC20 for IERC20;

    struct Participant {
        mapping(address => uint256) balances;
        bool exists;
        uint256 joinedTimestamp;
        bool isWhitelisted;
    }

    address[] private participantsArray;
    mapping(address => Participant) public participants;
    mapping(address => uint256) public totalBalances;
    mapping(address => uint256) public contributionAmounts;

    uint256 public lockupPeriod; // Lock-up period in seconds
    mapping(address => uint256) public vestingTimestamps; // Vesting timestamps for participants

    address public poolOwner;
    mapping(address => bool) public admins;
    mapping(address => bool) public referrals;

    uint256 public rebalanceInterval; // Interval for automatic rebalancing in seconds
    uint256 public lastRebalanceTimestamp; // Timestamp of the last rebalance

    event Contribution(address indexed participant, uint256 amount, address token);
    event Withdrawal(address indexed participant, uint256 amount, address token);
    event ReferralBonus(address indexed participant, address indexed referee, uint256 bonusAmount);

    constructor(uint256 _lockupPeriod, uint256 _rebalanceInterval) {
        poolOwner = msg.sender;
        lockupPeriod = _lockupPeriod;
        rebalanceInterval = _rebalanceInterval;
        admins[msg.sender] = true;
    }

    modifier onlyPoolOwner() {
        require(msg.sender == poolOwner, "Only pool owner can perform this action");
        _;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "Only admins can perform this action");
        _;
    }

    function contribute(address token, uint256 amount) external {
        require(amount > 0, "Contribution amount must be greater than zero");

        Participant storage participant = participants[msg.sender];
        if (!participant.exists) {
            participant.exists = true;
            participant.joinedTimestamp = block.timestamp;
            participant.isWhitelisted = false;
            participantsArray.push(msg.sender);
        }

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        participant.balances[token] += amount;
        totalBalances[token] += amount;
        contributionAmounts[msg.sender] += amount;

        emit Contribution(msg.sender, amount, token);
    }

    function withdraw(address token, uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= participants[msg.sender].balances[token], "Insufficient balance");
        require(block.timestamp >= vestingTimestamps[msg.sender], "Funds are still locked up");

        participants[msg.sender].balances[token] -= amount;
        totalBalances[token] -= amount;

        IERC20(token).safeTransfer(msg.sender, amount);

        emit Withdrawal(msg.sender, amount, token);
    }

    function addAdmin(address admin) external onlyPoolOwner {
        admins[admin] = true;
    }

    function removeAdmin(address admin) external onlyPoolOwner {
        delete admins[admin];
    }

    function whitelistParticipant(address participant) external onlyAdmin {
        participants[participant].isWhitelisted = true;
    }

    function removeWhitelistedParticipant(address participant) external onlyAdmin {
        participants[participant].isWhitelisted = false;
    }

    function setVestingTimestamp(address participant, uint256 timestamp) external onlyAdmin {
        require(participants[participant].exists, "Participant does not exist");

        vestingTimestamps[participant] = timestamp;
    }

    function setReferral(address referee) external {
        require(referee != address(0) && referee != msg.sender, "Invalid referee address");

        referrals[msg.sender] = true;
        emit ReferralBonus(referee, msg.sender, calculateReferralBonus(contributionAmounts[msg.sender]));
    }

    function calculateReferralBonus(uint256 amount) internal pure returns (uint256) {
        // Calculate referral bonus as 2% of the contribution amount
        return (amount * 2) / 100;
    }

    function getParticipantBalance(address participant, address token) external view returns (uint256) {
        return participants[participant].balances[token];
    }

    function setLockupPeriod(uint256 period) external onlyPoolOwner {
        lockupPeriod = period;
    }

    function setRebalanceInterval(uint256 interval) external onlyPoolOwner {
        rebalanceInterval = interval;
    }

    function rebalance(address[] calldata tokens) external {
        require(
            block.timestamp >= lastRebalanceTimestamp + rebalanceInterval,
            "Rebalance interval not reached"
        );

        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            uint256 totalBalance = IERC20(token).balanceOf(address(this));

            for (uint256 j = 0; j < participantsArray.length; j++) {
                address participant = participantsArray[j];
                uint256 participantBalance = participants[participant].balances[token];
                uint256 targetBalance = (participantBalance * totalBalance) / totalBalances[token];
                uint256 diff = targetBalance - participantBalance;

                if (diff > 0) {
                    IERC20(token).safeTransfer(participant, diff);
                    participants[participant].balances[token] += diff;
                }
            }
        }

        lastRebalanceTimestamp = block.timestamp;
    }
}

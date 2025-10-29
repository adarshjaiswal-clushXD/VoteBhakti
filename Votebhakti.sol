// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VoteBhakti {
    // ----- STRUCTS -----
    struct Candidate {
        string name;
        uint voteCount;
    }

    // ----- STATE VARIABLES -----
    address public admin;                      // Contract creator
    mapping(address => bool) public hasVoted;  // Track if an address has voted
    Candidate[] public candidates;             // Dynamic array of candidates
    bool public votingActive;                  // Voting status

    // ----- EVENTS -----
    event CandidateAdded(string name);
    event VoteCasted(address voter, uint candidateIndex);
    event VotingStarted();
    event VotingEnded();

    // ----- CONSTRUCTOR -----
    constructor() {
        admin = msg.sender; // whoever deploys is the admin
    }

    // ----- MODIFIERS -----
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    modifier votingOpen() {
        require(votingActive, "Voting is not active");
        _;
    }

    // ----- ADMIN FUNCTIONS -----
    function addCandidate(string memory _name) public onlyAdmin {
        require(!votingActive, "Cannot add candidates after voting started");
        candidates.push(Candidate(_name, 0));
        emit CandidateAdded(_name);
    }

    function startVoting() public onlyAdmin {
        require(!votingActive, "Voting already started");
        require(candidates.length > 0, "Add at least one candidate first");
        votingActive = true;
        emit VotingStarted();
    }

    function endVoting() public onlyAdmin {
        require(votingActive, "Voting already ended");
        votingActive = false;
        emit VotingEnded();
    }

    // ----- VOTING FUNCTION -----
    function vote(uint _candidateIndex) public votingOpen {
        require(!hasVoted[msg.sender], "You already voted!");
        require(_candidateIndex < candidates.length, "Invalid candidate");

        hasVoted[msg.sender] = true;
        candidates[_candidateIndex].voteCount += 1;

        emit VoteCasted(msg.sender, _candidateIndex);
    }

    // ----- VIEW FUNCTIONS -----
    function getCandidateCount() public view returns (uint) {
        return candidates.length;
    }

    function getCandidate(uint _index) public view returns (string memory, uint) {
        require(_index < candidates.length, "Invalid index");
        Candidate memory c = candidates[_index];
        return (c.name, c.voteCount);
    }

    function getWinner() public view returns (string memory winnerName, uint winnerVotes) {
        uint maxVotes = 0;
        uint winnerIndex = 0;

        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerIndex = i;
            }
        }

        winnerName = candidates[winnerIndex].name;
        winnerVotes = candidates[winnerIndex].voteCount;
    }
}


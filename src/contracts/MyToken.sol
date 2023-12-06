// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract VotingUSP is ERC721 {
    uint256 public nextTokenId;
    uint256 public votingEther = 0.000000000000000000 ether;
    mapping(address => string) public admins; // admin -> nome
    mapping(address => string) public candidates_names; // candidato -> nome
    mapping(address => address) public votes; // pessoa -> candidato
    mapping(address => uint256) public num_votes; // candidatos -> número de votos

    constructor() ERC721("VotingUSP", "MTK") {
        admins[msg.sender] = "Admin"; // Define um nome padrão para o primeiro administrador
    }

    modifier adminsOnly() {
        require(bytes(admins[msg.sender]).length > 0, 'Only admins can execute this function');
        _;
    }

    // Adiciona um novo administrador
    function addAdmim(address admim_adress, string memory name) external adminsOnly {
        admins[admim_adress] = name;
    }

    // Remove um administrador
    function deleteAdmim(address admim_adress) external adminsOnly {
        delete admins[admim_adress];
    }

    // Adiciona um novo candidato
    function addCandidate(address candidate_adress, string memory name) external adminsOnly {
        candidates_names[candidate_adress] = name;
        num_votes[candidate_adress] = 0;
    }

    // Remove um candidato
    function deleteandidate(address candidate_adress) external adminsOnly {
        delete candidates_names[candidate_adress];
        delete num_votes[candidate_adress];
    }

    // Retorna o número de votos recebidos por um candidato
    function showVotesCandidate(address candidate_adress) external view returns(uint256) {
        return num_votes[candidate_adress];
    }

    // Retorna o candidato escolhido pelo eleitor
    function showMyVote() external view returns (string memory) {
        address voter = msg.sender;
        address candidateAddress = votes[voter];

        // Verifica se o eleitor já votou
        require(candidateAddress != address(0), "You haven't voted yet");

        string memory candidateName = candidates_names[candidateAddress];
        return candidateName;
    }

    // Realiza um voto
    function vote(address candidate_adress) external payable {
        address voter = msg.sender;
        uint256 votingValue = msg.value;

        require(bytes(candidates_names[candidate_adress]).length > 0, 'Candidate not registered');
        require(votes[voter] == address(0), 'Address has already voted');
        require(votingValue >= votingEther, 'Insufficient voting value');

        // Registra o voto
        num_votes[voter] = num_votes[voter] + 1;
        votes[voter] = candidate_adress;

        // Cria o NFT (Token Não Fungível)
        uint256 tokenId = nextTokenId;
        _safeMint(voter, tokenId);

        // Incrementa o próximo tokenId para o próximo voto
        nextTokenId++;
    }
}

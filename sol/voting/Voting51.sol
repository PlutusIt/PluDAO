import 'common/Owned.sol'; 
import 'token/Token.sol'; 

/**
 * @dev The 51% voting
 */
contract Voting51 is Owned {
    Token public shares;
    uint  public voting_limit;

    address[]               public proposal;
    mapping(uint => string) public description;

    mapping(uint => uint)   public total_value;
    mapping(uint => mapping(address => uint)) public voter_value;

    uint public current_proposal = 0;

    event ProposalDone(uint indexed proposal);

    function Voting51(Token _shares) {
        shares = _shares;
        voting_limit = shares.totalSupply() / 2;
    }

    /**
     * @dev Append new proposal for voting
     * @param _target is a proposal target
     * @param _description is a proposal description
     */
    function appendProposal(address _target,
                            string _description) onlyOwner {
        description[proposal.length]  = _description;
        proposal.push(_target);
    }

    /**
     * @dev Voting for current proposal
     * @param _count is how amount of shares used
     * @notice shares should be approved for voting
     */
    function vote(uint _count) {
        // Check for no proposal exist
        if (proposal[current_proposal] == 0) throw;

        // Voting operation
        if (shares.transferFrom(msg.sender, this, _count)) {
            total_value[current_proposal]             += _count;
            voter_value[current_proposal][msg.sender] += _count;

            // Check vote done
            if (total_value[current_proposal] > voting_limit) {
                proposal[current_proposal].call();
                ProposalDone(current_proposal);
                ++current_proposal;
            }
        }
    }

    /**
     * @dev Refund shares
     * @param _proposal is a proposal id
     * @param _count is how amount of shares should be refunded
     */
    function refund(uint _proposal, uint _count) {
        if (voter_value[_proposal][msg.sender] >= _count)
            shares.transfer(msg.sender, _count);
    }
}

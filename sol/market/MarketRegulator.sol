import 'lib/AddressArray.sol';
import 'token/Token.sol';
import './MarketAgent.sol';
import './Market.sol';

/**
 * @title Market regulator abstract contract,
 *        this contract creates market and `credits` token
 *        for market trade
 */
contract MarketRegulator is Mortal {
    /* The self market */
    Market public market;

    /* The self credits */
    Token  public credits;

    /* The self created market agents */
    address[] public agents;
    using AddressArray for address[];

    /* Only market agents can call modified functions */
    modifier onlyAgents { if (agents.indexOf(msg.sender) < agents.length) _ }

    function MarketRegulator(uint credit_emission) {
        market  = new Market();
        credits = new Token("Credits", "C");
        credits.emission(credit_emission);
        credits.transfer(msg.sender, credit_emission);
    }

    /**
     * @dev Sign a contract with sender for trading on market
     * @return `MarketAgent` instance
     */
    function sign() returns (MarketAgent);

    /**
     * @dev Deal done callback, this called by market agent 
     *      after call deal of `Lot`
     * @param _lot is deal description
     */
    function dealDone(Lot _lot) onlyAgents;
}
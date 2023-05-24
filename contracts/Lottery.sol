// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainLink.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//creating the lottery contract
contract Lottery is Ownable{
    using SafeMathChainLink for uint256;
    enum LOTTERY_STATE {OPEN, CLOSED, CALCULATING_WINNDER};
    LOTTERY_STATE public lotteryState;
    AggregatorV3Interface internal ethUsdPriceFeed;
    uint256 public usdEntryFee;
    uint256 public randomness;
    address payable[] public players;

    constructor(address _ethUsdPriceFeed) public {

        ethUsdePriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        usdEntryFee = 50;//$50
        lotteryState = LOTTER_STATE.CLOSED;
    }

    function enter() public payable{
        require(msg.value >= getEntranceFee(),"Not enough ETH to enter");
        require(lotteryState == LOTTERY_STATE.OPEN);//to make sure previous game is finished
        players.push(msg.sender); //put new round of players into array for new game
    }

    function getEntranceFee() public view returns(uint256){
        uint256 precision = 1 * 10 ** 18;
        uint256 price = getLatestEthUsdPrice();
        uint256 costToEnter = (precision / price) * (usdEntryFee * 100000000);
    }

    function getLatestEthUsdPrice() public view returns(uint256){
        {
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        } = ethUsdPriceFeed.lastestRoundData();
        return uint256(price);
    } 

    //onlyOwner - only owner of the contract can call this function
    // use openzeplin's onlyOwner
    function startLottery() public onlyOwner{
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start a new lottery");
        lotteryState = LOTTERY_STATE.OPEN;
        randomness = 0;
    }

    function endLottery() public{

    }

    function pickWinner(){

    }
}
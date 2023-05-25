// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainLink.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/0.6/VRFConsumerBase.sol";

//creating the lottery contract
contract Lottery is VRFConsumerBase, Ownable{
    using SafeMathChainLink for uint256;
    enum LOTTERY_STATE {OPEN, CLOSED, CALCULATING_WINNDER};
    LOTTERY_STATE public lotteryState;
    AggregatorV3Interface internal ethUsdPriceFeed;
    uint256 public usdEntryFee;
    address public recentWinner;
    address payable[] public players;
    uint256 public randomness;
    uint256 public fee;
    bytes32 public keyHash;
    event RequestRandomness(bytes32 requestId);

    //_link = link address
    constructor(address _ethUsdPriceFeed, address _vrfCoordinator, address _link, bytes32 _keyHash)
        VRFConsumerBase(
            _vrfCoordinator,
            _link
         ) public{
        ethUsdePriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        usdEntryFee = 50;//$50
        lotteryState = LOTTER_STATE.CLOSED;
        fee = 100000000000000000; //0.1 link, 17s 0
        keyHash = _keyHash;
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

    //use chainlink inbuilt random number gen to pick winner
    function endLottery(uint256 userProvideSeed) public onlyOwner{
        require(lotteryState == LOTTERY_STATE.OPEN, "Can't end lottery yet");
        lotteryState = LOTTERY_STATE.CALCULATING_WINNER;
        pickWinner(userProvideSeed);
    }

    function pickWinner(uint256 userProvideSeed) private returns(bytes32){
        require(lotteryState == LOTTERY_STATE.CALCULATING_WINNER, "Needs to be calculating the winner");
        bytes32 requestId = requestRandomness(KeyHash, fee, userProvidedSeed);
        emit RequestedRandomness(requestId);
    }

    //request randomness
    function fulfilRandomness(bytes32 requestId, uint256 randomness) internal override{
        require(randomness > 0, "random number not found");
        uint256 index = randomness % players.length;
        //send all the eth in this contract to the winner
        players[index].transfer(address(this).balance);
        recentWinner = players[index]; //use to identify the most recent winner
        players = new address payable[](0);
        lotteryState = LOTTERY_STATE.CLOSED;
        randomness = randomness;
    }
}
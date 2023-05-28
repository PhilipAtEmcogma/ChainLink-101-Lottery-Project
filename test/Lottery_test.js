const {assert} = require('chai');
//use yarn add truffle-assertions to add truffle-assertions library
const truffleAssert = require('truffle-assertions;');

// when deploying this project in real life,
// make sure to write unit test for different mainnet and testnet
// for this project it works with local network, so only write unitest for the local network
contract ('Lottery', accounts => {
    //mock token
    const Lottery = artifacts.require('Lottery')
    const VRTCoordinatorMock = artifacts.require('VRFCoordinatorMock')
    const MockPriceFeed = artifacts.require('MockV3Aggregator')
    const {LinkToken} = require('@chainlink/contracts/truffle/v0.4/LinkToken')

    //mock lottery players account
    const defaultAccount = accounts[0]
    const player1 = accounts[1]
    const player2 = accounts[2]
    const player3 = accounts[3]

    let lottery, vrfCoorindatorMock, seed, link, keyhash, fee, mockPriceFeed

    //note should have a unit test for each of the function in the Lottery.sol contract
    describte('#request a random number', () => {
        let price = '200000000000'
        beforeEach(async () => {
            keyHash = ''
            fee = '10000000000000' //0.1 link
            seed = 123
            link = await LinkToken.new({from: defaultAccount}) //deploy mock contract
            mockPriceFeed = await MockPriceFeed.new(8, price, {from: defaultAccount}) //8 = 8 decimals
            vrfCoorindatorMock = await vrfCoorindatorMock.new(link.address, {from : defaultAccount})
            lottery = await Lottery.new(mockPriceFeed.address, vrfCoorindatorMock.address, link.address, keyHash, {from: defaultAccount})
        })

        it('starts in a closed state', async () => {
            assert(await lottery.lotteryState() == 1)
        })

        //inital price $2000 (2000000000000), with entrance fee of $50
        //thus $50/$2000 = $0.25 eth (gwei)~(25000000000000000)
        it('corrects gets the entrance fee', async () =>{
            let entrancefee = await lottery.getEntranceFee()
            assert.equal(entranceFee.toString(), '25000000000000000')
        })

        //test what happens if player doesn't have enough entrance fee
        it('Disallows entrants without enough money', async () => {
            await lottery.startLottery({from: defaultAccount})
            //reverts when someone tries to enter without enough money
            await truffleAssert.reverts(
                lottery.enter({from: defaultAccount, value: 0})
            )
        })

        //test for seeing if game plays correctly
        it('Plays the game correctly', async() => {
            await lottery.startLottery({from: defaultAccount})
            let entranceFee = await lottery.getEntranceFee()
            //enters the players
            lottery.enter({from: player1, value: entranceFee.toString()})
            lottery.enter({from: player2, value: entranceFee.toString()})
            lottery.enter({from: player3, value: entranceFee.toString()})
            //picks the winner and send it 1 link
            await link.transfer(lottery.address, web3.utils.toWei('1','ether'), {from: defaultAccount})
            //initialise vrfcoordinator once enough link is recieve as enter
            let transaction = await lottery.endLottery(seed, {from: defaultAccount})
            let requestId = transaction.receipt.rawLogs[3].topics[0]; //rawLogs[3] because chainlink itself also have logs

            await vrfCoordinatorMock.callBackWithRandomness(requestId, '3', lottery.address, {from: defaultAccount});
            let recentWinner = await lottery.recentWinner()
            //we know recentWinner is player1 because we put the 'random number' generated in vrfCoordination as 3, and 3%3 = 1, thus player1
            assert.equal(recentWinner,player1)
        })
    })
})
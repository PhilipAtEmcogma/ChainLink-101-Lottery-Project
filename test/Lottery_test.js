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
})
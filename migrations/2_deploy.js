const Lottery = artifacts.require('Lottery')
const {LinkToken} = require('@chainlink/contracts/truffle/v0.4/LinkToken')

module.exports = async(deployer, network, [defaultAccount]) =>{
    //if not start with Goerli testnet, set it to Goerli instead
    if(!network.startsWith('goerli')){
        console.log('Currently only works with Goerli');
        LinkToken.setProvider(deployer.provider);
    } else {
        //contract address is obtrained from doc.chain.link, Goerli testnet eth/usd price feed
        //0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e -eth/usd
        const GOERLI_KEYHASH= '0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e';
        //0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D -Goerli vrf coondinator
        const GOERLI_VRF_COODINATOR = '0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D';
        const ETH_USD_PRICE_FEED = '';
        const GOERLI_LINK_TOKEN ='';

        //deploy
        deployer.deploy(Lottery, ETH_USD_PRICE_FEED, GOERLI_VRF_COODINATOR, GOERLI_LINK_TOKEN, GOERLI_KEYHASH);
    }
}
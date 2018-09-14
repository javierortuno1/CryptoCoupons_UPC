const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const compiledFactory = require('./build/Campaign.solCampaignFactory.json');
const compiledFactory2 = require('./build/CryptoCoupon.solCryptoCouponFactory.json');

const provider = new HDWalletProvider(
  'call glow acoustic vintage front ring trade assist shuffle mimic volume reject',
  'https://rinkeby.infura.io/v3/1b105baedeac46cbb0e932172d5aae62'
);
/*
const provider = new Web3.providers.HttpProvider(
  'https://rinkeby.infura.io/v3/1b105baedeac46cbb0e932172d5aae62'
);*/

const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  console.log('Attempting to deploy from account', accounts[0]);

  const result = await new web3.eth.Contract(
    JSON.parse(compiledFactory.interface)
  )
    .deploy({ data: compiledFactory2.bytecode })
    .send({ gas: '3000000', from: accounts[0] });

  console.log('Contract deployed to', result.options.address);
};
deploy();

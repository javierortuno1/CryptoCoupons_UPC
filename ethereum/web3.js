import Web3 from 'web3';
const HDWalletProvider = require('truffle-hdwallet-provider');
let web3;

if (typeof window !== 'undefined' && typeof window.web3 !== 'undefined') {
  // We are in the browser and metamask is running.
  web3 = new Web3(window.web3.currentProvider);
} else {
  // We are on the server *OR* the user is not running metamask
  /*const provider = new HDWalletProvider(
  'call glow acoustic vintage front ring trade assist shuffle mimic volume reject',
  'https://rinkeby.infura.io/v3/1b105baedeac46cbb0e932172d5aae62'
	);*/

  const provider = new HDWalletProvider(
  'call glow acoustic vintage front ring trade assist shuffle mimic volume reject',
  'https://rinkeby.infura.io/v3/1b105baedeac46cbb0e932172d5aae62'
	);
  web3 = new Web3(provider);
}

export default web3;

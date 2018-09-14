import web3 from './web3';
import CryptoCoupon from './build/CryptoCoupon.solCryptoCoupon.json';

export default address => {
  return new web3.eth.Contract(JSON.parse(CryptoCoupon.interface), address);
};

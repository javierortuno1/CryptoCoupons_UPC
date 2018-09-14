import web3 from './web3';
import CryptoCouponFactory from './build/CryptoCoupon.solCryptoCouponFactory.json';

const instance = new web3.eth.Contract(
  JSON.parse(CryptoCouponFactory.interface),
  '0x9056796292Aa0fEe44cCd98346E2d29b86B11A26'
);

export default instance;


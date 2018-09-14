import web3 from './web3';
import CampaignFactory from './build/Campaign.solCampaignFactory.json';

const instance = new web3.eth.Contract(
  JSON.parse(CampaignFactory.interface),
  '0x9056796292Aa0fEe44cCd98346E2d29b86B11A26'
);

export default instance;

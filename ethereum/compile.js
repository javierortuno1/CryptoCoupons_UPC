const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);

const campaignPath = path.resolve(__dirname, 'contracts', 'Campaign.sol');
const cryptoCouponPath = path.resolve(__dirname, 'contracts', 'CryptoCoupon.sol');
const SafeMath = path.resolve(__dirname, 'contracts', 'SafeMath.sol');
const ERC721 = path.resolve(__dirname, 'contracts', 'ERC721.sol');
const AccessControl = path.resolve(__dirname, 'contracts', 'AccessControl.sol');



var input = {

  'Campaign.sol': fs.readFileSync(campaignPath, 'utf8'),
  'CryptoCoupon.sol': fs.readFileSync(cryptoCouponPath, 'utf8'),
  'SafeMath.sol': fs.readFileSync(SafeMath, 'utf8'),
  'ERC721.sol': fs.readFileSync(ERC721, 'utf8'),
  'AccessControl.sol': fs.readFileSync(AccessControl, 'utf8')

  };
  const output = solc.compile({sources: input}, 1).contracts;
fs.ensureDirSync(buildPath);

for (let contract in output) {
  fs.outputJsonSync(
    path.resolve(buildPath, contract.replace(':', '') + '.json'),
    output[contract]
  );
}

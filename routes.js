const routes = require('next-routes')();

routes
  .add('/campaigns/new', '/campaigns/new')
  .add('/campaigns/:address', '/campaigns/show')
  .add('/campaigns/:address/requests', '/campaigns/requests/index')
  .add('/campaigns/:address/requests/new', '/campaigns/requests/new')
  .add('/cryptoCoupons/new', '/cryptoCoupons/new')
  .add('/cryptoCoupons/advancedcoupon/new', '/cryptoCoupons/advancedcoupon/new')
  .add('/cryptoCoupons/:address', '/cryptoCoupons/show')
  .add('/cryptoCoupons/:address/coupons', '/cryptoCoupons/coupons/index')
  .add('/cryptoCoupons/:address/couponsSale', '/cryptoCoupons/couponsSale/index')
  .add('/cryptoCoupons/:address/coupons/new', '/cryptoCoupons/coupons/new');

module.exports = routes;

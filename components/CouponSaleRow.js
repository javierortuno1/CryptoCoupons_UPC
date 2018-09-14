import React, { Component } from 'react';
import { Table, Button } from 'semantic-ui-react';
import web3 from '../ethereum/web3';
import CryptoCoupon from '../ethereum/cryptoCoupon';

class CouponSaleRow extends Component {

  onFinalize = async () => {
    const cryptoCoupon = CryptoCoupon(this.props.address);

    const accounts = await web3.eth.getAccounts();
    await cryptoCoupon.methods.finalizeRequest(this.props.id).send({
      from: accounts[0]
    });
  };

  onPurchase = async () => {
    console.log("Buying Coupon");
    /*const cryptoCoupon = CryptoCoupon(this.props.address);

    const accounts = await web3.eth.getAccounts();

    console.log("account"+accounts[0]);
    await cryptoCoupon.methods
        .AccessControle()
        .send({
          from: accounts[0], gas: '100000'
        });

    await cryptoCoupon.methods.setCouponToSale(this.props.id).send({
      from: accounts[0], gas:'300000'
    });*/
  };

  render() {
    const { Row, Cell } = Table;
    const { id, coupon } = this.props;
    //const readyToFinalize = request.approvalCount > approversCount / 2;

    return (
      <Row disabled = {coupon.gift} >
        <Cell>{id}</Cell>
        <Cell>{coupon.name}</Cell>
        <Cell>{coupon.description}</Cell>
        <Cell>
          {coupon.serialNumber}
        </Cell>
        <Cell>{web3.utils.fromWei(coupon.value, 'ether')}</Cell>
       
        <Cell>
          
            <Button color="green" basic onClick={this.onPurchase}>
              Comprar
            </Button>
          
        </Cell>
       
        
      </Row>
    );
  }
}

export default CouponSaleRow;

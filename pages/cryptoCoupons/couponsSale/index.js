import React, { Component } from 'react';
import { Button, Table } from 'semantic-ui-react';
import { Link } from '../../../routes';
import Layout from '../../../components/Layout';
import CryptoCoupon from '../../../ethereum/cryptoCoupon';
import CouponSaleRow from '../../../components/CouponSaleRow';

class CouponIndex extends Component {
  static async getInitialProps(props) {
    const { address } = props.query;
    const cryptoCoupon = CryptoCoupon(address);
    const couponCount = await cryptoCoupon.methods.getCouponsSaleCount().call();
    //const approversCount = await campaign.methods.approversCount().call();

    const coupons = await Promise.all(
      Array(parseInt(couponCount))
        .fill()
        .map((element, index) => {
          return cryptoCoupon.methods.couponsSale(index).call();
        })
    );

    return { address, coupons, couponCount };
  }

  renderRows() {
    return this.props.coupons.map((coupon, index) => {
      return (
        <CouponSaleRow
          key={index}
          id={index}
          coupon={coupon}
          address={this.props.address}
          
        />
      );
    });
  }

  render() {
    const { Header, Row, HeaderCell, Body } = Table;

    return (
      <Layout>
        <h3>Coupons</h3>
        
        <Table>
          <Header>
            <Row>
              <HeaderCell>ID</HeaderCell>
              <HeaderCell>Name</HeaderCell>
              <HeaderCell>Description</HeaderCell>
              <HeaderCell>Serial Number</HeaderCell>
              <HeaderCell>Value</HeaderCell>
              <HeaderCell>Approve</HeaderCell>
            </Row>
          </Header>
          <Body>{this.renderRows()}</Body>
        </Table>
        <div>Found {this.props.couponCount} coupons.</div>
      </Layout>
    );
  }
}

export default CouponIndex;

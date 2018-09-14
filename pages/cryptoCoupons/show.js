import React, { Component } from 'react';
import { Card, Grid, Button } from 'semantic-ui-react';
import Layout from '../../components/Layout';
import CryptoCoupon from '../../ethereum/cryptoCoupon';
import web3 from '../../ethereum/web3';
//import ContributeForm from '../../components/ContributeForm';
import { Link } from '../../routes';

class CryptoCouponShow extends Component {
  static async getInitialProps(props) {
    const cryptoCoupon = CryptoCoupon(props.query.address);

    const summary = await cryptoCoupon.methods.getSummary().call();

    return {
      address: props.query.address,
      name: summary[0],
      balance: summary[1],
      couponsCount: summary[2],
      manager: summary[3]
    };
  }

  renderCards() {
    const {
      balance,
      manager,
      name,
      couponsCount,
    } = this.props;

    const items = [
      {
        header: manager,
        meta: 'Address of Manager',
        description:
          'The manager created this coupon',
        style: { overflowWrap: 'break-word' }
      },
      {
        header: name,
        meta: 'Company Name',
        description:
          'Company'
      },
      {
        header: couponsCount,
        meta: 'Number of Coupons',
        description:
          'Coupons'
      },
      {
        header: web3.utils.fromWei(balance, 'ether'),
        meta: 'Company Balance (ether)',
        description:
          'The balance is how much money this coupon has left to spend.'
      }
    ];

    return <Card.Group items={items} />;
  }

  render() {
    return (
      <Layout>
        <h3>Company Show</h3>
        <Grid>
          <Grid.Row>
            <Grid.Column width={10}>{this.renderCards()}</Grid.Column>

            <Grid.Column width={6}>
              
            </Grid.Column>
          </Grid.Row>

          <Grid.Row>
            <Grid.Column>
              <Link route={`/cryptoCoupons/${this.props.address}/coupons`}>
                <a>
                  <Button primary>View Coupons</Button>
                </a>
              </Link>
            </Grid.Column>
          </Grid.Row>
          <Grid.Row>
            <Grid.Column>
              <Link route={`/cryptoCoupons/${this.props.address}/couponsSale`}>
                <a>
                  <Button primary>View Coupons for Sale</Button>
                </a>
              </Link>
            </Grid.Column>
          </Grid.Row>
        </Grid>
      </Layout>
    );
  }
}

export default CryptoCouponShow;
//<!--<ContributeForm address={this.props.address} />-->

import React, { Component } from 'react';
import { Card, Button } from 'semantic-ui-react';
import factory from '../ethereum/cryptoFactory';
import Layout from '../components/Layout';
import { Link } from '../routes';
//{this.renderCoupons()}
class CryptoCouponIndex extends Component {
  static async getInitialProps() {
   const cryptoCoupons = await factory.methods.getDeployedCryptoCoupons().call();


    return { cryptoCoupons };
  }

  renderCryptoCoupons() {
    const items = this.props.cryptoCoupons.map(address => {
      return {
        header: address,
        description: (
          <Link route={`/cryptoCoupons/${address}`}>
            <a>View CryptoCoupon</a>
          </Link>
        ),
        fluid: true
      };
    });

    return <Card.Group items={items} />;
  }

  render() {
    return (
      <Layout>
        <div>
          <h3>Open Companies</h3>


          <Link route="/cryptoCoupons/new">
            <a>
              <Button
                floated="right"
                content="Create Company"
                icon="add circle"
                primary
              />
            </a>
          </Link>


          {this.renderCryptoCoupons()}

        </div>
      </Layout>
    );
  }
}

export default CryptoCouponIndex;

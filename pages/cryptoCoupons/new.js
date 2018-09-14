import React, { Component } from 'react';
import { Form, Button, Input, Message } from 'semantic-ui-react';
import Layout from '../../components/Layout';
import factory from '../../ethereum/cryptoFactory';
import web3 from '../../ethereum/web3';
import { Router } from '../../routes';

class CryptoCouponNew extends Component {
  state = {
    name: '',
    address : '',
    errorMessage: '',
    loading: false
  };

  onSubmit = async event => {
    event.preventDefault();

    this.setState({ loading: true, errorMessage: '' });

    try {
      const accounts = await web3.eth.getAccounts();
      console.log("from account:  "+accounts[0]);
      await factory.methods
        .createCryptoCoupon(this.state.name, this.state.address)
        .send({
          from: accounts[0],
          gas: '3000000'
        });


      Router.pushRoute('/');
    } catch (err) {
      this.setState({ errorMessage: err.message });
    }

    this.setState({ loading: false });
  };

  render() {
    return (
      <Layout>
        <h3>Create a CryptoCoupon Company</h3>

        <Form onSubmit={this.onSubmit} error={!!this.state.errorMessage}>
          <Form.Field>
            <label>Name</label>
            <Input
              value={this.state.name}
              onChange={event =>
                this.setState({ name: event.target.value })}
            />
            <label>Address</label>
            <Input
              value={this.state.address}
              onChange={event =>
                this.setState({ address: event.target.value })}
            />


          </Form.Field>

          <Message error header="Oops!" content={this.state.errorMessage} />
          <Button loading={this.state.loading} primary>
            Create!
          </Button>
        </Form>
      </Layout>
    );
  }
}

export default CryptoCouponNew;

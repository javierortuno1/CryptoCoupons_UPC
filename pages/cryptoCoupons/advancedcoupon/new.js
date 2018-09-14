import React, { Component } from 'react';
import { Form, Button, Input, Message } from 'semantic-ui-react';
import Layout from '../../../components/Layout';
import factory from '../../../ethereum/factory';
import web3 from '../../../ethereum/web3';
import { Router } from '../../../routes';

class CouponAdvancedNew extends Component {
  state = {
    name: '',
    description : '',
    serialNumber : '',
    gift : true, 
    fee : '', 
    value : '',
    address : '',
    price : '',
    errorMessage: '',
    loading: false
  };

  onSubmit = async event => {
    event.preventDefault();

    this.setState({ loading: true, errorMessage: '' });

    try {
      const accounts = await web3.eth.getAccounts();
      await factory.methods
        .AccessControle()
        .send({
          from: accounts[0]
        });
      await factory.methods
        .createToken(this.state.name, this.state.description, this.state.serialNumber, this.state.gift, this.state.fee, this.state.value, this.state.address, this.state.price)
        .send({
          from: accounts[0],
          gas: '1000000'
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
        <h3>Advanced Coupon</h3>

        <Form onSubmit={this.onSubmit} error={!!this.state.errorMessage}>
          <Form.Field>
            <label>Name</label>
            <Input
              value={this.state.name}
              onChange={event =>
                this.setState({ name: event.target.value })}
            />
            <label>Description</label>
            <Input
              value={this.state.description}
              onChange={event =>
                this.setState({ description: event.target.value })}
            />
            <label>gift</label>
            <Input
              value={this.state.gift}
              onChange={event =>
                this.setState({ gift: event.target.value })}
            />
            <label>Value</label>
            <Input
              value={this.state.value}
              onChange={event =>
                this.setState({ value: event.target.value })}
            />
            <label>Serial Number</label>
            <Input
              value={this.state.serialNumber}
              onChange={event =>
                this.setState({ serialNumber: event.target.value })}
            />
            <label>Fee</label>
            <Input
              value={this.state.fee}
              onChange={event =>
                this.setState({ fee: event.target.value })}
            />
            <label>Address</label>
            <Input
              value={this.state.address}
              onChange={event =>
                this.setState({ address: event.target.value })}
            />
            <label>Price</label>
            <Input
              value={this.state.price}
              onChange={event =>
                this.setState({ price: event.target.value })}
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

export default CouponAdvancedNew;

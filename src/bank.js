
import {randomize, randomizeInt, assert} from './helper.coffee';
import {Nonbank} from './nonbank.js';

const max_customers = 10;

export class Bank {

  constructor() {
    this.customers = [];
    this.reserves = 0;
    this.cb_debt = 0;
  }

  static get_random_bank() {
    let num_customers = randomizeInt(1, max_customers);
    let bank = new Bank()
    bank.customers = [];
    for (var i = 0; i < num_customers; i++) {
      bank.customers.push(Nonbank.get_random_nonbank(bank));
    }
    bank.reserves = bank.customer_deposits();
    bank.cb_debt = 0;
    return bank;
  }

  get assets_total(){
    return this.reserves + this.customer_loans();
  }

  get debt_total() {
    let debt = this.cb_debt + this.customer_deposits() + this.customer_savings();
    return debt;
  }

  get capital() {
    return this.assets_total() - this.debt_total();
  }

  customer_deposits() {
    let sum = 0;
    this.customers.forEach((c) => sum += c.deposit);
    return sum;
  }

  customer_savings() {
    let sum = 0;
    this.customers.forEach((c) => sum += c.savings);
    return sum;
  }

  customer_loans() {
    let sum = 0;
    this.customers.forEach((c) => sum += c.loan);
    return sum;
  }
}

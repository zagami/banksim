var CentralBank = require('./centralbank.coffee');

import {Bank} from './bank.js';

const dflt_params = {
  prime_rate: 0.000,  // prime rate paid by banks for central bank credits
  prime_rate_giro: 0.000, // prime rate paid by central bank to banks for deposits
  credit_interest: 0.00,
  deposit_interest: 0.00,
  deposit_interest_savings: 0.00,
};

class MicroEconomy {
  constructor(numbanks) {
    this.banks = [];
    for(let i = 0; i < numbanks; i++){
      console.log(Bank.get_random_bank);

      this.banks.push(Bank.get_random_bank()); 
    }
    let cb = new CentralBank(this.banks);
    this.params = dflt_params;
  }

  get nonbanks() {
    let all = [];
    this.banks.forEach((bank) => {
      bank.customers.forEach((c) => all.push(c)); 
    });
    return all;
  }
}

module.exports = MicroEconomy;


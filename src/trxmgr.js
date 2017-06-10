
import {assert, randomize, randomizeInt} from './helper.coffee';

export class TrxMgr {
  constructor(microeconomy) {
    this.microeconomy = microeconomy;
    this.banks = microeconomy.banks;
    this.nonbanks = microeconomy.nonbanks;
    this.cb = microeconomy.cb;
    this.params = microeconomy.params;
  }

  one_year() {
    //payments, economic activity
    this.create_transactions();
  }

  create_transactions() {
    // the amounts transferred are randomly chosen based on customer deposit
    // random transactions represent economic activity
    let num_nonbanks = this.nonbanks.length;

    if (num_nonbanks < 2)
      return

    for(let i = 0; i< this.params.num_trx; i++) {
      let nb1_index = randomizeInt(0, num_nonbanks - 1);
      let nb2_index = randomizeInt(0, num_nonbanks - 1);
      while (nb2_index == nb1_index) {
        // only transfers to another customer make sense
        nb2_index = randomizeInt(0, num_nonbanks - 1)
      }
      let nb1 = this.nonbanks[nb1_index];
      let nb2 = this.nonbanks[nb2_index];
      let amount = randomize(0, nb1.deposit)
      if (amount > 0)
        this.transfer(nb1, nb2, amount);
    }
  }
  // transferring money from one nonbank to another
  transfer (from, to, amount) {
    assert(from.deposit >= amount, 'not enough deposits')
    assert(amount > 0, 'cannot transfer negative amount')

    from.deposit -= amount
    to.deposit += amount
    assert(from.deposit >= 0, 'deposit must not be negative')
  }
}

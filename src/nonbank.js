
const dflt_initial_deposit_per_nonbank = 10;

export class Nonbank {
  constructor(bank, deposit, savings, loan) {
    this.bank = bank;
    this.deposit = deposit;
    this.savings = savings;
    this.loan = loan;
  }

  wealth() {
    return this.deposit + this.savings;
  }

  assets_total() {
    return this.deposit + this.savings;
  }

  capital() {
    return this.assets_total() - this.loan
  }

  static get_random_nonbank(bank) {
    let deposit = dflt_initial_deposit_per_nonbank;
    let loan = 0;
    let savings = 0;
    return new Nonbank(bank, deposit, savings, loan);
  }
}

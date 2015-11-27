// Generated by CoffeeScript 1.9.3
var Bank, CentralBank, MicroEconomy, TrxMgr, randomize, randomizeInt;

randomize = function(from, to) {
  var x;
  x = to - from;
  return parseFloat(from + x * Math.random());
};

randomizeInt = function(from, to) {
  var x;
  x = to - from + 1;
  return Math.floor(from + x * Math.random());
};

CentralBank = (function() {
  function CentralBank(banks) {
    this.banks = banks;
  }

  CentralBank.prototype.credits_total = function() {
    var bank, i, len, ref, sum;
    sum = 0;
    ref = this.banks;
    for (i = 0, len = ref.length; i < len; i++) {
      bank = ref[i];
      sum += bank.credit_cb;
    }
    return sum;
  };

  CentralBank.prototype.giro_total = function() {
    var bank, giro, i, len, ref;
    giro = 0;
    ref = this.banks;
    for (i = 0, len = ref.length; i < len; i++) {
      bank = ref[i];
      giro += bank.reserves;
    }
    return giro;
  };

  CentralBank.prototype.capital = function() {
    return this.credits_total() - this.giro_total();
  };

  CentralBank.prototype.M0 = function() {
    return this.giro_total();
  };

  CentralBank.prototype.M1 = function() {
    var bank, i, len, ref, sum;
    sum = 0;
    ref = this.banks;
    for (i = 0, len = ref.length; i < len; i++) {
      bank = ref[i];
      sum += bank.giral;
    }
    return sum;
  };

  CentralBank.prototype.M2 = function() {
    return 0;
  };

  return CentralBank;

})();

Bank = (function() {
  Bank.prototype.gameover = false;

  function Bank(reserves, credits, credit_cb1, giral1, capital1) {
    this.reserves = reserves;
    this.credits = credits;
    this.credit_cb = credit_cb1;
    this.giral = giral1;
    this.capital = capital1;
  }

  Bank.prototype.get_random_bank = function() {
    var c, capital, credit_cb, giral, r;
    r = randomize(0, 100);
    c = randomize(r, 300);
    credit_cb = r;
    giral = randomize(r, c);
    capital = r + c - giral - credit_cb;
    return new Bank(r, c, credit_cb, giral, capital);
  };

  Bank.prototype.deposit = function(amount) {
    this.reserves += amount;
    return this.giral += amount;
  };

  Bank.prototype.withdraw = function(amount) {
    this.reserves -= amount;
    return this.giral -= amount;
  };

  Bank.prototype.gameover = function() {
    console.log("gameover");
    this.gameover = true;
    return this.reserves = this.credits = this.credit_cb = this.giral = this.capital = 0;
  };

  return Bank;

})();

MicroEconomy = (function() {
  function MicroEconomy(cb, banks) {
    this.cb = cb;
    this.banks = banks;
  }

  return MicroEconomy;

})();

TrxMgr = (function() {
  function TrxMgr(params, microeconomy) {
    this.params = params;
    this.microeconomy = microeconomy;
    this.banks = this.microeconomy.banks;
    this.cb = this.microeconomy.cb;
  }

  TrxMgr.prototype.transfer = function(from, to, amount) {
    var diff;
    if (from.reserves > amount) {
      from.withdraw(amount);
      return to.deposit(amount);
    } else {
      console.log("not enough funds");
      diff = amount - from.reserves;
      from.credit_cb += diff;
      from.reserves += diff;
      return this.transfer(from, to, amount);
    }
  };

  TrxMgr.prototype.one_year = function() {
    this.create_transactions();
    this.customer_credits();
    this.pay_customer_interests();
    this.pay_cb_interests();
    this.settle_reserves();
    return this.settle_capital_requirement();
  };

  TrxMgr.prototype.create_transactions = function() {
    var amount, bank_src, bank_tgt, i, max_trx, ref, results, trx;
    max_trx = randomizeInt(1, parseInt(this.params.max_trx()));
    results = [];
    for (trx = i = 1, ref = max_trx; 1 <= ref ? i <= ref : i >= ref; trx = 1 <= ref ? ++i : --i) {
      bank_src = randomizeInt(0, this.banks.length - 1);
      bank_tgt = randomizeInt(0, this.banks.length - 1);
      bank_src = this.banks[bank_src];
      bank_tgt = this.banks[bank_tgt];
      amount = randomize(0, bank_src.giral);
      if (bank_src !== bank_tgt && !(bank_src.gameover || bank_tgt.gameover)) {
        results.push(this.transfer(bank_src, bank_tgt, amount));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  TrxMgr.prototype.pay_customer_interests = function() {
    var bank, cr, debt_bank, debt_cust, diff, dr, i, len, ref, results;
    cr = parseFloat(this.params.credit_interest()) / 100.0;
    dr = parseFloat(this.params.deposit_interest()) / 100.0;
    ref = this.banks;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      bank = ref[i];
      debt_cust = cr * bank.giral;
      debt_bank = dr * bank.giral;
      if (bank.giral < debt_cust) {
        diff = debt_cust - bank.giral;
        bank.credits += diff;
        bank.capital += diff;
      } else {
        bank.giral -= debt_cust;
        bank.capital += debt_cust;
      }
      bank.giral += debt_bank;
      results.push(bank.capital -= debt_bank);
    }
    return results;
  };

  TrxMgr.prototype.customer_credits = function() {
    var amount, bank, i, len, ref, results;
    ref = this.banks;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      bank = ref[i];
      amount = randomizeInt(0, Math.min(bank.credits, bank.giral));
      bank.credits -= amount;
      bank.giral -= amount;
      amount = randomizeInt(0, bank.credits);
      bank.credits += amount;
      results.push(bank.giral += amount);
    }
    return results;
  };

  TrxMgr.prototype.pay_cb_interests = function() {
    var bank, debt, i, interest, len, pr, pr_giro, ref, results;
    pr = parseFloat(this.params.prime_rate()) / 100.0;
    pr_giro = parseFloat(this.params.prime_rate_giro()) / 100.0;
    ref = this.banks;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      bank = ref[i];
      interest = pr_giro * bank.reserves;
      bank.reserves += interest;
      bank.capital += interest;
      debt = pr * bank.credit_cb;
      if (debt > bank.reserves || debt > bank.capital) {
        console.log("debt: " + debt + ", reserves: " + bank.reserves + ", capital: " + bank.capital);
        results.push(bank.gameover());
      } else {
        bank.reserves -= debt;
        results.push(bank.capital -= debt);
      }
    }
    return results;
  };

  TrxMgr.prototype.settle_reserves = function() {
    var bank, diff, i, len, minimal_reserves, ref, results;
    minimal_reserves = parseFloat(this.params.minimal_reserves()) / 100.0;
    ref = this.banks;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      bank = ref[i];
      if (bank.reserves < bank.giral * minimal_reserves) {
        diff = bank.giral * minimal_reserves - bank.reserves;
        this.credit_cb += diff;
        results.push(bank.reserves += diff);
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  TrxMgr.prototype.settle_capital_requirement = function() {
    var bank, cap_req, i, len, payback, ref, results, total;
    cap_req = parseFloat(this.params.cap_req()) / 100.0;
    ref = this.banks;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      bank = ref[i];
      total = bank.capital + bank.giral + bank.credit_cb;
      if (bank.capital < total * cap_req) {
        payback = Math.min(bank.credit_cb, bank.reserves);
        bank.credit_cb -= payback;
        bank.reserves -= payback;
        total = bank.capital + bank.giral + bank.credit_cb;
        if (bank.capital < total * cap_req) {
          results.push(bank.gameover());
        } else {
          results.push(void 0);
        }
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  return TrxMgr;

})();

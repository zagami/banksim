// Generated by CoffeeScript 1.9.3
var Bank, BankCustomer, CentralBank, DFLT_INITIAL_DEPOSIT_PER_CUST, DFLT_INITIAL_LOAN_PER_CUST, InterbankMarket, MAX_CUSTOMERS, MicroEconomy, NUM_BANKS, Params, State, Statistics, TAX_RATE, TrxMgr, assert, random_array, randomize, randomizeInt;

NUM_BANKS = 10;

MAX_CUSTOMERS = 10;

DFLT_INITIAL_DEPOSIT_PER_CUST = 10;

DFLT_INITIAL_LOAN_PER_CUST = 15;

TAX_RATE = 0.1;

assert = function(condition, message) {
  var e;
  if (!condition) {
    message = message || "Assertion failed";
    if (typeof Error !== "undefined") {
      e = new Error(message);
      console.log(e.stack);
      alert(message);
      throw e;
    }
    throw message;
  }
};

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

random_array = function(amount, n) {
  var arr, average, i, j, ref, rest, val;
  average = amount / n;
  rest = amount;
  arr = [];
  for (i = j = 1, ref = n - 1; 1 <= ref ? j <= ref : j >= ref; i = 1 <= ref ? ++j : --j) {
    val = randomize(0, 2 * average);
    arr.push(val);
    rest -= val;
  }
  arr.push(rest);
  return arr;
};

if (!Array.prototype.sum) {
  Array.prototype.sum = function() {
    var i, s;
    i = this.length;
    s = 0;
    while (i > 0) {
      s += this[--i];
    }
    return s;
  };
}

if (!Array.prototype.last) {
  Array.prototype.last = function() {
    var i;
    i = this.length;
    return this[i - 1];
  };
}

Params = (function() {
  function Params() {}

  Params.prototype.max_trx = 500;

  Params.prototype.prime_rate = 0.000;

  Params.prototype.prime_rate_giro = 0.000;

  Params.prototype.libor = 0.000;

  Params.prototype.cap_req = 0.00;

  Params.prototype.minimal_reserves = 0.00;

  Params.prototype.credit_interest = 0.00;

  Params.prototype.deposit_interest = 0.00;

  return Params;

})();

Statistics = (function() {
  function Statistics(microeconomy) {
    this.microeconomy = microeconomy;
    this.banks = this.microeconomy.banks;
    this.cb = this.microeconomy.cb;
    this.m0_series = [];
    this.m1_series = [];
    this.m2_series = [];
    this.m0_inflation_series = [];
    this.m1_inflation_series = [];
    this.m2_inflation_series = [];
    this.cb_b_flow_series = [];
    this.cb_s_flow_series = [];
    this.b_cb_flow_series = [];
    this.b_c_flow_series = [];
    this.b_s_flow_series = [];
    this.c_b_flow_series = [];
    this.c_c_flow_series = [];
    this.c_s_flow_series = [];
    this.s_c_flow_series = [];
    this.s_b_flow_series = [];
    this.reset_money_flow();
  }

  Statistics.prototype.reset_money_flow = function() {
    this.cb_b_flow = 0;
    this.cb_s_flow = 0;
    this.b_cb_flow = 0;
    this.b_c_flow = 0;
    this.b_s_flow = 0;
    this.c_b_flow = 0;
    this.c_c_flow = 0;
    this.c_s_flow = 0;
    this.s_c_flow = 0;
    return this.s_b_flow = 0;
  };

  Statistics.prototype.m0 = function() {
    return this.cb.giro_total();
  };

  Statistics.prototype.m1 = function() {
    var bank, j, len1, ref, sum;
    sum = 0;
    ref = this.banks;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      bank = ref[j];
      sum += bank.customer_deposits();
    }
    return sum;
  };

  Statistics.prototype.m2 = function() {
    var bank, j, len1, ref, sum;
    sum = 0;
    ref = this.banks;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      bank = ref[j];
      sum += bank.customer_savings();
    }
    return this.m1() + sum;
  };

  Statistics.prototype.one_year = function() {
    var infl_m0, infl_m1, infl_m2, len;
    this.m0_series.push(this.m0());
    this.m1_series.push(this.m1());
    this.m2_series.push(this.m2());
    len = this.m1_series.length;
    if (len > 1) {
      infl_m0 = (this.m0_series[len - 1] / this.m0_series[len - 2] - 1) * 100;
      this.m0_inflation_series.push(infl_m0);
      infl_m1 = (this.m1_series[len - 1] / this.m1_series[len - 2] - 1) * 100;
      this.m1_inflation_series.push(infl_m1);
      infl_m2 = (this.m2_series[len - 1] / this.m2_series[len - 2] - 1) * 100;
      this.m2_inflation_series.push(infl_m2);
    }
    this.cb_b_flow_series.push(this.cb_b_flow);
    this.cb_s_flow_series.push(this.cb_s_flow);
    this.b_cb_flow_series.push(this.b_cb_flow);
    this.b_c_flow_series.push(this.b_c_flow);
    this.b_s_flow_series.push(this.b_s_flow);
    this.c_b_flow_series.push(this.c_b_flow);
    this.c_s_flow_series.push(this.c_s_flow);
    this.c_c_flow_series.push(this.c_c_flow);
    this.s_c_flow_series.push(this.s_c_flow);
    this.s_b_flow_series.push(this.s_b_flow);
    return this.reset_money_flow();
  };

  Statistics.prototype.wealth_distribution = function() {
    var c, girals, result;
    girals = (function() {
      var j, len1, ref, results;
      ref = this.microeconomy.all_customers();
      results = [];
      for (j = 0, len1 = ref.length; j < len1; j++) {
        c = ref[j];
        results.push(c.giral);
      }
      return results;
    }).call(this);
    result = girals.sort(function(a, b) {
      return a - b;
    });
    return result;
  };

  return Statistics;

})();

CentralBank = (function() {
  function CentralBank(state, banks) {
    this.state = state;
    this.banks = banks;
  }

  CentralBank.prototype.credits_total = function() {
    var bank, j, len1, ref, sum;
    sum = 0;
    ref = this.banks;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      bank = ref[j];
      sum += bank.cb_debt;
    }
    return sum;
  };

  CentralBank.prototype.giro_total = function() {
    var bank, giro_banks, j, len1, ref;
    giro_banks = 0;
    ref = this.banks;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      bank = ref[j];
      giro_banks += bank.reserves;
    }
    return giro_banks + this.state.reserves;
  };

  CentralBank.prototype.assets_total = function() {
    return this.credits_total();
  };

  CentralBank.prototype.liabilities_total = function() {
    return this.giro_total() + this.capital();
  };

  CentralBank.prototype.capital = function() {
    return this.credits_total() - this.giro_total();
  };

  return CentralBank;

})();

InterbankMarket = (function() {
  InterbankMarket.instance = null;

  InterbankMarket.prototype.get_instance = function() {
    if (this.instance == null) {
      this.instance = new InterbankMarket();
    }
    return this.instance;
  };

  function InterbankMarket() {
    this.interbank = new Hashtable();
  }

  InterbankMarket.prototype.reset = function() {
    return this.instance = null;
  };

  InterbankMarket.prototype.give_interbank_loan = function(from, to, amount) {
    var hash, val;
    assert(from !== to, "banks not different");
    assert(amount > 0, "credit amount must be > 0");
    assert(from.reserves >= amount, "not enough reserves for interbank credit");
    assert(!from.gameover, "bankrupt bank cannot give credit");
    assert(!to.gameover, "bankrupt bank cannot get credit");
    assert(this.interbank !== null, "interbank null");
    from.reserves -= amount;
    to.reserves += amount;
    if (!this.interbank.containsKey(from)) {
      hash = new Hashtable();
      hash.put(to, amount);
      this.interbank.put(from, hash);
    } else {
      if (this.interbank.get(from).containsKey(to)) {
        val = this.interbank.get(from).get(to);
        this.interbank.get(from).put(to, val + amount);
      } else {
        this.interbank.get(from).put(to, amount);
      }
    }
    if (!this.interbank.containsKey(to)) {
      hash = new Hashtable();
      hash.put(from, -amount);
      return this.interbank.put(to, hash);
    } else {
      if (this.interbank.get(to).containsKey(from)) {
        val = this.interbank.get(to).get(from);
        return this.interbank.get(to).put(from, val - amount);
      } else {
        return this.interbank.get(to).put(from, -amount);
      }
    }
  };

  InterbankMarket.prototype.get_interbank_loans = function(bank) {
    var j, len1, ref, total, v;
    total = 0;
    if (this.interbank.containsKey(bank)) {
      ref = this.interbank.get(bank).values();
      for (j = 0, len1 = ref.length; j < len1; j++) {
        v = ref[j];
        if (v > 0) {
          total += v;
        }
      }
    }
    return total;
  };

  InterbankMarket.prototype.get_interbank_debt = function(bank) {
    var j, len1, ref, total, v;
    total = 0;
    if (this.interbank.containsKey(bank)) {
      ref = this.interbank.get(bank).values();
      for (j = 0, len1 = ref.length; j < len1; j++) {
        v = ref[j];
        if (v < 0) {
          total += Math.abs(v);
        }
      }
    }
    return total;
  };

  InterbankMarket.prototype.settle_interbank_interests = function(libor) {
    var b, j, key, len1, ref, results, val;
    ref = this.interbank.keys();
    results = [];
    for (j = 0, len1 = ref.length; j < len1; j++) {
      b = ref[j];
      results.push((function() {
        var k, len2, ref1, results1;
        ref1 = this.interbank.get(b).keys();
        results1 = [];
        for (k = 0, len2 = ref1.length; k < len2; k++) {
          key = ref1[k];
          val = this.interbank.get(b).get(key);
          this.interbank.get(b).put(key, val * (1 + libor));
          results1.push(b.capital += val * libor);
        }
        return results1;
      }).call(this));
    }
    return results;
  };

  InterbankMarket.prototype.set_gameover = function(bank) {
    var b, bank_loss, j, len1, ref;
    if (this.interbank.containsKey(bank)) {
      ref = this.interbank.get(bank).keys();
      for (j = 0, len1 = ref.length; j < len1; j++) {
        b = ref[j];
        if (this.interbank.containsKey(b)) {
          bank_loss = this.interbank.get(b).get(bank);
          if (bank_loss > 0) {
            console.log("bank just lost " + bank_loss + " from a bankcupcy");
            b.capital -= bank_loss;
          } else if (bank_loss < 0) {
            console.log("bank just gained " + (Math.abs(bank_loss)) + " a from bankrupcy");
            b.capital += Math.abs(bank_loss);
          }
          this.interbank.get(b).remove(bank);
        }
      }
      return this.interbank.get(bank).clear();
    }
  };

  return InterbankMarket;

})();

Bank = (function() {
  Bank.prototype.gameover = false;

  Bank.prototype.interbank_market = null;

  Bank.prototype.customers = [];

  Bank.prototype.reserves = 0;

  Bank.prototype.cb_debt = 0;

  Bank.prototype.capital = 0;

  function Bank() {
    this.interbank_market = InterbankMarket.prototype.get_instance();
  }

  Bank.prototype.get_random_bank = function() {
    var bank, i, num_customers;
    num_customers = randomizeInt(1, MAX_CUSTOMERS);
    bank = new Bank();
    bank.customers = (function() {
      var j, ref, results;
      results = [];
      for (i = j = 1, ref = num_customers; 1 <= ref ? j <= ref : j >= ref; i = 1 <= ref ? ++j : --j) {
        results.push(BankCustomer.prototype.get_random_customer(bank));
      }
      return results;
    })();
    bank.reserves = 100;
    bank.cb_debt = bank.reserves;
    bank.capital = bank.assets_total() - bank.debt_total();
    return bank;
  };

  Bank.prototype.assets_total = function() {
    return this.reserves + this.customer_loans() + this.interbank_loans();
  };

  Bank.prototype.liabilities_total = function() {
    return this.cb_debt + this.interbank_debt() + this.customer_deposits() + this.customer_savings() + this.capital;
  };

  Bank.prototype.debt_total = function() {
    return this.cb_debt + this.interbank_debt() + this.customer_deposits();
  };

  Bank.prototype.customer_deposits = function() {
    var c, j, len1, ref, sum;
    sum = 0;
    ref = this.customers;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      c = ref[j];
      sum += c.giral;
    }
    return sum;
  };

  Bank.prototype.customer_savings = function() {
    var c, j, len1, ref, sum;
    sum = 0;
    ref = this.customers;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      c = ref[j];
      sum += c.savings;
    }
    return sum;
  };

  Bank.prototype.customer_loans = function() {
    var c, j, len1, ref, sum;
    sum = 0;
    ref = this.customers;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      c = ref[j];
      sum += c.loan;
    }
    return sum;
  };

  Bank.prototype.interbank_loans = function() {
    return this.interbank_market.get_interbank_loans(this);
  };

  Bank.prototype.interbank_debt = function() {
    return this.interbank_market.get_interbank_debt(this);
  };

  Bank.prototype.give_interbank_loan = function(to, amount) {
    return this.interbank_market.give_interbank_loan(this, to, amount);
  };

  return Bank;

})();

BankCustomer = (function() {
  BankCustomer.prototype.income = 0;

  BankCustomer.prototype.expenses = 0;

  function BankCustomer(bank1, giral1, savings1, loan1) {
    this.bank = bank1;
    this.giral = giral1;
    this.savings = savings1;
    this.loan = loan1;
  }

  BankCustomer.prototype.get_random_customer = function(bank) {
    var giral, loan, savings;
    giral = DFLT_INITIAL_DEPOSIT_PER_CUST;
    loan = DFLT_INITIAL_LOAN_PER_CUST;
    savings = 0;
    return new BankCustomer(bank, giral, savings, loan);
  };

  BankCustomer.prototype.profit = function() {
    return this.income - this.expenses;
  };

  BankCustomer.prototype.assets_total = function() {
    return this.giral + this.savings;
  };

  return BankCustomer;

})();

MicroEconomy = (function() {
  function MicroEconomy(state, cb, banks, params) {
    this.state = state;
    this.cb = cb;
    this.banks = banks;
    this.params = params;
    this.stats = new Statistics(this);
  }

  MicroEconomy.prototype.all_customers = function() {
    var all_customers, bank, c, j, k, len1, len2, ref, ref1;
    all_customers = [];
    ref = this.banks;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      bank = ref[j];
      if (!bank.gameover) {
        ref1 = bank.customers;
        for (k = 0, len2 = ref1.length; k < len2; k++) {
          c = ref1[k];
          all_customers.push(c);
        }
      }
    }
    return all_customers;
  };

  return MicroEconomy;

})();

State = (function() {
  function State() {
    this.public_service_series = [];
    this.income_tax_series = [];
    this.reserves = 0;
  }

  return State;

})();

TrxMgr = (function() {
  function TrxMgr(microeconomy) {
    this.microeconomy = microeconomy;
    this.banks = this.microeconomy.banks;
    this.cb = this.microeconomy.cb;
    this.stats = this.microeconomy.stats;
    this.state = this.microeconomy.state;
    this.interbank_market = InterbankMarket.prototype.get_instance();
    this.params = this.microeconomy.params;
  }

  TrxMgr.prototype.one_year = function() {
    this.create_transactions();
    this.pay_customer_deposit_interests();
    this.get_customer_credit_interests();
    this.manage_customer_credits();
    this.get_cb_deposit_interests();
    this.pay_cb_credit_interests();
    this.pay_interbank_interests();
    this.manage_bank_debt();
    this.make_statistics();
    this.check_consistency();
    return this.check_bankrupcy();
  };

  TrxMgr.prototype.check_consistency = function() {
    var a, bank, j, l, len1, ref, results;
    a = this.cb.assets_total();
    l = this.cb.liabilities_total();
    assert(Math.round(1000 * a) - Math.round(1000 * l) === 0, "central bank balance sheet inconsistent: " + a + " != " + l + " ");
    ref = this.banks;
    results = [];
    for (j = 0, len1 = ref.length; j < len1; j++) {
      bank = ref[j];
      if (!(!bank.gameover)) {
        continue;
      }
      a = bank.assets_total();
      l = bank.liabilities_total();
      results.push(assert(Math.round(1000 * a) - Math.round(1000 * l) === 0, "bank balance sheet inconsistent: " + a + " != " + l + " "));
    }
    return results;
  };

  TrxMgr.prototype.check_bankrupcy = function() {
    var bank, j, len1, ref, results;
    if (this.cb.capital() < -0.01) {
      alert("central bank capital cannot be negative, " + (this.cb.capital()));
    }
    ref = this.banks;
    results = [];
    for (j = 0, len1 = ref.length; j < len1; j++) {
      bank = ref[j];
      if (bank.capital < -0.01 && !bank.gameover) {
        results.push(alert("bank capital cannot be negative " + bank.capital));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  TrxMgr.prototype.create_transactions = function() {
    var all_customers, amount, bank_src, bank_tgt, cust1, cust1_index, cust2, cust2_index, j, max_trx, num_customers, ref, results, trx;
    max_trx = randomizeInt(1, this.params.max_trx);
    console.log("performing " + max_trx + " transactions");
    all_customers = this.microeconomy.all_customers();
    num_customers = all_customers.length;
    if (num_customers < 2) {
      return;
    }
    results = [];
    for (trx = j = 1, ref = max_trx; 1 <= ref ? j <= ref : j >= ref; trx = 1 <= ref ? ++j : --j) {
      cust1_index = randomizeInt(0, num_customers - 1);
      cust2_index = randomizeInt(0, num_customers - 1);
      while (cust2_index === cust1_index) {
        cust2_index = randomizeInt(0, num_customers - 1);
      }
      cust1 = all_customers[cust1_index];
      cust2 = all_customers[cust2_index];
      bank_src = cust1.bank;
      bank_tgt = cust2.bank;
      amount = Math.min(randomize(0, 10), cust1.giral);
      results.push(this.transfer(cust1, cust2, amount));
    }
    return results;
  };

  TrxMgr.prototype.transfer = function(from, to, amount) {
    if (from.bank !== to.bank && from.bank.reserves < amount) {
      this.get_new_bank_loan(from, amount);
    }
    if (from.bank !== to.bank) {
      from.bank.reserves -= amount;
      to.bank.reserves += amount;
    }
    from.expenses += amount;
    to.income += amount;
    from.giral -= amount;
    to.giral += amount;
    return this.stats.c_c_flow += amount;
  };

  TrxMgr.prototype.pay_customer_deposit_interests = function() {
    var bank, c, debt_bank, dr, j, len1, ref, results;
    dr = this.params.deposit_interest;
    ref = this.banks;
    results = [];
    for (j = 0, len1 = ref.length; j < len1; j++) {
      bank = ref[j];
      if (!bank.gameover) {
        results.push((function() {
          var k, len2, ref1, results1;
          ref1 = bank.customers;
          results1 = [];
          for (k = 0, len2 = ref1.length; k < len2; k++) {
            c = ref1[k];
            debt_bank = dr * c.giral;
            c.giral += debt_bank;
            c.income += debt_bank;
            bank.capital -= debt_bank;
            results1.push(this.stats.b_c_flow += debt_bank);
          }
          return results1;
        }).call(this));
      }
    }
    return results;
  };

  TrxMgr.prototype.get_customer_credit_interests = function() {
    var bank, c, cr, debt_cust, diff, j, len1, ref, results;
    cr = this.params.credit_interest;
    ref = this.banks;
    results = [];
    for (j = 0, len1 = ref.length; j < len1; j++) {
      bank = ref[j];
      if (!bank.gameover) {
        results.push((function() {
          var k, len2, ref1, results1;
          ref1 = bank.customers;
          results1 = [];
          for (k = 0, len2 = ref1.length; k < len2; k++) {
            c = ref1[k];
            debt_cust = cr * c.loan;
            if (c.giral < debt_cust) {
              diff = debt_cust - c.giral;
              c.loan += diff;
              bank.capital += debt_cust;
              c.giral = 0;
              c.expenses += debt_cust;
              results1.push(this.stats.c_b_flow += debt_cust);
            } else {
              c.giral -= debt_cust;
              c.expenses += debt_cust;
              bank.capital += debt_cust;
              results1.push(this.stats.c_b_flow += debt_cust);
            }
          }
          return results1;
        }).call(this));
      }
    }
    return results;
  };

  TrxMgr.prototype.get_cb_deposit_interests = function() {
    var bank, interest, j, len1, pr_giro, ref, results;
    pr_giro = this.params.prime_rate_giro;
    interest = pr_giro * this.state.reserves;
    this.state.reserves += interest;
    this.stats.cb_s_flow += interest;
    ref = this.banks;
    results = [];
    for (j = 0, len1 = ref.length; j < len1; j++) {
      bank = ref[j];
      if (!(!bank.gameover)) {
        continue;
      }
      interest = pr_giro * bank.reserves;
      bank.reserves += interest;
      bank.capital += interest;
      results.push(this.stats.cb_b_flow += interest);
    }
    return results;
  };

  TrxMgr.prototype.pay_cb_credit_interests = function() {
    var bank, debt, diff, j, len1, pr, ref, results;
    pr = this.params.prime_rate;
    ref = this.banks;
    results = [];
    for (j = 0, len1 = ref.length; j < len1; j++) {
      bank = ref[j];
      if (!(!bank.gameover)) {
        continue;
      }
      debt = pr * bank.cb_debt;
      if (debt > bank.reserves) {
        diff = debt - bank.reserves;
        bank.capital -= debt;
        bank.reserves = 0;
        bank.cb_debt += diff;
      } else {
        bank.reserves -= debt;
        bank.capital -= debt;
      }
      results.push(this.stats.b_cb_flow += debt);
    }
    return results;
  };

  TrxMgr.prototype.pay_interbank_interests = function() {
    return this.interbank_market.settle_interbank_interests(this.params.libor);
  };

  TrxMgr.prototype.manage_customer_credits = function() {
    var cr, dr;
    dr = this.params.deposit_interest;
    return cr = this.params.credit_interest;
  };

  TrxMgr.prototype.collect_taxes = function() {
    var c, income_tax_current_year, j, len1, tax, tax_payers;
    income_tax_current_year = 0;
    tax_payers = this.microeconomy.all_customers();
    for (j = 0, len1 = tax_payers.length; j < len1; j++) {
      c = tax_payers[j];
      tax = TAX_RATE * c.profit();
      if (tax > c.giral) {
        c.dead = true;
        console.log("taxed to death");
      } else {
        c.giral -= tax;
        c.bank.reserves -= tax;
        income_tax_current_year += tax;
      }
      this.stats.c_s_flow += tax;
      c.income = 0;
      c.expenses = 0;
    }
    this.state.income_tax_series.push(income_tax_current_year);
    return this.state.reserves += income_tax_current_year;
  };

  TrxMgr.prototype.provide_public_service = function() {
    var arr, i, j, len, public_service_cost, ref, tax_payers;
    tax_payers = this.microeconomy.all_customers();
    len = tax_payers.length;
    public_service_cost = this.state.reserves;
    arr = random_array(public_service_cost, len);
    if (len === 0) {
      this.state.public_service_series.push(0);
      return;
    }
    for (i = j = 0, ref = len - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
      tax_payers[i].giral += arr[i];
      tax_payers[i].bank.reserves += arr[i];
      tax_payers[i].income += arr[i];
    }
    this.stats.s_c_flow += public_service_cost;
    this.state.reserves -= public_service_cost;
    return this.state.public_service_series.push(public_service_cost);
  };

  TrxMgr.prototype.manage_bank_debt = function() {
    var amount, bank, cr, diff, j, len1, potential, pr, prg, ref, results;
    cr = this.params.cap_req;
    pr = this.params.prime_rate;
    prg = this.params.prime_rate_giro;
    ref = this.banks;
    results = [];
    for (j = 0, len1 = ref.length; j < len1; j++) {
      bank = ref[j];
      if (!(!bank.gameover)) {
        continue;
      }
      if (this.compute_minimal_reserves(bank) > bank.reserves) {
        diff = Math.max(0, this.compute_minimal_reserves(bank) - bank.reserves);
        potential = this.compute_max_new_debt(bank);
        if (diff > potential) {
          this.set_gameover(bank, "cannot fulfill minimal reserve requirement");
          continue;
        }
        this.get_new_bank_loan(bank, diff);
      }
      if (bank.capital / bank.liabilities_total() < cr) {
        potential = this.payback_debt_potential(bank);
        amount = Math.min(potential, bank.cb_debt);
        bank.cb_debt -= amount;
        bank.reserves -= amount;
      }
      if (bank.capital / bank.liabilities_total() < cr) {
        this.set_gameover(bank, "cannot fulfill capital requirements");
        continue;
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  TrxMgr.prototype.get_new_bank_loan = function(bank, amount) {
    var b, demand, ib_loan, j, len1, libor, pot, pr, ref;
    pr = this.params.prime_rate;
    libor = this.params.libor;
    demand = amount;
    if (pr > libor) {
      ref = this.banks;
      for (j = 0, len1 = ref.length; j < len1; j++) {
        b = ref[j];
        if (b !== bank && demand > 0) {
          pot = this.compute_max_new_ib_loan(b);
          ib_loan = Math.min(demand, pot);
          if (ib_loan > 0) {
            b.give_interbank_loan(bank, ib_loan);
            demand -= ib_loan;
          }
        }
      }
    }
    if (demand > 0) {
      bank.reserves += demand;
      return bank.cb_debt += demand;
    }
  };

  TrxMgr.prototype.compute_minimal_reserves = function(bank) {
    var mr;
    mr = this.params.minimal_reserves;
    return mr * (bank.customer_deposits() + bank.cb_debt + bank.interbank_debt());
  };

  TrxMgr.prototype.compute_max_new_customer_loan = function(bank) {
    var cr, limit_cap, limit_mr, mr;
    cr = this.params.cap_req;
    mr = this.params.minimal_reserves;
    limit_cap = (bank.capital - cr * bank.liabilities_total()) / cr;
    limit_cap = Math.max(0, limit_cap);
    limit_mr = (bank.reserves - this.compute_minimal_reserves(bank)) / mr;
    limit_mr = Math.max(0, limit_mr);
    return Math.min(limit_cap, limit_mr);
  };

  TrxMgr.prototype.compute_max_new_ib_loan = function(bank) {
    var limit_mr, mr;
    mr = this.params.minimal_reserves;
    limit_mr = bank.reserves - this.compute_minimal_reserves(bank);
    return Math.max(0, limit_mr);
  };

  TrxMgr.prototype.compute_max_new_debt = function(bank) {
    var cr, limit_cap;
    cr = this.params.cap_req;
    limit_cap = (bank.capital - cr * bank.liabilities_total()) / cr;
    return Math.max(0, limit_cap);
  };

  TrxMgr.prototype.payback_debt_potential = function(bank) {
    var limit_mr, mr;
    mr = this.params.minimal_reserves;
    limit_mr = (bank.reserves - this.compute_minimal_reserves(bank)) / (1 - mr);
    return Math.max(0, limit_mr);
  };

  TrxMgr.prototype.make_statistics = function() {
    return this.stats.one_year();
  };

  TrxMgr.prototype.set_gameover = function(bank, reason) {
    var cb_loss;
    assert(!bank.gameover, "bank is already gameover");
    bank.gameover = true;
    console.log("reason for bankrupcy: " + reason);
    cb_loss = bank.cb_debt - bank.reserves;
    if (cb_loss > 0) {
      console.log("central bank just lost " + cb_loss + " from a bankrupcy");
    } else if (cb_loss < 0) {
      console.log("central bank just won " + (-cb_loss) + " from a bankrupcy");
    }
    this.interbank_market.set_gameover(bank);
    bank.customers = [];
    return bank.reserves = bank.cb_debt = bank.capital = 0;
  };

  return TrxMgr;

})();

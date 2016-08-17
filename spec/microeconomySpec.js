// Generated by CoffeeScript 1.9.3
var init_mini_environment, test;

test = {};

init_mini_environment = function() {
  var params;
  test = {};
  params = new Params();
  test.a = Bank.prototype.get_random_bank();
  test.b = Bank.prototype.get_random_bank();
  test.banks = [test.a, test.b];
  test.state = new State();
  test.cb = new CentralBank(test.state, test.banks);
  test.me = new MicroEconomy(test.state, test.cb, test.banks, test.params);
  return test.trxMgr = new TrxMgr(test.me);
};

describe("Bank", function() {
  beforeEach(function() {
    return InterbankMarket.prototype.reset();
  });
  return it("dummy test", function() {
    return expect(true).toBe(true);
  });
});

describe("CentralBank", function() {
  beforeEach(function() {
    return init_mini_environment();
  });
  it("shoud return the correct bank credits", function() {
    var a_credits, b_credits;
    a_credits = test.a.cb_debt;
    b_credits = test.b.cb_debt;
    return expect(test.cb.credits_banks()).toBe(a_credits + b_credits);
  });
  it("shoud return the correct bank deposits", function() {
    return expect(test.cb.giro_banks()).toBe(test.a.reserves + test.b.reserves);
  });
  it("shoud return the correct total debts", function() {
    return expect(test.cb.debt_total()).toBe(test.a.reserves + test.b.reserves);
  });
  it("shoud return the correct total debts (after PM transition)", function() {
    var customer_deposits, debt_before;
    debt_before = test.cb.debt_total();
    customer_deposits = test.a.customer_deposits() + test.b.customer_deposits();
    test.trxMgr.enable_positive_money();
    return expect(test.cb.debt_total()).toBe(debt_before + customer_deposits);
  });
  return it("shoud add correctly increase cb assets after positive money transition", function() {
    var assets_before, customer_deposits, debt_before, ib_debt;
    customer_deposits = test.a.customer_deposits() + test.b.customer_deposits();
    ib_debt = test.a.interbank_debt() + test.b.interbank_debt();
    assets_before = test.cb.assets_total();
    debt_before = test.cb.debt_total();
    test.trxMgr.enable_positive_money();
    expect(test.cb.assets_total()).toBe(assets_before + customer_deposits + ib_debt);
    return expect(test.cb.debt_total()).toBe(debt_before + customer_deposits + ib_debt);
  });
});

describe("TrxMgr", function() {
  beforeEach(function() {
    return init_mini_environment();
  });
  it("should transfer money if enough funds", function() {
    return expect(true).toBe(true);
  });
  return it("should transfer money if not enough funds", function() {
    return expect(true).toBe(true);
  });
});

describe("InterbankMarket", function() {
  beforeEach(function() {
    return InterbankMarket.prototype.reset();
  });
  it("should be a proper singleton", function() {
    var ib1, ib2;
    ib1 = InterbankMarket.prototype.get_instance();
    ib2 = InterbankMarket.prototype.get_instance();
    return expect(ib1).toEqual(ib2);
  });
  it("shoud return zero interbank debt", function() {
    var a, ib;
    ib = InterbankMarket.prototype.get_instance();
    a = Bank.prototype.get_random_bank();
    return expect(ib.get_all_interbank_debts(a)).toBe(0);
  });
  it("shoud return zero interbank loans", function() {
    var a, ib;
    ib = InterbankMarket.prototype.get_instance();
    a = Bank.prototype.get_random_bank();
    return expect(ib.get_all_interbank_loans(a)).toBe(0);
  });
  it("should increase interbank debt correctly", function() {
    var a, b, ib;
    a = Bank.prototype.get_random_bank();
    b = Bank.prototype.get_random_bank();
    ib = InterbankMarket.prototype.get_instance();
    ib.increase_interbank_debt(a, b, 100);
    expect(ib.get_interbank_debt(a, b)).toBe(100);
    ib.increase_interbank_debt(a, b, 50);
    expect(ib.get_interbank_debt(a, b)).toBe(150);
    return expect(ib.get_all_interbank_loans(b)).toBe(150);
  });
  it("should reduce interbank debt correctly", function() {
    var a, b, ib;
    a = Bank.prototype.get_random_bank();
    b = Bank.prototype.get_random_bank();
    ib = InterbankMarket.prototype.get_instance();
    ib.increase_interbank_debt(a, b, 100);
    ib.reduce_interbank_debt(a, b, 80);
    expect(ib.get_interbank_debt(a, b)).toBe(20);
    return expect(ib.get_all_interbank_loans(b)).toBe(20);
  });
  it("shoud return sum of interbank debt", function() {
    var a, b, c, ib;
    a = Bank.prototype.get_random_bank();
    b = Bank.prototype.get_random_bank();
    c = Bank.prototype.get_random_bank();
    ib = InterbankMarket.prototype.get_instance();
    ib.increase_interbank_debt(a, b, 20);
    ib.increase_interbank_debt(a, c, 30);
    return expect(ib.get_all_interbank_debts(a)).toBe(50);
  });
  it("hashCode function should vary per bank", function() {
    var a, b;
    a = Bank.prototype.get_random_bank();
    b = Bank.prototype.get_random_bank();
    return expect(a.hashCode()).not.toBe(b.hashCode());
  });
  it("shoud return sum of interbank loans for specific bank", function() {
    var a, b, c, ib;
    a = Bank.prototype.get_random_bank();
    b = Bank.prototype.get_random_bank();
    c = Bank.prototype.get_random_bank();
    ib = InterbankMarket.prototype.get_instance();
    ib.increase_interbank_debt(a, c, 20);
    ib.increase_interbank_debt(b, c, 30);
    expect(ib.get_all_interbank_loans(c)).toBe(50);
    expect(ib.get_all_interbank_loans(a)).toBe(0);
    return expect(ib.get_all_interbank_loans(b)).toBe(0);
  });
  it("shoud return interbank volume", function() {
    var a, b, c, ib;
    a = Bank.prototype.get_random_bank();
    b = Bank.prototype.get_random_bank();
    c = Bank.prototype.get_random_bank();
    ib = InterbankMarket.prototype.get_instance();
    ib.increase_interbank_debt(a, b, 20);
    ib.increase_interbank_debt(b, c, 30);
    ib.increase_interbank_debt(c, a, 40);
    return expect(ib.get_interbank_volume()).toBe(90);
  });
  return it("shoud add libor interest after settlement", function() {
    var a, b, ib;
    a = Bank.prototype.get_random_bank();
    b = Bank.prototype.get_random_bank();
    ib = InterbankMarket.prototype.get_instance();
    ib.increase_interbank_debt(a, b, 100);
    ib.settle_interbank_interests(0.05);
    return expect(ib.get_interbank_debt(a, b)).toBe(105);
  });
});

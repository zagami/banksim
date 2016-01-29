test = {}

describe "Bank", ->

  beforeEach ->
    InterbankMarket::reset()

  it "dummy test", ->
    expect(true).toBe(true)

  it "should return the right credit potential", ->
    b = new Bank(1,2,1,1,1)
    limit = b.compute_credit_potential(0.1, 0.1)
    expect(limit).toBeCloseTo(7, 4)

describe "TrxMgr", ->

  beforeEach ->
    test = {}
    params = new Params()
    test.a = Bank::get_random_bank()
    test.a.reserves += 100
    test.a.giral += 100
    test.b = Bank::get_random_bank()
    test.banks = [test.a,test.b]
    test.cb = new CentralBank(test.banks)
    test.me = new MicroEconomy(test.cb, test.banks, test.params)
    test.trxMgr = new TrxMgr(test.me)

  it "should transfer money if enough funds", ->
    ra = test.a.reserves
    ga = test.a.giral
    gb = test.b.giral
    amount = Math.min(ra / 2, ga)
    test.trxMgr.transfer(test.a, test.b, amount)
    assert(test.a.giral == ga - amount, "money transfered wrong")
    assert(test.b.giral == gb + amount, "money received wrong")

  it "should transfer money if not enough funds", ->
    ga = test.a.giral
    ra = test.a.reserves
    gb = test.b.giral
    amount = Math.min(ra * 2, ga)
    test.trxMgr.transfer(test.a, test.b, amount)
    assert(test.a.giral == ga - amount, "money transfered wrong")
    assert(test.b.giral == gb + amount, "money received wrong")

describe "InterbankMarket", ->

  beforeEach ->
    InterbankMarket::reset()

  it "should be a proper singleton", ->
    ib1 = InterbankMarket::get_instance()
    ib2 = InterbankMarket::get_instance()
    expect(ib1).toEqual(ib2)

  it "should return the given credit", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    a.reserves += 500
    a.capital += 500
    ib = InterbankMarket::get_instance()
    expect(ib.get_interbank_credits(a)).toBe(0)
    ib.give_interbank_credit(a,b,100)
    expect(ib.get_interbank_credits(a)).toBe(100)
    
  it "shoud return zero interbank credits", ->
    a = Bank::get_random_bank()
    expect(a.get_interbank_credits()).toBe(0)

  it "shoud return exact interbank credit", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    b.reserves += 500
    b.capital += 500
    b.give_interbank_credit(a, 50)
    expect(b.get_interbank_credits()).toBe(50)
    expect(a.get_interbank_credits()).toBe(0)

  it "shoud return sum of interbank credits", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    b.reserves += 500
    b.capital += 500
    b.give_interbank_credit(a, 44)
    b.give_interbank_credit(a, 50)
    expect(b.get_interbank_credits()).toBe(94)
    expect(a.get_interbank_credits()).toBe(0)

  it "shoud return sum of interbank debts", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    b.reserves += 500
    b.capital += 500
    b.give_interbank_credit(a, 20)
    b.give_interbank_credit(a, 50)
    expect(b.get_interbank_credits()).toBe(70)
    expect(a.get_interbank_debt()).toBe(70)
    expect(a.get_interbank_credits()).toBe(0)
    expect(b.get_interbank_debt()).toBe(0)

  it "shoud not affect assets or liabilities after interbank credit given", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    b.reserves += 500
    b.capital += 500
    assets_before = b.assets_total()
    liabilities_before = b.liabilities_total()
    b.give_interbank_credit(a, 20)
    expect(b.assets_total()).toBeCloseTo(assets_before, 4)
    expect(b.liabilities_total()).toBeCloseTo(liabilities_before, 4)

  it "shoud  increase assets and l. after interbank credit received", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    b.reserves += 500
    b.capital += 500
    assets_before = a.assets_total()
    liabilities_before = a.liabilities_total()
    b.give_interbank_credit(a, 20)
    expect(a.assets_total()).toBeCloseTo(assets_before + 20, 4)
    expect(a.liabilities_total()).toBeCloseTo(liabilities_before + 20)

  it "should write off interbank debt after bankrupcy", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    b.reserves += 500
    b.capital += 500
    b.give_interbank_credit(a, 50)
    expect(b.get_interbank_credits()).toBe(50)
    a.set_gameover()
    expect(b.get_interbank_credits()).toBe(0)

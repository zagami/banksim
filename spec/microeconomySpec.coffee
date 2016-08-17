test = {}
init_mini_environment = ->
  test = {}
  params = new Params()
  test.a = Bank::get_random_bank()
  test.b = Bank::get_random_bank()
  test.banks = [test.a,test.b]
  test.state = new State()
  test.cb = new CentralBank(test.state, test.banks)
  test.me = new MicroEconomy(test.state, test.cb, test.banks, test.params)
  test.trxMgr = new TrxMgr(test.me)

describe "Bank", ->

  beforeEach ->
    InterbankMarket::reset()

  it "dummy test", ->
    expect(true).toBe(true)

describe "CentralBank", ->

  beforeEach ->
    init_mini_environment()

  it "shoud return the correct bank credits", ->
    a_credits = test.a.cb_debt
    b_credits = test.b.cb_debt
    expect(test.cb.credits_banks()).toBe(a_credits + b_credits)

  it "shoud return the correct bank deposits", ->
    expect(test.cb.giro_banks()).toBe(test.a.reserves + test.b.reserves)

  it "shoud return the correct total debts", ->
    expect(test.cb.debt_total()).toBe(test.a.reserves + test.b.reserves)

  it "shoud return the correct total debts (after PM transition)", ->
    debt_before = test.cb.debt_total()
    customer_deposits = test.a.customer_deposits() + test.b.customer_deposits()
    test.trxMgr.enable_positive_money()
    expect(test.cb.debt_total()).toBe(debt_before + customer_deposits)

  it "shoud add correctly increase cb assets after positive money transition", ->
    customer_deposits = test.a.customer_deposits() + test.b.customer_deposits()
    ib_debt = test.a.interbank_debt() + test.b.interbank_debt()
    assets_before = test.cb.assets_total()
    debt_before = test.cb.debt_total()
    test.trxMgr.enable_positive_money()
    expect(test.cb.assets_total()).toBe(assets_before + customer_deposits + ib_debt)
    expect(test.cb.debt_total()).toBe(debt_before + customer_deposits + ib_debt)

describe "TrxMgr", ->

  beforeEach ->
    init_mini_environment()

  it "should transfer money if enough funds", ->
    expect(true).toBe(true)

  it "should transfer money if not enough funds", ->
    expect(true).toBe(true)

describe "InterbankMarket", ->

  beforeEach ->
    InterbankMarket::reset()

  it "should be a proper singleton", ->
    ib1 = InterbankMarket::get_instance()
    ib2 = InterbankMarket::get_instance()
    expect(ib1).toEqual(ib2)

  it "shoud return zero interbank debt", ->
    ib = InterbankMarket::get_instance()
    a = Bank::get_random_bank()
    expect(ib.get_all_interbank_debts(a)).toBe(0)

  it "shoud return zero interbank loans", ->
    ib = InterbankMarket::get_instance()
    a = Bank::get_random_bank()
    expect(ib.get_all_interbank_loans(a)).toBe(0)

  it "should increase interbank debt correctly", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    ib = InterbankMarket::get_instance()
    ib.increase_interbank_debt(a,b,100)
    expect(ib.get_interbank_debt(a, b)).toBe(100)
    ib.increase_interbank_debt(a,b,50)
    expect(ib.get_interbank_debt(a,b)).toBe(150)
    expect(ib.get_all_interbank_loans(b)).toBe(150)
    
  it "should reduce interbank debt correctly", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    ib = InterbankMarket::get_instance()
    ib.increase_interbank_debt(a,b,100)
    ib.reduce_interbank_debt(a,b,80)
    expect(ib.get_interbank_debt(a, b)).toBe(20)
    expect(ib.get_all_interbank_loans(b)).toBe(20)

  it "shoud return sum of interbank debt", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    c = Bank::get_random_bank()
    ib = InterbankMarket::get_instance()
    ib.increase_interbank_debt(a,b,20)
    ib.increase_interbank_debt(a,c,30)
    expect(ib.get_all_interbank_debts(a)).toBe(50)

  it "hashCode function should vary per bank", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    expect(a.hashCode()).not.toBe(b.hashCode())

  it "shoud return sum of interbank loans for specific bank", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    c = Bank::get_random_bank()
    ib = InterbankMarket::get_instance()
    ib.increase_interbank_debt(a,c,20)
    ib.increase_interbank_debt(b,c,30)
    expect(ib.get_all_interbank_loans(c)).toBe(50)
    expect(ib.get_all_interbank_loans(a)).toBe(0)
    expect(ib.get_all_interbank_loans(b)).toBe(0)

  it "shoud return interbank volume", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    c = Bank::get_random_bank()
    ib = InterbankMarket::get_instance()
    ib.increase_interbank_debt(a,b,20)
    ib.increase_interbank_debt(b,c,30)
    ib.increase_interbank_debt(c,a,40)
    expect(ib.get_interbank_volume()).toBe(90)

  it "shoud add libor interest after settlement", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    ib = InterbankMarket::get_instance()
    ib.increase_interbank_debt(a,b,100)
    ib.settle_interbank_interests(0.05)
    expect(ib.get_interbank_debt(a, b)).toBe(105)

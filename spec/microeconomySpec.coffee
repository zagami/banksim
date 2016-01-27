test = {}

describe "Bank", ->

  beforeEach ->
    test.bank = Bank::get_random_bank()

  it "dummy test", ->
    expect(true).toBe(true)

  it "should return the right credit potential", ->
    b = new Bank(1,2,1,1,1)
    limit = b.compute_credit_potential(0.1, 0.1)
    expect(limit).toBeCloseTo(7, 4)

  it "shoud return interbank credits", ->
    a = Bank::get_random_bank()
    b = Bank::get_random_bank()
    expect(b.get_interbank_credits()).toBe(0)
    b.give_interbank_credit(a, 100)
    expect(a.interbank).not.toEqual(b.interbank)
    expect(b.get_interbank_credits()).toBe(100)
    expect(a.get_interbank_debt()).toBe(100)


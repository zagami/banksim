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



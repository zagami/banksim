helper = require('./helper.coffee')
randomize = helper.randomize
randomizeInt = helper.randomizeInt
assert = helper.assert

class TrxMgr
  constructor: (@microeconomy) ->
    @banks = @microeconomy.banks
    @cb = @microeconomy.cb
    @params = @microeconomy.params

  one_year: ->
    #payments, economic activity
    @create_transactions()
    #settle customer interests
    # @pay_customer_deposit_interests()
    # @get_customer_credit_interests()

    # settle central bank interests
    # @get_cb_deposit_interests()
    # @pay_cb_credit_interests()

  create_transactions: ->
    # creating a random number of transactions 
    # (upper limit is a parameter max_trx)
    # the amounts transferred are randomly chosen based on customer deposit
    # random transactions represent economic activity
    num_trx = randomizeInt(1,10)
    nonbanks = @microeconomy.nonbanks
    num_nonbanks= nonbanks.length

    if num_nonbanks < 2
      return

    for trx in [1..num_trx]
      nb1_index = randomizeInt(0, num_nonbanks - 1)
      nb2_index = randomizeInt(0, num_nonbanks - 1)
      while nb2_index == nb1_index
        #only transfers to another customer make sense
        nb2_index = randomizeInt(0, num_nonbanks - 1)

      nb1 = nonbanks[nb1_index]
      nb2 = nonbanks[nb2_index]
      amount = randomize(0, nb1.deposit)
      if amount > 0
        @transfer(nb1, nb2, amount)
    return

  #transferring money from one customer to another
  transfer: (from, to, amount) ->
    assert(from.deposit >= amount, 'not enough deposits')
    assert(amount > 0, 'cannot transfer negative amount')
    console.log('transferring' + amount)
    # if from.bank != to.bank
       # TODO

    from.deposit -= amount
    to.deposit += amount
    assert(from.deposit >= 0, 'deposit must not be negative')

  pay_customer_deposit_interests: ->
    di = @params.deposit_interest
    dis = @params.deposit_interest_savings

    for bank in @banks
      for c in bank.customers
        debt_bank_deposit = di * c.deposit
        debt_bank_savings = dis * c.savings
        debt_bank = debt_bank_deposit + debt_bank_savings
        # pay deposit interest to customer
        c.deposit += debt_bank_deposit
      
  get_customer_credit_interests: ->
    cr = @params.credit_interest

    for bank in @banks
      for c in bank.customers
        # get credit interest from customer
        debt_cust = cr * c.loan
        if c.deposit < debt_cust
          #new credits if customer can't pay interest
          # resulting in compund interest
          diff = debt_cust - c.deposit
          c.loan += diff
          c.deposit = 0
          @stats.c_b_flow += debt_cust
        else
          c.deposit -= debt_cust
          c.expenses += debt_cust
          @stats.c_b_flow += debt_cust
        assert(c.deposit >= 0, 'deposits must not be negative')

  get_cb_deposit_interests: ->
    pr_giro = @params.prime_rate_giro

    for bank in @banks
      #interests from cb to bank
      interest = pr_giro * bank.reserves
      bank.reserves += interest

      if @params.positive_money
        for c in bank.customers
          interest = pr_giro * c.deposit
          c.deposit += interest

  pay_cb_credit_interests: ->
    pr = @params.prime_rate
    for bank in @banks
      #interests from bank to cb
      debt = pr*bank.cb_debt
      if debt > bank.reserves
        #cumulative debt, compound interest, negative capital
        diff = debt - bank.reserves
        bank.reserves = 0
        bank.cb_debt += diff
      else
        bank.reserves -= debt

module.exports = TrxMgr

MAX_CUSTOMERS = 40
DFLT_INITIAL_DEPOSIT_PER_CUST = 10

assert = (condition, message) ->
  if (!condition)
    message = message || "Assertion failed"
    if (typeof Error != "undefined")
      e = new Error(message)
      console.log e.stack
      alert message
      throw e
    throw message

randomize = (from, to) ->
  x = to - from
  parseFloat(from + x * Math.random())
  
randomizeInt = (from, to) ->
  x = to - from + 1
  Math.floor(from + x * Math.random())

random_array = (amount, n) ->
  average = amount / n
  rest = amount
  arr = []
  for i in [1..n-1]
    val = randomize(0, 2 * average)
    arr.push val
    rest -= val
  arr.push rest
  arr

if (!Array::sum)
  Array::sum = ->
    i = @length
    s = 0
    s += @[--i] while i > 0
    s

if (!Array::last)
  Array::last = ->
    i = @length
    if i > 0
      return @[i-1]
    else
      null

class Params
  max_trx: 500 # max nr of trx per year
  prime_rate: 0.000  # prime rate paid by banks for central bank credits
  prime_rate_giro: 0.000 # prime rate paid by central bank to banks for deposits
  libor: 0.000 # interbank offered rate
  cap_req: 0.00  #capital requirements (leverage ratio)
  minimal_reserves: 0.00  # reserve requirements for banks
  credit_interest: 0.00
  deposit_interest: 0.00
  deposit_interest_savings: 0.00
  savings_rate: 0.0
  income_tax_rate: 0.0 # percentage of tax from income
  wealth_tax_rate: 0.0 # percentage of tax from wealth
  gov_spending: 1.0 # percentage of expenditure from last years taxes (can be > 100%)
  basic_income_rate: 1.0 # percentage of basic income in relation to government spending 
  positive_money: false # positive money system enabled

class Statistics
  constructor: (@microeconomy) ->
    @banks = @microeconomy.banks
    @cb = @microeconomy.cb
    @m0_series = []
    @m1_series = []
    @m2_series = []
    @m_series = [] #positive money
    @interbank_volume_series = []
    @m0_inflation_series = []
    @m1_inflation_series = []
    @m2_inflation_series = []
    @m_inflation_series = []

    @gdp_series = []

    @cb_b_flow_series = []
    @cb_s_flow_series = []
    @b_cb_flow_series = []
    @b_c_flow_series = []
    @b_s_flow_series = []
    @c_b_flow_series = []
    @c_c_flow_series = []
    @c_s_flow_series = []
    @s_c_flow_series = []
    @s_b_flow_series = []

    @reset_year()

  reset_year: ->
    @cb_b_flow = 0
    @cb_s_flow = 0
    @b_cb_flow = 0
    @b_c_flow = 0
    @b_s_flow = 0
    @c_b_flow = 0
    @c_c_flow = 0
    @c_s_flow = 0
    @s_c_flow = 0
    @s_b_flow = 0
    @gdp = 0

  reset_ms_series: ->
    @m0_series = []
    @m1_series = []
    @m2_series = []
    @m_series = []
    @m0_inflation_series = []
    @m1_inflation_series = []
    @m2_inflation_series = []
    @m_inflation_series = []
    @interbank_volume_series = []

  m0: ->
    @cb.giro_banks() + @cb.giro_state()

  m1: ->
    sum = 0
    sum += bank.customer_deposits() for bank in @banks
    @m0() + sum

  m2: ->
    sum = 0
    sum += bank.customer_savings() for bank in @banks
    @m1() + sum

  m: ->
    result = 0
    if @microeconomy.params.positive_money
      result = @cb.debt_total()
    result

  interbank_volume: ->
    ib = InterbankMarket::get_instance()
    ib.get_interbank_volume()

  one_year: ->
    @m0_series.push @m0()
    @m1_series.push @m1()
    @m2_series.push @m2()
    @m_series.push @m()
    @interbank_volume_series.push @interbank_volume()

    len = @m1_series.length
    if len > 1
      infl_m0 = (@m0_series[len-1] / @m0_series[len-2] - 1)*100
      @m0_inflation_series.push infl_m0
      infl_m1 = (@m1_series[len-1] / @m1_series[len-2] - 1)*100
      @m1_inflation_series.push infl_m1
      infl_m2 = (@m2_series[len-1] / @m2_series[len-2] - 1)*100
      @m2_inflation_series.push infl_m2

    len = @m_series.length
    if len > 1
      infl_m = (@m_series[len-1] / @m_series[len-2] - 1)*100
      @m_inflation_series.push infl_m

    @cb_b_flow_series.push @cb_b_flow
    @cb_s_flow_series.push @cb_s_flow
    @b_cb_flow_series.push @b_cb_flow
    @b_c_flow_series.push @b_c_flow
    @b_s_flow_series.push @b_s_flow
    @c_b_flow_series.push @c_b_flow
    @c_s_flow_series.push @c_s_flow
    @c_c_flow_series.push @c_c_flow
    @s_c_flow_series.push @s_c_flow
    @s_b_flow_series.push @s_b_flow
    
    @gdp_series.push @gdp

    @reset_year()

  wealth_distribution: ->
    result = @microeconomy.all_customers().sort( (a,b) -> a.wealth()-b.wealth())
    result

class CentralBank
  positive_money: false

  constructor: (@state, @banks) ->
    @debt_free_money = 0
    @debt_free_money += (bank.reserves - bank.cb_debt) for bank in @banks
    @debt_free_money += @state.reserves

  credits_banks: ->
    sum = 0
    sum += bank.cb_debt for bank in @banks
    sum

  giro_banks: ->
    giro_banks= 0
    giro_banks += bank.reserves for bank in @banks
    giro_banks

  giro_nonbanks: ->
    giro_nonbanks = 0
    if @positive_money
      giro_nonbanks += bank.customer_deposits() for bank in @banks
    giro_nonbanks

  giro_state: ->
    @state.reserves

  assets_total: ->
    assets = @debt_free_money + @credits_banks()

  debt_total: ->
    debt = @giro_banks() + @giro_state()
    debt += @giro_nonbanks()
    debt

  capital: ->
    @assets_total() - @debt_total()

class InterbankMarket
  @instance: null

  InterbankMarket::get_instance = ->
    if not @instance?
      @instance = new InterbankMarket()
    @instance

  constructor: ->
    @interbank = new Hashtable()

  InterbankMarket::reset = ->
    @instance = null

  increase_interbank_debt: (bank, creditor, amount) ->
    assert(bank != creditor, "banks not different")
    assert(amount > 0, "credit amount must be > 0")
    assert(@interbank != null, "interbank null")

    if not @interbank.containsKey(bank)
      hash = new Hashtable()
      hash.put(creditor, amount)
      @interbank.put(bank, hash)
    else
      if @interbank.get(bank).containsKey(creditor)
        val = @interbank.get(bank).get(creditor)
        @interbank.get(bank).put(creditor, val + amount)
      else
        @interbank.get(bank).put(creditor, amount)

  reduce_interbank_debt: (bank, creditor, amount) ->
    assert(@interbank != null, "interbank null")
    assert(bank != creditor, "banks not different")
    assert(amount > 0, "credit amount must be > 0")
    assert(@get_interbank_debt(bank, creditor) >= amount, 'interbank debt too small')
    val = @interbank.get(bank).get(creditor)
    @interbank.get(bank).put(creditor, val - amount)

  get_all_interbank_loans: (bank) ->
    total = 0
    for key in @interbank.keys()
      if key != bank
        total += @get_interbank_debt(key, bank)
    total

  get_interbank_debt: (bank, creditor) ->
    assert(bank != creditor, "banks not different")
    if @interbank.containsKey(bank)
      if @interbank.get(bank).containsKey(creditor)
        val = @interbank.get(bank).get(creditor)
        return val
    return 0

  get_all_interbank_debts: (bank) ->
    total = 0
    if @interbank.containsKey(bank)
      for v in @interbank.get(bank).values()
        total += v
    total

  get_interbank_volume: ->
    volume = 0
    for b in @interbank.keys()
      for key in @interbank.get(b).keys()
        volume += @interbank.get(b).get(key)
    volume

  settle_interbank_interests: (libor) ->
    assert(@interbank != null, "interbank null")
    #iterate table, multiply credits / debts with libor
    for b in @interbank.keys()
      for key in @interbank.get(b).keys()
        val = @interbank.get(b).get(key)
        @interbank.get(b).put(key, val * (1 + libor))
    return

class Bank
  positive_money: false
  interbank_market: null
  customers: []
  reserves: 0
  cb_debt: 0

  constructor: ->
    @interbank_market = InterbankMarket::get_instance()
    @income = 0
    @expenses = 0
    @hash = randomizeInt(1, 10000000)

  profit: ->
    @income - @expenses

  reset_earnings: ->
    @income = 0
    @expenses = 0

  toString: ->
    "reserves:#{@reserves},cb_debt:#{@cb_debt}, nofC:#{@customers.length}"

  # attention: used by InterbankMarket class
  hashCode: ->
    @hash

  Bank::get_random_bank = ->
    num_customers = randomizeInt(1, MAX_CUSTOMERS)
    bank = new Bank()
    bank.customers = (BankCustomer::get_random_customer(bank) for i in [1..num_customers])
    bank.reserves = bank.customer_deposits()
    bank.cb_debt = 0
    bank

  assets_total: ->
    @reserves + @customer_loans() + @interbank_loans()

  debt_total: ->
    debt = @cb_debt + @interbank_debt() +  @customer_savings()
    debt += @customer_deposits() if not @positive_money
    debt

  capital: ->
    @assets_total() - @debt_total()

  customer_deposits: ->
    sum = 0
    for c in @customers
      sum += c.deposit
    sum

  customer_savings: ->
    sum = 0
    for c in @customers
      sum += c.savings
    sum

  customer_loans: ->
    sum = 0
    for c in @customers
      sum += c.loan
    sum

  interbank_loans: ->
    @interbank_market.get_all_interbank_loans(this)

  interbank_debt: ->
    @interbank_market.get_all_interbank_debts(this)

class BankCustomer
  constructor: (@bank, @deposit, @savings, @loan) ->
    @income = 0
    @expenses = 0

  profit: ->
    @income - @expenses

  wealth: ->
    @deposit + @savings

  reset_earnings: ->
    @income = 0
    @expenses = 0

  assets_total: ->
    @deposit + @savings

  capital: ->
    @assets_total() - @loan

  BankCustomer::get_random_customer = (bank) ->
    deposit = DFLT_INITIAL_DEPOSIT_PER_CUST
    loan = 0
    savings = 0
    new BankCustomer(bank, deposit, savings, loan)

class MicroEconomy
  constructor: (@state, @cb, @banks, @params) ->
    @stats = new Statistics(this)

  all_customers: ->
    all_customers = []
    for bank in @banks
      for c in bank.customers
        all_customers.push c
    all_customers

class State
  constructor: ->
    @reserves = 0

    @public_service_series = []
    @basic_income_series = []
    @income_tax_series = []
    @wealth_tax_series = []
    @last_year_taxes = 0

  capital: ->
    @reserves

class TrxMgr
  constructor: (@microeconomy) ->
    @banks = @microeconomy.banks
    @cb = @microeconomy.cb
    @stats = @microeconomy.stats
    @state = @microeconomy.state
    @interbank_market = InterbankMarket::get_instance()
    @params = @microeconomy.params

  one_year: ->
    @reset_earnings()
    #payments, economic activity
    @create_transactions()
    @provide_public_service()
    #settle customer interests
    @pay_customer_deposit_interests()
    @get_customer_credit_interests()

    #customer credit management
    @manage_customer_credits()
    @manage_investments()
    
    # settle central bank interests
    @get_cb_deposit_interests()
    @pay_cb_credit_interests()

    # settle interbank interests
    @pay_interbank_interests()

    # bank loan management and Basel II requirements
    @manage_bank_debt()
    @pay_dividends()
    @collect_taxes()
    @make_statistics()

  reset_earnings: ->
    for c in @microeconomy.all_customers()
      c.reset_earnings()
    for b in @banks
      b.reset_earnings()

  create_transactions: ->
    # creating a random number of transactions 
    # (upper limit is a parameter max_trx)
    # the amounts transferred are randomly chosen based on customer deposit
    # random transactions represent economic activity
    num_trx = randomizeInt(1,@params.max_trx)
    console.log "performing #{num_trx} transactions"
    all_customers = @microeconomy.all_customers()
    num_customers = all_customers.length
    if num_customers < 2
      return

    for trx in [1..num_trx]
      cust1_index = randomizeInt(0, num_customers - 1)
      cust2_index = randomizeInt(0, num_customers - 1)
      while cust2_index == cust1_index
        #only transfers to another customer make sense
        cust2_index = randomizeInt(0, num_customers - 1)

      cust1 = all_customers[cust1_index]
      cust2 = all_customers[cust2_index]
      amount = randomize(0, cust1.deposit)
      #only positive deposits make sense
      if amount > 0
        @transfer(cust1, cust2, amount)
        #adding transaction to gdp
        @stats.gdp += amount
    return

  interbank_transfer: (from, to, amount) ->
    assert(amount > 0, 'cannot transfer negative amount')
    remainder = amount
    ib_loan = @interbank_market.get_interbank_debt(to, from)
    #if target bank owes money, erase its debt first
    if ib_loan >= amount
      @interbank_market.reduce_interbank_debt(to, from, amount)
      remainder = 0
    else if ib_loan > 0
      @interbank_market.reduce_interbank_debt(to, from, ib_loan)
      remainder = amount - ib_loan

    if remainder > 0
      @interbank_market.increase_interbank_debt(from, to, remainder)

    #if remainder > 0 and from.reserves > 0
    #  if remainder > from.reserves
    #    to.reserves += from.reserves
    #    remainder = remainder - from.reserves
    #    from.reserves = 0
    #  else
    #    from.reserves -= remainder
    #    to.reserves += remainder
    #    remainder = 0
      
  #transferring money from one customer to another
  transfer: (from, to, amount) ->
    assert(from.deposit >= amount, 'not enough deposits')
    assert(amount > 0, 'cannot transfer negative amount')

    if not @params.positive_money
      if from.bank != to.bank
        @interbank_transfer(from.bank, to.bank, amount)

    from.deposit -= amount
    from.expenses += amount
    to.income += amount
    to.deposit += (1-@params.savings_rate)*amount
    to.savings += @params.savings_rate * amount
    @stats.c_c_flow += amount
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
        c.savings += debt_bank_savings

        c.income += debt_bank

        if @params.positive_money
          bank.reserves -= debt_bank

        @stats.b_c_flow += debt_bank
      
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
          c.expenses += debt_cust
          @stats.c_b_flow += debt_cust
        else
          c.deposit -= debt_cust
          c.expenses += debt_cust
          @stats.c_b_flow += debt_cust
        assert(c.deposit >= 0, 'deposits must not be negative')

  get_cb_deposit_interests: ->
    #interests from cb to state
    pr_giro = @params.prime_rate_giro
    interest = pr_giro * @state.reserves
    @state.reserves += interest
    @stats.cb_s_flow += interest

    for bank in @banks
      #interests from cb to bank
      interest = pr_giro * bank.reserves
      bank.reserves += interest
      @stats.cb_b_flow += interest

      if @params.positive_money
        for c in bank.customers
          interest = pr_giro * c.deposit
          c.deposit += interest
    return

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

      @stats.b_cb_flow += debt
    return

  pay_interbank_interests: ->
    @interbank_market.settle_interbank_interests(@params.libor)

  manage_bank_debt: ->
    pr = @params.prime_rate
    prg = @params.prime_rate_giro
    libor = @params.libor

    for bank in @banks
      if bank.reserves > 0 and prg < libor and bank.interbank_debt() > 0
        #paying back interbank debt
        # unless prime rate giro makes it worth keeping the reserves
        max_payback = bank.reserves
        payback = Math.min(bank.interbank_debt(), max_payback)
        payback = randomize(0, payback)
        remainder = payback
        for creditor in @banks
          if remainder > 0 and creditor != bank
            debt = @interbank_market.get_interbank_debt(bank, creditor)
            debt = Math.min(debt, remainder)
            @interbank_transfer(bank, creditor, debt) if debt > 0
            remainder -= debt

      if bank.reserves > 0 and prg < pr and bank.cb_debt > 0
        #paying back cb debt
        max_payback = bank.reserves
        payback = Math.min(bank.cb_debt, max_payback)
        payback = randomize(0, payback)
        bank.cb_debt -= payback
        bank.reserves -= payback

      if prg > pr and bank.capital() > 0
        #get new loan if prime rate giro is good
        max_new_loan = bank.capital()
        new_loan = randomize(0, max_new_loan)
        bank.cb_debt += new_loan
        bank.reserves += new_loan
    return

  manage_customer_credits: ->
    dr = @params.deposit_interest
    cr = @params.credit_interest
    sr = @params.deposit_interest_savings

    for c in @microeconomy.all_customers()
      if sr < cr and c.savings > 0 and c.loan > 0
        # customers paying back credits with savings
        max_payback = c.savings
        payback = Math.min(c.loan, max_payback)
        payback = randomize(0, payback)
        c.loan -= payback
        c.savings -= payback

      if sr > cr or dr > cr and c.capital() > 0
        # get new loan if deposit rates are good
        max_new_loan = c.capital()
        new_loan = randomize(0, max_new_loan)
        c.loan += new_loan
        c.deposit += new_loan
    return

  manage_investments: ->
    #TODO: buy stocks from non-banks

  pay_dividends: ->
    #TODO: pay dividends to bank owners

  collect_taxes: ->
    income_tax_current_year = 0
    wealth_tax_current_year = 0
    tax_payers = @microeconomy.all_customers()
    for c in tax_payers
      income_tax = @params.income_tax_rate * c.income
      wealth_tax = @params.wealth_tax_rate * c.wealth()
      income_tax_current_year += income_tax
      wealth_tax_current_year += wealth_tax

      tax = income_tax + wealth_tax
      if tax > c.deposit
        diff = tax - c.deposit
        #customer takes loan to pay taxes
        c.deposit += diff
        c.loan += diff

      c.deposit -= tax
      @state_transfer(c.bank, tax)
    taxes_total = income_tax_current_year + wealth_tax_current_year
    @state.income_tax_series.push taxes_total
    @state.wealth_tax_series.push taxes_total
    @state.last_year_taxes = taxes_total
    @stats.c_s_flow += income_tax_current_year + wealth_tax_current_year

  state_transfer: (bank, amount) ->
    if bank.reserves > amount
      bank.reserves -= amount
    else
      diff = amount - bank.reserves
      bank.cb_debt += diff
      bank.reserves = 0

    @state.reserves += amount

  provide_public_service: ->
    if @state.income_tax_series.length == 0
      #there is nothing to spend
      return

    gov_spending = @state.last_year_taxes * @params.gov_spending
    if gov_spending > 0
      basic_income_total = gov_spending * @params.basic_income_rate
      @provide_basic_income(basic_income_total)
    else
      @state.basic_income_series.push 0

    @state.public_service_series.push gov_spending

  provide_basic_income: (basic_income_total)->
    tax_payers = @microeconomy.all_customers()
    len = tax_payers.length
    assert(len > 0, 'there are no tax payers')
    basic_income = basic_income_total / len

    for i in [0..len-1]
      tax_payers[i].deposit += basic_income
      tax_payers[i].bank.reserves += basic_income
      tax_payers[i].income += basic_income

    @state.reserves -= basic_income_total

    @stats.s_c_flow += basic_income_total
    @state.basic_income_series.push basic_income_total

  make_statistics: ->
    @stats.one_year()

  enable_positive_money: ->
    @cb.positive_money = true
    @stats.reset_ms_series()
    for bank in @banks
      bank.positive_money = true
      bank.cb_debt += bank.customer_deposits()
      bank.cb_debt += bank.interbank_debt()
    return

  disable_positive_money: ->
    console.log "disable_positive_money"
    @cb.positive_money = false
    @stats.reset_ms_series()
    for bank in @banks
      bank.positive_money = false
      bank.reserves += bank.customer_deposits()
      cb_debt_reduction = Math.min(bank.cb_debt, bank.reserves)
      bank.reserves -= cb_debt_reduction
      bank.cb_debt -= cb_debt_reduction
    return

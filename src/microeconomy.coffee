NUM_BANKS = 20
MAX_CUSTOMERS = 40

DFLT_INITIAL_DEPOSIT_PER_CUST = 10
DFLT_INITIAL_SAVINGS_PER_CUST = 0
DFLT_INITIAL_STOCKS_PER_CUST = 0
DFLT_INITIAL_LOAN_PER_CUST = 10

DFLT_INITIAL_RESERVES_PER_BANK = 20
DFLT_INITIAL_STOCKS_PER_BANK = 20
DFLT_INITIAL_CBDEBT_PER_BANK = 20

DFLT_INITIAL_CB_STOCKS = 400


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
    @[i-1]

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
  positive_money: false # positive money system enabled

class Statistics
  constructor: (@microeconomy) ->
    @banks = @microeconomy.banks
    @cb = @microeconomy.cb
    @m0_series = []
    @m1_series = []
    @m2_series = []
    @interbank_volume_series = []
    @m0_inflation_series = []
    @m1_inflation_series = []
    @m2_inflation_series = []

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

  m0: ->
    @cb.giro_banks()

  m1: ->
    sum = 0
    sum += bank.customer_deposits() for bank in @banks
    @m0() + sum

  m2: ->
    sum = 0
    sum += bank.customer_savings() for bank in @banks
    @m1() + sum

  M: ->
    @cb.debt_total()

  interbank_volume: ->
    ib = InterbankMarket::get_instance()
    ib.get_interbank_volume()

  one_year: ->
    @m0_series.push @m0()
    @m1_series.push @m1()
    @m2_series.push @m2()
    @interbank_volume_series.push @interbank_volume()

    len = @m1_series.length
    if len > 1
      infl_m0 = (@m0_series[len-1] / @m0_series[len-2] - 1)*100
      @m0_inflation_series.push infl_m0
      infl_m1 = (@m1_series[len-1] / @m1_series[len-2] - 1)*100
      @m1_inflation_series.push infl_m1
      infl_m2 = (@m2_series[len-1] / @m2_series[len-2] - 1)*100
      @m2_inflation_series.push infl_m2

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
    @stocks = DFLT_INITIAL_CB_STOCKS
    @kassa = 0

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
    giro_nonbanks += bank.customer_deposits() for bank in @banks
    giro_nonbanks

  assets_total: ->
    @kassa + @credits_banks() + @stocks

  debt_total: ->
    debt = @giro_banks() + @state.reserves
    debt += @giro_nonbanks if @positive_money
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

class Bank
  positive_money: false
  interbank_market: null
  customers: []
  reserves: 0
  stocks: 0
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
    bank.reserves = DFLT_INITIAL_RESERVES_PER_BANK
    bank.stocks = DFLT_INITIAL_STOCKS_PER_BANK
    bank.cb_debt = bank.reserves
    bank

  assets_total: ->
    @reserves + @customer_loans() + @interbank_loans() + @stocks

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
  constructor: (@bank, @deposit, @savings, @stocks, @loan) ->
    @income = 0
    @expenses = 0

  profit: ->
    @income - @expenses

  wealth: ->
    @deposit + @savings + @stocks

  reset_earnings: ->
    @income = 0
    @expenses = 0

  assets_total: ->
    @deposit + @savings + @stocks

  capital: ->
    @assets_total() - @loan

  BankCustomer::get_random_customer = (bank) ->
    deposit = DFLT_INITIAL_DEPOSIT_PER_CUST
    stocks = DFLT_INITIAL_STOCKS_PER_CUST
    loan = DFLT_INITIAL_LOAN_PER_CUST
    savings = DFLT_INITIAL_SAVINGS_PER_CUST
    new BankCustomer(bank, deposit, savings, stocks, loan)

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
    @basic_income_series = []
    @income_tax_series = []
    @reserves = 0

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
    #@provide_public_service()
    @provide_basic_income()
    #settle customer interests
    @pay_customer_deposit_interests()
    @get_customer_credit_interests()

    #customer credit management
    @manage_customer_credits()

    # settle central bank interests
    @get_cb_deposit_interests()
    @pay_cb_credit_interests()

    # settle interbank interests
    @pay_interbank_interests()

    # bank loan management and Basel II requirements
    @manage_bank_debt()
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
        cust2_index = randomizeInt(0, num_customers - 1)
      cust1 = all_customers[cust1_index]
      cust2 = all_customers[cust2_index]

      amount = randomize(0, cust1.deposit)
      @transfer(cust1, cust2, amount)
      #adding transaction to gdp
      @stats.gdp += amount

  interbank_transfer: (from, to, amount) ->
    remainder = amount
    ib_loan = @interbank_market.get_interbank_debt(to, from)
    if ib_loan > amount
      @interbank_market.reduce_interbank_debt(to, from, amount)
      remainder = 0
    else if ib_loan > 0
      @interbank_market.reduce_interbank_debt(to, from, ib_loan)
      remainder = amount - ib_loan

    if remainder > 0 and from.reserves > 0
      if remainder > from.reserves
        to.reserves += from.reserves
        remainder = remainder - from.reserves
        from.reserves = 0
      else
        from.reserves -= remainder
        to.reserves += remainder
        remainder = 0

    if remainder > 0
      libor = @params.libor
      pr = @params.prime_rate
      if pr >= libor
        @interbank_market.increase_interbank_debt(from, to, remainder)
      else
        from.reserves += remainder
        from.cb_debt += remainder

  #transferring money from one customer to another
  transfer: (from, to, amount) ->
    assert(from.deposit >= amount, 'not enough deposits')

    if not @params.positive_money
      if from.bank != to.bank
        @interbank_transfer(from.bank, to.bank, amount)

    from.deposit -= amount
    from.expenses += amount
    to.income += amount
    to.deposit += (1-@params.savings_rate)*amount
    to.savings += @params.savings_rate * amount
    @stats.c_c_flow += amount

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
      
  pay_interbank_interests: ->
    @interbank_market.settle_interbank_interests(@params.libor)

  manage_customer_credits: ->
    dr = @params.deposit_interest
    cr = @params.credit_interest

    #for bank in @banks
    #  for c in bank.customers
        # customers paying back credits
        # TRX: deposits AN credits
        #if dr < cr
        #  max_payback = Math.min(c.loan, c.deposit)
        #  amount = randomize(0, max_payback)
        #  c.loan -= amount
        #  c.deposit -= amount
        
        # customers taking new loans
        # money creation
        # TRX: credits AN deposits
        # upper limit for customer loan: 10 times deposit   
        # max_credit = @compute_max_new_customer_loan(bank)
        # amount = randomize(0, Math.min(max_credit, 10* c.deposit))
        # c.loan += amount
        # c.deposit += amount
        
  collect_taxes: ->
    income_tax_current_year = 0
    tax_payers = @microeconomy.all_customers()
    for c in tax_payers
      tax = @params.income_tax_rate * c.income
      if tax > c.deposit
        diff = tax - c.deposit
        #customer takes loan to pay taxes
        c.deposit += diff
        c.loan += diff

      c.deposit -= tax
      c.bank.reserves -= tax
      income_tax_current_year += tax

    @state.income_tax_series.push income_tax_current_year
    @state.reserves += income_tax_current_year
    @stats.c_s_flow += income_tax_current_year

  provide_basic_income: ->
    tax_payers = @microeconomy.all_customers()
    len = tax_payers.length
    basic_income_total = @state.reserves

    if len == 0
      @state.public_service_series.push 0
      return

    basic_income = basic_income_total / len

    for i in [0..len-1]
      tax_payers[i].deposit += basic_income
      tax_payers[i].bank.reserves += basic_income
      tax_payers[i].income += basic_income

    @stats.s_c_flow += basic_income_total
    @state.reserves -= basic_income_total
    @state.basic_income_series.push basic_income_total

  manage_bank_debt: ->
    cr = @params.cap_req
    pr = @params.prime_rate
    prg = @params.prime_rate_giro

  make_statistics: ->
    @stats.one_year()

  enable_positive_money: ->
    @cb.positive_money = true
    for bank in @banks
      bank.positive_money = true
      bank.cb_debt += bank.customer_deposits()
      bank.cb_debt += bank.interbank_debt()

  disable_positive_money: ->
    console.log "disable"

NUM_BANKS = 10
MAX_CUSTOMERS = 10
DFLT_INITIAL_DEPOSIT_PER_CUST = 10
DFLT_INITIAL_LOAN_PER_CUST = 15
TAX_RATE = 0.1

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

class Statistics
  constructor: (@microeconomy) ->
    @banks = @microeconomy.banks
    @cb = @microeconomy.cb
    @m0_series = []
    @m1_series = []
    @m2_series = []
    @m0_inflation_series = []
    @m1_inflation_series = []
    @m2_inflation_series = []

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

    @reset_money_flow()

  reset_money_flow: ->
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

  m0: ->
    @cb.giro_total()

  m1: ->
    sum = 0
    sum += bank.customer_deposits() for bank in @banks
    sum

  m2: ->
    sum = 0
    sum += bank.customer_savings() for bank in @banks
    @m1() + sum

  one_year: ->
    @m0_series.push @m0()
    @m1_series.push @m1()
    @m2_series.push @m2()

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

    @reset_money_flow()

  wealth_distribution: ->
    girals = (c.giral for c in @microeconomy.all_customers())
    result = girals.sort( (a,b) -> a-b)
    result

class CentralBank
  constructor: (@state, @banks) ->

  credits_total: ->
    sum = 0
    sum += bank.cb_debt for bank in @banks
    sum
    #state cannot take loan directly from cb

  giro_total: ->
    giro_banks= 0
    giro_banks += bank.reserves for bank in @banks
    giro_banks + @state.reserves

  assets_total: ->
    @credits_total()

  liabilities_total: ->
    @giro_total() + @capital()

  capital: ->
    @credits_total() - @giro_total()

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

  give_interbank_loan: (from, to, amount) ->
    assert(from != to, "banks not different")
    assert(amount > 0, "credit amount must be > 0")
    assert(from.reserves >= amount, "not enough reserves for interbank credit")
    assert(not from.gameover, "bankrupt bank cannot give credit")
    assert(not to.gameover, "bankrupt bank cannot get credit")
    assert(@interbank != null, "interbank null")

    from.reserves -= amount
    to.reserves += amount

    if not @interbank.containsKey(from)
      hash = new Hashtable()
      hash.put(to, amount)
      @interbank.put(from, hash)
    else
      if @interbank.get(from).containsKey(to)
        val = @interbank.get(from).get(to)
        @interbank.get(from).put(to, val + amount)
      else
        @interbank.get(from).put(to, amount)

    if not @interbank.containsKey(to)
      hash = new Hashtable()
      hash.put(from, -amount)
      @interbank.put(to, hash)
    else
      if @interbank.get(to).containsKey(from)
        val = @interbank.get(to).get(from)
        @interbank.get(to).put(from, val - amount)
      else
        @interbank.get(to).put(from, -amount)

  get_interbank_loans: (bank) ->
    total = 0
    if @interbank.containsKey(bank)
      for v in @interbank.get(bank).values()
        total += v if v > 0
    total

  get_interbank_debt: (bank) ->
    total = 0
    if @interbank.containsKey(bank)
      for v in @interbank.get(bank).values()
        total += Math.abs(v) if v < 0
    total

  settle_interbank_interests: (libor) ->
    #iterate table, multiply credits / debts with libor
    for b in @interbank.keys()
      for key in @interbank.get(b).keys()
        val = @interbank.get(b).get(key)
        @interbank.get(b).put(key, val * (1 + libor))
        b.capital += val * libor

  set_gameover: (bank) ->
    #interbank write offs can trigger chain reaction of bankcupcy
    #TrxMgr must check if other banks affected
    if @interbank.containsKey(bank)
      for b in @interbank.get(bank).keys()
        if @interbank.containsKey(b)
          bank_loss = @interbank.get(b).get(bank)
          if bank_loss > 0
            console.log "bank just lost #{bank_loss} from a bankcupcy"
            b.capital -= bank_loss
          else if bank_loss < 0
            console.log "bank just gained #{Math.abs(bank_loss)} a from bankrupcy"
            b.capital += Math.abs(bank_loss)
          @interbank.get(b).remove(bank)

      @interbank.get(bank).clear()

class Bank
  gameover: false
  interbank_market: null
  customers: []
  reserves: 0
  cb_debt: 0
  capital: 0

  constructor: ->
    @interbank_market = InterbankMarket::get_instance()

  # attention: don't override, used by Hashtable class
  #toString: ->
  #  "r:#{@reserves},c: #{@credits}, dcb:#{@cb_debt}, g:#{@giral},c:#{@capital}"

  Bank::get_random_bank = ->
    num_customers = randomizeInt(1, MAX_CUSTOMERS)
    bank = new Bank()
    bank.customers = (BankCustomer::get_random_customer(bank) for i in [1..num_customers])
    bank.reserves = 100
    bank.cb_debt = bank.reserves
    bank.capital = bank.assets_total() - bank.debt_total()
    bank

  assets_total: ->
    @reserves + @customer_loans() + @interbank_loans()

  liabilities_total: ->
    @cb_debt + @interbank_debt() + @customer_deposits() + @customer_savings() + @capital

  debt_total: ->
    @cb_debt + @interbank_debt() + @customer_deposits()

  customer_deposits: ->
    sum = 0
    for c in @customers
      sum += c.giral
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
    @interbank_market.get_interbank_loans(this)

  interbank_debt: ->
    @interbank_market.get_interbank_debt(this)

  give_interbank_loan: (to, amount) ->
    @interbank_market.give_interbank_loan(this, to, amount)
  
class BankCustomer
  income: 0
  expenses: 0
  constructor: (@bank, @giral, @savings, @loan) ->

  BankCustomer::get_random_customer = (bank) ->
    giral = DFLT_INITIAL_DEPOSIT_PER_CUST
    loan = DFLT_INITIAL_LOAN_PER_CUST
    savings = 0
    new BankCustomer(bank, giral, savings, loan)

  profit: ->
    @income - @expenses

  assets_total: ->
    @giral + @savings  

class MicroEconomy
  constructor: (@state, @cb, @banks, @params) ->
    @stats = new Statistics(this)

  all_customers: ->
    all_customers = []
    for bank in @banks when not bank.gameover
      for c in bank.customers
        all_customers.push c
    all_customers

class State
  constructor: ->
    @public_service_series = []
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
    #payments, economic activity
    @create_transactions()
    # @provide_public_service()

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
    #@collect_taxes()
    @make_statistics()
    @check_consistency()
    @check_bankrupcy()

  check_consistency: ->
    a = @cb.assets_total()
    l = @cb.liabilities_total()
    assert(Math.round(1000*a) - Math.round(1000*l) == 0, "central bank balance sheet inconsistent: #{a} != #{l} ")
    for bank in @banks when not bank.gameover
      a = bank.assets_total()
      l = bank.liabilities_total()
      assert(Math.round(1000*a) - Math.round(1000*l) == 0, "bank balance sheet inconsistent: #{a} != #{l} ")

  check_bankrupcy: ->
    #rounding errors considered
    if @cb.capital() < -0.01
      alert "central bank capital cannot be negative, #{@cb.capital()}"

    for bank in @banks
      if bank.capital < -0.01 and not bank.gameover
        alert "bank capital cannot be negative #{bank.capital}"

  create_transactions: ->
    # creating a random number of transactions (upper limit is a parameter max_trx)
    # the amounts transferred are randomly chosen based on reserves of bank??
    # random transactions represent economic activity
    max_trx = randomizeInt(1,@params.max_trx)
    console.log "performing #{max_trx} transactions"
    all_customers = @microeconomy.all_customers()
    num_customers = all_customers.length
    if num_customers < 2
      return

    for trx in [1..max_trx]
      cust1_index = randomizeInt(0, num_customers - 1)
      cust2_index = randomizeInt(0, num_customers - 1)
      while cust2_index == cust1_index
        cust2_index = randomizeInt(0, num_customers - 1)
      cust1 = all_customers[cust1_index]
      cust2 = all_customers[cust2_index]

      bank_src = cust1.bank
      bank_tgt = cust2.bank
      amount = Math.min(randomize(0,10), cust1.giral)
      @transfer(cust1, cust2, amount)

  transfer: (from, to, amount) ->
    if from.bank != to.bank and from.bank.reserves < amount
      @get_new_bank_loan(from, amount)

    if from.bank != to.bank
      from.bank.reserves -= amount
      to.bank.reserves += amount

    from.expenses += amount
    to.income += amount
    from.giral -= amount
    to.giral += amount
    @stats.c_c_flow += amount

  pay_customer_deposit_interests: ->
    dr = @params.deposit_interest
    for bank in @banks when not bank.gameover
      for c in bank.customers
        debt_bank = dr * c.giral
        # pay deposit interest to customer
        # TRX: capital AN giral
        c.giral += debt_bank
        c.income += debt_bank
        bank.capital -= debt_bank
        @stats.b_c_flow += debt_bank
      
  get_customer_credit_interests: ->
    cr = @params.credit_interest

    for bank in @banks when not bank.gameover
      for c in bank.customers
        # get credit interest from customer
        # TRX: giral AN capital
        debt_cust = cr * c.loan
        if c.giral < debt_cust
          #new credits if customer can't pay interest
          # resulting in compund interest
          # customer is actually bankrupt now
          diff = debt_cust - c.giral
          c.loan += diff
          bank.capital += debt_cust
          c.giral = 0
          c.expenses += debt_cust
          @stats.c_b_flow += debt_cust
          #
          # alternative: writing off credits
          # bank.capital -= c.loan
          # c.loan = 0
          # seize the remaining money of customer
          # bank.capital += c.giral
          # c.giral = 0
        else
          c.giral -= debt_cust
          c.expenses += debt_cust
          bank.capital += debt_cust
          @stats.c_b_flow += debt_cust

  get_cb_deposit_interests: ->
    pr_giro = @params.prime_rate_giro
    interest = pr_giro * @state.reserves
    @state.reserves += interest
    @stats.cb_s_flow += interest

    for bank in @banks when not bank.gameover
      #interests from cb to bank
      #TRX: reserves an capital
      interest = pr_giro * bank.reserves
      bank.reserves += interest
      bank.capital += interest
      @stats.cb_b_flow += interest

  pay_cb_credit_interests: ->
    pr = @params.prime_rate
    for bank in @banks when not bank.gameover
      #interests from bank to cb
      #TRX: capital an reserves
      debt = pr*bank.cb_debt
      if debt > bank.reserves
        #cumulative debt, compound interest, negative capital
        diff = debt - bank.reserves
        bank.capital -= debt
        bank.reserves = 0
        bank.cb_debt += diff
      else
        bank.reserves -= debt
        bank.capital -= debt

      @stats.b_cb_flow += debt
      
  pay_interbank_interests: ->
    @interbank_market.settle_interbank_interests(@params.libor)

  manage_customer_credits: ->
    dr = @params.deposit_interest
    cr = @params.credit_interest

    #for bank in @banks when not bank.gameover
    #  for c in bank.customers
        # customers paying back credits
        # TRX: giral AN credits
        #if dr < cr
        #  max_payback = Math.min(c.loan, c.giral)
        #  amount = randomize(0, max_payback)
        #  c.loan -= amount
        #  c.giral -= amount
        
        # customers taking new loans
        # money creation
        # TRX: credits AN giral
        # upper limit for customer loan: 10 times deposit   
        # max_credit = @compute_max_new_customer_loan(bank)
        # amount = randomize(0, Math.min(max_credit, 10* c.giral))
        # c.loan += amount
        # c.giral += amount
        
  collect_taxes: ->
    income_tax_current_year = 0
    tax_payers = @microeconomy.all_customers()
    for c in tax_payers
      tax = TAX_RATE * c.profit()
      if tax > c.giral
        c.dead = true
        console.log "taxed to death"
      else
        c.giral -= tax
        c.bank.reserves -= tax
        income_tax_current_year += tax

      @stats.c_s_flow += tax
      c.income = 0
      c.expenses = 0

    @state.income_tax_series.push income_tax_current_year
    @state.reserves += income_tax_current_year

  provide_public_service: ->
    tax_payers = @microeconomy.all_customers()
    len = tax_payers.length
    public_service_cost = @state.reserves
    arr = random_array(public_service_cost, len)

    if len == 0
      @state.public_service_series.push 0
      return

    for i in [0..len-1]
      tax_payers[i].giral += arr[i]
      tax_payers[i].bank.reserves += arr[i]
      tax_payers[i].income += arr[i]

    @stats.s_c_flow += public_service_cost
    @state.reserves -= public_service_cost
    @state.public_service_series.push public_service_cost


  manage_bank_debt: ->
    cr = @params.cap_req
    pr = @params.prime_rate
    prg = @params.prime_rate_giro

    for bank in @banks when not bank.gameover
      if @compute_minimal_reserves(bank) > bank.reserves
        diff = Math.max(0, @compute_minimal_reserves(bank) - bank.reserves)
        potential = @compute_max_new_debt(bank)
        if diff > potential
          @set_gameover(bank, "cannot fulfill minimal reserve requirement")
          continue

        # new cb loan to satisfy minimal reserves requirements
        @get_new_bank_loan(bank, diff)

      if bank.capital / bank.liabilities_total() < cr
        potential = @payback_debt_potential(bank)

        amount = Math.min(potential, bank.cb_debt)
        bank.cb_debt -= amount
        bank.reserves -= amount

      if bank.capital / bank.liabilities_total() < cr
          @set_gameover(bank, "cannot fulfill capital requirements")
          continue

  get_new_bank_loan: (bank, amount) ->
    pr = @params.prime_rate
    libor = @params.libor

    # if interbank interest rate is lower than cb prime rate
    #taking interbank credit
    demand = amount
    if pr > libor
      for b in @banks
        if b != bank and demand > 0
          pot = @compute_max_new_ib_loan(b)
          ib_loan = Math.min(demand, pot)
          if ib_loan > 0
            b.give_interbank_loan(bank, ib_loan)
            demand -= ib_loan

    if demand > 0
      #still more money needed
      bank.reserves += demand
      bank.cb_debt += demand

  #lower limit of reserves that bank must have
  compute_minimal_reserves: (bank) ->
    mr = @params.minimal_reserves
    mr * (bank.customer_deposits() + bank.cb_debt + bank.interbank_debt())

  #max limit for new customer loan
  compute_max_new_customer_loan: (bank) ->
    cr = @params.cap_req
    mr = @params.minimal_reserves

    # compute upper limit regarding capital requirement
    limit_cap = (bank.capital - cr * bank.liabilities_total()) / cr
    limit_cap = Math.max(0, limit_cap)
    #computer upper limit regarding minimal reserves requirement
    limit_mr = (bank.reserves -  @compute_minimal_reserves(bank)) / mr
    limit_mr = Math.max(0, limit_mr)
    #the smaller limit determines the maximal credit potential
    Math.min(limit_cap, limit_mr)

  #max amount of reserves that can be loaned to other banks
  compute_max_new_ib_loan: (bank) ->
    mr = @params.minimal_reserves

    #computer upper limit regarding minimal reserves requirement
    limit_mr = bank.reserves -  @compute_minimal_reserves(bank)
    Math.max(0, limit_mr)

  # max limit for new loan that bank can take
  compute_max_new_debt: (bank) ->
    cr = @params.cap_req

    # compute upper limit regarding capital requirement
    limit_cap = (bank.capital - cr * bank.liabilities_total()) / cr
    Math.max(0, limit_cap)

  #max limit of reserves that can be used to payback bank debt
  payback_debt_potential: (bank) ->
    mr = @params.minimal_reserves

    #computer upper limit regarding minimal reserves requirement
    limit_mr = (bank.reserves -  @compute_minimal_reserves(bank)) / (1 - mr)
    Math.max(0, limit_mr)

  make_statistics: ->
    @stats.one_year()

  set_gameover: (bank, reason) ->
    assert(not bank.gameover, "bank is already gameover")
    bank.gameover = true
    console.log "reason for bankrupcy: #{reason}"
    cb_loss = bank.cb_debt - bank.reserves
    if cb_loss > 0
      console.log "central bank just lost #{cb_loss} from a bankrupcy"
    else if cb_loss < 0
      console.log "central bank just won #{-cb_loss} from a bankrupcy"
      
    @interbank_market.set_gameover(bank)
    bank.customers = []
    bank.reserves = bank.cb_debt = bank.capital = 0



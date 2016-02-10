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

if (!Array::sum)
  Array::sum = ->
    i = @length
    s = 0
    s += @[--i] while i > 0
    s

class Params
  max_trx: 50 # max nr of trx per year
  prime_rate: 0.004  # prime rate paid by banks for central bank credits
  prime_rate_giro: 0.003 # prime rate paid by central bank to banks for deposits
  libor: 0.002 # interbank offered rate
  cap_req: 0.08  #capital requirements (leverage ratio)
  minimal_reserves: 0.05  # reserve requirements for banks
  credit_interest: 0.03
  deposit_interest: 0.02

class Statistics
  m0: []
  m1: []
  inflation_m0: []
  inflation_m1: []

class CentralBank
  constructor: (@banks) ->
    @stats = new Statistics()

  credits_total: ->
    sum = 0
    sum += bank.debt_cb for bank in @banks
    sum

  giro_total: ->
    giro = 0
    giro += bank.reserves for bank in @banks
    giro

  assets_total: ->
    @credits_total()

  liabilities_total: ->
    @giro_total() + @capital()

  capital: ->
    @credits_total() - @giro_total()

  M0: ->
    @giro_total()

  M1: ->
    sum = 0
    sum += bank.giral for bank in @banks
    sum

  M2: ->
    0

# Helper class to manage interbank market.
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

  give_interbank_credit: (from, to, amount) ->
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

  get_interbank_credits: (bank) ->
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

  constructor: (@reserves, @credits, @debt_cb, @giral, @capital) ->
    @interbank_market = InterbankMarket::get_instance()

  # attention: don't override, used by Hashtable class
  #toString: ->
  #  "r:#{@reserves},c: #{@credits}, dcb:#{@debt_cb}, g:#{@giral},c:#{@capital}"

  Bank::get_random_bank = ->
    r = randomize(0, 100)
    c = randomize(r, 300)
    debt_cb = 1.1 * r # allow cb some initial capital
    giral = randomize(r, c)
    capital = r + c - giral - debt_cb
    new Bank(r, c, debt_cb, giral, capital)

  assets_total: ->
    @reserves + @credits + @get_interbank_credits()

  liabilities_total: ->
    @debt_cb + @get_interbank_debt() + @giral + @capital

  debt_total: ->
    @debt_cb + @get_interbank_debt() + @giral

  get_interbank_credits: ->
    @interbank_market.get_interbank_credits(this)

  get_interbank_debt: ->
    @interbank_market.get_interbank_debt(this)

  give_interbank_credit: (to, amount) ->
    @interbank_market.give_interbank_credit(this, to, amount)
  

class MicroEconomy
  constructor: (@cb, @banks, @params) ->

class TrxMgr
  constructor: (@microeconomy) ->
    @banks = @microeconomy.banks
    @cb = @microeconomy.cb
    @interbank_market = InterbankMarket::get_instance()
    @params = @microeconomy.params

  one_year: ->
    #payments, economic activity
    @create_transactions()

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
    @manage_bank_loans()

    @make_statistics()
    @check_consistency()
    @check_bankrupcy()

  check_consistency: ->
    a = @cb.assets_total()
    l = @cb.liabilities_total()
    assert(Math.round(1000*a) - Math.round(1000*l) == 0, "central bank balance sheet inconsistent: #{a} != #{l} ")
    for bank in @banks
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
    for trx in [1..max_trx]
      bank_src_index = randomizeInt(0, @banks.length - 1)
      bank_tgt_index = randomizeInt(0, @banks.length - 1)
      bank_src = @banks[bank_src_index]
      bank_tgt = @banks[bank_tgt_index]
      # console.log "transferring #{amount} from #{bank_src} to #{bank_tgt}"
      if bank_src_index != bank_tgt_index and not (bank_src.gameover or bank_tgt.gameover)
        amount = randomize(0, bank_src.giral)
        @transfer(bank_src, bank_tgt, amount)

  transfer: (from, to, amount) ->
    if from.reserves < amount
      if to.reserves > amount and @params.prime_rate > @params.libor
        # if interbank interest rate is lower than cb prime rate
        #taking interbank credit, full amount of transfer
        to.give_interbank_credit(from, amount)
      else
        # take a credit from centralbank
        from.debt_cb += amount
        from.reserves += amount

    #GIRAL an reserves
    from.reserves -= amount
    from.giral -= amount
    #reserves an GIRAL
    to.reserves += amount
    to.giral += amount
    
  pay_customer_deposit_interests: ->
    dr = @params.deposit_interest
    for bank in @banks when not bank.gameover
      debt_bank = dr * bank.giral
      # pay deposit interest to customer
      # TRX: capital AN giral
      bank.giral += debt_bank
      bank.capital -= debt_bank
      
  get_customer_credit_interests: ->
    cr = @params.credit_interest

    for bank in @banks when not bank.gameover
      # get credit interest from customer
      # TRX: giral AN capital
      debt_cust = cr * bank.credits
      if bank.giral < debt_cust
        #new credits if customer can't pay interest
        # resulting in compund interest
        # customer is actually bankrupt now
        diff = debt_cust - bank.giral
        bank.credits += diff
        bank.capital += debt_cust
        bank.giral = 0
        #
        # alternative: writing off credits
        # bank.capital -= bank.credits
        # bank.credits = 0
        # seize the remaining money of customer
        # bank.capital += bank.giral
        # bank.giral = 0
      else
        bank.giral -= debt_cust
        bank.capital += debt_cust

  get_cb_deposit_interests: ->
    pr_giro = @params.prime_rate_giro
    for bank in @banks when not bank.gameover
      #interests from cb to bank
      #TRX: reserves an capital
      interest = pr_giro * bank.reserves
      bank.reserves += interest
      bank.capital += interest

  pay_cb_credit_interests: ->
    pr = @params.prime_rate
    for bank in @banks when not bank.gameover
      #interests from bank to cb
      #TRX: capital an reserves
      debt = pr*bank.debt_cb
      if debt > bank.reserves
        #cumulative debt, compound interest, negative capital
        diff = debt - bank.reserves
        bank.capital -= debt
        bank.reserves = 0
        bank.debt_cb += diff
      else
        bank.reserves -= debt
        bank.capital -= debt

  pay_interbank_interests: ->
    @interbank_market.settle_interbank_interests(@params.libor)

  manage_customer_credits: ->
    dr = @params.deposit_interest
    cr = @params.credit_interest

    for bank in @banks when not bank.gameover
      # customers paying back credits
      # TRX: giral AN credits
      if dr < cr
        max_payback = Math.min(bank.credits, bank.giral)
        amount = randomize(0, max_payback)
        bank.credits -= amount
        bank.giral -= amount
      
      # customers taking new loans
      # money creation
      # TRX: credits AN giral
         
      max_credit = @customer_credit_potential(bank)
      amount = randomize(0, max_credit)
      bank.credits += amount
      bank.giral += amount

  customer_credit_potential: (bank) ->
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

  compute_minimal_reserves: (bank) ->
    mr = @params.minimal_reserves
    mr * (bank.giral + bank.debt_cb + bank.get_interbank_debt())

  manage_bank_loans: ->
    cr = @params.cap_req
    pr = @params.prime_rate
    prg = @params.prime_rate_giro

    for bank in @banks when not bank.gameover
      if @compute_minimal_reserves(bank) > bank.reserves
        diff = Math.max(0, @compute_minimal_reserves(bank) - bank.reserves)
        potential = @new_loan_potential(bank)
        if diff > potential
          @set_gameover(bank)
          continue
        
        bank.reserves += diff
        bank.debt_cb += diff

      if bank.capital / bank.liabilities_total() < cr
        potential = @payback_loan_potential(bank)

        amount = Math.min(potential, bank.debt_cb)
        bank.debt_cb -= amount
        bank.reserves -= amount

      if bank.capital / bank.liabilities_total() < cr
          @set_gameover(bank)
          continue
        
  new_loan_potential: (bank) ->
    cr = @params.cap_req

    # compute upper limit regarding capital requirement
    limit_cap = (bank.capital - cr * bank.liabilities_total()) / cr
    Math.max(0, limit_cap)

  payback_loan_potential: (bank) ->
    mr = @params.minimal_reserves

    #computer upper limit regarding minimal reserves requirement
    limit_mr = (bank.reserves -  @compute_minimal_reserves(bank)) / (1 - mr)
    Math.max(0, limit_mr)

  make_statistics: ->
    @cb.stats.m0.push @cb.M0()
    @cb.stats.m1.push @cb.M1()
    len = @cb.stats.m1.length
    if len > 1
      infl_m0 = (@cb.stats.m0[len-1] / @cb.stats.m0[len-2] - 1)*100
      @cb.stats.inflation_m0.push infl_m0
      infl_m1 = (@cb.stats.m1[len-1] / @cb.stats.m1[len-2] - 1)*100
      @cb.stats.inflation_m1.push infl_m1

  set_gameover: (bank) ->
    assert(not bank.gameover, "bank is already gameover")
    bank.gameover = true
    cb_loss = bank.debt_cb - bank.reserves
    if cb_loss > 0
      console.log "central bank just lost #{cb_loss} from a bankrupcy"
    else if cb_loss < 0
      console.log "central bank just won #{-cb_loss} from a bankrupcy"
      
    @interbank_market.set_gameover(bank)
    bank.reserves = bank.credits = bank.debt_cb = bank.giral = bank.capital = 0


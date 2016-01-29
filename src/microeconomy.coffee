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
  prime_rate: 0.02  # prime rate paid by banks for central bank credits
  prime_rate_giro: 0.01 # prime rate paid by central bank to banks for deposits
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

  set_gameover: (bank) ->
    if @interbank.containsKey(bank)
      for b in @interbank.get(bank).keys()
        if @interbank.containsKey(b)
          @interbank.get(b).put(bank, 0)
        @interbank.get(bank).clear()

class Bank
  gameover: false
  interbank_market: null

  constructor: (@reserves, @credits, @debt_cb, @giral, @capital) ->
    @interbank_market = InterbankMarket::get_instance()

  #toString: ->
  #  "r:#{@reserves},c: #{@credits}, dcb:#{@debt_cb}, g:#{@giral},c:#{@capital}"

  Bank::get_random_bank = ->
    r = randomize(0, 100)
    c = randomize(r, 300)
    debt_cb = r
    giral = randomize(r, c)
    capital = r + c - giral - debt_cb
    new Bank(r, c, debt_cb, giral, capital)

  assets_total: ->
    @reserves + @credits + @get_interbank_credits()

  liabilities_total: ->
    @debt_cb + @get_interbank_debt() + @giral + @capital

  get_interbank_credits: ->
    @interbank_market.get_interbank_credits(this)

  get_interbank_debt: ->
    @interbank_market.get_interbank_debt(this)

  give_interbank_credit: (to, amount) ->
    @interbank_market.give_interbank_credit(this, to, amount)
  
  set_gameover: ->
    @gameover = true
    console.log "central bank just lost #{@debt_cb - @reserves}"
    @reserves = @credits = @debt_cb = @giral = @capital = 0
    @interbank_market.set_gameover(this)

  compute_credit_potential: (cap_req, min_res) ->
    # compute upper limit regarding capital requirement
    limit_cap = (@capital - cap_req * @liabilities_total()) / cap_req
    limit_cap = Math.max(0, limit_cap)
    #computer upper limit regarding minimal reserves requirement
    limit_mr = (@reserves - min_res * @giral) / min_res
    limit_mr = Math.max(0, limit_mr)
    #the smaller limit determines the maximal credit potential
    Math.min(limit_cap, limit_mr)

class MicroEconomy
  constructor: (@cb, @banks, @params) ->

class TrxMgr
  constructor: (@microeconomy) ->
    @banks = @microeconomy.banks
    @cb = @microeconomy.cb
    @interbank_market = InterbankMarket::get_instance()
    @params = @microeconomy.params

  one_year: ->
    @create_transactions()
    @pay_customer_deposit_interests()
    @get_customer_credit_interests()
    @get_cb_deposit_interests()
    @pay_cb_credit_interests()
    @pay_interbank_interests()
    @repay_cb_credits()
    @new_cb_credits()
    @repay_customer_credits()
    @new_customer_credits()
    @settle_reserves()
    @settle_capital_requirement()
    @make_statistics()
    @check_consistency()

  check_consistency: ->
    @check_balance(@cb)
    console.log "central bank ok"
    for b in @banks
      @check_balance(b)

  check_balance: (bank) ->
    assets = bank.assets_total()
    liabilities = bank.liabilities_total()
    assert(Math.round(1000*assets) - Math.round(1000*liabilities) == 0, "balance sheet inconsistent: #{assets} != #{liabilities}  #{bank.toString()} ")

  create_transactions: ->
    # creating a random number of transactions (upper limit is a parameter max_trx)
    # the amounts transferred are randomly chosen based on reserves of bank??
    # random transactions represent economic activity
    max_trx = randomizeInt(1,@params.max_trx)
    console.log "performing #{max_trx} transactions"
    for trx in [1..max_trx]
      bank_src = randomizeInt(0, @banks.length - 1)
      bank_tgt = randomizeInt(0, @banks.length - 1)
      # console.log "transferring #{amount} from #{bank_src} to #{bank_tgt}"
      if bank_src != bank_tgt and not (bank_src.gameover or bank_tgt.gameover)
        bank_src = @banks[bank_src]
        bank_tgt = @banks[bank_tgt]
        amount = randomize(0, bank_src.giral)
        @transfer(bank_src, bank_tgt, amount)

  transfer: (from, to, amount) ->

    if from.reserves < amount
      console.log "not enough funds: #{from.reserves} < #{amount}"
      if to.reserves > amount
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
    dr = @params.deposit_interest / 100.0
    for bank in @banks
      debt_bank = dr * bank.giral
      # pay deposit interest to customer
      # TRX: capital AN giral
      bank.giral += debt_bank
      bank.capital -= debt_bank
      
  get_customer_credit_interests: ->
    cr = @params.credit_interest / 100.0
    for bank in @banks
      # get credit interest from customer
      # TRX: giral AN capital
      debt_cust = cr * bank.credits
      if bank.giral < debt_cust
        #TODO:new credits if customer can't pay interest??
        # compund interest
        #bank.credits += diff
        #bank.capital += diff
        #
        # customer is actually bankrupt now
        # writing off credits
        bank.capital -= bank.credits
        bank.credits = 0
        # seize the remaining money of customer
        bank.capital += bank.giral
        bank.giral = 0
      else
        bank.giral -= debt_cust
        bank.capital += debt_cust

  get_cb_deposit_interests: ->
    pr_giro = @params.prime_rate_giro / 100.0
    for bank in @banks
      #interests from cb to bank
      #TRX: reserves an capital
      interest = pr_giro * bank.reserves
      bank.reserves += interest
      bank.capital += interest

  pay_cb_credit_interests: ->
    pr = @params.prime_rate
    for bank in @banks
      #interests from bank to cb
      #TRX: capital an reserves
      debt = pr*bank.debt_cb
      if debt > bank.reserves or debt > bank.capital
        console.log "debt: #{debt}, reserves: #{bank.reserves}, capital: #{bank.capital}"
        console.log "bankrupt because of debt to central bank"
        bank.set_gameover()
      else
        bank.reserves -= debt
        bank.capital -= debt

  pay_interbank_interests: ->

  repay_cb_credits: ->
    pr = @params.prime_rate
    prg = @params.prime_rate_giro
    minimal_reserves = @params.minimal_reserves
    for bank in @banks
      if (pr*bank.debt_cb > prg.reserves)
        reserve_surplus = Math.max(bank.giral*minimal_reserves - bank.reserves, 0)
        payback = Math.min(bank.debt_cb, reserve_surplus)
        #TRX: debt_cb an reserves
        bank.debt_cb -= payback
        bank.reserves -= payback

  new_cb_credits: ->
    pr = @params.prime_rate
    prg = @params.prime_rate_giro
    cr = @params.credit_interest
    dr = @params.deposit_interest
    cap_req = @params.cap_req

    for bank in @banks
      if (pr*bank.debt_cb < prg.reserves)
        potential  = cap_req * bank.liabilities_total() - bank.capital
        #central bank must have enough capital to grant new credit
        c = Math.min(potential, @cb.capital())
        #TRX: reserves an debt_cb
        bank.debt_cb += c
        bank.reserves += c

  repay_customer_credits: ->
    for bank in @banks
      # customers paying back credits
      # TRX: giral AN credits
      amount = randomizeInt(0, Math.min(bank.credits, bank.giral))
      bank.credits -= amount
      bank.giral -= amount

  new_customer_credits: ->
    for bank in @banks
      # customers taking new loans
      # money creation
      # TRX: credits AN giral
      cr = @params.cap_req / 100.0
      mr = @params.minimal_reserves / 100.0
      amount = randomizeInt(0, bank.compute_credit_potential(cr, mr))
      bank.credits += amount
      bank.giral += amount

  settle_reserves: ->
    minimal_reserves = @params.minimal_reserves / 100.0
    for bank in @banks
      if bank.reserves < bank.giral * minimal_reserves
        #bank has not enough reserves and needs a credit from central bank
        diff = bank.giral * minimal_reserves - bank.reserves
        #TRX: reserves an debt_cb
        bank.debt_cb += diff
        bank.reserves += diff

  settle_capital_requirement: ->
    cap_req = @params.cap_req / 100.0
    for bank in @banks
      total = bank.liabilities_total()
      if bank.capital < total * cap_req
        #try to pay back central bank credit
        # only necessary in case of deficient capital reqs
        payback = Math.min(bank.debt_cb, bank.reserves)
        #TRX: KREDIT_cb an reserves
        bank.debt_cb -= payback
        bank.reserves -= payback
        total = bank.liabilities_total()
        if bank.capital < total * cap_req
          console.log "bankrupt because of capital requirements"
          bank.set_gameover()

  make_statistics: ->
    @cb.stats.m0.push @cb.M0()
    @cb.stats.m1.push @cb.M1()
    len = @cb.stats.m1.length
    if len > 1
      infl_m0 = (@cb.stats.m0[len-1] / @cb.stats.m0[len-2] - 1)*100
      @cb.stats.inflation_m0.push infl_m0
      infl_m1 = (@cb.stats.m1[len-1] / @cb.stats.m1[len-2] - 1)*100
      @cb.stats.inflation_m1.push infl_m1

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

class Statistics
  m0: []
  m1: []
  inflation: []

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

class Bank
  gameover: false
  constructor: (@reserves, @credits, @debt_cb, @giral, @capital) ->
  Bank::get_random_bank = ->
    r = randomize(0, 100)
    c = randomize(r, 300)
    debt_cb = r
    giral = randomize(r, c)
    capital = r + c - giral - debt_cb
    new Bank(r, c, debt_cb, giral, capital)

  assets_total: ->
    @reserves + @credits

  liabilities_total: ->
    @debt_cb + @giral + @capital

  deposit: (amount) ->
    #reserves an GIRAL
    @reserves += amount
    @giral += amount

  withdraw: (amount) ->
    #GIRAL an reserves
    @reserves -= amount
    @giral -= amount

  gameover: ->
    @gameover = true
    @reserves = @credits = @debt_cb = @giral = @capital = 0

class MicroEconomy
  constructor: (@cb, @banks) ->

class TrxMgr
  constructor: (@params, @microeconomy) ->
    @banks = @microeconomy.banks
    @cb = @microeconomy.cb

  transfer: (from, to, amount) ->
    if from.reserves > amount
      from.withdraw(amount)
      to.deposit(amount)
    else
      # TODO: take loan from bank (interbank)
      console.log "not enough funds"
      # take a credit from centralbank
      diff = amount - from.reserves
      from.debt_cb += diff
      from.reserves += diff
      # trying again...
      @transfer(from, to, amount)

  one_year: ->
    @create_transactions()
    @customer_credits()
    @pay_customer_interests()
    @pay_cb_interests()
    @settle_reserves()
    @settle_capital_requirement()
    @cb.stats.m0.push @cb.M0()
    @cb.stats.m1.push @cb.M1()

  create_transactions: ->
    # creating a random number of transactions (upper limit is a parameter max_trx)
    # the amounts transferred are randomly chosen based on reserves of bank??
    # random transactions represent economic activity
    max_trx = randomizeInt(1,parseInt(@params.max_trx()))
    for trx in [1..max_trx]
      bank_src = randomizeInt(0, @banks.length - 1)
      bank_tgt = randomizeInt(0, @banks.length - 1)
      bank_src = @banks[bank_src]
      bank_tgt = @banks[bank_tgt]
      #TODO: Amount upper limit?
      amount = randomize(0, bank_src.giral)
      if bank_src != bank_tgt and not (bank_src.gameover or bank_tgt.gameover) 
        @transfer(bank_src, bank_tgt, amount)

  pay_customer_interests: ->
    cr = parseFloat(@params.credit_interest())/100.0
    dr = parseFloat(@params.deposit_interest())/100.0
    for bank in @banks
      debt_cust = cr * bank.giral
      debt_bank = dr * bank.giral
      # get credit interest from customer
      # TRX: giral AN capital
      if bank.giral < debt_cust 
        #TODO: new credits if customer can't pay interest??
        # compund interest
        # customer is actually bankrupt now
        diff = debt_cust - bank.giral 
        bank.credits += diff
        bank.capital += diff 
      else
        bank.giral -= debt_cust
        bank.capital += debt_cust

      # pay deposit interest to customer
      # TRX: capital AN giral
      bank.giral += debt_bank
      bank.capital -= debt_bank

  customer_credits: ->
    for bank in @banks
      # customers paying back credits
      # TRX: giral AN credits
      amount = randomizeInt(0, Math.min(bank.credits, bank.giral))
      bank.credits -= amount
      bank.giral -= amount

      # customers taking new loans
      # money creation
      # TRX: credits AN giral
      # TODO: new loans dependent on existing loans?
      
      amount = randomizeInt(0, bank.credits)
      bank.credits += amount
      bank.giral += amount

  pay_cb_interests: ->
    pr = parseFloat(@params.prime_rate()) / 100.0
    pr_giro = parseFloat(@params.prime_rate_giro()) / 100.0
    for bank in @banks
      #interests from cb to bank
      #TRX: reserves an capital
      interest = pr_giro*bank.reserves
      bank.reserves += interest
      bank.capital += interest
      #interests from bank to cb
      #TRX: capital an reserves
      debt = pr*bank.debt_cb
      if debt > bank.reserves or debt > bank.capital
        console.log "debt: #{debt}, reserves: #{bank.reserves}, capital: #{bank.capital}"
        bank.gameover()
      else
        bank.reserves -= debt
        bank.capital -= debt

  settle_reserves: ->
    minimal_reserves = parseFloat(@params.minimal_reserves()) / 100.0
    for bank in @banks
      if bank.reserves < bank.giral * minimal_reserves
        diff = bank.giral * minimal_reserves - bank.reserves
        #TRX: reserves an KREDIT_CB
        bank.debt_cb += diff
        bank.reserves += diff

  settle_capital_requirement: ->
    cap_req = parseFloat(@params.cap_req()) / 100.0
    for bank in @banks
      total = bank.capital + bank.giral + bank.debt_cb
      if bank.capital < total * cap_req
        #try to pay back central bank credit
        # only necessary in case of deficient capital reqs
        payback = Math.min(bank.debt_cb, bank.reserves)
        #TRX: KREDIT_cb an reserves
        bank.debt_cb -= payback
        bank.reserves -= payback
        total = bank.capital + bank.giral + bank.debt_cb
        if bank.capital < total * cap_req
          bank.gameover()


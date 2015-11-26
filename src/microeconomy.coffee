randomize = (from, to) ->
  x = to - from
  parseFloat(from + x * Math.random())
  
randomizeInt = (from, to) ->
  x = to - from + 1
  Math.floor(from + x * Math.random()) 

class CentralBank
  constructor: (@banks) ->
  credits_total: ->
    sum = 0
    sum += bank.credit_cb for bank in @banks
    sum
  giro_total: ->
    giro = 0
    giro += bank.reserves for bank in @banks
    giro
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
  constructor: (@reserves, @credits, @credit_cb, @giral, @capital) -> 
  Bank::get_random_bank= ->
      r = randomize(0, 100)
      c = randomize(0, 100)
      credit_cb = r 
      giral = randomize(r, r + c - credit_cb)
      capital = r + c - giral - credit_cb
      new Bank(r, c, credit_cb, giral, capital)
  deposit: (amount) ->
    #reserves an GIRAL
    @reserves += amount
    @giral += amount
  withdraw: (amount) ->
    #GIRAL an reserves
    @reserves -= amount
    @giral -= amount
  gameover: ->
    console.log "gameover"
    @gameover = true
    @reserves = @credits = @credit_cb = @giral = @capital = 0
    
class TrxMgr
  constructor: (@params, @simulator) ->
  transfer: (from, to, amount) ->
    if from.reserves > amount
      from.withdraw(amount)
      to.deposit(amount)
    else
      # TODO: take loan from bank (interbank)
      console.log "not enough funds"
  create_transactions: ->
    banks = @simulator.banks
    max_trx = randomizeInt(1,parseInt(@params.max_trx()))
    console.log "creating #{max_trx} transactions"
    for trx in [1..max_trx]
      bank_src = randomizeInt(0, banks.length - 1)
      bank_tgt = randomizeInt(0, banks.length - 1)
      bank_src = banks[bank_src]
      bank_tgt = banks[bank_tgt]
      #TODO: Amount upper limit?
      amount = randomize(0, bank_src.giral)
      if bank_src != bank_tgt and not (bank_src.gameover or bank_tgt.gameover) 
        @transfer(bank_src, bank_tgt, amount)
  pay_cb_interests: ->
    banks = @simulator.banks
    cb = @simulator.cb
    pr = parseFloat(@params.prime_rate()) / 100.0
    pr_giro = parseFloat(@params.prime_rate_giro()) / 100.0
    for bank in banks
      #interests from cb to bank
      #reserves an capital
      interest = pr_giro*bank.reserves
      bank.reserves += interest
      bank.capital += interest
      #interests from bank to cb
      #capital an reserves
      debt = pr*bank.credit_cb
      if debt > bank.reserves or debt > bank.capital
        bank.gameover()
      else
        bank.reserves -= debt
        bank.capital -= debt
  settle_reserves: ->
    minimal_reserves = parseFloat(@params.minimal_reserves()) / 100.0
    banks = @simulator.banks
    for bank in banks
      if bank.reserves < bank.giral * minimal_reserves
        diff = bank.giral * minimal_reserves - bank.reserves
        #reserves an KREDIT_CB
        @credit_cb += diff
        bank.reserves += diff
  settle_capital_requirement: ->
    cap_req = parseFloat(@params.cap_req()) / 100.0
    banks = @simulator.banks
    for bank in banks
      total = bank.capital + bank.giral + bank.credit_cb
      if bank.capital < total * cap_req
        #try to pay back central bank credit
        payback = Math.min(bank.credit_cb, bank.reserves)
        #KREDIT_cb an reserves
        bank.credit_cb -= payback
        bank.reserves -= payback
        total = bank.capital + bank.giral + bank.credit_cb
        if bank.capital < total * cap_req
          bank.gameover()



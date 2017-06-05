class CentralBank
  constructor: (@banks) ->
    @debt_free_money = 0
    @debt_free_money += (bank.reserves - bank.cb_debt) for bank in @banks

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

  assets_total: ->
    assets = @debt_free_money + @credits_banks()

  debt_total: ->
    debt = @giro_banks()
    debt += @giro_nonbanks()
    debt

  capital: ->
    @assets_total() - @debt_total()

module.exports = CentralBank

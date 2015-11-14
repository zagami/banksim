LANG = 'DE'
translate = (engl_word) ->
  if LANG == 'EN'
    engl_word
  else if LANG == 'DE'
    for e, d of DICT
      if engl_word == e
        return d
    console.log "TODO: translate - #{e}"

DICT =
  "table": "Tabelle"
  "diagram": "Diagramm" 
  "interest": "Zins"
  "reserves": "Reserven"
  "banks": "Banken"
  "central bank": "Zentralbank"
  "capital": "Eigenkapital"
  "assets": "Aktiven"
  "liabilities": "Passiven"
  "balance sheet": "Bilanz"
  "prime rate": "Leitzins"
  "stocks": "Wertschriften"
  "statistics": "Statistiken"
  "money supply": "Geldmenge"
  "credits": "Kredite"
  "credits to banks": "Kredite an Banken"
  "debt to central bank": "Schulden an ZB"
  "bank deposits": "Giralgeld" 

AUTORUN_DELAY = 2000
DFLT_VIZ = [translate("table")]


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
  get_random_bank: ->
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
      #reserves an capital
      interest = pr_giro*bank.reserves
      bank.reserves += interest
      bank.capital += interest
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

class Simulator
  constructor: (@params) ->
    @trx_mgr = new TrxMgr(@params, this)
    @visualizer = new Visualizer(this)
    @setVisualizer(DFLT_VIZ)
  banks: []
  cb: null
  trx_mgr: null
  visualizer: null
  simulate: (years) ->
    console.log("simulating..." + years + " years")
    @simulate_one_year() for [1..years]
    @visualizer.visualize()
  simulate_one_year: ->
    @trx_mgr.create_transactions()
    @trx_mgr.pay_cb_interests()
    @trx_mgr.settle_reserves()
    @trx_mgr.settle_capital_requirement()
    # @trx_mgr.create_credits()
  reset: ->
    @init()
  init: ->
    @banks = (Bank::get_random_bank() for i in [1..10])
    @cb = new CentralBank(@banks)
  visualize: ->
    @visualizer.visualize()

  setVisualizer: (viz) ->
    @visualizer.clear()
    vizArray = []
    if @params.tableViz_checked() 
      vizArray.push( new TableVisualizer(this) ) 
    if @params.diagramViz_checked()
      vizArray.push( new GraphVisualizer(this) )
    @visualizer.vizArray = vizArray

class Visualizer
  vizArray: []
  constructor: (@simulator) ->
  visualize: ->
    for viz in @vizArray
      viz.visualize()
  clear: ->
    for viz in @vizArray
      viz.clear()
  
class TableVisualizer extends Visualizer
  clear: ->
    super
    $('#cb_table').empty()
    $('#banks_table').empty()

  create_row: (entries...) ->
    tr = '<tr>'
    tr += '<td>' + entry + '</td>' for entry in entries
    tr +='</tr>'

  create_cb_table: (cb) ->
    # balance sheet of central bank
    $('#cb_table').append( '<table>' )   
    row_h = @create_row(translate('assets'), '', translate('liabilities'), '')
    row_1 = @create_row('Forderungen an Banken', cb.credits_total().toFixed(2), 'ZB Giralgeld', cb.giro_total().toFixed(2) )    
    row_2 = @create_row(translate('stocks'), '0', translate('capital'), cb.capital().toFixed(2)) 
    $('#cb_table').append(row_h).append(row_1).append(row_2)
    $('#cb_table').append(  '</table>' )

    # money supply
    $('#cb_table').append('<h3>'+translate('statistics') + '</h3>')
    $('#cb_table').append(  '<table>' )
    row_h = @create_row(translate('money supply'), 'M0', 'M1', 'M2')
    row = @create_row('', cb.M0(), cb.M1(), cb.M2())
    $('#cb_table').append(  '<table>' ).append(row_h).append(row)
    $('#cb_table').append('</table>' )

  create_bank_header: ->
    th = '<th>'
    th += '<td>' + translate("reserves")  + '</td>'
    th += '<td>' + translate('credits')  + '</td>'
    th += '<td>' + translate('debt to central bank')  + '</td>'
    th += '<td>' + translate('bank deposits')  + '</td>'
    th += '<td>' + translate("capital")  + '</td>'
    th += '</th>'
    th

  create_bank_row: (bank) ->
    tr = '<tr>'
    tr += '<td></td>'
    tr += '<td>' + bank.reserves.toFixed(2)  + '</td>'
    tr += '<td>' + bank.credits.toFixed(2)  + '</td>'
    tr += '<td>' + bank.credit_cb.toFixed(2)  + '</td>'
    tr += '<td>' + bank.giral.toFixed(2)  + '</td>'
    tr += '<td>' + bank.capital.toFixed(2)  + '</td>'
    tr +='</tr>'
    tr

  visualize: ->
    banks = @simulator.banks
    console.log "creating table for #{banks.length} banks"
    @clear()
    @create_cb_table(@simulator.cb)
    $('#banks_table').append(  '<table>' );
    $('#banks_table').append(@create_bank_header())
    for bank in banks
      $('#banks_table').append(@create_bank_row(bank))      
    $('#banks_table').append(  '</table>' )

class GraphVisualizer extends Visualizer
  clear: ->
    $('#banks_graph').empty()
    $('#cb_graph').empty()
  draw_cb: (cb) ->
    $('#cb_graph').highcharts({
      chart:
        type: 'column'
      title:
        text: translate("central bank")
      xAxis:
        categories: []
      yAxis:
        allowDecimals: false
        min: 0
        title:
          text: 'CHF'
      tooltip:
          formatter: ->
              return '<b>' + this.x + '</b><br/>' +
                  this.series.name + ': ' + this.y + '<br/>' +
                  'Total: ' + this.point.stackTotal
      plotOptions:
        column:
          stacking: 'normal'
      series: [{
          name: translate('credits to banks')
          data: [cb.credits_total()]
          stack: translate('assets')
      }, {
          name: translate('stocks')
          data: [0]
          stack: translate('assets')
      }, {
          name: 'M0'
          data: [cb.giro_total()]
          stack: translate('liabilities')
      }, {
          name: translate("capital")
          data: [cb.capital()]
          stack: translate('liabilities')
      }]
    })
  drawgraph: (banks) ->
    reserves = (bank.reserves for bank in banks)
    credits = (bank.credits for bank in banks)
    caps = (bank.capital for bank in banks)
    cbcredits = (bank.credit_cb for bank in banks)
    girals = (bank.giral for bank in banks)
    $('#banks_graph').highcharts({
      chart:
        type: 'column'
      title:
        text: translate('banks')
      xAxis:
        categories: []
      yAxis:
        allowDecimals: false
        min: 0
        title:
          text: 'CHF'
      tooltip:
          formatter: ->
              return '<b>' + this.x + '</b><br/>' +
                  this.series.name + ': ' + this.y + '<br/>' +
                  'Total: ' + this.point.stackTotal
      plotOptions:
        column:
          stacking: 'normal'
      series: [{
          name: translate("reserves")
          data: reserves
          stack: translate('assets')
      }, {
          name: translate('credits')
          data: credits
          stack: translate('assets')
      }, {
          name: translate('debt to central bank')
          data: cbcredits
          stack: translate('liabilities')
      }, {
          name: translate('bank deposits') 
          data: girals
          stack: translate('liabilities')
      }, {
          name: translate("capital")
          data: caps
          stack: translate('liabilities')
      }]
    })
  visualize: ->
    console.log("drawing graph... #{@simulator.banks.length}")
    @clear()
    @draw_cb(@simulator.cb)
    @drawgraph(@simulator.banks)

iv = (val) ->
  ko.observable(val)

params =
  step: iv(0)
  yearsPerStep: iv(1)
  autorun: iv("off")
  autorun_id: 0
  max_trx: iv(5)
  prime_rate: iv(3)
  prime_rate_giro: iv(1)
  cap_req: iv(8)  #capital requirements in percent
  minimal_reserves: iv(5)
  tableViz_checked: iv(true)
  diagramViz_checked: iv(true)
  vizClicked: ->
    console.log "vizClicked"
    _simulator.setVisualizer()
    _simulator.visualize()
    return true # needed by knockout
  lang_de_clicked: ->
    LANG = 'DE'
    _simulator.visualize()
  lang_en_clicked: ->
    LANG = 'EN'
    _simulator.visualize()
  simulateClicked: ->
    yps = parseInt(@yearsPerStep())
    curr_s = parseInt(@step())
    @step(yps + curr_s)
    _simulator.simulate(yps)
  autorunClicked: ->
    if @autorun() is "off"
      @autorun('on')
      @autorun_id = setInterval("params.simulateClicked()", AUTORUN_DELAY) 
    else
      clearInterval(@autorun_id)
      @autorun("off")
  reset: ->
    @step(0)
    _simulator.reset()

_simulator = null

$ ->
  _simulator = new Simulator(params)
  _simulator.init()
  _simulator.simulate()

  #Knockout.JS specific code
  viewModel = params
  ko.applyBindings(viewModel)



#Backlog
# - GUI controls 
# - Tilgung der Kredite?
# - Kreditausfall? (Sicherheit pfänden?)
# - Interbankenmarkt
# - individuelle Bankkunden
# - Repo Geschäfte mit SNB

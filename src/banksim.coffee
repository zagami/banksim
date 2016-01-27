LANG = 'EN'
NUM_BANKS = 30
CHART_WIDTH = 400
INFLATION_HIST = 20 #data points of inflation graph
AUTORUN_DELAY = 2000

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
  "total": "Total"

class Simulator
  init: ->
    banks = (Bank::get_random_bank() for i in [1..NUM_BANKS])
    cb = new CentralBank(banks)
    @microeconomy = new MicroEconomy(cb, banks)
    @trx_mgr = new TrxMgr(@params, @microeconomy)

  constructor: (@params) ->
    @init()
    @params.set_simulator(this)
    
  simulate: (years) ->
    @simulate_one_year() for [1..years]

  simulate_one_year: ->
    @trx_mgr.one_year()
    
  reset: ->
    @init()

class VisualizerMgr
  vizArray: []
  visualize: ->
    for viz in @vizArray
      viz.visualize()
  clear: ->
    for viz in @vizArray
      viz.clear()
  addViz: (viz) ->
    @vizArray.push(viz)
  reset: ->
    @clear()
    @vizArray = []

class Visualizer
  constructor: (microeconomy) ->
    @microeconomy = microeconomy
    @banks = microeconomy.banks
    @cb = microeconomy.cb
  clear: ->
  visualize: ->

class TableVisualizer extends Visualizer
  constructor: (@microeconomy) ->
    super
  clear: ->
    super
    $('#cb_table').empty()
    $('#ms_table').empty()
    $('#banks_table').empty()

  create_row: (entries...) ->
    tr = '<tr>'
    tr += '<td>' + entry + '</td>' for entry in entries
    tr +='</tr>'

  create_header: (entries...) ->
    tr = '<tr>'
    tr += '<th>' + entry + '</th>' for entry in entries
    tr +='</tr>'

  create_cb_table: (cb) ->
    # balance sheet of central bank
    $('#cb_table').append( '<table>' )
    $('#cb_table').append( '<caption>' + translate('central bank') + '</caption>' )

    row_h = @create_header(
      translate('assets'),
      '',
      translate('liabilities'),
      ''
    )

    row_1 = @create_row(
      'Forderungen an Banken',
      cb.credits_total().toFixed(2),
      'ZB Giralgeld',
      cb.giro_total().toFixed(2)
    )

    row_2 = @create_row(
      translate('stocks'),
      '0',
      translate('capital'),
      cb.capital().toFixed(2)
    )

    row_3 = @create_row(
      translate('total'),
      cb.assets_total().toFixed(2),
      '',
      cb.liabilities_total().toFixed(2)
    )
    
    $('#cb_table').append(row_h).append(row_1).append(row_2).append(row_3)
    $('#cb_table').append('</table>')

  create_ms_table: (cb) ->
    # money supply
    $('#ms_table').append('<table>')
    $('#ms_table').append( '<caption>' + translate('money supply') + '</caption>' )
    row_h = @create_header(
      'M0',
      'M1',
      'M2'
    )
    row = @create_row(
      cb.M0().toFixed(2),
      cb.M1().toFixed(2),
      cb.M2().toFixed(2)
    )
    $('#ms_table').append(row_h).append(row)
    $('#ms_table').append('</table>' )

  create_bank_header: ->
    @create_header(
      '',
      translate("reserves"),
      translate('credits'),
      translate('debt to central bank'),
      translate('bank deposits'),
      translate("capital"),
      translate("assets"),
      translate("liabilities")
    )

  create_bank_row: (id, bank) ->
    @create_row(
      id,
      bank.reserves.toFixed(2),
      bank.credits.toFixed(2),
      bank.debt_cb.toFixed(2),
      bank.giral.toFixed(2),
      bank.capital.toFixed(2),
      bank.assets_total().toFixed(2),
      bank.liabilities_total().toFixed(2)
    )

  create_banks_table: (banks) ->
    $('#banks_table').append( '<table>' )
    $('#banks_table').append( '<caption>' + translate('banks') + '</caption>' )
    $('#banks_table').append(@create_bank_header())
    i = 0
    for bank in @banks
      $('#banks_table').append(@create_bank_row(i, bank))
      i += 1
    $('#banks_table').append(  '</table>' )

  visualize: ->
    @clear()
    @create_cb_table(@cb)
    @create_ms_table(@cb)
    @create_banks_table(@banks)

class GraphVisualizer extends Visualizer
  constructor: (@microeconomy) ->
    super

  clear: ->
    $('#banks_graph').empty()
    $('#banks_total_graph').empty()
    $('#cb_graph').empty()
    $('#stats_graph').empty()

  draw_stats: ->
    $('#stats_graph1').highcharts({
      chart:
        width: CHART_WIDTH
      title:
        text: translate("money supply")
      xAxis:
        categories: []
      yAxis:
        allowDecimals: false
        title:
          text: 'CHF'
      tooltip:
          formatter: ->
              return '<b>' + this.x + '</b><br/>' +
                  this.series.name + ': ' + this.y + '<br/>' 
      plotOptions:
        column:
          stacking: 'normal'
        series:
          animation: false
      series: [{
          name: translate('money supply M0')
          data: @cb.stats.m0
      }, {
          name: translate('money supply M1')
          data: @cb.stats.m1
      }]
    })
    
    $('#stats_graph2').highcharts({
      chart:
        width: CHART_WIDTH
      title:
        text: translate("inflation")
      xAxis:
        categories: []
      yAxis:
        allowDecimals: false
        title:
          text: '%'
      tooltip:
          formatter: ->
              return '<b>' + this.x + '</b><br/>' +
                  this.series.name + ': ' + this.y + '<br/>' 
      plotOptions:
        column:
          stacking: 'normal'
        series:
          animation: false
      series: [{
          name: translate('inflation M0')
          data: @cb.stats.inflation_m0[-INFLATION_HIST..]
      }, {
          name: translate('inflation M1')
          data: @cb.stats.inflation_m1[-INFLATION_HIST..]
      }]
    })


  draw_cb: ->
    $('#cb_graph').highcharts({
      chart:
        type: 'column'
        width: CHART_WIDTH
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
        series:
          animation: false
      series: [{
          name: translate('credits to banks')
          data: [@cb.credits_total()]
          stack: translate('assets')
      }, {
          name: translate('stocks')
          data: [0]
          stack: translate('assets')
      }, {
          name: 'M0'
          data: [@cb.giro_total()]
          stack: translate('liabilities')
      }, {
          name: translate("capital")
          data: [@cb.capital()]
          stack: translate('liabilities')
      }]
    })

  draw_banks: ->
    reserves = (bank.reserves for bank in @banks)
    credits = (bank.credits for bank in @banks)
    caps = (bank.capital for bank in @banks)
    cbcredits = (bank.debt_cb for bank in @banks)
    girals = (bank.giral for bank in @banks)
    interbank_credits = (bank.get_interbank_credits() for bank in @banks)
    interbank_debts = (bank.get_interbank_debt() for bank in @banks)

    $('#banks_graph').highcharts({
      chart:
        type: 'column'
        width: CHART_WIDTH
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
        series:
          animation: false
      series: [{
          name: translate("reserves")
          data: reserves
          stack: translate('assets')
      }, {
          name: translate('interbank credits')
          data: interbank_credits
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
          name: translate('interbank debt')
          data: interbank_debts
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

    $('#banks_graph2').highcharts({
      chart:
        type: 'column'
        width: CHART_WIDTH
      title:
        text: translate("central bank deposits")
      xAxis:
        categories: []
      yAxis:
        allowDecimals: false
        title:
          text: '%'
      tooltip:
          formatter: ->
              return '<b>' + this.x + '</b><br/>' +
                  this.series.name + ': ' + this.y + '<br/>' 
      plotOptions:
        column:
          stacking: 'normal'
        series:
          animation: false
      series: [{
          name: translate('central bank deposits')
          data: reserves
          stack: '1'
      }, {
          name: translate('central bank debt')
          data: cbcredits
          stack: '2'
      }, {
          name: translate('interbank debt')
          data: interbank_debts
          stack: '3'
      }]
    })

    $('#banks_total_graph').highcharts({
      chart:
        type: 'column'
        width: CHART_WIDTH
      title:
        text: translate('banks consolidated')
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
        series:
          animation: false
      series: [{
          name: translate("reserves")
          data: [ reserves.sum() ]
          stack: translate('assets')
      }, {
          name: translate('credits')
          data: [ credits.sum() ]
          stack: translate('assets')
      }, {
          name: translate('debt to central bank')
          data: [ cbcredits.sum() ]
          stack: translate('liabilities')
      }, {
          name: translate('bank deposits')
          data: [ girals.sum() ]
          stack: translate('liabilities')
      }, {
          name: translate("capital")
          data: [ caps.sum() ]
          stack: translate('liabilities')
      }]
    })

  visualize: ->
    @clear()
    @draw_cb()
    @draw_stats()
    @draw_banks()

iv = (val) ->
  ko.observable(val)
  
class Params
  # Simulator Control
  step: iv(0)
  yearsPerStep: iv(1)
  autorun: iv(false)
  autorun_id: 0
  tableViz_checked: iv(true)
  diagramViz_checked: iv(true)

  # Microeconomy
  max_trx: iv(50)  # max nr of trx per year
  prime_rate: iv(2)  # prime rate paid by banks for central bank credits
  prime_rate_giro: iv(1) # prime rate paid by central bank to banks for deposits
  cap_req: iv(8)  #capital requirements in percent (leverage ratio)
  minimal_reserves: iv(5)  # reserve requirements for banks
  credit_interest: iv(3)
  deposit_interest: iv(2)
  
  # functions
  set_simulator: (sim) ->
    @simulator = sim
    @visualizerMgr = new VisualizerMgr()
    @set_viz()

  reset_params: ->
    @step(0)

  set_viz: ->
    @visualizerMgr.reset()
    if @tableViz_checked()
      @visualizerMgr.addViz ( new TableVisualizer(@simulator.microeconomy) )
    if @diagramViz_checked()
      @visualizerMgr.addViz( new GraphVisualizer(@simulator.microeconomy) )
  
  # Event Handlers
  viz_clicked: ->
    @set_viz()
    @visualizerMgr.visualize()
    return true # needed by knockout

  lang_de_clicked: ->
    LANG = 'DE'
    @visualizerMgr.visualize()

  lang_en_clicked: ->
    LANG = 'EN'
    @visualizerMgr.visualize()
    
  simulate_clicked: ->
    yps = parseInt(@yearsPerStep())
    curr_s = parseInt(@step())
    @step(yps + curr_s)
    @simulator.simulate(yps)
    @visualizerMgr.visualize()

  autorun_clicked: ->
    if not @autorun() 
      @autorun(true)
      @autorun_id = setInterval("params.simulate_clicked()", AUTORUN_DELAY)
    else
      clearInterval(@autorun_id)
      @autorun(false)
    return true # needed by knockout

  reset_clicked: ->
    @reset_params()
    @simulator.reset()
    @set_viz()
    #visualize again after resetting
    @visualizerMgr.visualize()

#global objects
simulator = null
params = null

$ ->
  params = new Params()
  simulator = new Simulator(params)
  # show 1st simulation step after page load
  params.visualizerMgr.visualize()

  #Knockout.JS specific code
  viewModel = params
  ko.applyBindings(viewModel)


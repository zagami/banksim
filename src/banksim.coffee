LANG = 'EN'
NUM_BANKS = 20
CHART_WIDTH = 300
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


iv = (val) ->
  ko.observable(val)

class Simulator
  init: ->
    banks = (Bank::get_random_bank() for i in [1..NUM_BANKS])
    cb = new CentralBank(banks)
    @params = new Params()
    @microeconomy = new MicroEconomy(cb, banks, @params)
    @trx_mgr = new TrxMgr(@microeconomy)
    @visualizerMgr = new VisualizerMgr()
    @visualizerMgr.addViz ( new TableVisualizer(@microeconomy) )
    @visualizerMgr.addViz( new GraphVisualizer(@microeconomy) )
    @init_params()

  constructor: ->
    @init()
    
  simulate: (years) ->
    @simulate_one_year() for [1..years]

  simulate_one_year: ->
    @trx_mgr.one_year()
    
  reset: ->
    InterbankMarket::reset()
    @init()

  # Simulator Control
  step: iv(0)
  yearsPerStep: iv(1)
  autorun: iv(false)
  autorun_id: 0

  init_params: ->
    @gui_params = ko.mapping.fromJS(@params)

    @prime_rate = ko.computed({
      read: =>
        (@gui_params.prime_rate() * 100).toFixed(1)
      write: (value) =>
        newval = parseFloat(value)/100
        @gui_params.prime_rate(newval)
        @params.prime_rate = newval
    }, this)

    @prime_rate_giro = ko.computed({
      read: =>
        ( @gui_params.prime_rate_giro() * 100 ).toFixed(1)
      write: (value) =>
        newval = parseFloat(value)/100
        @gui_params.prime_rate_giro(newval)
        @params.prime_rate_giro = newval
    }, this)

    @libor = ko.computed({
      read: =>
        ( @gui_params.libor() * 100 ).toFixed(1)
      write: (value) =>
        newval = parseFloat(value)/100
        @gui_params.libor(newval)
        @params.libor = newval
    }, this)

    @cap_req = ko.computed({
      read: =>
        ( @gui_params.cap_req() * 100 ).toFixed(1)
      write: (value) =>
        newval = parseFloat(value)/100
        @gui_params.cap_req(newval)
        @params.cap_req = newval
    }, this)

    @minimal_reserves = ko.computed({
      read: =>
        ( @gui_params.minimal_reserves() * 100 ).toFixed(1)
      write: (value) =>
        newval = parseFloat(value)/100
        @gui_params.minimal_reserves(newval)
        @params.minimal_reserves = newval
    }, this)

    @credit_interest = ko.computed({
      read: =>
        ( @gui_params.credit_interest() * 100 ).toFixed(1)
      write: (value) =>
        newval = parseFloat(value)/100
        @gui_params.credit_interest(newval)
        @params.credit_interest = newval
    }, this)

    @deposit_interest = ko.computed({
      read: =>
        ( @gui_params.deposit_interest() * 100 ).toFixed(1)
      write: (value) =>
        newval = parseFloat(value)/100
        @gui_params.deposit_interest(newval)
        @params.deposit_interest = newval
    }, this)

  # functions
  reset_params: ->
    @step(0)

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
    @simulate(yps)
    @visualizerMgr.visualize()

  autorun_clicked: ->
    if not @autorun()
      @autorun(true)
      @autorun_id = setInterval("simulator.simulate_clicked()", AUTORUN_DELAY)
    else
      clearInterval(@autorun_id)
      @autorun(false)
    return true # needed by knockout

  reset_clicked: ->
    @reset_params()
    @reset()
    #visualize again after resetting
    #@visualizerMgr.clear()
    @visualizerMgr.visualize()

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
      translate('interbank credits')
      translate('credits'),
      translate('debt to central bank'),
      translate('interbank debt')
      translate('bank deposits'),
      translate("capital"),
      translate("assets"),
      translate("liabilities")
    )

  create_bank_row: (id, bank) ->
    @create_row(
      id,
      bank.reserves.toFixed(2),
      bank.get_interbank_credits().toFixed(2),
      bank.credits.toFixed(2),
      bank.debt_cb.toFixed(2),
      bank.get_interbank_debt().toFixed(2),
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
      row = $(@create_bank_row(i, bank))
      row.addClass('bankrupt') if bank.gameover
      $('#banks_table').append(row)
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
          name: translate('interbank credits')
          data: [ interbank_credits.sum() ]
          stack: translate('assets')
      }, {
          name: translate('debt to central bank')
          data: [ cbcredits.sum() ]
          stack: translate('liabilities')
      }, {
          name: translate('interbank debt')
          data: [ interbank_debts.sum() ]
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

#global objects
simulator = null

$ ->
  simulator = new Simulator()
  # show 1st simulation step after page load
  simulator.visualizerMgr.visualize()

  #Knockout.JS specific code
  viewModel = simulator
  ko.applyBindings(viewModel)


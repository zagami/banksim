LANG = 'EN'
CHART_WIDTH = 300
INFLATION_HIST = 20 #data points of inflation graph
AUTORUN_DELAY = 2000
COL1 = "red"
COL2 = "blue"
COL3 = "green"
COL4 = "yellow"

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
    state = new State()
    cb = new CentralBank(state, banks)
    @params = new Params()
    @microeconomy = new MicroEconomy(state, cb, banks, @params)
    @trx_mgr = new TrxMgr(@microeconomy)
    @visualizerMgr = new VisualizerMgr()

    vizArray = [
      new CentralBankTable(@microeconomy, '#cb_table', 'central bank'),
      new StateTable(@microeconomy, '#state_table', 'state'),
      new MoneySupplyTable(@microeconomy, '#ms_table', 'money supply'),
      new BanksTable(@microeconomy, '#banks_table', 'banks'),
      new BanksChart(@microeconomy, '#banks_chart', 'all banks'),
      new BanksTotalChart(@microeconomy, '#banks_total_chart', 'banks consolidated'),
      new BanksDebtChart(@microeconomy, '#banks_chart2', 'central bank deposits'),
      new CustomerTotalChart(@microeconomy, '#customers_total_chart', 'customers consolidated'),
      new CentralBankChart(@microeconomy, '#cb_chart', 'central bank'),
      new MoneySupplyChart(@microeconomy, '#stats_chart1', 'money supply'),
      new InflationChart(@microeconomy, '#stats_chart2', 'inflation'),
      new WealthDistributionChart(@microeconomy, '#wealth_chart', 'wealth distribution'),
      new InterestGraph(@microeconomy, '#interest_graph', 'flow of interest'),
      #new CustomerGraph(@microeconomy, '#customer_graph', 'Customers')
    ]
    for v in vizArray
      @visualizerMgr.addViz v
     
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
  constructor: (@microeconomy, @element_id) ->
    @banks = @microeconomy.banks
    @cb = @microeconomy.cb
    @stats = @microeconomy.stats
    @state = @microeconomy.state

  clear: ->
  visualize: ->

class GraphVisualizer extends Visualizer
  network: null
  constructor: (@microeconomy, @element_id, @title) ->
    super
    @drawGraph()

  drawGraph: ->
    @nodesArray = []
    @edgesArray = []
    @initGraph()
    assert(@nodesArray.length > 0, 'Nodes not initializes')
    assert(@edgesArray.length > 0, 'Edges not initializes')
    @edges = new vis.DataSet(@edgesArray)
    @nodes = new vis.DataSet(@nodesArray)

    data = {
      nodes: @nodes,
      edges: @edges
    }

    container = document.getElementById(@element_id.replace('#', ''))
    options = {
      nodes: { font: { size: 12 }, borderWidth: 2, shadow:true },
      edges: { width: 2, shadow:true }
      interaction: {
        zoomView: false
      }
      #scaling:
      #  customScalingFunction: (min,max,total,value) ->
      #    return min + value/total*max
      #  min:5
      #  max:150
    }
    @network = new vis.Network(container, data, options)
    @network.stabilize()

  clear: ->
    super
    $(@element_id).empty()

  addNode: (id, label, val = 1) ->
    @nodesArray.push {id: id, value: val, label: label}

  addEdgeSimple: (src, tgt) ->
    @edgesArray.push {id: src + "_" + tgt, from: src, to: tgt, font: {align: 'bottom'}}

  addEdge: (src, tgt, label) ->
    @edgesArray.push {id: src + "_" + tgt, from: src, to: tgt, label: label, arrows:'to', font: {align: 'bottom'}}

  updateNode: (id, label, val) ->
    assert(@nodes?, 'nodes not initialized')
    nodes.update({ id: id, label: label, value: val })

  updateEdge: (src, tgt, label) ->
    assert(@edges?, 'edges not initialized')
    v = 0
    v = label.toFixed(0) if label?

    @edges.update({
      id: src + "_" + tgt,
      from: src,
      to: tgt,
      label: v
      })

  #override this method
  initGraph: ->
  #override this method
  updateGraph: ->

  visualize: ->
    @updateGraph()

class CustomerGraph extends GraphVisualizer
  initGraph: ->
    cb_label = "Central Bank"
    cb = 0
    @addNode(cb, cb_label)
    c_index = 0
    for i in [1..@banks.length]
      @addNode(i, "Bank #{i}")
      @addEdgeSimple(cb, i)
      for c in @banks[i-1].customers
        @addNode('c'+ c_index, c_index)
        c_index += 1

  updateGraph: ->
    #@drawGraph()

class InterestGraph extends GraphVisualizer
  initGraph: ->
    cb_label = "Central Bank"
    b_label = "Banks"
    c_label = "Customers"
    s_label = "State"
    cb = 1
    b = 2
    s = 3
    c = 4

    @addNode(cb, cb_label)
    @addNode(b, b_label)
    @addNode(s, s_label)
    @addNode(c, c_label)

    @addEdge(cb, b, 0)
    @addEdge(b, cb, 0)
    @addEdge(b, c, 0)
    @addEdge(c, b, 0)
    @addEdge(cb, s, 0)

  updateGraph: ->
    cb = 1
    b = 2
    s = 3
    c = 4

    @updateEdge(cb, b, @stats.cb_b_flow_series.last())
    @updateEdge(b, cb, @stats.b_cb_flow_series.last())
    @updateEdge(b, c, @stats.b_c_flow_series.last())
    @updateEdge(c, b, @stats.c_b_flow_series.last())
    @updateEdge(cb, s, @stats.cb_s_flow_series.last())

class TableVisualizer extends Visualizer
  constructor: (@microeconomy, @element_id, @title) ->
    super

  clear: ->
    super
    $(@element_id).empty()

  create_row: (entries...) ->
    tr = '<tr>'
    tr += '<td>' + entry + '</td>' for entry in entries
    tr +='</tr>'
    tr = $(tr)
    $(@element_id).append(tr)
    tr

  create_header: (entries...) ->
    tr = '<tr>'
    tr += '<th>' + entry + '</th>' for entry in entries
    tr +='</tr>'
    $(@element_id).append(tr)

  draw_table: ->
    $(@element_id).append( '<table>' )
    $(@element_id).append( '<caption>' + translate(@title) + '</caption>' )
    @create_table()
    $(@element_id).append('</table>')

  visualize: ->
    @clear()
    @draw_table()

class CentralBankTable extends TableVisualizer
  create_table: ->
    # balance sheet of central bank
    @create_header(
      translate('assets'),
      '',
      translate('liabilities'),
      ''
    )
    @create_row(
      'Forderungen an Banken',
      @cb.credits_total().toFixed(2),
      'ZB Giralgeld',
      @cb.giro_total().toFixed(2)
    )

    @create_row(
      translate('stocks'),
      '0',
      translate('capital'),
      @cb.capital().toFixed(2)
    )

    @create_row(
      translate('total'),
      @cb.assets_total().toFixed(2),
      '',
      @cb.liabilities_total().toFixed(2)
    )

class StateTable extends TableVisualizer
  create_table: ->
    len = @state.income_tax_series.length
    if len > 0
      @create_row('taxes current year', @state.income_tax_series[len-1].toFixed(2))
      @create_row('expenses current year', @state.public_service_series[len-1].toFixed(2))
      @create_row('state reserves', @state.reserves.toFixed(2))

  create_ms_table: ->
    # money supply
    $('#ms_table').append('<table>')
    $('#ms_table').append( '<caption>' + translate('money supply') + '</caption>' )
    row_h = @create_header(
      'M0',
      'M1',
      'M2'
    )
    row = @create_row(
      @stats.m0().toFixed(2),
      @stats.m1().toFixed(2),
      @stats.m2().toFixed(2),
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
      translate("liabilities"),
      translate('number of clients')
    )

  create_bank_row: (id, bank) ->
    @create_row(
      id,
      bank.reserves.toFixed(2),
      bank.interbank_loans().toFixed(2),
      bank.customer_loans().toFixed(2),
      bank.cb_debt.toFixed(2),
      bank.interbank_debt().toFixed(2),
      bank.customer_deposits().toFixed(2),
      bank.capital.toFixed(2),
      bank.assets_total().toFixed(2),
      bank.liabilities_total().toFixed(2),
      bank.customers.length
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

class MoneySupplyTable extends TableVisualizer
  create_table: ->
    # money supply
    @create_header(
      'M0',
      'M1',
      'M2'
    )
    @create_row(
      @stats.m0().toFixed(2),
      @stats.m1().toFixed(2),
      @stats.m2().toFixed(2),
    )

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
      translate("liabilities"),
      translate('number of clients')
    )

  create_bank_row: (id, bank) ->
    @create_row(
      id,
      bank.reserves.toFixed(2),
      bank.interbank_loans().toFixed(2),
      bank.customer_loans().toFixed(2),
      bank.cb_debt.toFixed(2),
      bank.interbank_debt().toFixed(2),
      bank.customer_deposits().toFixed(2),
      bank.capital.toFixed(2),
      bank.assets_total().toFixed(2),
      bank.liabilities_total().toFixed(2),
      bank.customers.length
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

class BanksTable extends TableVisualizer
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
      translate("liabilities"),
      translate('number of clients')
    )

  create_bank_row: (id, bank) ->
    row = @create_row(
      id,
      bank.reserves.toFixed(2),
      bank.interbank_loans().toFixed(2),
      bank.customer_loans().toFixed(2),
      bank.cb_debt.toFixed(2),
      bank.interbank_debt().toFixed(2),
      bank.customer_deposits().toFixed(2),
      bank.capital.toFixed(2),
      bank.assets_total().toFixed(2),
      bank.liabilities_total().toFixed(2),
      bank.customers.length
    )
    row.addClass('bankrupt') if bank.gameover

  create_table: ->
    @create_bank_header()
    i = 0
    for bank in @banks
      @create_bank_row(i, bank)
      i += 1

class ChartVisualizer extends Visualizer
  constructor: (@microeconomy, @element_id, @title) ->
    super
    @data = []
    @set_options()

  set_options: ->
    @y_label = 'CHF'
    @chart_type = 'column'
    @y_max = null

  draw_chart: ->
    $(@element_id).highcharts({
      chart:
        type: @chart_type
        width: CHART_WIDTH
      title:
        text: translate(@title)
      xAxis:
        categories: []
      yAxis:
        allowDecimals: false
        max: @y_max
        title:
          text: @y_label
      tooltip:
          formatter: ->
              return '<b>' + this.x + '</b><br/>' +
                  this.series.name + ': ' + this.y + '<br/>' 
      plotOptions:
        column:
          stacking: 'normal'
        series:
          animation: false
      series: @data
    })

  update_data: ->

  visualize: ->
    @clear()
    @update_data()
    @draw_chart()

class MoneySupplyChart extends ChartVisualizer
  set_options: ->
    @chart_type = 'line'

  update_data: ->
    @data = [{
        name: translate('money supply M0')
        data: @stats.m0_series
      }, {
        name: translate('money supply M1')
        data: @stats.m1_series
      }, {
        name: translate('money supply M2')
        data: @stats.m2_series
    }]
    
class InflationChart extends ChartVisualizer
  set_options: ->
    @y_label = '%'
    @chart_type = 'line'

  update_data: ->
    @data = [{
        name: translate('inflation M0')
        data: @stats.m0_inflation_series[-INFLATION_HIST..]
      }, {
        name: translate('inflation M1')
        data: @stats.m1_inflation_series[-INFLATION_HIST..]
      }, {
        name: translate('inflation M2')
        data: @stats.m2_inflation_series[-INFLATION_HIST..]
    }]

class WealthDistributionChart extends ChartVisualizer
  update_data: ->
    @data = [{
        name: translate('wealth distribution')
        data: @stats.wealth_distribution()
    }]

class CentralBankChart extends ChartVisualizer
  set_options: ->
    super
    @y_max = 2*@stats.m2()

  update_data: ->
    @data = [{
          name: translate('credits to banks')
          data: [@cb.credits_total()]
          color: COL1
          stack: translate('assets')
      }, {
          name: translate('stocks')
          data: [0]
          stack: translate('assets')
      }, {
          name: 'M0'
          data: [@cb.giro_total()]
          color: COL2
          stack: translate('liabilities')
      }, {
          name: translate("capital")
          data: [@cb.capital()]
          stack: translate('liabilities')
      }]

class BanksChart extends ChartVisualizer
  update_data: ->
    reserves = (bank.reserves for bank in @banks)
    loans = (bank.customer_loans() for bank in @banks)
    caps = (bank.capital for bank in @banks)
    cb_debts = (bank.cb_debt for bank in @banks)
    deposits = (bank.customer_deposits() for bank in @banks)
    savings = (bank.customer_savings() for bank in @banks)
    interbank_loans = (bank.interbank_loans() for bank in @banks)
    interbank_debts = (bank.interbank_debt() for bank in @banks)

    @data = [{
          name: translate("reserves")
          data: reserves
          stack: translate('assets')
      }, {
          name: translate('interbank credits')
          data: interbank_loans
          stack: translate('assets')
      }, {
          name: translate('customer loans')
          data: loans
          stack: translate('assets')
      }, {
          name: translate('debt to central bank')
          data: cb_debts
          stack: translate('liabilities')
      }, {
          name: translate('interbank debt')
          data: interbank_debts
          stack: translate('liabilities')
      }, {
          name: translate('deposits') 
          data: deposits
          stack: translate('liabilities')
      }, {
          name: translate('savings') 
          data: savings
          stack: translate('liabilities')
      }, {
          name: translate("capital")
          data: caps
          stack: translate('liabilities')
      }]

class BanksTotalChart extends ChartVisualizer
  set_options: ->
    super
    @y_max = 2*@stats.m2()

  update_data: ->
    reserves = (bank.reserves for bank in @banks)
    loans = (bank.customer_loans() for bank in @banks)
    caps = (bank.capital for bank in @banks)
    cb_debts = (bank.cb_debt for bank in @banks)
    deposits = (bank.customer_deposits() for bank in @banks)
    savings = (bank.customer_savings() for bank in @banks)
    interbank_loans = (bank.interbank_loans() for bank in @banks)
    interbank_debts = (bank.interbank_debt() for bank in @banks)

    @data = [{
          name: translate("reserves")
          data: [ reserves.sum() ]
          color: COL2
          stack: translate('assets')
      }, {
          name: translate('interbank loans')
          data: [ interbank_loans.sum() ]
          stack: translate('assets')
      }, {
          name: translate('customer loans')
          data: [ loans.sum() ]
          color: COL3
          stack: translate('assets')
      }, {
          name: translate('debt to central bank')
          data: [ cb_debts.sum() ]
          color: COL1
          stack: translate('liabilities')
      }, {
          name: translate('interbank debt')
          data: [ interbank_debts.sum() ]
          stack: translate('liabilities')
      }, {
          name: translate('bank deposits')
          data: [ deposits.sum() ]
          color: COL4
          stack: translate('liabilities')
      }, {
          name: translate('savings')
          data: [savings.sum() ]
          stack: translate('liabilities')
      }, {
          name: translate("capital")
          data: [ caps.sum() ]
          stack: translate('liabilities')
    }]

class CustomerTotalChart extends ChartVisualizer
  set_options: ->
    super
    @y_max = 2*@stats.m2()

  update_data: ->
    customers = @microeconomy.all_customers()
    girals = (c.giral for c in customers)
    savings = (c.savings for c in customers)
    loans = (c.loan for c in customers)
    capital = (c.capital() for c in customers)

    @data = [{
          name: translate("giral deposits")
          data: [ girals.sum() ]
          color: COL4
          stack: translate('assets')
      }, {
          name: translate('savings')
          data: [ savings.sum() ]
          stack: translate('assets')
      }, {
          name: translate('loans')
          data: [ loans.sum() ]
          color: COL3
          stack: translate('liabilities')
      }, {
          name: translate('capital')
          data: [ capital.sum() ]
          stack: translate('liabilities')
    }]

class BanksDebtChart extends ChartVisualizer
  update_data: ->
    reserves = (bank.reserves for bank in @banks)
    cb_debts = (bank.cb_debt for bank in @banks)
    interbank_debts = (bank.interbank_debt() for bank in @banks)

    @data = [{
          name: translate('central bank deposits')
          data: reserves
          stack: '1'
      }, {
          name: translate('central bank debt')
          data: cb_debts
          stack: '2'
      }, {
          name: translate('interbank debt')
          data: interbank_debts
          stack: '3'
    }]

#global objects
simulator = null

$ ->
  simulator = new Simulator()
  # show 1st simulation step after page load
  simulator.visualizerMgr.visualize()

  #Knockout.JS specific code
  viewModel = simulator
  ko.applyBindings(viewModel)


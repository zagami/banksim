LANG = 'EN'
CHART_WIDTH = 300
INFLATION_HIST = 20 #data points of inflation graph
MONEY_SUPPLY_HIST = 20 #data points of money supply graph
AUTORUN_DELAY = 2000
COL1 = "red"
COL2 = "blue"
COL3 = "green"
COL4 = "yellow"

_tr = (id) ->
  if LANG == 'EN'
    for index, t of DICT
      return DICT[index][0] if id == index
  else if LANG == 'DE'
    for index, t of DICT
      if id == index
        if DICT[index].length > 1
          return DICT[index][1]
        else
          #use english translation
          return DICT[index][0]
  console.log "TODO: translate - #{id}"

DICT =
  controls_header: ["Controls", "Steuerung"]
  param_header: ['Parameters', 'Parameter']
  simulate_button: ['Simulate', 'Simulieren']
  years_per_step: ['years per step', 'Jahre pro Schritt']
  autorun: ['autorun']
  reset_button: ['Reset']
  #params
  prime_rate: ['prime rate', 'Leitzins']
  prime_rate_giro: ['prime rate deposits', 'Leitzins Reserven']
  libor: ['LIBOR']
  cap_req: ['capital requirement', 'Eigenkapitalvorschrift']
  minimal_reserves: ['minimal reserves', 'Mindestreserve']
  credit_interest: ['loan interest', 'Kreditzinsen']
  deposit_interest: ['deposit interest', 'Guthabenszinsen Zahlungskonto']
  deposit_interest_savings: ['deposit interest savings', 'Guthabenszinsen Sparkonto']
  savings_rate: ['savings rate', 'Sparquote']
  income_tax_rate: ['income tax rate', 'Einkommenssteuersatz']
  #balance sheets
  assets: ['assets', 'Aktiven']
  liabilities: ['liabilities', 'Passiven']
  capital: ['capital', "Eigenkapital"]
  interest: ['interest', "Zins"]
  reserves: ['reserves', "Reserven"]
  balance_sheet: ['balance sheet', "Bilanz"]
  stocks: ['stocks', "Wertschriften"]
  deposits: ['deposits', "Giralgeld"]
  savings: ['savings', 'Sparguthaben']
  loans: ['loans', "Kredite"]
  cb_deposits: ['central bank deposits', 'Zentralbank Guthaben']
  cb_debt: ['central bank debt', "Zentralbank Schulden"]
  interbank_loans: ['interbank loans', "Interbank Kredite"]
  interbank_debt: ['interbank debt', "Interbank Schulden"]
  #diagram titles
  central_bank: ["central bank", "Zentralbank"]
  state: ['state', 'Staat']
  customers: ['customers', 'Bankkunden']
  banks: ['banks', "Banken"]
  statistics: ['statistics', "Statistiken"]
  money_supply: ['money supply', "Geldmenge"]
  wealth_distribution: ['wealth distribution', 'Vermögensverteilung']
  debt_distribution: ['debt distribution', 'Schuldenverteilung']
  banks_consolidated: ['banks consolidated', 'Banken aggregiert']
  customers_consolidated: ['customers consolidated', 'Bankkunden aggregiert']
  income_taxes: ['income taxes', 'Einkommenssteuer']
  income: ['income', 'Einkommen']
  basic_income: ['basic income', 'Grundeinkommen']
  average_income: ['average income', 'Durchschnittseinkommen']
  expenses: ['expenses', 'Ausgaben']
  inflation: ['inflation', 'Inflation']
  taxes: ['taxes', 'Steuern']
  money_flow: ['flow of money', 'Geldfluss']
  nof_customers: ['number of customers', 'Anzahl Bankkunden']
  gdp: ['gross domestic product', 'Bruttoinlandsprodukt BIP']
  basic_income_per_citizen: ['basic income per citizen', 'Grundeinkommen pro Kopf']
iv = (val) ->
  ko.observable(val)

class Simulator

  constructor: ->
    new GUIBuilder().initGUI()
    @update_translations()
    @init()

  init: ->
    banks = (Bank::get_random_bank() for i in [1..NUM_BANKS])
    state = new State()
    cb = new CentralBank(state, banks)
    @params = new Params()
    @microeconomy = new MicroEconomy(state, cb, banks, @params)
    @trx_mgr = new TrxMgr(@microeconomy)
    @visualizerMgr = new VisualizerMgr()


    vizArray = [
      new CentralBankTable(@microeconomy, '#cb_table', 'central_bank'),
      new StateTable(@microeconomy, '#state_table', 'state'),
      new CustomersTable(@microeconomy, '#customers_table', 'customers'),
      new MoneySupplyTable(@microeconomy, '#ms_table', 'money_supply'),
      new BanksTable(@microeconomy, '#banks_table', 'banks'),
      new BanksChart(@microeconomy, '#banks_chart', 'banks'),
      new BanksTotalChart(@microeconomy, '#banks_total_chart', 'banks_consolidated'),
      new BanksDebtChart(@microeconomy, '#banks_chart2', 'cb_deposits'),
      new CustomerTotalChart(@microeconomy, '#customers_total_chart', 'customers_consolidated'),
      new CentralBankChart(@microeconomy, '#cb_chart', 'central_bank'),
      new MoneySupplyChart(@microeconomy, '#stats_chart1', 'money_supply'),
      new InflationChart(@microeconomy, '#stats_chart2', 'inflation'),
      new TaxesChart(@microeconomy, '#taxes_chart', 'taxes'),
      new WealthDistributionChart(@microeconomy, '#wealth_chart', 'wealth_distribution'),
      new InterestGraph(@microeconomy, '#interest_graph', 'money_flow'),
    ]
    for v in vizArray
      @visualizerMgr.addViz v
     
    @init_params()

  simulate: (years) ->
    @simulate_one_year() for [1..years]

  simulate_one_year: ->
    @trx_mgr.one_year()
    
  reset: ->
    InterbankMarket::reset()
    @init()

  init_params: ->
    @step = iv(0)
    @years_per_step =  iv(1)
    @autorun = iv(false)
    @autorun_id = 0
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

    @deposit_interest_savings = ko.computed({
      read: =>
        ( @gui_params.deposit_interest_savings() * 100 ).toFixed(1)
      write: (value) =>
        newval = parseFloat(value)/100
        @gui_params.deposit_interest_savings(newval)
        @params.deposit_interest_savings = newval
    }, this)

    @savings_rate = ko.computed({
      read: =>
        ( @gui_params.savings_rate() * 100 ).toFixed(1)
      write: (value) =>
        newval = parseFloat(value)/100
        @gui_params.savings_rate(newval)
        @params.savings_rate = newval
    }, this)

    @income_tax_rate = ko.computed({
      read: =>
        ( @gui_params.income_tax_rate() * 100 ).toFixed(1)
      write: (value) =>
        newval = parseFloat(value)/100
        @gui_params.income_tax_rate(newval)
        @params.income_tax_rate = newval
    }, this)

  # functions
  reset_params: ->
    @step(0)

  update_text: (id) ->
    $('#'+id).text(_tr(id))

  update_val: (id) ->
    $('#'+id).val(_tr(id))

  update_translations: ->
    @update_text('controls_header')
    @update_text('param_header')
    @update_val('simulate_button')
    @update_text('years_per_step')
    @update_text('autorun')
    @update_val('reset_button')
    @update_text('prime_rate')
    @update_text('prime_rate_giro')
    @update_text('libor')
    @update_text('cap_req')
    @update_text('minimal_reserves')
    @update_text('credit_interest')
    @update_text('deposit_interest')
    @update_text('deposit_interest_savings')
    @update_text('savings_rate')
    @update_text('income_tax_rate')
    if LANG == 'DE'
      $('#instructions_english').hide()
      $('#instructions_german').show()
    else
      $('#instructions_english').show()
      $('#instructions_german').hide()

  lang_de_clicked: ->
    LANG = 'DE'
    @update_translations()
    @visualizerMgr.visualize()

  lang_en_clicked: ->
    LANG = 'EN'
    @update_translations()
    @visualizerMgr.visualize()
    $('#instructions_english').show()
    $('#instructions_german').hide()
    
  simulate_clicked: ->
    yps = parseInt(@years_per_step())
    curr_s = parseInt(@step())
    @step(yps + curr_s)
    @simulate(yps)
    @visualizerMgr.visualize()

  toggle_autorun: ->
    if not @autorun_id
      @autorun_id = setInterval("simulator.simulate_clicked()", AUTORUN_DELAY)
    else
      clearInterval(@autorun_id)
      @autorun_id = null
  
  autorun_clicked: ->
    #needed for keyboard event
    if not @autorun() and not @autorun_id
      @autorun(true) 
    if @autorun() and @autorun_id
      @autorun(false)
    @toggle_autorun()
    return true# needed by knockout

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

class GUIBuilder

  add_button: (container_id, id, handler) ->
    row = $('<tr></tr>')
    button = $('<td colspan=2></td>').append('<input class="button" id="' + id + '" type="button" data-bind="click: ' + handler + '"/>')
    $(container_id).append(row, button)

  add_checkbox: (container_id, id, handler) ->
    row = $('<tr></tr>')
    label = $('<td></td>').addClass('label').attr('id', id)
    checkbox = $('<input type="checkbox" data-bind="checked: ' + id + ', click: ' + handler + '">')
    checkbox = $('<td></td>').append(checkbox)
    $(container_id).append(label, checkbox)

  add_range_param: (container_id, id, start, end, step, unit) ->
    row = $('<tr></tr>')
    label = $('<td></td>').addClass('label').attr('id', id)
    range = $('<td></td>').append('<input data-bind="value:' + id + '" type="range" min="' + start + '" max="' + end + '" step="' + step + '"/>')
    range.append('<span data-bind="text: ' + id + '"></span>'+ (if unit then unit else ''))
    row.append(label).append(range)
    $('#param_table').append(row)
    $(container_id).append(row)

  initGUI: ->
    container_id = '#controls'
    header = $('<h2></h2>').attr('id', 'controls_header')
    table = $('<table></table>').attr('id', 'controls_table')
    $('#controls').append(header, table)
    container_id = '#controls_table'
    @add_button(container_id, 'simulate_button', 'simulate_clicked')
    @add_range_param(container_id, 'years_per_step', 1, 100, 5)
    @add_checkbox(container_id, 'autorun', 'autorun_clicked')
    @add_button(container_id, 'reset_button', 'reset_clicked')

    header = $('<h2></h2>').attr('id', 'param_header')
    table = $('<table></table>').attr('id', 'param_table')
    $('#params').append(header).append(table)
    container_id = '#param_table'
    @add_range_param(container_id, 'prime_rate', 0, 15, 0.1, '%')
    @add_range_param(container_id, 'prime_rate_giro', 0, 15, 0.1, '%')
    @add_range_param(container_id, 'libor', 0, 15, 0.1, '%')
    @add_range_param(container_id, 'cap_req', 0, 50, 1, '%')
    @add_range_param(container_id, 'minimal_reserves', 0, 50, 1, '%')
    @add_range_param(container_id, 'credit_interest', 0, 10, 0.1, '%')
    @add_range_param(container_id, 'deposit_interest', 0, 10, 0.1, '%')
    @add_range_param(container_id, 'deposit_interest_savings', 0, 10, 0.1, '%')
    @add_range_param(container_id, 'savings_rate', 0, 100, 1, '%')
    @add_range_param(container_id, 'income_tax_rate', 0, 100, 1, '%')

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
      nodes: { font: { size: 12 }, borderWidth: 2, shadow:true, mass:2 },
      edges:
        width: 2,
        shadow:true,
        #smooth:
        #type: 'curvedCW'
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
    @network.startSimulation()

  clear: ->
    super
    $(@element_id).empty()

  addNode: (id, label, val = 1) ->
    @nodesArray.push {id: id, value: val, label: label}

  addEdgeSimple: (src, tgt) ->
    @edgesArray.push {id: src + "_" + tgt, from: src, to: tgt, font: {align: 'bottom'}}

  addEdge: (src, tgt, label) ->
    @edgesArray.push {id: src + "_" + tgt, from: src, to: tgt, label: label, arrows:'to', font: {align: 'bottom'}}

  updateNode: (id, label, val=1) ->
    assert(@nodes?, 'nodes not initialized')
    @nodes.update({ id: id, label: label, value: val })

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

class InterestGraph extends GraphVisualizer
  initGraph: ->
    cb_label = _tr("central_bank")
    b_label = _tr("banks")
    c_label = _tr("customers")
    s_label = _tr("state")
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
    @addEdge(s, c, 0)
    @addEdge(s, b, 0)
    @addEdge(b, s, 0)
    @addEdge(c, s, 0)
    @addEdge(c, b, 0)
    @addEdge(cb, s, 0)

  updateGraph: ->
    cb = 1
    b = 2
    s = 3
    c = 4
    cb_label = _tr("central_bank")
    b_label = _tr("banks")
    c_label = _tr("customers")
    s_label = _tr("state")
    @updateNode(cb, cb_label)
    @updateNode(b, b_label)
    @updateNode(s, s_label)
    @updateNode(c, c_label)

    @updateEdge(cb, b, @stats.cb_b_flow_series.last())
    @updateEdge(b, cb, @stats.b_cb_flow_series.last())
    @updateEdge(b, c, @stats.b_c_flow_series.last())
    @updateEdge(c, b, @stats.c_b_flow_series.last())
    @updateEdge(cb, s, @stats.cb_s_flow_series.last())
    @updateEdge(c, s, @stats.c_s_flow_series.last())
    @updateEdge(s, c, @stats.s_c_flow_series.last())

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
    $(@element_id).append( '<caption>' + _tr(@title) + '</caption>' )
    @create_table()
    $(@element_id).append('</table>')

  visualize: ->
    @clear()
    @draw_table()

class CentralBankTable extends TableVisualizer
  create_table: ->
    # balance sheet of central bank
    @create_header(
      _tr('assets'),
      '',
      _tr('liabilities'),
      ''
    )
    @create_row(
      _tr('loans'),
      @cb.credits_total().toFixed(2),
      _tr('reserves'),
      @cb.giro_total().toFixed(2)
    )

    @create_row(
      _tr('stocks'),
      '0',
      _tr('capital'),
      @cb.capital().toFixed(2)
    )

    @create_row(
      'Total',
      @cb.assets_total().toFixed(2),
      '',
      @cb.liabilities_total().toFixed(2)
    )

class CustomersTable extends TableVisualizer
  create_table: ->
    customers = @microeconomy.all_customers()
    len = customers.length
    girals = (c.giral for c in customers)
    savings = (c.savings for c in customers)
    stocks = (c.stocks for c in customers)
    loans = (c.loan for c in customers)
    caps = (c.capital() for c in customers)
    incomes = (c.income for c in customers)
    expenses = (c.expenses for c in customers)

    @create_row(_tr('income'), incomes.sum().toFixed(2))
    @create_row(_tr('expenses'), expenses.sum().toFixed(2))
    @create_row(_tr('average_income'), (incomes.sum()/len).toFixed(2))

class StateTable extends TableVisualizer
  create_table: ->
    num_citizens = @microeconomy.all_customers().length
    len = @state.income_tax_series.length
    if len > 0
      @create_row(_tr('taxes'), @state.income_tax_series.last().toFixed(2))
      @create_row(_tr('basic_income') + ' total', @state.basic_income_series.last().toFixed(2))
      basic_incom_per_citizen = @state.basic_income_series.last() / num_citizens
      @create_row(_tr('basic_income_per_citizen'), basic_incom_per_citizen.toFixed(2))
      @create_row(_tr('gdp'), @stats.gdp_series.last().toFixed(2))

    @create_row(_tr('reserves'), @state.reserves.toFixed(2))
  
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
      _tr("reserves"),
      _tr('interbank credits')
      _tr('credits'),
      _tr('debt to central bank'),
      _tr('interbank debt')
      _tr('bank deposits'),
      _tr("capital"),
      _tr("assets"),
      _tr("liabilities"),
      _tr('nof_customers')
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
    $('#banks_table').append( '<caption>' + _tr('banks') + '</caption>' )
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
      _tr("reserves"),
      '%',
      _tr('interbank_loans')
      _tr('loans'),
      _tr('stocks'),
      _tr('cb_debt'),
      _tr('interbank_debt')
      _tr('deposits'),
      _tr('savings'),
      _tr("capital"),
      _tr("assets"),
      _tr("liabilities"),
      _tr('nof_customers')
    )

  create_bank_row: (id, bank) ->
    row = @create_row(
      id,
      bank.reserves.toFixed(2),
      if bank.gameover then 0 else (bank.reserves / bank.debt_total()*100).toFixed(0) + '%',
      bank.interbank_loans().toFixed(2),
      bank.customer_loans().toFixed(2),
      bank.stocks.toFixed(2),
      bank.cb_debt.toFixed(2),
      bank.interbank_debt().toFixed(2),
      bank.customer_deposits().toFixed(2),
      bank.customer_savings().toFixed(2),
      bank.capital.toFixed(2),
      bank.assets_total().toFixed(2),
      bank.liabilities_total().toFixed(2),
      bank.customers.length
    )
    row.addClass('bankrupt') if bank.gameover

  create_total_row: ->
    reserves = (bank.reserves for bank in @banks)
    loans = (bank.customer_loans() for bank in @banks)
    stocks = (bank.stocks for bank in @banks)
    caps = (bank.capital for bank in @banks)
    cb_debts = (bank.cb_debt for bank in @banks)
    deposits = (bank.customer_deposits() for bank in @banks)
    savings = (bank.customer_savings() for bank in @banks)
    interbank_loans = (bank.interbank_loans() for bank in @banks)
    interbank_debts = (bank.interbank_debt() for bank in @banks)
    assets = (bank.assets_total() for bank in @banks)
    liabilities = (bank.liabilities_total() for bank in @banks)

    @create_row(
      'Total:',
      reserves.sum().toFixed(2),
      '',
      interbank_loans.sum().toFixed(2),
      loans.sum().toFixed(2),
      stocks.sum().toFixed(2),
      cb_debts.sum().toFixed(2),
      interbank_debts.sum().toFixed(2),
      deposits.sum().toFixed(2),
      savings.sum().toFixed(2),
      caps.sum().toFixed(2),
      assets.sum().toFixed(2),
      liabilities.sum().toFixed(2),
      @microeconomy.all_customers().length
    )

  create_table: ->
    @create_bank_header()
    i = 0
    for bank in @banks
      @create_bank_row(i, bank)
      i += 1
    @create_total_row()

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
        text: _tr(@title)
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
        name: _tr('money_supply')  + ' M0'
        data: @stats.m0_series[-MONEY_SUPPLY_HIST..]
      }, {
        name: _tr('money_supply') + ' M1'
        data: @stats.m1_series[-MONEY_SUPPLY_HIST..]
      }, {
        name: _tr('money_supply') + ' M2'
        data: @stats.m2_series[-MONEY_SUPPLY_HIST..]
    }]
    
class InflationChart extends ChartVisualizer
  set_options: ->
    @y_label = '%'
    @chart_type = 'line'

  update_data: ->
    @data = [{
        name: _tr('inflation') + ' M0'
        data: @stats.m0_inflation_series[-INFLATION_HIST..]
      }, {
        name: _tr('inflation') + ' M1'
        data: @stats.m1_inflation_series[-INFLATION_HIST..]
      }, {
        name: _tr('inflation') + ' M2'
        data: @stats.m2_inflation_series[-INFLATION_HIST..]
    }]

class TaxesChart extends ChartVisualizer
  set_options: ->
    @chart_type = 'line'

  update_data: ->
    @data = [{
        name: _tr('income_taxes')
        data: @state.income_tax_series
      }, {
        name: _tr('basic_income')
        data: @state.basic_income_series
    }]

class WealthDistributionChart extends ChartVisualizer
  update_data: ->
    sorted_customers = @stats.wealth_distribution()
    
    wealth = (c.wealth() for c in sorted_customers)
    loans = (-c.loan for c in sorted_customers)
    @data = [{
        name: _tr('wealth_distribution')
        data: wealth
        }, {
        name: _tr('debt_distribution')
        data: loans
    }]

class CentralBankChart extends ChartVisualizer
  set_options: ->
    super

  update_data: ->
    @data = [{
          name: _tr('loans')
          data: [@cb.credits_total()]
          color: COL1
          stack: _tr('assets')
      }, {
          name: _tr('stocks')
          data: [@cb.stocks]
          stack: _tr('assets')
      }, {
          name: 'M0'
          data: [@cb.giro_total()]
          color: COL2
          stack: _tr('liabilities')
      }, {
          name: _tr("capital")
          data: [@cb.capital()]
          stack: _tr('liabilities')
      }]

class BanksChart extends ChartVisualizer
  update_data: ->
    reserves = (bank.reserves for bank in @banks)
    loans = (bank.customer_loans() for bank in @banks)
    stocks = (bank.stocks for bank in @banks)
    caps = (bank.capital for bank in @banks)
    cb_debts = (bank.cb_debt for bank in @banks)
    deposits = (bank.customer_deposits() for bank in @banks)
    savings = (bank.customer_savings() for bank in @banks)
    interbank_loans = (bank.interbank_loans() for bank in @banks)
    interbank_debts = (bank.interbank_debt() for bank in @banks)

    @data = [{
          name: _tr("reserves")
          data: reserves
          stack: _tr('assets')
      }, {
          name: _tr('interbank_loans')
          data: interbank_loans
          stack: _tr('assets')
      }, {
          name: _tr('loans')
          data: loans
          stack: _tr('assets')
      }, {
          name: _tr('stocks')
          data: stocks
          stack: _tr('assets')
      }, {
          name: _tr('cb_debt')
          data: cb_debts
          stack: _tr('liabilities')
      }, {
          name: _tr('interbank_debt')
          data: interbank_debts
          stack: _tr('liabilities')
      }, {
          name: _tr('deposits') 
          data: deposits
          stack: _tr('liabilities')
      }, {
          name: _tr('savings') 
          data: savings
          stack: _tr('liabilities')
      }, {
          name: _tr("capital")
          data: caps
          stack: _tr('liabilities')
      }]

class BanksTotalChart extends ChartVisualizer
  set_options: ->
    super

  update_data: ->
    reserves = (bank.reserves for bank in @banks)
    loans = (bank.customer_loans() for bank in @banks)
    stocks = (bank.stocks for bank in @banks)
    caps = (bank.capital for bank in @banks)
    cb_debts = (bank.cb_debt for bank in @banks)
    deposits = (bank.customer_deposits() for bank in @banks)
    savings = (bank.customer_savings() for bank in @banks)
    interbank_loans = (bank.interbank_loans() for bank in @banks)
    interbank_debts = (bank.interbank_debt() for bank in @banks)

    @data = [{
          name: _tr("reserves")
          data: [ reserves.sum() ]
          color: COL2
          stack: _tr('assets')
      }, {
          name: _tr('interbank_loans')
          data: [ interbank_loans.sum() ]
          stack: _tr('assets')
      }, {
          name: _tr('loans')
          data: [ loans.sum() ]
          color: COL3
          stack: _tr('assets')
      }, {
          name: _tr('stocks')
          data: [ stocks.sum() ]
          stack: _tr('assets')
      }, {
          name: _tr('cb_debt')
          data: [ cb_debts.sum() ]
          color: COL1
          stack: _tr('liabilities')
      }, {
          name: _tr('interbank_debt')
          data: [ interbank_debts.sum() ]
          stack: _tr('liabilities')
      }, {
          name: _tr('deposits')
          data: [ deposits.sum() ]
          color: COL4
          stack: _tr('liabilities')
      }, {
          name: _tr('savings')
          data: [savings.sum() ]
          stack: _tr('liabilities')
      }, {
          name: _tr("capital")
          data: [ caps.sum() ]
          stack: _tr('liabilities')
    }]

class CustomerTotalChart extends ChartVisualizer
  set_options: ->
    super

  update_data: ->
    customers = @microeconomy.all_customers()
    girals = (c.giral for c in customers)
    savings = (c.savings for c in customers)
    stocks = (c.stocks for c in customers)
    loans = (c.loan for c in customers)
    caps = (c.capital() for c in customers)

    @data = [{
          name: _tr("deposits")
          data: [ girals.sum() ]
          color: COL4
          stack: _tr('assets')
      }, {
          name: _tr('savings')
          data: [ savings.sum() ]
          stack: _tr('assets')
      }, {
          name: _tr('stocks')
          data: [ stocks.sum() ]
          stack: _tr('assets')
      }, {
          name: _tr('loans')
          data: [ loans.sum() ]
          color: COL3
          stack: _tr('liabilities')
      }, {
          name: _tr('capital')
          data: [ caps.sum() ]
          stack: _tr('liabilities')
    }]

class BanksDebtChart extends ChartVisualizer
  update_data: ->
    banks_sorted = @banks.slice().sort( (a,b) -> a.reserves - b.reserves)
    reserves = (bank.reserves for bank in banks_sorted)
    cb_debts = (-bank.cb_debt for bank in banks_sorted)
    interbank_debts = (-bank.interbank_debt() for bank in banks_sorted)

    @data = [{
          name: _tr('cb_deposits')
          data: reserves
          stack: '1'
      }, {
          name: _tr('cb_debt')
          data: cb_debts
          stack: '1'
      }, {
          name: _tr('interbank_debt')
          data: interbank_debts
          stack: '1'
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


NUM_BANKS = 10

LANG = 'EN'
INFLATION_HIST = 20 #data points of inflation graph
MONEY_SUPPLY_HIST = 20 #data points of money supply graph
AUTORUN_DELAY = 2000
COL1 = "red"
COL2 = "blue"
COL3 = "green"
COL4 = "yellow"

_tr = (key) ->
  for k, t of DICT
    if k == key
      return DICT[k][0] if LANG == 'EN'
      return DICT[k][1] if LANG == 'DE'
  console.log "TODO: translate - #{key}"
  return "TODO"
  

DICT = []

add_tr = (key, trans) ->
  DICT[key] = trans

#controls
add_tr("lbl_1", ["Year", "Jahr"])
add_tr("lbl_2", ["Controls", "Steuerung"])
add_tr("lbl_3", ['Parameters', 'Parameter'])
add_tr("lbl_4", ['Simulate', 'Simulieren'])
add_tr("lbl_5", ['years per step', 'Jahre pro Schritt'])
add_tr("lbl_6", ['autorun'])
add_tr("lbl_7", ['Reset'])
#params
add_tr("lbl_8", ['prime rate', 'Leitzins'])
add_tr("lbl_9", ['prime rate deposits', 'Leitzins Reserven'])
add_tr("lbl_10", ['LIBOR'])
add_tr("lbl_11", ['capital requirement', 'Eigenkapitalvorschrift'])
add_tr("lbl_12", ['minimal reserves', 'Mindestreserve'])
add_tr("lbl_13", ['loan interest', 'Kreditzinsen'])
add_tr("lbl_14", ['deposit interest', 'Guthabenszinsen Zahlungskonto'])
add_tr("lbl_15", ['deposit interest savings', 'Guthabenszinsen Sparkonto'])
add_tr("lbl_16", ['savings rate', 'Sparquote'])
add_tr("lbl_17", ['income tax rate', 'Einkommenssteuersatz'])
add_tr("lbl_18", ['wealth tax rate', 'Vermögenssteuersatz'])
add_tr("lbl_19", ['government spending', 'Staatsausgaben'])
add_tr("lbl_20", ['basic income', 'Grundeinkommen'])
add_tr("lbl_21", ['positive money', 'Vollgeld'])
add_tr("lbl_22", ['On/Off', 'Ein/Aus'])
add_tr("lbl_23", ['Central Bank', 'Zentralbank'])
add_tr("lbl_24", ['Banks', 'Banken'])
add_tr("lbl_25", ['State', 'Staat'])
#main chart
add_tr("cb_a1", ["debt free money", "schuldfreies ZB Geld"])
add_tr("cb_a2", ["loans to banks", "Kredite an Banken"])
add_tr("cb_l1", ["giro banks", "Giroguthaben Banken"])
add_tr("cb_l2", ["giro state", "Giroguthaben Staat"])
add_tr("cb_l3", ["giro non-banks", "Giroguthaben Nichtbanken"])
add_tr("cb_l4", ["capital", "Eigenkapital"])
add_tr("b_a1", DICT["cb_a1"])
add_tr("b_a2", DICT["cb_l1"])
add_tr("b_a3", ["loans to banks", "Kredite an Banken"])
add_tr("b_a4", ["loans to non-banks", "Kredite an Nichtbanken"])
add_tr("b_l1", ["debt to central bank", "Verbindlichkeit an Zentralbank"])
add_tr("b_l2", ["debt to banks", "Verbindlichkeit an Banken"])
add_tr("b_l3", ["deposits", "Girokonten"])
add_tr("b_l4", ["savings", "Sparkonten"])
add_tr("b_l5", DICT["cb_l4"])
add_tr("nb_a1", DICT["cb_a1"])
add_tr("nb_a2", DICT["b_l3"])
add_tr("nb_a3", DICT["b_l4"])
add_tr("nb_l1", DICT["b_l2"])
add_tr("nb_l2", DICT["cb_l4"])
add_tr("s_a1", DICT["cb_a1"])
add_tr("s_a2", DICT["cb_l2"])
add_tr("s_l1", DICT["cb_l4"])

#balance sheets
add_tr("assets", ['assets', 'Aktiven'])
add_tr("liabilities", ['liabilities', 'Passiven'])

add_tr("central_bank", ["central bank", "Zentralbank"])
add_tr("banks", ['banks', "Banken"])
add_tr("bank", ['bank', "Bank"])
add_tr("nonbanks", ['non-banks', "Nichtbanken"])
add_tr("state", ['state', 'Staat'])
add_tr("money_supply", ['money supply', "Geldmenge"])
add_tr("interest", ['interest', "Zins"])
add_tr("inflation", ['inflation', 'Inflation'])
add_tr("money_flow", ['flow of money', 'Geldfluss'])


add_tr("tab_ms_1", ['interbank volume', 'Interbankenvolumen'])
add_tr("tab_banks_1", ['number of customers', 'Anzahl Kunden'])

add_tr("tab_stats_0", ['statistics', "Statistiken"])
add_tr("tab_stats_1", ['total income', 'Einkommen'])
add_tr("tab_stats_2", ['total expenses', 'Ausgaben'])
add_tr("tab_stats_3", ['average income', 'Durchschnittseinkommen'])

add_tr("tab_stats_4", ['income tax', 'Einkommenssteuer'])
add_tr("tab_stats_5", ['wealth tax', 'Vermögenssteuer'])
add_tr("tab_stats_6", ['gross domestic product', 'Bruttoinlandsprodukt BIP'])
add_tr("tab_stats_7", ['basic income total', 'Total Grundeinkommen'])
add_tr("tab_stats_8", ['basic income per citizen', 'Grundeinkommen pro Kopf'])
add_tr("tab_stats_9", ['number of individuals', 'Anzahl Wirtschaftsteilnehmer'])

add_tr("chart_main_1", ['Overview', 'Übersicht'])

add_tr("chart_ms_1", ['money supply overview', 'Geldmengen Übersicht'])
add_tr("chart_mshist_0", ['money supply development', 'Geldmengen Entwicklung'])
add_tr("chart_mshist_1", ['positive money M', 'Vollgeldmenge M'])
add_tr("chart_mshist_2", DICT["tab_ms_1"])

add_tr("chart_bd_1", ['bank debt', 'Bankverschuldung'])

add_tr("chart_tax_0", ['taxes', 'Steuern'])
add_tr("chart_tax_1", ['income tax', 'Einkommenssteuer'])
add_tr("chart_tax_2", ['wealth tax', 'Vermögenssteuer'])
add_tr("chart_tax_3", ['basic income', 'Grundeinkommen'])

add_tr("chart_wd_0", ['inequality', 'Soziale Ungleichheit'])
add_tr("chart_wd_1", ['wealth distribution', 'Vermögensverteilung'])
add_tr("chart_wd_2", ['debt distribution', 'Schuldenverteilung'])

add_tr("chart_nofc_1", ['reserves / customer ratio', 'Reserven im Verhältnis zu Bankkunden'])
add_tr("chart_nofc_2", ['number of customers', 'Anzahl Kunden'])

  
iv = (val) ->
  ko.observable(val)

class Simulator
  constructor: ->
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
      new MainChart(@microeconomy, '#main_chart'),
      new MoneySupplyChart1(@microeconomy, '#ms_chart1'),
      new MoneySupplyChart2(@microeconomy, '#ms_chart2'),
      new InflationChart(@microeconomy, '#infl_chart'),
      new TaxesChart(@microeconomy, '#taxes_chart'),
      new WealthDistributionChart(@microeconomy, '#wealth_chart'),
      new BanksChart(@microeconomy, '#banks_chart'),
      new BanksDebtChart(@microeconomy, '#banks_chart2'),
      new BanksNumCustomersChart(@microeconomy, '#banks_chart3'),
      new OverviewGraph(@microeconomy, '#overview_graph'),
      new InterestGraph(@microeconomy, '#interest_graph'),
      new CentralBankTable(@microeconomy, '#cb_table'),
      new MoneySupplyTable(@microeconomy, '#ms_table'),
      new StatisticsTable(@microeconomy, '#stats_table'),
      new BanksTable(@microeconomy, '#banks_table'),
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
    @years_per_step =  iv(5)
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

    @wealth_tax_rate = ko.computed({
      read: =>
        ( @gui_params.wealth_tax_rate() * 100 ).toFixed(1)
      write: (value) =>
        newval = parseFloat(value)/100
        @gui_params.wealth_tax_rate(newval)
        @params.wealth_tax_rate = newval
    }, this)

    @gov_spending = ko.computed({
      read: =>
        ( @gui_params.gov_spending() * 100 ).toFixed(1)
      write: (value) =>
        newval = parseFloat(value)/100
        @gui_params.gov_spending(newval)
        @params.gov_spending= newval
    }, this)

    @basic_income_rate = ko.computed({
      read: =>
        ( @gui_params.basic_income_rate() * 100 ).toFixed(1)
      write: (value) =>
        newval = parseFloat(value)/100
        @gui_params.basic_income_rate(newval)
        @params.basic_income_rate = newval
    }, this)

    @positive_money = ko.computed({
      read: =>
        @gui_params.positive_money()
      write: (value) =>
        @gui_params.positive_money(value)
        @params.positive_money= value
    }, this)

  # functions
  reset_params: ->
    @step(0)

  update_label: (id) ->
    if $('#' + id).length > 0
      $('#' + id).text(_tr(id))

  update_translations: ->
    for id, trl of DICT
      @update_label(id)

  lang_de_clicked: ->
    LANG = 'DE'
    @update_translations()
    @visualizerMgr.visualize()
    $('#instructions_english').hide()
    $('#instructions_german').show()

  lang_en_clicked: ->
    LANG = 'EN'
    @update_translations()
    @visualizerMgr.visualize()
    $('#instructions_english').show()
    $('#instructions_german').hide()
    
  instructions_clicked: ->
    $('.instructions').slideToggle()

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

  positive_money_clicked: ->
    $('.deposit_interest').slideToggle()
    if @positive_money()
      @trx_mgr.enable_positive_money()
      @deposit_interest(0)
    else
      @trx_mgr.disable_positive_money()
    return true #needed by knockout

class VisualizerMgr
  vizArray: []
  visualize: ->
    for viz in @vizArray
      viz.visualize()
    return

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
  constructor: (@microeconomy, @element_id) ->
    super
    @setOptions()
    @buildGraph()
    @drawGraph()

  setOptions: ->
    @options = {
      nodes:
        color:
          background: "lightblue"
        font:
          size: 18
        borderWidth: 2
        shadow:true
        mass: 2
      layout:
        randomSeed: 2
      edges:
        width: 2,
        shadow:true,
      interaction:
        zoomView: false
        dragNodes: false
        dragView: false
      physics:
        enabled: true
    }
    
  buildGraph: ->
    @nodesArray = []
    @edgesArray = []
    @initGraph()
    assert(@nodesArray.length > 0, 'Nodes not initialized')
    assert(@edgesArray.length > 0, 'Edges not initialized')
    @edges = new vis.DataSet(@edgesArray)
    @nodes = new vis.DataSet(@nodesArray)

  drawGraph: ->
    data = {
      nodes: @nodes,
      edges: @edges
    }
    container = document.getElementById(@element_id.replace('#', ''))
    @network = new vis.Network(container, data, @options)
    # @network.stabilize()
    # @network.startSimulation()

  clear: ->
    super
    @nodesArray = []
    @edgesArray = []
    $(@element_id).empty()

  addNode: (id, label, val = 1) ->
    @nodesArray.push {id: id, value: val, label: label}

  addEdgeSimple: (src, tgt) ->
    @edgesArray.push {id: src + "_" + tgt, from: src, to: tgt, font: {align: 'bottom'}}

  addEdge: (src, tgt, label) ->
    @edgesArray.push {id: src + "_" + tgt, from: src, to: tgt, label: label, arrows:'to', font: {align: 'bottom'}}

  addNode: (id, label, val=1) ->
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
  #
  updateGraph: ->

  visualize: ->
    @updateGraph()

class InterestGraph extends GraphVisualizer
  initGraph: ->
    super
    @title = _tr('money_flow')
    cb_label = _tr("central_bank")
    b_label = _tr("banks")
    c_label = _tr("nonbanks")
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
    c_label = _tr("nonbanks")
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

class OverviewGraph extends GraphVisualizer
  initGraph: ->
    super
    @options = {
      nodes:
        scaling:
          min: 1
          max: 100 
          label: 
            enabled: true
            min: 5
            max: 96
        shadow:true
      layout:
        improvedLayout: true
        hierarchical:
          enabled: true
          levelSeparation: 500
          nodeSpacing: 20
          edgeMinimization: false
          sortMethod: 'directed'
          parentCentralization: true
      interaction:
        zoomView: true
        dragNodes: true
        dragView: true
      physics:
        enabled: false
    }
    
    cb_label = _tr("central_bank")
    c_label = _tr("nonbank")
    b_label = _tr("bank")
    s_label = _tr("state")
    cb = "cbID"
    s = "stateID"
    console.log "initGraph"
    @addNode(cb, cb_label, 100)
    @addNode(s, s_label, 100)
    @addEdge(s, cb)
    for i in [0...NUM_BANKS]
      @addNode(i, b_label, 50)
      @addEdge(cb, i)
      for j in [0...@banks[i].customers.length]
        c = (i+1)*100+j
        @addNode(c, c_label, 10)
        @addEdge(i,c)

  updateGraph: ->
    cb_label = _tr("central_bank")
    c_label = _tr("nonbank")
    b_label = _tr("bank")
    s_label = _tr("state")
    cb = "cbID"
    s = "stateID"
    console.log "initGraph"
    @updateNode(cb, cb_label, 100)
    @updateNode(s, s_label, 100)
    @updateEdge(s, cb)
    for i in [0...NUM_BANKS]
      @updateNode(i, b_label, 50)
      @updateEdge(cb, i)
      for j in [0...@banks[i].customers.length]
        c = (i+1)*100+j
        @updateNode(c, c_label, 10)
        @updateEdge(i,c)

class TableVisualizer extends Visualizer
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
    @create_table()
    $(@element_id).append( '<caption>' + @title + '</caption>' )
    $(@element_id).append('</table>')

  visualize: ->
    @clear()
    @draw_table()

class CentralBankTable extends TableVisualizer
  create_table: ->
    @title = _tr('central_bank')
    # balance sheet of central bank
    @create_header(
      _tr('assets'),
      '',
      _tr('liabilities'),
      ''
    )
    @create_row(
      _tr('cb_a1'),
      @cb.debt_free_money.toFixed(2),
      _tr('cb_l1'),
      @cb.giro_banks().toFixed(2)
    )

    @create_row(
      _tr('cb_a2'),
      @cb.credits_banks().toFixed(2),
      _tr('cb_l4'),
      @cb.capital().toFixed(2)
    )

    @create_row(
      'Total',
      @cb.assets_total().toFixed(2),
      '',
      @cb.assets_total().toFixed(2)
    )

class StatisticsTable extends TableVisualizer
  create_table: ->
    @title = _tr('tab_stats_0')
    customers = @microeconomy.all_customers()
    len = customers.length
    deposits = (c.deposit for c in customers)
    savings = (c.savings for c in customers)
    loans = (c.loan for c in customers)
    caps = (c.capital() for c in customers)
    incomes = (c.income for c in customers)
    expenses = (c.expenses for c in customers)
    num_citizens = @microeconomy.all_customers().length

    @create_row(_tr('tab_stats_9'), num_citizens)
    @create_row(_tr('tab_stats_1'), incomes.sum().toFixed(2))
    @create_row(_tr('tab_stats_2'), expenses.sum().toFixed(2))
    @create_row(_tr('tab_stats_3'), (incomes.sum()/len).toFixed(2))

    len = @state.income_tax_series.length
    if len > 0
      @create_row(_tr('tab_stats_4'), @state.income_tax_series.last().toFixed(2))
      @create_row(_tr('tab_stats_5'), @state.wealth_tax_series.last().toFixed(2))
      @create_row(_tr('tab_stats_6'), @stats.gdp_series.last().toFixed(2))

    if len > 1
      @create_row(_tr('tab_stats_7'), @state.basic_income_series.last().toFixed(2))
      basic_incom_per_citizen = @state.basic_income_series.last() / num_citizens
      @create_row(_tr('tab_stats_8'), basic_incom_per_citizen.toFixed(2))

    @create_row(_tr('s_a2'), @state.reserves.toFixed(2))
  
class MoneySupplyTable extends TableVisualizer
  create_table: ->
    @title = _tr('money_supply')
    # money supply
    @create_row('M0', @stats.m0().toFixed(2))
    @create_row('M1', @stats.m1().toFixed(2))
    @create_row('M2', @stats.m1().toFixed(2))
    @create_row(_tr('tab_ms_1'), @stats.interbank_volume().toFixed(2))

class BanksTable extends TableVisualizer
  create_bank_header: ->
    @create_header(
      '',
      _tr("b_a1"),
      _tr("b_a2"),
      '%',
      _tr('b_a3')
      _tr('b_a4'),
      _tr('b_l1'),
      _tr('b_l2')
      _tr('b_l3'),
      _tr('b_l4'),
      _tr("b_l5"),
      _tr("assets"),
      _tr("liabilities"),
      _tr('tab_banks_1')
    )

  create_bank_row: (id, bank) ->
    row = @create_row(
      id,
      0,
      bank.reserves.toFixed(2),
      (bank.reserves / bank.debt_total()*100).toFixed(0) + '%',
      bank.interbank_loans().toFixed(2),
      bank.customer_loans().toFixed(2),
      bank.cb_debt.toFixed(2),
      bank.interbank_debt().toFixed(2),
      bank.customer_deposits().toFixed(2),
      bank.customer_savings().toFixed(2),
      bank.capital().toFixed(2),
      bank.assets_total().toFixed(2),
      bank.assets_total().toFixed(2),
      bank.customers.length
    )

  create_total_row: ->
    reserves = (bank.reserves for bank in @banks)
    loans = (bank.customer_loans() for bank in @banks)
    caps = (bank.capital() for bank in @banks)
    cb_debts = (bank.cb_debt for bank in @banks)
    deposits = (bank.customer_deposits() for bank in @banks)
    savings = (bank.customer_savings() for bank in @banks)
    interbank_loans = (bank.interbank_loans() for bank in @banks)
    interbank_debts = (bank.interbank_debt() for bank in @banks)
    assets = (bank.assets_total() for bank in @banks)
    liabilities = assets

    @create_row(
      'Total:',
      0,
      reserves.sum().toFixed(2),
      '',
      interbank_loans.sum().toFixed(2),
      loans.sum().toFixed(2),
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
    @title = _tr('banks')
    @create_bank_header()
    i = 0
    for bank in @banks
      @create_bank_row(i, bank)
      i += 1
    @create_total_row()

class ChartVisualizer extends Visualizer
  constructor: (@microeconomy, @element_id) ->
    super
    @data = []
    @set_options()

  set_options: ->
    @y_label = 'CHF'
    @chart_type = 'column'
    @categories = []
    @legend_visible = true

  draw_chart: ->
    $(@element_id).highcharts({
      chart:
        type: @chart_type
      title:
        text: @title
      xAxis:
        categories: @categories
      yAxis:
        allowDecimals: false
        title:
          text: @y_label
      legend:
        enabled: @legend_visible
      tooltip:
          formatter: ->
              return this.series.name + ': ' + this.y + '<br/>' 
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

class MoneySupplyChart1 extends ChartVisualizer
  set_options: ->
    super
    @legend_visible = false

  update_data: ->
    @title = _tr('chart_ms_1')
    cb_giro_banks = @cb.giro_banks()
    cb_giro_state = @cb.giro_state()
    #interbank_loans = (bank.interbank_loans() for bank in @banks).sum()
    #interbank_debts = (bank.interbank_debt() for bank in @banks).sum()
    customers = @microeconomy.all_customers()
    nb_deposits = (c.deposit for c in customers).sum()
    nb_savings = (c.savings for c in customers).sum()

    @categories = ['M0', 'M1', 'M2']
    @data = [{
          name: _tr('cb_l1')
          data: [cb_giro_banks, 0, 0]
      }, {
          name: _tr('cb_l2')
          data: [cb_giro_state, 0, 0]
      }, {
          name: _tr('cb_a1')
          data: [0, 0, 0]
      }, {
          name: _tr('b_l3')
          data: [0, nb_deposits, 0]
      }, {
          name: 'M0'
          data: [0, @stats.m0(), 0]
      }, {
          name: _tr('b_l4')
          data: [0, 0, nb_savings]
      }, {
          name: 'M1'
          data: [0, 0, @stats.m1()]
    }]
    return

class MoneySupplyChart2 extends ChartVisualizer
  set_options: ->
    super
    @chart_type = 'line'

  update_data: ->
    @title = _tr('chart_mshist_0')
    if @microeconomy.params.positive_money
      @data = [{
          name: _tr('chart_mshist_1')
          data: @stats.m_series[-MONEY_SUPPLY_HIST..]
      }, {
          name: _tr('chart_mshist_2')
          data: @stats.interbank_volume_series[-MONEY_SUPPLY_HIST..]
      }]
    else
      @data = [{
          name: _tr('money_supply')  + ' M0'
          data: @stats.m0_series[-MONEY_SUPPLY_HIST..]
        }, {
          name: _tr('money_supply') + ' M1'
          data: @stats.m1_series[-MONEY_SUPPLY_HIST..]
        }, {
          name: _tr('money_supply') + ' M2'
          data: @stats.m2_series[-MONEY_SUPPLY_HIST..]
        }, {
          name: _tr('chart_mshist_2')
          data: @stats.interbank_volume_series[-MONEY_SUPPLY_HIST..]
      }]
    return
class InflationChart extends ChartVisualizer
  set_options: ->
    super
    @y_label = '%'
    @chart_type = 'line'
    @legend_visible = true

  update_data: ->
    @title = _tr('inflation')
    if @microeconomy.params.positive_money
      @data = [{
          name: _tr('inflation') + ' M'
          data: @stats.m_inflation_series[-INFLATION_HIST..]
      }]
    else
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
    return
class TaxesChart extends ChartVisualizer
  set_options: ->
    super
    @chart_type = 'line'
    @legend_visible = true

  update_data: ->
    @title = _tr('chart_tax_0')
    @data = [{
        name: _tr('chart_tax_1')
        data: @state.income_tax_series
      }, {
        name: _tr('chart_tax_2')
        data: @state.wealth_tax_series
      }, {
        name: _tr('chart_tax_3')
        data: @state.basic_income_series
    }]
    return

class WealthDistributionChart extends ChartVisualizer
  set_options: ->
    super
    @chart_type = 'area'

  update_data: ->
    @title = _tr('chart_wd_0')
    sorted_customers = @stats.wealth_distribution()
    wealth = (c.wealth() for c in sorted_customers)
    loans = (-c.loan for c in sorted_customers)
    @data = [{
        name: _tr('chart_wd_1')
        data: wealth
        }, {
        name: _tr('chart_wd_2')
        data: loans
    }]
    return

class BanksChart extends ChartVisualizer
  set_options: ->
    super
    @chart_type = 'column'
    @legend_visible = false

  update_data: ->
    @title = _tr('banks')
    reserves = (bank.reserves for bank in @banks)
    loans = (bank.customer_loans() for bank in @banks)
    caps = (bank.capital() for bank in @banks)
    cb_debts = (bank.cb_debt for bank in @banks)
    deposits = []
    if not @microeconomy.params.positive_money
      deposits = (bank.customer_deposits() for bank in @banks)
    savings = (bank.customer_savings() for bank in @banks)
    interbank_loans = (bank.interbank_loans() for bank in @banks)
    interbank_debts = (bank.interbank_debt() for bank in @banks)

    @data = [{
          name: _tr("b_a2")
          data: reserves
          stack: _tr('assets')
      }, {
          name: _tr('b_a3')
          data: interbank_loans
          stack: _tr('assets')
      }, {
          name: _tr('b_a4')
          data: loans
          stack: _tr('assets')
      }, {
          name: _tr('b_l1')
          data: cb_debts
          stack: _tr('liabilities')
      }, {
          name: _tr('b_l2')
          data: interbank_debts
          stack: _tr('liabilities')
      },{
          name: _tr('b_l3')
          data: deposits
          stack: _tr('liabilities')
      },{
          name: _tr('b_l4')
          data: savings
          stack: _tr('liabilities')
      }, {
          name: _tr("b_l5")
          data: caps
          stack: _tr('liabilities')
      }]
    return

class MainChart extends ChartVisualizer
  set_options: ->
    super
    @categories = [_tr("central_bank"), _tr("banks"), _tr('nonbanks'), _tr('state')]
    @legend_visible = false

  update_data: ->
    @title = _tr('chart_main_1')
    bank_caps = (bank.capital() for bank in @banks).sum()
    interbank_loans = (bank.interbank_loans() for bank in @banks).sum()
    interbank_debts = (bank.interbank_debt() for bank in @banks).sum()
    customers = @microeconomy.all_customers()
    nb_deposits = (c.deposit for c in customers).sum()
    b_deposits = if @cb.positive_money then 0 else nb_deposits
    nb_savings = (c.savings for c in customers).sum()
    nb_loans = (c.loan for c in customers).sum()
    nb_caps = (c.capital() for c in customers).sum()

    @data = [{
          name: _tr("cb_a1")
          data: [@cb.debt_free_money, 0, 0, 0]
          stack: _tr('assets')
      }, {
          name: _tr("cb_a2")
          data: [@cb.credits_banks(), 0, 0, 0]
          stack: _tr('assets')
      }, {
          name: _tr("cb_l1")
          data: [@cb.giro_banks(), 0, 0, 0]
          stack: _tr('liabilities')
      }, {
          name: _tr("cb_l2")
          data: [@cb.giro_state(), 0, 0, 0]
          stack: _tr('liabilities')
      }, {
          name: _tr("cb_l3")
          data: [@cb.giro_nonbanks(), 0, 0, 0]
          stack: _tr('liabilities')
      }, {
          name: _tr("cb_l4")
          data: [@cb.capital(), 0, 0, 0]
          stack: _tr('liabilities')
      }, {
          name: _tr("b_a1")
          data: [0, 0, 0, 0] #TODO: Cash
          stack: _tr('assets')
      }, {
          name: _tr("b_a2")
          data: [0, @cb.giro_banks(), 0, 0]
          stack: _tr('assets')
      }, {
          name: _tr("b_a3")
          data: [0, interbank_loans, 0, 0]
          stack: _tr('assets')
      }, {
          name: _tr("b_a4")
          data: [0, nb_loans, 0, 0]
          stack: _tr('assets')
      }, {
          name: _tr("b_l1")
          data: [0, @cb.credits_banks(), 0, 0]
          stack: _tr('liabilities')
      }, {
          name: _tr("b_l2")
          data: [0, interbank_debts, 0, 0]
          stack: _tr('liabilities')
      }, {
          name: _tr("b_l3")
          data: [0, b_deposits, 0, 0]
          stack: _tr('liabilities')
      }, {
          name: _tr("b_l4")
          data: [0, nb_savings, 0, 0]
          stack: _tr('liabilities')
      }, {
          name: _tr("b_l5")
          data: [0, bank_caps, 0, 0]
          stack: _tr('liabilities')
      }, {
          name: _tr("nb_a1")
          data: [0, 0, 0, 0]  #TODO: Cash
          stack: _tr('assets')
      }, {
          name: _tr("nb_a2")
          data: [0, 0, nb_deposits, 0]
          stack: _tr('assets')
      }, {
          name: _tr("nb_a3")
          data: [0, 0, nb_savings, 0]
          stack: _tr('assets')
      }, {
          name: _tr("nb_l1")
          data: [0, 0, nb_loans, 0]
          stack: _tr('liabilities')
      }, {
          name: _tr("nb_l2")
          data: [0, 0, nb_caps, 0]
          stack: _tr('liabilities')
      }, {
          name: _tr("s_a1")
          data: [0, 0, 0, 0]
          stack: _tr('assets')
      }, {
          name: _tr("s_a2")
          data: [0, 0, 0, @cb.giro_state()]
          stack: _tr('assets')
      }, {
          name: _tr("s_l1")
          data: [0, 0, 0, @state.capital()]
          stack: _tr('liabilities')
    }]
    return

class BanksDebtChart extends ChartVisualizer
  update_data: ->
    @title = _tr('chart_bd_1')
    banks_sorted = @banks.slice().sort( (a,b) -> a.reserves + a.interbank_loans() - b.reserves - b.interbank_loans())
    reserves = (bank.reserves for bank in banks_sorted)
    cb_debts = (-bank.cb_debt for bank in banks_sorted)
    interbank_loans = (bank.interbank_loans() for bank in banks_sorted)
    interbank_debts = (-bank.interbank_debt() for bank in banks_sorted)

    @data = [{
          name: _tr('b_a2')
          data: reserves
          stack: '1'
      }, {
          name: _tr('b_a3')
          data: interbank_loans
          stack: '1'
      }, {
          name: _tr('b_l1')
          data: cb_debts
          stack: '1'
      }, {
          name: _tr('b_l2')
          data: interbank_debts
          stack: '1'
    }]
    return

class BanksNumCustomersChart extends ChartVisualizer
  set_options: ->
    @chart_type = 'line'
    @legend_visible = true

  update_data: ->
    @title = _tr('chart_nofc_1')
    banks_sorted = @banks.slice().sort( (a,b) -> a.customers.length - b.customers.length)
    total_customers = @microeconomy.all_customers().length
    num_customers = (bank.customers.length * 100 / total_customers for bank in banks_sorted)
    reserve_pct = (bank.reserves * 100 / bank.debt_total() for bank in banks_sorted)
    cb_debts = (bank.cb_debt * 100 / bank.assets_total() for bank in banks_sorted)
    interbank_debts = (bank.interbank_debt() / bank.assets_total() for bank in banks_sorted)

    @data = [{
          name: _tr('b_a2') + ' in %'
          data: reserve_pct
          stack: '1'
      }, {
          name: _tr('chart_nofc_2') + ' in %'
          data: num_customers
          stack: '1'
      }, {
          name: _tr('b_l2') + ' in %'
          data: interbank_debts
          stack: '1'
      }, {
          name: _tr('b_l1') + ' in %'
          data: cb_debts
          stack: '1'
    }]
    return

#global objects
simulator = null

$ ->
  simulator = new Simulator()
  # show 1st simulation step after page load
  simulator.visualizerMgr.visualize()

  #Knockout.JS specific code
  viewModel = simulator
  ko.applyBindings(viewModel)


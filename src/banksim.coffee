$ = require('jquery')
vis = require('vis') 

#params
("lbl_8", ['prime rate', 'Leitzins'])
("lbl_9", ['prime rate deposits', 'Leitzins Reserven'])
("lbl_10", ['LIBOR'])
("lbl_13", ['loan interest', 'Kreditzinsen'])
("lbl_14", ['deposit interest', 'Guthabenszinsen Zahlungskonto'])
("lbl_15", ['deposit interest savings', 'Guthabenszinsen Sparkonto'])
("lbl_23", ['Central Bank', 'Zentralbank'])
#main chart
("cb_a1", ["debt free money", "schuldfreies ZB Geld"])
("cb_a2", ["loans to banks", "Kredite an Banken"])
("cb_l1", ["giro banks", "Giroguthaben Banken"])
("cb_l2", ["giro state", "Giroguthaben Staat"])
("cb_l3", ["giro non-banks", "Giroguthaben Nichtbanken"])
("cb_l4", ["capital", "Eigenkapital"])
("b_a1", DICT["cb_a1"])
("b_a2", DICT["cb_l1"])
("b_a3", ["loans to banks", "Kredite an Banken"])
("b_a4", ["loans to non-banks", "Kredite an Nichtbanken"])
("b_l1", ["debt to central bank", "Verbindlichkeit an Zentralbank"])
("b_l2", ["debt to banks", "Verbindlichkeit an Banken"])
("b_l3", ["deposits", "Girokonten"])
("b_l4", ["savings", "Sparkonten"])
("b_l5", DICT["cb_l4"])
("nb_a1", DICT["cb_a1"])
("nb_a2", DICT["b_l3"])
("nb_a3", DICT["b_l4"])
("nb_l1", DICT["b_l2"])
("nb_l2", DICT["cb_l4"])
("s_a1", DICT["cb_a1"])
("s_a2", DICT["cb_l2"])
("s_l1", DICT["cb_l4"])
#balance sheets
("assets", ['assets', 'Aktiven'])
("liabilities", ['liabilities', 'Passiven'])
("central_bank", ["central bank", "Zentralbank"])
("banks", ['banks', "Banken"])
("bank", ['bank', "Bank"])
("nonbanks", ['non-banks', "Nichtbanken"])
("state", ['state', 'Staat'])
("money_supply", ['money supply', "Geldmenge"])
("interest", ['interest', "Zins"])
("inflation", ['inflation', 'Inflation'])
("money_flow", ['flow of money', 'Geldfluss'])

("tab_ms_1", ['interbank volume', 'Interbankenvolumen'])
("tab_banks_1", ['number of customers', 'Anzahl Kunden'])
("tab_stats_0", ['statistics', "Statistiken"])
("tab_stats_1", ['total income', 'Einkommen'])
("tab_stats_2", ['total expenses', 'Ausgaben'])
("tab_stats_3", ['average income', 'Durchschnittseinkommen'])
("tab_stats_4", ['income tax', 'Einkommenssteuer'])
("tab_stats_5", ['wealth tax', 'Vermögenssteuer'])
("tab_stats_6", ['gross domestic product', 'Bruttoinlandsprodukt BIP'])
("tab_stats_7", ['basic income total', 'Total Grundeinkommen'])
("tab_stats_8", ['basic income per citizen', 'Grundeinkommen pro Kopf'])
("tab_stats_9", ['number of nonbanks', 'Anzahl Wirtschaftsteilnehmer'])

("chart_main_1", ['Overview', 'Übersicht'])

("chart_ms_1", ['money supply overview', 'Geldmengen Übersicht'])
("chart_mshist_0", ['money supply development', 'Geldmengen Entwicklung'])
("chart_mshist_1", ['positive money M', 'Vollgeldmenge M'])
("chart_mshist_2", DICT["tab_ms_1"])
("chart_bd_1", ['bank debt', 'Bankverschuldung'])
("chart_tax_0", ['taxes', 'Steuern'])
("chart_tax_1", ['income tax', 'Einkommenssteuer'])
("chart_tax_2", ['wealth tax', 'Vermögenssteuer'])
("chart_tax_3", ['basic income', 'Grundeinkommen'])

("chart_wd_0", ['inequality', 'Soziale Ungleichheit'])
("chart_wd_1", ['wealth distribution', 'Vermögensverteilung'])
("chart_wd_2", ['debt distribution', 'Schuldenverteilung'])
("chart_nofc_1", ['reserves / customer ratio', 'Reserven im Verhältnis zu Bankkunden'])
("chart_nofc_2", ['number of customers', 'Anzahl Kunden'])


class GraphVisualizer extends Visualizer
  network: null
  constructor: (@microeconomy, @element_id) ->
    super
    @setOptions()
    @nodesArray = []
    @edgesArray = []
    @edges = new vis.DataSet(@edgesArray)
    @nodes = new vis.DataSet(@nodesArray)
    data = {
      nodes: @nodes,
      edges: @edges
    }
    container = document.getElementById(@element_id.replace('#', ''))
    @network = new vis.Network(container, data, @options)
    # @network.stabilize()
    # @network.startSimulation()

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
    
  clear: ->
    super
    $(@element_id).empty()


  #override this method
  initGraph: ->
    # build graph here with @edges.update, @nodes.update
    
  visualize: ->
    @initGraph()

class InterestGraph extends GraphVisualizer
  setOptions: ->
    @options =
      nodes:
        color:
          background: "lightblue"
        font:
          size: 18
        borderWidth: 2
        shadow:true
        mass: 2
      layout:
        improvedLayout: false
        randomSeed: 2
      edges:
        width: 2,
        shadow:true,
        arrows: 'to'
        font:
          align: 'bottom'
      interaction:
        zoomView: true
        dragNodes: false
        dragView: true
      physics:
        enabled: true
   
  initGraph: ->
    @title = _tr('money_flow')

    cb_label = _tr("central_bank")
    b_label = _tr("banks")
    s_label = _tr("state")
    c_label = _tr("nonbanks")
    cb = 1
    b = 2
    s = 3
    c = 4

    @nodes.update(
      id: cb
      label: cb_label
    )
    @nodes.update(
      id: b
      label: b_label
    )
    @nodes.update(
      id: s
      label: s_label
    )
    @nodes.update(
      id: c
      label: c_label
    )
    @edges.update(
      id: cb + "_" + b
      from: cb
      to: b
      label: @stats.cb_b_flow_series.last()?.toFixed(0)
    )
    @edges.update(
      id: b + "_" + cb
      from: b
      to: cb
      label: @stats.b_cb_flow_series.last()?.toFixed(0)
    )
    @edges.update(
      id: b + "_" + c
      from: b
      to: c
      label: @stats.b_c_flow_series.last()?.toFixed(0)
    )
    @edges.update(
      id: s + "_" + c
      from: s
      to: c
      label: @stats.s_c_flow_series.last()?.toFixed(0)
    )
    @edges.update(
      id: s + "_" + b
      from: s
      to: b
      label: @stats.s_b_flow_series.last()?.toFixed(0)
    )
    @edges.update(
      id: b + "_" + s
      from: b
      to: s
      label: @stats.b_s_flow_series.last()?.toFixed(0)
    )
    @edges.update(
      id: c + "_" + s
      from: c
      to: s
      label: @stats.c_s_flow_series.last()?.toFixed(0)
    )
    @edges.update(
      id: c + "_" + b
      from: c
      to: b
      label: @stats.c_b_flow_series.last()?.toFixed(0)
    )
    @edges.update(
      id: cb + "_" + s
      from: cb
      to: s
      label: @stats.cb_s_flow_series.last()?.toFixed(0)
    )

    @network.stabilize()
    # @network.startSimulation()
    #
class OverviewGraph extends GraphVisualizer
  setOptions: ->
    @options = {
      nodes:
        scaling:
          min: 1
          max: 100
          label:
            enabled: true
            min: 5
            max: 16
        shadow: false
      edges:
        width: 1
      layout:
        improvedLayout: false
        hierarchical:
          enabled: true
          # direction: 'LR'
          levelSeparation: 100
          blockShifting: true
          nodeSpacing: 7
          edgeMinimization: false
          sortMethod: 'directed'
          parentCentralization: false
      interaction:
        zoomView: false
        dragNodes: true
        dragView: true
      physics:
        enabled: false
    }

  initGraph: ->
    if @nodes.length > 0
      return

    cb_label = _tr("central_bank")
    c_label = _tr("nonbank")
    b_label = _tr("bank")
    s_label = _tr("state")
    cb = "cbID"
    s = "stateID"
    @nodes.update(
      id: cb
      label: cb_label
      value: 100
    )
    @nodes.update(
      id: s
      label: s_label
      value: 100
    )
    @edges.update(
      id: s + "_" + cb
      from: s
      to: cb
    )

    for i in [0...NUM_BANKS]
      @nodes.update(
        id: i
        label: b_label
        value: 50
      )
      @edges.update(
        id: cb + "_" + i
        from: cb
        to: i
      )
      for j in [0...@banks[i].customers.length]
        c = (i+1)*100+j
        @nodes.update(
          id: c
          value: 10
        )
        @edges.update(
          id: i + "_" + c
          from: i
          to: c
        )

class TableVisualizer extends Visualizer
  clear: ->
    super
    $(@element_id).empty()

  create_row: (entries...) ->
    tr = '<tr>'
    tr += '<td>' + entry + '</td>' for entry in entries
    tr +='</tr>'
    tr = $(tr)
    @table.append(tr)

  create_header: (entries...) ->
    tr = '<tr>'
    tr += '<th>' + entry + '</th>' for entry in entries
    tr +='</tr>'
    @table.append(tr)

  draw_table: ->
    @table = $('<table></table>')
    $(@element_id).append(@table)
    @create_table()
    @table.append( '<caption>' + @title + '</caption>' )

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
    @create_row(
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
    Highcharts.chart(@element_id.replace("#", ""), {
    
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


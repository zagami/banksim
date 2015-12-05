LANG = 'DE'
NUM_BANKS = 12

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

AUTORUN_DELAY = 2000

class Simulator
  init: ->
    banks = (Bank::get_random_bank() for i in [1..NUM_BANKS])
    cb = new CentralBank(banks)
    @microeconomy = new MicroEconomy(cb, banks)

  constructor: (@params) ->
    @init()
    @trx_mgr = new TrxMgr(@params, @microeconomy)
    @params.set_simulator(this)
    
  simulate: (years) ->
    console.log years
    console.log("simulating..." + years + " years")
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
    $('#banks_table').empty()

  create_row: (entries...) ->
    tr = '<tr>'
    tr += '<td>' + entry + '</td>' for entry in entries
    tr +='</tr>'

  create_cb_table: (cb) ->
    # balance sheet of central bank
    $('#cb_table').append( '<table>' )
    $('#cb_table').append( '<caption>' + translate('central bank') + '</caption>' )
    row_h = @create_row(translate('assets'), '', translate('liabilities'), '')
    row_1 = @create_row('Forderungen an Banken', cb.credits_total().toFixed(2), 'ZB Giralgeld', cb.giro_total().toFixed(2) )
    row_2 = @create_row(translate('stocks'), '0', translate('capital'), cb.capital().toFixed(2))
    row_3 = @create_row(translate('total'), cb.assets_total().toFixed(2), '', cb.liabilities_total().toFixed(2)) 
    
    $('#cb_table').append(row_h).append(row_1).append(row_2).append(row_3)
    $('#cb_table').append(  '</table>' )

    # money supply
    $('#cb_table').append('<h3>'+translate('statistics') + '</h3>')
    $('#cb_table').append(  '<table>' )
    row_h = @create_row(translate('money supply'), 'M0', 'M1', 'M2')
    row = @create_row('', cb.M0().toFixed(2), cb.M1().toFixed(2), cb.M2().toFixed(2))
    $('#cb_table').append(  '<table>' ).append(row_h).append(row)
    $('#cb_table').append('</table>' )

  create_bank_header: ->
    th = '<tr>'
    th += '<th>' + translate("reserves")  + '</th>'
    th += '<th>' + translate('credits')  + '</th>'
    th += '<th>' + translate('debt to central bank')  + '</th>'
    th += '<th>' + translate('bank deposits')  + '</th>'
    th += '<th>' + translate("capital")  + '</th>'
    th += '<th>' + translate("assets")  + '</th>'
    th += '<th>' + translate("liabilities")  + '</th>'
    th += '</tr>'
    th

  create_bank_row: (bank) ->
    tr = '<tr>'
    tr += '<td>' + bank.reserves.toFixed(2)  + '</td>'
    tr += '<td>' + bank.credits.toFixed(2)  + '</td>'
    tr += '<td>' + bank.credit_cb.toFixed(2)  + '</td>'
    tr += '<td>' + bank.giral.toFixed(2)  + '</td>'
    tr += '<td>' + bank.capital.toFixed(2)  + '</td>'
    tr += '<td>' + bank.assets_total().toFixed(2)  + '</td>'
    tr += '<td>' + bank.liabilities_total().toFixed(2)  + '</td>'
    tr +='</tr>'
    tr

  visualize: ->
    console.log "creating table for #{@banks.length} banks"
    @clear()
    @create_cb_table(@cb)
    $('#banks_table').append(  '<table>' );
    $('#cb_table').append( '<caption>' + translate('banks') + '</caption>' )
    $('#banks_table').append(@create_bank_header())
    for bank in @banks
      $('#banks_table').append(@create_bank_row(bank))      
    $('#banks_table').append(  '</table>' )

class GraphVisualizer extends Visualizer
  constructor: (@microeconomy) ->
    super
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
    console.log("drawing graph... #{@banks.length}")
    @clear()
    @draw_cb(@cb)
    @drawgraph(@banks)

iv = (val) ->
  ko.observable(val)
  
class Params
  # Simulator Control
  step: iv(0)
  yearsPerStep: iv(1)
  autorun: iv("off")
  autorun_id: 0
  tableViz_checked: iv(true)
  diagramViz_checked: iv(true)

  # Microeconomy
  max_trx: iv(50)  # max nr of trx per year
  prime_rate: iv(3)  # prime rate paid by banks for central bank credits
  prime_rate_giro: iv(1) # prime rate paid by central bank to banks for deposits
  cap_req: iv(8)  #capital requirements in percent (leverage ratio)
  minimal_reserves: iv(5)  # reserve requirements for banks
  credit_interest: iv(6)
  deposit_interest: iv(2)
  
  # functions
  set_simulator: (sim) ->
    @simulator = sim
    @visualizerMgr = new VisualizerMgr(sim.microeconomy)
    @set_viz()

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
    if @autorun() is "off"
      @autorun('on')
      @autorun_id = setInterval("params.simulate_clicked()", AUTORUN_DELAY) 
    else
      clearInterval(@autorun_id)
      @autorun("off")

  reset_clicked: ->
    @step(0)
    @simulator.reset()
    @visualizerMgr.visualize()

#global objects
simulator = null
params = null

$ ->
  params = new Params()
  simulator = new Simulator(params)
  # show 1st simulation step after page load
  params.reset_clicked()

  #Knockout.JS specific code
  viewModel = params
  ko.applyBindings(viewModel)


#Backlog
# - GUI controls 
# resetting parameters?
# - Tilgung der Kredite?
# - Kreditausfall? (Sicherheit pfänden?)
# - Interbankenmarkt
# - individuelle Bankkunden
# - Repo Geschäfte mit SNB

// Generated by CoffeeScript 1.9.3
var AUTORUN_DELAY, DICT, GraphVisualizer, LANG, NUM_BANKS, Params, Simulator, TableVisualizer, Visualizer, VisualizerMgr, iv, params, simulator, translate,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

LANG = 'DE';

NUM_BANKS = 12;

translate = function(engl_word) {
  var d, e;
  if (LANG === 'EN') {
    return engl_word;
  } else if (LANG === 'DE') {
    for (e in DICT) {
      d = DICT[e];
      if (engl_word === e) {
        return d;
      }
    }
    return console.log("TODO: translate - " + e);
  }
};

DICT = {
  "table": "Tabelle",
  "diagram": "Diagramm",
  "interest": "Zins",
  "reserves": "Reserven",
  "banks": "Banken",
  "central bank": "Zentralbank",
  "capital": "Eigenkapital",
  "assets": "Aktiven",
  "liabilities": "Passiven",
  "balance sheet": "Bilanz",
  "prime rate": "Leitzins",
  "stocks": "Wertschriften",
  "statistics": "Statistiken",
  "money supply": "Geldmenge",
  "credits": "Kredite",
  "credits to banks": "Kredite an Banken",
  "debt to central bank": "Schulden an ZB",
  "bank deposits": "Giralgeld",
  "total": "Total"
};

AUTORUN_DELAY = 2000;

Simulator = (function() {
  Simulator.prototype.init = function() {
    var banks, cb, i;
    banks = (function() {
      var j, ref, results;
      results = [];
      for (i = j = 1, ref = NUM_BANKS; 1 <= ref ? j <= ref : j >= ref; i = 1 <= ref ? ++j : --j) {
        results.push(Bank.prototype.get_random_bank());
      }
      return results;
    })();
    cb = new CentralBank(banks);
    return this.microeconomy = new MicroEconomy(cb, banks);
  };

  function Simulator(params1) {
    this.params = params1;
    this.init();
    this.trx_mgr = new TrxMgr(this.params, this.microeconomy);
    this.params.set_simulator(this);
  }

  Simulator.prototype.simulate = function(years) {
    var j, ref, results;
    console.log(years);
    console.log("simulating..." + years + " years");
    results = [];
    for (j = 1, ref = years; 1 <= ref ? j <= ref : j >= ref; 1 <= ref ? j++ : j--) {
      results.push(this.simulate_one_year());
    }
    return results;
  };

  Simulator.prototype.simulate_one_year = function() {
    return this.trx_mgr.one_year();
  };

  Simulator.prototype.reset = function() {
    return this.init();
  };

  return Simulator;

})();

VisualizerMgr = (function() {
  function VisualizerMgr() {}

  VisualizerMgr.prototype.vizArray = [];

  VisualizerMgr.prototype.visualize = function() {
    var j, len, ref, results, viz;
    ref = this.vizArray;
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      viz = ref[j];
      results.push(viz.visualize());
    }
    return results;
  };

  VisualizerMgr.prototype.clear = function() {
    var j, len, ref, results, viz;
    ref = this.vizArray;
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      viz = ref[j];
      results.push(viz.clear());
    }
    return results;
  };

  VisualizerMgr.prototype.addViz = function(viz) {
    return this.vizArray.push(viz);
  };

  VisualizerMgr.prototype.reset = function() {
    this.clear();
    return this.vizArray = [];
  };

  return VisualizerMgr;

})();

Visualizer = (function() {
  function Visualizer(microeconomy) {
    this.microeconomy = microeconomy;
    this.banks = microeconomy.banks;
    this.cb = microeconomy.cb;
  }

  Visualizer.prototype.clear = function() {};

  Visualizer.prototype.visualize = function() {};

  return Visualizer;

})();

TableVisualizer = (function(superClass) {
  extend(TableVisualizer, superClass);

  function TableVisualizer(microeconomy1) {
    this.microeconomy = microeconomy1;
    TableVisualizer.__super__.constructor.apply(this, arguments);
  }

  TableVisualizer.prototype.clear = function() {
    TableVisualizer.__super__.clear.apply(this, arguments);
    $('#cb_table').empty();
    return $('#banks_table').empty();
  };

  TableVisualizer.prototype.create_row = function() {
    var entries, entry, j, len, tr;
    entries = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    tr = '<tr>';
    for (j = 0, len = entries.length; j < len; j++) {
      entry = entries[j];
      tr += '<td>' + entry + '</td>';
    }
    return tr += '</tr>';
  };

  TableVisualizer.prototype.create_cb_table = function(cb) {
    var row, row_1, row_2, row_3, row_h;
    $('#cb_table').append('<table>');
    $('#cb_table').append('<caption>' + translate('central bank') + '</caption>');
    row_h = this.create_row(translate('assets'), '', translate('liabilities'), '');
    row_1 = this.create_row('Forderungen an Banken', cb.credits_total().toFixed(2), 'ZB Giralgeld', cb.giro_total().toFixed(2));
    row_2 = this.create_row(translate('stocks'), '0', translate('capital'), cb.capital().toFixed(2));
    row_3 = this.create_row(translate('total'), cb.assets_total().toFixed(2), '', cb.liabilities_total().toFixed(2));
    $('#cb_table').append(row_h).append(row_1).append(row_2).append(row_3);
    $('#cb_table').append('</table>');
    $('#cb_table').append('<h3>' + translate('statistics') + '</h3>');
    $('#cb_table').append('<table>');
    row_h = this.create_row(translate('money supply'), 'M0', 'M1', 'M2');
    row = this.create_row('', cb.M0().toFixed(2), cb.M1().toFixed(2), cb.M2().toFixed(2));
    $('#cb_table').append('<table>').append(row_h).append(row);
    return $('#cb_table').append('</table>');
  };

  TableVisualizer.prototype.create_bank_header = function() {
    var th;
    th = '<tr>';
    th += '<th>' + translate("reserves") + '</th>';
    th += '<th>' + translate('credits') + '</th>';
    th += '<th>' + translate('debt to central bank') + '</th>';
    th += '<th>' + translate('bank deposits') + '</th>';
    th += '<th>' + translate("capital") + '</th>';
    th += '<th>' + translate("assets") + '</th>';
    th += '<th>' + translate("liabilities") + '</th>';
    th += '</tr>';
    return th;
  };

  TableVisualizer.prototype.create_bank_row = function(bank) {
    var tr;
    tr = '<tr>';
    tr += '<td>' + bank.reserves.toFixed(2) + '</td>';
    tr += '<td>' + bank.credits.toFixed(2) + '</td>';
    tr += '<td>' + bank.credit_cb.toFixed(2) + '</td>';
    tr += '<td>' + bank.giral.toFixed(2) + '</td>';
    tr += '<td>' + bank.capital.toFixed(2) + '</td>';
    tr += '<td>' + bank.assets_total().toFixed(2) + '</td>';
    tr += '<td>' + bank.liabilities_total().toFixed(2) + '</td>';
    tr += '</tr>';
    return tr;
  };

  TableVisualizer.prototype.visualize = function() {
    var bank, j, len, ref;
    console.log("creating table for " + this.banks.length + " banks");
    this.clear();
    this.create_cb_table(this.cb);
    $('#banks_table').append('<table>');
    $('#cb_table').append('<caption>' + translate('banks') + '</caption>');
    $('#banks_table').append(this.create_bank_header());
    ref = this.banks;
    for (j = 0, len = ref.length; j < len; j++) {
      bank = ref[j];
      $('#banks_table').append(this.create_bank_row(bank));
    }
    return $('#banks_table').append('</table>');
  };

  return TableVisualizer;

})(Visualizer);

GraphVisualizer = (function(superClass) {
  extend(GraphVisualizer, superClass);

  function GraphVisualizer(microeconomy1) {
    this.microeconomy = microeconomy1;
    GraphVisualizer.__super__.constructor.apply(this, arguments);
  }

  GraphVisualizer.prototype.clear = function() {
    $('#banks_graph').empty();
    return $('#cb_graph').empty();
  };

  GraphVisualizer.prototype.draw_cb = function(cb) {
    return $('#cb_graph').highcharts({
      chart: {
        type: 'column'
      },
      title: {
        text: translate("central bank")
      },
      xAxis: {
        categories: []
      },
      yAxis: {
        allowDecimals: false,
        min: 0,
        title: {
          text: 'CHF'
        }
      },
      tooltip: {
        formatter: function() {
          return '<b>' + this.x + '</b><br/>' + this.series.name + ': ' + this.y + '<br/>' + 'Total: ' + this.point.stackTotal;
        }
      },
      plotOptions: {
        column: {
          stacking: 'normal'
        }
      },
      series: [
        {
          name: translate('credits to banks'),
          data: [cb.credits_total()],
          stack: translate('assets')
        }, {
          name: translate('stocks'),
          data: [0],
          stack: translate('assets')
        }, {
          name: 'M0',
          data: [cb.giro_total()],
          stack: translate('liabilities')
        }, {
          name: translate("capital"),
          data: [cb.capital()],
          stack: translate('liabilities')
        }
      ]
    });
  };

  GraphVisualizer.prototype.drawgraph = function(banks) {
    var bank, caps, cbcredits, credits, girals, reserves;
    reserves = (function() {
      var j, len, results;
      results = [];
      for (j = 0, len = banks.length; j < len; j++) {
        bank = banks[j];
        results.push(bank.reserves);
      }
      return results;
    })();
    credits = (function() {
      var j, len, results;
      results = [];
      for (j = 0, len = banks.length; j < len; j++) {
        bank = banks[j];
        results.push(bank.credits);
      }
      return results;
    })();
    caps = (function() {
      var j, len, results;
      results = [];
      for (j = 0, len = banks.length; j < len; j++) {
        bank = banks[j];
        results.push(bank.capital);
      }
      return results;
    })();
    cbcredits = (function() {
      var j, len, results;
      results = [];
      for (j = 0, len = banks.length; j < len; j++) {
        bank = banks[j];
        results.push(bank.credit_cb);
      }
      return results;
    })();
    girals = (function() {
      var j, len, results;
      results = [];
      for (j = 0, len = banks.length; j < len; j++) {
        bank = banks[j];
        results.push(bank.giral);
      }
      return results;
    })();
    return $('#banks_graph').highcharts({
      chart: {
        type: 'column'
      },
      title: {
        text: translate('banks')
      },
      xAxis: {
        categories: []
      },
      yAxis: {
        allowDecimals: false,
        min: 0,
        title: {
          text: 'CHF'
        }
      },
      tooltip: {
        formatter: function() {
          return '<b>' + this.x + '</b><br/>' + this.series.name + ': ' + this.y + '<br/>' + 'Total: ' + this.point.stackTotal;
        }
      },
      plotOptions: {
        column: {
          stacking: 'normal'
        }
      },
      series: [
        {
          name: translate("reserves"),
          data: reserves,
          stack: translate('assets')
        }, {
          name: translate('credits'),
          data: credits,
          stack: translate('assets')
        }, {
          name: translate('debt to central bank'),
          data: cbcredits,
          stack: translate('liabilities')
        }, {
          name: translate('bank deposits'),
          data: girals,
          stack: translate('liabilities')
        }, {
          name: translate("capital"),
          data: caps,
          stack: translate('liabilities')
        }
      ]
    });
  };

  GraphVisualizer.prototype.visualize = function() {
    console.log("drawing graph... " + this.banks.length);
    this.clear();
    this.draw_cb(this.cb);
    return this.drawgraph(this.banks);
  };

  return GraphVisualizer;

})(Visualizer);

iv = function(val) {
  return ko.observable(val);
};

Params = (function() {
  function Params() {}

  Params.prototype.step = iv(0);

  Params.prototype.yearsPerStep = iv(1);

  Params.prototype.autorun = iv("off");

  Params.prototype.autorun_id = 0;

  Params.prototype.tableViz_checked = iv(true);

  Params.prototype.diagramViz_checked = iv(true);

  Params.prototype.max_trx = iv(50);

  Params.prototype.prime_rate = iv(3);

  Params.prototype.prime_rate_giro = iv(1);

  Params.prototype.cap_req = iv(8);

  Params.prototype.minimal_reserves = iv(5);

  Params.prototype.credit_interest = iv(6);

  Params.prototype.deposit_interest = iv(2);

  Params.prototype.set_simulator = function(sim) {
    this.simulator = sim;
    this.visualizerMgr = new VisualizerMgr(sim.microeconomy);
    return this.set_viz();
  };

  Params.prototype.set_viz = function() {
    this.visualizerMgr.reset();
    if (this.tableViz_checked()) {
      this.visualizerMgr.addViz(new TableVisualizer(this.simulator.microeconomy));
    }
    if (this.diagramViz_checked()) {
      return this.visualizerMgr.addViz(new GraphVisualizer(this.simulator.microeconomy));
    }
  };

  Params.prototype.viz_clicked = function() {
    this.set_viz();
    this.visualizerMgr.visualize();
    return true;
  };

  Params.prototype.lang_de_clicked = function() {
    LANG = 'DE';
    return this.visualizerMgr.visualize();
  };

  Params.prototype.lang_en_clicked = function() {
    LANG = 'EN';
    return this.visualizerMgr.visualize();
  };

  Params.prototype.simulate_clicked = function() {
    var curr_s, yps;
    yps = parseInt(this.yearsPerStep());
    curr_s = parseInt(this.step());
    this.step(yps + curr_s);
    this.simulator.simulate(yps);
    return this.visualizerMgr.visualize();
  };

  Params.prototype.autorun_clicked = function() {
    if (this.autorun() === "off") {
      this.autorun('on');
      return this.autorun_id = setInterval("params.simulate_clicked()", AUTORUN_DELAY);
    } else {
      clearInterval(this.autorun_id);
      return this.autorun("off");
    }
  };

  Params.prototype.reset_clicked = function() {
    this.step(0);
    this.simulator.reset();
    return this.visualizerMgr.visualize();
  };

  return Params;

})();

simulator = null;

params = null;

$(function() {
  var viewModel;
  params = new Params();
  simulator = new Simulator(params);
  params.reset_clicked();
  viewModel = params;
  return ko.applyBindings(viewModel);
});

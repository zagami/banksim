import React from 'react';
import ReactDOM from 'react-dom';
import {randomize, randomizeInt, assert} from './helper.coffee';

var Highcharts = require('highcharts');

const instr_en = require('./english.md');
const instr_de = require('./german.md');

var $ = require('jquery');

// var MicroEconomy = require('./microeconomy.js');

import MicroEconomy from './microeconomy';

var TrxMgr = require('./trxmgr.coffee');

const DFLT_LANG = 'DE';
var LANG = DFLT_LANG;

var __ = function(en, de) {
	return LANG == 'EN'? en : de;
}

class Slider extends React.Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    this.props.onChange(this.props.name, event.target.value/100);
  }

  render() {
    return (
      <form>
        <label>
          {this.props.label}
          <input type="range" name={this.props.name} value={(this.props.params[this.props.name]*100).toFixed(1)} onChange={this.handleChange} />
		{(this.props.params[this.props.name]*100).toFixed(1)} %
        </label>
      </form>
    );
  }
}

class Parameters extends React.Component {

  getSlider(id, label){
	  return <Slider name={id} params={this.props.params} label={label} onChange={this.props.onChange} />
  }
	render() {
		return(<div id = "params" className='input-group'>
			<h1>{__('Parameters', 'Parameter')}</h1>
			{this.getSlider('prime_rate', __("Prime Rate", "Leitzins"))}
			{this.getSlider('prime_rate_giro', __("Prime Rate Deposits", "Leitzins Reserven"))}
			{this.getSlider('credit_interest', __('Loan Interest', 'Kreditzinsen'))}
			{this.getSlider('deposit_interest', __('Deposit Interest', 'Guthabenszinsen Zahlungskonto'))}
			{this.getSlider('deposit_interest_savings', __('Deposit Interest Savings', 'Guthabenszinsen Sparkonto'))}
			</div>
		);
	}
 }
      
class Controls extends React.Component {
	render() {
		return (<div id="controls">
			<h1>{__("Controls", "Steuerung")}</h1>
			<div>{__("year", "Jahr")}: {this.props.year}</div>
			<button id="simulate" className="btn btn-primary btn-block" type="button" onClick={this.props.onSimulate}>{__("Simulate", "Simulieren")}</button>
			</div>
		);
	}
}

class Simulator extends React.Component {
  constructor(props) {
    super(props);
    this.microeconomy = new MicroEconomy();
    this.trx_mgr = new TrxMgr(this.microeconomy);

    this.handleParamChange = this.handleParamChange.bind(this);
    this.lang_en_clicked= this.lang_en_clicked.bind(this);
    this.lang_de_clicked= this.lang_de_clicked.bind(this);
    this.simulateClicked = this.simulateClicked.bind(this);

	this.state = {
		year: 0,
		lang: DFLT_LANG,
		params: this.microeconomy.params
	}
  }
	
  componentDidMount() {
	this.setInstructionsLang(DFLT_LANG);
  }
	setInstructionsLang(lang) {
		let container = document.getElementById("instructions");
		if(lang=='EN') {
			container.innerHTML = instr_en;
		} else if(lang=='DE') {
			container.innerHTML = instr_de;
		}
	}

	handleParamChange(p, val) {
		//console.log(`handle change ${p} ${val}`);
		this.microeconomy.params[p] = val;
		this.setState({params: this.microeconomy.params});
	}


  lang_en_clicked() {
	LANG = 'EN';
	this.setInstructionsLang(LANG);
    this.setState({lang: 'EN'});
  }

  lang_de_clicked() {
	LANG = 'DE';
	this.setInstructionsLang(LANG);
    this.setState({lang: 'DE'});
  }

	simulateClicked(){
		this.trx_mgr.one_year()
		this.setState((prevState, props) => ({
			year: prevState.year + 1
		}));
	}

	render() {
		return(<div id="simulator">
			<div className="row">
			<div className="col-md-12"> 
			<div className="btn-group">
				<a href="#" className="btn btn-default" data-toggle="modal" data-target=".instr_modal">{__("Instructions", "Anleitung")}</a>
				<a href="#" className="btn btn-default"  onClick = {this.lang_de_clicked}>DE</a>
				<a href="#" className="btn btn-default" onClick = {this.lang_en_clicked}>EN</a>
			</div> 
			</div>
			</div>
			<div className="instr_modal modal fade">
			<div className="modal-dialog modal-lg">
			<div className="modal-content">
			<div className="modal-header">
				<button type="button" className="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
			</div>
			<div id="instructions"></div>
			</div>
			</div>
			</div>
			<h1>BankSim</h1>
			<Controls year = {this.state.year} onSimulate={this.simulateClicked}/>
			<Parameters params={this.microeconomy.params} onChange={this.handleParamChange} />
			<MicroEconomyViewer me={this.microeconomy}/>
			</div>
		);
	}
 }

class MicroEconomyViewer extends React.Component {
  constructor(props) {
	super(props);
  }
  
  componentDidMount() {
  let data = [{
        name: 'Installation',
        data: [43934, 52503, 57177, 69658, 97031, 119931, 137133, 154175]
    }, {
        name: 'Manufacturing',
        data: [24916, 24064, 29742, 29851, 32490, 30282, 38121, 40434]
    }, {
        name: 'Sales & Distribution',
        data: [11744, 17722, 16005, 19771, 20185, 24377, 32147, 39387]
    }, {
        name: 'Project Development',
        data: [null, null, 7988, 12169, 15112, 22452, 34400, 34227]
    }, {
        name: 'Other',
        data: [12908, 5948, 8105, 11248, 8989, 11816, 18274, 18111]
    }];
	  Highcharts.chart("chart1", {series: data});
  }
  render() {
	  return (<div id="chart1" className="chart"> Hello Chart! </div>);
  }
}

ReactDOM.render(
  <Simulator />,
  document.getElementById('app')
);

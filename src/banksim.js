import React from 'react';
import ReactDOM from 'react-dom';
import {randomize, randomizeInt, assert} from './helper.coffee';

var $ = require('jquery');

// var MicroEconomy = require('./microeconomy.js');

import MicroEconomy from './microeconomy';

var TrxMgr = require('./trxmgr.coffee');

var DFLT_LANG = 'DE';
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
		return(<div id = "params">
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
			<button id="simulate" type="button" onClick={this.props.onSimulate}>{__("Simulate", "Simulieren")}</button>
			</div>
		);
	}
}

class Simulator extends React.Component {
  constructor(props) {
    super(props);
	this.state = {
		year: 0,
		lang: DFLT_LANG
	}
    this.microeconomy = new MicroEconomy();
    this.trx_mgr = new TrxMgr(this.microeconomy);

    this.handleParamChange = this.handleParamChange.bind(this);
    this.lang_en_clicked= this.lang_en_clicked.bind(this);
    this.lang_de_clicked= this.lang_de_clicked.bind(this);
    this.instructions_clicked = this.instructions_clicked.bind(this);
    this.simulateClicked = this.simulateClicked.bind(this);
  }

	handleParamChange(p, val) {
		//console.log(`handle change ${p} ${val}`);
		this.microeconomy.params[p] = val;
		ReactDOM.render(
			<Parameters params={this.microeconomy.params} />,
			document.getElementById('params')
		);
	}

  lang_en_clicked() {
	LANG = 'EN';
    this.setState({lang: 'EN'});
  }

  lang_de_clicked() {
	LANG = 'DE';
    this.setState({lang: 'DE'});
  }

  instructions_clicked() {
	if (this.state.lang == 'DE') {
		$('#instructions_german').slideToggle();
		$('#instructions_english').hide()
		console.log('DE');
	}
	if (this.state.lang == 'EN') {
		$('#instructions_english').slideToggle();
		$('#instructions_german').hide()
	}
  }
	simulateClicked(){
		this.trx_mgr.one_year()
		this.setState((prevState, props) => ({
			year: prevState.year + 1
		}));
	}

	render() {
		return(<div id="simulator">
			<a href="#" onClick= {this.instructions_clicked}>{__("Instructions", "Anleitung")}</a>
			<a href="#" onClick = {this.lang_de_clicked}>DE</a>
			<a href="#" onClick = {this.lang_en_clicked}>EN</a>
			<h1>BankSim</h1>
			<Controls year = {this.state.year} onSimulate={this.simulateClicked}/>
			<Parameters params={this.microeconomy.params} onChange={this.handleParamChange} />
			</div>
		);
	}
 }

ReactDOM.render(
  <Simulator numbanks="10"/>,
  document.getElementById('app')
);

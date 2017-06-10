import React from 'react';
import ReactDOM from 'react-dom';

import $ from 'jquery';
import Highcharts from 'highcharts';

const instr_en = require('./english.md');
const instr_de = require('./german.md');


import {randomize, randomizeInt, assert} from './helper.coffee';
import {MicroEconomy} from './microeconomy.js';
import {TrxMgr} from './trxmgr.js'

const DFLT_LANG = 'DE';

var LANG = DFLT_LANG;
const NUM_BANKS = 3;

const i18n = {
  'Controls': 'Steuerung',
  'Parameters': 'Parameter',
  'Year': 'Jahr',
  'Simulate': 'Simulieren',
  'Instructions': 'Anleitung',
  'Prime Rate': 'Leitzins',
  'Prime Rate Deposits': 'Leitzins Reserven',
  'Loan Interest': 'Kreditzinsen',
  'Deposit Interest': 'Guthabenszinsen Zahlungskonto',
  'Deposit Interest Savings': 'Guthabenszinsen Sparkonto',
  'Number of Transactions': 'Anzahl Transaktionen',
}

var __ = function(en) {

  if(LANG == 'EN') {
    return en 
  } else {
    return i18n.hasOwnProperty(en) ? i18n[en] : 'TODO:' + en;
  }
}

class Slider extends React.Component {

  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
    this.options = this.props.options || {};
    this.min = this.options.min || 0;
    this.max = this.options.max || 100;
    this.step = this.options.step || 0.1;
    this.percent = !(this.options.percent == false); // percent is default
  }

  handleChange(event) {
    let val = this.percent? event.target.value/100 : event.target.value;
    this.props.onChange(this.props.name, val);
  }

  render() {
    let paramVal = this.props.params[this.props.name];
    let displayVal = this.percent? (paramVal * 100).toFixed(1): paramVal

    return (
    <div className='form-group form-group-sm'>
        <label htmlFor={this.props.name} className='control-label'> {this.props.label} </label>
        <div className='input-group'>
          <input 
            id={this.props.name} 
            className='form-control input-sm'
            name={this.props.name} 
            type="range" 
            min={this.min}
            max={this.max}
            step={this.step}
            value={displayVal} 
            onChange={this.handleChange} />
          <span className='input-group-addon'>
            {displayVal} {this.percent? '%' : ''} 
          </span>      
        </div>
    </div>
    );
  }
}

class Parameters extends React.Component {

  constructor(props) {
    super(props);
    this.handleParamChange = this.handleParamChange.bind(this);
    this.state = {
      params: this.props.params
    }
  }

  handleParamChange(p, val) {
    // console.log(`handle change ${p} ${val}`);
    this.props.params[p] = val;
    this.setState({params: this.props.params});
  }

  getSlider(id, label, options) {
    return (<Slider 
              name={id} 
              params={this.props.params} 
              label={label} 
              onChange={this.handleParamChange} 
              options = {options}
            />);
  }

  render() {
    return(
    <form >
      <div id = "params">
        <h2>{__('Parameters')}</h2>
        {this.getSlider('num_trx', __("Number of Transactions"), {step: 1, percent: false})}
        {this.getSlider('prime_rate', __("Prime Rate"))}
        {this.getSlider('prime_rate_giro', __("Prime Rate Deposits"))}
        {this.getSlider('credit_interest', __('Loan Interest'))}
        {this.getSlider('deposit_interest', __('Deposit Interest'))}
        {this.getSlider('deposit_interest_savings', __('Deposit Interest Savings'))}
      </div>
    </form>
    );
  }
 }
      
class Controls extends React.Component {
  render() {
    return (
      <div id="controls" >
      <h2>{__("Controls")}</h2>
      <div>{__("Year")}: {this.props.year}</div>
      <button 
        id="simulate" 
        className="btn btn-primary btn-block" 
        type="button" 
        onClick={this.props.onSimulate}>
          {__("Simulate")}
      </button>
      </div>
    );
  }
}

class Simulator extends React.Component {
  constructor(props) {
    super(props);
    this.microeconomy = new MicroEconomy(NUM_BANKS);
    this.trx_mgr = new TrxMgr(this.microeconomy);

    this.lang_en_clicked= this.lang_en_clicked.bind(this);
    this.lang_de_clicked= this.lang_de_clicked.bind(this);
    this.simulateClicked = this.simulateClicked.bind(this);

    this.state = {
      year: 0,
      lang: DFLT_LANG,
    }
  }
  
  // componentDidMount() {
  // componentDidUpdate() {

  lang_en_clicked() {
    LANG = 'EN';
    this.setState({lang: 'EN'});
  }

  lang_de_clicked() {
    LANG = 'DE';
    this.setState({lang: 'DE'});
  }

  simulateClicked(){
    this.trx_mgr.one_year()
    this.setState((prevState, props) => ({
      year: prevState.year + 1
    }));
  }

  render() {
    return(
    <div id="simulator">
      <div className="row">
        <div className="col-md-8"> 
          <Instructions lang={this.state.lang} />
          <div className="btn-group">
            <a href="#" 
              className="btn btn-primary" 
              data-toggle="modal" 
              data-target=".instr_modal">{__("Instructions")}
            </a>
            <a href="#" 
              className="btn btn-default"  
              onClick = {this.lang_de_clicked}>DE</a>
            <a href="#" 
              className="btn btn-default" 
              onClick = {this.lang_en_clicked}>EN</a>
          </div> 
          <h1>BankSim</h1>
          <MicroEconomyViewer 
            me={this.microeconomy}/>
        </div>
        <div className="col-md-4"> 
          <Controls 
            year = {this.state.year} 
            onSimulate={this.simulateClicked}
          />
          <Parameters 
            params={this.microeconomy.params} 
          />
        </div>
      </div> 
    </div>
    );
  }
 }

class Instructions extends React.Component {
  constructor(props) {
    super(props);
  }
  
  get_instr() {
    return { __html: this.props.lang =='EN'? instr_en : instr_de };
  }

  render() {
    return (
    <div>
      <div className="instr_modal modal fade">
        <div className="modal-dialog modal-lg">
          <div className="modal-content">
            <div className="modal-header">
              <button type="button" 
                className="close" 
                data-dismiss="modal" 
                aria-label="Close">
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
            <div id="instructions" dangerouslySetInnerHTML={this.get_instr()}></div>
          </div>
        </div>
      </div>
    </div>
    );
  }
}
class MicroEconomyViewer extends React.Component {
  constructor(props) {
  super(props);
  }
  
  getData() {
    let data = [];
    let nonbanks = this.props.me.nonbanks;
    nonbanks.forEach( (nb, index) => {
      data.push({name: index, data: [nb.deposit]});
    });
    return data;
  }

  componentDidMount() {
    let data = this.getData();
    this.options = {
      series: data,
      chart: {type: 'column'},
      title: {text: ''},
      plotOptions: {series: {animation: false}}
    };

    Highcharts.chart("chart1", this.options);
  }

  componentDidUpdate() {
    let data = this.getData();
    this.options.series = data;
    Highcharts.chart("chart1", this.options);
  }

  render() {
    return (<div id="chart1" className="chart"> Hello Chart! </div>);
  }
}

ReactDOM.render(
  <Simulator />,
  document.getElementById('app')
);

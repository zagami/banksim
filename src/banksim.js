import React from 'react';
import ReactDOM from 'react-dom';

import $ from 'jquery';
import Highcharts from 'highcharts';

const instr_en = require('./english.md');
const instr_de = require('./german.md');


import {randomize, randomizeInt, assert} from './helper.coffee';
import MicroEconomy from './microeconomy';
import TrxMgr from './trxmgr.coffee'

const DFLT_LANG = 'DE';

var LANG = DFLT_LANG;
const NUM_BANKS = 3;

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
          <input 
            type="range" 
            name={this.props.name} 
            value={(this.props.params[this.props.name]*100).toFixed(1)} 
            onChange={this.handleChange} />
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
      <h2>{__('Parameters', 'Parameter')}</h2>
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
      <h2>{__("Controls", "Steuerung")}</h2>
      <div>{__("year", "Jahr")}: {this.props.year}</div>
      <button 
        id="simulate" 
        className="btn btn-primary btn-block" 
        type="button" 
        onClick={this.props.onSimulate}>
          {__("Simulate", "Simulieren")}
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
  
  // componentDidMount() {
  // componentDidUpdate() {

  handleParamChange(p, val) {
    //console.log(`handle change ${p} ${val}`);
    this.microeconomy.params[p] = val;
    this.setState({params: this.microeconomy.params});
  }


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
  get_instr() {
   return { __html: this.state.lang =='EN'? instr_en : instr_de };
  }
  render() {
    console.log("render");
    return(<div id="simulator">
      <div className="row">
      <div className="col-md-12"> 
      <div className="btn-group">
        <a href="#" 
          className="btn btn-default" 
          data-toggle="modal" 
          data-target=".instr_modal">{__("Instructions", "Anleitung")}
        </a>
        <a href="#" 
          className="btn btn-default"  
          onClick = {this.lang_de_clicked}>DE</a>
        <a href="#" 
          className="btn btn-default" 
          onClick = {this.lang_en_clicked}>EN</a>
      </div> 
      </div>
      </div>
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
      <h1>BankSim</h1>
      <Controls 
        year = {this.state.year} 
        onSimulate={this.simulateClicked}/>
      <Parameters 
        params={this.microeconomy.params} 
        onChange={this.handleParamChange} />
      <MicroEconomyViewer 
        me={this.microeconomy}/>
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

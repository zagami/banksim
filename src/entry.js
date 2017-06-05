require('./banksim.js');

var html = require('./english.md');
var container = document.getElementById("instructions_english");
container.innerHTML = html;

var html = require('./german.md');
var container = document.getElementById("instructions_german");
container.innerHTML = html;


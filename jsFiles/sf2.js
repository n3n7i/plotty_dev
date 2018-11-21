
// JS_uFerret

function objMain(){
  this.data = [];
  this.data.push(document.body);
  this.push = function(elem) { this.data.push(document.createElement(elem)); }
  this.append = function(id) { this.data[0].appendChild(this.data[id]); }
  this.end = function() { return this.data.length-1; }
  return(this);
  }

var xferret = new objMain();


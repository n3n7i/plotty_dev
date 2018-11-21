
// JS_xcontrol

var pointdata = [];

function xcon_obj(){
  this.x1=0;
  this.y1=0;
  this.x2=0;
  this.y2=0;
  this.xbutton=0;
  this.up = function(inp) { 
				if(inp.length == 5){
					if((inp[4] !== this.xbutton) && (inp[4]!==0)) pointdata.push([this.x1, this.y1, this.x2, this.y2, inp[4]]);
					this.x1 += inp[0]/300; this.y1 += inp[1]/300; this.x2 += inp[2]/300; this.y2 += inp[3]/300; this.xbutton = inp[4]; 
					tri_marker();
					refreshAttribs();
					} }
  return(this);
  }
  
var xcon = new xcon_obj();

var gt;

var parsestr = "0123456789ABCDEF";

  
function inp_reader(o){
  var t = o.target.value.split(' ');
  for(var i=0; i<t.length; i++){
	 t[i] = xparse(t[i]);
    }
  xcon.up(t);
  o.target.value = "";
  gt = t;
  //xparse(t);
  }
  
function xparse(ts){
  //n = t.length;
  //gt = n;
  var x = parsestr.indexOf(ts[0]) - parsestr.indexOf(ts[1]); 
  return(x); 
  }
	
function xcon_init(){
  if(xferret){
    xferret.push("input");
	var i = xferret.end();
	xferret.append(i);
	xferret.data[i].onchange = inp_reader;
    }
  }
  
function tri_marker(){
  if(xgl){
    jp2[0][0] = xcon.x1;
	jp2[0][1] = xcon.x1;
	jp2[0][2] = xcon.x1 + 0.2;
	
    jp2[1][0] = xcon.y1;
	jp2[1][1] = xcon.y1 + 0.2;
	jp2[1][2] = xcon.y1;
	
    jp2[2][0] = xcon.x2 + 0.2;
	jp2[2][1] = xcon.x2;
	jp2[2][2] = xcon.x2;
	
	jp2[6][0] = 1;
	jp2[6][1] = 1;
	jp2[6][2] = 1;
    }
  }

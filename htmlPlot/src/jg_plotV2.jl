
##-----------------------

function jmesh(d1=10, d2=10, d3=10)
  n = zeros(3, d1 * d2 * d3);
  ni = 1;
  for iterx = 1:d1
    for itery = 1:d2
      for iterz = 1:d3        
        n[:, ni] = [iterx itery iterz];
        ni += 1;
        end;
      end;
    end;
  return(n);
  end;


function jnorm3a(xmat)
  ret = similar(xmat);
  rmin = minimum(xmat);
  rmax = maximum(xmat);
  ret = (xmat .- rmin) ./ (rmax .- rmin);
  return(ret);
  end;
  


function jg_plot(fidx, vm; kblimit = [100, 20]);

  nes = [size(vm,1), size(vm,2)];
  n2 = 2.0 ./ nes[2];
  fid = open("./$(fidx).html", "w");
  
  xmat = zeros(7, nes[1]*(nes[2]-1));
  
  xvec = zeros(1, nes[1]*(nes[2]-1)*2); 
  
  z1step = nes[2]<=kblimit[1] ? 1 : round(Int32,nes[2]/kblimit[1])+1;
  z2step = nes[1]<=kblimit[2] ? 1 : round(Int32,nes[1]/kblimit[2])+1;
  
  vm2 = 2.0 .* jnorm3a(vm) .- 1;
  c = 0;
  d = 0;
  for itery = 1:z2step:nes[1]
    randcol = [2.4 .*rand(3); 0.5 + rand(1)/2] ./ 3.0;
    rcc  = [rand(3); 3.0 + rand(1)/2] ./ 5.0;
	
      p1 = [-1.0+n2; vm2[itery, 1]; 0; rcc]; #randcol .+ rcc];
      xmat[:, c+1] = p1;
      xvec[1, d+1] = c+1;
	
      c += 1;
      d += 1;
	
    for iterx = z1step+1:z1step:nes[2]
    
      randcolb = [rand(3); 3.0 + rand(1)/2] ./ 5.0;
      ##write(fid, rsline((iterx-1)*n2[2], vm2[itery, iterx-1], iterx*n2[2], vm2[itery, iterx], 1, "#f00"));	  
	  
      p2 = [-1.0+iterx*n2; vm2[itery, iterx]; 0; 1.2 .- (randcol .+ randcolb)];
      rcc = 1.1 .- (randcol .+ randcolb); ##randcolb;

      xmat[:, c+1] = p2;
      xvec[1, d+1] = c+1;
      xvec[1, d+2] = c+1;	  

      c+= 1;
      d+= 2;
      end;
	  
    xvec[1, d+1] = c;
    d += 1;
    end;
  
  webgmat = xmat[:, 1:c];
   
  webxvec = xvec[:, 1:d];
  
  write(fid, webBlock.webstring(webgmat, webxvec, modesel = "L"));
  #write(fid, rsend(" min $(minimum(vm)) <br> max $(maximum(vm))"));
  close(fid);
  #return(webgmat);
  end;


function jg_plotMesh(fidx, vm, rstr = false, ms = "P");

  nesM = maximum(vm, dims=2) .- minimum(vm, dims=2) .+ 1;

  nM = 2.0 ./ nesM;
  
  xmat = zeros(7, size(vm, 2));

  xmat[1:3, :] = (vm .* nM) .- 1.0;

  #xmat[3, :] = (xmat[3, :] .+ 1) ./ 2;

  xmat[4:7, :] = rand(4, size(vm,2));

#  println(xmat[1:3, 1:3]);

#  halt();

  vx = size(xmat,2);
  
  xvec = zeros(1, vx);
  
  xvec[:] = collect(1:vx) .- 1.0;

  if(!rstr)

    fid = open("./$(fidx).html", "w");

    write(fid, webBlock.webstring(xmat, xvec, modesel="P"));

    close(fid);

    else

    return(webBlock.webstring(xmat, xvec, modesel=ms));

    end;

  end;



function jg_plotMeshC(fidx, vm, vr, rstr = false, ms = "P");

  xwid = size(vm, 1);

  nesM = maximum(vm, dims=2) .- minimum(vm, dims=2) .+ 1;

  nM = 2.0 ./ nesM;
  
  xmat = zeros(7, size(vm, 2));

  xmat[1:3, :] = (vm[1:3,:] .* nM[1:3]) .- 1.0;
  
  xmat[4:xwid, :] = vm[4:xwid,:];

  #xmat[3, :] = (xmat[3, :] .+ 1) ./ 2;

  xmat[xwid+1:7, :] = rand(7-xwid, size(vm,2));

  println(xmat[1:3, 1:3]);

#  halt();

  vx = size(xmat,2);
  
  xvec = vr; ##zeros(1, vx);
  
  ##xvec[:] = collect(1:vx);

  if(!rstr)

    fid = open("./$(fidx).html", "w");

    write(fid, webBlock.webstring(xmat, xvec, modesel="P"));

    close(fid);

    else

    return(webBlock.webstring(xmat, xvec, modesel=ms));

    end;

  end;



##-----------------------

module webBlock

function make_Julson(mat, parsx = x->x, parsr = x->x, r2 = false)
  nd = ndims(mat);
  println("ndims: $nd ");
  
  jstr = "";
  pr2 = parsx;
  if(nd == 2)
    jstr = jstr * "\"[" 
    for iter = 1:size(mat, 1)
      if((iter == 4) & (r2)) pr2 = parsr; end;
      jstr = jstr * "[" * join(map(x->"$(pr2(x))", mat[iter, :]), ",") * "],";
      end;
    jstr = jstr[1:end-1] * "]\"";
    end;
  return(jstr);
  end;


function webstring(tkinp, tkinp2; modesel = "P", wmod = 600, hmod = 600)

tkstr = make_Julson(tkinp, x->round(x, sigdigits=4), x->round(x, sigdigits=2), true);

println(size(tkinp2));

tkstr2 = make_Julson(tkinp2);

webgl = """

<script>

detlen = jp2[0].length;

alert(ji[0].length);

var xgl;
var xprog;

var xmode = "$modesel";

var xmpriv;

function createShader(gl, type, source) {
  var shader = gl.createShader(type);
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  var success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
  if (success) {
    return shader;
  }

  console.log(gl.getShaderInfoLog(shader));
  gl.deleteShader(shader);
}

function createProgram(gl, vertexShader, fragmentShader) {
  var program = gl.createProgram();
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);
  gl.linkProgram(program);
  var success = gl.getProgramParameter(program, gl.LINK_STATUS);
  if (success) {
    return program;
  }

  console.log(gl.getProgramInfoLog(program));
  gl.deleteProgram(program);
}


function myAttrib_Buffer(gl, program, atname, atdata, atstep){

  var positionAttributeLocation = gl.getAttribLocation(program, atname); //"a_position");

  var positionBuffer = gl.createBuffer();

  gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

  var positions = atdata; //jp[0]; 
    
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

  gl.enableVertexAttribArray(positionAttributeLocation);

  var size = atstep; //2;          // 2 components per iteration;
  var type = gl.FLOAT;   // the data is 32bit floats;
  var normalize = false; // don't normalize the data;
  var stride = 0;        // 0 = move forward size * sizeof(type) each iteration to get the next position;
  var offset = 0;        // start at the beginning of the buffer;

  gl.vertexAttribPointer(positionAttributeLocation, size, type, normalize, stride, offset);
  }
  
  
function myUniform_Buffer(gl, program, atname, atdata, atcount){
  var colorUniformLocation = gl.getUniformLocation(program, atname); //"u_color");//
  var color = atdata; //jp[1];//
    // set the color;//
  gl.uniform1fv(colorUniformLocation, color, atcount); //30);//
}

function refreshAttribs(){

  myAttrib_Buffer(xgl, xprog, "x_position", jp2[0], 1);
  myAttrib_Buffer(xgl, xprog, "y_position", jp2[1], 1);
  myAttrib_Buffer(xgl, xprog, "z_position", jp2[2], 1);
  
  myAttrib_Buffer(xgl, xprog, "red_colour",   jp2[3], 1);
  myAttrib_Buffer(xgl, xprog, "green_colour", jp2[4], 1);
  myAttrib_Buffer(xgl, xprog, "blue_colour",  jp2[5], 1);
  myAttrib_Buffer(xgl, xprog, "alpha_colour", jp2[6], 1);
}

function main(xparam) {
  // Get A WebGL context //
  var canvas = document.getElementById("c");
  
  var devicePixelRatio = window.devicePixelRatio || 1;

  // set the size of the drawingBuffer based on the size it's displayed.//
  canvas.width = canvas.clientWidth * devicePixelRatio;
  canvas.height = canvas.clientHeight * devicePixelRatio;
  
  
  var gl = canvas.getContext("webgl", { preserveDrawingBuffer: true });
  if (!gl) {
    return;
  }

  xgl = gl;

  // Get the strings for our GLSL shaders//
  var vertexShaderSource = document.getElementById("2d-vertex-shader").text;
  var fragmentShaderSource = document.getElementById("2d-fragment-shader").text;

  // create GLSL shaders, upload the GLSL source, compile the shaders//
  var vertexShader = createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);
  var fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);

  // Link the two shaders into a program//
  var program = createProgram(gl, vertexShader, fragmentShader);

  xprog = program;

    // Clear the canvas//
  gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA); //(gl.SRC_ALPHA, gl.ONE);//
  gl.enable(gl.BLEND);
  
  gl.depthFunc(gl.GEQUAL);  
  gl.enable(gl.DEPTH_TEST);


  //gl.enable(gl.POINT_SMOOTH);/

  gl.clearDepth(0.0);    
  gl.clearColor(0.4, 0.4, 0.4, 1.0);
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

  // Tell it to use our program (pair of shaders)
  gl.useProgram(program);


  myUniform_Buffer(gl, program, "uxy_rot", [0.5], 1);
  myUniform_Buffer(gl, program, "uyz_rot", [1.6], 1);
  myUniform_Buffer(gl, program, "uzx_rot", [0.0], 1);

  myUniform_Buffer(gl, program, "user_x", [0.0], 1);
  myUniform_Buffer(gl, program, "user_y", [0.0], 1);
  myUniform_Buffer(gl, program, "user_z", [0.0], 1);


  //Attrib buffer
  //attribute float y_position;
  //attribute float red_colour;
  
  myAttrib_Buffer(gl, program, "x_position", jp2[0], 1);
  myAttrib_Buffer(gl, program, "y_position", jp2[1], 1);
  myAttrib_Buffer(gl, program, "z_position", jp2[2], 1);



  //myAttrib_Buffer(gl, program, "point_colour", jp[2], 1);
  
  myAttrib_Buffer(gl, program, "red_colour",   jp2[3], 1);
  myAttrib_Buffer(gl, program, "green_colour", jp2[4], 1);
  myAttrib_Buffer(gl, program, "blue_colour",  jp2[5], 1);
  myAttrib_Buffer(gl, program, "alpha_colour", jp2[6], 1);

  gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

  // draw
  var primitiveType;
  if(xmode == "P"){
    primitiveType = gl.POINTS;}
  if(xmode == "L"){
    primitiveType = gl.LINES;}
  if(xmode == "T"){
    primitiveType = gl.TRIANGLES;}
 
  xmpriv = primitiveType;
  var offset = 0;
  var count = xparam;
  gl.drawArrays(primitiveType, offset, count);  
}

main(detlen);

var xoffset =0;
var xoffcount= 10;

requestAnimationFrame(MyDraw);

var rx = 0, rx_d = 0.002;
var ry = 0, ry_d = 0.004;
var rz = 0, rz_d = 0.006;

var ux = 0;
var uy = 0;
var uz = 0;

var cB_en = true, dB_en = true;

function MyDraw(){

  xgl.clear(xgl.COLOR_BUFFER_BIT*cB_en | xgl.DEPTH_BUFFER_BIT*dB_en);

  rx += rx_d;
  ry += ry_d;
  rz += rz_d;


  myUniform_Buffer(xgl, xprog, "uxy_rot", [rx], 1);
  myUniform_Buffer(xgl, xprog, "uyz_rot", [ry], 1);
  myUniform_Buffer(xgl, xprog, "uzx_rot", [rz], 1);

  myUniform_Buffer(xgl, xprog, "user_x", [ux], 1);
  myUniform_Buffer(xgl, xprog, "user_y", [uy], 1);
  myUniform_Buffer(xgl, xprog, "user_z", [uz], 1);
  

  //var primitiveType = xgl.POINTS;
  xoffset = (xoffset + xoffcount) % detlen; //modifiers!
  var offset = 0; //xoffset; //0
  var count = detlen; //detlen - offset; //detlen
  xgl.drawArrays(xmpriv, offset, count);

  requestAnimationFrame(MyDraw);
  }



</script>

""";

webshaders = """

<script id="2d-vertex-shader" type="notjs">

  // an attribute will receive data from a buffer

  varying vec4 fade_colour;

  attribute float x_position;
  attribute float y_position;
  attribute float z_position;

  attribute float red_colour;
  attribute float green_colour;
  attribute float blue_colour;
  attribute float alpha_colour;

  uniform float uxy_rot;
  uniform float uyz_rot;
  uniform float uzx_rot;

  uniform float user_x;
  uniform float user_y;
  uniform float user_z;

  
  float p1;
  float p2;

  float p1b;
  float p2b;

  float p1c;
  float p2c;

  vec3 npos;

  mat3 nr_mat;
  mat3 nr_matb;
  

  // all shaders have a main function
  void main() {

    // gl_Position is a special variable a vertex shader
    // is responsible for setting

    p2 = sin(uxy_rot);
    p1 = cos(uxy_rot);


    p2b = sin(uyz_rot);
    p1b = cos(uyz_rot);


    p2c = sin(uzx_rot);
    p1c = cos(uzx_rot);

    npos = vec3(x_position + user_x, y_position + user_y, z_position+ user_z);

    npos = npos * mat3(p2, -p1, 0,   p1, p2, 0,      0, 0, 1);

    npos = npos * mat3(1, 0, 0,      0, p2b, -p1b,   0, p1b, p2b);

    npos = npos * mat3(p1c, 0, p2c,   0, 1, 0,        p2c, 0, -p1c);

    npos = npos + vec3(0.0, 0.0, 2.5);

    //nr_mat = mat3(p2*p1c, -p1, p2c,   p1, p2*p2b, -p1b,      p2c, p1b, -p1c*p2b);


    //npos = npos * nr_mat;

      //npos = (npos * mat3(p1c, 0, p2c,   0, 1, 0,        p2c, 0, -p1c)) * mat3(1, 0, 0,      0, p2b, -p1b,   0, p1b, p2b);

//    gl_Position = vec4(x_position / z_position, y_position / z_position, z_position - 2.0, 1.0);
    fade_colour = vec4(red_colour, green_colour, blue_colour, alpha_colour);

    gl_Position = vec4(npos.x/npos.z, npos.y/npos.z, (1.0/abs(npos.z)), 1.0);


    gl_PointSize = 5.0; // / (10.0 * npos.z) + 5.0;


    }

</script>
<script id="2d-fragment-shader" type="notjs">

  // fragment shaders don't have a default precision so we need
  // to pick one. mediump is a good default
  precision mediump float;
  
varying vec4 fade_colour;
float xdist;
float ss;

void main() {
   xdist = distance(gl_PointCoord, vec2(0.2, 0.2));
   ss = 1.0 - clamp(0.0, 1.0, smoothstep(0.3, 0.6, xdist));
   if(ss <= 0.3){ discard; }
   gl_FragColor = vec4(fade_colour.rgb, clamp(0.0, 1.0, ss*fade_colour.a));
}
  </script> """;

  
  
webPack = """

function UnpackData(dmat, indvec){
  narry = [[], [], [],  [], [], [], []];
  indlen = indvec[0].length;
  ddep = dmat.length;
  for(i = 0; i<indlen; i++){
    for(j = 0; j<ddep; j++){
	  narry[j][i] = dmat[j][indvec[0][i]];
	  }
	}
  return(narry);
  }
  
""";
  
myhtml = """
<!DOCTYPE html>
<html>
<body bgcolor=#fff>
<canvas id="c" width=$(wmod) height=$(hmod)></canvas>

<script> 
var jstr = $tkstr;
var jp = JSON.parse(jstr);

var jstr2 = $tkstr2;
var ji = JSON.parse(jstr2);

$webPack

jp2 = UnpackData(jp, ji);

</script>

$webshaders

$webgl

<script src="./jsFiles/sf2.js"></script>
<script src="./jsFiles/xcon.js"> </script>

</body></html>
""";

return(myhtml);

end;

end;

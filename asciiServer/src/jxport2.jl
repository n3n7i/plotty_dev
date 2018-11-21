

module zport

 mutable struct xport_I  ##mutable struct xport_I ## type

  sock;
  r1::Bool;
  r2::Bool;
  compsend::Bool;
  comprec::Bool;
  rstr::String; 
  rstrB::String; 
  rmode::Int32;
  iter::Int32;

  xport_I(sock) = new(sock, false, false, false, false, " ", " ", -1, 0);

  end;

 end;


##module yport

using Sockets;


global Cgraphdata = "";

global Xruntime = Dict{String, String}();

global Xpostcontrol = Dict{String, Function}();


function cgSet(xstr)

  global Cgraphdata = xstr;
  end;


function xrSet(xkey, xstr)

  global Xruntime[xkey] = xstr;
  end;
  
  
  
function readzx(xp)

  return String(readavailable(xp));

  end;  


function taskport(addr=8088, xresp=xdef)

  tp = @task jlportZ2(addr, xdef);

  schedule(tp);

  yield();

  return(tp);

  end;



function jlportZ2(addr = 8088, xresp = xdef)

 server = listen(addr);

   while isopen(server)

     local xp = zport.xport_I(accept(server));

     while isopen(xp.sock)

       p1 = false;

       println("Read ready!");

       r = String(readavailable(xp.sock));

       println(r);
	   
	   xp.rstr = r;

       println("Read break");

       if iswritable(xp.sock)

         println("Write ready!");

         line1 = split(r, "\n")[1];

         println("  Resp?: $line1");

         (g1, p1, rt) = typedet(line1);

         if(rt == 99) println("exit server!"); close(server); return; end;

         println("get $g1 post $p1 type $rt");


         if(xresp(xp, [g1 p1 rt], line1)) 

           end;  #reset(xp.sock); mark(xp.sock); 

         end;

       if(!isreadable(xp.sock) & !iswritable(xp.sock)) println(" halted"); end;

       if(!p1) println(" no post"); xhalt = true; end;       

       println("read/write complete?");

       close(xp.sock);

       end;

    println(" socket complete?");

    end;

  println(" server complete?")

  return(server);

  end;


xembed = """
<svg height="60" width="60" style="border: 0px solid black;">
<rect x="0" y="0" rx="16" ry="16" width="60" height="60" style="fill:orange;" />
  <circle cx="30" cy="18" r="14" fill="red" stroke="white" stroke-width="2"/>
  <circle cx="18" cy="40" r="14" fill="green" stroke="white" stroke-width="2"/>
  <circle cx="42" cy="40" r="14" fill="purple" stroke="white" stroke-width="2"/>
  </svg> 
""";

xrSet("Julia_Logo", xembed);

pdef = x-> println("\n\nXpc: " * parsePost(x.rstr)[1][1]);
 
Xpostcontrol["def"] = pdef;

function parsePost(nstr)
  xstr = split(nstr, "\n")[end];
  fields = split(xstr, "&");
  fields = split.(fields, "=");
  return fields;
  end;



function xdef(xpr, m1, m2)

  println("$m1, $m2");

  r = false;

  println("Settings: $m1 $m2");

  if((m1[3]==1) & (m1[1] == 1))  write(xpr.sock, stock_Resp()*"\r\n\n");  r =true; println("\n HTml out?"); end;        ##HTML request

  if((m1[3]==77) & (m1[1] == 1))  write(xpr.sock, post_Resp(xembed)*"\r\n\n");  r =true; println("\n HTml out?"); end;        ##HTML request
  
  if((m1[3]==88) & (m1[1] == 1))

    m3 = split(split(m2, " ")[2], "/")[end];
	if(haskey(Xruntime, m3))
      write(xpr.sock, post_Resp(Xruntime[m3])*"\r\n\n");  r =true; println("\n HTml out?"); 
      end;
	end;
	


  if((m1[3]==1) & (m1[2] == 1))

	  Xpostcontrol["def"](xpr);

	  write(xpr.sock, post_Resp("[Iframe data]")*"\r\n\n"); r=true;  end;  ##HTML form submit

  if((m1[3]==5) & (m1[1] == 1))  write(xpr.sock, stock_RespX(Cgraphdata, "text/html")*"\r\n\n"); r=true; end;  ##Graph request

  if((m1[3]==6) & (m1[1] == 1))  write(xpr.sock, stock_RespX(fresp(split(m2, " ")[2]), "application/javascript")*"\r\n\n"); r=true; end;  ##File request

  if((m1[3]==7) & (m1[1] == 1))  xdata = frespB(split(m2, " ")[2]); print(xpr.sock, stock_RespX(xdata, "image/x-icon", length(xdata)) );
##  flush(xpr.sock);
##  print(xpr.sock, xdata); r=true; 
  r=true; end;  ##Binary File request


  flush(xpr.sock);

  return(r);

  end;


reqtype = Dict([("Html", 1), ("EVENT", 2), ("WEBSOCK", 3), ("XML", 4), ("Graph", 5), (".js", 6), (".txt", 6), (".jpg", 7), ("Embed", 77), ("Run", 88), ("Exit", 99)]); 


function typedet(msg1) 

  r1 = false;
  rettype = -1;

  c2 = occursin( "POST", msg1);
  c1 = occursin("GET", msg1);

  if(c1 | c2)
    r1 = true;

    for iter = keys(reqtype)

      retbool = occursin(iter, msg1);
      if(retbool) rettype = get(reqtype, iter, -1); end;
      end;
    end;
      
  return(c1, c2, rettype);
  end;


function stock_Resp()

cont = """
<html>
<body>
<h1>Hello, World!</h1>
 <form Method="post" target="xWin" accept-charset="utf-8">
  First name:<br>
  <input type="text" name="firstname" value="Mickey"><br>
  Last name:<br>
  <input type="text" name="lastname" value="Mouse"><br><br>
  <input type="submit" value="Submit">
</form> 
<iframe id="xWin" name="xWin" style=""></iframe>

<script src="./jsFiles/sf2.js"></script>
<script src="./jsFiles/xcon.js"> </script>

</body>
</html>
""";

data = """
\r
HTTP/1.1 200 OK\r
Date: Mon, 27 Jul 2009 12:28:53 GMT\r
Server: Apache/2.2.14 (Win32)\r
Last-Modified: Wed, 22 Jul 2009 19:15:56 GMT\r
Retry-After: 2 \r
Content-Length: $(sizeof(cont))\r
Content-Type: text/html\r
Connection: close\r

$cont
""";

return(data);

end;


function fresp(field1)

  z = "";

  if(isfile("."*field1)) 

    println("File found! ", "."*field1);  

    fid = open("."*field1, "r");

    z = String(read(fid));

    close(fid);

    end;

  return(z);

  end;


function frespB(field1)

  z = "";

  if(isfile("."*field1)) 

    println("File found! ", "."*field1);  

    fid = open("."*field1, "r");

    z = read(fid);

    close(fid);

    end;

  return(z);

  end;



function stock_RespX(xhtml, xmime = "text/html", orval = 0)

data = """
\r
HTTP/1.1 200 OK\r
Date: Mon, 27 Jul 2009 12:28:53 GMT\r
Server: Apache/2.2.14 (Win32)\r
Last-Modified: Wed, 22 Jul 2009 19:15:56 GMT\r
Retry-After: 2 \r
Content-Length: $(orval>0 ? orval : length(xhtml)) \r
Content-Type: $(xmime) \r
Connection: close\r

$xhtml
\r
""";

return(data);

end;


function post_Resp(xhtml = "")

  data = """
\r
HTTP/1.1 200 OK\r
Content-Length: $(length(xhtml)) \r
Content-Type: text/html\r
Retry-After: 2 \r
Connection: close\r

$xhtml
\r
""";
  return(data);
  end;

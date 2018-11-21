
module test1;

 function test(x, y, am)
   return (x*(1-am) + y*am);
   end;

 function test2(x,y,z, am)
   return test( test(x,y,am), test(y,z,am), am);
   end;

 function test1x1(w1, w2, x1, x2, am1, am2)
   return test( test(w1, w2, am1), test(x1, x2, am1), am2);
   end;
 
 function test2x2(x1,y1,z1, x2,y2,z2, x3,y3,z3, am1, am2)
   return test2( test2(x1,y1,z1, am1), test2(x2,y2,z2, am1), test2(x3,y3,z3, am1), am2 );
   end;

 end;


module n3bezier;

 export point3d, surf2control;

 struct point3d{T}
   x::T; ##Float64;
   y::T; ##Float64;
   z::T; ##Float64;
   end;

## abstract type xpoint <: point3d end;

 function xpoint3d(n)
   return point3d(n...);
   end;
 
 function bline(x, y, am)
   println("scalar+ bline");
   println(typeof(x));
   return (x.*(1 .-am) .+ y.*am);
   end;

 function bline(x::point3d, y::point3d, am) ## where {T<:point3d}
   println("point_bline");
   return point3d( bline(x.x, y.x, am), bline(x.y, y.y, am), bline(x.z, y.z, am) ); ##   return (x*(1-am) + y*am);
   end;

 function bquad(x,y,z, am)
   println("bquad");
   return bline( bline(x,y,am), bline(y,z,am), am);
   end;

 function bquad(x::point3d{T},y::point3d{T},z::point3d{T}, am) where {T}
   println("point bquad");
   return bline( bline(x,y,am), bline(y,z,am), am);
   end;   
   
 function blgon(w1, w2, x1, x2, am1, am2)
   return bline( bline(w1, w2, am1), bline(x1, x2, am1), am2);
   end;
 
 function bqgon(x1,y1,z1, x2,y2,z2, x3,y3,z3, am1, am2)
   println("Standard!!");
   return bquad( bquad(x1,y1,z1, am1), bquad(x2,y2,z2, am1), bquad(x3,y3,z3, am1), am2 );
   end;

 function bqgon(x1::point3d{N},y1,z1, x2,y2,z2, x3,y3,z3, am1, am2) where {N} ##, T::point3d{N}} ##where {N}
   println("Specialized!");
   xs = bqgon(x1.x, y1.x, z1.x, x2.x, y2.x, z2.x, x3.x, y3.x, z3.x, am1, am2);
   ys = bqgon(x1.y, y1.y, z1.y, x2.y, y2.y, z2.y, x3.y, y3.y, z3.y, am1, am2);
   zs = bqgon(x1.z, y1.z, z1.z, x2.z, y2.z, z2.z, x3.z, y3.z, z3.z, am1, am2);
   
   return point3d.(xs, ys, zs);
   end;

 function bqgonx(x1::T, x2::T) where {T<:point3d}
   println("Point3d!");
   end;

 function bqgonx(x1::point3d, x2)
   println("!!");
   end;


 function bqgonx(x1, x2)
   println(typeof(x1));
   println("??");
   end;

# function (x::point3d{T})(z::T) where{T}
#   return point3d(x.x + z, x.y + z, x.z + z);
#   end;

 function (p::point3d{T})(x::T, y::T, z::T) where{T}
   return point3d(p.x + x, p.y + y, p.z + z);
   end;

 function (p::point3d{T})(x::T2, y::T2, z::T2) where{T, T2}
   return point3d(p.x + x, p.y + y, p.z + z);
   end;

 function pointmap(xp)
   n = size(xp);
   x = zeros(n);
   z = zeros(Int64, 0,3);
   x[:] = collect(1:prod(n));
   for i=1:n[1]-1, j=1:n[2]-1
     z = vcat(z, [x[i,j] x[i+1,j] x[i, j+1]]);
     z = vcat(z, [x[i+1,j+1] x[i+1,j] x[i, j+1]]);
     end;
   return z;
   end;


 function pointmapB(xp)
   n = size(xp);
   ji = (n[1]-1) * (n[2]-1) * 2;
   k = 0;
   x = zeros(n);
   z = zeros(Int64, 3,ji);
   x[:] = collect(1:prod(n)) .- 1;
   for i=1:n[1]-1, j=1:n[2]-1
     ##print(" [", i, " ",j,"] ");

     z[:, k+1] = [x[i,j] x[i+1,j] x[i, j+1]];
     z[:, k+2] = [x[i+1,j+1] x[i+1,j] x[i, j+1]];
     k += 2;

     end;
   return z;
   end;


 function s2cpoint(fixa, fixb, midp)

   centr = (fixa .+ fixb) / 2;
   return 2*(midp - centr) + centr;
   end;

 function surf2control(spoints)
   topmid    = s2cpoint(spoints[1], spoints[3], spoints[2]);
   botmid    = s2cpoint(spoints[7], spoints[9], spoints[8]);
   leftcent  = s2cpoint(spoints[1], spoints[7], spoints[4]);
   rightcent = s2cpoint(spoints[3], spoints[9], spoints[6]);
   midcent   = s2cpoint(spoints[2], spoints[8], spoints[5]);
   midcentb   = s2cpoint(leftcent, rightcent, midcent);

   println(midcent - midcentb, " err?");

   return [spoints[1] topmid spoints[3]; leftcent midcentb rightcent; spoints[7] botmid spoints[9]]
   
  end;

 function collectmaps(bzgons, ntype = 3)
   n = size(bzgons,1);
   ix = 0;
   nm = zeros(Int, 1,0);
   px = zeros(Float64, ntype, 0);
   for iter = 1:n
     bz = bzgons[iter];
     bm = pointmapB(bz);
     nm = hcat(nm, bm[:]' .+ ix);
    ##print(reduce(hcat, collect.(bz[:])));
    ##break;
    ##px = hcat(px, reduce(hcat, reduce(vcat, collect.(bz[:]))));
	 
     px = hcat(px, reduce(hcat, bz[:]));
     ix = size(px,2);
     end;
   return (px, nm);
   end; 
  
  import Base.adjoint, Base.show, Base.length, Base.iterate;

  adjoint(x::point3d{T}) where{T} = x;
  show(io::IO, x::point3d{T}) where{T} = print(io, "3d $(x.x) $(x.y) $(x.z)");

  length(x::point3d{T}) where{T} = 1;
  iterate(x::point3d{T}, state = 1) where{T} = state == 1 ? ([x.x, x.y, x.z], 2) : nothing;

end;

##Base.length(x::Main.n3bezier.point3d{T}) where{T} = 1;
##Base.iterate(x::Main.n3bezier.point3d{T}, state = 1) where{T} = state == 1 ? ([x.x, x.y, x.z], 2) : nothing;

#Base.getindex(x::Main.n3bezier.point3d{T}, i) where{T} = i<4 ? (i==1 ? x.x : (i==2 ? x.y : (i==3 ? x.z : nothing))) : nothing; 
#Base.setindex!(x::Main.n3bezier.point3d{T}, v, i) where{T} = i<4 ? (i==1 ? x.x=v : (i==2 ? x.y=v : (i==3 ? x.z=v : nothing))) : nothing; 
#Base.firstindex(x::Main.n3bezier.point3d{T}) where{T} = 1;
#Base.lastindex(x::Main.n3bezier.point3d{T}) where{T} = 3;

##import Main.n3bezier.point3d;


function xp=oscilams(t,x,flag,datosgen)
t=t'; % versión normal.
% *******************************************************************
% En alguna version de estudiantes no ha de transponerse el vector t
% y tienen que transponerse los vectores x y xp
% *******************************************************************
a=datosgen';
ngen=-1+sqrt(1+(length(a)/2));
kD=a(1:ngen);
kH=a(ngen+1:2*ngen);
Pmec=a(2*ngen+1:3*ngen);
egenm=a(3*ngen+1:4*ngen);
Yeqr=reshape(a(4*ngen+1:4*ngen+ngen*ngen),ngen,ngen);
Yeqi=reshape(a(4*ngen+ngen*ngen+1:4*ngen+2*ngen*ngen),ngen,ngen);
Yeq=Yeqr+j*Yeqi;
xp(1:ngen)=kD.*x(1:ngen)+kH.*(Pmec-real((egenm.*exp(-j*x(ngen+1:2*ngen))).*(Yeq*(egenm.*exp(j*x(ngen+1:2*ngen))))));
xp(ngen+1:2*ngen)=x(1:ngen);
xp=xp';

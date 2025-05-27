function[yppt,ypst,yspt,ysst,y0t,rt,yppt0,ypst0,ysst0,Ytraf1,Ytraf2,Ytraf0,nt,nt1,nt2]=trafofcc(fide,fids,nnu,ntraf,nn,cnombre)
%
% Flujo de cargas:Lectura de los datos de los trafos.
%
nt=[];
nt1=[];
nt2=[];
%Inicializar las admitancias de los trafos.
y0t=zeros(1,ntraf);
yppt=zeros(1,ntraf);
ypst=zeros(1,ntraf);
yspt=zeros(1,ntraf);
ysst=zeros(1,ntraf);
yppt0=zeros(1,ntraf);
ypst0=zeros(1,ntraf);
ysst0=zeros(1,ntraf);
fprintf(fids,'\n\n  nombre  primario  secundario       Rcc       Xcc        G0        B0        rt    alfa   conexp    Rpt       Xpt    conexs    Rps       Xps \n\n');
%Lectura de los datos de los trafos:
for k=1:ntraf
   nt(k,1:cnombre)=leernomb(fide,fids,cnombre,'del trafo');
   nt1(k,1:cnombre)=leernomb(fide,fids,cnombre,'del primario');
   nt2(k,1:cnombre)=leernomb(fide,fids,cnombre,'del secundario');
% Convertir a la numeración interna.
   n1ti(k)=buscar(fide,fids,nt1(k,:),nn,'Trafo. No se encontró el nudo primario: ');
   n2ti(k)=buscar(fide,fids,nt2(k,:),nn,'Trafo. No se encontró el nudo secundario: ');
%
   dtraf(1:12,k)=fscanf(fide,'%f',12); % Rcc,Xcc,G0,B0,rt,alfa,conexp,Rpt,Xpt,conexs,Rst,Xst.
   fprintf(fids,'%s  %s   %s  %10.4f%10.4f%10.4f%10.4f%10.4f%7.0f%7.0f%10.4f%10.4f%7.0f%10.4f%10.4f\n',nt(k,:),nt1(k,:),nt2(k,:),dtraf(1:12,k)); 
% Comprobar los desfases de los trafos.
   ktipo=abs((dtraf(7,k)+dtraf(10,k))*(dtraf(7,k)-dtraf(10,k)));
   if ktipo<=3 & dtraf(6,k)~=0
      fprintf(fids,'********** Advertencia: El desfase del transformador%s, no es nulo\n',nt(k,:)) ;
      fprintf(1,'********** Advertencia: El desfase del transformador%s, no es nulo\n',nt(k,:)) ;
   end
   if ktipo>3 & dtraf(6,k)==0
      fprintf(fids,'********** Advertencia: El desfase del transformador%s, es nulo\n',nt(k,:)) ;
      fprintf(1,'********** Advertencia: El desfase del transformador%s, es nulo\n',nt(k,:)) ;
   end
%
end
%
zcct=dtraf(1,:)+j*dtraf(2,:); % Impedancia de cortocircuito.
ycct=zcct.\1;
y0t=dtraf(3,:)+j*dtraf(4,:); % Admitancia de vacio.
rt=dtraf(5,:).*exp(j*pi*dtraf(6,:)/180); % Relación de transformación.
yppt=ycct./(abs(rt).^2);
ysst=ycct+y0t;
ypst=-ycct./conj(rt);
yspt=-ycct./rt;
yppt=sparse((1:ntraf),(1:ntraf),yppt);
ypst=sparse((1:ntraf),(1:ntraf),ypst);
ysst=sparse((1:ntraf),(1:ntraf),ysst);
yspt=sparse((1:ntraf),(1:ntraf),yspt);
y0t=sparse((1:ntraf),(1:ntraf),y0t);
ztp=3*(dtraf(8,:)+j*dtraf(9,:))./(abs(rt).^2);
zts=3*(dtraf(11,:)+j*dtraf(12,:));
Ctraf1=sparse(n1ti,[1:ntraf],ones(1,ntraf),nnu,ntraf); % Matriz de conexión.
Ctraf2=sparse(n2ti,[1:ntraf],ones(1,ntraf),nnu,ntraf); % Matriz de conexión.
Ytraf1=Ctraf1*yppt*Ctraf1'+Ctraf1*ypst*Ctraf2'+Ctraf2*yspt*Ctraf1'+Ctraf2*ysst*Ctraf2';
Ytraf2=Ctraf1*yppt*Ctraf1'+Ctraf1*yspt*Ctraf2'+Ctraf2*ypst*Ctraf1'+Ctraf2*ysst*Ctraf2';
%
yppt0=zeros(1,ntraf);
ysst0=zeros(1,ntraf);
ypst0=zeros(1,ntraf);
for k=1:ntraf 
   if dtraf(7,k)==1 & dtraf(10,k)==1
      ycct0(k)=1/(ztp(k)+zcct(k)+zts(k));
      yppt0(k)=ycct0(k)/(abs(rt(k))^2);
      ypst0(k)=-ycct0(k)/abs(rt(k));
      ysst0(k)=ycct0(k)+y0t(k);
   end
   if dtraf(7,k)==1 & dtraf(10,k)==3
      ycct0(k)=1/(ztp(k)+zcct(k));
      yppt0(k)=ycct0(k)/(abs(rt(k))^2);
      ysst0(k)=y0t(k);
   end
   if dtraf(7,k)==3 & dtraf(10,k)==1
      ycct0(k)=1/(zcct(k)+zts(k));
      ysst0(k)=ycct0(k)+y0t(k);
   end
end
yppt0=sparse((1:ntraf),(1:ntraf),yppt0);
ypst0=sparse((1:ntraf),(1:ntraf),ypst0);
ysst0=sparse((1:ntraf),(1:ntraf),ysst0);
Ytraf0=Ctraf1*yppt0*Ctraf1'+Ctraf1*ypst0*Ctraf2'+Ctraf2*ypst0*Ctraf1'+Ctraf2*ysst0*Ctraf2';


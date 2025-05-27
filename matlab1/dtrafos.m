function[yppt,ypst,yspt,ysst,yppt0,ypst0,ysst0,Ytraf1,Ytraf2,Ytraf0,nt,n1ti,n2ti]=dtrafos(fide,fids,nnu,ntraf,nudos,iprevia);
dtraf=fscanf(fide,'%d %d %d %f %f %f %f %f %f %d %f %f %d %f %f',[15 ntraf]);
fprintf(fids,'%4d %4d %4d %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %4d %8.4f %8.4f %4d %8.4f %8.4f\n',dtraf);
%
nt=dtraf(1,:); % Número identificador del trafo.
n1t=dtraf(2,:); % Nudo del primario.
n2t=dtraf(3,:); % Nudo del secundario.
zcct=dtraf(4,:)+j*dtraf(5,:); % Impedancia de cortocircuito.
ycct=zcct.\1;
y0t=dtraf(6,:)+j*dtraf(7,:); % Admitancia de vacio.
%
if iprevia==4
   y0t=zeros(1,ntraf);
end
% Comprobar los desfases de los trafos.
for k=1:ntraf
	ktipo=abs((dtraf(10,k)+dtraf(13,k))*(dtraf(10,k)-dtraf(13,k)));
	if ktipo<=3 & dtraf(9,k)~=0
		fprintf(fids,'********** Advertencia: El desfase del transformador%4d, no es nulo\n',nt(k)) ;
      fprintf(1,'********** Advertencia: El desfase del transformador%4d, no es nulo\n',nt(k)) ;
   end
	if ktipo>3 & dtraf(9,k)==0
      fprintf(fids,'********** Advertencia: El desfase del transformador%4d, es nulo\n',nt(k)) ;
      fprintf(1,'********** Advertencia: El desfase del transformador%4d, es nulo\n',nt(k)) ;
	end
end
%
% Convertir a la numeración interna.
[n1ti,n1t]=nudosint(fide,fids,ntraf,n1t,nudos,'Trafo. No se encontró el nudo primario: ');
[n2ti,n2t]=nudosint(fide,fids,ntraf,n2t,nudos,'Trafo. No se encontró el nudo secundario: ');
%
rt=dtraf(8,:).*exp(j*pi*dtraf(9,:)/180); % Relación de transformación.
if iprevia==4
   rt=exp(j*pi*dtraf(9,:)/180);
end
yppt=ycct./(abs(rt).^2);
ysst=ycct+y0t;
ypst=-ycct./conj(rt);
yspt=-ycct./rt;
yppt=sparse((1:ntraf),(1:ntraf),yppt);
ypst=sparse((1:ntraf),(1:ntraf),ypst);
ysst=sparse((1:ntraf),(1:ntraf),ysst);
yspt=sparse((1:ntraf),(1:ntraf),yspt);
ztp=3*(dtraf(11,:)+j*dtraf(12,:))./(abs(rt).^2);
zts=3*(dtraf(14,:)+j*dtraf(15,:));
Ctraf1=sparse(n1ti,[1:ntraf],ones(1,ntraf),nnu,ntraf); % Matriz de conexión.
Ctraf2=sparse(n2ti,[1:ntraf],ones(1,ntraf),nnu,ntraf); % Matriz de conexión.
Ytraf1=Ctraf1*yppt*Ctraf1'+Ctraf1*ypst*Ctraf2'+Ctraf2*yspt*Ctraf1'+Ctraf2*ysst*Ctraf2';
Ytraf2=Ctraf1*yppt*Ctraf1'+Ctraf1*yspt*Ctraf2'+Ctraf2*ypst*Ctraf1'+Ctraf2*ysst*Ctraf2';
%
yppt0=zeros(1,ntraf);
ysst0=zeros(1,ntraf);
ypst0=zeros(1,ntraf);
for k=1:ntraf 
   if dtraf(10,k)==1 & dtraf(13,k)==1
      ycct0(k)=1/(ztp(k)+zcct(k)+zts(k));
      yppt0(k)=ycct0(k)/(abs(rt(k))^2);
      ypst0(k)=-ycct0(k)/abs(rt(k));
      ysst0(k)=ycct0(k)+y0t(k);
   end
   if dtraf(10,k)==1 & dtraf(13,k)==3
      ycct0(k)=1/(ztp(k)+zcct(k));
      yppt0(k)=ycct0(k)/(abs(rt(k))^2);
      ysst0(k)=y0t(k);
   end
   if dtraf(10,k)==3 & dtraf(13,k)==1
      ycct0(k)=1/(zcct(k)+zts(k));
      ysst0(k)=ycct0(k)+y0t(k);
   end
end
yppt0=sparse((1:ntraf),(1:ntraf),yppt0);
ypst0=sparse((1:ntraf),(1:ntraf),ypst0);
ysst0=sparse((1:ntraf),(1:ntraf),ysst0);
Ytraf0=Ctraf1*yppt0*Ctraf1'+Ctraf1*ypst0*Ctraf2'+Ctraf2*ypst0*Ctraf1'+Ctraf2*ysst0*Ctraf2';


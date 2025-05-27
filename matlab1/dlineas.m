function[yppl,ypsl,yppl0,ypsl0,Ylin1,Ylin2,Ylin0,nl,n1li,n2li]=dlineas(fide,fids,nnu,nlin,nudos,iprevia);
dlin=fscanf(fide,'%d %d %d %f %f %f %f %f %f %f %f',[11 nlin]);
fprintf(fids,'%4d %4d %4d %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f\n',dlin);
nl=dlin(1,:); % Número de identificación de la línea.
n1l=dlin(2,:); % Nudo origen.
n2l=dlin(3,:); % Nudo final.
zsl1=dlin(4,:)+j*dlin(5,:); % Impedancia serie de secuencia directa.
ysl1=zsl1.\1;
ypl1=dlin(6,:)+j*dlin(7,:); % Admitancia paralelo de secuencia directa.
%if iprevia==0
if iprevia>2
   ypl1=zeros(1,nlin);
end
zsl0=dlin(8,:)+j*dlin(9,:); % Impedancia serie de secuencia homopolar.
if zsl0==0.0
   zsl0=3*zsl1;
end
ysl0=zsl0.\1;
ypl0=dlin(10,:)+j*dlin(11,:); % Admitancia paralelo de secuencia homopolar.
%if iprevia==0
if iprevia>2
   ypl0=zeros(1,nlin);
end
yppl=ysl1+0.5*ypl1; % Admitancia propia, secuencias directa e inversa.
ypsl=-ysl1; % Admitancia mutua, secuencias directa e inversa.
yppl0=ysl0+0.5*ypl0; % Admitancia propia, secuencia homopolar.
ypsl0=-ysl0; % Admitancia mutua, secuencia homopolar.
yppl=sparse((1:nlin),(1:nlin),yppl);
ypsl=sparse((1:nlin),(1:nlin),ypsl);
yppl0=sparse((1:nlin),(1:nlin),yppl0);
ypsl0=sparse((1:nlin),(1:nlin),ypsl0);
clave=leeclave(fide,fids,'Acoplamientos:');
fprintf(fids,'%s\n',clave);
nacop=fscanf(fide,'%d',1);
if nacop~=0
   acop=fscanf(fide,'%d %d %f %f',[4 nacop]);
   fprintf(fids,'%4d %4d %8.4f %8.4f\n',acop);
   L1=acop(1,:);
   L2=acop(2,:);
   zacop=acop(3,:)+j*acop(4,:);
   Yacop=sparse(nlin,nlin);
   for k=1:nacop
      Lin1=find(nl==L1(k));
      Lin2=find(nl==L2(k));
      zlin=[zsl0(Lin1) zacop(k); zacop(k) zsl0(Lin2)];
      ylin=inv(zlin);
      Yacop(Lin1,Lin1)=ylin(1,1)-ysl0(Lin1);
      Yacop(Lin2,Lin2)=ylin(2,2)-ysl0(Lin2);
      Yacop(Lin1,Lin2)=ylin(1,2);
      Yacop(Lin2,Lin1)=ylin(2,1);
   end
   yppl0=yppl0+Yacop;
   ypsl0=ypsl0-Yacop;
end
% Convertir a la numeración interna.
[n1li,n1l]=nudosint(fide,fids,nlin,n1l,nudos,'Línea. No se encontró el nudo origen: ');
[n2li,n2l]=nudosint(fide,fids,nlin,n2l,nudos,'Línea. No se encontró el nudo final: ');
%
Clin1=sparse(n1li,[1:nlin],ones(1,nlin),nnu,nlin); % Matriz de conexión.
Clin2=sparse(n2li,[1:nlin],ones(1,nlin),nnu,nlin); % Matriz de conexión.
Ylin1=Clin1*yppl*Clin1'+Clin1*ypsl*Clin2'+Clin2*ypsl*Clin1'+Clin2*yppl*Clin2';
Ylin2=Ylin1;
Ylin0=Clin1*yppl0*Clin1'+Clin1*ypsl0*Clin2'+Clin2*ypsl0*Clin1'+Clin2*yppl0*Clin2';





function[yppl,ypsl,yppl0,ypsl0,Ylin1,Ylin2,Ylin0,nl,nl1,nl2]=lineafcc(fide,fids,nnu,nlin,nn,cnombre)
%
% Flujo de cargas:Lectura de los datos de las líneas.
%
nl=[];
nl1=[];
nl2=[];
%Inicializar las admitancias de las líneas.
yppl=zeros(1,nlin);
ypsl=zeros(1,nlin);
yppl0=zeros(1,nlin);
ypsl0=zeros(1,nlin);
fprintf(fids,'\n\n  nombre     nudo1     nudo2         R         X         G         B        R0        X0        G0        B0 \n\n');
%Lectura de los datos de las líneas:
for k=1:nlin
   nl(k,1:cnombre)=leernomb(fide,fids,cnombre,'de la línea');
   nl1(k,1:cnombre)=leernomb(fide,fids,cnombre,'del nudo 1 de la línea');
   nl2(k,1:cnombre)=leernomb(fide,fids,cnombre,'del nudo 2 de la línea');
% Convertir a la numeración interna.
   n1li(k)=buscar(fide,fids,nl1(k,:),nn,'Línea. No se encontró el nudo 1: ');
   n2li(k)=buscar(fide,fids,nl2(k,:),nn,'Línea. No se encontró el nudo 2: ');
%
   dlin(1:8,k)=fscanf(fide,'%f',8); % R,X,G,B,R0,X0,G0,B0.
   fprintf(fids,'%s  %s  %s  %10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f\n',nl(k,:),nl1(k,:),nl2(k,:),dlin(1:8,k)); 
end
zsl1=dlin(1,:)+j*dlin(2,:); % Impedancia serie de secuencia directa.
ysl1=zsl1.\1;
ypl1=dlin(3,:)+j*dlin(4,:); % Admitancia paralelo de secuencia directa.
zsl0=dlin(5,:)+j*dlin(6,:); % Impedancia serie de secuencia homopolar.
if zsl0==0.0
   zsl0=3*zsl1;
end
ysl0=zsl0.\1;
ypl0=dlin(7,:)+j*dlin(8,:); % Admitancia paralelo de secuencia homopolar.
yppl=ysl1+0.5*ypl1; % Admitancia propia, secuencias directa e inversa.
ypsl=-ysl1; % Admitancia mutua, secuencias directa e inversa.
yppl0=ysl0+0.5*ypl0; % Admitancia propia, secuencia homopolar.
ypsl0=-ysl0; % Admitancia mutua, secuencia homopolar.
yppl=sparse((1:nlin),(1:nlin),yppl);
ypsl=sparse((1:nlin),(1:nlin),ypsl);
yppl0=sparse((1:nlin),(1:nlin),yppl0);
ypsl0=sparse((1:nlin),(1:nlin),ypsl0);
fprintf(fids,'\n\nDATOS DE LOS ACOPLAMIENTOS: \n\n');
clave=leeclave(fide,fids,'Acoplamientos:');
nacop=fscanf(fide,'%d',1);
fprintf(fids,'Pares de líneas acopladas:%4d\n',nacop);
if nacop~=0
   Yacop=sparse(nlin,nlin);
   fprintf(fids,'\n\n  Línea1    Línea2        R012      X012\n\n');
   for k=1:nacop
      linacop1(k,1:cnombre)=leernomb(fide,fids,cnombre,'de la línea acoplada');
      linacop2(k,1:cnombre)=leernomb(fide,fids,cnombre,'de la línea acoplada');
      acop(1:2,k)=fscanf(fide,'%f',2);
      fprintf(fids,'%s  %s  %10.4f%10.4f\n',linacop1(k,:),linacop2(k,:),acop(1:2,k)); 
      Lin1=buscar(fide,fids,linacop1(k,:),nl,'No se encontró la línea acoplada: ');
      Lin2=buscar(fide,fids,linacop2(k,:),nl,'No se encontró la línea acoplada: ');
      zacop(k)=acop(1,k)+j*acop(2,k);
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
 %
Clin1=sparse(n1li,[1:nlin],ones(1,nlin),nnu,nlin); % Matriz de conexión.
Clin2=sparse(n2li,[1:nlin],ones(1,nlin),nnu,nlin); % Matriz de conexión.
Ylin1=Clin1*yppl*Clin1'+Clin1*ypsl*Clin2'+Clin2*ypsl*Clin1'+Clin2*yppl*Clin2';
Ylin2=Ylin1;
Ylin0=Clin1*yppl0*Clin1'+Clin1*ypsl0*Clin2'+Clin2*ypsl0*Clin1'+Clin2*yppl0*Clin2';
% 
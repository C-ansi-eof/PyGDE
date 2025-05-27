function[Ipfase,Isfase]=ifaselta(fids,T,nlt,n1,n2,nn,nnlt,ucc0,ucc1,ucc2,ypp,yps,ysp,yss,ypp0,yps0,yss0)
% Calcular e imprimir las intensidades de líneas/trafos.
% Ipfase: Intensidades de fase de los primarios (origen).
% Isfase: Intensidades de fase de los secundarios (final).
% fids: Identificador del fichero de salida.
% T: Matriz de transformación.
% nlt: Número de líneas/trafos.
% n1: Vector de nudos primarios.
% n2: Vector de nudos secundarios.
% nn: Vector de nombres de los nudos.
% nnlt: Vector de nombres de las líneas/trafos.
% ucc0: Tensiones de cortocircuito de secuencia homopolar.
% ucc1: Tensiones de cortocircuito de secuencia directa.
% ucc2: Tensiones de cortocircuito de secuencia inversa.
% ypp: Admitancia propia del nudo 1, primario,de secuencia directa.
% yps: Admitancia mutua, primario-secundario,de secuencia directa.
% ysp: Admitancia mutua, secundario-primario,de secuencia directa.
% yss: Admitancia propia del nudo 2, secundario,de secuencia directa.
% ypp0: Admitancia propia del nudo 1, primario,de secuencia homopolar.
% yps0: Admitancia mutua, de secuencia homopolar.
% yss0: Admitancia propia del nudo 2, secundario,de secuencia homopolar.
%
% **********************************************************
% Ampliar los vectores ucc 
% para evitar el uso de n1 0 n2 como arrays lógicos.
   ucc1(length(ucc1)+1)=0;
   ucc2(length(ucc2)+1)=0;
   ucc0(length(ucc0)+1)=0;
% **********************************************************
Ip1=ypp*ucc1(n1)+yps*ucc1(n2);
Ip2=ypp*ucc2(n1)+ysp*ucc2(n2);
Ip0=ypp0*ucc0(n1)+yps0*ucc0(n2);
Ipsim=[Ip0.';Ip1.';Ip2.'];
Ipfase=(T*Ipsim).';
Ipfasem=abs(Ipfase); 
Ipfasea=180*angle(Ipfase)/pi;
Is1=ysp*ucc1(n1)+yss*ucc1(n2);
Is2=yps*ucc2(n1)+yss*ucc2(n2);
Is0=yps0*ucc0(n1)+yss0*ucc0(n2);
Issim=[Is0.';Is1.';Is2.'];
Isfase=(T*Issim).';
Isfasem=abs(Isfase); 
Isfasea=180*angle(Isfase)/pi;
%
for k=1:nlt
   lintraf=nnlt(k,:);
   Nudoa=nn(n1(k),:);
   Nudob=nn(n2(k),:);
   A1=[Ipfasem(k,:);Ipfasea(k,:)];
   A2=[Isfasem(k,:);Isfasea(k,:)];
   fprintf(fids,'%s %s %s %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f\n',lintraf,Nudoa,Nudob,A1);
   fprintf(fids,'%s %s %s %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f\n',lintraf,Nudob,Nudoa,A2); 
end

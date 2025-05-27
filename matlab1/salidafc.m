function[nudo1lin,nudo2lin,nudo1traf,nudo2traf]=salidafc(fids,nudos,nn,unudos,umod,ufase,lineas,nl,nl1,nl2,Ylin11,Ylin12,trafos,nt,nt1,nt2,Ytraf11,Ytraf12,Ytraf21,Ytraf22,Pgen,Qgen,Pcarga,Qcarga,Qcomp,perdidas,limites);
%
% Salida de resultados del flujo de cargas.
% También se obtienen los números de los nudos extremos de
% líneas y trafos, para usarlos en el análisis de cortocircuitos.
%
%
fprintf(fids,'\n\n\n\n              ---------- RESULTADOS DEL FLUJO DE CARGAS ----------\n\n');
fprintf(fids,' Nudo     Limite  Tensión  Ángulo(º)       Pgen       Qgen     Pcarga     Qcarga      Qcomp\n');
fprintf(fids,'-------------------------------------------------------------------------------------------\n\n');
for k=1:nudos
   Nudo=nn(k,:);
   Limite=limites(k,:);
   A=[umod(k);ufase(k);Pgen(k);Qgen(k);Pcarga(k);Qcarga(k);Qcomp(k)];
   fprintf(fids,'%s %s %s',Nudo,blanks(1),Limite);
   fprintf(fids,'%10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f \n',A);
end
if lineas~0;
fprintf(fids,'\n\tPérdidas de activa= %7.5f / Pérdidas de reactiva= %7.5f\n\n',real(perdidas),imag(perdidas));
%
fprintf(fids,'\n\n            ---------- FLUJOS DE POTENCIAS POR LAS LINEAS ----------\n\n');
fprintf(fids,'   Línea    Nudo-A     Nudo-B       P(A->B)    Q(A->B)    P(B->A)    Q(B->A)\n');
fprintf(fids,'----------------------------------------------------------------------------\n\n');

   for k=1:lineas
   n1=buscar2(nl1(k,:),nn);
   nudo1lin(k)=n1;
   n2=buscar2(nl2(k,:),nn);
   nudo2lin(k)=n2;
   ulin=unudos([n1 n2]);
   Ylin=[Ylin11(k,k),Ylin12(k,k);Ylin12(k,k),Ylin11(k,k)];
   slin=ulin.*conj(Ylin*ulin);
   Linea=nl(k,:);
   Nudoa=nn(n1,:);
   Nudob=nn(n2,:);
   A=[real(slin(1,1));imag(slin(1,1));real(slin(2,1));imag(slin(2,1))];
   fprintf(fids,'%s %s %s %s %s',Linea,blanks(1),Nudoa,blanks(1),Nudob);
   fprintf(fids,'%12.4f %10.4f %10.4f %10.4f \n',A);
end
else
    nudo1lin=[];
    nudo2lin=[];
end
%
if trafos~0;
fprintf(fids,'\n\n            ---------- FLUJOS DE POTENCIAS POR LOS TRAFOS ----------\n\n');
fprintf(fids,'   Trafo   Primario Secundario     P(Prim.)   Q(Prim.)  P(Secun.)  Q(Secun.)\n');
fprintf(fids,'----------------------------------------------------------------------------\n\n');
    for k=1:trafos
   n1=buscar2(nt1(k,:),nn);
   nudo1traf(k)=n1;
   n2=buscar2(nt2(k,:),nn);
   nudo2traf(k)=n2;
   utraf=unudos([n1 n2]);
   Ytraf=[Ytraf11(k,k),Ytraf12(k,k);Ytraf21(k,k),Ytraf22(k,k)];
   straf=utraf.*conj(Ytraf*utraf);
   Trafo=nt(k,:);
   Nudoa=nn(n1,:);
   Nudob=nn(n2,:);
   A=[real(straf(1,1));imag(straf(1,1));real(straf(2,1));imag(straf(2,1))];
   fprintf(fids,'%s %s %s %s %s',Trafo,blanks(1),Nudoa,blanks(1),Nudob);
   fprintf(fids,'%12.4f %10.4f %10.4f %10.4f \n',A);
end
else
    nudo1traf=[];
    nudo2traf=[];
end
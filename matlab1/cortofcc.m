function[Zn1,Zn2,Zn0]=cortofcc(fide,fids,nnu,nn,cnombre,nlin,nnl,n1li,n2li,yppl,ypsl,yppl0,ypsl0,....
ntraf,nnt,n1ti,n2ti,yppt,ypst,yspt,ysst,yt0,rt,yppt0,ypst0,ysst0,unudos,Yn1,Yn2,Yn0,scarga,sgen)
%  
% Programa para el análisis de cortocircuitos. (Enero-1997)
%
% El programa es de libre disposición para uso académico.
%
%      *******************************************
%      *   UNIVERSIDAD POLITÉCNICA DE MADRID.    *
%      *   E.T.S. DE INGENIEROS INDUSTRIALES.    *
%      *  DEPARTAMENTO DE INGENIERÍA ELÉCTRICA.  *
%      *******************************************
%
% Advertencia: Esta versión está en periodo de pruebas
% y puede contener muchos errores.
%
% Para comunicar los fallos encontrados o para cualquier
% otra sugerencia relacionada con el programa, dirigirse a:
%
%             aperez@inel.etsii.upm.es
%
%
%
% Análisis de cortocircuitos para ejecutar dentro del flujo de cargas (fcycc)
%
%
% Fijar las condiciones iniciales.
%
U0=1;
ip1='CONSIDERAR LAS INTENSIDADES PREVIAS A LA FALTA';
ip2='NO CONSIDERAR LAS INTENSIDADES PREVIAS A LA FALTA...';
ip3='... y despreciar la admitancia paralelo de las líneas...';
ip4='... además, suponer todos los trafos de relación unidad.';
iprevia=menu('CONDICIONES INICIALES',ip1,ip2,ip3,ip4);
   if iprevia>=2
      fprintf(fids,'\n\nNo se consideran las intensidades previas a la falta.\n\n');
%
      if iprevia>2
         fprintf(fids,'\n\nSe desprecia la admitancia paralelo de las líneas.\n\n');
      end
      if iprevia==4
         fprintf(fids,'\n\nLos trafos se suponen de relación de transformación unidad.\n\n');
         U0=input('Valor en p.u. de las tensiones previas:  ');
      else
         U0=input('Factor de multiplicación de las tensiones previas:  ');
      end
   end
%
%
ksintrafos=abs(unudos(1));
unudos=U0*unudos;
inudos=Yn1*unudos;
Sin0=unudos.*conj(inudos); % Potencias complejas inyectadas en los nudos.
Sin=Sin0;
k=0;
% Buscar el identificador @ de comienzo de los datos.
while k==0
   [A,count]=fscanf(fide,'%s',1);
      if A(1)=='@'
         k=1;
      end
end
%
% Lectura de los datos de los generadores.
%
clave=leeclave(fide,fids,'Generadores:');
ngen=fscanf(fide,'%d',1); % Número de generadores.
fprintf(fids,'\n\nDATOS ADICIONALES PARA EL ANALISIS DE CORTOCIRCUITOS: \n\n');
fprintf(fids,'\n\nDATOS DE LOS GENERADORES: \n\n');
fprintf(fids,'Número total de generadores:%4d\n',ngen);
nugeni=[];
if ngen~=0
egen=zeros(ngen,1);
fprintf(fids,'\n\n  nombre      nudo        Pgen      Qgen       R1        X1        R2        X2        R0        X0    conext     Rt        Xt \n\n');
for k=1:ngen
   nombregen=leernomb(fide,fids,cnombre,'del generador');
   nng(k,1:cnombre)=nombregen;
   nombrenug=leernomb(fide,fids,cnombre,'del nudo generador');
   n1=buscar(fide,fids,nombrenug,nn,'No se encontró el nudo generador: ');
   nugeni(k)=n1; % Nudos con generador.
   dgen=fscanf(fide,'%f %f %f %f %f %f %f %f %d %f %f ',11);
   zg1(k)=dgen(3,:)+j*dgen(4,:); % Impedancias de secuencia directa de los generadores.
   yg1(k)=1/zg1(k);
   zg2(k)=dgen(5,:)+j*dgen(6,:); % Impedancias de secuencia inversa de los generadores.
   yg2(k)=1/zg2(k);
   zg0(k)=dgen(7,:)+j*dgen(8,:); % Impedancias de secuencia homopolar de los generadores.
   zgt(k)=dgen(10,:)+j*dgen(11,:); % Impedancias de puesta a tierra de los generadores.
   yg0(k)=1/(zg0(k)+3*zgt(k));
   yg0(k)=yg0(k)*dgen(9,:); % Anular las yg0 de los generadores sin puesta a tierra.
   Sgen(k)=real(sgen(n1))*dgen(1,:)+j*imag(sgen(n1))*dgen(2,:); % Potencias complejas generadas.
   Sin(n1)=Sin(n1)-Sgen(k); % Quitar las potencias de los generadores.
   ugen(k)=unudos(nugeni(k)); % Tensiones de los nudos con generador.
   ugen(k)=unudos(nugeni(k)); % Tensiones de los nudos con generador.
   egen(k)=ugen(k)+zg1(k)*conj(Sgen(k)/ugen(k)); % Tensiones internas de los generadores.
   fprintf(fids,'%s  %s  %10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%7.0f%10.4f%10.4f\n',nng(k,:),nombrenug(1,:),real(Sgen(k)),imag(Sgen(k)),dgen(3:11)); 
   end
end
%
% Lectura de los datos de los motores.
%
clave=leeclave(fide,fids,'Motores:');
nmot=fscanf(fide,'%d',1); % Número de motores.
fprintf(fids,'\n\nDATOS DE LOS MOTORES: \n\n');
fprintf(fids,'Número total de motores:%4d\n',nmot);
numoti=[];
nnm=0;
emot=[];
ym1=[];
ym2=[];
ym0=[];
if nmot~=0
emot=zeros(nmot,1);
fprintf(fids,'\n\n  nombre      nudo        Pmot      Qmot       R1        X1        R2        X2        R0        X0    conext     Rt        Xt \n\n');
for k=1:nmot
   nombremot=leernomb(fide,fids,cnombre,'del motor');
   nnm(k,1:cnombre)=nombremot;
   nombrenum=leernomb(fide,fids,cnombre,'del nudo motor');
   n1=buscar(fide,fids,nombrenum,nn,'No se encontró el nudo motor: ');
   numoti(k)=n1;% Nudos con motor.
   dmot=fscanf(fide,'%f %f %f %f %f %f %f %f %d %f %f ',11);
   zm1(k)=dmot(3,:)+j*dmot(4,:); % Impedancias de secuencia directa de los motores.
   ym1(k)=1/zm1(k);
   zm2(k)=dmot(5,:)+j*dmot(6,:); % Impedancias de secuencia inversa de los motores.
   ym2(k)=1/zm2(k);
   zm0(k)=dmot(7,:)+j*dmot(8,:); % Impedancias de secuencia homopolar de los motores.
   zmt(k)=dmot(10,:)+j*dmot(11,:); % Impedancias de puesta a tierra de los motores.
   ym0(k)=1/(zm0(k)+3*zmt(k));
   ym0(k)=ym0(k)*dmot(9,:); % Anular las ym0 de los motores sin puesta a tierra.
   Smot(k)=real(scarga(n1))*dmot(1,:)+j*imag(scarga(n1))*dmot(2,:); % Potencias complejas inyectadas por los motores.
   Sin(n1)=Sin(n1)+Smot(k); % Quitar las potencias de los motores.
   umot(k)=unudos(numoti(k)); % Tensiones de los nudos con motor.
   emot(k)=umot(k)-zm1(k)*conj(Smot(k)/umot(k)); % Tensiones internas de los motores.
   fprintf(fids,'%s  %s  %10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%7.0f%10.4f%10.4f\n',nnm(k,:),nombrenum(1,:),real(Smot(k)),imag(Smot(k)),dmot(3:11)); 
   end
end
%
%
clave=leeclave(fide,fids,'Fin');
fprintf(fids,'\n\n FIN DEL LISTADO DE LOS DATOS ADICIONALES. \n\n');
%******* Fin de la lectura de datos de generadores y motores *******
%
% Construcción de las matrices de admitancias de nudos.
%
nudosi=[1:nnu];
if iprevia>=2
   Yn1=sparse(nnu,nnu); % Secuencia directa.
   Yn2=sparse(nnu,nnu); % Secuencia inversa.
   Yn0=sparse(nnu,nnu); % Secuencia homopolar.
   if nlin~=0
% Admitancias de las líneas.
      if iprevia>2
         yppl=-ypsl;
         yppl0=-ypsl0;
      end
%
      Clin1=sparse(n1li,[1:nlin],ones(1,nlin),nnu,nlin); % Matriz de conexión.
      Clin2=sparse(n2li,[1:nlin],ones(1,nlin),nnu,nlin); % Matriz de conexión.
      Ylin1=Clin1*yppl*Clin1'+Clin1*ypsl*Clin2'+Clin2*ypsl*Clin1'+Clin2*yppl*Clin2';
     Ylin2=Ylin1;
      Ylin0=Clin1*yppl0*Clin1'+Clin1*ypsl0*Clin2'+Clin2*ypsl0*Clin1'+Clin2*yppl0*Clin2';
      Yn1=Yn1+Ylin1;
      Yn2=Yn2+Ylin2;
      Yn0=Yn0+Ylin0;
   end
   if ntraf~=0
% Admitancias de los trafos.
      if iprevia==4
         ysst=ysst-yt0;
         yppt=ysst;
         rtmod=abs(rt);
         rtmod=sparse(diag(rtmod));
         ypst=ypst*rtmod;
         yspt=yspt*rtmod;
         yppt0=(yppt0*rtmod)*rtmod;
         ypst0=ypst0*rtmod;
         ysst0=ysst0-yt0;
      end
      Ctraf1=sparse(n1ti,[1:ntraf],ones(1,ntraf),nnu,ntraf); % Matriz de conexión.
      Ctraf2=sparse(n2ti,[1:ntraf],ones(1,ntraf),nnu,ntraf); % Matriz de conexión.
      Ytraf1=Ctraf1*yppt*Ctraf1'+Ctraf1*ypst*Ctraf2'+Ctraf2*yspt*Ctraf1'+Ctraf2*ysst*Ctraf2';
      Ytraf2=Ctraf1*yppt*Ctraf1'+Ctraf1*yspt*Ctraf2'+Ctraf2*ypst*Ctraf1'+Ctraf2*ysst*Ctraf2';
      Ytraf0=Ctraf1*yppt0*Ctraf1'+Ctraf1*ypst0*Ctraf2'+Ctraf2*ypst0*Ctraf1'+Ctraf2*ysst0*Ctraf2';
      Yn1=Yn1+Ytraf1;
      Yn2=Yn2+Ytraf2;
      Yn0=Yn0+Ytraf0;
   end
   unudos0=-inv(Yn1(2:nnu,2:nnu))*Yn1(2:nnu,1)*unudos(1);
   unudos0=full([unudos(1);unudos0]);
   if iprevia==4
      unudos=unudos0/ksintrafos;
   end
   ku=unudos./unudos0;
else
% Ajuste de las condiciones iniciales del reparto de cargas.
%unudos=unudos.'; % Cambiar a vector columna.
   ycarga=-(conj(Sin))./(abs(unudos).^2); % Admitancias de las cargas.
   ycarga=sparse([1:nnu],[1:nnu],ycarga);
   Yn1=Yn1+ycarga;
   Yn2=Yn2+ycarga;
   ycarga=full(diag(ycarga));
   fprintf(fids,' Para ajustar las condiciones iniciales del reparto de cargas,\n se añaden las siguientes admitancias de carga:\n\n');
   for k=1:nnu
      fprintf(fids,'\n Nudo: %s,  ycarga= %10.8f + j(%10.8f)\n',nn(k,:),real(ycarga(k)),imag(ycarga(k)));
   end
end
% Admitancias de los generadores.
for k=1:ngen
   ig=nugeni(k);
   Yn1(ig,ig)=Yn1(ig,ig)+yg1(k);
   Yn2(ig,ig)=Yn2(ig,ig)+yg2(k);
   Yn0(ig,ig)=Yn0(ig,ig)+yg0(k);
end
% Admitancias de los motores.
for k=1:nmot
   im=numoti(k);
   Yn1(im,im)=Yn1(im,im)+ym1(k);
   Yn2(im,im)=Yn2(im,im)+ym2(k);
   Yn0(im,im)=Yn0(im,im)+ym0(k);
end
% Matrices de impedancias de nudos.
Zn1=inv(Yn1);
Zn2=inv(Yn2);
% Evitar la posible singularidad de Yn0.
%
%if rcond(full(Yn0))<1.e-10
if condest(Yn0)>1.e10
   sumafilas=abs(Yn0*ones(nnu,1));
   k=find(sumafilas<1.e-10);
   k1=size(k,1);
   ky0=j*1.e-10*sparse([1:k1],[1:k1],ones(1,k1));
   Yn0(k,k)=Yn0(k,k)+ky0;
end
%
Zn0=inv(Yn0);
%
a=exp(j*2*pi/3);
a2=exp(-j*2*pi/3);
T=[1 1 1; 1 a2 a; 1 a a2];
%
cc1='FALTA TRIFÁSICA';
cc2='FALTA A TIERRA DE LA FASE A';
cc3='FALTA ENTRE LAS FASES B Y C';
cc4='FALTA A TIERRA DE LAS FASES B Y C';
cc5='FALTA TRIFÁSICA, CON IMPEDANCIA DE FALTA';
cc6='FALTA A TIERRA DE LA FASE A, CON IMPEDANCIA DE FALTA';
cc7='FALTA ENTRE LAS FASES B Y C, CON IMPEDANCIA DE FALTA';
cc8='FALTA A TIERRA DE LAS FASES B Y C, CON IMPEDANCIA DE FALTA';
cc9='NO CONSIDERAR MAS FALLOS';
tipocc=str2mat(cc1,cc2,cc3,cc4,cc5,cc6,cc7,cc8,cc9);
opcion=menu('Elegir una opción',cc1,cc2,cc3,cc4,cc5,cc6,cc7,cc8,cc9);
while opcion<9
   nf=0;
   while nf==0
      fprintf(1,'\nNudos de la red:\n\n');
      for k=1:nnu
         fprintf(1,'%8d %s\n',nudosi(k),nn(k,:));
      end
      nfalta=input('(Vector de números; []= todos) Fallo en los nudos: ');
      if isempty(nfalta)
         nfalta=nudosi;
      end
      nf=1;
      for k=1:max(size(nfalta))
         nfv=find(nudosi==nfalta(k));
         if isempty(nfv)
            fprintf(1,'\nEl nudo número%4d, no es de la red.\n',nfalta(k));
            nf=0;
         end
      end
   end
%
   zfalta=0.0;
   Icc2=zeros(nnu,1);
   Icc0=zeros(nnu,1);
%
   if opcion>4      
      zfalta=input('Valor complejo de la impedancia de falta:  ');
   end
%
   if opcion==1 | opcion==5  % Corto trifásico.
      Zff=zfalta+diag(Zn1);
      Icc1=Zff.\unudos; 
   end
%
   if opcion==2 | opcion==6  % Corto monofásico.
      Zff=3*zfalta+diag(Zn0)+diag(Zn1)+diag(Zn2);
      Icc1=Zff.\unudos; % Intensidades de cortocircuito monofásico.
      Icc2=Icc1;
      Icc0=Icc1;
   end
%
   if opcion==3 | opcion==7  % Corto bifásico.
      Zff=zfalta+diag(Zn1)+diag(Zn2);
      Icc1=Zff.\unudos; % Intensidades de cortocircuito monofásico.
      Icc2=-Icc1;
   end
%
   if opcion==4 | opcion==8  % Corto bifásico a tierra.
      Zaux=3*zfalta+diag(Zn0)+diag(Zn2);
      Zaux=Zaux.\(3*zfalta+diag(Zn0));
      Zff=diag(Zn1)+diag(Zn2).*Zaux;
      Icc1=Zff.\unudos; % Intensidades de cortocircuito monofásico.
      Icc2=-Icc1.*Zaux;
      Icc0=-Icc1-Icc2;
   end
%
   Iccsim=[Icc0.';Icc1.';Icc2.'];
   Iccfase=(T*Iccsim).';
   Iccfasem=abs(Iccfase); % Módulo de la Icc.
   Iccfasea=180*angle(Iccfase)/pi; % Argumento, en grados, de la Icc.
   for k=nfalta
      if iprevia>=2
         unudos1=ku(k)*unudos0;
         egen=unudos1(nugeni);
         emot=unudos1(numoti);
      else
         unudos1=unudos;
      end
      ucc1=full(unudos1-Icc1(k).*Zn1(:,k));
      ucc2=full(-Icc2(k).*Zn2(:,k));
      ucc0=full(-Icc0(k).*Zn0(:,k));
      uccsim=[ucc0.';ucc1.';ucc2.'];
      uccfase=(T*uccsim).';
      uccfasem=abs(uccfase); % Módulo de las tensiones.
      uccfasea=180*angle(uccfase)/pi; % Argumento, en grados, de las tensiones.
      fprintf(fids,'\n\n\n***********************************************************************************************************************************************\n');
      fprintf(fids,'*                                                                                                                                             *\n');            
      fprintf(fids,'*  %s                                                                                 * \n',tipocc(opcion,:));
      fprintf(fids,'*                                                                                                                                             *\n'); 
      fprintf(fids,'*  FALLO EN EL NUDO: %s                                                                                                                 *\n',nn(k,:));
      fprintf(fids,'*                                                                                                                                             *\n'); 
      fprintf(fids,'*  Impedancia de falta= %6.4f +j*%5.4f                                                                                                      *\n',real(zfalta),imag(zfalta));
      fprintf(fids,'*                                                                                                                                             *\n'); 
      fprintf(fids,'*                                                                                                                                             *\n'); 
      fprintf(fids,'*  INTENSIDADES DE FALTA: Ia = %8.4f p.u./ %8.4f grados;   Ib = %8.4f p.u./ %8.4f grados;   Ic = %8.4f p.u./ %8.4f grados.  *\n',[Iccfasem(k,:);Iccfasea(k,:)]);
      fprintf(fids,'*                                                                                                                                             *\n'); 
      fprintf(fids,'***********************************************************************************************************************************************\n\n');
      fprintf(fids,'TENSIONES EN LOS NUDOS:\n\n');         
      fprintf(fids,'    Nudo  Tensión(a)   Fase(º)  Tensión(b)   Fase(º)  Tensión(c)   Fase(º) \n');
      fprintf(fids,'---------------------------------------------------------------------------\n\n');
%
      for kp=1:nnu
         fprintf(fids,'%s %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f\n',nn(kp,:),[uccfasem(kp,:);uccfasea(kp,:)]);
      end
%
   if ngen~=0
      fprintf(fids,'\n\n             ----- INTENSIDADES POR LOS GENERADORES -----\n\n');
      fprintf(fids,'     Gener    Nudo   Igen(a)    Fase(º)    Igen(b)    Fase(º)    Igen(c)    Fase(º)\n');
      fprintf(fids,'------------------------------------------------------------------------------------\n\n');
		Igfase=ifasegma(fids,T,ngen,nugeni,nn,nng,egen,ucc0,ucc1,ucc2,yg1,yg2,yg0);
   end
%
   if nmot~=0
      fprintf(fids,'\n\n             ------- INTENSIDADES POR LOS MOTORES -------\n\n');
      fprintf(fids,'     Motor    Nudo   Imot(a)    Fase(º)    Imot(b)    Fase(º)    Imot(c)    Fase(º)\n');
      fprintf(fids,'------------------------------------------------------------------------------------\n\n');
%
		Imfase=ifasegma(fids,T,nmot,numoti,nn,nnm,emot,ucc0,ucc1,ucc2,ym1,ym2,ym0);

   end
%
   if nlin~=0
      fprintf(fids,'\n\n            ---------- INTENSIDADES POR LAS LINEAS ----------\n\n');
      fprintf(fids,'   Línea    Nudo-A     Nudo-B  Imod(a)   Fase(º)     Imod(b)   Fase(º)     Imod(c)   Fase(º)\n');
      fprintf(fids,'---------------------------------------------------------------------------------------------\n\n');

  %
		[Iplfase,Islfase]=ifaselta(fids,T,nlin,n1li,n2li,nn,nnl,ucc0,ucc1,ucc2,yppl,ypsl,ypsl,yppl,yppl0,ypsl0,yppl0);
   end
%
   if ntraf~=0
      fprintf(fids,'\n\n            ---------- INTENSIDADES POR LOS TRAFOS ----------\n\n');
      fprintf(fids,'   Trafo    Nudo-A     Nudo-B  Imod(a)   Fase(º)     Imod(b)   Fase(º)     Imod(c)   Fase(º)\n');
      fprintf(fids,'---------------------------------------------------------------------------------------------\n\n');
%
      [Iptfase,Istfase]=ifaselta(fids,T,ntraf,n1ti,n2ti,nn,nnt,ucc0,ucc1,ucc2,yppt,ypst,yspt,ysst,yppt0,ypst0,ysst0);
   end
%
   end
%
   if fids==1
      fprintf(fids,'\n\nPuede examinar los resultados. Pulse cualquier tecla para continuar.\n\n');
      pause
   end
% 
   opcion=menu('Elegir una opción',cc1,cc2,cc3,cc4,cc5,cc6,cc7,cc8,cc9);    
end
%
%fclose('all');
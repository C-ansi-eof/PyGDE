% Análisis de flujo de cargas por el método de Newton-Raphson
% y análisis de cortocircuitos. (Enero-1997)
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
%
%
% La forma de crear el fichero con los datos de entrada
% se explica en el fichero ayudafcc.txt
%
% El órden de entrada de los nudos puede ser arbitrario.
% El programa los ordena internamente, primero el nudo balance,
% luego los nudos PU y a continuación los PQ. 
%
% Los nudos se identifican por nombres.
%
% Se incluyen límites de reactiva en los nudos PU
% y límites de tensiones en los nudos PQ.
%
% Se considera el desfase de los trafos.
%
% Para el análisis posterior de estabilidad:
%
% Los datos adicionales comienzan a partir de otra "a de arroba".
% Entre el final de los datos del flujo de cargas y el principio
% de los datos de cortocircuito se pueden incluir comentarios.
%
clear 
fide=-1;
%**************************************************************
% LECTURA DE LOS DATOS
%**************************************************************

while fide<=0
   entrada=input('Fichero con los datos de entrada: ','s');
   fide=fopen(entrada,'rt');
      if fide<=0
         disp('No se encontró el fichero.')
      end
end
%           
% Fichero de salida.
fids=1; % Salida por pantalla.
pantalla=input('¿Salida de resultados por la pantalla? s/n (s): ','s');
   if isempty(pantalla)
      pantalla='s';
   end
%
  if (pantalla~='s'& pantalla~='S')
     salida=input('Fichero para escribir los resultados: ','s');
     fids=fopen(salida,'wt+');
  end
%
limitesq=1; % Tener en cuenta los límites de reactiva de los nudos PU.
LQ=input('¿Considerar los límites de reactiva en los nudos PU? s/n (s): ','s');
   if isempty(LQ)
      LQ='s';
   end
%
   if (LQ~='s'& LQ~='S')
      limitesq=0;
      fprintf(fids,'No se consideran los límites de reactiva.\n\n');
   end
%
limitesu=1; % Tener en cuenta los límites de tensiones de los nudos PQ.
LU=input('¿Considerar los límites de tensiones en los nudos PQ? s/n (s): ','s');
   if isempty(LU)
      LU='s';
   end
%
   if (LU~='s'& LU~='S')
      limitesu=0;
      fprintf(fids,'No se consideran los límites de tensiones.\n\n');
   end
% 
% Buscar el identificador @ de comienzo de los datos.
%
k=0;
while k==0
   [A,count]=fscanf(fide,'%s',1);
      if A(1)=='@'
         k=1;
      end
end
% Comienzo de los datos de nudos.
fprintf(fids,'\n\nDATOS DE LOS NUDOS: \n\n');
clave=leeclave(fide,fids,'Nudos:');
nudos=fscanf(fide,'%d',1); % Número de nudos.
fprintf(fids,'Número total de nudos:%4d\n',nudos);
Yred=sparse(nudos,nudos); % Matriz de admitancias de secuencia directa.
Yred2=sparse(nudos,nudos); % Matriz de admitancias de secuencia inversa.
Yred0=sparse(nudos,nudos); % Matriz de admitancias de secuencia homopolar.
cambioti=0; % Control de cambio de tipo durante la iteración.
cnombre=8; % Admitir hasta 8 caracteres para los nombres.
% Datos de los nudos:
[limites,nn,tipoi,tipo,unudos,udada,snudos,scarga,Gcarga,Bcarga,Bcomp,qumax,qumin,Yred]=nudosfcc(fide,fids,nudos,cnombre,limitesq,limitesu,Yred);
%
%Fin de los datos de nudos.
%
%
%Ordenación de los nudos.
%
k1=find(tipo==1); % El nudo 1 es el balance.
k2=find(tipo==2); % Los nudos siguientes son PU.
k3=find(tipo==3); % Los nudos siguientes son PQ.
korden=[k1 k2 k3];
	if length(k1)~=1
		fprintf(fids,' Error: debe haber un nudo balance. ');
		fclose('all');return
	end
nudospu=length(k2)+1; % Nudos PU, incluido el balance.
nudospu0=nudospu; % Número inicial de nudos PU.
nudospq=length(k3); % Nudos PQ.
unudos=unudos(korden);
snudos=snudos(korden);
scarga=scarga(korden);
qumax=qumax(korden);
qumin=qumin(korden);
tipo=tipo(korden);
tipoi=tipoi(korden);
Yred=Yred(korden,korden);
Yred2=Yred;
nn=nn(korden,:);
Gcarga=Gcarga(korden);
Bcarga=Bcarga(korden);
Bcomp=Bcomp(korden);
udada=udada(korden);
%
%Potencias activas de los nudos:
P=real(snudos(2:nudos));
%Potencias reactivas de los nudos P-Q:
qnudos=imag(snudos);
Q=qnudos(nudospu+1:nudos);
%
%
%*************************LINEAS******************************
%
fprintf(fids,'\n\nDATOS DE LAS LINEAS: \n\n');
clave=leeclave(fide,fids,'Líneas:');
lineas=fscanf(fide,'%d',1); % Número de lineas.
fprintf(fids,'Número total de líneas:%4d\n',lineas);
nl=lineas;
nl1=[];
nl2=[];
yppl=[];
ypsl=[];
yppl0=[];
ypsl0=[];
if lineas~=0
%Lectura de los datos de las líneas.
   [yppl,ypsl,yppl0,ypsl0,Ylin1,Ylin2,Ylin0,nl,nl1,nl2]=lineafcc(fide,fids,nudos,lineas,nn,cnombre);
    Yred=Yred+Ylin1;
   Yred2=Yred2+Ylin2;
   Yred0=Yred0+Ylin0;
end
%
%*************************TRAFOS******************************
%
fprintf(fids,'\n\nDATOS DE LOS TRANSFORMADORES: \n\n');
clave=leeclave(fide,fids,'Trafos:');
%fprintf(fids,'%s\n',clave);
trafos=fscanf(fide,'%d',1); % Número de trafos.
fprintf(fids,'Número total de transformadores:%4d\n',trafos);
nt=trafos;
nt1=[];
nt2=[];
yppt=[];
ypst=[];
yspt=[];
ysst=[];
if trafos~=0
%Lectura de los datos de los trafos.
   [yppt,ypst,yspt,ysst,y0t,rt,yppt0,ypst0,ysst0,Ytraf1,Ytraf2,Ytraf0,nt,nt1,nt2]=trafofcc(fide,fids,nudos,trafos,nn,cnombre);
   Yred=Yred+Ytraf1;
   Yred2=Yred2+Ytraf2;
   Yred0=Yred0+Ytraf0;
end
%
%Lectura del número máximo de iteraciones:
maxiter=fscanf(fide,'%d',1);
%Lectura de la tolerancia:
tol=fscanf(fide,'%f',1);
fprintf(fids,'\n\nmaxiter  tolerancia \n\n');
fprintf(fids,'%6d%14.7f\n',maxiter,tol);
fprintf(fids,'\n\n FIN DEL LISTADO DE LOS DATOS DE ENTRADA DEL FLUJO DE CARGAS. \n\n');
%
%**************************************************************
% FIN DE LA LECTURA DE DATOS DEL FLUJO DE CARGAS
%**************************************************************
%
%
%**************************************************************
%  FLUJO DE CARGAS POR NEWTON-RAPHSON
%**************************************************************
%
% Valores iniciales.
fdada=[P;Q];
s=unudos.*conj(Yred*unudos);
pcalc=real(s(2:nudos));
qcalc=[];
if nudospq>0
   qcalc=imag(s(nudospu+1:nudos));
end
fcalc=[pcalc;qcalc];
iter=0;
uteta=angle(unudos);
umod=abs(unudos);
tetacalc=(uteta(2:nudos));
ucalc=[];
if nudospq>0
   ucalc=(umod(nudospu+1:nudos));
end
xcalc=[tetacalc;ucalc];
uref=[ones(nudos-1,1);ucalc]; % Correción para usar deltaU/U, en lugar de deltaU.
%
% Comienzo de las iteraciones.
%
minerror=[100,0]; % Inicializar vector con error mínimo e iteración.
while ((max(abs(fdada-fcalc)) > tol)|(cambioti>0)) & (iter<maxiter)
   cambioti=0; % Control de cambio de tipo durante la iteración.
   iter = iter+1;
   J=jacobisp(unudos,Yred); % Jacobiana de todos los nudos.
   J11=J(2:nudos,2:nudos);
   J12=[];
   J21=[];
   J22=[];
%
   if nudospq>0
      J12=J(2:nudos,nudos+nudospu+1:nudos+nudos);
      J21=J(nudos+nudospu+1:nudos+nudos,2:nudos);
      J22=J(nudos+nudospu+1:nudos+nudos,nudos+nudospu+1:nudos+nudos);
   end
%
   Jred=[J11 J12;J21 J22]; % Matriz Jacobiana
   xcalc=xcalc+uref.*(inv(Jred)*(fdada-fcalc)); % uref está para usar deltaU/U, en lugar de deltaU.
   tetacalc=xcalc(1:nudos-1);
   ucalc=[];
%
   if nudospq>0
      ucalc=xcalc(nudos:nudos+nudospq-1);
   end
%
   uref=[ones(nudos-1,1);ucalc]; % Correción para usar deltaU/U, en lugar de deltaU.
   unudos=[umod(1:nudospu);ucalc].*exp(j*[uteta(1,1);tetacalc]);
   s=unudos.*conj(Yred*unudos);
%
 
% ***********************************************************
% Comprobación de los límites de reactiva y de las tensiones.
% ***********************************************************
%
if (limitesq==1) | (limitesu==1)
       for k=2:nudos
% Verificar límites de reactiva.
         if(limitesq==1) & (iter>2)
            [nudospu,nudospq,limites,tipo,cambioti,unudos,qnudos]=qmaxmin(nudospu,nudospq,limites,tipo,tipoi,unudos,udada,qnudos,s,qumax,qumin,k,cambioti);
        end 
% Verificar límites de tensiones.
         if (limitesu==1) & (iter>2) 
            [nudospu,nudospq,limites,tipo,cambioti,unudos]=umaxmin(nudospu,nudospq,limites,tipo,tipoi,unudos,udada,qnudos,s,qumax,qumin,k,cambioti);
			end
        end % fin del 'for'
%
%Ordenar de nuevo los nudos.
%
      k1=find(tipo==1);
      k2=find(tipo==2);
      k3=find(tipo==3);
      korden=[k1 k2 k3];
      [orden,korigen]=sort(korden); % Vector para volver al órden inicial.
      unudos=unudos(korden);
      snudos=snudos(korden);
      scarga=scarga(korden);
      s=s(korden);
      qnudos=qnudos(korden);
      qumax=qumax(korden);
      qumin=qumin(korden);
      tipo=tipo(korden);
      tipoi=tipoi(korden);
      Yred=Yred(korden,korden);
      Yred2=Yred2(korden,korden);
      Yred0=Yred0(korden,korden);
      nn=nn(korden,:);
      limites=limites(korden,:);
      Gcarga=Gcarga(korden);
      Bcarga=Bcarga(korden);
      Bcomp=Bcomp(korden);
      udada=udada(korden);
%
      P=real(snudos(2:nudos));
      Q=qnudos(nudospu+1:nudos);
      fdada=[P;Q];
      uteta=angle(unudos);
      umod=abs(unudos);
      tetacalc=(uteta(2:nudos));
      ucalc=[];
%
      if nudospq>0
         ucalc=(umod(nudospu+1:nudos));
      end
%
      xcalc=[tetacalc;ucalc];
      uref=[ones(nudos-1,1);ucalc]; % Correción para usar deltaU/U, en lugar de deltaU.
      
  end % fin del control de los límites de tensiones y de reactiva.
  %
% *********************************************************************
% Fin de la comprobación de los límites de reactiva y de las tensiones.
% *********************************************************************
%
   pcalc=real(s(2:nudos));
   qcalc=[];
   Q=[];
%
   if nudospq>0
      qcalc=imag(s(nudospu+1:nudos));
   end
%
   fcalc=[pcalc;qcalc];
%
    minerror=[min(minerror(1),max(abs(fdada-fcalc))),iter];
   if iter==maxiter
      fprintf(fids,'Sin converger después de maxiter iteraciones: %4d\n',iter);
      fprintf(fids,'El error mínimo= %10.7f',minerror(1));
      fprintf(fids,', se obtuvo en la iteración: %4d\n\n\n',minerror(2));
   end
end
%
umod=abs(unudos);
ufase=(180/pi)*angle(unudos);
sz=((Gcarga+j*Bcarga).*umod').*umod'; % Cargas que son impedancias.
Pcarga=real(sz+scarga);
Qcarga=imag(sz+scarga);
Qcomp=(Bcomp.*umod').*umod'; % Reactiva de compensación.
sgen=s.'+scarga; % Potencias complejas de generación.
Pgen=real(sgen);
Qgen=imag(sgen);
si=s.'-sz; %Potencias complejas inyectadas en los nudos.
perdidas=ones(size(si))*(si+j*Qcomp).';
%
% Salida de resultados.
[nudo1lin,nudo2lin,nudo1traf,nudo2traf]=salidafc(fids,nudos,nn,unudos,umod,ufase,lineas,nl,nl1,nl2,yppl,ypsl,trafos,nt,nt1,nt2,yppt,ypst,yspt,ysst,Pgen,Qgen,Pcarga,Qcarga,Qcomp,perdidas,limites);
%

   if fids==1
      fprintf(fids,'\n\nPuede examinar los resultados. Pulse cualquier tecla para continuar.\n\n');
      pause
   end
%

% *************************************************************************
%                          ANÁLISIS DE ESTABILIDAD
% *************************************************************************
%
fallos=input('¿Se vá a estudiar la estabilidad? s/n (s): ','s');
	if isempty(fallos)
		fallos='s';
   end
%
if (fallos=='s'| fallos=='S')
[tiempo,wr,delta,deltarel,ng,nomg,ngr,nomgr]=estabtr(fide,fids,nudos,nn,cnombre,lineas,nl,nudo1lin,nudo2lin,yppl,ypsl,yppl0,ypsl0,unudos,Yred,Yred2,Yred0,scarga,sgen);
end
%
fclose('all');

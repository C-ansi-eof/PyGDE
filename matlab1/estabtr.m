function[tiempo,wr,delta,deltarel,ng,nomg,ngr,nomgr]=estabtr(fide,fids,nnu,nn,cnombre,nlin,nl,n1li,n2li,yppl,ypsl,yppl0,ypsl0,unudos,Yn1,Yn2,Yn0,scarga,sgen)
% Programa para el análisis de estabilidad. (Abril-1998)
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
%**************************************************************
%
inudos=Yn1*unudos;
Sin=unudos.*conj(inudos); % Potencias complejas inyectadas en los nudos.
numlin=[1:nlin];
% Buscar el identificador @ de comienzo de los datos.
k=0;
while k==0
   [A,count]=fscanf(fide,'%s',1);
   if A(1)=='@'
      k=1;
   end
end
fprintf(fids,'\n\nLISTADO DE LOS DATOS DE ENTRADA: \n\n');
%
%
% Lectura de los datos de las máquinas.
%
clave=leeclave(fide,fids,'Generadores:');
fprintf(fids,'%s\n',clave);
ngen=fscanf(fide,'%d',1); % Número de generadores.
fprintf(fids,'\n\nDATOS ADICIONALES PARA EL ANALISIS DE ESTABILIDAD: \n\n');
fprintf(fids,'\n\nDATOS DE LAS MAQUINAS: \n\n');
fprintf(fids,'Número total de maquinas:%4d\n',ngen);
nugeni=[];
if ngen~=0
   egen=zeros(ngen,1);
   fprintf(fids,'\n\n  nombre      nudo        Pgen      Qgen       R1        X1        R2        X2        R0        X0    conext     Rt        Xt        H          D\n\n');
   for k=1:ngen
      nombregen=leernomb(fide,fids,cnombre,'del generador');
      nomg(k,1:cnombre)=nombregen;
      nombrenug=leernomb(fide,fids,cnombre,'del nudo generador');
      n1=buscar(fide,fids,nombrenug,nn,'No se encontró el nudo generador: ');
      nugeni(k)=n1; % Nudos con generador.
      dgen=fscanf(fide,'%f %f %f %f %f %f %f %f %d %f %f  %f  %f ',13);
      zg1(k)=dgen(3,:)+j*dgen(4,:); % Impedancia transitoria de los generadores.
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
      egen(k)=ugen(k)+zg1(k)*conj(Sgen(k)/ugen(k)); % Tensiones internas de los generadores.
      H(k)=dgen(12,:);
      D(k)=dgen(13,:);
      fprintf(fids,'%s  %s  %10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%7.0f%10.4f%10.4f%10.4f%10.4f\n',nomg(k,:),nombrenug(1,:),real(Sgen(k)),imag(Sgen(k)),dgen(3:13));
   end
end
%
%
clave=leeclave(fide,fids,'Fin');
fprintf(fids,'%s\n',clave);
fprintf(fids,'\n\n FIN DEL LISTADO DE LOS DATOS ADICIONALES \n\n');
%*********************** Fin de la lectura de datos *********************
%
%
% Construcción de las matrices de admitancias de nudos.
%
nudosi=[1:nnu]; % Numeración interna de los nudos.
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
% Admitancias de los generadores.
Cgen=sparse(nugeni,[1:ngen],ones(1,ngen),nnu,ngen); % Matriz de conexión.
Ygen1=Cgen*sparse(diag(yg1))*Cgen';
Ygen2=Cgen*sparse(diag(yg2))*Cgen';
Ygen0=Cgen*sparse(diag(yg0))*Cgen';
Yn1=Yn1+Ygen1;
Yn2=Yn2+Ygen2;
Yn0=Yn0+Ygen0;
%
% Matrices de impedancias de nudos.
%
Zn1=inv(Yn1);
Zn2=inv(Yn2);
%
% Evitar la posible singularidad de Yn0.
%
if condest(Yn0)>1.e10
   sumafilas=abs(Yn0*ones(nnu,1))
   k=find(sumafilas<1.e-10);
   k1=size(k,1);
   ky0=j*1.e-8*sparse([1:k1],[1:k1],ones(1,k1));
   Yn0(k,k)=Yn0(k,k)+ky0;
   disp('singularidad en Yn0')
end
%
Zn0=inv(Yn0);
%
% Condiciones previas a la falta.
%
Ygg=Ygen1(nugeni,nugeni);
Yng=Ygen1(:,nugeni);
Yggeq=Ygg-Yng.'*Zn1*Yng;
Igen=Yggeq*egen;
sgeneq=egen.*conj(Igen);
Pmec=real(sgeneq); % Potencias mecánicas constantes. (Máquina clásica)
egenm=abs(egen);  % Tensiones internas transitorias constantes. (Máquina clásica)
delta00=angle(egen); % Argumentos iniciales de las tensiones internas.
f=input('frecuencia de la red, ([]=50 Hz): ');
if isempty(f)
   f=50;
end
kH=H.\(pi*f);
%
cc1='FALTA TRIFÁSICA';
cc2='FALTA A TIERRA DE LA FASE A';
cc3='FALTA ENTRE LAS FASES B Y C';
cc4='FALTA A TIERRA DE LAS FASES B Y C';
cc5='FALTA A TIERRA DE LA FASE A, CON REENGANCHE MONOFÁSICO';
cc6='NO CONSIDERAR MAS FALLOS';
tipocc=str2mat(cc1,cc2,cc3,cc4,cc5,cc6);
opcion=menu('Tipo de falta',cc1,cc2,cc3,cc4,cc5,cc6);
while opcion<6
   nlfi=[];
   while isempty(nlfi)
      fprintf(1,'\nLíneas de la red:\n\n');
      for k=1:nlin
         fprintf(1,'%8d %s\n',numlin(k),nl(k,:));
      end
      nlf=input('Línea en la que se desea simular la falta: ');
      nlfi=find(numlin==nlf);
      if isempty(nlfi)
         fprintf(1,'\nLa línea número%4d, no es de la red.\n',nlf);
      end
   end
   nf1i=n1li(nlfi);
   nf2i=n2li(nlfi);
   fprintf(1,'\nLos nudos extremos de la línea son el %4d ( %s ) y el %4d ( %s )\n',nf1i,nn(nf1i,:),nf2i,nn(nf2i,:));
   nfi=0;
   while nfi==0
      nf=input('Extremo en el que se produce el corto: ');
      if nf ~=nf1i & nf ~=nf2i
         fprintf(1,'\nEl nudo número%4d, no es de la línea.\n',nf);
         fprintf(1,'\nLos extremos de la línea son:\n\n');
         fprintf(1,'%8d y %8d\n',nf1i,nf2i);
      else
         nfi=nf;
      end
   end
%
   leert=0;
   while leert==0
      ta=input('Instante de eliminación de la falta: ');
      tr=input('Instante del reenganche de la línea: ');
      tf=input('Instante final de la simulación: ');
      fprintf(1,'\n*****\n\nInstante de eliminación de la falta: %6.4f\n\nInstante del reenganche de la línea: %6.4f\n\nInstante final de la simulación:     %6.4f\n\n*****\n',ta,tr,tf);
      if tr<ta
         fprintf(1,'\n***** Error: El instante del reenganche de la línea: %6.4f\n\nes menor que el instante de apertura: %6.4f\n',tr,ta);
      end
      if tr>=tf
         fprintf(1,'\n***** La línea no reengancha. Reenganche en tr=  %6.4f\n\n***** final del estudio en tf=  %6.4f\n',tr,tf);
         tr=tf;
      end
      releer=input('¿Datos correctos? s/n (s): ','s');
      if isempty(releer)
         releer='s';
      end
%
      if (releer=='s' | releer=='S')
         leert=1;
      end
   end
%
   Yn1f=Yn1;
   Yngf=Yng;
   if opcion==1  % Cortocircuito trifásico en el nudo nfi
      Yn1f(:,nfi)=[];
      Yn1f(nfi,:)=[];
      Yngf(nfi,:)=[];
   end
%
   if opcion==2 | opcion==5 % Cortocircuito monofásico en el nudo nfi
      Yn1f(nfi,nfi)=Yn1f(nfi,nfi)+1/(Zn2(nfi,nfi)+Zn0(nfi,nfi));
   end
%
   if opcion==3  % Cortocircuito bifásico en el nudo nfi
      Yn1f(nfi,nfi)=Yn1f(nfi,nfi)+1/Zn2(nfi,nfi);
   end
%
   if opcion==4  % Cortocircuito bifásico, a tierra, en el nudo nfi
      Yn1f(nfi,nfi)=Yn1f(nfi,nfi)+(Zn2(nfi,nfi)+Zn0(nfi,nfi))/(Zn2(nfi,nfi)*Zn0(nfi,nfi));
   end
%
   Yggf=Ygg-Yngf.'*inv(Yn1f)*Yngf;
%
%Apertura de la línea nlfi (nudos nf1i-nf2i)
   Clin1=sparse(n1li(nlfi),1,1,nnu,1); % Matriz de conexión.
   Clin2=sparse(n2li(nlfi),1,1,nnu,1); % Matriz de conexión.
   ylin=Clin1*yppl(nlfi,nlfi)*Clin1'+Clin1*ypsl(nlfi,nlfi)*Clin2'+Clin2*ypsl(nlfi,nlfi)*Clin1'+Clin2*yppl(nlfi,nlfi)*Clin2';
   Yn1a=Yn1-ylin;
   if opcion==5 % Apertura monofásica.
      if nnz(ypsl0(nlfi,:))>1
         error('*** El programa no está preparado para la apertura monofásica de líneas acopladas. ***')
      end
      Zn1a=inv(Yn1a);
      Yn2a=Yn2-ylin;
      ylin0=Clin1*yppl0(nlfi,nlfi)*Clin1'+Clin1*ypsl0(nlfi,nlfi)*Clin2'+Clin2*ypsl0(nlfi,nlfi)*Clin1'+Clin2*yppl0(nlfi,nlfi)*Clin2';
      Yn0a=Yn0-ylin0;
      Zn2a=inv(Yn2a);
% Evitar la posible singularidad de Yn0a.
%
      if condest(Yn0a)>1.e10
         sumafilas=abs(Yn0a*ones(nnu,1));
         k=find(sumafilas<1.e-10);
	 k1=size(k,1);
         ky0a=j*1.e-8*sparse([1:k1],[1:k1],ones(1,k1));
         Yn0a(k,k)=Yn0a(k,k)+ky0a;
         disp('singularidad en Yn0a')
      end
%
      Zn0a=inv(Yn0a);
      ylserie=-ypsl(nlfi,nlfi);
      ylpar=yppl(nlfi,nlfi)+ypsl(nlfi,nlfi);
      ylserie0=-ypsl0(nlfi,nlfi);
      ylpar0=yppl0(nlfi,nlfi)+ypsl0(nlfi,nlfi);
      if ylpar==0 & ylpar0==0
         zeq2=(1/ylserie)+Zn2a(nf1i,nf1i)+Zn2a(nf2i,nf2i)-Zn2a(nf1i,nf2i)-Zn2a(nf2i,nf1i);
         zeq0=(1/ylserie0)+Zn0a(nf1i,nf1i)+Zn0a(nf2i,nf2i)-Zn0a(nf1i,nf2i)-Zn0a(nf2i,nf1i);
         zserie=(1/ylserie)+zeq2*zeq0/(zeq2+zeq0);
         ysumar=(1/zserie)*[1 -1 ; -1 1];
      else
         ylinea=ylin([nf1i, nf2i],[nf1i, nf2i]);
         ylinea0=ylin0([nf1i, nf2i],[nf1i, nf2i]);
         zth1=Zn1([nf1i, nf2i],[nf1i, nf2i]);
         ysim=(1/9)*[4*ylinea0+2*ylinea, -2*ylinea0-ylinea, -2*ylinea0-ylinea;...
         -2*ylinea0-ylinea, ylinea0+5*ylinea, ylinea0-4*ylinea;...
         -2*ylinea0-ylinea, ylinea0-4*ylinea, ylinea0+5*ylinea];
         zreda(1:2,1:2)=Zn0a([nf1i, nf2i],[nf1i, nf2i]);
         zreda(3:4,3:4)=Zn1a([nf1i, nf2i],[nf1i, nf2i]);
         zreda(5:6,5:6)=Zn2a([nf1i, nf2i],[nf1i, nf2i]);
         uno=eye(6);
         yL=inv(uno+ysim*zreda)*ysim;
         yL11=yL(3:4,3:4);
   % Evitar la posible singularidad de yL11.
%
         if condest(yL11)>1.e10
            sumafilas=abs(yL11*ones(2,1));
            k=find(sumafilas<1.e-10);
            k1=size(k,1);
            ky0a=j*1.e-8*sparse([1:k1],[1:k1],ones(1,k1));
            yL11(k,k)=yL11(k,k)+ky0a;
            disp('singularidad en yL11')
         end
%
         zth1a=Zn1a([nf1i, nf2i],[nf1i, nf2i]);
         zsumar=inv(yL11)-zth1a;
         ysumar=inv(zsumar);
      end
%
      Yn1a([nf1i, nf2i],[nf1i, nf2i])=Yn1a([nf1i, nf2i],[nf1i, nf2i])+ysumar;
   end
   Ygga=Ygg-Yng.'*inv(Yn1a)*Yng;
   Igena=Ygga*egen;
   sgena=egen.*conj(Igena);
%
%
   kD=-kH.*D;
   t0=0;
   x0=[zeros(1,ngen),delta00'];
   wr0=zeros(1,ngen);
   delta0=delta00;
   wr=[];
   delta=[];
   tiempo=[];
   fprintf(fids,'\n\n************************************************************************\n\n');       
   fprintf(fids,'\n\n************************************************************************\n\n');       
   k=1;
   while k<=3
      if k==1 % Situación de fallo.
         fprintf(fids,'\n\n  %s\n',tipocc(opcion,:));
         fprintf(fids,'\n  EN EL NUDO%4d   DE LA LINEA%4d\n\n',nf,nlf);
         Yeq=Yggf;
         t0=0;
         tfin=ta;
      end
      if k==2 % Apertura de la línea.
         fprintf(fids,'\n  APERTURA DE LA LINEA A LOS %8.5f  segundos\n\n',ta);
         Yeq=Ygga;
         t0=ta;
         tfin=tr;
      end
      if k==2 & ta==tr
			k=3;
      end
      if k==3 % Reenganche de la línea.
         fprintf(fids,'\n  REENGANCHE DE LA LINEA A LOS %8.5f  segundos\n\n',tr);
         Yeq=Yggeq;
         t0=tr;
         tfin=tf;
      end
      Yeqv=reshape(full(Yeq),1,ngen*ngen);
      datosgen=[kD,kH,Pmec',egenm',real(Yeqv),imag(Yeqv)];
      [t,x]=ode45('oscilams',[t0,tfin],x0,[],datosgen); % Solución de las ecuaciones de oscilación.
      wr=[wr;x(:,1:ngen)]; % Pulsaciones relativas.
      delta=[delta;x(:,ngen+1:2*ngen)]; % Ángulos internos.
      tiempo=[tiempo;t];
% Actualizar los valores iniciales.
      [filas,col]=size(x);
      x0=x(filas,:);
      delta0=x(filas,ngen+1:2*ngen)';
      k=k+1;
   end
%
% Referir los ángulos a un generador.
% El generador número 0 representa la referencia de pulsación nominal.
%
   delta=(180/pi)*delta; % Ángulos en grados. 
   deltarel=delta;
   ngenref=0;
   ng=[1:ngen];
   ngr=ng;
   nomgr=nomg;
   fprintf(1,'\nGeneradores de la red: \n\n');
for k=1:ngen
   fprintf(1,'%8d  %s\n',k,nomg(k,:));
end
   genref=input('Número del generador al que se refieren los ángulos, ([]= 0): ');	   
   if isempty(genref) | genref==0
      genrefi=0;
      genref=0;
      ngenref=1;
   end
   while ngenref==0
      ngenref=1;
      genrefi=find(ngr==genref);
      if isempty(genrefi)
         fprintf(1,'\nEl generador número%4d, no es de la red.\n',genref);
   	 fprintf(1,'\nGeneradores de la red: \n\n');
   	 fprintf(1,'%8d\n',numgen);
         genref=input('Número del generador al que se refieren los ángulos, ([]= 0): ');	   
	 ngenref=0;
      end
   end
%
nombregenr=' 0 ';
   if genrefi~=0
		nombregenr=nomg(genrefi,:);
      ngr(:,genrefi)=[]
      nomgr(genrefi,:)=[]
      deltaref=delta(:,genrefi);
      deltarel(:,genrefi)=[];
      for k=1:ngen-1
         deltarel(:,k)=deltarel(:,k)-deltaref;
      end
   end
%
% Gráfica de los ángulos en función del tiempo.
%
   [puntos,angulos]=size(deltarel);
   plot(tiempo,deltarel)
   hold on
   xy=(axis);
   ymax=xy(3);
   ymin=xy(4);
   plot([ta,ta],[ymin,ymax],'w:')
   text(ta,(2*ymax+ymin)/3,['apertura a los ',num2str(ta),' segundos'])
   plot([tr,tr],[ymin,ymax],'w:')
   text(tr,(ymax+2*ymin)/3,['reenganche a los ',num2str(tr),' segundos'])
   title([tipocc(opcion,:),' en el nudo ',nn(nf,:), ' de la línea ',nl(nlf,:)]);
   ylabel(['    Angulos,en grados, respecto al generador ',nombregenr]);
   xlabel('Tiempo en segundos');
   ngenr=length(ngr);
   xtexto=round(0.5*puntos/ngenr)-1;
   cabecera='      t(s) ';
   for k=1:ngenr
      text(tiempo(xtexto*k),deltarel(xtexto*k,k),nomgr(k,:))
      text(tiempo(xtexto*(k+ngenr)),deltarel(xtexto*(k+ngenr),k),nomgr(k,:))
      cabecera=[cabecera,nomgr(k,:)];
   end
   pause
   close
%
% Salida numérica de los ángulos en función del tiempo.
%
   fprintf(fids,'\n%s\n\n',['    Angulos,en grados, respecto al generador ',int2str(genref)]);
   fprintf(fids,'\n     Tiempo      Angulos\n\n');
   salida=[tiempo';deltarel'];
   fprintf(fids,'%s',cabecera);
   for k=1:puntos
      fprintf(fids,'\n\n');
      fprintf(fids,'%12.6f',salida(:,k));
   end 
   fprintf(fids,'\n\n************************************************************************\n\n');       
   opcion=menu('Tipo de falta',cc1,cc2,cc3,cc4,cc5,cc6);    
end
%
fclose('all');
     
function[limites,nn,tipoi,tipo,unudos,udada,snudos,scarga,Gcarga,Bcarga,Bcomp,qumax,qumin,Yred]=nudosfcc(fid,fids,nudos,cnombre,limitesq,limitesu,Yred)
%
% Flujo de cargas, (fcycc):Lectura de los datos de los nudos.
%
unudos=zeros(nudos,1);
snudos=zeros(nudos,1);
nn=[];
fprintf(fids,'\n\n   nombre  tipo     Umod      Uarg      Pgen     Bcomp    Pcarga    Gcarga    Qcarga    Bcarga      Qgen    Q/Umax    Q/Umin \n\n');
for k=1:nudos
   limites(k,:)='....';  % Inicializar la matriz indicadora de los límites.
   nn(k,1:cnombre)=leernomb(fid,fids,cnombre,'del nudo');
  [As,count]=fscanf(fid,'%s',1); % Identificación del nudo.
      if As=='Ua'
         tipoi(k)=1; % Tipo de nudo. Se mantiene durante el estudio.
         tipo(k)=1; % Variable durante el estudio.
      end
%
      if As=='PU'
         tipoi(k)=2;
         tipo(k)=2;
      end
%
      if As=='PQ'
         tipoi(k)=3;
         tipo(k)=3;
      end
%
	[A,count]=fscanf(fid,'%f',13); % Datos restantes del nudo.
      if (A(6)~=0)&(A(7)~=2)
	 fclose('all');
         error('Datos erróneos de la demanda de activa. En: P=G.U^exp, exp debe de ser 2.');
      end
%
      if (A(9)~=0)&(A(10)~=2)
	 fclose('all');
         error('Datos erróneos de la demanda de reactiva. En: Q=B.U^exp, exp debe de ser 2.');
      end
   unudos(k)=A(1)*exp(j*pi*A(2)/180); % Tensión compleja.
   snudos(k)=(A(3)-A(5))+j*(A(11)-A(8)); % Potencia compleja inyectada.
   scarga(k)=A(5)+j*A(8); % Carga como potencias constantes.
   Yred(k,k)=Yred(k,k)+j*A(4)+A(6)-j*A(9); % Compensación y cargas como admitancias.
   udada(k)=A(1); % Tensión a mantener en los nudos PU.
   qumax(k)=A(12); % Límite máximo de la tensión, o de la reactiva.
   qumin(k)=A(13); % Límite mínimo de la tensión, o de la reactiva.
   Gcarga(k)=A(6);
   Bcarga(k)=A(9);
   Bcomp(k)=A(4);
%
   if (tipo(k)==2) & (limitesq==1)
      if qumax(k)==0.0
         qumax(k)=0.75*A(3); % Qmaxgen=0.75*Pgen
      end
      qumax(k)=qumax(k)-A(8); % Límite máximo de la reactiva.
      qumin(k)=A(13)-A(8); % Límite mínimo de la reactiva.
   end
%
   if (tipo(k)==3) & (limitesu==1)
      if qumax(k)==0.0
         qumax(k)=1.1; % Umax=1.1 p.u.
      end
   end
fprintf(fids,'%s    %s%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f\n',nn(k,:),As,A(1:6),A(8),A(9),A(11),qumax(k),qumin(k)); 
end   
%
%Fin de los datos de nudos.
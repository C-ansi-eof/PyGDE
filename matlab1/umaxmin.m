function[nudospu,nudospq,limites,tipo,cambioti,unudos]=umaxmin(nudospu,nudospq,limites,tipo,tipoi,unudos,udada,qnudos,s,qumax,qumin,k,cambioti)
%
% Verifica los límites de tensiones de los nudos PQ.
% Si se violan los límites, el nudo cambia a PU.
% En iteraciones posteriores puede volver a PQ.
% cambioti=1, indica que se ha producido algún cambio de tipo de nudo.    
%
if(tipoi(k))==3
   if (((abs(unudos(k))==qumax(k))&(imag(s(k))>qnudos(k))))|(((abs(unudos(k))==qumin(k))&(imag(s(k))<qnudos(k)))&(tipo(k)==2))
      tipo(k)=3;
      cambioti=cambioti+1;
      nudospu=nudospu-1;
      nudospq=nudospq+1;
      limites(k,:)='....';
   else
%
   if (abs(unudos(k))>qumax(k))&(tipo(k)==3)
      tipo(k)=2;
      cambioti=cambioti+1;
      nudospu=nudospu+1;
      nudospq=nudospq-1;
      unudos(k)=qumax(k)*exp(j*angle(unudos(k)));
      limites(k,:)='Umax';
   else
%
   if (abs(unudos(k))<qumin(k))&(tipo(k)==3)
      tipo(k)=2;
      cambioti=cambioti+1;
      nudospu=nudospu+1;
      nudospq=nudospq-1;
      unudos(k)=qumin(k)*exp(j*angle(unudos(k)));
      limites(k,:)='Umin';
   end
   end
   end
end
			
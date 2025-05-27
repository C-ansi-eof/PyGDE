function[nudospu,nudospq,limites,tipo,cambioti,unudos,qnudos]=qmaxmin(nudospu,nudospq,limites,tipo,tipoi,unudos,udada,qnudos,s,qumax,qumin,k,cambioti)

% Verifica los límites de reactiva de los nudos PU.
% Si se violan los límites, el nudo cambia a PQ.
% En iteraciones posteriores puede volver a PU.
% cambioti=1, indica que se ha producido algún cambio de tipo de nudo.    
%
if(tipoi(k))==2 
   %if (((tipo(k)==3)&(imag(s(k))<=qumax(k))&(abs(unudos(k))>=udada(k))))|(((tipo(k)==3)&(imag(s(k))>=qumax(k))&(abs(unudos(k))<udada(k))))
  if (((tipo(k)==3)&(imag(s(k))>qumax(k))&(abs(unudos(k))>udada(k))))|(((tipo(k)==3)&(imag(s(k))<qumin(k))&(abs(unudos(k))<udada(k))))
       tipo(k)=2;
		cambioti=cambioti+1;
      nudospq=nudospq-1;
      nudospu=nudospu+1;
      unudos(k)=udada(k)*exp(j*angle(unudos(k)));
      limites(k,:)='....';
   else
%
if (imag(s(k))>=qumax(k))&(tipo(k)==2)
   	tipo(k)=3;
   	cambioti=cambioti+1;
      nudospq=nudospq+1;
      nudospu=nudospu-1;
      qnudos(k)=qumax(k);
      limites(k,:)='Qmax';
   else
%
   if (qumin(k)>=imag(s(k)))&(tipo(k)==2)
      tipo(k)=3;
      cambioti=cambioti+1;
      nudospq=nudospq+1;
      nudospu=nudospu-1;
      qnudos(k)=qumin(k);
      limites(k,:)='Qmin';
   end
   end
   end
end
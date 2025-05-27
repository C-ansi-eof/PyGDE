 function[indice]=buscar(fide,fids,Nombre,nn,mensaje)
   kf=1;
   indice=0;
   filas=size(nn,1);
   while (kf<=filas) & (indice==0)
      if nn(kf,:)==Nombre 
         indice=kf;
      end
   kf=kf+1;
	end
	if indice==0
	  fprintf(fids,'%s %s\n\n',mensaje,Nombre);
	  fclose('all');
          error(mensaje);
	end
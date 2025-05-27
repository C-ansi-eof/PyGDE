 function[indice]=buscar(Nombre,nn)
   kf=1;
   indice=0;
   filas=size(nn,1);
   while (kf<=filas) & (indice==0)
      if nn(kf,:)==Nombre 
         indice=kf;
      end
   kf=kf+1;
   end
function[Nombre]=leernomb(fid,fids,cnombre,mensaje)
[As,count]=fscanf(fid,'%s',1); % Leer el nombre.
      nblancos=cnombre-max(size(As)); % Admitir un máximo de cnombre caracteres.
      Nombre=[blanks(nblancos) As];
      if nblancos<0
         Nombre=As(:,1:cnombre);
         nblancos=0;
         fprintf(fids,'Se trunca el nombre %s a los %d primeros caracteres: %s\n\n',mensaje,cnombre,Nombre);
      end
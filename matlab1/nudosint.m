function[nudoi,nudo]=nudosint(fide,fids,nuelem,nudo,nudos,mensaje)
nudoi=[];
for k=1:nuelem
   knum=find(nudos==nudo(k));% Convertir a la numeración interna.
   if  isempty(knum)
      fprintf(fids,'\n\n%s %8d\n\n',mensaje,nudo(k));
      fclose('all');
      error(mensaje);    
   end
   nudoi(k)=knum;
end
function[lectura]=leeclave(fide,fids,clave)
lectura=fscanf(fide,'%s',1);
if ~strcmp(lectura,clave)
fprintf(fids,'\n\n***ERROR*** Se ha leido la clave: " %s ", en lugar de: " %s "\n\n',lectura,clave);
close('all');
error('clave incorrecta');
end
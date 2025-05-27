function[yg1,yg2,yg0,Ygen1,Ygen2,Ygen0,ng,nugeni,Sgn,ugen,egen,H,D]=dgenest(fide,fids,nnu,ngen,nudos,unudos)
dgen=fscanf(fide,'%d %d %f %f %f %f %f %f %f %f %d %f %f %f %f',[15 ngen]);
fprintf(fids,'%4d %4d %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %4d %8.4f %8.4f %8.4f %8.4f\n',dgen);
ng=dgen(1,:); % Número identificador del generador.
nugen=dgen(2,:); % Nudos con generador.
zg1=dgen(5,:)+j*dgen(6,:); % Impedancias de secuencia directa de los generadores.
yg1=zg1.\1;
zg2=dgen(7,:)+j*dgen(8,:); % Impedancias de secuencia inversa de los generadores.
yg2=zg2.\1;
zg0=dgen(9,:)+j*dgen(10,:); % Impedancias de secuencia homopolar de los generadores.
zgt=dgen(12,:)+j*dgen(13,:); % Impedancias de puesta a tierra de los generadores.
yg0=(zg0+3*zgt).\1;
yg0=yg0.*dgen(11,:); % Anular las yg0 de los generadores sin puesta a tierra.
% Convertir a la numeración interna.
[nugeni,nugen]=nudosint(fide,fids,ngen,nugen,nudos,'Generador/Motor. No se encontró el nudo: ');
%
Cgen=sparse(nugeni,[1:ngen],ones(1,ngen),nnu,ngen); % Matriz de conexión.
Ygen1=Cgen*sparse(diag(yg1))*Cgen';
Ygen2=Cgen*sparse(diag(yg2))*Cgen';
Ygen0=Cgen*sparse(diag(yg0))*Cgen';
Sgen=dgen(3,:)+j*dgen(4,:); % Potencias complejas generadas.
ugen=unudos(:,nugeni); % Tensiones de los nudos con generador.
egen=ugen+zg1.*conj(Sgen./ugen); % Tensiones internas de los generadores.
egen=egen.'; % Cambiar a vector columna.
Sgn=Cgen*Sgen.';
H=dgen(14,:);
D=dgen(15,:);

function[Ifase]=ifasegm(fids,T,ngm,nui,nn,nngm,e,ucc0,ucc1,ucc2,y1,y2,y0)
% Calcular e imprimir las intensidades de líneas/trafos.
% Ipfase: Intensidades de fase de los primarios (origen).
% Isfase: Intensidades de fase de los secundarios (final).
% fids: fichero de salida.
% T: Matriz de transformación.
% ngm: Número de generadores/motores.
% nui: Vector de nudos con generador/motor.
% nn: Vector de nombres de nudos.
% nngm: Vector de nombres de generadores/motores.
% e: Vector de tensiones internas de los generadores/motores.
% ucc0: Tensiones de cortocircuito de secuencia homopolar.
% ucc1: Tensiones de cortocircuito de secuencia directa.
% ucc2: Tensiones de cortocircuito de secuencia inversa.
% y1: Admitancia de secuencia directa de los generadores/motores.
% y2: Admitancia de secuencia inversa de los generadores/motores.
% y0: Admitancia de secuencia homopolar de los generadores/motores.
%
I1=(y1.').*(e-ucc1(nui));
I2=-(y2.').*ucc2(nui);
I0=-(y0.').*ucc0(nui);
Isim=[I0.';I1.';I2.'];
Ifase=(T*Isim).';
Ifasem=abs(Ifase); 
Ifasea=180*angle(Ifase)/pi; 
%
for k=1:ngm
   genmot=nngm(k,:);
   Nudoa=nn(nui(k),:);
   A=[Ifasem(k,:);Ifasea(k,:)];
   fprintf(fids,'%s %s %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f\n',genmot,Nudoa,A);
end   


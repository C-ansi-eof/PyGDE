function J=jacobisp(U,Y)
%Function J=jacobisp(U,Y)
%Calcula la matriz Jacobiana a partir de la de admitancias y el vector de tensiones.
nudos=max(size(U));
fila=[1:nudos];
col=[fila];
Us=sparse(fila,col,U);
In=Y*U;
S=U.*conj(In);
Ss=sparse(fila,col,S);
A=Us*conj(Y)*conj(Us);
dpa=-imag(Ss-A);
dpu=real((Ss+A));
dqa=real(Ss-A);
dqu=imag((Ss+A));
J=[dpa dpu;dqa dqu];


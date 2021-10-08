function [temp,mask]= shiftbits(temp1,mask1,shift)
[row, col]=size(temp1);   
t1=temp1(:,1:col/2); %atribui a metade esquerda da imagem em t1    
t2=temp1(:,col/2+1:col); %atribui a metade direita da imagem em t1
t1=circshift(t1,[0, shift]); %desloca os bits na coluna
t2=circshift(t2,[0, shift]); %desloca os bits na coluna
temp=[t1 t2]; %

m1=mask1(:,1:col/2);
m2=mask1(:,col/2+1:col);
m1=circshift(m1,[0 shift]);
m2=circshift(m2,[0 shift]);
mask=[m1 m2];
    return;
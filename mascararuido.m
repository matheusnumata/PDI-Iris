function [ruido] = tira_ruido(norm)
%norm = double(imread('C:\PDI\segmentada\1.bmp'));
[l,c]=size(norm);
for i=1:l
    for j=1:c
        if (norm(i,j)==0)
            ruido(i,j)=0;
        else
            ruido(i,j)=1;
        end
    end
end
%imshow(ruido);
        





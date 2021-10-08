localIris = 'C:\PDI\iris\'; %local das imagens originais
localIC='C:\PDI\iriscode\'; %imagens iris code
pessoa=20; %escolher a pessoa 1-20
pasta_img=1; %escolher a pasta de cada pessoa 1
foto_numero=3; %definir qual foto da pasta 


total_comparacoes=0; %total de comparações
certo=0; %caso as caracteristicas estejam dentro do limiar e reconheça, e caso as características estejam fora do limiar, e reconheça que aquela pessoa nao é a mesma pessoa
porcentagem_erro=0; %é o (falso negativo + falso positivo * 100) /total) -> pra reconhecer todos os erros.
falso_negativo=0; %caso as caracteristicas estejam dentro do limiar, porem nao reconhece (falso negativo)
falso_positivo=0; %caso as caracteristicas nao estejam dentro do limiar, e reconhece (falso positivo)


for cont_pessoa=1:pessoa %for para as pessoas
    cont_pessoa;
for cont_pastaimg=1:pasta_img %for para as pastas de cada pessoa
    cont_pastaimg;
for cont_fotonumero=1:foto_numero %for para as 3 imagens
    cont_fotonumero;
    
if(cont_pessoa<10) %concatena cada informação para formar o arquivo correto a ser lido caso seja de 0 a 9
    nome=strcat(localIris,'00',num2str(cont_pessoa),'\',num2str(cont_pastaimg),'\00',num2str(cont_pessoa),'_',num2str(cont_pastaimg),'_',num2str(cont_fotonumero),'.bmp');
elseif (cont_pessoa<100) %concatena cada informação para formar o arquivo correto a ser lido caso seja de 10 a 99
    nome=strcat(localIris,'0',num2str(cont_pessoa),'\',num2str(cont_pastaimg),'\0',num2str(cont_pessoa),'_',num2str(cont_pastaimg),'_',num2str(cont_fotonumero),'.bmp');
else % concatena cada informação para formar o arquivo correto a ser lido caso seja de 100 a 999
    nome=strcat(localIris,num2str(cont_pessoa),'\',num2str(cont_pastaimg),'\',num2str(cont_pessoa),'_',num2str(cont_pastaimg),'_',num2str(cont_fotonumero),'.bmp');
end
 
%leitura da imagem
I = imread('C:\PDI\iris\001\1\001_1_1.bmp'); %le a imagem
%I = imread(nome);
%figure('Name', 'Imagem Original'), imshow(I); %exibe imagem

%binarização
bw = imbinarize(I, 0.26); %binariza imagem com threshold de 0.26
%figure('Name', 'Imagem Binarizada'), imshow(bw); %exibe a imagem

%canny filtro de detecção de borda
canny = edge(bw,'Canny'); %aplica canny com threshold de 0.2 e 2
%figure('Name', 'Imagem com Canny') , imshow(canny); %exibe imagem

Rmin = 30; %raio minimo definido
Rmax = 65; %raio maximo definido

[centersDark, radiiDark] = imfindcircles(canny,[Rmin Rmax],'ObjectPolarity','dark'); %detecta objetos escuros na imagem (pupila)
%viscircles(centersDark, radiiDark,'Color','b'); %exibe o circulo detectado na imagem

%figure('Name', 'Imagem com a Íris Detectada'), imshow(I); %exibe imagem

%disp(centersDark);
%disp(radiiDark);

iris = radiiDark * 2; %define o raio da iris
%disp(iris);
%viscircles(centersDark, iris, 'Color', 'b'); %cria o circulo da imagem
%figure('Name', 'I222222'), imshow(I); %exibe imagem
%disp(centersDark);

%cortar a imagem
x = centersDark(2); %coloca o segundo valor do vetor referente a posiçao do centro da pupila na variavel x
y = centersDark(1); %coloca o primeiro valor do vetor referente a posiçao do centro da pupila na variavel y

imageSize = size(I); %imageSize recebe o tamanho da imagem I
ci = [x, y, iris]; %centro da pupila e raio da íris na variável ci
[xx,yy] = ndgrid((1:imageSize(1))-ci(1),(1:imageSize(2))-ci(2)); %cria um grid com os tamanhos xy da imagem que está sendo lida
mask = uint8((xx.^2 + yy.^2)<ci(3)^2); %%cria uma mascara com um valor q a soma de xx yy elevado ao quadrado seja menor que o raio da pupila ao quadrado
croppedImage = uint8(zeros(size(I))); %cria um vetor de 0s no tamanho da imagem original
croppedImage(:,:,1) = I(:,:,1).*mask; %passa a matriz I, em todos os intervalos para os pixels da mask
%croppedImage(:,:,1) = I(:,:,1).*mask;
%croppedImage(:,:,1) = I(:,:,1).*mask;

%figure('Name', 'Circulo'), imshow(croppedImage); %exibe imagem cortada

%normalizaçao
%M = double(croppedImage)/255.0;

normalizada = ImToPolar(croppedImage, 0, 0.1, 50, 200, centersDark); %realiza a normalização
%figure('Name', 'Imagem Normalizada'), imshow(normalizada); %exibe imagem normalizada

%tira ruido
ruido=mascararuido(normalizada); %aplica a mascara de tirar ruido

%gabor/wavelet
[irisCode, mascara]=extracao(normalizada, ruido, 1, 12, 0.5, 0.5); %aplica gabor
%nome_seg=strcat(localIC,num2str(cont_pessoa),'_',num2str(cont_pastaimg),'_',num2str(cont_fotonumero),'.bmp');
%imwrite(im2uint8(irisCode),nome_seg);
%nome_seg=strcat(localIC,num2str(cont_pessoa),'_',num2str(cont_pastaimg),'_',num2str(cont_fotonumero),'R.bmp');
%imwrite(im2uint8(mascara),nome_seg);

template1 = logical(irisCode);
mascara1 = logical(mascara);

%hamming
numero_pessoa=20;
pasta_pessoa=1;
foto_pessoa=3;

for sub_pessoa=1:numero_pessoa
    for sub_pasta=1:pasta_pessoa
        for sub_foto=1:foto_pessoa
            nome_seg=strcat(localIC,num2str(sub_pessoa),'_',num2str(sub_pasta),'_',num2str(sub_foto),'.bmp');
            template2 = logical(imread(nome_seg));
            nome_seg=strcat(localIC,num2str(sub_pessoa),'_',num2str(sub_pasta),'_',num2str(sub_foto),'R.bmp');         
            mascara2 = logical(imread(nome_seg));
            
            %calculo hamming
            n=0;
            for i=-8:2:8
                [temp, mask] = deslocabits(template1, mascara1, i);
                num = sum(sum((xor(temp, template2))&(mask)&(mascara2)));
                dinom = sum(sum((mask&mascara2)));
                n = n+1;
                hd(n) = num/dinom;
            end
            disp(sub_pessoa);
            disp(cont_pessoa);
            hd=min(hd);
            disp(hd);
            if(hd < 0.452)
                if(sub_pessoa == cont_pessoa)
                    certo = certo + 1;
                else
                    falso_positivo = falso_positivo + 1;
                end
            else
                if(sub_pessoa == cont_pessoa)
                    falso_negativo = falso_negativo + 1;
                else
                    certo = certo + 1;
                end
            end
            total_comparacoes=total_comparacoes+1;
        end
    end
end
end
end
end

porcentagem_acerto = (certo*100)/total_comparacoes;
porcentagem_erro = ((falso_negativo + falso_positivo) * 100) /total_comparacoes;
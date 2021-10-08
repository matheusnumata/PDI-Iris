localIris = 'C:\PDI\iris\'; %local das imagens originais
localIC='C:\PDI\iriscode\'; %imagens iris code

pessoa=20;
pasta_img=1;
foto_numero=3;

for sub_pessoa=1:pessoa
    sub_pessoa;
    for sub_pasta=1:pasta_img
        sub_pasta;
        for sub_foto=1:foto_numero
            sub_foto;
            if(sub_pessoa<10)
                nome=strcat(localIris,'00',num2str(sub_pessoa),'\',num2str(sub_pasta),'\00',num2str(sub_pessoa),'_',num2str(sub_pasta),'_',num2str(sub_foto),'.bmp');
            elseif (sub_pessoa<100)
                nome=strcat(localIris,'0',num2str(sub_pessoa),'\',num2str(sub_pasta),'\0',num2str(sub_pessoa),'_',num2str(sub_pasta),'_',num2str(sub_foto),'.bmp');
            else
                nome=strcat(localIris,num2str(sub_pessoa),'\',num2str(sub_pasta),'\',num2str(sub_pessoa),'_',num2str(sub_pasta),'_',num2str(sub_foto),'.bmp');
            end
            
            I = imread(nome); %lê a imagem
            %figure('Name', 'Imagem Original'), imshow(I);
            
            bw = imbinarize(I, 0.26); %binariza a imagem
            %figure('Name', 'Imagem Binarizada'), imshow(bw);

            canny = edge(bw,'Canny'); %detecta borda através do filtro de canny
            %figure('Name', 'Imagem com Canny') , imshow(I2);

            Rmin = 30;
            Rmax = 65;

            [centers, radii] = imfindcircles(canny,[Rmin Rmax],'ObjectPolarity', 'dark'); %identifica a pupila
            %viscircles(centers, radii,'Color','b');
            %figure('Name', 'Imagem com a Íris Detectada'), imshow(I);

            %disp(centersDark);
            %disp(radiiDark);

            iris = radii * 2; %raio da íris
            %disp(iris);
            %viscircles(centersDark, iris, 'Color', 'b');
            %disp(centersDark);

            %deletar a imagem
            x = centers(2); %coloca o primeiro valor do vetor referente a posiçao do centro da pupila na variavel x
            y = centers(1); %coloca o primeiro valor do vetor referente a posiçao do centro da pupila na variavel y

            imageSize = size(I); %imageSize recebe o tamanho da imagem I
            ci = [x, y, iris]; %centro da pupila e raio da íris na variável ci
            [xx,yy] = ndgrid((1:imageSize(1))-ci(1),(1:imageSize(2))-ci(2)); %cria um grid com os tamanhos xy da imagem que está sendo lida
            mask = uint8((xx.^2 + yy.^2)<ci(3)^2); %%cria uma mascara com um valor q a soma de xx yy elevado ao quadrado seja menor que o raio da pupila ao quadrado
            croppedImage = uint8(zeros(size(I))); %cria um vetor de 0s no tamanho da imagem original
            croppedImage(:,:,1) = I(:,:,1).*mask; %passa a matriz I, em todos os intervalos para os pixels da mask
            %croppedImage(:,:,1) = I(:,:,1).*mask;
            %croppedImage(:,:,1) = I(:,:,1).*mask;

            %normalizaçao
            %M = double(croppedImage)/255.0; %

            normalizada = ImToPolar(croppedImage, 0, 0.1, 50, 200, centers); %realiza a normalização
            %figure('Name', 'Imagem Normalizada'), imshow(normalizada); %exibe imagem normalizada

            %tira ruido
            ruido=mascararuido(normalizada); %aplica a mascara de tirar ruido

            %gabor/wavelet 
            [irisCode, mascara]=extracao(normalizada, ruido, 1, 12, 0.5, 0.5); %aplica gabor
            nome_seg=strcat(localIC,num2str(sub_pessoa),'_',num2str(sub_pasta),'_',num2str(sub_foto),'.bmp');
            imwrite(im2uint8(irisCode),nome_seg);
            nome_seg=strcat(localIC,num2str(sub_pessoa),'_',num2str(sub_pasta),'_',num2str(sub_foto),'R.bmp');
            imwrite(im2uint8(mascara),nome_seg);

            template1 = logical(irisCode);
            mascara1 = logical(mascara);

        end
    end
end

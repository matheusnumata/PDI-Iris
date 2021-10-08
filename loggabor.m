function [EO, filtersum] = loggabor(im, nscale, minWaveLength, mult, sigmaOnf)

[rows, cols] = size(im); %recebe o tamanho da imagem i em linhas e colunas
filtersum = zeros(1,size(im,2)); %array de 0s com x sendo 1, e y sendo o tamanho da imagem original em 2 dimensões

EO = cell(1, nscale); %cria um tipo de dado cell, e guarda nele a variavel nscales e o inteiro 1   

ndata = cols; %atribuição de cols para ndata
if mod(ndata,2) == 1 %caso modulo de ndata e 2 seja = 1, é retirado uma coluna            
    ndata = ndata-1;              
end

logGabor = zeros(1,ndata); %filtro de loggabor com array (1 linha ndata colunas) de 0s
result = zeros(rows,ndata); %resultado com array (linhas por colunas) de 0s

radius = (0:fix(ndata/2))/fix(ndata/2)/2; %frequencia: valor = 0 - 0.5
radius(1) = 1; %atribui alguma coisa

wavelength = minWaveLength; %inicializando o filtro de wavelet.

for s = 1:nscale        
    fo = 1.0/wavelength; % Centro da frequencia do filtro.              

    logGabor(1:ndata/2+1) = exp((-(log(radius/fo)).^2) / (2 * log(sigmaOnf)^2)); %calculo de alguma coisa
    logGabor(1) = 0; %atribui alguma coisa
    
    filter = logGabor; %atribui loggabor sendo o filtro
    
    filtersum = filtersum+filter; %soma dois filtros (?)
    
    for r = 1:rows	
        signal = im(r,1:ndata); %parte imaginaria de uma funcao
        imagefft = fft( signal ); %transformada de fourier
        result(r,:) = ifft(imagefft .* filter); %transformada inversa de fourier
    end
    
    EO{s} = result; %armazenada no vetor EO{s}
    wavelength = wavelength * mult; %define o comprimento da onda
end
filtersum = fftshift(filtersum); %desloca a frequencia 0 para o centro do espectro da onda
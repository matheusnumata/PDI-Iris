function [template, mask] = extracao(polar_array, noise_array, nscales, minWaveLength, mult, sigmaOnf)

[E0, filtersum] = loggabor(polar_array, nscales, minWaveLength, mult, sigmaOnf);

length = size(polar_array,2)*2*nscales; %atribuiçao com base no valor calculado entre as variaveis

template = zeros(size(polar_array,1), length); 

length2 = size(polar_array,2);
h = 1:size(polar_array,1);

%Cria a iriscode

mask = zeros(size(template));

for k=1:nscales
    
    E1 = E0{k};
    
    H1 = real(E1) > 0;
    H2 = imag(E1) > 0;
    H3 = abs(E1) < 0.0001;
    
    for i=0:(length2-1)
                
        ja = double(2*nscales*(i));
        
        % Construção da iriscode
        template(h,ja+(2*k)-1) = H1(h, i+1);
        template(h,ja+(2*k)) = H2(h,i+1);
        
        %Construção da máscara de ruídos
        mask(h,ja+(2*k)-1) = noise_array(h, i+1) | H3(h, i+1);
        mask(h,ja+(2*k)) =   noise_array(h, i+1) | H3(h, i+1);
        
    end
end 
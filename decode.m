function [ centre, width, weight ] = decode( pop,popsize )
%--------------------------------------Decodes the chromosome to decimal values--------------------
centre = zeros(popsize,10);
width = zeros(popsize,10);
weight = zeros(popsize,25);
%-----------------------1-160 are Center-width pairs. 161-360 are the weights---------------------
for i=1:1:popsize;
    for j=1:16:160;
        centre(i,floor(j/16 + 1)) =(-1)*pop(i,j)*128 + pop(i,j+1)*64 + pop(i,j+2)*32 + pop(i,j+3)*16 + pop(i,j+4)*8 + pop(i,j+5)*4 + pop(i,j+6)*2 + pop(i,j+7);
        width(i,floor(j/16 + 1)) = pop(i,j+8)*128 + pop(i,j+9)*64 + pop(i,j+10)*32 + pop(i,j+11)*16 + pop(i,j+12)*8 + pop(i,j+13)*4 + pop(i,j+14)*2 + pop(i,j+15);
    end
    for j=161:8:360;
        weight(i,floor((j-160)/8+1)) = (-1)*pop(i,j)*128 + pop(i,j+1)*64 + pop(i,j+2)*32 + pop(i,j+3)*16 + pop(i,j+4)*8 + pop(i,j+5)*4 + pop(i,j+6)*2+ pop(i,j+7);
    end
end
end
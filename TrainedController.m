%---------This script takes the fittest member from the execution of the Main script after 500----------
%---------Generations and puts the obtained optimized parameters into the controller. The car-----------
%---------is started from various initial positions and its x and y positions plotted and recorded------
%-------- for results and discussions. -----------------------------------------------------------------
clc;
close all;
clear all;
%-----------------fittest member chromosome inputted, decoded and normalized----------------
curpop=[1,0,0,0,1,1,1,1,0,0,0,1,0,0,0,0,1,0,1,0,1,1,0,0,1,0,0,1,1,1,0,0,0,1,1,1,1,0,1,0,1,1,0,1,0,0,0,0,0,1,0,1,0,1,0,0,0,0,0,1,0,0,0,1,0,0,0,1,1,0,0,1,0,0,1,1,0,0,0,1,0,1,0,1,1,0,1,0,0,1,1,0,1,0,0,1,1,1,0,1,1,1,1,1,0,1,0,0,1,1,0,0,0,0,0,1,1,1,0,0,0,1,0,1,0,1,1,0,1,0,0,1,0,1,0,1,1,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,0,0,0,1,0,1,0,0,1,1,1,1,1,0,1,0,0,0,1,1,0,1,1,0,1,0,1,0,1,0,1,1,1,0,0,0,1,0,0,1,0,0,0,1,1,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0,1,0,1,1,0,1,0,1,0,0,0,0,1,1,0,1,0,0,1,0,1,1,1,0,1,0,0,0,1,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0,1,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,0,1,1,1,1,1,0,0,0,1,0,1,1,1,1,1,1,0,0,0,0,1,0,1,1,1,1,1,0,0,1,0,0,1,1,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,1,1,0];
[centre,width,weight]=decode(curpop,1);
centre=(centre+0.5)/127.5; %-1 to 1,0 to 1,-1 to 1
width=width/255;
weight=(weight+0.5)/127.5;
%-------Initialize and normalize variables. A manual bias of -0.1245 applied to Input 1--------
popsize=1;
init_x=0;
fin_theta=0;
fin_y=-.1245;
init_theta=-pi;
init_y=50;
fin_theta=fin_theta/pi;
fin_y=fin_y/50;
init_theta=init_theta/pi;
init_y=init_y/50;
init_x=init_x/50;
cur_y=ones(1,301)*init_y;
cur_x=ones(1,301)*init_x;
cur_theta=ones(1,301)*init_theta;
fuzzified=zeros(1,10);
fuzzymin=zeros(5,5);
alpha=0;
aggreg=0;
sumH=0;
PerfIndex=0;
v=0.5;
t=1;
l=2.6;
%-------------controller functioning starts in the same way as before, for T=300s---------------
for sample=1:1:300
    aggreg=0;
    sumH=0;
    err_y=cur_y(sample)-fin_y;
    cw1=[centre(1:5);width(1:5)];
    cw2=[centre(6:10);width(6:10)];
    cw1=(sortrows(cw1.',1)).';
    cw2=(sortrows(cw2.',1)).';
    for j=1:1:5
        fuzzified(j)=exp(-(((cw1(1,j)-err_y)/cw1(2,j)).^2));
        fuzzified(j+5)=exp(-(((cw2(1,j)-cur_theta(sample))/cw2(2,j)).^2));
    end
    for j=1:1:5
        for k=1:1:5
            fuzzymin(j,k)=min(fuzzified(j),fuzzified(k+5));
            aggreg=aggreg + (fuzzymin(j,k)*weight(((j-1)*5)+k));
            sumH=sumH+fuzzymin(j,k);
        end
    end
    alpha=aggreg/sumH;
    alpha=alpha*pi/3;
    cur_y=cur_y*50;
    cur_x=cur_x*50;
    cur_theta=cur_theta*pi;
    cur_theta(sample+1) = cur_theta(sample) + (v*t*tan(alpha)/l);
    cur_y(sample+1) = cur_y(sample) + v*t*sin(cur_theta(sample+1));
    cur_x(sample+1) = cur_x(sample) + v*t*cos(cur_theta(sample+1));
    cur_y=cur_y/50;
    cur_x=cur_x/50;
    cur_theta=cur_theta/pi;
    err_theta=cur_theta(sample+1)-fin_theta;
    err_y=cur_y(sample+1)-fin_y;
    PerfIndex=PerfIndex + ( (((err_theta).^2)+1) * (((err_y).^2)+1) * sample/1000);
end
%-----------------End of program. Plotting X,Y coordinates of car and the axis-------------------
plot(cur_x*50,cur_y*50)
hold on
hline(0)
vline(0)
hold off
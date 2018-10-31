clc;
close all;
clear all;
%------------------Initializing population size of 200 with random binary values------------------
popsize=200;
randompop=randi(2,popsize,360);
randompop(randompop==2)=0;
curpop=randompop;
%------------------defining x-axis as the final trajectory. Also defined the 12 trials’ -------------
%------------------initial position. ---------------------------------------------------------------------------
fin_theta=0;
fin_y=0;
init_theta= [pi, pi, -pi, -pi, pi/2, pi/2, pi, -pi, 0, -pi/2, pi/3, -3*pi/4];
init_y = [50, -50, 50, -50, -1, 0, 0, 0, 0, 10, 20, -30];
trials=12;
%-------------------------------------Normalizing the inputs to (-1,1)------------------------------------
fin_theta=fin_theta/pi;
fin_y=fin_y/50;
init_theta=init_theta/pi;
init_y=init_y/50;
%-----------------------------------------Initializing all arrays used---------------------------------------
cur_y=ones(popsize,1);
cur_theta=ones(popsize,1);
err_y=cur_y-fin_y;
fuzzified=zeros(popsize,10);
fuzzymin=zeros(5,5,popsize);
alpha=zeros(popsize,1);
aggreg=zeros(popsize,1);
sumH=zeros(popsize,1);
%------------Parameters of car: Velocity, time of sampling, and length. Maximum----------------
%------------Generations = 500------------------------------------------------------------------------------
v=0.5;
t=1;
l=2.6;
Gens=0;
MaxGens=500;
PerfIndex=zeros(popsize,1);
while(Gens<=MaxGens)
    PerfIndex=PerfIndex*0;
    %-------------Decoding the chromosome to decimal values and normalizing--------------------
    [centre,width,weight]=decode(curpop,popsize);
    centre=(centre+0.5)/127.5; %-1 to 1,0 to 1,-1 to 1
    width=width/255;
    weight=(weight+0.5)/127.5;
    for N=1:1:trials
        cur_y=(cur_y*0)+init_y(N);
        cur_theta=(cur_theta*0)+init_theta(N);
        %---------------------------We let the car run for T=300s, i.e. 300 samples----------------------
        for sample=1:1:300
            aggreg=aggreg*0;
            sumH=sumH*0;
            err_y=cur_y-fin_y;
            for i=1:1:popsize
                %-----------Flexible position coding strategy implementation. Obtain center------------ 
				%-----------width pairs for both inputs 1 and 2, and sort them w.r.t. centers------------ 
				%-----------for fuzzification of inputs variables-------------------------------------------------
                cw1=[centre(i,1:5);width(i,1:5)];
                cw2=[centre(i,6:10);width(i,6:10)];
                cw1=(sortrows(cw1.',1)).';
                cw2=(sortrows(cw2.',1)).';
                for j=1:1:5
                    %--------------fuzzification of both inputs, 10 fuzzy values. 10-8 added----------------- 
					%--------------to prevent division by zero-----------------------------------------------------
                    fuzzified(i,j)=exp(-(((cw1(1,j)-err_y(i))/(0.00000001+cw1(2,j))).^2));
                    fuzzified(i,j+5)=exp(-(((cw2(1,j)-cur_theta(i))/(0.00000001+cw2(2,j))).^2));
                end
            end
            for i=1:1:popsize
                for j=1:1:5
                    for k=1:1:5
                        %-------------------Taking min (using AND) and rule firing-----------------------------
                        fuzzymin(j,k,i)=min(fuzzified(i,j),fuzzified(i,k+5));
                        aggreg(i)=aggreg(i) + (fuzzymin(j,k,i)*weight(i,((j-1)*5)+k));
                        sumH(i)=sumH(i)+fuzzymin(j,k,i);
                    end
                end
                %---------------output generated using COA aggregation method--------------------------
                alpha(i)=aggreg(i)/(0.00000001+sumH(i));
            end
            %------------------Updating car position after de-normalization-------------------------------
            alpha=alpha*pi/3;
            cur_y=cur_y*50;
            cur_theta=cur_theta*pi;
            for i=1:1:popsize
                cur_theta(i) = cur_theta(i) + (v*t*tan(alpha(i))/l);
                cur_y(i) = cur_y(i) + v*t*sin(cur_theta(i));
            end
            cur_y=cur_y/50;
            cur_theta=cur_theta/pi;
            err_theta=cur_theta-fin_theta;
            err_y=cur_y-fin_y;
            %---------------------Evaluation of Performance index (MSE)----------------------------------
            for i=1:1:popsize
                PerfIndex(i)=PerfIndex(i) + ( (((err_theta(i)).^2)+1) * (((err_y(i)).^2)+1) * sample/1000);
            end
        end
    end
    %---------------Function call to the GA program for creation of next generation----------------
    curpop=GA(PerfIndex,curpop,popsize,Gens,MaxGens);
    Gens=Gens+1;
end
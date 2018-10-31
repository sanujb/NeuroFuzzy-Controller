function [ newpop ] = GA( PerfIndex,curpop,popsize,Gens,MaxGens )
rng('shuffle');
fitness=zeros(popsize,3);
totalfit=0;
%------Dynamic Crossover Rate. Evaluation of fitness using inverse of PerfIndex---------------
CrossRate=exp((-0.75)*Gens/MaxGens);
for i=1:1:popsize
    fitness(i,1) = 100000/(1 + PerfIndex(i)); %f=100/(1+F);
    totalfit = totalfit + fitness(i,1);
    fitness(i,2)=i;
end
%---------Sorting fitness in ascending order, keeping indices paired with original---------------
%---------individual. Find probability of each and cumulative probability for selection----------
%---------using roulette-wheel scheme------------------------------------------------------------
fitness=sortrows(fitness,1);
fitness(1,3)=fitness(1,1)/totalfit;
for i=2:1:popsize
    fitness(i,3)=fitness(i,1)/totalfit + fitness(i-1,3);
end
newpopsize=0;
newpop=zeros(popsize,360);
while(newpopsize<popsize)
    %----------------Selection of parents for crossover from the roulette-wheel-----------------------
    X=rand;
    for i=1:1:popsize
        if(X<fitness(i,3))
            break;
        end;
    end;
    X=rand;
    for j=1:1:popsize
        if(X<fitness(j,3))
            break;
        end;
    end;
    %--------------if the same parent selected twice, no crossover. Selection again-----------------
    if(i==j)
        continue;
    end
    p1=curpop(fitness(i,2),:); %parent 1 and 2
    p2=curpop(fitness(j,2),:);
    %----------------------------If random number < crossover rate, crossover will happen-----------
    %----------------------------otherwise parents will be cloned directly to next generation-------
    if(rand<CrossRate)
        %-----------------------------------Selection of two-points for crossover---------------------------
        cross1=floor(360*rand);
        cross2=floor(360*rand);
        if(cross1==0)
            cross1=1;
        end
        if(cross2==0)
            cross2=1;
        end
        %------------------------Execution of crossover between the two points-------------------------
        if(cross1>cross2)
            for i=cross2:1:cross1
                temp=p1(i);
                p1(i)=p2(i);
                p2(i)=temp;
            end
        end
        if(cross2>cross1)
            for i=cross1:1:cross2
                temp=p1(i);
                p1(i)=p2(i);
                p2(i)=temp;
            end
        end
    end
    %-----------------------------Children written into next generation----------------------------------
    newpop(newpopsize+1,:)=p1;
    newpop(newpopsize+2,:)=p2;
    newpopsize=newpopsize+2;
end;
%--------------------------------------1 elite copied over directly------------------------------------------
newpop(popsize,:)=curpop(fitness(popsize,2),:);
%-----------Mutation executed gene-wise in each chromosome. Random bit flipped------------
MutRate=(exp(0.05*Gens/MaxGens))-1;
for i=1:1:(popsize-1)
    for j=1:8:360
        if(rand<=MutRate)
            X=floor(8*rand);
            if (X==8)
                X=7;
            end
            newpop(i,j+X)=1-newpop(i,j+X);
        end
    end
end
end
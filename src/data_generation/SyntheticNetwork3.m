%1, dataset 1, 100 nodes, 60 time intervals, 4-3-4 communities for times
%1-20/21-40/41-60
%2, dataset 2, 100 nodes, 60 time intervals, 3-5-4 communities for times
%1-20/21-40/41-60
%3, dataset 3, 100 nodes, 60 time intervals, 4-5-6 communities for times
%1-20/21-40/41-60
%4, dataset 4, 100 nodes, 60 time intervals, 4-8-4 communities for times
%1-20/21-40/41-60


function [Net,GT,Attrt1,K,Vindex] = SyntheticNetwork3(dataset,seed,randomAttrs,multiAttrs)
    %%Unweighted, undirected, no selfloops

    if(~isdeployed)
        cd(getProjectRoot());
    end

    %To visualize connections of the random network
    plotflag = 0;
    
    tic

    rng(seed);
    
    %There is an error on dataset 3 for seed 7 that creates a node less between 
    %times 21 and 40, for consistency, it is changed to seed 11
    if seed == 7
        rng(11)
    end

    u = 2;
    if multiAttrs == 0
        M=1;
        if randomAttrs == 0
            mu1 = 0;
            mu2 = u;
            mu3 = -u;
            mu4 = -2*u;
            mu5 = -3*u;
            mu6 = 2*u;
            mu7 = 3*u;
            mu8 = 4*u;
        else
            mu1 = 0;
            mu2 = 0;
            mu3 = 0;
            mu4 = 0;
            mu5 = 0;
            mu6 = 0;
            mu7 = 0;
            mu8 = 0;
        end
        sigma = 0.1;
    end
    if multiAttrs == 1
        M=3;
        if randomAttrs == 0
            mu1 = [u 0 0];
            mu2 = [0 0 0];
            mu3 = [-u 0 0];
            mu4 = [-2*u 0 0];
            mu5 = [-3*u 0 0];
            mu6 = [2*u 0 0];
            mu7 = [3*u 0 0];
            mu8 = [4*u 0 0];
        else
            mu1 = [0 0 0];
            mu2 = [0 0 0];
            mu3 = [0 0 0];
            mu4 = [0 0 0];
            mu5 = [0 0 0];
            mu6 = [0 0 0];
            mu7 = [0 0 0];
            mu8 = [0 0 0];
        end
        sigma = 0.1*eye(M);
    end
    N = 100;%200;
    T = 60;
    chpts = [21, 41];

    % Values for each dataset at each block interval
    muIntra = [0.7, 0.5, 0.6, 0.8;0.5, 0.5, 0.4, 0.6;0.7, 0.5, 0.6, 0.8]';
    sigmaIntra = [0.4, 0.4, 0.4, 0.5; 0.3, 0.2, 0.2, 0.2; 0.4, 0.4, 0.4, 0.5]';
    muInter = [0.4, 0.3, 0.2, 0.3; 0.2, 0.2, 0.2, 0.2; 0.4, 0.3, 0.2, 0.3]';
    sigmaInter = [0.2, 0.2, 0.2, 0.2; 0.2, 0.2, 0.1, 0.3; 0.2, 0.2, 0.2, 0.2]';

    %Values for time points 1-20
    commsizes = cell(4,3);
    commsizes{1,1} = [30,30,20,20];
    commsizes{2,1} = [60,20,20];
    commsizes{3,1} = [30,30,20,20];
    commsizes{4,1} = [30,30,20,20];
    commsizes{1,2} = [60,20,20];
    commsizes{2,2} = [20,20,20,20,20];
    commsizes{3,2} = [30,15,15,20,20];
    commsizes{4,2} = [15,15,15,15,10,10,10,10];
    commsizes{1,3} = [30,30,20,20];
    commsizes{2,3} = [40,20,20,20];
    commsizes{3,3} = [15,15,15,15,20,20];
    commsizes{4,3} = [30,30,20,20];

    Net = cell(1,T);
    Attrt1 = cell(1,T);

    %% for the first set of snapshots
    tt=1;
    addcommsizes = zeros(size(commsizes{dataset,tt},2)-1,1);
    addtemp = 0;
    for i=1:size(commsizes{dataset,tt},2)
        addtemp = addtemp + commsizes{dataset,tt}(i);
        addcommsizes(i) = addtemp;
    end
    
    group = 1;
    for i=1:addcommsizes(group)
        for j=i+1:addcommsizes(group)
            for t = 1:chpts(1)-1
                randnum = muIntra(dataset,tt)+sigmaIntra(dataset,tt)*trandn((0-muIntra(dataset,tt))/sigmaIntra(dataset,tt),(1-muIntra(dataset,tt))/sigmaIntra(dataset,tt)); 
                if randnum >=0.5
                    Net{1,t}(i,j) = 1;
                    Net{1,t}(j,i) = 1;
                end
            end
        end
        for j=addcommsizes(group)+1:N
            for t = 1:chpts(1)-1
                randnum = muInter(dataset,tt)+sigmaInter(dataset,tt)*trandn((0-muInter(dataset,tt))/sigmaInter(dataset,tt),(1-muInter(dataset,tt))/sigmaInter(dataset,tt)); 
                if randnum >=0.5
                    Net{1,t}(i,j) = 1;
                    Net{1,t}(j,i) = 1;
                end
            end
        end
        sAttrs = rng;
        if multiAttrs == 0
            t = 1;
            switch group
                case 1
                Attrt1{1,t}(i,1)=normrnd(mu1,sigma);
                case 2
                Attrt1{1,t}(i,1)=normrnd(mu2,sigma);
                case 3
                Attrt1{1,t}(i,1)=normrnd(mu3,sigma);
                case 4
                Attrt1{1,t}(i,1)=normrnd(mu4,sigma);
                case 5
                Attrt1{1,t}(i,1)=normrnd(mu5,sigma);
                case 6
                Attrt1{1,t}(i,1)=normrnd(mu6,sigma);
                case 7
                Attrt1{1,t}(i,1)=normrnd(mu7,sigma);
                case 8
                Attrt1{1,t}(i,1)=normrnd(mu8,sigma);
            end
            for t = 2:chpts(1)-1
                Attrt1{1,t}(i,1) = Attrt1{1,t-1}(i,1);
            end
        end
        if multiAttrs == 1
            t = 1;
            switch group
                case 1
                Attrt1{1,t}(i,:)=mvnrnd(mu1,sigma);
                case 2
                Attrt1{1,t}(i,:)=mvnrnd(mu2,sigma);
                case 3
                Attrt1{1,t}(i,:)=mvnrnd(mu3,sigma);
                case 4
                Attrt1{1,t}(i,:)=mvnrnd(mu4,sigma);
                case 5
                Attrt1{1,t}(i,:)=mvnrnd(mu5,sigma);
                case 6
                Attrt1{1,t}(i,:)=mvnrnd(mu6,sigma);
                case 7
                Attrt1{1,t}(i,:)=mvnrnd(mu7,sigma);
                case 8
                Attrt1{1,t}(i,:)=mvnrnd(mu8,sigma);
            end
            for t = 2:chpts(1)-1
                Attrt1{1,t}(i,:) = Attrt1{1,t-1}(i,:);
            end
        end
        rng(sAttrs);
    end

    for group=2:size(commsizes{dataset,tt},2)
        %% for the other groups
        for i=addcommsizes(group-1)+1:addcommsizes(group)
            for j=i+1:addcommsizes(group)
                for t = 1:chpts(1)-1
                    randnum = muIntra(dataset,tt)+sigmaIntra(dataset,tt)*trandn((0-muIntra(dataset,tt))/sigmaIntra(dataset,tt),(1-muIntra(dataset,tt))/sigmaIntra(dataset,tt)); 
                    if randnum >=0.5
                        Net{1,t}(i,j) = 1;
                        Net{1,t}(j,i) = 1;
                    end
                end
            end
            for j=addcommsizes(group)+1:N

                for t = 1:chpts(1)-1
                        randnum = muInter(dataset,tt)+sigmaInter(dataset,tt)*trandn((0-muInter(dataset,tt))/sigmaInter(dataset,tt),(1-muInter(dataset,tt))/sigmaInter(dataset,tt)); 
                    if randnum >=0.5
                        Net{1,t}(i,j) = 1;
                        Net{1,t}(j,i) = 1;
                    end
                end
            end
            sAttrs = rng;
            if multiAttrs == 0
                t = 1;
                switch group
                    case 1
                    Attrt1{1,t}(i,1)=normrnd(mu1,sigma);
                    case 2
                    Attrt1{1,t}(i,1)=normrnd(mu2,sigma);
                    case 3
                    Attrt1{1,t}(i,1)=normrnd(mu3,sigma);
                    case 4
                    Attrt1{1,t}(i,1)=normrnd(mu4,sigma);
                    case 5
                    Attrt1{1,t}(i,1)=normrnd(mu5,sigma);
                    case 6
                    Attrt1{1,t}(i,1)=normrnd(mu6,sigma);
                    case 7
                    Attrt1{1,t}(i,1)=normrnd(mu7,sigma);
                    case 8
                    Attrt1{1,t}(i,1)=normrnd(mu8,sigma);
                end
                for t = 2:chpts(1)-1
                    Attrt1{1,t}(i,1) = Attrt1{1,t-1}(i,1);
                end
            end
            if multiAttrs == 1
                t = 1;
                switch group
                    case 1
                    Attrt1{1,t}(i,:)=mvnrnd(mu1,sigma);
                    case 2
                    Attrt1{1,t}(i,:)=mvnrnd(mu2,sigma);
                    case 3
                    Attrt1{1,t}(i,:)=mvnrnd(mu3,sigma);
                    case 4
                    Attrt1{1,t}(i,:)=mvnrnd(mu4,sigma);
                    case 5
                    Attrt1{1,t}(i,:)=mvnrnd(mu5,sigma);
                    case 6
                    Attrt1{1,t}(i,:)=mvnrnd(mu6,sigma);
                    case 7
                    Attrt1{1,t}(i,:)=mvnrnd(mu7,sigma);
                    case 8
                    Attrt1{1,t}(i,:)=mvnrnd(mu8,sigma);
                end
                for t = 2:chpts(1)-1
                    Attrt1{1,t}(i,:) = Attrt1{1,t-1}(i,:);
                end
            end
            rng(sAttrs);
        end
    end

    

    %% for the second set of snapshots
    tt=2;
    addcommsizes = zeros(size(commsizes{dataset,tt},2)-1,1);
    addtemp = 0;
    for i=1:size(commsizes{dataset,tt},2)
        addtemp = addtemp + commsizes{dataset,tt}(i);
        addcommsizes(i) = addtemp;
    end

    
    group = 1;
    %% for the first group
    for i=1:addcommsizes(group)
        for j=i+1:addcommsizes(group)

            for t=chpts(1):chpts(2)-1
                randnum = muIntra(dataset,tt)+sigmaIntra(dataset,tt)*trandn((0-muIntra(dataset,tt))/sigmaIntra(dataset,tt),(1-muIntra(dataset,tt))/sigmaIntra(dataset,tt)); 
                if randnum >=0.5
                    Net{1,t}(i,j) = 1;
                    Net{1,t}(j,i) = 1;
                end
            end
        end
        for j=addcommsizes(group)+1:N

            for t=chpts(1):chpts(2)-1
                randnum = muInter(dataset,tt)+sigmaInter(dataset,tt)*trandn((0-muInter(dataset,tt))/sigmaInter(dataset,tt),(1-muInter(dataset,tt))/sigmaInter(dataset,tt)); 
                if randnum >=0.5
                    Net{1,t}(i,j) = 1;
                    Net{1,t}(j,i) = 1;
                end
            end
        end
        sAttrs = rng;
        if multiAttrs == 0
            t = chpts(1);
            switch group
                case 1
                Attrt1{1,t}(i,1)=normrnd(mu1,sigma);
                case 2
                Attrt1{1,t}(i,1)=normrnd(mu2,sigma);
                case 3
                Attrt1{1,t}(i,1)=normrnd(mu3,sigma);
                case 4
                Attrt1{1,t}(i,1)=normrnd(mu4,sigma);
                case 5
                Attrt1{1,t}(i,1)=normrnd(mu5,sigma);
                case 6
                Attrt1{1,t}(i,1)=normrnd(mu6,sigma);
                case 7
                Attrt1{1,t}(i,1)=normrnd(mu7,sigma);
                case 8
                Attrt1{1,t}(i,1)=normrnd(mu8,sigma);
            end
            for t=chpts(1)+1:chpts(2)-1
                Attrt1{1,t}(i,1) = Attrt1{1,t-1}(i,1);
            end
        end
        if multiAttrs == 1
            t = chpts(1);
            switch group
                case 1
                Attrt1{1,t}(i,:)=mvnrnd(mu1,sigma);
                case 2
                Attrt1{1,t}(i,:)=mvnrnd(mu2,sigma);
                case 3
                Attrt1{1,t}(i,:)=mvnrnd(mu3,sigma);
                case 4
                Attrt1{1,t}(i,:)=mvnrnd(mu4,sigma);
                case 5
                Attrt1{1,t}(i,:)=mvnrnd(mu5,sigma);
                case 6
                Attrt1{1,t}(i,:)=mvnrnd(mu6,sigma);
                case 7
                Attrt1{1,t}(i,:)=mvnrnd(mu7,sigma);
                case 8
                Attrt1{1,t}(i,:)=mvnrnd(mu8,sigma);
            end
            for t=chpts(1)+1:chpts(2)-1
                Attrt1{1,t}(i,:) = Attrt1{1,t-1}(i,:);
            end
        end
        rng(sAttrs);  
    end

    for group=2:size(commsizes{dataset,tt},2)
        %% for the other groups
        for i=addcommsizes(group-1)+1:addcommsizes(group)
            for j=i+1:addcommsizes(group)

                for t=chpts(1):chpts(2)-1
                    randnum = muIntra(dataset,tt)+sigmaIntra(dataset,tt)*trandn((0-muIntra(dataset,tt))/sigmaIntra(dataset,tt),(1-muIntra(dataset,tt))/sigmaIntra(dataset,tt)); 
                    if randnum >=0.5
                        Net{1,t}(i,j) = 1;
                        Net{1,t}(j,i) = 1;
                    end
                end
            end
            for j=addcommsizes(group)+1:N

                for t=chpts(1):chpts(2)-1
                    randnum = muInter(dataset,tt)+sigmaInter(dataset,tt)*trandn((0-muInter(dataset,tt))/sigmaInter(dataset,tt),(1-muInter(dataset,tt))/sigmaInter(dataset,tt)); 
                    if randnum >=0.5
                        Net{1,t}(i,j) = 1;
                        Net{1,t}(j,i) = 1;
                    end
                end
            end
            sAttrs = rng;
            if multiAttrs == 0
                t = chpts(1);
                switch group
                    case 1
                    Attrt1{1,t}(i,1)=normrnd(mu1,sigma);
                    case 2
                    Attrt1{1,t}(i,1)=normrnd(mu2,sigma);
                    case 3
                    Attrt1{1,t}(i,1)=normrnd(mu3,sigma);
                    case 4
                    Attrt1{1,t}(i,1)=normrnd(mu4,sigma);
                    case 5
                    Attrt1{1,t}(i,1)=normrnd(mu5,sigma);
                    case 6
                    Attrt1{1,t}(i,1)=normrnd(mu6,sigma);
                    case 7
                    Attrt1{1,t}(i,1)=normrnd(mu7,sigma);
                    case 8
                    Attrt1{1,t}(i,1)=normrnd(mu8,sigma);
                end
                for t=chpts(1)+1:chpts(2)-1
                    Attrt1{1,t}(i,1) = Attrt1{1,t-1}(i,1);
                end
            end
            if multiAttrs == 1
                t = chpts(1);
                switch group
                    case 1
                    Attrt1{1,t}(i,:)=mvnrnd(mu1,sigma);
                    case 2
                    Attrt1{1,t}(i,:)=mvnrnd(mu2,sigma);
                    case 3
                    Attrt1{1,t}(i,:)=mvnrnd(mu3,sigma);
                    case 4
                    Attrt1{1,t}(i,:)=mvnrnd(mu4,sigma);
                    case 5
                    Attrt1{1,t}(i,:)=mvnrnd(mu5,sigma);
                    case 6
                    Attrt1{1,t}(i,:)=mvnrnd(mu6,sigma);
                    case 7
                    Attrt1{1,t}(i,:)=mvnrnd(mu7,sigma);
                    case 8
                    Attrt1{1,t}(i,:)=mvnrnd(mu8,sigma);
                end
                for t=chpts(1)+1:chpts(2)-1
                    Attrt1{1,t}(i,:) = Attrt1{1,t-1}(i,:);
                end
            end
            rng(sAttrs); 
        end
    end  
    

    %% for the third set of snapshots
    tt=3;
    addcommsizes = zeros(size(commsizes{dataset,tt},2)-1,1);
    addtemp = 0;
    for i=1:size(commsizes{dataset,tt},2)
        addtemp = addtemp + commsizes{dataset,tt}(i);
        addcommsizes(i) = addtemp;
    end

    
    group = 1;
    %% for the first group
    for i=1:addcommsizes(group)
        for j=i+1:addcommsizes(group)

            for t=chpts(2):T
                randnum = muIntra(dataset,tt)+sigmaIntra(dataset,tt)*trandn((0-muIntra(dataset,tt))/sigmaIntra(dataset,tt),(1-muIntra(dataset,tt))/sigmaIntra(dataset,tt)); 
                if randnum >=0.5
                    Net{1,t}(i,j) = 1;
                    Net{1,t}(j,i) = 1;
                end
            end
        end
        for j=addcommsizes(group)+1:N

            for t=chpts(2):T
                randnum = muInter(dataset,tt)+sigmaInter(dataset,tt)*trandn((0-muInter(dataset,tt))/sigmaInter(dataset,tt),(1-muInter(dataset,tt))/sigmaInter(dataset,tt)); 
                if randnum >=0.5
                    Net{1,t}(i,j) = 1;
                    Net{1,t}(j,i) = 1;
                end
            end
        end
        sAttrs = rng;
        if multiAttrs == 0
            t = chpts(2);
            switch group
                case 1
                Attrt1{1,t}(i,1)=normrnd(mu1,sigma);
                case 2
                Attrt1{1,t}(i,1)=normrnd(mu2,sigma);
                case 3
                Attrt1{1,t}(i,1)=normrnd(mu3,sigma);
                case 4
                Attrt1{1,t}(i,1)=normrnd(mu4,sigma);
                case 5
                Attrt1{1,t}(i,1)=normrnd(mu5,sigma);
                case 6
                Attrt1{1,t}(i,1)=normrnd(mu6,sigma);
                case 7
                Attrt1{1,t}(i,1)=normrnd(mu7,sigma);
                case 8
                Attrt1{1,t}(i,1)=normrnd(mu8,sigma);
            end
            for t=chpts(2)+1:T
                Attrt1{1,t}(i,1) = Attrt1{1,t-1}(i,1);
            end
        end
        if multiAttrs == 1
            t = chpts(2);
            switch group
                case 1
                Attrt1{1,t}(i,:)=mvnrnd(mu1,sigma);
                case 2
                Attrt1{1,t}(i,:)=mvnrnd(mu2,sigma);
                case 3
                Attrt1{1,t}(i,:)=mvnrnd(mu3,sigma);
                case 4
                Attrt1{1,t}(i,:)=mvnrnd(mu4,sigma);
                case 5
                Attrt1{1,t}(i,:)=mvnrnd(mu5,sigma);
                case 6
                Attrt1{1,t}(i,:)=mvnrnd(mu6,sigma);
                case 7
                Attrt1{1,t}(i,:)=mvnrnd(mu7,sigma);
                case 8
                Attrt1{1,t}(i,:)=mvnrnd(mu8,sigma);
            end
            for t=chpts(2)+1:T
                Attrt1{1,t}(i,:) = Attrt1{1,t-1}(i,:);
            end
        end
        rng(sAttrs);
    end

    for group=2:size(commsizes{dataset,tt},2)
        %% for the other groups
        for i=addcommsizes(group-1)+1:addcommsizes(group)
            for j=i+1:addcommsizes(group)

                for t=chpts(2):T
                    randnum = muIntra(dataset,tt)+sigmaIntra(dataset,tt)*trandn((0-muIntra(dataset,tt))/sigmaIntra(dataset,tt),(1-muIntra(dataset,tt))/sigmaIntra(dataset,tt)); 
                    if randnum >=0.5
                        Net{1,t}(i,j) = 1;
                        Net{1,t}(j,i) = 1;
                    end
                end
            end
            for j=addcommsizes(group)+1:N

                for t=chpts(2):T
                        randnum = muInter(dataset,tt)+sigmaInter(dataset,tt)*trandn((0-muInter(dataset,tt))/sigmaInter(dataset,tt),(1-muInter(dataset,tt))/sigmaInter(dataset,tt)); 
                    if randnum >=0.5
                        Net{1,t}(i,j) = 1;
                        Net{1,t}(j,i) = 1;
                    end
                end
            end
            sAttrs = rng;
            if multiAttrs == 0
                t = chpts(2);
                switch group
                    case 1
                    Attrt1{1,t}(i,1)=normrnd(mu1,sigma);
                    case 2
                    Attrt1{1,t}(i,1)=normrnd(mu2,sigma);
                    case 3
                    Attrt1{1,t}(i,1)=normrnd(mu3,sigma);
                    case 4
                    Attrt1{1,t}(i,1)=normrnd(mu4,sigma);
                    case 5
                    Attrt1{1,t}(i,1)=normrnd(mu5,sigma);
                    case 6
                    Attrt1{1,t}(i,1)=normrnd(mu6,sigma);
                    case 7
                    Attrt1{1,t}(i,1)=normrnd(mu7,sigma);
                    case 8
                    Attrt1{1,t}(i,1)=normrnd(mu8,sigma);
                end
                for t=chpts(2)+1:T
                    Attrt1{1,t}(i,1) = Attrt1{1,t-1}(i,1);
                end
            end
            if multiAttrs == 1
                t = chpts(2);
                switch group
                    case 1
                    Attrt1{1,t}(i,:)=mvnrnd(mu1,sigma);
                    case 2
                    Attrt1{1,t}(i,:)=mvnrnd(mu2,sigma);
                    case 3
                    Attrt1{1,t}(i,:)=mvnrnd(mu3,sigma);
                    case 4
                    Attrt1{1,t}(i,:)=mvnrnd(mu4,sigma);
                    case 5
                    Attrt1{1,t}(i,:)=mvnrnd(mu5,sigma);
                    case 6
                    Attrt1{1,t}(i,:)=mvnrnd(mu6,sigma);
                    case 7
                    Attrt1{1,t}(i,:)=mvnrnd(mu7,sigma);
                    case 8
                    Attrt1{1,t}(i,:)=mvnrnd(mu8,sigma);
                end
                for t=chpts(2)+1:T
                    Attrt1{1,t}(i,:) = Attrt1{1,t-1}(i,:);
                end
            end
            rng(sAttrs);
        end
    end  

    GT = cell(T,1);
    Vindex = cell(T,1);
    step = 20;
    if dataset == 1
        t1 = [ones(1,30),2*ones(1,30),3*ones(1,20),4*ones(1,20)];
        for t = 1:step
            GT{t} = t1';
        end
        t2 = [ones(1,60),2*ones(1,20),3*ones(1,20)];
        for t = step+1:step*2
            GT{t} = t2';
        end
        t3 = [ones(1,30),2*ones(1,30),3*ones(1,20),4*ones(1,20)];
        for t = step*2+1:step*3
            GT{t} = t3';
        end
        K = [4*ones(1,20) 3*ones(1,20) 4*ones(1,20)];
    end

    if dataset == 2
        t1 = [ones(1,60),2*ones(1,20),3*ones(1,20)];
        for t = 1:step
            GT{t} = t1';
        end
        t2 = [ones(1,20),2*ones(1,20),3*ones(1,20),4*ones(1,20),5*ones(1,20)];
        for t = step+1:step*2
            GT{t} = t2';
        end        
        t3 = [ones(1,40),2*ones(1,20),3*ones(1,20),4*ones(1,20)];
        for t = step*2+1:step*3
            GT{t} = t3';
        end        
        K = [3*ones(1,20) 5*ones(1,20) 4*ones(1,20)];
    end
    if dataset == 3
        t1 = [ones(1,30),2*ones(1,30),3*ones(1,20),4*ones(1,20)];
        for t = 1:step
            GT{t} = t1';
        end        
        t2 = [ones(1,30),2*ones(1,15),3*ones(1,15),4*ones(1,20),5*ones(1,20)];
        for t = step+1:step*2
            GT{t} = t2';
        end        
        t3 = [ones(1,15),2*ones(1,15),3*ones(1,15),4*ones(1,15),5*ones(1,20),6*ones(1,20)];
        for t = step*2+1:step*3
            GT{t} = t3';
        end                
        K = [4*ones(1,20) 5*ones(1,20) 6*ones(1,20)];
    end 
    if dataset == 4
        t1 = [ones(1,30),2*ones(1,30),3*ones(1,20),4*ones(1,20)];
        for t = 1:step
            GT{t} = t1';
        end        
        t2 = [ones(1,15),2*ones(1,15),3*ones(1,15),4*ones(1,15),5*ones(1,10),6*ones(1,10),7*ones(1,10),8*ones(1,10)];
        for t = step+1:step*2
            GT{t} = t2';
        end        
        t3 = [ones(1,30),2*ones(1,30),3*ones(1,20),4*ones(1,20)];
        for t = step*2+1:step*3
            GT{t} = t3';
        end                
        K = [4*ones(1,20) 8*ones(1,20) 4*ones(1,20)];
    end



    fignum = 1;
    stepsize = 5;
    AttrOverTime = cell(M(1),1);
    for j = 1:M
        AttrOverTime{j} = zeros(N(1),T);
        for t = 1:T
            for n = 1:N
                AttrOverTime{j}(n,t) = Attrt1{t}(n,j);
            end
        end
    end
    if plotflag == 1
        for t = 1:stepsize:T
            figure(fignum)
            spy(Net{t},'k')
            delete(findall(findall(gcf,'Type','axe'),'Type','text'))
            xlabel("Nodes")
            ylabel("Nodes")
            xticks([0 20 40 60 80 100]);
            ax = gca;
            ax.XAxis.FontSize = 16;
            ax.YAxis.FontSize = 16;  
            fignum = fignum + 1;
            saveas(gcf,strcat('AlSh',num2str(dataset),'Adjt',num2str(t),'.png'))
        end
        for j =1:M
            figure(fignum)
            imagesc(AttrOverTime{j})
            colormap(gray(256))
            colorbar
            ax = gca;
            ax.XAxis.FontSize = 16;
            ax.YAxis.FontSize = 16;  

            xlabel(strcat("Timestamps"))
            ylabel("Nodes")
            saveas(gcf,strcat('AlSh',num2str(dataset),'Attr',num2str(j),'.png'))
            fignum=fignum+1;
        end

    end

for t = 1:T
    Vindex{t} = 1:size(Net{t},1);
end

end

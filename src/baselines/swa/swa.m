%% Clear all
clear;

initIn = 1;

Alg = 12;

printWarning = 0;

if(~isdeployed)
  cd(getProjectRoot());
end

dirFolder = pwd;

%Name of the output file
saveName ="Results/Testing";

replicate = 20;

attrsIncBool = 0;

eigsStatic =1;
attrsType = "Reales";

initInTimeStart = tic;
%Number of dataset to use
%17 and 18: SyntheticNetwork1
%107, 108, 109: SyntheticNetwork2
%19, 20, 21, 22: SyntheticNetwork3
Data = 17;
%For SyntheticNetwork1 and SyntheticNetwork3
randomAttrs = 0;
multiAttrs = 1;
%For SyntheticNetwork2
%ProbVar = 0.21;%0.21;%0.25 %for 107
%ProbVar = 0.1;%0.1;%0.14 %for 108
ProbVar = 0.19;%0.19;%0.23 %for 109IterRep = 1;
if attrsType == "CategoricosHamming"
    HammingDistance = 1;
else
    HammingDistance = 0;
end
%Use coldstart when multiple tensors are used
coldstart = 1;
%Seed for the random generation of the data (where applies)
seed = 1;
%Stopping criteria for early convergence
earlystop = 1;
%Maximum number of iterations for the alternating optimization
MaxIter = 20;
%Values for the window size. At most the the value of T
Ls = 2;

structSim = 1;
NormalizerAbs = 0;
NormalizerNoAbs = 0;
%Flag for plotting community assignment
plotflag = 0;
plotflagData = 0;
sigmaMST = 1;
NormalizeWnorm2 = 0;
NormalizeWsum1 = 0;
NormalizeAttrMax = 0;
NormalizeAttrSum = 0;
NormalizeUgUxAt = 0;
learnAlpha = 1;%0;
%Minimum change threshold
epsilon = 1e-5;
saveResults = 1;
static = 0;

cd CreateData

timeData = tic;

if Data == 17
    [Net,Attr,GT,K,Vindex] = SyntheticNetwork1(1,seed,randomAttrs,multiAttrs);
elseif Data == 18
    [Net,Attr,GT,K,Vindex] = SyntheticNetwork1(2,seed,randomAttrs,multiAttrs);
elseif Data == 107
    [Net, Attr, K, GT, AttrOverTime,Vindex] = SyntheticNetwork2(7, seed, ProbVar, randomAttrs);       
elseif Data == 108 
    [Net, Attr, K, GT, AttrOverTime,Vindex] = SyntheticNetwork2(8, seed, ProbVar, randomAttrs);     
elseif Data == 109  
    [Net, Attr, K, GT, AttrOverTime,Vindex] = SyntheticNetwork2(9, seed, ProbVar, randomAttrs);     
elseif Data == 19
    [Net,GT,Attr,K,Vindex] = SyntheticNetwork3(1,seed,randomAttrs,multiAttrs);%It needs the number of the dataset to create: 1, 2, 3, 4
    Net=Net';
elseif Data == 20 
    [Net,GT,Attr,K,Vindex] = SyntheticNetwork3(2,seed,randomAttrs,multiAttrs);%It needs the number of the dataset to create: 1, 2, 3, 4
    Net=Net';
elseif Data == 21
    [Net,GT,Attr,K,Vindex] = SyntheticNetwork3(3,seed,randomAttrs,multiAttrs);%It needs the number of the dataset to create: 1, 2, 3, 4
    Net=Net';
elseif Data == 22
    [Net,GT,Attr,K,Vindex] = SyntheticNetwork3(4,seed,randomAttrs,multiAttrs);%It needs the number of the dataset to create: 1, 2, 3, 4
    Net=Net';
elseif Data == 122 %Dataset 1 in the paper
    load(fullfile(getProjectRoot(),'datasets','Synthetic network 4','Data122',"Data122S"+num2str(seed)));
elseif Data == 123 %Dataset 2 in the paper
    load(fullfile(getProjectRoot(),'datasets','Synthetic network 4','Data123',"Data123S"+num2str(seed)));
elseif Data == 124 %Dataset 3 in the paper
    load(fullfile(getProjectRoot(),'datasets','Synthetic network 4','Data124',"Data124S"+num2str(seed)));
elseif Data == 125 %Dataset 4 in the paper
    load(fullfile(getProjectRoot(),'datasets','Synthetic network 4','Data125',"Data125S"+num2str(seed)));
elseif Data == 128 %Dataset 9 in the paper
    load(fullfile(getProjectRoot(),'datasets','Synthetic network 4','Data128',"Data128S"+num2str(seed)));
elseif Data == 129 %Dataset 10 in the paper
    load(fullfile(getProjectRoot(),'datasets','Synthetic network 4','Data129',"Data129S"+num2str(seed)));
elseif Data == 130 %Dataset 11 in the paper
    load(fullfile(getProjectRoot(),'datasets','Synthetic network 4','Data130',"Data130S"+num2str(seed)));
elseif Data == 131 %Dataset 12 in the paper
    load(fullfile(getProjectRoot(),'datasets','Synthetic network 4','Data131',"Data131S"+num2str(seed)));
elseif Data == 135 %Dataset 5 in the paper   
    load(fullfile(getProjectRoot(),'datasets','Synthetic network 4','Data135',"Data135S"+num2str(seed)));
elseif Data == 136 %Dataset 6 in the paper  
    load(fullfile(getProjectRoot(),'datasets','Synthetic network 4','Data136',"Data136S"+num2str(seed)));
elseif Data == 137 %Dataset 7 in the paper   
    load(fullfile(getProjectRoot(),'datasets','Synthetic network 4','Data137',"Data137S"+num2str(seed)));
elseif Data == 138 %Dataset 8 in the paper   
    load(fullfile(getProjectRoot(),'datasets','Synthetic network 4','Data138',"Data138S"+num2str(seed)));
end

if ismember(Data,[107:109,120:131,133:138])
    K = K';
end

cd ..

timeData=toc(timeData);

%Number of time intervals
T = size(Net,1);

if static
    T = 1;
end

IterRep = 1;
NMItotalorig = cell(IterRep,1);
VItotal = cell(IterRep,1);
Jaccardtotal = cell(IterRep,1);
Precisiontotal = cell(IterRep,1);
Sensitivitytotal = cell(IterRep,1);
Specificitytotal = cell(IterRep,1);
RandIndextotal = cell(IterRep,1);
AdjustedRandIndextotal = cell(IterRep,1);
%timeTensor = cell(1,1);
Timetotal = cell(IterRep,1);
Commstotal = cell(IterRep,T);
KValNum = 1;
NMItotal = zeros(T,KValNum);
Modularitytotal = zeros(T,KValNum);%zeros(IterRep,T,KValNum);
Densitytotal = zeros(T,KValNum);
Entropytotal = zeros(T,KValNum);
DBtotal = zeros(T,KValNum);
CHtotal = zeros(T,KValNum);
Siltotal = zeros(T,KValNum);
%Initialization of a cell array for handling temporary operations 
A = cell(T,1);

Sg = cell(T,1);
Sx = cell(T,1);
Comms = cell(T,1);
Z = cell(T,1);
Lg = cell(T,1);
Lx = cell(T,1);
alpha = cell(T,IterRep);


N = zeros(T,1);
M = zeros(T,1);
for t=1:T
    %number of nodes
    N(t) = size(Net{t},1);
    %number of attributes
    M(t) = size(Attr{t},2);
end

numfig = 1;

if plotflag == 1
    MinAttr = zeros(2,1);
    MaxAttr = zeros(2,1);

    for j = 1:M
        MinAttr(j) = min(Attr{1}(:,j));
        MaxAttr(j) = max(Attr{1}(:,j));
        for t=2:T
            MinAttrNew = min(Attr{t}(:,j));
            if MinAttrNew < MinAttr(j)
                MinAttr(j) = MinAttrNew;
            end
            MaxAttrNew = max(Attr{t}(:,j));
            if MaxAttrNew > MaxAttr(j)
                MaxAttr(j) = MaxAttrNew;
            end
        end
    end 
end


for rep=1:IterRep
    %Initialization of arrays for NMI and VI
    NMI = zeros(T,1);
    VI = zeros(T,1);
    Jaccard = zeros(T,1);
    Precision = zeros(T,1);
    Sensitivity = zeros(T,1);
    Specificity = zeros(T,1);
    RandIndex = zeros(T,1);
    AdjustedRandIndex = zeros(T,1);
    timeTotalStart = tic;
    for t = 1:T
        if ~attrsIncBool
            M(t) = size(Attr{t},2);
            reduceAtStr = "";
            numAttrs = "";
        else 
            Attr{t} = Attr{t}(:,reduceAt);
            M(t) = size(Attr{t},2);
            reduceAtStr1 = num2str(reduceAt);
            reduceAtStr = "At"+reduceAtStr1(~isspace(reduceAtStr1));
            numAttrs = "nAt"+num2str(M(t));
        end
        if structSim == 1
            G = graph(Net{t});
            %distances according to Tang (2020)
            Wg = distances(G);%NOTE: is the diagonal supposed to be inf?
            if sigmaMST
                MSTG = minspantree(G);
                sigmaSq1 = (max(max(distances(MSTG))))^2;
                if sigmaSq1 == Inf%It does not specify what to do
                    sigmaSq1 = (N(t)*10)^2;
                end
            else
                knum = log(N(t))+1;
                if sum(sum(Wg==Inf)) > 0
                    for i=1:N(t)
                        for j=1:N(t)
                            if Wg(i,j)==Inf
                                Wg(i,j) = N(t)*10;
                            end
                        end
                    end
                end
                idx = knnsearch(Wg,Wg,'k',int8(knum));
                mean = 0;
                cont = 0;
                for i=1:N(t)
                    mean = mean + pdist([Wg(i,:); Wg(idx(i,int8(knum)),:)]);
                    cont = cont + 1;
                end
                mean = mean/cont;
                sigmaSq1 = mean^2;
                if sigmaSq1 == Inf
                    sigmaSq1 = (N(t)*10)^2;
                end
            end
            N(t) = size(Net{t},1);
            %graph symmetric similarity matrix
            Sg{t} = exp(-((Wg.*Wg)/(sigmaSq1*log(N(t)))));
            [Lg{t}, ~] = Laplacian(Sg{t},[]);
        else
            Sg{t} = Net{t};
            Lg{t} = Laplacian(Net{t});
        end

        if eigsStatic
            [Ug,vals] = eigs(Lg{t}',K(t));
            if t == 1
                if K(t) ~= 1
                    Ugt1 = Ug;
                else
                    Ugt1 = zeros(size(Ug,1),2);
                    Ugt1(:,1) = Ug;
                end
            end       
        else
            [~,Diag,Ug] = eig(Lg{t});
            [~,ind] = sort(abs(diag(Diag)),'descend');
            Ug = Ug(:,ind);
            if t == 1
                Ugt1 = Ug;
            end
            Ug = Ug(:,1:K(t));
        end
        
        if sum(sum(abs(imag(Ug)))) ~= 0
            if printWarning
                disp(["Seed",seed])
                disp(["Rep",rep])
                disp(["Iter",iter])
                disp("complex Ug")
            end
            Ug=real(Ug);
        end

        for i=1:N(t)
            NormalizerUg = norm(Ug(i,:),1);
            if NormalizerUg > 0
                Ug(i,:)=Ug(i,:)/NormalizerUg;
            end
        end


        %norm(Ug)
        if NormalizerAbs
            NormalizerUg = sum(abs(Ug),2);
            if NormalizerUg > 0
                Ug=Ug./NormalizerUg;
            end
        end

        if NormalizerNoAbs
            NormalizerUg = sum(Ug,2);
            if NormalizerUg ~= 0
                Ug=Ug./NormalizerUg;
            end
        end
            
        NumalphaDiff = zeros(M(t),1);
        if t == 1  
            alpha{t,rep} = ones(M(t),1);%[0.0477137307240585;0.611527419834035;0.340758849441906];%
            alpha{t,rep} = alpha{t,rep}/(sum(alpha{t,rep}));
        else
            alpha{t,rep}=alpha{t-1,rep};
        end
    
        num = zeros(N(t),N(t));
        if sigmaMST
            EuclideanWx = pdist(Attr{t});%Euclidean distance
            sqWx = squareform(EuclideanWx);
            G = graph(sqWx);
            MSTG = minspantree(G);
            sigmaSq2=(max(max(distances(MSTG))))^2;
        else
            knum = log(N(t))+1;
            idx = knnsearch(Attr{t},Attr{t},'k',int8(knum));
            Attr2 = Attr{t}(idx(:,int8(knum)),:);
            mean = 0;
            cont = 0;
            for i=1:N(t)
                mean = mean + pdist([Attr{t}(i,:); Attr2(idx(i,int8(knum)),:)]);
                cont = cont + 1;
            end
            mean = mean/cont;
            sigmaSq2=mean^2;
        end
        for m=1:M(t)
            if ~HammingDistance
                EuclideanWx = pdist(Attr{t}(:,m));%Euclidean distance
                sqWx = squareform(EuclideanWx);
            else
                HammingWx = pdist(Attr{t}(:,m));%Hamming distance
                sqWx = squareform(HammingWx);
            end
            
            num = num + (sqWx.^2)*alpha{t,rep}(m); 
        end
        
        Sx{t} = exp(-(num/(sigmaSq2)));

        [Lx{t}, ~] = Laplacian(Sx{t},[]);

        if eigsStatic
            [Ux,vals] = eigs(Lx{t}',K(t));
            if t == 1
                if K(t) ~= 1
                    Uxt1 = Ux;
                else
                    Uxt1 = zeros(size(Ux,1),2);
                    Uxt1(:,1) = Ux;
                end
            end        
        else
            
            [~,Diag,Ux] = eig(Lx{t});
            [~,ind] = sort(diag(Diag),'descend');
            
            Ux = Ux(:,ind); 
            if t == 1
                Uxt1 = Ux;
            end
            Ux = Ux(:,1:K(t));
        end
        if sum(sum(abs(imag(Ux)))) ~= 0
            if printWarning
                disp(["Seed",seed])
                disp(["Rep",rep])
                disp(["Iter",iter])
                disp("complex Ux")
            end                
            Ux=real(Ux);
        end


        for i=1:N(t)
            NormalizerUx = norm(Ux(i,:),1);
            if NormalizerUx > 0
                Ux(i,:)=Ux(i,:)/NormalizerUx;
            end
        end

        
        if NormalizerAbs
            NormalizerUx = sum(abs(Ux),2);
            if NormalizerUx > 0
                Ux=Ux./NormalizerUx;
            end
        end
        %norm(Ux)
        if NormalizerNoAbs
            NormalizerUx = sum(Ux,2);
            if NormalizerUx ~= 0
                Ux=Ux./NormalizerUx;
            end
        end

        UgUx = [Ug Ux];
        
        if NormalizeUgUxAt
            for i=1:N(1)
                NormalizerUgUxAt = norm(UgUx(i,:),1);
                if NormalizerUgUxAt > 0
                    UgUx(i,:)=UgUx(i,:)/NormalizerUgUxAt;
                end
            end
        end   

        rng(rep);
        Z{t} = kmeans(UgUx,K(t),'Replicate', replicate);

        flag = 1;

        NcutX = 1;
        iter = 0;
        
        if M(t) == 1
            learnAlphat = 0;
        else
            learnAlphat = learnAlpha;
        end
        if learnAlphat 
            while(flag)
                %matrix of cluster centers
                C = zeros(K(t),M(t));
                %to assign belonging of nodes
                Comms{t} = zeros(N(t),K(t));
                for n=1:N(t)
                    for k=1:K(t)
                        if Z{t}(n) == k
                            Comms{t}(n,k)=1;
                        end
                    end
                end
                for k=1:K(t)
                    for m=1:M(t)
                        C(k,m) = Comms{t}(:,k)'*Attr{t}(:,m)/sum(Comms{t}(:,k));%I have to check the centers
                    end
                end

                
                NcutXnew = Ncut(Comms{t},Sx{t});
                if (iter > MaxIter || norm(NcutX-NcutXnew) < epsilon) %|| NcutX < epsilon)%(abs(NcutGnew - NcutXnew) < epsilon || iter >= MaxIter)%((norm(NcutG-NcutGnew) < epsilon && norm(NcutX-NcutXnew) < epsilon) || iter == MaxIter) %&& norm(NcutXnew-NcutX) < epsilon)
                    break;
                else

                    NcutX = NcutXnew;
                end

                e = zeros(M(t));
                f = zeros(M(t));
                AttrMean = sum(Attr{t})/N(t);
                for m=1:M(t)
                    for k = 1:K(t)
                        iIdx = find(Comms{t}(:,k))';
                        f(m) = f(m) + sum(Comms{t}(:,k))*(C(k,m)-AttrMean(m))^2;
                        for i = iIdx
                            e(m) = e(m) + (Attr{t}(i,m)-C(k,m))^2;
                        end
                    end

                end

                DenalphaDiff = 0;
                for m=1:M(t) 
                    if e(m)~=0
                        NumalphaDiff(m) = f(m)/e(m);
                    else
                        NumalphaDiff(m) = 0;
                    end
                    DenalphaDiff = DenalphaDiff + NumalphaDiff(m);
                end
                
                for m=1:M(t)
                    alphaDiff = NumalphaDiff(m)/DenalphaDiff;
                
                    alpha{t,rep}(m) = 1/2*(alpha{t,rep}(m)+alphaDiff);

                    if isnan(alpha{t,rep}(m))
                        alpha{t,rep}(m)=0;
                    end
                end
                
                iter = iter + 1;
                
                num = zeros(N(t),N(t));
                if sigmaMST
                    EuclideanWx = pdist(Attr{t});%Euclidean distance
                    sqWx = squareform(EuclideanWx);
                    G = graph(sqWx);
                    MSTG = minspantree(G);
                    sigmaSq2=(max(max(distances(MSTG))))^2;
                else
                    knum = log(N(t))+1;
                    idx = knnsearch(Attr{t},Attr{t},'k',int8(knum));
                    Attr2 = Attr{t}(idx(:,int8(knum)),:);
                    mean = 0;
                    cont = 0;
                    for i=1:N(t)
                
                        mean = mean + pdist([Attr{t}(i,:); Attr2(idx(i,int8(knum)),:)]);
                        cont = cont + 1;
                    end
                    mean = mean/cont;
                    sigmaSq2=mean^2;
                end
                for m=1:M(t)
                    if ~HammingDistance
                        EuclideanWx = pdist(Attr{t}(:,m));%Euclidean distance
                        sqWx = squareform(EuclideanWx);
                    else
                        HammingWx = pdist(Attr{t}(:,m));%Hamming distance
                        sqWx = squareform(HammingWx);
                    end
                
                    num = num + (sqWx.^2)*alpha{t,rep}(m); 
                end
                
                Sx{t} = exp(-(num/(sigmaSq2)));


                [Lx{t}, ~] = Laplacian(Sx{t},[]);

                if eigsStatic
                    [Ux,vals] = eigs(Lx{t}',K(t));
                    if t == 1
                        Uxt1 = Ux;
                    end        
                else
                    [~,Diag,Ux] = eig(Lx{t});
                    [~,ind] = sort(diag(Diag),'descend');
                    Ux = Ux(:,ind); 
                    if t == 1
                        Uxt1 = Ux;
                    end
                    Ux = Ux(:,1:K(t));
                end
                if sum(sum(abs(imag(Ux)))) ~= 0
                    if printWarning
                        disp(["Seed",seed])
                        disp(["Rep",rep])
                        disp(["Iter",iter])
                        disp("complex Ux")
                    end
                    Ux=real(Ux);
                end
                
                for i=1:N(t)
                    NormalizerUx = norm(Ux(i,:),1);
                    if NormalizerUx > 0
                        Ux(i,:)=Ux(i,:)/NormalizerUx;
                    end
                end
                if NormalizerAbs
                    NormalizerUx = sum(abs(Ux),2);
                    if NormalizerUx > 0
                        Ux=Ux./NormalizerUx;
                    end
                end
                if NormalizerNoAbs
                    NormalizerUx = sum(Ux,2);
                    if NormalizerUx ~= 0
                        Ux=Ux./NormalizerUx;
                    end
                end
                

                UgUx = [Ug Ux];

                if NormalizeUgUxAt
                    for i=1:N(1)
                        NormalizerUgUxAt = norm(UgUx(i,:),1);
                        if NormalizerUgUxAt > 0
                            UgUx(i,:)=UgUx(i,:)/NormalizerUgUxAt;
                        end
                    end
                end 
        

                rng(rep);
                Z{t} = kmeans(UgUx,K(t),'Replicate', replicate);
                
            end
        else
            Comms{t} = zeros(N(t),K(t));
            for n=1:N(t)
                for k=1:K(t)
                    if Z{t}(n) == k
                        Comms{t}(n,k)=1;
                    end
                end
            end
        end
        Commstotal{rep,t} = Z{t};
    end
    Timetotal{rep} = toc(timeTotalStart);

    NetMet = Net;
    %% Results
    
for t = 1:T
    if ismember(attrsType,["CategoricosHamming","Categoricos"])
        numComms = unique(Z{t});
        partition = zeros(size(numComms,1),size(Z{t},1));
        partitionToSave = zeros(size(numComms,1),size(Z{t},1));
        posComm = ones(size(numComms,1),1);

        for i = 1:size(Z{t},1)
            for j = 1:size(numComms,1)
                if Z{t}(i) == numComms(j)
                    if ~ismember(120:131,Data)
                        partition(j,posComm(j)) = i;
                        partitionToSave(j,posComm(j)) = i;
                    else
                        partition(j,posComm(j)) = i;
                        partitionToSave(j,posComm(j)) = Vindex{t}(i);
                    end
                    posComm(j) = posComm(j) + 1;
                end
            end
        end
    end
    Modularitytotal(t) = modularity(Z{t},NetMet{t,1});
    Densitytotal(t) = density(Z{t},NetMet{t,1});         
    if size(Attr,1) > size(Attr,2) 
        if ismember(attrsType,["CategoricosHamming","Categoricos"])
            entropyt = entropy(partition,Attr{t,1},nbins);
            silt = evalclusters(Attr{t,1},Z{t},'silhouette','Distance','Hamming');
            Entropytotal(t) = entropyt;
            Siltotal(t) = silt.CriterionValues;
        end
        if attrsType == "Reales"
            dbt = evalclusters(Attr{t,1},Z{t},'DaviesBouldin');
            cht = evalclusters(Attr{t,1},Z{t},'CalinskiHarabasz');
            silt = evalclusters(Attr{t,1},Z{t},'silhouette','Distance','Euclidean');
            DBtotal(t) = dbt.CriterionValues;
            CHtotal(t) = cht.CriterionValues;
            Siltotal(t) = silt.CriterionValues;
        end
    else
        if ismember(attrsType,["CategoricosHamming","Categoricos"])
            entropyt = entropy(partition,Attr{1,t},nbins);
            silt = evalclusters(Attr{1,t},Z{t},'silhouette','Distance','Hamming');
            Entropytotal(t) = entropyt;
            Siltotal(t) = silt.CriterionValues;
        end
        if attrsType == "Reales"
            dbt = evalclusters(Attr{1,t},Z{t},'DaviesBouldin');
            cht = evalclusters(Attr{1,t},Z{t},'CalinskiHarabasz');
            silt = evalclusters(Attr{1,t},Z{t},'silhouette','Distance','Euclidean');
            DBtotal(t) = dbt.CriterionValues;
            CHtotal(t) = cht.CriterionValues;
            Siltotal(t) = silt.CriterionValues;
        end
    end            
    NMIval = getNMI(Z{t},GT{t});
    NMItotal(t,1) = NMIval;
    NMI(t) = getNMI(Z{t},GT{t});
    VI(t) = getVI(Z{t},GT{t});
    [Jaccard(t),Precision(t),Sensitivity(t),Specificity(t),RandIndex(t),AdjustedRandIndex(t)] = getMeasures(Z{t}',GT{t});



    if plotflag
        cd ImagesOutput
        Comms = zeros(maxsize,K(t));
        for n=1:maxsize
            for k=1:K(t)
                if Z{t}(n) == k
                    Comms(n,k)=1;
                end
            end
        end
        figure(numfig)
        imagesc(Comms)
        colormap(gray(256))
        title(strcat("Community assignment at time t = ",num2str(t)))
        xlabel("Communities")
        ylabel("Nodes")
        saveas(gcf,strcat('D',num2str(Data),'t',num2str(t),'R',num2str(rep),'s',num2str(seed),'i',num2str(MaxIter),'s',num2str(structSim),'A',num2str(NormalizerAbs),'nA',num2str(NormalizerNoAbs),'s',num2str(sigmaMST),'wn',num2str(NormalizeWnorm2),'ws',num2str(NormalizeWsum1),'am',num2str(NormalizeAttrMax),'as',num2str(NormalizeAttrSum),'nU',num2str(NormalizeUgUxAt),'l',num2str(learnAlpha),'K23','.png'))%'K23'
        cd ..
    end
end
    numfig=numfig+1;


    NMItotalorig{rep} = NMI;
    VItotal{rep} = VI;
    Jaccardtotal{rep} = Jaccard;
    Precisiontotal{rep} = Precision;
    Sensitivitytotal{rep} = Sensitivity;
    Specificitytotal{rep} = Specificity;
    RandIndextotal{rep} = RandIndex;
    AdjustedRandIndextotal{rep} = AdjustedRandIndex;
    
end



if plotflag == 1
    figure(numfig)
    imagesc(Comms{t})
    colormap(gray(256))
    xlabel("Communities")
    ylabel("Nodes")
    numfig=numfig+1;
end

if plotflagData == 1
    cd ImagesData

    figure(numfig)
    imagesc(Net{t})
    colormap(gray(256))
    colorbar
    title(strcat("Adjacency matrix at time t = ",num2str(t)))
    xlabel("Nodes")
    ylabel("Nodes")
    numfig=numfig+1;
    saveas(gcf,strcat('TN1Adjt',num2str(t),'.png'))
    
    for j =1:M
        figure(numfig)
        imagesc(Attr{t}(:,j),[MinAttr(j) MaxAttr(j)])
        colormap(gray(256))
        colorbar
        title(strcat("Attribute matrix at time t = ",num2str(t)))
        xlabel(strcat("Atribute ",num2str(j)))
        ylabel("Nodes")
        set(gca,'xtick',[])
        saveas(gcf,strcat('TN1Attr',num2str(j),'t',num2str(t),'.png'))
        numfig=numfig+1;
    end
   
end



if saveResults
    cd(dirFolder)
    
    folderToCheck = extractBetween(saveName,1,8)+"ResA"+num2str(Alg)+"D"+num2str(Data)+"/";
    if ~exist(folderToCheck, 'dir')
       mkdir(folderToCheck)
    end
    dataNoGT =[];
    if ismember(Data,dataNoGT) && Alg ~= 1
        saveNameNew = folderToCheck+"/Attr"+attrsType+"/"+extractBetween(saveName,9,strlength(saveName));
    else
        saveNameNew = folderToCheck+extractBetween(saveName,9,strlength(saveName));
    end
   
    
    if Data == 14 || Data == 15 || Data == 16  || Data == 89 || Data == 90 || Data == 91 || Data == 107 || Data == 108 || Data == 109
        save(strcat(saveNameNew,"A",int2str(Alg),'D',num2str(Data),'s',num2str(seed),'i',num2str(MaxIter),'s',num2str(structSim),'A',num2str(NormalizerAbs),'nA',num2str(NormalizerNoAbs),'s',num2str(sigmaMST),'am',num2str(NormalizeAttrMax),'as',num2str(NormalizeAttrSum),'nU',num2str(NormalizeUgUxAt),'l',num2str(learnAlpha),'PV',num2str(ProbVar),'rk',num2str(replicate),numAttrs,reduceAtStr,"Rep.mat"),'NMItotal','VItotal','Timetotal','Alg','Data','alpha','Commstotal','Modularitytotal','Densitytotal','Entropytotal','DBtotal','CHtotal','Siltotal');
    elseif Data == 17 || Data == 18 || Data == 19 || Data == 20 || Data == 21 || Data == 22
        save(strcat(saveNameNew,"A",int2str(Alg),'D',num2str(Data),'s',num2str(seed),'i',num2str(MaxIter),'s',num2str(structSim),'A',num2str(NormalizerAbs),'nA',num2str(NormalizerNoAbs),'s',num2str(sigmaMST),'am',num2str(NormalizeAttrMax),'as',num2str(NormalizeAttrSum),'nU',num2str(NormalizeUgUxAt),'l',num2str(learnAlpha),'R',num2str(randomAttrs),'M',num2str(multiAttrs),'rk',num2str(replicate),numAttrs,reduceAtStr,"Rep.mat"),'NMItotal','VItotal','Timetotal','Alg','Data','alpha','Commstotal','Modularitytotal','Densitytotal','Entropytotal','DBtotal','CHtotal','Siltotal');
    else
        save(strcat(saveNameNew,"A",int2str(Alg),'D',num2str(Data),'s',num2str(seed),'i',num2str(MaxIter),'s',num2str(structSim),'A',num2str(NormalizerAbs),'nA',num2str(NormalizerNoAbs),'s',num2str(sigmaMST),'am',num2str(NormalizeAttrMax),'as',num2str(NormalizeAttrSum),'nU',num2str(NormalizeUgUxAt),'l',num2str(learnAlpha),'rk',num2str(replicate),numAttrs,reduceAtStr,"Rep.mat"),'NMItotal','VItotal','Timetotal','Alg','Data','alpha','Commstotal','Modularitytotal','Densitytotal','Entropytotal','DBtotal','CHtotal','Siltotal');
    end

end

if initIn
    fullTime = toc(initInTimeStart)
end

function Ncut = Ncut(Comms,S)

K = size(Comms,2);
for k = 1:K
    iIdx = find(Comms(:,k))';
    jIdx = find(~Comms(:,k))';
    num = 0;
    den = 0;
    for i=iIdx
        for j=jIdx
            num = num + S(i,j);
            den = den + S(i,j);
        end
        for ii=iIdx
            den = den + S(i,ii);
        end
    end
    Ncut = num/den;
end
end

function [A, maxsize] = Laplacian(Net,maxsize)

    %Degree of each node
    D = sum(Net,2);
    %Number of nodes
    numNodes1 = size(D,1);
    %Indices for the rows/columns with all zero values, in case they exist
    rowZeroIndex = find(all(D == 0,2));
    %In case there are full rows/columns with zero values
    if ~isempty(rowZeroIndex)
        A = Net;
        %Remove each row/columns with full zero values
        for j=1:length(rowZeroIndex)
            A(rowZeroIndex(j)-j+1,:)=[];
            A(:,rowZeroIndex(j)-j+1)=[];
        end
        %Degree of each node without the full zeros columns/rows
        D = sum(A,2);
        %Calculation of normalized adjacency matrices
        A = diag(D)^(-1/2)*A*diag(D)^(-1/2);
        %Next 4 lines are for adding the zero rows/columns again
        p = ~ismember(1:numNodes1,rowZeroIndex);
        M = bsxfun(@and,p,p')+0;
        M(M~=0)=A;
        A = M;
    else
        %Calculation of normalized adjacency matrices
        A = diag(D)^(-1/2)*Net*diag(D)^(-1/2); %Normalized adjacency matrix
    end
    %Number of nodes for the current snapshot
    dimA = size(A,1);
  
    
end
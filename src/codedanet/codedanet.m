%% Clear all
clear;


printWarning = 0;

Alg = 15;

if(~isdeployed)
  cd(getProjectRoot());
end

dirFolder = pwd;

%Name of the output file
saveName ="Results/Testing";
replicate = 20;

khatri = 0;
reig = 1;
displayW = 0;
WfixedW = 0;
WfixedX = 1;
MaxIterW = 20;
boolColSize = 0;
if boolColSize
    ColSize = 2;
end
printTimeKro = 0;
mttkrpUse = 0;
useNcutG = 0;

WfixedVal = [1;0];
%To define if the structural similarity function is used
structSim = 0;
svdSizeKR = 1;
attrsIncBool = 0;
%Number of dataset to use
%17 and 18: SyntheticNetwork1
%107, 108, 109: SyntheticNetwork2
%19, 20, 21, 22: SyntheticNetwork3
Data = 122;
%For SyntheticNetwork1 and SyntheticNetwork3
randomAttrs = 0;
multiAttrs = 1;
%For SyntheticNetwork2
ProbVar = 0.21;%0.25 %for 107
%ProbVar = 0.1;%0.14 %for 108
%ProbVar = 0.19;%0.23 %for 109

%Define the random seed numbers to use
RepSet = [1];%[3];
%Seed for the random generation of the data (where applies)
seed = 1;
%Maximum number of iterations for the alternatg optimization
MaxIter = 20;

%Values for the window size. At most the the value of T
Ls = 2;

typeDiag = 0;

NormalizeAttrMax = 0;
NormalizeAttrSum = 0;
NormalizerAbs = 0;
NormalizerNoAbs = 0;

sigmaMST = 1;

eigsStatic = 0;

absGSta = 1;
absXSta = 0;
Ucomb = 2;

alphaUAttr = 0.5;

NormalizeUgBoolSta = 2;
NormalizeUxBoolSta = 2;

svdCalc = 0;

NormalizeWnorm2 = 1;
NormalizeWsum1 = 0;

if typeDiag == 0
    absG = 0;
    absX = 0;
else
    absG = 1;
    absX = 1;
end

NormalizeUgBool = 0;
NormalizeUxBool = 0;

NormalizeUgUxSta = 2;
NormalizeUgUx = 2;

ReduceUnToK = 1;

%Use coldstart when multiple tensors are used
coldstart = 1;

%Stopping criteria for early convergence
earlystop = 1;

learnAlpha = 1;

initTimeStart = tic;

attrsType = "Reales";%"CategoricosHamming";%"Reales";%"Categoricos";
if Data == 132 || Data == 150 || Data == 139 || Data == 160
    attrsType = "CategoricosHamming";
end
if attrsType == "CategoricosHamming"
    HammingDistance = 1;
    HammingDistanceSigmaMST = 1;
else
    HammingDistance = 0;
    HammingDistanceSigmaMST = 0;
end     

%To vary the number of communities used
if ismember(Data,[132,139,150,160])
    kvar = 1;
    %How many values of the number of communities K to use 
    KValNum = 3;%5;%12;%8;%10;%Better uneven in order to recognize the number of components
else
    kvar = 0;
end    
nbins = 0;
discretizeAttr = 0;

%Flag for plottg community assignment
plotflag = 0;
plotflagData = 0;

MaxMod = 0;
MaxDen = 0;
MinEnt = 0;
MaxSil = 0;
MaxCH = 0;
MinDB = 0;
%Combined matrix are only used when K varies
MaxModEnt = 1;
MaxDenEnt = 0;
MaxModSil = 0;
MaxDenSil = 0;
MaxModCH = 0;
MaxDenCH = 0;
MaxModDB = 0;
MaxDenDB = 0;    
weightMod = 0.5;

printMetrics = 0;

%Minimum change threshold
epsilon = 1e-5;
saveResults = 1;
static = 0;


if MaxModEnt == 1
    Opt = "ME";
elseif MaxDenEnt == 1
    Opt = "DE";
elseif MaxModSil == 1
    Opt = "MS";
elseif MaxDenSil == 1
    Opt = "DS";
elseif MaxModCH == 1
    Opt = "MC";
elseif MaxDenCH == 1
    Opt = "DC";
elseif MaxModDB == 1
    Opt = "MD";
elseif MaxDenDB == 1   
    Opt = "DD";
end
numfig = 1;

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

%Define the number of iterations to do
IterRep = size(RepSet,1);

%Nodes at Vindex for t = 1 must be preprocessed to start at 1, having consecutive numbers, 
%without having missing values. If a missing value exist in a future time step, this means
%that the node left the network. A node that left the network must be
%inserted according to its number. In this way, for all time steps, the
%indices of the nodes are ordered

timeData=toc(timeData);

cd ..

%Number of time intervals
if ismember(Data,[150,160])
    %T = 10;
    T = size(Net,1);
elseif ismember(Data,[132,139])
    T = size(Net,1);
else
    T = size(Net,1);
    if T > size(Net,1)
        T = size(Net,1);
    end
end

if static
    T = 1;
end

if exist('Vindex', 'var') == 0
    Vindex = cell(T,1);
    for t = 1:T
        Vindex{t} = 1:size(Net{t},1);
    end
end


%if nbins changes for detection of communities. Else they will change only
%for entropy computation, according to the number of bins
if discretizeAttr
    for t = 1:T
        [Attr{1,t},E] = discretize(Attr{1,t},nbins,'IncludedEdge','right');
    end
    attrsType = "CategoricosHamming";
end

%%To test different values of communities, the starting value is the number
%%of connected components unless stated otherwise
%Difference between the number of communities that are used
kchange = 1;%3
%Percentage of KValNum values that are below the number of connected
%components
PercLessK = 1/2;%1/6;
%kvar defines if the number of communities is gonna be set inside the
%algorithm or if taken from the ground truth


if kvar == 1
    Kt = cell(T,KValNum);
else
    KValNum = 1;
    Kt = cell(T,KValNum);
    for t = 1:T
        Kt{t,KValNum}=K(1,t);
    end
end

%Initialization of arrays according to a dynamic or static network
if T > 1
    Commstotal = cell(T,KValNum);
    NMItotal = zeros(T,KValNum);
    VItotal = zeros(T,KValNum);
    Jaccardtotal = zeros(T,KValNum);
    Precisiontotal = zeros(T,KValNum);
    Sensitivitytotal = zeros(T,KValNum);
    Specificitytotal = zeros(T,KValNum);
    RandIndextotal = zeros(T,KValNum);
    AdjustedRandIndextotal = zeros(T,KValNum);
    Modularitytotal = zeros(T,KValNum);
    Densitytotal = zeros(T,KValNum);
    Entropytotal = zeros(T,KValNum);
    DBtotal = zeros(T,KValNum);
    CHtotal = zeros(T,KValNum);
    Siltotal = zeros(T,KValNum);
    ModEnttotal = zeros(T,KValNum);
    DenEnttotal = zeros(T,KValNum);
    timeTensor = cell(size(Ls,2),1);
    TimeAlSharoa = cell(IterRep,size(Ls,2));
    
    NMItotalSta = zeros(T,KValNum);
    VItotalSta = zeros(T,KValNum);
    JaccardtotalSta = zeros(T,KValNum);
    PrecisiontotalSta = zeros(T,KValNum);
    SensitivitytotalSta = zeros(T,KValNum);
    SpecificitytotalSta = zeros(T,KValNum);
    RandIndextotalSta = zeros(T,KValNum);
    AdjustedRandIndextotalSta = zeros(T,KValNum);
    ModularitytotalSta = zeros(T,KValNum);
    DensitytotalSta = zeros(T,KValNum);
    EntropytotalSta = zeros(T,KValNum);
    DBtotalSta = zeros(T,KValNum);
    CHtotalSta = zeros(T,KValNum);
    SiltotalSta = zeros(T,KValNum);
    DenEnttotalSta = zeros(T,KValNum);
    ModEnttotalSta = zeros(T,KValNum);
    DenSiltotalSta = zeros(T,KValNum);
    ModSiltotalSta = zeros(T,KValNum);
    DenCHtotalSta = zeros(T,KValNum);
    ModCHtotalSta = zeros(T,KValNum);
    DenDBtotalSta = zeros(T,KValNum);
    ModDBtotalSta = zeros(T,KValNum);
    Ugt1OverKt = cell(KValNum,1);
    UgOverKt = cell(KValNum,1);
    Uxt1OverKt = cell(KValNum,1);
    UxOverKt = cell(KValNum,1);
    
    CommstotalStat1 = cell(IterRep,KValNum);
    CommstotalSta = cell(T,KValNum);
else
    Commstotal = cell(1,KValNum);
    NMItotal = cell(IterRep,1);
    VItotal = cell(IterRep,1);
    Jaccardtotal = cell(IterRep,1);
    Precisiontotal = cell(IterRep,1);
    Sensitivitytotal = cell(IterRep,1);
    Specificitytotal = cell(IterRep,1);
    RandIndextotal = cell(IterRep,1);
    AdjustedRandIndextotal = cell(IterRep,1);
    Modularitytotal = cell(IterRep,1);
    Densitytotal = cell(IterRep,1); 
    Entropytotal = cell(IterRep,1);
    DBtotal = cell(IterRep,1);
    CHtotal = cell(IterRep,1);
    Siltotal = cell(IterRep,1);
    ModEnttotal = cell(IterRep,1);
    DenEnttotal = cell(IterRep,1);    
    
    CommstotalSta = cell(1,KValNum);
    CommstotalStat1 = cell(IterRep,KValNum);
    timeTensor = cell(1,1);
    TimeAlSharoa = cell(IterRep,1);
end

%Initialization of a cell array for handling temporary operations 
A = cell(T,1);
%Initialization of array for the number of attributes
M = zeros(T,1);
%Initialization of array for the number of nodes
N = zeros(T,1);
%Initialization of array for recording the max modularity
if MaxMod
    MaxModularityTotal = zeros(T,1);%dynamic phase
    MaxModularityTotalSta = zeros(T,1);%static phase
elseif MaxDen
    MaxDensityTotal = zeros(T,1);%dynamic phase
    MaxDensityotalSta = zeros(T,1);%static phase
elseif MinEnt
    MinEntropyTotal = zeros(T,1);%dynamic phase
    MinEntropyTotalSta = zeros(T,1);%static phase
elseif MaxSil
    MaxSilhouetteTotal = zeros(T,1);%dynamic phase
    MaxSilhouetteTotalSta = zeros(T,1);%static phase
elseif MaxCH
    MaxCalinskiHarabaszTotal = zeros(T,1);%dynamic phase
    MaxCalinskiHarabaszTotalSta = zeros(T,1);%static phase
elseif MinDB
    MinDaviesBouldinTotal = zeros(T,1);%dynamic phase
    MinDaviesBouldinTotalSta = zeros(T,1);%static phase
elseif MaxModEnt
    MaxModularityEntropyTotal = zeros(T,1);%dynamic phase
    MaxModularityEntropyTotalSta = zeros(T,1);%static phase    
elseif MaxDenEnt
    MaxDensityEntropyTotal = zeros(T,1);%dynamic phase
    MaxDensityEntropyTotalSta = zeros(T,1);%static phase   
elseif MaxModSil
    MaxModularitySilhouetteTotal = zeros(T,1);%dynamic phase
    MaxModularitySilhouetteTotalSta = zeros(T,1);%static phase    
elseif MaxDenSil
    MaxDensitySilhouetteTotal = zeros(T,1);%dynamic phase
    MaxDensitySilhouetteTotalSta = zeros(T,1);%static phase   
elseif MaxModCH
    MaxModularityCalinskiHarabaszTotal = zeros(T,1);%dynamic phase
    MaxModularityCalinskiHarabaszTotalSta = zeros(T,1);%static phase    
elseif MaxDenCH
    MaxDensityCalinskiHarabaszTotal = zeros(T,1);%dynamic phase
    MaxDensityCalinskiHarabaszTotalSta = zeros(T,1);%static phase   
elseif MaxModDB
    MaxModularityDaviesBouldinTotal = zeros(T,1);%dynamic phase
    MaxModularityDaviesBouldinTotalSta = zeros(T,1);%static phase    
elseif MaxDenDB
    MaxDensityDaviesBouldinTotal = zeros(T,1);%dynamic phase
    MaxDensityDaviesBouldinTotalSta = zeros(T,1);%static phase   
end   
    
%Initialization of array for recording the value of k where the max
%modularity appears
Maxkiter = zeros(T,1);%dynamic phase
MaxkiterSta = zeros(T,1);%static pahse
%Initialization of array for recording the weights of the attributes
alpha = cell(T,KValNum);
%Initialization of maximum number of nodes
maxsize = 0;
UgUxKmeansSta = cell(T,KValNum);
UgUxKmeansDyn = cell(T,KValNum);

%Initialization of the array for community assignment
CommsTN = cell(T,IterRep);

%Not used. Only to save the weight of the time steps inside the algorithm
WrepG=cell(T,IterRep);
WrepX=cell(T,IterRep);

%%Full algorithm
%For each iteration
for repidx=1:IterRep

    %Use the current seed
    rep = RepSet(repidx);
    %Array to save the similarity for attributes
    Sx = cell(T,1);
    %Array to save the eigenvectors for topology. Is the same for each number of
    %communities at each snapshot    
    Lg = cell(T,1);
    %Array to save the eigenvectors for attributes for each number of
    %communities at each snapshot
    Lx = cell(T,KValNum);
    %Only if the structural similarity is used
    if structSim == 1
        %Array to save structural similarity
        Sg = cell(T,1);
    end
    %To save the communities at each snapshot, only if the attributes of
    %the weights are learned. It contains matrices NxK and values 0-1
    Comms = cell(T,1);
    %To save communities at each time step for each number of communities,
    %using a column vector where each value represents a community
    %assignment
    Y = cell(T,KValNum);
    %To record time for computing eigenvectors for all time steps
    timeLaplaciansStart = tic;
    %To reset the difference between the number of communities that are
    %used to its original values
    kchangeOrig = kchange;
    NetMet = cell(size(Net));
    %% Loop over each snapshot in a static first phase
    for t = 1:T
        %Reset kchange at the start of each snapshot to its original value
        kchange = kchangeOrig;
        %initialization of the iterator over the possible values of K
        kiter = 1; 
        %initialization of the flag for the iterator over K
        kbool = 1;
        %number of nodes
        N(t) = size(Net{t},1);
        %Update diagonal
        NetMet(t) = Net(t);
        if structSim == 0
            if typeDiag == 1
                for i = 1:N(t)
                    Net{t}(i,i)=1;
                end
            elseif typeDiag == 2
                for i = 1:N(t)
                    Net{t}(i,i)=sum(Net{t}(i,:));
                end
            end
        end
        %Computing of the maximum number of communities so far
        if N(t) > maxsize
            maxsize = N(t);%only to plot
        end
        %number of attributes
        if ~attrsIncBool
            M(t) = size(Attr{t},2);
            reduceAtStr = "";

        else 
            Attr{t} = Attr{t}(:,reduceAt);
            M(t) = size(Attr{t},2);
            reduceAtStr1 = num2str(reduceAt);
            reduceAtStr = "At"+reduceAtStr1(~isspace(reduceAtStr1));
        end

        if NormalizeAttrMax
            for j = 1:M(t)
                MaxAttr = max(Attr{t}(:,j));
                Attr{t}(:,j)=abs(Attr{t}(:,j)/MaxAttr);
            end
        end
        if NormalizeAttrSum
            for j = 1:M(t)
                sumAttr = sum(Attr{t}(:,j));
                Attr{t}(:,j)=abs(Attr{t}(:,j)/sumAttr);
            end
        end

        %From matrix to graph format for calculating number of components
        G = graph(Net{t});
        %Number of nodes
        numNodes = N(t);
        %Count the number of connected components
        [~,binsAssign] = conncomp(G);
        numConnected = size(binsAssign,2);
        %If K is variable, it sets a starting value for K
        if kvar == 1
            if numConnected > 1
                valKt = numConnected-floor(kchange*KValNum*PercLessK);%kchange*2;
                if valKt < 2
                    Kt{t,1} = 2;
                else
                    Kt{t,1} = valKt;
                end
            else
                Kt{t,1} = 2;
            end  
        end

        %If the use of structural similarity is required
        if structSim == 1
            Wg = distances(G);
            %Sigma, parameter of the Gaussian similarity function, is 
            %computed by minimum spanning tree or k-nearest neighbor
            if sigmaMST
                MSTG = minspantree(G);
                sigmaSq1 = (max(max(distances(MSTG))))^2;
                if sigmaSq1 == Inf
                    sigmaSq1 = (N(t)*10)^2;
                end
            else
                knum = log(N(t))+1;
                %To replace infinity distances by a large number
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
                sumKNN = 0;
                cont = 0;
                for i=1:N(t)
                    sumKNN = sumKNN + pdist([Wg(i,:); Wg(idx(i,int8(knum)),:)]);
                    cont = cont + 1;
                end
                mean = sumKNN/cont;
                sigmaSq1 = mean^2;
                if sigmaSq1 == Inf
                    sigmaSq1 = (N(t)*10)^2;
                end
            end
            %graph symmetric similarity matrix
            Sg{t} = exp(-((Wg.*Wg)/(sigmaSq1*log(N(t)))));
            Lg{t} = Laplacian(Sg{t});
        else
            Sg{t} = Net{t};
            Lg{t} = Laplacian(Sg{t});
        end

        while kbool
            if eigsStatic
                [Ug,vals] = eigs(Lg{t}',Kt{t,kiter});%K(t)
                if t == 1
                    if Kt{t,kiter} ~= 1
                        Ugt1OverKt{kiter} = Ug;%Ugt1 = Ug;
                    else
                        Ugt1OverKt{kiter} = zeros(size(Ug,1),2);%Ugt1 = zeros(size(Ug,1),2);
                        Ugt1OverKt{kiter}(:,1) = Ug;%Ugt1(:,1) = Ug;
                    end
                end            
            else

                [~,Diag,Ug] = eig(Lg{t});
                if absGSta
                    [~,ind] = sort(abs(diag(Diag)),'descend');
                else
                    [~,ind] = sort(diag(Diag),'descend');
                end

                Ug = Ug(:,ind);
                if t == 1
                    Ugt1OverKt{kiter} = Ug;%Ugt1 = Ug;%Ugt1 is full size
                end
                Ug = Ug(:,1:Kt{t,kiter});%K(t)
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
            if NormalizeUgBoolSta
                for i=1:N(t)
                    if NormalizeUgBoolSta == 1
                        NormalizerUgSta = norm(Ug(i,:),1);
                    elseif NormalizeUgBoolSta == 2
                        NormalizerUgSta = norm(Ug(i,:),2);
                    else
                        NormalizerUgSta = norm(Ug(i,:),'fro');
                    end
                    if NormalizerUgSta > 0
                        Ug(i,:)=Ug(i,:)/NormalizerUgSta;
                    end
                end
            end

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
                alpha{t,kiter} = ones(M(t),1);
                alpha{t,kiter} = alpha{t,kiter}/(sum(alpha{t,kiter}));
            else
                if alpha{t-1,kiter} ~= 0
                    alpha{t,kiter}=alpha{t-1,kiter};
                else
                    alpha{t,kiter}=alpha{t-1,1};
                end
            end

            num = zeros(N(t),N(t));
            if sigmaMST
                if ~HammingDistanceSigmaMST
                    EuclideanWx = pdist(Attr{t});%Euclidean distance
                    sqWx = squareform(EuclideanWx);
                else
                    HammingWx = pdist(Attr{t},'hamming');%Hamming distance
                    sqWx = squareform(HammingWx);
                end
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
                    %pdist([Attr{t}(i,j); Attr{t}(idx(i,int8(knum)),j)])
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
                    HammingWx = pdist(Attr{t}(:,m),'hamming');%Hamming distance
                    sqWx = squareform(HammingWx);
                end
                %G = graph(sqWx);
                %MSTG = minspantree(G);
                %maxValnew=max(max(distances(MSTG)));
                %if maxValnew > maxVal
                %    maxVal = maxValnew;
                %end
                num = num + (sqWx.^2)*alpha{t,kiter}(m); 
            end

            Sx{t} = exp(-(num/(sigmaSq2)));

            Lx{t,kiter} = Laplacian(Sx{t});

            if eigsStatic
                [Ux,vals] = eigs(Lx{t,kiter}',Kt{t,kiter});%K(t)
                if t == 1
                    if Kt{t,kiter} ~= 1%K(t)
                        Uxt1OverKt{kiter} = Ux;
                    else
                        Uxt1OverKt{kiter} = zeros(size(Ux,1),2);
                        Uxt1OverKt{kiter}(:,1) = Ux;
                    end
                end      
            else

                [~,Diag,Ux] = eig(Lx{t,kiter});
                if absXSta
                    [~,ind] = sort(abs(diag(Diag)),'descend');
                else
                    [~,ind] = sort(diag(Diag),'descend');
                end

                Ux = Ux(:,ind); 
                if t == 1
                    Uxt1OverKt{kiter} = Ux;%Uxt1 is full size
                end
                Ux = Ux(:,1:Kt{t,kiter});%K(t)
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

            if NormalizeUxBoolSta
                for i=1:N(t)
                    if NormalizeUxBoolSta == 1
                        NormalizerUxSta = norm(Ux(i,:),1);
                    elseif NormalizeUxBoolSta == 2
                        NormalizerUxSta = norm(Ux(i,:),2);
                    else
                        NormalizerUxSta = norm(Ux(i,:),'fro');
                    end
                    if NormalizerUxSta > 0
                        Ux(i,:)=Ux(i,:)/NormalizerUxSta;
                    end
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

            if Ucomb == 1
                UgUx = (1-alphaUAttr)*Ug + alphaUAttr*Ux;
            elseif Ucomb == 2
                UgUx = [(1-alphaUAttr)*Ug alphaUAttr*Ux];
            elseif Ucomb == 0
                UgUx = [Ug Ux];
            end

            if NormalizeUgUxSta
                for i=1:N(t)
                    if NormalizeUgUxSta == 1
                        NormalizerUgUx = norm(UgUx(i,:),1);
                    elseif NormalizeUgUxSta == 2
                        NormalizerUgUx = norm(UgUx(i,:),2);
                    else
                        NormalizerUgUx = norm(UgUx(i,:),'fro');
                    end
                    if NormalizerUgUx > 0
                        UgUx(i,:)=UgUx(i,:)/NormalizerUgUx;
                    end
                end
            end   

            UgUxKmeansSta{t,kiter} = UgUx;
            rng(rep);
            Y{t,kiter} = kmeans(UgUxKmeansSta{t,kiter},Kt{t,kiter},'Replicate',replicate);


            flag = 1;
            if useNcutG
                NcutG = 1;
            end
            NcutX = 1;
            iter = 0;

            if M(t) == 1
                learnAlphat = 0;
            else
                learnAlphat = learnAlpha;
            end
            if learnAlphat 
                while(flag)
                    C = zeros(Kt{t,kiter},M(t));

                    Comms{t} = zeros(N(t),Kt{t,kiter});
                    for n=1:N(t)
                        for k=1:Kt{t,kiter}
                            if Y{t,kiter}(n) == k
                                Comms{t}(n,k)=1;
                            end
                        end
                    end
                    for k=1:Kt{t,kiter}
                        for m=1:M(t)
                            C(k,m) = Comms{t}(:,k)'*Attr{t}(:,m)/sum(Comms{t}(:,k));%I have to check the centers
                        end
                    end
                    if useNcutG
                        NcutGnew = Ncut(Comms{t},Sg{t});
                    end
                    NcutXnew = Ncut(Comms{t},Sx{t});
                    if useNcutG

                        if (iter > MaxIter || (norm(NcutX-NcutXnew) < epsilon) && (norm(NcutG-NcutGnew) < epsilon)) 
                            if iter > MaxIter
                                disp(norm(NcutG-NcutGnew))
                                disp(norm(NcutX-NcutXnew))
                            end
                            break;
                        else
                            NcutG = NcutGnew;
                            NcutX = NcutXnew;
                        end
                    else
                        if (iter > MaxIter || norm(NcutX-NcutXnew) < epsilon) %|| NcutX < epsilon)%(abs(NcutGnew - NcutXnew) < epsilon || iter >= MaxIter)%((norm(NcutG-NcutGnew) < epsilon && norm(NcutX-NcutXnew) < epsilon) || iter == MaxIter) %&& norm(NcutXnew-NcutX) < epsilon)

                            break;
                        else

                            NcutX = NcutXnew;
                        end
                    end


                    e = zeros(M(t));
                    f = zeros(M(t));
                    AttrMean = sum(Attr{t})/N(t);
                    for m=1:M(t)
                        for k = 1:Kt{t,kiter}
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

                        alpha{t,kiter}(m) = 1/2*(alpha{t,kiter}(m)+alphaDiff);

                        if isnan(alpha{t,kiter}(m))
                            alpha{t,kiter}(m)=0;
                        end
                    end



                    iter = iter + 1;

                    num = zeros(N(t),N(t));
                    if sigmaMST
                        if ~HammingDistanceSigmaMST
                            EuclideanWx = pdist(Attr{t});%Euclidean distance
                            sqWx = squareform(EuclideanWx);
                        else
                            HammingWx = pdist(Attr{t},'hamming');%Hamming distance
                            sqWx = squareform(HammingWx);
                        end
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
                            HammingWx = pdist(Attr{t}(:,m),'hamming');%Hamming distance
                            sqWx = squareform(HammingWx);
                        end
                        num = num + (sqWx.^2)*alpha{t,kiter}(m); 
                    end
                    Sx{t} = exp(-(num/(sigmaSq2)));


                    Lx{t,kiter} = Laplacian(Sx{t});

                    if eigsStatic
                        [Ux,vals] = eigs(Lx{t,kiter}',Kt{t,kiter});
                        if t == 1
                            Uxt1OverKt{kiter} = Ux;
                        end        
                    else
                        [~,Diag,Ux] = eig(Lx{t,kiter});
                        if absXSta
                            [~,ind] = sort(abs(diag(Diag)),'descend');
                        else
                            [~,ind] = sort(diag(Diag),'descend');
                        end
                        Ux = Ux(:,ind); 
                        if t == 1
                            Uxt1OverKt{kiter} = Ux;%Uxt1 is full size
                        end
                        Ux = Ux(:,1:Kt{t,kiter});
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

                    if NormalizeUxBoolSta
                        for i=1:N(t)
                            if NormalizeUxBoolSta == 1
                                NormalizerUxSta = norm(Ux(i,:),1);
                            elseif NormalizeUxBoolSta == 2
                                NormalizerUxSta = norm(Ux(i,:),2);
                            else
                                NormalizerUxSta = norm(Ux(i,:),'fro');
                            end
                            if NormalizerUxSta > 0
                                Ux(i,:)=Ux(i,:)/NormalizerUxSta;
                            end
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

                    if Ucomb == 1
                        UgUx = (1-alphaUAttr)*Ug + alphaUAttr*Ux;
                    elseif Ucomb == 2
                        UgUx = [(1-alphaUAttr)*Ug alphaUAttr*Ux];
                    elseif Ucomb == 0
                        UgUx = [Ug Ux];
                    end

                    if NormalizeUgUxSta
                        for i=1:N(t)
                            if NormalizeUgUxSta == 1
                                NormalizerUgUx = norm(UgUx(i,:),1);
                            elseif NormalizeUgUxSta == 2
                                NormalizerUgUx = norm(UgUx(i,:),2);
                            else
                                NormalizerUgUx = norm(UgUx(i,:),'fro');
                            end
                            if NormalizerUgUx > 0
                                UgUx(i,:)=UgUx(i,:)/NormalizerUgUx;
                            end
                        end
                    end 


                    UgUxKmeansSta{t,kiter} = UgUx;
                    rng(rep);
                    Y{t,kiter} = kmeans(UgUxKmeansSta{t,kiter},Kt{t,kiter},'Replicate',replicate);
                end
            end

            if t == 1
                CommstotalStat1{repidx,kiter} = Y{t,kiter};
            end
            CommstotalSta{t,kiter} = Y{t,kiter};
            numComms = unique(CommstotalSta{t,kiter});

            partitionStart = tic;
            partition = zeros(size(numComms,1),size(CommstotalSta{t,kiter},1));
            partitionToSave = zeros(size(numComms,1),size(CommstotalSta{t,kiter},1));
            posComm = ones(size(numComms,1),1);
            for i = 1:size(CommstotalSta{t,kiter},1)
                for j = 1:size(numComms,1)
                    if CommstotalSta{t,kiter}(i) == numComms(j)
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

            ModularitytotalSta(t,kiter) = modularity(CommstotalSta{t,kiter},NetMet{t,1});
            DensitytotalSta(t,kiter) = density(CommstotalSta{t,kiter},NetMet{t,1});         
            if size(Attr,1) > size(Attr,2) 
                if ismember(attrsType,["CategoricosHamming","Categoricos"])
                    entropyt = entropy(partition,Attr{t,1},nbins);
                    silt = evalclusters(Attr{t,1},CommstotalSta{t,kiter},'silhouette','Distance','Hamming');
                    EntropytotalSta(t,kiter) = entropyt;
                    SiltotalSta(t,kiter) = silt.CriterionValues;
                end
                if attrsType == "Reales"
                    dbt = evalclusters(Attr{t,1},CommstotalSta{t,kiter},'DaviesBouldin');
                    cht = evalclusters(Attr{t,1},CommstotalSta{t,kiter},'CalinskiHarabasz');
                    silt = evalclusters(Attr{t,1},CommstotalSta{t,kiter},'silhouette','Distance','Euclidean');
                    DBtotalSta(t,kiter) = dbt.CriterionValues;
                    CHtotalSta(t,kiter) = cht.CriterionValues;
                    SiltotalSta(t,kiter) = silt.CriterionValues;
                end
            else
                if ismember(attrsType,["CategoricosHamming","Categoricos"])
                    entropyt = entropy(partition,Attr{1,t},nbins);
                    silt = evalclusters(Attr{1,t},CommstotalSta{t,kiter},'silhouette','Distance','Hamming');
                    EntropytotalSta(t,kiter) = entropyt;
                    SiltotalSta(t,kiter) = silt.CriterionValues;
                end
                if attrsType == "Reales"
                    dbt = evalclusters(Attr{1,t},CommstotalSta{t,kiter},'DaviesBouldin');
                    cht = evalclusters(Attr{1,t},CommstotalSta{t,kiter},'CalinskiHarabasz');
                    silt = evalclusters(Attr{1,t},CommstotalSta{t,kiter},'silhouette','Distance','Euclidean');
                    DBtotalSta(t,kiter) = dbt.CriterionValues;
                    CHtotalSta(t,kiter) = cht.CriterionValues;
                    SiltotalSta(t,kiter) = silt.CriterionValues;
                end
            end

            NMIval = getNMI(CommstotalSta{t,kiter},GT{t});
            VIval = getVI(CommstotalSta{t,kiter},GT{t});
            [Jaccardval,Precisionval,Sensitivityval,Specificityval,RandIndexval,AdjustedRandIndexval] = getMeasures(CommstotalSta{t,kiter}',GT{t});
            NMItotalSta(t,kiter) = NMIval;
            VItotalSta(t,kiter) = VIval;
            JaccardtotalSta(t,kiter) = Jaccardval;
            PrecisiontotalSta(t,kiter) = Precisionval;
            SensitivitytotalSta(t,kiter) = Sensitivityval;
            SpecificitytotalSta(t,kiter) = Specificityval;
            RandIndextotalSta(t,kiter) = RandIndexval;
            AdjustedRandIndextotalSta(t,kiter) = AdjustedRandIndexval;

            if plotflag
                cd ImagesOutput
                Comms = zeros(maxsize,Kt{t,kiter});%K(t)
                for n=1:maxsize
                    for k=1:Kt{t,kiter}%K(t)
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
            if MaxMod
                if kiter == 1
                    MaxModularityTotalSta(t) = ModularitytotalSta(t,kiter);
                    MaxkiterSta(t) = kiter;
                end
                if kiter > 1
                    if ModularitytotalSta(t,kiter) > MaxModularityTotalSta(t)
                        MaxModularityTotalSta(t) = ModularitytotalSta(t,kiter);
                        MaxkiterSta(t) = kiter;
                    end
                end
            end
            if MaxDen
                if kiter == 1
                    MaxDensityTotalSta(t) = DensitytotalSta(t,kiter);
                    MaxkiterSta(t) = kiter;
                end
                if kiter > 1
                    if DensitytotalSta(t,kiter) > MaxDensityTotalSta(t)
                        MaxDensityTotalSta(t) = DensitytotalSta(t,kiter);
                        MaxkiterSta(t) = kiter;
                    end
                end
            end
            if MinEnt
                if kiter == 1
                    MinEntropyTotalSta(t) = EntropytotalSta(t,kiter);
                    MaxkiterSta(t) = kiter;
                end
                if kiter > 1
                    if EntropytotalSta(t,kiter) < MinEntropyTotalSta(t)
                        MinEntropyTotalSta(t) = EntropytotalSta(t,kiter);
                        MaxkiterSta(t) = kiter;
                    end
                end
            end
            if MaxSil
                if kiter == 1
                    MaxSilhouetteTotalSta(t) = SiltotalSta(t,kiter);
                    MaxkiterSta(t) = kiter;
                end
                if kiter > 1
                    if SiltotalSta(t,kiter) > MaxSilhouetteTotalSta(t)
                        MaxSilhouetteTotalSta(t) = SiltotalSta(t,kiter);
                        MaxkiterSta(t) = kiter;
                    end
                end
            end            
            if MaxCH
                if kiter == 1
                    MaxCalinskiHarabaszTotalSta(t) = CHtotalSta(t,kiter);
                    MaxkiterSta(t) = kiter;
                end
                if kiter > 1
                    if CHtotalSta(t,kiter) > MaxCalinskiHarabaszTotalSta(t)
                        MaxCalinskiHarabaszTotalSta(t) = CHtotalSta(t,kiter);
                        MaxkiterSta(t) = kiter;
                    end
                end
            end
            if MinDB
                if kiter == 1
                    MinDaviesBouldinTotalSta(t) = DBtotalSta(t,kiter);
                    MaxkiterSta(t) = kiter;
                end
                if kiter > 1
                    if DBtotalSta(t,kiter) < MinDaviesBouldinTotalSta(t)
                        MinDaviesBouldinTotalSta(t) = DBtotalSta(t,kiter);
                        MaxkiterSta(t) = kiter;
                    end
                end
            end            



            if kiter == KValNum || Kt{t,kiter} + kchange > numNodes% | diff entre actual y anterior
                kbool = 0;
            else
                kiter = kiter + 1;
                if kvar == 1
                    if kchange*KValNum > numNodes
                        kchange = 1;
                        Kt{t,kiter} = Kt{t,kiter-1}+kchange;
                    else
                        Kt{t,kiter} = Kt{t,kiter-1}+kchange;
                    end
                end  
            end

        end

        MaxDenVal = max(DensitytotalSta(t,:));
        MaxModVal = max(ModularitytotalSta(t,:));
        MaxSilVal = max(SiltotalSta(t,:));
        if ismember(attrsType,["CategoricosHamming","Categoricos"])
            MinEntVal = min(EntropytotalSta(t,:));
        end
        if attrsType == "Reales"
            MaxCHVal = max(CHtotalSta(t,:));
            MinDBVal = min(DBtotalSta(t,:));
        end
        for kiter=1:KValNum                     
            if ismember(attrsType,["CategoricosHamming","Categoricos"])
                DenEnttotalSta(t,kiter) = weightMod*((DensitytotalSta(t,kiter)-MaxDenVal)/MaxDenVal)+(1-weightMod)*(-(EntropytotalSta(t,kiter)-MinEntVal)/MinEntVal);
                ModEnttotalSta(t,kiter) = weightMod*((ModularitytotalSta(t,kiter)-MaxModVal)/MaxModVal)+(1-weightMod)*(-(EntropytotalSta(t,kiter)-MinEntVal)/MinEntVal);
            end
            if attrsType == "Reales"
                DenCHtotalSta(t,kiter) = weightMod*((DensitytotalSta(t,kiter)-MaxDenVal)/MaxDenVal)+(1-weightMod)*((CHtotalSta(t,kiter)-MaxCHVal)/MaxCHVal);
                ModCHtotalSta(t,kiter) = weightMod*((ModularitytotalSta(t,kiter)-MaxModVal)/MaxModVal)+(1-weightMod)*((CHtotalSta(t,kiter)-MaxCHVal)/MaxCHVal);
                DenDBtotalSta(t,kiter) = weightMod*((DensitytotalSta(t,kiter)-MaxDenVal)/MaxDenVal)+(1-weightMod)*(-(DBtotalSta(t,kiter)-MinDBVal)/MinDBVal);
                ModDBtotalSta(t,kiter) = weightMod*((ModularitytotalSta(t,kiter)-MaxModVal)/MaxModVal)+(1-weightMod)*(-(DBtotalSta(t,kiter)-MinDBVal)/MinDBVal);
            end
            DenSiltotalSta(t,kiter) = weightMod*((DensitytotalSta(t,kiter)-MaxDenVal)/MaxDenVal)+(1-weightMod)*((SiltotalSta(t,kiter)-MaxSilVal)/MaxSilVal);                
            ModSiltotalSta(t,kiter) = weightMod*((ModularitytotalSta(t,kiter)-MaxModVal)/MaxModVal)+(1-weightMod)*((SiltotalSta(t,kiter)-MaxSilVal)/MaxSilVal);                
            if MaxDenEnt
                if kiter == 1
                    MaxDensityEntropyTotalSta(t) = DenEnttotalSta(t,kiter);
                    MaxkiterSta(t) = kiter;
                end
                if kiter > 1
                    if DenEnttotalSta(t,kiter) > MaxDensityEntropyTotalSta(t)
                        MaxDensityEntropyTotalSta(t) = DenEnttotalSta(t,kiter);
                        MaxkiterSta(t) = kiter;
                    end
                end                                    
            elseif MaxModEnt
                if kiter == 1
                    MaxModularityEntropyTotalSta(t) = ModEnttotalSta(t,kiter);
                    MaxkiterSta(t) = kiter;
                end
                if kiter > 1
                    if ModEnttotalSta(t,kiter) > MaxModularityEntropyTotalSta(t)
                        MaxModularityEntropyTotalSta(t) = ModEnttotalSta(t,kiter);
                        MaxkiterSta(t) = kiter;
                    end
                end           
            elseif MaxDenSil                
                if kiter == 1
                    MaxDensitySilhouetteTotalSta(t) = DenSiltotalSta(t,kiter);
                    MaxkiterSta(t) = kiter;
                end
                if kiter > 1
                    if DenSiltotalSta(t,kiter) > MaxDensitySilhouetteTotalSta(t)
                        MaxDensitySilhouetteTotalSta(t) = DenSiltotalSta(t,kiter);
                        MaxkiterSta(t) = kiter;
                    end
                end            
            elseif MaxModSil              
                if kiter == 1
                    MaxModularitySilhouetteTotalSta(t) = ModSiltotalSta(t,kiter);
                    MaxkiterSta(t) = kiter;
                end
                if kiter > 1
                    if ModSiltotalSta(t,kiter) > MaxModularitySilhouetteTotalSta(t)
                        MaxModularitySilhouetteTotalSta(t) = ModSiltotalSta(t,kiter);
                        MaxkiterSta(t) = kiter;
                    end
                end                   
            elseif MaxDenCH
                if kiter == 1
                    MaxDensityCalinskiHarabaszTotalSta(t) = DenCHtotalSta(t,kiter);
                    MaxkiterSta(t) = kiter;
                end
                if kiter > 1
                    if DenCHtotalSta(t,kiter) > MaxDensityCalinskiHarabaszTotalSta(t)
                        MaxDensityCalinskiHarabaszTotalSta(t) = DenCHtotalSta(t,kiter);
                        MaxkiterSta(t) = kiter;
                    end
                end                 
            elseif MaxModCH
                if kiter == 1
                    MaxModularityCalinskiHarabaszTotalSta(t) = ModCHtotalSta(t,kiter);
                    MaxkiterSta(t) = kiter;
                end
                if kiter > 1
                    if ModCHtotalSta(t,kiter) > MaxModularityCalinskiHarabaszTotalSta(t)
                        MaxModularityCalinskiHarabaszTotalSta(t) = ModCHtotalSta(t,kiter);
                        MaxkiterSta(t) = kiter;
                    end
                end                   
            elseif MaxDenDB
                if kiter == 1
                    MaxDensityDaviesBouldinTotalSta(t) = DenDBtotalSta(t,kiter);
                    MaxkiterSta(t) = kiter;
                end
                if kiter > 1
                    if DenDBtotalSta(t,kiter) > MaxDensityDaviesBouldinTotalSta(t)
                        MaxDensityDaviesBouldinTotalSta(t) = DenDBtotalSta(t,kiter);
                        MaxkiterSta(t) = kiter;
                    end
                end                
            elseif MaxModDB
                if kiter == 1
                    MaxModularityDaviesBouldinTotalSta(t) = ModDBtotalSta(t,kiter);
                    MaxkiterSta(t) = kiter;
                end
                if kiter > 1
                    if ModDBtotalSta(t,kiter) > MaxModularityDaviesBouldinTotalSta(t)
                        MaxModularityDaviesBouldinTotalSta(t) = ModDBtotalSta(t,kiter);
                        MaxkiterSta(t) = kiter;
                    end
                end                 
            end
        end       
    end            



    if plotflagData == 1
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
    initTimeDyn = tic;

    %Inilization of structure for storing all tensors
    X=cell(T,1);
    Z=cell(T,1);
    timeLaplacians = toc(timeLaplaciansStart);

    if T > 1
        Wt=cell(T,size(Ls,2),KValNum);
        for LIter=1:size(Ls,2)
            %Weight of sparsity constraints
            L = Ls(LIter); %I didn't find the value in the papers
            RedtNew = cell(size(Net,1)-1,L);
            AttrtNew = cell(size(Net,1)-1,L);
            UNewIndex = cell(size(Net,1)-1,L);
            %% Creation of tensors

            timeTensorStart = tic;
            for t = 1
                for kiter = 1:KValNum
                    sizeTen = N(t);
                    tensorArray = zeros(sizeTen,sizeTen,t);
                    tensorArray1 = zeros(sizeTen,sizeTen,t);
                    l = 1;
                    while (l<=t)
                        tensorArray(:,:,l) = Lg{l};
                        tensorArray1(:,:,l) = Lx{l,kiter};
                        l = l + 1;
                    end
                    %The tensor package muste be preloaded
                    X{t} = tensor(tensorArray,[N(t),N(t),t]);
                    Z{t} = tensor(tensorArray1,[N(t),N(t),t]);


                    if reig
                        [~,Diag,Un] = eig(Lg{1}); 
                    else
                        [Un,Diag,Vn] = eig(Lg{1});
                    end
                    if absG
                        [dx,ind] = sort(abs(diag(Diag)),'descend');
                    else    
                        [~,ind] = sort(diag(Diag),'descend');
                    end
                    Un = Un(:,ind);
                    
                    if sum(sum(abs(imag(Un)))) ~= 0
                        if printWarning
                            disp(["Seed",seed])
                            disp(["Rep",rep])
                            disp(["Iter",iter])
                            disp("complex Ux")
                        end
                        Un=real(Un);
                    end
                    
                    if NormalizerAbs
                        NormalizerUn = sum(abs(Un),2);
                        if NormalizerUn > 0
                            Un=Un./NormalizerUn;
                        end
                    end
                    if NormalizerNoAbs
                        NormalizerUn = sum(Un,2);
                        if NormalizerUn ~= 0
                            Un=Un./NormalizerUn;
                        end
                    end 

                    if NormalizeUgBool
                        for i=1:N(t)
                            if NormalizeUgBool == 1
                                NormalizerUg = norm(Un(i,:),1);
                            elseif NormalizeUgBool == 2
                                NormalizerUg = norm(Un(i,:),2);
                            else
                                NormalizerUg = norm(Un(i,:),'fro');
                            end
                            if NormalizerUg > 0
                                Un(i,:)=Un(i,:)/NormalizerUg;
                            end
                        end
                    end                   
                                      
                    Ugt1OverKt{kiter} = Un;
                    if reig
                        [~,Diag,Un] = eig(Lx{1,kiter}); 
                    else
                        [Un,Diag,Vn] = eig(Lx{1,kiter});
                    end
                    
                    if absX
                        [dx,ind] = sort(abs(diag(Diag)),'descend');
                    else    
                        [~,ind] = sort(diag(Diag),'descend');
                    end
                    Un = Un(:,ind);
                    
                    if sum(sum(abs(imag(Un)))) ~= 0
                        if printWarning
                            disp(["Seed",seed])
                            disp(["Rep",rep])
                            disp(["Iter",iter])
                            disp("complex Ux")
                        end
                        Un=real(Un);
                    end 
                    
                    if NormalizerAbs
                        NormalizerUn = sum(abs(Un),2);
                        if NormalizerUn > 0
                            Un=Un./NormalizerUn;
                        end
                    end
                    if NormalizerNoAbs
                        NormalizerUn = sum(Un,2);
                        if NormalizerUn ~= 0
                            Un=Un./NormalizerUn;
                        end
                    end
                    if NormalizeUxBool
                        for i=1:N(t)
                            if NormalizeUxBool == 1
                                NormalizerUx = norm(Un(i,:),1);
                            elseif NormalizeUxBool == 2
                                NormalizerUx = norm(Un(i,:),2);
                            else
                                NormalizerUx = norm(Un(i,:),'fro');
                            end
                            if NormalizerUx > 0
                                Un(i,:)=Un(i,:)/NormalizerUx;
                            end
                        end
                    end
                    Uxt1OverKt{kiter} = Un;

                    UgC = Ugt1OverKt{kiter}(:,1:Kt{t,kiter});
                    UxC = Uxt1OverKt{kiter}(:,1:Kt{t,kiter});
  

                    if Ucomb == 1
                        UgUx = (1-alphaUAttr)*UgC + alphaUAttr*UxC;
                    elseif Ucomb == 2
                        UgUx = [(1-alphaUAttr)*UgC alphaUAttr*UxC];
                    elseif Ucomb == 0
                        UgUx = [UgC UxC];
                    end

                    if NormalizeUgUx
                        for i=1:N(t)
                            if NormalizeUgUx == 1
                                NormalizerUgUx = norm(UgUx(i,:),1);
                            elseif NormalizeUgUx == 2
                                NormalizerUgUx = norm(UgUx(i,:),2);
                            else
                                NormalizerUgUx = norm(UgUx(i,:),'fro');
                            end
                            if NormalizerUgUx > 0
                                UgUx(i,:)=UgUx(i,:)/NormalizerUgUx;
                            end
                        end
                    end
                    
                    
                    UgUxKmeansDyn{t,kiter} = UgUx;
                    rng(rep);
                    Commstotal{t,kiter}=kmeans(UgUxKmeansDyn{t,kiter},Kt{t,kiter},'Replicate',replicate);%CommsTN{1,rep};           
                    numComms = unique(Commstotal{t,kiter});
                    partition = zeros(size(numComms,1),size(Commstotal{t,kiter},1));
                    partitionToSave = zeros(size(numComms,1),size(Commstotal{t,kiter},1));
                    posComm = ones(size(numComms,1),1);

                    for i = 1:size(Commstotal{t,kiter},1)
                        for j = 1:size(numComms,1)
                            if Commstotal{t,kiter}(i) == numComms(j)
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
                    Modularitytotal(t,kiter) = modularity(Commstotal{t,kiter},NetMet{t,1});
                    Densitytotal(t,kiter) = density(Commstotal{t,kiter},NetMet{t,1});         
                    if size(Attr,1) > size(Attr,2) 
                        if ismember(attrsType,["CategoricosHamming","Categoricos"])
                            entropyt = entropy(partition,Attr{t,1},nbins);
                            silt = evalclusters(Attr{t,1},Commstotal{t,kiter},'silhouette','Distance','Hamming');
                            Entropytotal(t,kiter) = entropyt;
                            Siltotal(t,kiter) = silt.CriterionValues;
                        end
                        if attrsType == "Reales"
                            dbt = evalclusters(Attr{t,1},Commstotal{t,kiter},'DaviesBouldin');
                            cht = evalclusters(Attr{t,1},Commstotal{t,kiter},'CalinskiHarabasz');
                            silt = evalclusters(Attr{t,1},Commstotal{t,kiter},'silhouette','Distance','Euclidean');
                            DBtotal(t,kiter) = dbt.CriterionValues;
                            CHtotal(t,kiter) = cht.CriterionValues;
                            Siltotal(t,kiter) = silt.CriterionValues;
                        end
                    else
                        if ismember(attrsType,["CategoricosHamming","Categoricos"])
                            entropyt = entropy(partition,Attr{1,t},nbins);
                            silt = evalclusters(Attr{1,t},Commstotal{t,kiter},'silhouette','Distance','Hamming');
                            Entropytotal(t,kiter) = entropyt;
                            Siltotal(t,kiter) = silt.CriterionValues;
                        end
                        if attrsType == "Reales"
                            dbt = evalclusters(Attr{1,t},Commstotal{t,kiter},'DaviesBouldin');
                            cht = evalclusters(Attr{1,t},Commstotal{t,kiter},'CalinskiHarabasz');
                            silt = evalclusters(Attr{1,t},Commstotal{t,kiter},'silhouette','Distance','Euclidean');
                            DBtotal(t,kiter) = dbt.CriterionValues;
                            CHtotal(t,kiter) = cht.CriterionValues;
                            Siltotal(t,kiter) = silt.CriterionValues;
                        end
                    end  
                    weightMod = 0.5;
                    normalizerAggr = 4;
                    
                    NMIval = getNMI(Commstotal{t,kiter},GT{t});
                    VIval = getVI(Commstotal{t,kiter},GT{t});
                    [Jaccardval,Precisionval,Sensitivityval,Specificityval,RandIndexval,AdjustedRandIndexval] = getMeasures(Commstotal{t,kiter}',GT{t});
                    NMItotal(t,kiter) = NMIval;
                    VItotal(t,kiter) = VIval;
                    Jaccardtotal(t,kiter) = Jaccardval;
                    Precisiontotal(t,kiter) = Precisionval;
                    Sensitivitytotal(t,kiter) = Sensitivityval;
                    Specificitytotal(t,kiter) = Specificityval;
                    RandIndextotal(t,kiter) = RandIndexval;
                    AdjustedRandIndextotal(t,kiter) = AdjustedRandIndexval;
               

                    if MaxMod
                        if kiter == 1
                            MaxModularityTotal(t) = Modularitytotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if Modularitytotal(t,kiter) > MaxModularityTotal(t)
                                MaxModularityTotal(t) = Modularitytotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end
                    end
                    if MaxDen
                        if kiter == 1
                            MaxDensityTotal(t) = Densitytotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if Densitytotal(t,kiter) > MaxDensityTotal(t)
                                MaxDensityTotal(t) = Densitytotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end
                    end
                    if MinEnt
                        if kiter == 1
                            MinEntropyTotal(t) = Entropytotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if Entropytotal(t,kiter) < MinEntropyTotal(t)
                                MinEntropyTotal(t) = Entropytotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end
                    end
                    if MaxSil
                        if kiter == 1
                            MaxSilhouetteTotal(t) = Siltotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if Siltotal(t,kiter) > MaxSilhouetteTotal(t)
                                MaxSilhouetteTotal(t) = Siltotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end
                    end            
                    if MaxCH
                        if kiter == 1
                            MaxCalinskiHarabaszTotal(t) = CHtotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if CHtotal(t,kiter) > MaxCalinskiHarabaszTotal(t)
                                MaxCalinskiHarabaszTotal(t) = CHtotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end
                    end
                    if MinDB
                        if kiter == 1
                            MinDaviesBouldinTotal(t) = DBtotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if DBtotal(t,kiter) < MinDaviesBouldinTotal(t)
                                MinDaviesBouldinTotal(t) = DBtotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end
                    end 
                    if KValNum > 1 && kiter < size(Kt,2) 
                        if isempty(Kt{t,kiter+1})
                            break;
                        end
                    end
                end
                MaxDenVal = max(Densitytotal(t,:));
                MaxModVal = max(Modularitytotal(t,:));
                MaxSilVal = max(Siltotal(t,:));
                if ismember(attrsType,["CategoricosHamming","Categoricos"])
                    MinEntVal = min(Entropytotal(t,:));
                end
                if attrsType == "Reales"
                    MaxCHVal = max(CHtotal(t,:));
                    MinDBVal = min(DBtotalSta(t,:));
                end
                for kiter=1:KValNum                     
                    if ismember(attrsType,["CategoricosHamming","Categoricos"])
                        DenEnttotal(t,kiter) = weightMod*((Densitytotal(t,kiter)-MaxDenVal)/MaxDenVal)+(1-weightMod)*(-(Entropytotal(t,kiter)-MinEntVal)/MinEntVal);
                        ModEnttotal(t,kiter) = weightMod*((Modularitytotal(t,kiter)-MaxModVal)/MaxModVal)+(1-weightMod)*(-(Entropytotal(t,kiter)-MinEntVal)/MinEntVal);
                    end
                    if attrsType == "Reales"
                        DenCHtotal(t,kiter) = weightMod*((Densitytotal(t,kiter)-MaxDenVal)/MaxDenVal)+(1-weightMod)*((CHtotal(t,kiter)-MaxCHVal)/MaxCHVal);
                        ModCHtotal(t,kiter) = weightMod*((Modularitytotal(t,kiter)-MaxModVal)/MaxModVal)+(1-weightMod)*((CHtotal(t,kiter)-MaxCHVal)/MaxCHVal);
                        DenDBtotal(t,kiter) = weightMod*((Densitytotal(t,kiter)-MaxDenVal)/MaxDenVal)+(1-weightMod)*(-(DBtotal(t,kiter)-MinDBVal)/MinDBVal);
                        ModDBtotal(t,kiter) = weightMod*((Modularitytotal(t,kiter)-MaxModVal)/MaxModVal)+(1-weightMod)*(-(DBtotal(t,kiter)-MinDBVal)/MinDBVal);
                    end
                    DenSiltotal(t,kiter) = weightMod*((Densitytotal(t,kiter)-MaxDenVal)/MaxDenVal)+(1-weightMod)*((Siltotal(t,kiter)-MaxSilVal)/MaxSilVal);                
                    ModSiltotal(t,kiter) = weightMod*((Modularitytotal(t,kiter)-MaxModVal)/MaxModVal)+(1-weightMod)*((Siltotal(t,kiter)-MaxSilVal)/MaxSilVal);                        
                    if MaxDenEnt
                        if kiter == 1
                            MaxDensityEntropyTotal(t) = DenEnttotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if DenEnttotal(t,kiter) > MaxDensityEntropyTotal(t)
                                MaxDensityEntropyTotal(t) = DenEnttotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end                                    
                    elseif MaxModEnt
                        if kiter == 1
                            MaxModularityEntropyTotal(t) = ModEnttotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if ModEnttotal(t,kiter) > MaxModularityEntropyTotal(t)
                                MaxModularityEntropyTotal(t) = ModEnttotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end           
                    elseif MaxDenSil                
                        if kiter == 1
                            MaxDensitySilhouetteTotal(t) = DenSiltotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if DenSiltotal(t,kiter) > MaxDensitySilhouetteTotal(t)
                                MaxDensitySilhouetteTotal(t) = DenSiltotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end            
                    elseif MaxModSil              
                        if kiter == 1
                            MaxModularitySilhouetteTotal(t) = ModSiltotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if ModSiltotal(t,kiter) > MaxModularitySilhouetteTotal(t)
                                MaxModularitySilhouetteTotal(t) = ModSiltotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end                   
                    elseif MaxDenCH
                        if kiter == 1
                            MaxDensityCalinskiHarabaszTotal(t) = DenCHtotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if DenCHtotal(t,kiter) > MaxDensityCalinskiHarabaszTotal(t)
                                MaxDensityCalinskiHarabaszTotal(t) = DenCHtotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end                 
                    elseif MaxModCH
                        if kiter == 1
                            MaxModularityCalinskiHarabaszTotal(t) = ModCHtotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if ModCHtotal(t,kiter) > MaxModularityCalinskiHarabaszTotal(t)
                                MaxModularityCalinskiHarabaszTotal(t) = ModCHtotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end                   
                    elseif MaxDenDB
                        if kiter == 1
                            MaxDensityDaviesBouldinTotal(t) = DenDBtotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if DenDBtotal(t,kiter) > MaxDensityDaviesBouldinTotal(t)
                                MaxDensityDaviesBouldinTotal(t) = DenDBtotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end                
                    elseif MaxModDB
                        if kiter == 1
                            MaxModularityDaviesBouldinTotal(t) = ModDBtotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if ModDBtotal(t,kiter) > MaxModularityDaviesBouldinTotal(t)
                                MaxModularityDaviesBouldinTotal(t) = ModDBtotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end                 
                    end
                end  
                
            end
            
            
            MaxNumNode = size(Net{1,1},1);
            
            NodosEliminados = cell(T-1,1);
            NodosNuevos = cell(T-1,1);
            NodosAgregAntiguos = cell(T-1,1);

            for t = 2:T
                sizeTen = N(t);
                if ~boolColSize
                    ColSize = ceil(sqrt(1600000000/(N(t)^2))/2);
                end
                if ColSize > N(t)
                    ColSize = N(t);
                end
                
                for kiter = 1:size(Kt,2)
                    
                    tensorArray = zeros(sizeTen,sizeTen,L);
                    tensorArray1 = zeros(sizeTen,sizeTen,L);
                    larray = L;
                    if L > 1
                        for ll = 1                         
                            if kiter == 1
                                RedtNew{t-1,1} = Lg{t-larray+1};
                            end
                            AttrtNew{t-1,1} = Lx{t-larray+1,Maxkiter(t-1)};
                            if kiter == 1
                                RemainingNodes = ismember(Vindex{t-1,1},Vindex{t,1});
                                NodosEliminados{t-1} = find(RemainingNodes == 0);
                            end

                            %for nodes that are eliminated at t, all
                            %positions at t-1 must be deleted
                            if ~isempty(NodosEliminados{t-1})
                                if kiter == 1
                                    NodosEliminados{t-1} = sort(NodosEliminados{t-1},'descend'); 
                                end
                                for i=1:size(NodosEliminados{t-1},1)
                                    if kiter == 1
                                        RedtNew{t-1,1}(NodosEliminados{t-1}(i),:) = [];
                                        RedtNew{t-1,1}(:,NodosEliminados{t-1}(i)) = [];
                                    end
                                    AttrtNew{t-1,1}(NodosEliminados{t-1}(i),:) = [];
                                    AttrtNew{t-1,1}(:,NodosEliminados{t-1}(i)) = [];
                                end
                            end
                            if kiter == 1
                                nodesbool = ~ismember(Vindex{t,1},Vindex{t-1,1});
                                nodes = Vindex{t,1}(nodesbool);
                                NodosNuevos{t-1} = nodes(nodes>MaxNumNode);
                                NodosAgregAntiguos{t-1} = nodes(nodes<=MaxNumNode);
                            end

                            %For new nodes
                            if ~isempty(NodosNuevos{t-1})
                                %fillzeros is a function that add zeros
                                %both on rows and columns
                                if kiter == 1
                                    MaxNumNode = max(NodosNuevos{t-1});
                                    RedtNew{t-1,1} = fillzeros(RedtNew{t-1,1},size(RedtNew{t-1,1},1)+size(NodosNuevos{t-1},1));
                                end
                                AttrtNew{t-1,1} = fillzeros(AttrtNew{t-1,1},size(AttrtNew{t-1,1},1)+size(NodosNuevos{t-1},1));
                             end
                            
                            %For nodes that reappeared
                            if kiter == 1
                                if size(NodosAgregAntiguos{t-1},1)>=1 && size(NodosAgregAntiguos{t-1},2)>0
                                    posAnt = zeros(size(NodosAgregAntiguos{t-1},1),1);
                                    for k = 1:size(NodosAgregAntiguos{t-1},1)
                                        posAnt(k) = find(Vindex{t,1} == NodosAgregAntiguos{t-1}(k));
                                    end
                                end
                            end
                            if ~isempty(NodosAgregAntiguos{t-1})
                                if kiter == 1
                                    A = RedtNew{t-1,1};
                                end
                                AAttr = AttrtNew{t-1,1};
                                for i=1:size(NodosAgregAntiguos{t-1},1)
                                    if kiter == 1
                                        A = insertNodes(A, posAnt(i));
                                    end
                                    AAttr = insertNodes(AAttr, posAnt(i));
                                end
                                if kiter == 1
                                    RedtNew{t-1,1} = A;
                                end
                                AttrtNew{t-1,1} = AAttr;
                            end

                            if isempty(NodosNuevos{t-1}) && isempty(NodosAgregAntiguos{t-1}) && isempty(NodosEliminados{t-1})
                                if kiter == 1
                                    RedtNew{t-1,1} = Lg{t-1};
                                end
                                AttrtNew{t-1,1} = Lx{t-1,Maxkiter(t-1)};
                            end
                            if kiter == 1
                                tensorArray(:,:,ll) = RedtNew{t-1,1};
                            end
                            tensorArray1(:,:,ll) = AttrtNew{t-1,1};
                            larray = larray-1;
                        end
                        ll = 2;
                        if kiter == 1
                            tensorArray(:,:,ll) = Lg{t,1};
                            X{t} = tensor(tensorArray,[N(t),N(t),L]);
                        end
                        tensorArray1(:,:,ll) = Lx{t,kiter};
                        Z{t} = tensor(tensorArray1,[N(t),N(t),L]);
                    else
                        disp("L must be greater than 1")
                        tensorArray(:,:,1) = Lg{t,1};
                        X{t} = tensor(tensorArray,[N(t),N(t),L]);
                        tensorArray1(:,:,1) = Lx{t,kiter};
                        Z{t} = tensor(tensorArray1,[N(t),N(t),L]);
                    end


                    timeTensor{LIter} = toc(timeTensorStart);

                    TimeAlSharoaStart = tic;    

                    %% Clustering for each time interval, startg with time interval 2





                    if t < L
                        svdSize = t;
                        W=zeros(t,1);
                    else
                        svdSize = L;
                        W=zeros(L,1);
                    end


                    initTimeTestStart = tic;
                    
                    if coldstart
                        if t == 2
                            U = Ugt1OverKt{Maxkiter(t-1)};
                        else
                            U = MaxUgOverKt;
                        end

                        if L > 1
                            if ~isempty(NodosEliminados{t-1})
                                %returns the position not the number of the node
                                NodosEliminados{t-1} = sort(NodosEliminados{t-1},'descend'); 
                                for i=1:size(NodosEliminados{t-1},1)
                                    U(NodosEliminados{t-1}(i),:) = [];
                                    
                                end
                                
                            end
                            if size(NodosAgregAntiguos{t-1},1)>=1 && size(NodosAgregAntiguos{t-1},2)>0
                                posAnt = zeros(size(NodosAgregAntiguos{t-1},1),1);
                                for k = 1:size(NodosAgregAntiguos{t-1},1)
                                    posAnt(k) = find(Vindex{t,1} == NodosAgregAntiguos{t-1}(k));
                                end
                            end 

                            if ~isempty(NodosNuevos{t-1})
                                MaxNumNode = max(NodosNuevos{t-1});
                                U = fillzerosAttr(U,size(U,1)+size(NodosNuevos{t-1},1));
                                
                            end

                            if ~isempty(NodosAgregAntiguos{t-1})
                                A = U;
                                for i=1:size(NodosAgregAntiguos{t-1},1) 
                                    A = insertNodesAttr(A, posAnt(i));
                                end
                                U = A;
                              
                            end

                            if isempty(NodosNuevos{t-1}) && isempty(NodosAgregAntiguos{t-1}) && isempty(NodosEliminados{t-1})
                                U = U;
                                
                            end
                        end



                    else
                        if t < L
                            InitU = hosvd(X{t},epsilon,'verbosity',0);
                            U = InitU{2};
                        else
                            InitU = hosvd(X{t},epsilon,'verbosity',0);
                            U = InitU{2};
                        end
                    end
                    %Initialization of iteration counter
                    iterNum = 0;
                    if ~WfixedW
                        if L > 1
                            if mttkrpUse == 1
                                Xsp=sptensor(X{t});
                                temp = mttkrp(Xsp,{U,U,W},3);
                                W=svd(temp);
                            else
                                X_3 = tenmat(X{t},3);
                                Z_3 = tenmat(Z{t},3);
                                if printTimeKro
                                    tic
                                end
                                if svdSizeKR
                                    if khatri 
                                        if size(U,2) < ColSize
                                            temp=X_3 *khatrirao(U,U);
                                        else
                                            temp=X_3 *khatrirao(U(:,1:ColSize),U(:,1:ColSize));
                                        end
                                    else
                                        if size(U,2) < ColSize
                                            temp=X_3 *kron(U,U);
                                        else
                                            temp=X_3 *kron(U(:,1:ColSize),U(:,1:ColSize));
                                        end
                                        
                                    end

                                else                          
                                    if khatri
                                        temp=X_3 * khatrirao(U,U);
                                    else
                                        temp=X_3 * kron(U,U);
                                    end
                                end
                                if printTimeKro
                                    toc
                                end

                                W=svd(temp.data);
                            end

                            if displayW
                                disp(W)
                            end
                            if NormalizeWnorm2
                                W=W/norm(W,2);  
                            end
                            if NormalizeWsum1
                                W=W/sum(W);  
                            end
                            
                        end
                    else
                        W=WfixedVal;
                    end
                    
                    A_avg = 0;

                    if L == 1
                        A_avg = Lg{t};
                    else
                        if t < L
                            for tt=1:t
                                A_avg = A_avg + W(tt)*Lg{t-(tt-1)};
                            end
                            for tt=2:t
                                A_avg = A_avg + W(tt)*RedtNew{t-(tt-1)};
                            end
                        else
                            for LL=1
                                A_avg = A_avg + W(LL)*Lg{t-(LL-1)};
                            end
                            for LL=2:L
                                A_avg = A_avg + W(LL)*RedtNew{t-(LL-1)};
                            end
                        end
                    end
                    if reig
                        [~,Diag,Un] = eig(A_avg);
                    else
                        [Un,Diag,Vn] = eig(A_avg); 
                    end

                    
                    if absG
                        [dx,ind] = sort(abs(diag(Diag)),'descend');
                    else    
                        [~,ind] = sort(diag(Diag),'descend');
                    end
                    Un = Un(:,ind);
                    
                    if sum(sum(abs(imag(Un)))) ~= 0
                        if printWarning
                            disp(["Seed",seed])
                            disp(["Rep",rep])
                            disp(["Iter",iter])
                            disp("complex Ug")
                        end
                        Un=real(Un);
                    end
                    
                    if NormalizerAbs
                        NormalizerUn = sum(abs(Un),2);
                        if NormalizerUn > 0
                            Un=Un./NormalizerUn;
                        end
                    end

                    if NormalizerNoAbs
                        NormalizerUn = sum(Un,2);
                        if NormalizerUn ~= 0
                            Un=Un./NormalizerUn;
                        end
                    end
                    if NormalizeUgBool
                        for i=1:N(t)
                            if NormalizeUgBool == 1
                                NormalizerUg = norm(Un(i,:),1);
                            elseif NormalizeUgBool == 2
                                NormalizerUg = norm(Un(i,:),2);
                            else
                                NormalizerUg = norm(Un(i,:),'fro');
                            end
                            if NormalizerUg > 0
                                Un(i,:)=Un(i,:)/NormalizerUg;
                            end
                        end
                    end
                    initTimeTestStart = tic;
                    flagloop = 1;
                    %Iterate until convergence
                    while(flagloop)
                        U=Un;
                        if ~WfixedW
                            if L > 1
                    
                                if mttkrpUse == 1
                                    temp = mttkrp(Xsp,{U,U,W},3);
                                    W=svd(temp);
                                else
                                    if printTimeKro
                                        tic
                                    end                                
                                    if svdSizeKR
                                        if khatri 
                                            temp=X_3 *khatrirao(U(:,1:ColSize),U(:,1:ColSize));
                                        else
                                            temp=X_3 *kron(U(:,1:ColSize),U(:,1:ColSize));
                                        end
                                    else                          
                                        if khatri
                                            temp=X_3 * khatrirao(U,U);
                                        else
                                            temp=X_3 * kron(U,U);
                                        end
                                    end
                                    if printTimeKro
                                        toc
                                    end
                                    W=svd(temp.data);
                                end

                                if displayW
                                    disp(W);
                                end
                                if NormalizeWnorm2
                                    W=W/norm(W,2);  
                                end
                                if NormalizeWsum1
                                    W=W/sum(W);  
                                end
                                
                            end
                        else 
                            W=WfixedVal;
                        end
                        A_avg = 0;
                        if L == 1
                            A_avg = Lg{t};
                        else
                            if t < L
                                for tt=1
                                    A_avg = A_avg + W(tt)*Lg{t-(tt-1)};
                                end
                                for tt=2:t
                                    A_avg = A_avg + W(tt)*RedtNew{t-(tt-1)};
                                end
                            else
                                for LL=1
                                    A_avg = A_avg + W(LL)*Lg{t-(LL-1)};
                                end
                                for LL=2:L
                                    A_avg = A_avg + W(LL)*RedtNew{t-(LL-1)};
                                end
                            end
                        end

                        if reig
                            [~,Diag,Un] = eig(A_avg);
                        else
                            [Un,Diag,Vn] = eig(A_avg);
                        end
                        if absG
                            [dx,ind] = sort(abs(diag(Diag)),'descend');
                        else    
                            [~,ind] = sort(diag(Diag),'descend');
                        end
                        Un = Un(:,ind);
                        
                        if sum(sum(abs(imag(Un)))) ~= 0
                            if printWarning
                                disp(["Seed",seed])
                                disp(["Rep",rep])
                                disp(["Iter",iter])
                                disp("complex Ug")
                            end
                            Un=real(Un);
                        end

                        if NormalizerAbs
                            NormalizerUn = sum(abs(Un),2);
                            if NormalizerUn > 0
                                Un=Un./NormalizerUn;
                            end
                        end

                        if NormalizerNoAbs
                            NormalizerUn = sum(Un,2);
                            if NormalizerUn ~= 0
                                Un=Un./NormalizerUn;
                            end
                        end
                        if NormalizeUgBool
                            for i=1:N(t)
                                if NormalizeUgBool == 1
                                    NormalizerUg = norm(Un(i,:),1);
                                elseif NormalizeUgBool == 2
                                    NormalizerUg = norm(Un(i,:),2);
                                else
                                    NormalizerUg = norm(Un(i,:),'fro');
                                end
                                if NormalizerUg > 0
                                    Un(i,:)=Un(i,:)/NormalizerUg;
                                end
                            end
                        end
                        %If it reaches the maximum number of iterations it will exit the
                        %loop
                        
                        if earlystop
                            if norm(Un-U,'fro')^2<epsilon
                                flagloop = 0;
                            end
                        end

                        iterNum = iterNum + 1;
                        if iterNum == MaxIterW
                            flagloop = 0;
                        end
                    end

                    UgOverKt{kiter} = Un;
                    WrepG{t,repidx}=W;
                    initTimeTestStart = tic;
                    if coldstart
                        if t == 2
                            U = Uxt1OverKt{Maxkiter(t-1)};
                        else
                            U = MaxUxOverKt;%UxOverKt{Maxkiter(t-1)};%Initialization with previous value
                        end
                        if ~isempty(NodosEliminados{t-1})
                            %returns the position not the number of the node
                            NodosEliminados{t-1} = sort(NodosEliminados{t-1},'descend'); 
                            for i=1:size(NodosEliminados{t-1},1)
                                U(NodosEliminados{t-1}(i),:) = [];
                                
                            end
                            
                        end
                        if size(NodosAgregAntiguos{t-1},1)>=1 && size(NodosAgregAntiguos{t-1},2)>0
                            posAnt = zeros(size(NodosAgregAntiguos{t-1},1),1);
                            for k = 1:size(NodosAgregAntiguos{t-1},1)
                                posAnt(k) = find(Vindex{t,1} == NodosAgregAntiguos{t-1}(k));
                            end
                        end 

                        if ~isempty(NodosNuevos{t-1})
                            MaxNumNode = max(NodosNuevos{t-1});
                            U = fillzerosAttr(U,size(U,1)+size(NodosNuevos{t-1},1));
                            
                        end

                        if ~isempty(NodosAgregAntiguos{t-1})
                            A = U;
                            for i=1:size(NodosAgregAntiguos{t-1},1) 
                                A = insertNodesAttr(A, posAnt(i));
                            end
                            U = A;
                            
                        end

                        if isempty(NodosNuevos{t-1}) && isempty(NodosAgregAntiguos{t-1}) && isempty(NodosEliminados{t-1})
                            U = U;
                            
                        end                    
                    else
                        if t < L
                            InitU = hosvd(Z{t},epsilon,'verbosity',0);
                            U = InitU{1};
                        else
                            InitU = hosvd(Z{t},epsilon,'verbosity',0);
                            U = InitU{1};
                        end
                    end
                    %Initialization of iteration counter
                    iterNum = 0;

                    
                    if ~WfixedX
                        if L > 1
                            if mttkrpUse == 1
                                Zsp=sptensor(Z{t});
                                temp = mttkrp(Zsp,{U,U,W},3);
                                W=svd(temp);
                            else
                                if printTimeKro
                                    tic
                                end
                                if svdSizeKR
                                    if khatri 
                                        temp=Z_3 *khatrirao(U(:,1:ColSize),U(:,1:ColSize));
                                    else
                                        temp=Z_3 *kron(U(:,1:ColSize),U(:,1:ColSize));
                                    end
                                else                          
                                    if khatri
                                        temp=Z_3 * khatrirao(U,U);
                                    else
                                        temp=Z_3 * kron(U,U);
                                    end
                                end
                                if printTimeKro
                                    toc
                                end

                                W=svd(temp.data);
                            end
                            if displayW
                                disp(W);
                            end
                            if NormalizeWnorm2
                                W=W/norm(W,2);  
                            end
                            if NormalizeWsum1
                                W=W/sum(W);  
                            end
                        end
                    else 
                        W=WfixedVal;
                    end

                    A_avg = 0;
                    if L == 1
                        A_avg = Lx{t,kiter};
                    else
                        if t < L
                            for tt=1
                                A_avg = A_avg + W(tt)*Lx{t-(tt-1)};
                            end
                            for tt=2:t
                                A_avg = A_avg + W(tt)*AttrtNew{t-(tt-1)};
                            end
                        else
                            for LL=1
                                A_avg = A_avg + W(LL)*Lx{t-(LL-1)};
                            end
                            for LL=2:L
                                A_avg = A_avg + W(LL)*AttrtNew{t-(LL-1)};
                            end
                        end

                    end

                    if reig
                        [~,Diag,Un] = eig(A_avg); 
                    else
                        [Un,Diag,Vn] = eig(A_avg);
                    end
                  
                    if absX
                        [dx,ind] = sort(abs(diag(Diag)),'descend');
                    else    
                        [~,ind] = sort(diag(Diag),'descend');
                    end

                    Un = Un(:,ind);


                    if sum(sum(abs(imag(Un)))) ~= 0
                        if printWarning
                            disp(["Seed",seed])
                            disp(["Rep",rep])
                            disp(["Iter",iter])
                            disp("complex Ux")
                        end
                        Un=real(Un);
                    end 
                    
                    if NormalizerAbs
                        NormalizerUn = sum(abs(Un),2);
                        if NormalizerUn > 0
                            Un=Un./NormalizerUn;
                        end
                    end

                    if NormalizerNoAbs
                        NormalizerUn = sum(Un,2);
                        if NormalizerUn ~= 0
                            Un=Un./NormalizerUn;
                        end
                    end
                    if NormalizeUxBool
                        for i=1:N(t)
                            if NormalizeUxBool == 1
                                NormalizerUx = norm(Un(i,:),1);
                            elseif NormalizeUxBool == 2
                                NormalizerUx = norm(Un(i,:),2);
                            else
                                NormalizerUx = norm(Un(i,:),'fro');
                            end
                            if NormalizerUx > 0
                                Un(i,:)=Un(i,:)/NormalizerUx;
                            end
                        end
                    end
                    flagloop = 1;
                    %Iterate until convergence
                    initTimeTestStart = tic;
                    while(flagloop)
                        U=Un;

                        if ~WfixedX
                            if L > 1

                                if mttkrpUse == 1
                                    temp = mttkrp(Zsp,{U,U,W},3);

                                    W=svd(temp);
 
                                else
                                    if printTimeKro
                                        tic
                                    end
                                    if svdSizeKR
                                        if khatri 
                                            temp=Z_3 *khatrirao(U(:,1:ColSize),U(:,1:ColSize));
                                        else
                                            temp=Z_3 *kron(U(:,1:ColSize),U(:,1:ColSize));
                                        end

                                    else                          
                                        if khatri
                                            temp=Z_3 * khatrirao(U,U);
                                        else
                                            temp=Z_3 * kron(U,U);
                                        end
                                    end
                                    if printTimeKro
                                        toc
                                    end
                                    W=svd(temp.data);
                                end


                                if displayW
                                    disp(W);
                                end
                                if NormalizeWnorm2
                                    W=W/norm(W,2);
                                end
                                if NormalizeWsum1
                                    W=W/sum(W);  
                                end
                            end
                        else
                            W=WfixedVal;
                        end

                        A_avg = 0;
                        if L == 1
                            A_avg = Lx{t,kiter};
                        else
                            if t < L
                                for tt=1
                                    A_avg = A_avg + W(tt)*Lx{t-(tt-1)};
                                end
                                for tt=2:t
                                    A_avg = A_avg + W(tt)*AttrtNew{t-(tt-1)};
                                end
                            else
                                for LL=1
                                    A_avg = A_avg + W(LL)*Lx{t-(LL-1)};
                                end
                                for LL=2:L
                                    A_avg = A_avg + W(LL)*AttrtNew{t-(LL-1)};
                                end
                            end
                        end
                        if reig
                            [~,Diag,Un] = eig(A_avg); 
                        else
                            [Un,Diag,Vn] = eig(A_avg);
                        end
                       
                        if absX
                            [dx,ind] = sort(abs(diag(Diag)),'descend');
                        else    
                            [~,ind] = sort(diag(Diag),'descend');
                        end

                        Un = Un(:,ind);
                                        
                        if sum(sum(abs(imag(Un)))) ~= 0
                            if printWarning
                                disp(["Seed",seed])
                                disp(["Rep",rep])
                                disp(["Iter",iter])
                                disp("complex Ux")
                            end
                            Un=real(Un);
                        end 
                                               
                        if NormalizerAbs
                            NormalizerUn = sum(abs(Un),2);
                            if NormalizerUn > 0
                                Un=Un./NormalizerUn;
                            end
                        end

                        if NormalizerNoAbs
                            NormalizerUn = sum(Un,2);
                            if NormalizerUn ~= 0
                                Un=Un./NormalizerUn;
                            end
                        end
                        if NormalizeUxBool
                            for i=1:N(t)
                                if NormalizeUxBool == 1
                                    NormalizerUx = norm(Un(i,:),1);
                                elseif NormalizeUxBool == 2
                                    NormalizerUx = norm(Un(i,:),2);
                                else
                                    NormalizerUx = norm(Un(i,:),'fro');
                                end
                                if NormalizerUx > 0
                                    Un(i,:)=Un(i,:)/NormalizerUx;
                                end
                            end
                        end
                        %If it reaches the maximum number of iterations it will exit the
                        %loop
                        if earlystop
                            if norm(Un-U,'fro')^2<epsilon
                                flagloop = 0;
                            end
                        end
                        
                        iterNum = iterNum + 1;
                        if iterNum == MaxIterW
                            flagloop = 0;
                        end
                    end

                    UxOverKt{kiter} = Un;

                    WrepX{t,repidx}=W;

                    UgC = UgOverKt{kiter}(:,1:Kt{t,kiter});
                    UxC = UxOverKt{kiter}(:,1:Kt{t,kiter});


                    if Ucomb == 1
                        UgUx = (1-alphaUAttr)*UgC + alphaUAttr*UxC;
                    elseif Ucomb == 2
                        UgUx = [(1-alphaUAttr)*UgC alphaUAttr*UxC];
                    elseif Ucomb == 0
                        UgUx = [UgC UxC];
                    end

                    if NormalizeUgUx
                        for i=1:N(t)
                            if NormalizeUgUx == 1
                                NormalizerUgUx = norm(UgUx(i,:),1);
                            elseif NormalizeUgUx == 2
                                NormalizerUgUx = norm(UgUx(i,:),2);
                            else
                                NormalizerUgUx = norm(UgUx(i,:),'fro');
                            end
                            if NormalizerUgUx > 0
                                UgUx(i,:)=UgUx(i,:)/NormalizerUgUx;
                            end
                        end
                    end

                    Wt{t,LIter,kiter}=W;
                    
                    UgUxKmeansDyn{t,kiter} = UgUx;
                    rng(rep);
                    Commstotal{t,kiter} = kmeans(UgUxKmeansDyn{t,kiter},Kt{t,kiter},'Replicate',replicate); 

                    numComms = unique(Commstotal{t,kiter});
                    partition = zeros(size(numComms,1),size(Commstotal{t,kiter},1));
                    partitionToSave = zeros(size(numComms,1),size(Commstotal{t,kiter},1));
                    posComm = ones(size(numComms,1),1);

                    for i = 1:size(Commstotal{t,kiter},1)
                        for j = 1:size(numComms,1)
                            if Commstotal{t,kiter}(i) == numComms(j)
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
                    Modularitytotal(t,kiter) = modularity(Commstotal{t,kiter},NetMet{t,1});
                    Densitytotal(t,kiter) = density(Commstotal{t,kiter},NetMet{t,1});         
                    if size(Attr,1) > size(Attr,2) 
                        if ismember(attrsType,["CategoricosHamming","Categoricos"])
                            entropyt = entropy(partition,Attr{t,1},nbins);
                            silt = evalclusters(Attr{t,1},Commstotal{t,kiter},'silhouette','Distance','Hamming');
                            Entropytotal(t,kiter) = entropyt;
                            Siltotal(t,kiter) = silt.CriterionValues;
                        end
                        if attrsType == "Reales"
                            dbt = evalclusters(Attr{t,1},Commstotal{t,kiter},'DaviesBouldin');
                            cht = evalclusters(Attr{t,1},Commstotal{t,kiter},'CalinskiHarabasz');
                            silt = evalclusters(Attr{t,1},Commstotal{t,kiter},'silhouette','Distance','Euclidean');
                            DBtotal(t,kiter) = dbt.CriterionValues;
                            CHtotal(t,kiter) = cht.CriterionValues;
                            Siltotal(t,kiter) = silt.CriterionValues;
                        end
                    else
                        if ismember(attrsType,["CategoricosHamming","Categoricos"])
                            entropyt = entropy(partition,Attr{1,t},nbins);
                            silt = evalclusters(Attr{1,t},Commstotal{t,kiter},'silhouette','Distance','Hamming');
                            Entropytotal(t,kiter) = entropyt;
                            Siltotal(t,kiter) = silt.CriterionValues;
                        end
                        if attrsType == "Reales"
                            dbt = evalclusters(Attr{1,t},Commstotal{t,kiter},'DaviesBouldin');
                            cht = evalclusters(Attr{1,t},Commstotal{t,kiter},'CalinskiHarabasz');
                            silt = evalclusters(Attr{1,t},Commstotal{t,kiter},'silhouette','Distance','Euclidean');
                            DBtotal(t,kiter) = dbt.CriterionValues;
                            CHtotal(t,kiter) = cht.CriterionValues;
                            Siltotal(t,kiter) = silt.CriterionValues;
                        end
                    end  

                    
                    NMIval = getNMI(Commstotal{t,kiter},GT{t});
                    VIval = getVI(Commstotal{t,kiter},GT{t});
                    [Jaccardval,Precisionval,Sensitivityval,Specificityval,RandIndexval,AdjustedRandIndexval] = getMeasures(Commstotal{t,kiter}',GT{t});
                    NMItotal(t,kiter) = NMIval;
                    VItotal(t,kiter) = VIval;
                    Jaccardtotal(t,kiter) = Jaccardval;
                    Precisiontotal(t,kiter) = Precisionval;
                    Sensitivitytotal(t,kiter) = Sensitivityval;
                    Specificitytotal(t,kiter) = Specificityval;
                    RandIndextotal(t,kiter) = RandIndexval;
                    AdjustedRandIndextotal(t,kiter) = AdjustedRandIndexval;
                

                    if MaxMod
                        if kiter == 1
                            MaxModularityTotal(t) = Modularitytotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if Modularitytotal(t,kiter) > MaxModularityTotal(t)
                                MaxModularityTotal(t) = Modularitytotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end
                    end
                    if MaxDen
                        if kiter == 1
                            MaxDensityTotal(t) = Densitytotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if Densitytotal(t,kiter) > MaxDensityTotal(t)
                                MaxDensityTotal(t) = Densitytotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end
                    end
                    if MinEnt
                        if kiter == 1
                            MinEntropyTotal(t) = Entropytotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if Entropytotal(t,kiter) < MinEntropyTotal(t)
                                MinEntropyTotal(t) = Entropytotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end
                    end
                    if MaxSil
                        if kiter == 1
                            MaxSilhouetteTotal(t) = Siltotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if Siltotal(t,kiter) > MaxSilhouetteTotal(t)
                                MaxSilhouetteTotal(t) = Siltotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end
                    end            
                    if MaxCH
                        if kiter == 1
                            MaxCalinskiHarabaszTotal(t) = CHtotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if CHtotal(t,kiter) > MaxCalinskiHarabaszTotal(t)
                                MaxCalinskiHarabaszTotal(t) = CHtotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end
                    end
                    if MinDB
                        if kiter == 1
                            MinDaviesBouldinTotal(t) = DBtotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if DBtotal(t,kiter) < MinDaviesBouldinTotal(t)
                                MinDaviesBouldinTotal(t) = DBtotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end
                    end 
                end
                MaxDenVal = max(Densitytotal(t,:));
                MaxModVal = max(Modularitytotal(t,:));
                MaxSilVal = max(Siltotal(t,:));
                if ismember(attrsType,["CategoricosHamming","Categoricos"])
                    MinEntVal = min(Entropytotal(t,:));
                end
                if attrsType == "Reales"
                    MaxCHVal = max(CHtotal(t,:));
                    MinDBVal = min(DBtotalSta(t,:));
                end
                for kiter=1:KValNum                     
                    if ismember(attrsType,["CategoricosHamming","Categoricos"])
                        DenEnttotal(t,kiter) = weightMod*((Densitytotal(t,kiter)-MaxDenVal)/MaxDenVal)+(1-weightMod)*(-(Entropytotal(t,kiter)-MinEntVal)/MinEntVal);
                        ModEnttotal(t,kiter) = weightMod*((Modularitytotal(t,kiter)-MaxModVal)/MaxModVal)+(1-weightMod)*(-(Entropytotal(t,kiter)-MinEntVal)/MinEntVal);
                    end
                    if attrsType == "Reales"
                        DenCHtotal(t,kiter) = weightMod*((Densitytotal(t,kiter)-MaxDenVal)/MaxDenVal)+(1-weightMod)*((CHtotal(t,kiter)-MaxCHVal)/MaxCHVal);
                        ModCHtotal(t,kiter) = weightMod*((Modularitytotal(t,kiter)-MaxModVal)/MaxModVal)+(1-weightMod)*((CHtotal(t,kiter)-MaxCHVal)/MaxCHVal);
                        DenDBtotal(t,kiter) = weightMod*((Densitytotal(t,kiter)-MaxDenVal)/MaxDenVal)+(1-weightMod)*(-(DBtotal(t,kiter)-MinDBVal)/MinDBVal);
                        ModDBtotal(t,kiter) = weightMod*((Modularitytotal(t,kiter)-MaxModVal)/MaxModVal)+(1-weightMod)*(-(DBtotal(t,kiter)-MinDBVal)/MinDBVal);
                    end
                    DenSiltotal(t,kiter) = weightMod*((Densitytotal(t,kiter)-MaxDenVal)/MaxDenVal)+(1-weightMod)*((Siltotal(t,kiter)-MaxSilVal)/MaxSilVal);                
                    ModSiltotal(t,kiter) = weightMod*((Modularitytotal(t,kiter)-MaxModVal)/MaxModVal)+(1-weightMod)*((Siltotal(t,kiter)-MaxSilVal)/MaxSilVal);                                            
                    if MaxDenEnt
                        if kiter == 1
                            MaxDensityEntropyTotal(t) = DenEnttotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if DenEnttotal(t,kiter) > MaxDensityEntropyTotal(t)
                                MaxDensityEntropyTotal(t) = DenEnttotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end                                    
                    elseif MaxModEnt
                        if kiter == 1
                            MaxModularityEntropyTotal(t) = ModEnttotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if ModEnttotal(t,kiter) > MaxModularityEntropyTotal(t)
                                MaxModularityEntropyTotal(t) = ModEnttotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end           
                    elseif MaxDenSil                
                        if kiter == 1
                            MaxDensitySilhouetteTotal(t) = DenSiltotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if DenSiltotal(t,kiter) > MaxDensitySilhouetteTotal(t)
                                MaxDensitySilhouetteTotal(t) = DenSiltotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end            
                    elseif MaxModSil              
                        if kiter == 1
                            MaxModularitySilhouetteTotal(t) = ModSiltotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if ModSiltotal(t,kiter) > MaxModularitySilhouetteTotal(t)
                                MaxModularitySilhouetteTotal(t) = ModSiltotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end                   
                    elseif MaxDenCH
                        if kiter == 1
                            MaxDensityCalinskiHarabaszTotal(t) = DenCHtotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if DenCHtotal(t,kiter) > MaxDensityCalinskiHarabaszTotal(t)
                                MaxDensityCalinskiHarabaszTotal(t) = DenCHtotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end                 
                    elseif MaxModCH
                        if kiter == 1
                            MaxModularityCalinskiHarabaszTotal(t) = ModCHtotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if ModCHtotal(t,kiter) > MaxModularityCalinskiHarabaszTotal(t)
                                MaxModularityCalinskiHarabaszTotal(t) = ModCHtotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end                   
                    elseif MaxDenDB
                        if kiter == 1
                            MaxDensityDaviesBouldinTotal(t) = DenDBtotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if DenDBtotal(t,kiter) > MaxDensityDaviesBouldinTotal(t)
                                MaxDensityDaviesBouldinTotal(t) = DenDBtotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end                
                    elseif MaxModDB
                        if kiter == 1
                            MaxModularityDaviesBouldinTotal(t) = ModDBtotal(t,kiter);
                            Maxkiter(t) = kiter;
                        end
                        if kiter > 1
                            if ModDBtotal(t,kiter) > MaxModularityDaviesBouldinTotal(t)
                                MaxModularityDaviesBouldinTotal(t) = ModDBtotal(t,kiter);
                                Maxkiter(t) = kiter;
                            end
                        end                 
                    end
                end 
                           
                MaxUgOverKt = UgOverKt{Maxkiter};
                MaxUxOverKt = UxOverKt{Maxkiter};
            end

            TimeAlSharoa{repidx,LIter} = toc(TimeAlSharoaStart);

        end
    end
    

end

CommstotalStaOld = CommstotalSta;
CommstotalOld = Commstotal;
CommstotalSta = cell(T,1);
Commstotal = cell(T,1);
for t=1:T
    CommstotalSta{t,1} = CommstotalStaOld{t,Maxkiter(t)};
    Commstotal{t,1} = CommstotalOld{t,Maxkiter(t)};
end

if plotflagData
    cd ImagesData
    for t=1:T
        figure(numfig)
        imagesc(Net{t})
        colormap(gray(256))
        colorbar
        title(strcat("Adjacency matrix at time t = ",num2str(t)))
        xlabel("Nodes")
        ylabel("Nodes")
        numfig=numfig+1;
        saveas(gcf,strcat('TN',num2str(Data-7),'Adjt',num2str(t),'.png'))

        for j =1:M
            figure(numfig)
            imagesc(Attr{t}(:,j),[MinAttr(j) MaxAttr(j)])
            colormap(gray(256))
            colorbar
            title(strcat("Attribute matrix at time t = ",num2str(t)))
            xlabel(strcat("Atribute ",num2str(j)))
            ylabel("Nodes")
            set(gca,'xtick',[])
            saveas(gcf,strcat('TN',num2str(Data-7),'Attr',num2str(j),'t',num2str(t),'.png'))
            numfig=numfig+1;
        end
    end
    cd ..
end

if saveResults
    cd(dirFolder)
    
    folderToCheck = extractBetween(saveName,1,8)+"ResA"+num2str(Alg)+"D"+num2str(Data)+"/";
    if ~exist(folderToCheck, 'dir')
       mkdir(folderToCheck)
    end
    
    if Alg ~= 1
        saveNameNew = folderToCheck+"Attr"+attrsType+"/"+extractBetween(saveName,9,strlength(saveName));
        if ~exist(folderToCheck+"Attr"+attrsType+"/", 'dir')
            mkdir(folderToCheck+"Attr"+attrsType+"/")
        end
    else
        saveNameNew = folderToCheck+extractBetween(saveName,9,strlength(saveName));
    end
    
    if eigsStatic
        eSSav = "e"+num2str(eigsStatic);
        absGSta = 0;
        absXSta = 0;
        aGSSav = "";
        aXSSav = "";
    else
        eSSav = "";
        if absGSta
            aGSSav = "aG"+num2str(absGSta);
        else
            aGSSav = "";
        end
        if absXSta        
            aXSSav = "aX"+num2str(absXSta);
        else
            aXSSav = "";
        end
    end
    
    if typeDiag
        tDSav = "D"+num2str(typeDiag);
    else
        tDSav = "";
    end
   
    if HammingDistanceSigmaMST
        HDSSav = "H"+num2str(HammingDistanceSigmaMST);
    else
        HDSSav = "";
    end
    
    if structSim
        sSSav = "s"+num2str(structSim);
    else
        sSSav = "";
    end

    if Ucomb
        UcSav = "U"+num2str(Ucomb);
        aUASav = "A"+num2str(alphaUAttr);
    else
        UcSav = "";
        aUASav = "";
    end
    
    if NormalizeUgBoolSta
        NUgBSSav = "g"+num2str(NormalizeUgBoolSta);
    else
        NUgBSSav = "";
    end
    
    if NormalizeUxBoolSta
        NUxBSSav = "x"+num2str(NormalizeUxBoolSta);
    else
        NUxBSSav = "";
    end
    
    if NormalizeUgUxSta
        NUgxSSav = "gx"+num2str(NormalizeUgUxSta);
    else
        NUgxSSav = "";
    end

    if svdCalc
        sCSav = "C"+num2str(svdCalc);
    else
        sCSav = "";
    end
    
    if absG
        aGSav = "G"+num2str(absG);
    else
        aGSav = "";
    end
    
    if absX
        aXSav = "X"+num2str(absX);
    else
        aXSav = "";
    end
    
    if NormalizeUgBool
        NUgBSav = "g"+num2str(NormalizeUgBool);
    else
        NUgBSav = "";
    end
    
    if NormalizeUxBool
        NUxBSav = "x"+num2str(NormalizeUxBool);
    else
        NUxBSav = "";
    end
    
    if NormalizeUgUx
        NUgxSav = "gx"+num2str(NormalizeUgUx);
    else
        NUgxSav = "";
    end
    
    if ReduceUnToK
        RUTKSav = "K"+num2str(ReduceUnToK);
    else
        RUTKSav = "";
    end
    
    if svdSizeKR
        sSKRSav = "KR"+num2str(svdSizeKR);
    else
        sSKRSav = "";
    end
    
    if NormalizeWnorm2
        NWSav = "W"+num2str(NormalizeWnorm2);
    else
        NWSav = "";
    end
    
    if NormalizeAttrMax
        NAMSav = "AM" +num2str(NormalizeAttrMax);
    else
        NAMSav = "";
    end
    
    if NormalizeAttrSum
        NASSav = "AS"+num2str(NormalizeAttrSum);
    else
        NASSav = "";
    end
    
    if NormalizerAbs
        NASav = "A"+num2str(NormalizerAbs);
    else
        NASav = "";
    end
    
    if NormalizerNoAbs
        NNASav = "NA"+num2str(NormalizerNoAbs);
    else
        NNASav = "";
    end

    if NormalizeWsum1
        NWsSav = "Ws"+num2str(NormalizeWsum1);
    else 
        NWsSav = "";
    end
    
    if coldstart
        csSav = "c"+num2str(coldstart);
    else
        csSav = "";
    end
    
    if earlystop
        esSav = "e"+num2str(earlystop);
    else
        esSav = "";
    end
    
    if learnAlpha
        lASav = "l"+num2str(learnAlpha);
    else
        lASav = "";
    end
    
    if sigmaMST
        sMSav = "sM"+num2str(sigmaMST);
    else
        sMSav = "";
    end
    
    if ~attrsIncBool
        numAttrs = "";
    else
        numAttrs = "nAt"+num2str(M(T));
    end
    
    if ~useNcutG
        uNcG = "";
    else
        uNcG = "nC"+num2str(useNcutG);
    end
    
    if WfixedW && WfixedX
        Wfixed = 1;
        if ~Wfixed
            WfSav = "";
        else
            WfSav = "Wf"+num2str(WfixedVal(1));
        end
    else
        Wfixed = 0;
        if ~WfixedX
            WfSav = "";
        else
            WfSav = "WfX"+num2str(WfixedVal(1));
        end    
    end
    paramsFileName = strcat(tDSav,NAMSav,NASSav,NASav,NNASav,sSSav,sMSav,HDSSav,eSSav,aGSSav,aXSSav,UcSav,aUASav,NUgBSSav,NUxBSSav,NUgxSSav,sCSav,sSKRSav,NWSav,NWsSav,aGSav,aXSav,NUgBSav,NUxBSav,NUgxSav,RUTKSav,csSav,esSav,lASav,numAttrs,reduceAtStr,WfSav,uNcG);
    Opt = "";
    
    if Data == 14 || Data == 15 || Data == 16 || Data == 89 || Data == 90 || Data == 91 || Data == 107 || Data == 108 || Data == 109
        Opt = "";
        if static == 0
            save(strcat(saveNameNew,"A",int2str(Alg),'D',num2str(Data),'t',num2str(t),'R',num2str(rep),'s',num2str(seed),'i',num2str(MaxIter),'L',num2str(L),'PV',num2str(ProbVar),'rk',num2str(replicate),paramsFileName,Opt,".mat"),'NMItotal','NMItotalSta','VItotal','TimeAlSharoa','timeTensor','Alg','Data','Ls','alpha','WrepG','WrepX','Commstotal','CommstotalSta','Modularitytotal','Densitytotal','Entropytotal','ModularitytotalSta','DensitytotalSta','EntropytotalSta','DBtotal','CHtotal','Siltotal','DBtotalSta','CHtotalSta','SiltotalSta','Maxkiter');    %'K',num2str(K(1))
        else
            save(strcat(saveNameNew,"A",int2str(Alg),'D',num2str(Data),'t',num2str(t),'R',num2str(rep),'s',num2str(seed),'i',num2str(MaxIter),'L',num2str(L),'PV',num2str(ProbVar),'rk',num2str(replicate),paramsFileName,Opt,".mat"),'NMItotal','NMItotalSta','VItotal','timeTensor','Alg','Data','alpha','Commstotal','CommstotalSta','Modularitytotal','Densitytotal','Entropytotal','ModularitytotalSta','DensitytotalSta','EntropytotalSta','DBtotal','CHtotal','Siltotal','DBtotalSta','CHtotalSta','SiltotalSta','Maxkiter');    %'K',num2str(K(1))
        end
    elseif Data == 17 || Data == 18 || Data == 19 || Data == 20 || Data == 21 || Data == 22
        if static == 0
            save(strcat(saveNameNew,"A",int2str(Alg),'D',num2str(Data),'t',num2str(t),'R',num2str(rep),'s',num2str(seed),'i',num2str(MaxIter),'L',num2str(L),'RA',num2str(randomAttrs),'MA',num2str(multiAttrs),'rk',num2str(replicate),paramsFileName,Opt,".mat"),'NMItotal','NMItotalSta','VItotal','TimeAlSharoa','timeTensor','Alg','Data','Ls','alpha','WrepG','WrepX','Commstotal','CommstotalSta','Modularitytotal','Densitytotal','Entropytotal','ModularitytotalSta','DensitytotalSta','EntropytotalSta','DBtotal','CHtotal','Siltotal','DBtotalSta','CHtotalSta','SiltotalSta','Maxkiter');    %'K',num2str(K(1))
        else
            save(strcat(saveNameNew,"A",int2str(Alg),'D',num2str(Data),'t',num2str(t),'R',num2str(rep),'s',num2str(seed),'i',num2str(MaxIter),'L',num2str(L),'RA',num2str(randomAttrs),'MA',num2str(multiAttrs),'rk',num2str(replicate),paramsFileName,Opt,".mat"),'NMItotal','NMItotalSta','VItotal','timeTensor','Alg','Data','alpha','Commstotal','CommstotalSta','Modularitytotal','Densitytotal','Entropytotal','ModularitytotalSta','DensitytotalSta','EntropytotalSta','DBtotal','CHtotal','Siltotal','DBtotalSta','CHtotalSta','SiltotalSta','Maxkiter');    %'K',num2str(K(1))
        end
    else
        if static == 0
            save(strcat(saveNameNew,"A",int2str(Alg),'D',num2str(Data),'t',num2str(t),'R',num2str(rep),'s',num2str(seed),'i',num2str(MaxIter),'L',num2str(L),'rk',num2str(replicate),paramsFileName,Opt,".mat"),'NMItotal','NMItotalSta','VItotal','TimeAlSharoa','timeTensor','Alg','Data','Ls','alpha','WrepG','WrepX','Commstotal','CommstotalSta','Modularitytotal','Densitytotal','Entropytotal','ModularitytotalSta','DensitytotalSta','EntropytotalSta','DBtotal','CHtotal','Siltotal','DBtotalSta','CHtotalSta','SiltotalSta','Maxkiter');    %'K',num2str(K(1))
        else
            save(strcat(saveNameNew,"A",int2str(Alg),'D',num2str(Data),'t',num2str(t),'R',num2str(rep),'s',num2str(seed),'i',num2str(MaxIter),'L',num2str(L),'rk',num2str(replicate),paramsFileName,Opt,".mat"),'NMItotal','NMItotalSta','VItotal','timeTensor','Alg','Data','alpha','Commstotal','CommstotalSta','Modularitytotal','Densitytotal','Entropytotal','ModularitytotalSta','DensitytotalSta','EntropytotalSta','DBtotal','CHtotal','Siltotal','DBtotalSta','CHtotalSta','SiltotalSta','Maxkiter');    %'K',num2str(K(1))
        end
    end
    
    if printMetrics 
        disp(["TypeDiag",typeDiag])
        disp(["ModularitytotalSta",mean(ModularitytotalSta)])
        disp(["EntropytotalSta",mean(EntropytotalSta)])
        disp(["NMItotalSta",mean(NMItotalSta)])
        disp(["Modularitytotal",mean(Modularitytotal)])
        disp(["Entropytotal",mean(Entropytotal)])
        disp(["NMItotal",mean(NMItotal)])
    end
end
   

fullTime = toc(initTimeStart)

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
        Lsym = 0;
        Lrw = 0;
        LunLux = 0;
        LTang = 1;
        if Lsym == 1
            A = eye(numNodes1) - diag(D)^(-1/2)*A*diag(D)^(-1/2);
        end
        if Lrw == 1
            A = eye(numNodes1) - diag(D)^(-1)*A;
        end
        if LunLux == 1
            A = diag(D) - A;
        end
        if LTang == 1
            %Calculation of normalized adjacency matrices according to Tang
            A = diag(D)^(-1/2)*A*diag(D)^(-1/2);
        end
        %Next 4 lines are for adding the zero rows/columns again
        p = ~ismember(1:numNodes1,rowZeroIndex);
        M = bsxfun(@and,p,p')+0;
        M(M~=0)=A;
        A = M;
    else
        Lsym = 0;%no converge
        Lrw = 0;%no converge
        LunLux = 0;%no converge
        LTang = 1;
        if Lsym == 1
            A = eye(numNodes1) - diag(D)^(-1/2)*Net*diag(D)^(-1/2);
        end
        if Lrw == 1
            A = eye(numNodes1) - diag(D)^(-1)*Net;
        end
        if LunLux == 1
            A = diag(D) - Net;
        end
        if LTang == 1
            %Calculation of normalized adjacency matrices according to Tang
            A = diag(D)^(-1/2)*Net*diag(D)^(-1/2);
        end
    end
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

function A = fillzeros(A, n)
    m=size(A,1);
    B = zeros(n,n);
    B(1:m,1:m)= A;
    A=B;
end

function B = insertNodes(A, pos)
    sizeMat = size(A,2);
    B = zeros(sizeMat+1,sizeMat+1);
    if pos > sizeMat
        B(1:sizeMat,1:sizeMat) = A(1:sizeMat,1:sizeMat);
    elseif pos == 1
        B(2:end,2:end) = A(1:sizeMat,1:sizeMat);
    else
        B(1:pos-1,1:pos-1) = A(1:pos-1,1:pos-1); 
        B(pos+1:end,pos+1:end) = A(pos:end,pos:end);
        B(pos+1:end,1:pos-1) = A(pos:end,1:pos-1);
        B(1:pos-1,pos+1:end) = A(1:pos-1,pos:end);
    end
    
end

function A = fillzerosAttr(A, n)
    m=size(A,1);
    m2=size(A,2);
    B = zeros(n,m2);
    B(1:m,:)= A;
    A=B;
end

function B = insertNodesAttr(A, pos)
    sizeMat = size(A,1);
    sizeMat2 = size(A,2);
    B = zeros(sizeMat+1,sizeMat2);
    if pos > sizeMat
        B(1:sizeMat,:) = A(1:sizeMat,:);
    elseif pos == 1
        B(2:end,:) = A(1:sizeMat,:);
    else
        B(1:pos-1,:) = A(1:pos-1,:); 
        B(pos+1:end,:) = A(pos:end,:);
    end
end

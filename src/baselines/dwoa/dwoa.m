%% Clear all
clear;

%Name of the output file
saveName ="Results/Testing";

Alg = 1;

if(~isdeployed)
  cd(getProjectRoot());
end

dirFolder = pwd;

mttkrpUse = 0;

replicate = 20;

khatri = 0;
reig = 1;
displayW = 0;
Wfixed = 0;
WfixedVal = [0;1];
NormalizeUgUxCol = 0;
nbins = 0;

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
attrsType = "Reales";

svdSizeKR = 1;

initInTimeStart = tic;

%Number of runs with different random initialization for the
%alternating optimization
IterRep = 1;
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
structSim=0;
NormalizerAbs = 0;
NormalizerNoAbs = 0;
plotflag = 0;
plotflagData = 0;
sigmaMST = 1;
NormalizeWnorm2 = 1;
NormalizeWsum1 = 0;
NormalizeUgUx = 1;
%Minimum change threshold
epsilon = 1e-5;
saveResults = 1;


numfig = 1;

NMItotalorig = cell(IterRep,size(Ls,2));
VItotal = cell(IterRep,size(Ls,2));
Jaccardtotal = cell(IterRep,size(Ls,2));
Precisiontotal = cell(IterRep,size(Ls,2));
Sensitivitytotal = cell(IterRep,size(Ls,2));
Specificitytotal = cell(IterRep,size(Ls,2));
RandIndextotal = cell(IterRep,size(Ls,2));
AdjustedRandIndextotal = cell(IterRep,size(Ls,2));
timeTensor = cell(size(Ls,2),1);
TimeAlSharoa = cell(IterRep,size(Ls,2));
KValNum = 1;

%% Set random seed for replication
%rng(0);
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

NetMet = cell(size(Net));

%tic

%Number of time intervals
T = size(Net,1);

NMItotal = zeros(T,KValNum);
Modularitytotal = zeros(T,KValNum);
Densitytotal = zeros(T,KValNum);
Entropytotal = zeros(T,KValNum);
DBtotal = zeros(T,KValNum);
CHtotal = zeros(T,KValNum);
Siltotal = zeros(T,KValNum);
Commstotal = cell(IterRep,size(Ls,2),T);
%Initialization of maximum number of nodes
maxsize = 0;
%Initialization of a cell array for handling temporary operations 
A = cell(T,1);
N = zeros(T,1);

if structSim == 1
    Sg = cell(T,1);
end


Lg = cell(T,1);
timeLaplacians = tic;
%% Normalization of adjacency matrices
for t = 1:T
    N(t) = size(Net{t},1);
    if N(t) > maxsize
        maxsize = N(t);
    end
    %The algorithm does not enter here
    if structSim == 1
        G = graph(Net{t});
        Wg = distances(G);
        if sigmaMST
            %pdist????
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
                %pdist([Attr{t}(i,j); Attr{t}(idx(i,int8(knum)),j)])
                mean = mean + pdist([Wg(i,:); Wg(idx(i,int8(knum)),:)]);
                cont = cont + 1;
            end
            mean = mean/cont;
            sigmaSq1 = mean^2;
            if sigmaSq1 == Inf%It does not specify what to do
                sigmaSq1 = (N(t)*10)^2;
            end
        end
        %graph symmetric similarity matrix
        Sg{t} = exp(-((Wg.*Wg)/(sigmaSq1*log(N(t)))));
        Lg{t} = Laplacian(Sg{t});
    else
        Sg{t} = Net{t};
        Lg{t} = Laplacian(Net{t});
    end
end
timeLaplacians = toc(timeLaplacians);

Redt = Lg;
%Initialization of the array for community assignment
CommsTN = cell(T,IterRep);

%Inilization of structure for storing all tensors
X=cell(T,1);

Wt=cell(T,size(Ls,2));

for LIter=1:size(Ls,2)
    L = Ls(LIter);
    RedtNew = cell(size(Net,1)-1,1);
    UNewIndex = cell(size(Net,1)-1,L);
    %W=zeros(L,1);
    %% Creation of tensors
    timeTensorStart = tic;
    
    for t = 2:L
        RedtNew{t-1,1} = Redt{t};
        sizeTen = N(t);
        tensorArray = zeros(sizeTen,sizeTen,t);
        l = 1;
        while (l<=t-1)
            tensorArray(:,:,l) = RedtNew{t-1,1};
            l = l + 1;
        end
        tensorArray(:,:,l) = Redt{t};
        X{t} = tensor(tensorArray,[N(t),N(t),t]);
    end

    MaxNumNode = size(Net{1,1},1);
    NodosEliminados = cell(T-1,1);
    NodosNuevos = cell(T-1,1);
    NodosAgregAntiguos = cell(T-1,1);
    if t>= L
    for t=L:T
        sizeTen = N(t);
        tensorArray = zeros(sizeTen,sizeTen,L);
        l = L;
        for ll = 1:L-1
            RedtNew{t-1,1} = Redt{t-l+1};
            RemainingNodes = ismember(Vindex{t-1,1},Vindex{t,1});
            NodosEliminados{t-1} = find(RemainingNodes == 0);
            
            if ~isempty(NodosEliminados{t-1})
                %returns the position not the number of the node
                NodosEliminados{t-1} = sort(NodosEliminados{t-1},'descend'); 
                for i=1:size(NodosEliminados{t-1},1)
                    RedtNew{t-1,1}(NodosEliminados{t-1}(i),:) = [];
                    RedtNew{t-1,1}(:,NodosEliminados{t-1}(i)) = [];
                end

            end

            nodesbool = ~ismember(Vindex{t,1},Vindex{t-1,1});
            nodes = Vindex{t,1}(nodesbool);
            NodosNuevos{t-1} = nodes(nodes>MaxNumNode);
            NodosAgregAntiguos{t-1} = nodes(nodes<=MaxNumNode);

            %NOTE: when old nodes have been re-added, double check this
            %size check is using the correct dimension
            if size(NodosAgregAntiguos{t-1},2)>=1 && size(NodosAgregAntiguos{t-1},1)>0%fixed on 2021-04-24, from >1 to >=1
                posAnt = zeros(size(NodosAgregAntiguos{t-1},2),1);
                for k = 1:size(NodosAgregAntiguos{t-1},2)
                    posAnt(k) = find(Vindex{t,1} == NodosAgregAntiguos{t-1}(k));
                end
            end 

            if ~isempty(NodosNuevos{t-1})
                MaxNumNode = max(NodosNuevos{t-1});
                RedtNew{t-1,1} = fillzeros(RedtNew{t-1,1},size(RedtNew{t-1,1},1)+size(NodosNuevos{t-1},1));

            end

            if ~isempty(NodosAgregAntiguos{t-1})
                A = RedtNew{t-1,1};
                for i=1:size(NodosAgregAntiguos{t-1},2) 
                    A = insertNodes(A, posAnt(i));
                end
                RedtNew{t-1,1} = A;
            end

            if isempty(NodosNuevos{t-1}) && isempty(NodosAgregAntiguos{t-1}) && isempty(NodosEliminados{t-1})
                RedtNew{t-1,1} = Redt{t-1};
            end
            tensorArray(:,:,ll) = RedtNew{t-1,1};%RedtNew{t-1,1};%RedtNew{t-1,1};
            l = l-1;
        end
        ll = L;
        tensorArray(:,:,ll) = Redt{t};%Redt{t};%RedtNew{t-1,1};
        X{t} = tensor(tensorArray,[N(t),N(t),L]);
    end
    end
    %toc
    
    timeTensor{LIter} = toc(timeTensorStart);

    TimeAlSharoaStart = tic;
    %% Clustering for t=1

    if reig
        [~,Diag,Un] = eig(Redt{1});
    else
        [Un,Diag,Vn] = eig(Redt{1});
    end
    
    [~,ind] = sort(diag(Diag),'descend');
    Un = Un(:,ind);
    %Diag will have the eigenvalues in the diagonal. The greater the
    %eigenvalue, the more densely connected is the graph
    

    %% Normalizing by sum of absolute values
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

    
    UgUx = Un(:,1:K(1));
    if NormalizeUgUx
        for i=1:N(1)
            NormalizerUgUx = norm(UgUx(i,:),NormalizeUgUx);
            if NormalizerUgUx > 0
                UgUx(i,:)=UgUx(i,:)/NormalizerUgUx;
            end
        end
    end
            if NormalizeUgUxCol
            for i=1:K(1)
                NormalizerUgUx = norm(UgUx(:,i),NormalizeUgUx);
                if NormalizerUgUx > 0
                    UgUx(:,i)=UgUx(:,i)/NormalizerUgUx;
                end
            end
        end
    for rep=1:IterRep
        rng(rep);
        %Taking the first K eigenvectors that correspond to the larger eigenvalues
        CommsTN{1,rep} = kmeans(UgUx,K(1),'replicate',replicate);
        Commstotal{rep,:,1}=CommsTN{1,rep};
    end
  
    %% Clustering for each time interval, starting with time interval 2
    for t = 2:T

        ColSize = ceil(sqrt(1600000000/(N(t)^2))/2);
        
        if ColSize > N(t)
            ColSize = N(t);
        end
        if t < L
            svdSize = t;
            W=zeros(t,1);
        else
            svdSize = L;
            W=zeros(L,1);
        end
        %Update of W
        
        
        if coldstart
            if ~isempty(NodosEliminados{t-1})
                %returns the position not the number of the node
                NodosEliminados{t-1} = sort(NodosEliminados{t-1},'descend'); 
                for i=1:size(NodosEliminados{t-1},1)
                    Un(NodosEliminados{t-1}(i),:) = [];
                    Un(:,NodosEliminados{t-1}(i)) = [];
                end

            end
            if size(NodosAgregAntiguos{t-1},2)>=1 && size(NodosAgregAntiguos{t-1},1)>0%Agregado 24/04/2021
                posAnt = zeros(size(NodosAgregAntiguos{t-1},2),1);
                for k = 1:size(NodosAgregAntiguos{t-1},2)
                    posAnt(k) = find(Vindex{t,1} == NodosAgregAntiguos{t-1}(k));
                end
            end 

            if ~isempty(NodosNuevos{t-1})
                MaxNumNode = max(NodosNuevos{t-1});
                Un = fillzeros(Un,size(Un,1)+size(NodosNuevos{t-1},1));

            end

            if ~isempty(NodosAgregAntiguos{t-1})
                A = Un;
                for i=1:size(NodosAgregAntiguos{t-1},2) 
                    A = insertNodes(A, posAnt(i));
                end
                Un = A;

            end

            if isempty(NodosNuevos{t-1}) && isempty(NodosAgregAntiguos{t-1}) && isempty(NodosEliminados{t-1})
                Un = Un;

            end
            U = Un;%Initialization with previous value
        else
            if t < L
                InitU = hosvd(X{t},epsilon,'verbosity',0);%,'ranks',[N(t),N(t),t]);
                U = InitU{2};%position 2 of the results should be the same due to simmetry
            else
                InitU = hosvd(X{t},epsilon,'verbosity',0);%,'ranks',[N(t),N(t),L]);
                U = InitU{2};%position 2 of the results should be the same due to simmetry
            end
        end
        
        %Initialization of iteration counter
        i = 0;
        %Update of W
        if mttkrpUse == 1
            Xsp=sptensor(X{t});
            temp = mttkrp(Xsp,{U,U,W},3);
            W=svd(temp);
        else
            X_3 = tenmat(X{t},3);%'fc' 'bc'
            if svdSizeKR
                if khatri
                    temp=X_3 * khatrirao(U(:,1:ColSize),U(:,1:ColSize));
                else
                    temp=X_3 * kron(U(:,1:ColSize),U(:,1:ColSize));%khatrirao(U(:,1:svdSize),U(:,1:svdSize));
                end
            else
                if khatri
                    temp=X_3 * khatrirao(U,U); 
                else
                    temp=X_3 * kron(U,U); 
                end
            end

            W=svd(temp.data);%,'econ');% dominant left singular vector of size L

        end
        if displayW
            disp(W)
        end
        if Wfixed
            W=WfixedVal;
        end
        if NormalizeWnorm2
            W=W/norm(W,2);  
        end
        if NormalizeWsum1
            W=W/sum(W);  
        end

        A_avg = 0;
        if L == 1
            A_avg = Redt{t};
        else
            if t < L
                for tt=1
                    A_avg = A_avg + W(tt)*Redt{t-(tt-1)};
                end
                for tt=2:t
                    A_avg = A_avg + W(tt)*RedtNew{t-(tt-1)};
                end
            else
                for LL=1
                    A_avg = A_avg + W(LL)*Redt{t-(LL-1)};
                end
                for LL=2:L
                    A_avg = A_avg + W(LL)*RedtNew{t-(LL-1)};
                end
            end
        end

        %Update of U
        if reig
            [~,Diag,Un] = eig(A_avg);
        else
            [Un,Diag,Vn] = eig(A_avg);
        end

        [dx,ind] = sort(diag(Diag),'descend');
        
        Un = Un(:,ind);
        
        %% Normalizing by sum of absolute values
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
        flagloop = 1;
        %Iterate until convergence
        while(flagloop)
            U=Un;

            if mttkrpUse == 1
                temp = mttkrp(Xsp,{U,U,W},3);
                W=svd(temp);
            else
                if svdSizeKR
                    if khatri
                        temp=X_3 * khatrirao(U(:,1:ColSize),U(:,1:ColSize));
                    else
                        temp=X_3 * kron(U(:,1:ColSize),U(:,1:ColSize));%khatrirao(U(:,1:svdSize),U(:,1:svdSize));
                    end
                else
                    if khatri
                        temp=X_3 * khatrirao(U,U);
                    else
                        temp=X_3 * kron(U,U);
                    end
                end
                W=svd(temp.data);%,'econ');
                
            end
            
            if NormalizeWnorm2
                W=W/norm(W,2);  
            end
            if NormalizeWsum1
                W=W/sum(W);  
            end
            
            if displayW
                disp(W)
            end
            if Wfixed
                W=WfixedVal;
            end
            A_avg = 0;
            if L == 1
                A_avg = Redt{t};
            else
                if t < L
                    for tt=1
                        A_avg = A_avg + W(tt)*Redt{t-(tt-1)};
                    end
                    for tt=2:t
                        A_avg = A_avg + W(tt)*RedtNew{t-(tt-1)};
                    end
                else
                    for LL=1
                        A_avg = A_avg + W(LL)*Redt{t-(LL-1)};
                    end
                    for LL=2:L
                        A_avg = A_avg + W(LL)*RedtNew{t-(LL-1)};
                    end
                end
            end

            %Update of U
            if reig
                [~,Diag,Un] = eig(A_avg);
            else
                [Un,Diag,Vn] = eig(A_avg);%cambiado el 2109
            end
            
            [dx,ind] = sort(diag(Diag),'descend');
            
            Un = Un(:,ind);

            
            
            %% Normalizing by sum of absolute values
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
            

            %Update of the iterator
            i=i+1;
            %If it reaches the maximum number of iterations it will exit the
            %loop
            if earlystop
                if norm(Un-U,'fro')^2<epsilon
                    flagloop = 0;
                end
            end

            if i == MaxIter
                flagloop = 0;
            end

        end

        
        %% Normalizing by sum of absolute values
        Wt{t,LIter}=W;
        UgUx = Un(:,1:K(t));
        if NormalizeUgUx
            for i=1:N(t)
                NormalizerUgUx = norm(UgUx(i,:),NormalizeUgUx);
                if NormalizerUgUx > 0
                    UgUx(i,:)=UgUx(i,:)/NormalizerUgUx;
                end
            end
        end
        if NormalizeUgUxCol
            for i=1:K(t)
                NormalizerUgUx = norm(UgUx(:,i),NormalizeUgUx);
                if NormalizerUgUx > 0
                    UgUx(:,i)=UgUx(:,i)/NormalizerUgUx;
                end
            end
        end

        for rep=1:IterRep
            rng(rep);
            
            CommsTN{t,rep} = kmeans(UgUx,K(t),'replicate',replicate);
            
            Commstotal{rep,LIter,t} = CommsTN{t,rep};
        end
    end

    %Initialization of arrays for NMI and VI
    NMI = zeros(T,1);
    VI = zeros(T,1);
    Jaccard = zeros(T,1);
    Precision = zeros(T,1);
    Sensitivity = zeros(T,1);
    Specificity = zeros(T,1);
    RandIndex = zeros(T,1);
    AdjustedRandIndex = zeros(T,1);

    NetMet = Net;
    
    for rep=1:IterRep  
        %% Results
        for t = 1:T
            if ismember(attrsType,["CategoricosHamming","Categoricos"])
                numComms = unique(CommsTN{t,rep});
                partition = zeros(size(numComms,1),size(CommsTN{t,rep},1));
                partitionToSave = zeros(size(numComms,1),size(CommsTN{t,rep},1));
                posComm = ones(size(numComms,1),1);

                for i = 1:size(CommsTN{t,rep},1)
                    for j = 1:size(numComms,1)
                        if CommsTN{t,rep}(i) == numComms(j)
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
            Modularitytotal(t) = modularity(CommsTN{t,rep},NetMet{t,1});
            Densitytotal(t) = density(CommsTN{t,rep},NetMet{t,1});         
            if size(Attr,1) > size(Attr,2) 
                if ismember(attrsType,["CategoricosHamming","Categoricos"])
                    entropyt = entropy(partition,Attr{t,1},nbins);
                    silt = evalclusters(Attr{t,1},CommsTN{t,rep},'silhouette','Distance','Hamming');
                    Entropytotal(t) = entropyt;
                    Siltotal(t) = silt.CriterionValues;
                end
                if attrsType == "Reales"
                    dbt = evalclusters(Attr{t,1},CommsTN{t,rep},'DaviesBouldin');
                    cht = evalclusters(Attr{t,1},CommsTN{t,rep},'CalinskiHarabasz');
                    silt = evalclusters(Attr{t,1},CommsTN{t,rep},'silhouette','Distance','Euclidean');
                    DBtotal(t) = dbt.CriterionValues;
                    CHtotal(t) = cht.CriterionValues;
                    Siltotal(t) = silt.CriterionValues;
                end
            else
                if ismember(attrsType,["CategoricosHamming","Categoricos"])
                    entropyt = entropy(partition,Attr{1,t},nbins);
                    silt = evalclusters(Attr{1,t},CommsTN{t,rep},'silhouette','Distance','Hamming');
                    Entropytotal(t) = entropyt;
                    Siltotal(t) = silt.CriterionValues;
                end
                if attrsType == "Reales"
                    dbt = evalclusters(Attr{1,t},CommsTN{t,rep},'DaviesBouldin');
                    cht = evalclusters(Attr{1,t},CommsTN{t,rep},'CalinskiHarabasz');
                    silt = evalclusters(Attr{1,t},CommsTN{t,rep},'silhouette','Distance','Euclidean');
                    DBtotal(t) = dbt.CriterionValues;
                    CHtotal(t) = cht.CriterionValues;
                    Siltotal(t) = silt.CriterionValues;
                end
            end            
            NMIval = getNMI(CommsTN{t,rep},GT{t});
            NMItotal(t,1) = NMIval;
            sizeNet = sum(GT{t}>0);
            if sizeNet <= maxsize
                NMI(t) = getNMI(CommsTN{t,rep},GT{t});
                VI(t) = getVI(CommsTN{t,rep},GT{t});
                [Jaccard(t),Precision(t),Sensitivity(t),Specificity(t),RandIndex(t),AdjustedRandIndex(t)] = getMeasures(CommsTN{t,rep}(1:sizeNet)',GT{t});
                if plotflag
                    Comms = zeros(maxsize,K(t));
                    for n=1:maxsize
                        for k=1:K(t)
                            if CommsTN{t,rep}(n) == k
                                Comms(n,k)=1;
                            end
                        end
                    end
                    figure(t)
                    imagesc(Comms)
                    colormap(gray(256))
                end
            else
                NMI(t) = getNMI(CommsTN{t,rep}',GT{t});
                VI(t) = getVI(CommsTN{t,rep}',GT{t});
                [Jaccard(t),Precision(t),Sensitivity(t),Specificity(t),RandIndex(t),AdjustedRandIndex(t)] = getMeasures(CommsTN{t,rep}',GT{t});
                if plotflag
                    Comms = zeros(maxsize,K(t));
                    for n=1:maxsize
                        for k=1:K(t)
                            if CommsTN{t,rep}(n) == k
                                Comms(n,k)=1;
                            end
                        end
                    end
                    figure(t)
                    imagesc(Comms)
                    colormap(gray(256))
                end
            end

        end

        NMItotalorig{rep,LIter} = NMI;
        VItotal{rep,LIter} = VI;
        Jaccardtotal{rep,LIter} = Jaccard;
        Precisiontotal{rep,LIter} = Precision;
        Sensitivitytotal{rep,LIter} = Sensitivity;
        Specificitytotal{rep,LIter} = Specificity;
        RandIndextotal{rep,LIter} = RandIndex;
        AdjustedRandIndextotal{rep,LIter} = AdjustedRandIndex;
        TimeAlSharoa{rep,LIter} = toc(TimeAlSharoaStart);
        %NMI
    end

end

if saveResults
    cd(dirFolder)
    
    folderToCheck = extractBetween(saveName,1,8)+"ResA"+num2str(Alg)+"D"+num2str(Data)+"/";
    if ~exist(folderToCheck, 'dir')
       mkdir(folderToCheck)
    end
    if Alg ~= 1
        saveNameNew = folderToCheck+"/Attr"+attrsType+"/"+extractBetween(saveName,9,strlength(saveName));
    else
        saveNameNew = folderToCheck+extractBetween(saveName,9,strlength(saveName));
    end

    if Data == 14 || Data == 15 || Data == 16  || Data == 89 || Data == 90 || Data == 91 || Data == 107 || Data == 108 || Data == 109
        save(strcat(saveNameNew,"A",int2str(Alg),'D',num2str(Data),'c',num2str(coldstart),'s',num2str(seed),'e',num2str(earlystop),'i',num2str(MaxIter),'A',num2str(NormalizerAbs),'nA',num2str(NormalizerNoAbs),'wn',num2str(NormalizeWnorm2),'ws',num2str(NormalizeWsum1),'PV',num2str(ProbVar),'rk',num2str(replicate),"RepNew.mat"),'NMItotal','VItotal','TimeAlSharoa','timeTensor','Alg','Data','Ls','Wt','Commstotal','Modularitytotal','Densitytotal','Entropytotal','DBtotal','CHtotal','Siltotal');    
    elseif Data == 17 || Data == 18 || Data == 19 || Data == 20 || Data == 21 || Data == 22
        save(strcat(saveNameNew,"A",int2str(Alg),'D',num2str(Data),'c',num2str(coldstart),'s',num2str(seed),'e',num2str(earlystop),'i',num2str(MaxIter),'A',num2str(NormalizerAbs),'nA',num2str(NormalizerNoAbs),'wn',num2str(NormalizeWnorm2),'ws',num2str(NormalizeWsum1),'R',num2str(randomAttrs),'M',num2str(multiAttrs),'rk',num2str(replicate),"RepNew.mat"),'NMItotal','VItotal','TimeAlSharoa','timeTensor','Alg','Data','Ls','Wt','Commstotal','Modularitytotal','Densitytotal','Entropytotal','DBtotal','CHtotal','Siltotal');    
    else
        save(strcat(saveNameNew,"A",int2str(Alg),'D',num2str(Data),'c',num2str(coldstart),'s',num2str(seed),'e',num2str(earlystop),'i',num2str(MaxIter),'A',num2str(NormalizerAbs),'nA',num2str(NormalizerNoAbs),'wn',num2str(NormalizeWnorm2),'ws',num2str(NormalizeWsum1),'rk',num2str(replicate),"RepNew.mat"),'NMItotal','VItotal','TimeAlSharoa','timeTensor','Alg','Data','Ls','Wt','Commstotal','Modularitytotal','Densitytotal','Entropytotal','DBtotal','CHtotal','Siltotal');    
    end
    
    
    
end





fullTime = toc(initInTimeStart)


function [A, maxsize] = Laplacian(Net,maxsize)

    %Degree of each node
    D = sum(Net,2);
    %Number of nodes for unweighted network
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

function B = removeNodes(A, pos)
    if pos == size(A,2)
        B = A(1:pos-1,1:pos-1); 
    elseif pos == 1
        B = A(pos+1:end,pos+1:end);
    else
        B = zeros(size(A,1)-1,size(A,2)-1);
        B(1:pos-1,1:pos-1) = A(1:pos-1,1:pos-1); 
        B(pos:end,pos:end) = A(pos+1:end,pos+1:end);
        B(pos:end,1:pos-1) = A(pos+1:end,1:pos-1);
        B(1:pos-1,pos:end) = A(1:pos-1,pos+1:end);
    end
end

function [Net, Attr, K, GT, AttrOverTime,Vindex] = SyntheticNetwork2(datasets, seed, ProbVar, randomAttrs)

%Each time step is randomly generated in the same way as T = 1

if(~isdeployed)
  cd(getProjectRoot());
end

if seed ~= 0
    rng(seed);
else
    rng();
end

close all;

plotflag = 0;

if datasets == 7
    T = 10;
    N = zeros(T,1);
    M = zeros(T,1);
    M(:) = 3;
    n1 = 80;
    n2 = 90;
    n2cum = n1+n2; 
    n3 = 100;
    N(:) = n1 + n2 + n3;
    perc5Num = round(.05*N(1));
    nodes5 = randi([1 N(1)],perc5Num,1);
    while (size(unique(nodes5),1)<perc5Num)
        nodes5 = unique(nodes5);
        nodes5(size(unique(nodes5),1)+1) = randi([1 N(1)],1,1);
    end
    %number of nodes that are moved to community 1 at each time step
    %it also indicates how many nodes at the start of community 2 change to
    %commmunity 1 and how many nodes at the start of community 3 change to
    %commmunity 2, therefore reducing community 3 
    chgValues = [20 3 4 25 1 34 1 2 1];
    theta = ones(N(1),1);
    theta(nodes5,1)=3;
    Net=cell(T,1);
    Attr=cell(T,1);
    GT = cell(T,1);
    Vindex = cell(T,1);
    ProbE11 = ProbVar;
    ProbE22 = ProbE11 -0.01;
    ProbE33 = ProbE11 -0.02;
    ProbMix = 0.08;
    u = 1.5;
    if randomAttrs == 0
        mu1 = [u 0 0];
        mu2 = [0 0 0];
        mu3 = [-u 0 0];
    else
        mu1 = [0 0 0];
        mu2 = [0 0 0];
        mu3 = [0 0 0];
    end
    sigma = 0.1*eye(M(1));
    for t=1
        Net{t} = zeros(N(t),N(t));
        Attr{t} = zeros(N(t),M(t));
        for i = 1:n1
            for j = i+1:n1
                if rand() < ProbE11*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end
            for j = n1+1:N
                if rand() < ProbMix*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end                
        end
        for i = n1+1:n2cum
            for j = i+1:n2cum
                if rand() < ProbE22*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end
            for j = n2cum+1:N
                if rand() < ProbMix*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end                
        end
        for i = n2cum+1:N
            for j = i+1:N
                if rand() < ProbE33*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end
        end     
        %This is in order to replicate the same network structure, no matter 
        %if there is attributes or not, the same sequence of random numbers
        %run over the creation of the adjacency matrices
        sAttrs = rng;
        Attr{t}(1:n1,:) = mvnrnd(mu1,sigma,n1);       
        Attr{t}(n1+1:n2cum,:) = mvnrnd(mu2,sigma,n2);
        Attr{t}(n2cum+1:N,:) = mvnrnd(mu3,sigma,n3); 
        GT{t} = [ones(1,n1) 2*ones(1,n2) 3*ones(1,n3)]';
        rng(sAttrs);
    end
    for t=2:T
        GT{t}=GT{t-1};
        Net{t} = Net{t-1};
        Attr{t} = Attr{t-1};
        for i = n1 + 1:n1 + chgValues(t-1)
            GT{t}(i) = 1;
            sAttrs = rng;
            Attr{t}(i,:) = mvnrnd(mu1,sigma,1);       
            rng(sAttrs);
            Net{t}(i,:) = 0;
            Net{t}(:,i) = 0;
            for j = 1:n1 + chgValues(t-1)
                if i == j
                    Net{t}(i,j) = 0;
                else
                    if rand() < ProbE11*theta(i)*theta(j)
                        Net{t}(i,j) = 1;
                        Net{t}(j,i) = 1;
                    end
                end
            end
            for j = n1 + chgValues(t-1) + 1:N
                if rand() < ProbMix*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end                
        end
        for i = n2cum+1:n2cum + chgValues(t-1)
            GT{t}(i) = 2;
            sAttrs = rng;
            Attr{t}(i,:) = mvnrnd(mu2,sigma,1);
            rng(sAttrs);
            Net{t}(i,:) = 0;
            Net{t}(:,i) = 0;
            for j = n1 + chgValues(t-1): n2cum + chgValues(t-1)
                if i == j
                    Net{t}(i,j) = 0;
                else
                    if rand() < ProbE22*theta(i)*theta(j)
                        Net{t}(i,j) = 1;
                        Net{t}(j,i) = 1;
                    end
                end
            end
            for j = 1 : n1 + chgValues(t-1)
                if i == j
                    Net{t}(i,j) = 0;
                else
                    if rand() < ProbMix*theta(i)*theta(j)
                        Net{t}(i,j) = 1;
                        Net{t}(j,i) = 1;
                    end
                end
            end
            for j = i+1: N(t)
                if i == j
                    Net{t}(i,j) = 0;
                else
                    if rand() < ProbMix*theta(i)*theta(j)
                        Net{t}(i,j) = 1;
                        Net{t}(j,i) = 1;
                    end
                end
            end
        end
        n1 = n1 + chgValues(t-1);
        n2cum = n2cum + chgValues(t-1);
    end    
    AttrOverTime = cell(M(1),1);
    for j = 1:M
        AttrOverTime{j} = zeros(N(1),T);
        for t = 1:T
            for n = 1:N
                AttrOverTime{j}(n,t) = Attr{t}(n,j);
            end
        end
    end
    if plotflag == 1
        MinAttr = zeros(M(t),1);
        MaxAttr = zeros(M(t),1);

        for j = 1:M(t)
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
        k = 1;
        for t = 1:T
            figure(k)
            spy(Net{t},'k')
            delete(findall(findall(gcf,'Type','axe'),'Type','text'))
            ax = gca;
            ax.XAxis.FontSize = 16;
            ax.YAxis.FontSize = 16;
            xticks([1 55 110 165 220 270]);
            yticks([1 55 110 165 220 270]);
            
            xlabel("Nodes")
            ylabel("Nodes")
            k=k+1;
            saveas(gcf,strcat('Tang1Adjt',num2str(t),'.png'))
        end
        for j =1:M
            figure(k)
            imagesc(AttrOverTime{j},[MinAttr(j) MaxAttr(j)])
            colormap(gray(256))
            c = colorbar;
            c.FontSize = 16;
            ax = gca;
            ax.XAxis.FontSize = 16;
            ax.YAxis.FontSize = 16;

            yticks([1 55 110 165 220 270]); 
            
            xlabel(strcat("Timestamps"))
            ylabel("Nodes")
            saveas(gcf,strcat('Tang1Attr',num2str(j),'.png'))
            k=k+1;
        end
    end
    K = 3*ones(T,1);
    
end

if datasets == 8
    T = 10;
    N = zeros(T,1);
    M = zeros(T,1);
    M(:) = 3;
    n1 = 80;
    n2 = 90;
    n2cum = n1+n2; 
    n3 = 100;
    N(:) = n1 + n2 + n3;
    perc5Num = round(.05*N(1));
    nodes5 = randi([1 N(1)],perc5Num,1);
    while (size(unique(nodes5),1)<perc5Num)
        nodes5 = unique(nodes5);
        nodes5(size(unique(nodes5),1)+1) = randi([1 N(1)],1,1);
    end
    chgValues = [20 3 4 25 1 34 1 2 1];
    theta = ones(N(1),1);
    theta(nodes5,1)=3;
    Net=cell(T,1);
    Attr=cell(T,1);
    GT = cell(T,1);
    Vindex = cell(T,1);
    ProbE11 = 0.3;
    ProbE22 = 0.3;
    ProbE33 = 0.1;
    ProbMix = 0.09;
    ProbMix12 = ProbVar;
    u = 1.5;
    if randomAttrs == 0
        mu1 = [u 0 0];
        mu2 = [0 0 0];
        mu3 = [-u 0 0];
    else
        mu1 = [0 0 0];
        mu2 = [0 0 0];
        mu3 = [0 0 0];
    end
    sigma = 0.1*eye(M(1));
    for t=1
        Net{t} = zeros(N(t),N(t));
        Attr{t} = zeros(N(t),M(t));
        for i = 1:n1
            for j = i+1:n1
                if rand() < ProbE11*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end
            for j = n1+1:n2cum
                if rand() < ProbMix12*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end    
            for j = n2cum+1:N
                if rand() < ProbMix*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end                
        end
        for i = n1+1:n2cum
            for j = i+1:n2cum
                if rand() < ProbE22*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end
            for j = n2cum+1:N
                if rand() < ProbMix*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end                
        end
        for i = n2cum+1:N
            for j = i+1:N
                if rand() < ProbE33*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end
        end
        sAttrs = rng;
        Attr{t}(1:n1,:) = mvnrnd(mu1,sigma,n1);       
        Attr{t}(n1+1:n2cum,:) = mvnrnd(mu2,sigma,n2);
        Attr{t}(n2cum+1:N,:) = mvnrnd(mu3,sigma,n3);
        GT{t} = [ones(1,n1) 2*ones(1,n2) 3*ones(1,n3)]';
        rng(sAttrs);
    end
    for t=2:T
        GT{t}=GT{t-1};
        Net{t} = Net{t-1};
        Attr{t} = Attr{t-1};
        for i = n1 + 1:n1 + chgValues(t-1)
            GT{t}(i) = 1;
            sAttrs = rng;
            Attr{t}(i,:) = mvnrnd(mu1,sigma,1);
            rng(sAttrs);
            Net{t}(i,:) = 0;
            Net{t}(:,i) = 0;
            for j = 1:n1 + chgValues(t-1)
                if i == j
                    Net{t}(i,j) = 0;
                else
                    if rand() < ProbE11*theta(i)*theta(j)
                        Net{t}(i,j) = 1;
                        Net{t}(j,i) = 1;
                    end
                end
            end
            for j = n1 + chgValues(t-1) + 1:n2cum + chgValues(t-1)
                if rand() < ProbMix12*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end    
            for j = n2cum+ chgValues(t-1)+1:N
                if rand() < ProbMix*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end                
        end
        for i = n2cum+1:n2cum + chgValues(t-1)
            GT{t}(i) = 2;
            sAttrs = rng;
            Attr{t}(i,:) = mvnrnd(mu2,sigma,1);
            rng(sAttrs);
            Net{t}(i,:) = 0;
            Net{t}(:,i) = 0;
            for j = n1 + chgValues(t-1): n2cum + chgValues(t-1)
                if i == j
                    Net{t}(i,j) = 0;
                else
                    if rand() < ProbE22*theta(i)*theta(j)
                        Net{t}(i,j) = 1;
                        Net{t}(j,i) = 1;
                    end
                end
            end
            for j = 1 : n1 + chgValues(t-1)
                if i == j
                    Net{t}(i,j) = 0;
                else
                    if rand() < ProbMix12*theta(i)*theta(j)
                        Net{t}(i,j) = 1;
                        Net{t}(j,i) = 1;
                    end
                end
            end   
            for j = i+1: N(t)
                if i == j
                    Net{t}(i,j) = 0;
                else
                    if rand() < ProbMix*theta(i)*theta(j)
                        Net{t}(i,j) = 1;
                        Net{t}(j,i) = 1;
                    end
                end
            end            
        end           
        n1 = n1 + chgValues(t-1);
        n2cum = n2cum + chgValues(t-1);
        
    end
        AttrOverTime = cell(M(1),1);
    for j = 1:M
        AttrOverTime{j} = zeros(N(1),T);
        for t = 1:T
            for n = 1:N
                AttrOverTime{j}(n,t) = Attr{t}(n,j);
            end
        end
    end
    if plotflag == 1
        MinAttr = zeros(M(t),1);
        MaxAttr = zeros(M(t),1);

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
        k = 1;
        for t = 1:T
            figure(k)
            spy(Net{t},'k')
            delete(findall(findall(gcf,'Type','axe'),'Type','text'))
            ax = gca;
            ax.XAxis.FontSize = 16;
            ax.YAxis.FontSize = 16;
            xticks([1 55 110 165 220 270]);
            yticks([1 55 110 165 220 270]); 
            
            xlabel("Nodes")
            ylabel("Nodes")
            k=k+1;
            saveas(gcf,strcat('Tang2Adjt',num2str(t),'.png'))
        end
        for j =1:M
            figure(k)
            imagesc(AttrOverTime{j},[MinAttr(j) MaxAttr(j)])
            colormap(gray(256))
            c = colorbar;
            c.FontSize = 16;
            ax = gca;
            ax.XAxis.FontSize = 16;
            ax.YAxis.FontSize = 16;

            yticks([1 55 110 165 220 270]);
            xlabel(strcat("Timestamps"))
            ylabel("Nodes")
            saveas(gcf,strcat('Tang2Attr',num2str(j),'.png'))
            k=k+1;
        end
    end
    K = 3*ones(T,1);

end

if datasets == 9
    T = 10;
    N = zeros(T,1);
    M = zeros(T,1);
    M(:) = 3;    
    n1 = 80;
    n2 = 90;
    n2cum = n1+n2; 
    n3 = 100;
    N(:) = n1 + n2 + n3;
    perc5Num = round(.05*N(1));
    nodes5 = randi([1 N(1)],perc5Num,1);
    while (size(unique(nodes5),1)<perc5Num)
        nodes5 = unique(nodes5);
        nodes5(size(unique(nodes5),1)+1) = randi([1 N(1)],1,1);
    end
    chgValues = [20 3 4 25 1 34 1 2 1];
    theta = ones(N(1),1);
    theta(nodes5,1)=3;
    Net=cell(T,1);
    Attr=cell(T,1);
    GT = cell(T,1);
    Vindex = cell(T,1);
    ProbE11 = 0.1;
    ProbE22 = 0.1;
    ProbE33 = 0.1;
    ProbMix = ProbVar;
    u = 1.5;
    if randomAttrs == 0
        mu1 = [u 0 0];
        mu2 = [0 0 0];
        mu3 = [-u 0 0];
    else
        mu1 = [0 0 0];
        mu2 = [0 0 0];
        mu3 = [0 0 0];
    end
    sigma = 0.1*eye(M(1));%author do not state the value, only say is the same for the three attributes
    
    for t=1      
        Net{t} = zeros(N(t),N(t));
        Attr{t} = zeros(N(t),M(t));
        
        for i = 1:n1
            for j = i+1:n1
                if rand() < ProbE11*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end
            for j = n1+1:N
                if rand() < ProbMix*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end                
        end
        for i = n1+1:n2cum
            for j = i+1:n2cum
                if rand() < ProbE22*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end
            for j = n2cum+1:N
                if rand() < ProbMix*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end                
        end
        for i = n2cum+1:N
            for j = i+1:N
                if rand() < ProbE33*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end
        end    
        sAttrs = rng;
        Attr{t}(1:n1,:) = mvnrnd(mu1,sigma,n1);       
        Attr{t}(n1+1:n2cum,:) = mvnrnd(mu2,sigma,n2);
        Attr{t}(n2cum+1:N,:) = mvnrnd(mu3,sigma,n3);
        GT{t} = [ones(1,n1) 2*ones(1,n2) 3*ones(1,n3)]'; 
        rng(sAttrs);
    end
    for t=2:T  
        GT{t}=GT{t-1};
        Net{t} = Net{t-1};
        Attr{t} = Attr{t-1};
        
        for i = n1 + 1:n1 + chgValues(t-1)
            GT{t}(i) = 1;
            sAttrs = rng;
            Attr{t}(i,:) = mvnrnd(mu1,sigma,1);
            rng(sAttrs);
            Net{t}(i,:) = 0;
            Net{t}(:,i) = 0;
            for j = 1:n1 + chgValues(t-1)
                if i == j
                    Net{t}(i,j) = 0;
                else
                    if rand() < ProbE11*theta(i)*theta(j)
                        Net{t}(i,j) = 1;
                        Net{t}(j,i) = 1;
                    end
                end
            end
            for j = n1 + chgValues(t-1) + 1:N
                if rand() < ProbMix*theta(i)*theta(j)
                    Net{t}(i,j) = 1;
                    Net{t}(j,i) = 1;
                end
            end                 
        end
        for i = n2cum+1:n2cum + chgValues(t-1)
            GT{t}(i) = 2;
            sAttrs = rng;
            Attr{t}(i,:) = mvnrnd(mu2,sigma,1);
            rng(sAttrs);
            Net{t}(i,:) = 0;
            Net{t}(:,i) = 0;
            for j = n1 + chgValues(t-1): n2cum + chgValues(t-1)
                if i == j
                    Net{t}(i,j) = 0;
                else
                    if rand() < ProbE22*theta(i)*theta(j)
                        Net{t}(i,j) = 1;
                        Net{t}(j,i) = 1;
                    end
                end
            end
            for j = 1 : n1 + chgValues(t-1)
                if i == j
                    Net{t}(i,j) = 0;
                else
                    if rand() < ProbMix*theta(i)*theta(j)
                        Net{t}(i,j) = 1;
                        Net{t}(j,i) = 1;
                    end
                end
            end
            for j = i+1: N(t)
                if i == j
                    Net{t}(i,j) = 0;
                else
                    if rand() < ProbMix*theta(i)*theta(j)
                        Net{t}(i,j) = 1;
                        Net{t}(j,i) = 1;
                    end
                end
            end
        end

        n1 = n1 + chgValues(t-1);
        n2cum = n2cum + chgValues(t-1);       
            
    end
    
    AttrOverTime = cell(M(1),1);
    for j = 1:M
        AttrOverTime{j} = zeros(N(1),T);
        for t = 1:T
            for n = 1:N
                AttrOverTime{j}(n,t) = Attr{t}(n,j);
            end
        end
    end
    if plotflag == 1
        MinAttr = zeros(M(t),1);
        MaxAttr = zeros(M(t),1);

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
        k = 1;
        for t = 1:T
            figure(k)
            spy(Net{t},'k')
            delete(findall(findall(gcf,'Type','axe'),'Type','text'))
            ax = gca;
            ax.XAxis.FontSize = 16;
            ax.YAxis.FontSize = 16;
            xticks([1 55 110 165 220 270]);
            yticks([1 55 110 165 220 270]); 
            
            xlabel("Nodes")
            ylabel("Nodes")
            k=k+1;
            saveas(gcf,strcat('Tang3Adjt',num2str(t),'.png'))
        end      
        for j =1:M
            figure(k)
            imagesc(AttrOverTime{j},[MinAttr(j) MaxAttr(j)])
            colormap(gray(256))
            c = colorbar;
            c.FontSize = 16;
            ax = gca;
            ax.XAxis.FontSize = 16;
            ax.YAxis.FontSize = 16;

            yticks([1 55 110 165 220 270]);
            
            xlabel(strcat("Timestamps"))
            ylabel("Nodes")
            saveas(gcf,strcat('Tang3Attr',num2str(j),'.png'))
            k=k+1;
        end

    end
    K = 3*ones(T,1);
end

for t = 1:T
    Vindex{t} = 1:size(Net{t},1);
    Vindex{t} = Vindex{t}';
end
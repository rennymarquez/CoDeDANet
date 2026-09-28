%17, dataset 1: 200 nodes, 1 attribute, 20 time intervals, starts
%with 2 groups where 40 % of the nodes become a third group, in both
%topology and attributes
%18, dataset 2: 200 nodes, 1 attribute, 20 time intervals, starts
%with 2 groups where 80 % of the nodes become a third group, in both
%topology and attributes

function [Net,Attr,GT,K,Vindex] = SyntheticNetwork1(dataset,seed,randomAttrs,multiAttrs) 
    rng(seed);

    if(~isdeployed)
        cd(getProjectRoot());
    end
    %Flag to plot
    plotflag = 0;
    if multiAttrs == 0
        M=1;
        if randomAttrs == 0
            mu1 = 0;
            mu2 = 1;
            mu3 = -1;
        else
            mu1 = 0;
            mu2 = 0;
            mu3 = 0;
        end
        sigma = 0.1;
    end
    if multiAttrs == 1
        M=3;
        if randomAttrs == 0
            mu1 = [1 0 0];
            mu2 = [0 0 0];
            mu3 = [-1 0 0];
        else
            mu1 = [0 0 0];
            mu2 = [0 0 0];
            mu3 = [0 0 0];
        end
        sigma = 0.1*eye(M);
    end
    
    
    if dataset ==1 %40 percent
        %%Unweighted, undirected, no selfloops

        %Number of nodes
        N = 200;
        
        %Number of snapshots
        T = 20;

        %Dividing the nodes in two, on the middle
        sizes = [N/2,N/2];
        cumsize = sum(sizes);
        %Probabilities of inter and intra edges at the beginning, with two groups
        probs = [0.3 0.1; 0.1 0.3];
        %Probabilities of inter and intra edges, after being three groups
        probnew = [0.3 0.1 0.1; 0.1 0.3 0.1; 0.1 0.1 0.3];
        %30% of the nodes end up in the first group, 40% in the second group and
        %30% in the third group
        sizesnew = [N*3/10,N*4/10,N*3/10];
        cumsizenew = [sizesnew(1)+sizesnew(2) sum(sizesnew)];
        %Ground truth at the beginning
        GTarray = zeros(T,N);
        GTarray(1:T,1:sizes(1)) = 1;
        GTarray(1:T,sizes(1)+1:N) = 2;

        %Creating the intra edges for the first group and inter edges that links
        %with the second group
        adj = zeros(N,N);
        Attrt1 = zeros(N,M);
        for i=1:sizes(1)
            for j=i+1:sizes(1)
                if rand() < probs(1,1)
                    adj(i,j) = 1;
                else
                    adj(i,j) = 0;
                end
            end
            for j=sizes(1)+1:cumsize
                if rand() < probs(1,2)
                    adj(i,j) = 1;
                else
                    adj(i,j) = 0;
                end
            end
        end
        sAttrs = rng;
        Attrt1(1:sizes(1),:)=mvnrnd(mu1,sigma,sizes(1));
        rng(sAttrs);
        %Creating the intra edges for the second group
        for i=sizes(1)+1:cumsize
            for j=i+1:cumsize
                if rand() < probs(2,2)
                    adj(i,j) = 1;
                else
                    adj(i,j) = 0;
                end
            end

        end
        sAttrs = rng;
        Attrt1(sizes(1)+1:cumsize,:)=mvnrnd(mu2,sigma,cumsize-sizes(1));
        rng(sAttrs);
        %setting the symmetry on the network
        adj = adj+adj';

        %Setting the time interval where the node will change its belonging, for
        %each of the 40% of the nodes (middle nodes)
        chgpts = round(normrnd(10,2,[sizesnew(2),1]));
        %Obtaining an ordered array of the time and node that will change
        [time,index] = sort(chgpts);
        %Updating the index array to the number of the node
        index=index+sizesnew(1);
        %First time where a change is made
        initT = min(chgpts);
        %Last time where a change is made
        endT = max(chgpts);
        %Initilization for the new adjacency matrix
        adjt = cell(1,T);
        %Initilization for the array of attribute matrices
        Attr = cell(1,T);
        %Setting first adjacency matrices as before, for all time intervals before
        %doing the first change
        for i = 1:initT-1
            adjt{i} = adj;
            Attr{i} = Attrt1;
        end

        %Flag to control the assignment of the adjacency matrix from previous snapshot 
        %into the current one
        flag = 1;

        %For each of the nodes included in the 40%
        for nodechg=1:sizesnew(2)
            %Retrieve the index of the node
            i=index(nodechg);
            %Update the belonging of the node
            GTarray(time(nodechg):T,i)=3;
            
            %If the flag is not 0, it will assign the full adjacency matrix from previous 
            %snapshot into the current one
            if flag == 1
                adjt{1,time(nodechg)}=adjt{time(nodechg)-1};
                Attr{1,time(nodechg)}=Attr{time(nodechg)-1};
            end

            sAttrs = rng;
            Attr{1,time(nodechg)}(i,:)=mvnrnd(mu3,sigma);
            rng(sAttrs);
            %Setting the rows and coumns of the node to zero
            adjt{1,time(nodechg)}(i,:)=zeros(1,N);
            adjt{1,time(nodechg)}(:,i)=zeros(1,N);
            %Random assignment of the node with the first group
            for j=1:sizesnew(1)
                if rand() < probnew(1,3)
                    adjt{1,time(nodechg)}(i,j) = 1;
                    adjt{1,time(nodechg)}(j,i) = 1;
                end

            end
            %Random assignment of the node with the third group
            for j=sizesnew(1)+1:cumsizenew(1)
                if rand() < probnew(3,3)
                    adjt{1,time(nodechg)}(i,j) = 1;
                    adjt{1,time(nodechg)}(j,i) = 1;
                end

            end
            %Random assignment of the node with the second group
            for j=cumsizenew(1)+1:cumsizenew(2)
                if rand() < probnew(2,3)
                    adjt{1,time(nodechg)}(i,j) = 1;
                    adjt{1,time(nodechg)}(j,i) = 1;
                end
            end
            %If the time for next node to assign is the same, flag will be 0 and no
            %initialization of the full adjacency matrix will be done
            if nodechg<sizesnew(2)
                flag = time(nodechg+1)-time(nodechg);
                if flag > 1
                    for i=1:flag
                        adjt{1,time(nodechg)+i}=adjt{time(nodechg)+i-1};
                        Attr{1,time(nodechg)+i}=Attr{time(nodechg)+i-1};
                    end
                end
            end    
        end

        %Assignment of the adjacency matrices beyond endT as the previous ones
        for i = endT+1:T
            adjt{i} = adjt{i-1};
            Attr{i} = Attr{i-1};
        end

        %To visualize connections of the random network
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
            for t = 1:T
                figure(t)
                spy(adjt{t},'k')
                delete(findall(findall(gcf,'Type','axe'),'Type','text'))
                ax = gca;
                ax.XAxis.FontSize = 16;
                ax.YAxis.FontSize = 16;  
                xlabel("Nodes")
                ylabel("Nodes")
                saveas(gcf,strcat('Sheik1Adjt',num2str(t),'.png'))

            end
            for j =1:M
                figure(T+j)
                imagesc(AttrOverTime{j})
                colormap(gray(256))
                c = colorbar;
                c.FontSize = 16;
                xlabel(strcat("Timestamps"))
                ylabel("Nodes")
                ax = gca;
                ax.XAxis.FontSize = 16;
                ax.YAxis.FontSize = 16;  
                saveas(gcf,strcat('Sheik1Attr',num2str(j),'.png'))
            end

            
        end

        %Update of the name of the array
        Net = adjt';

        %Number of communities at each snapshot
        K = [2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2];
        K(initT:20)=3;
    elseif dataset == 2 %80percent
        %Number of nodes
        N = 200;

        %Number of snapshots
        T = 20;



        %Dividing the nodes in two, on the middle
        sizes = [N/2,N/2];
        cumsize = sum(sizes);
        %Probabilities of inter and intra edges at the beginning, with two groups
        probs = [0.3 0.1; 0.1 0.3];
        %Probabilities of inter and intra edges, after being three groups
        probnew = [0.3 0.1 0.1; 0.1 0.3 0.1; 0.1 0.1 0.3];
        %30% of the nodes end up in the first group, 40% in the second group and
        %30% in the third group
        sizesnew = [N*1/10,N*8/10,N*1/10];
        cumsizenew = [sizesnew(1)+sizesnew(2) sum(sizesnew)];
        %Ground truth at the beginning
        GTarray = zeros(T,N);
        GTarray(1:T,1:sizes(1)) = 1;
        GTarray(1:T,sizes(1)+1:N) = 2;

        %Creating the intra edges for the first group and inter edges that links
        %with the second group
        adj = zeros(N,N);
        Attrt1 = zeros(N,M);
        for i=1:sizes(1)
            for j=i+1:sizes(1)
                if rand() < probs(1,1)
                    adj(i,j) = 1;
                else
                    adj(i,j) = 0;
                end
            end
            for j=sizes(1)+1:cumsize
                if rand() < probs(1,2)
                    adj(i,j) = 1;
                else
                    adj(i,j) = 0;
                end
            end
        end
        sAttrs = rng;
        Attrt1(1:sizes(1),:)=mvnrnd(mu1,sigma,sizes(1));
        rng(sAttrs);        

        %Creating the intra edges for the second group
        for i=sizes(1)+1:cumsize
            for j=i+1:cumsize
                if rand() < probs(2,2)
                    adj(i,j) = 1;
                else
                    adj(i,j) = 0;
                end
            end
        end
        sAttrs = rng;
        Attrt1(sizes(1)+1:cumsize,:)=mvnrnd(mu2,sigma,cumsize-sizes(1));
        rng(sAttrs);        
        %setting the symmetry on the network
        adj = adj+adj';

        %Setting the time interval where the node will change its belonging, for
        %each of the 80% of the nodes (middle nodes)
        chgpts = round(normrnd(10,2,[sizesnew(2),1]));
        %Obtaining an ordered array of the time and node that will change
        [time,index] = sort(chgpts);
        %Updating the index array to the number of the node
        index=index+sizesnew(1);
        %First time where a change is made
        initT = min(chgpts);
        %Last time where a change is made
        endT = max(chgpts);
        %Initilization for the new adjacency matrix
        adjt = cell(1,T);
        %Initilization for the array of attribute matrices
        Attr = cell(1,T);
        %Setting first adjacency matrices as before, for all time intervals before
        %doing the first change
        for i = 1:initT-1
            adjt{i} = adj;
            Attr{i} = Attrt1;
        end

        %Flag to control the assignment of the adjacency matrix from previous snapshot 
        %into the current one
        flag = 1;

        %For each of the nodes included in the 80%
        for nodechg=1:sizesnew(2)
            %Retrieve the index of the node
            i=index(nodechg);
            %Update the belonging of the node
            GTarray(time(nodechg):T,i)=3;

            %If the flag is not 0, it will assign the full adjacency matrix from previous 
            %snapshot into the current one
            if flag == 1
                adjt{1,time(nodechg)}=adjt{time(nodechg)-1};
                Attr{1,time(nodechg)}=Attr{time(nodechg)-1};
            end

            sAttrs = rng;
            Attr{1,time(nodechg)}(i,:)=mvnrnd(mu3,sigma);
            rng(sAttrs);           
            %Setting the rows and coumns of the node to zero
            adjt{1,time(nodechg)}(i,:)=zeros(1,N);
            adjt{1,time(nodechg)}(:,i)=zeros(1,N);
            %Random assignment of the node with the first group
            for j=1:sizesnew(1)
                if rand() < probnew(1,3)
                    adjt{1,time(nodechg)}(i,j) = 1;
                    adjt{1,time(nodechg)}(j,i) = 1;
                end

            end
            %Random assignment of the node with the third group
            for j=sizesnew(1)+1:cumsizenew(1)
                if rand() < probnew(3,3)
                    adjt{1,time(nodechg)}(i,j) = 1;
                    adjt{1,time(nodechg)}(j,i) = 1;
                end

            end
            %Random assignment of the node with the second group
            for j=cumsizenew(1)+1:cumsizenew(2)
                if rand() < probnew(2,3)
                    adjt{1,time(nodechg)}(i,j) = 1;
                    adjt{1,time(nodechg)}(j,i) = 1;
                end
            end
            %If the time for next node to assign is the same, flag will be 0 and no
            %initialization of the full adjacency matrix will be done
            if nodechg<sizesnew(2)
                flag = time(nodechg+1)-time(nodechg);
                if flag > 1
                    for i=1:flag
                        adjt{1,time(nodechg)+i}=adjt{time(nodechg)+i-1};
                        Attr{1,time(nodechg)+i}=Attr{time(nodechg)+i-1};
                    end
                end
            end    
        end

        %Assignment of the adjacency matrices beyond endT as the previous ones
        for i = endT+1:T
            adjt{i} = adjt{i-1};
            Attr{i} = Attr{i-1};
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
        %To visualize connections of the random network
        if plotflag == 1
            for t = 1:T
                figure(t)
                spy(adjt{t},'k')
                delete(findall(findall(gcf,'Type','axe'),'Type','text'))
                ax = gca;
                ax.XAxis.FontSize = 16;
                ax.YAxis.FontSize = 16;  
                xlabel("Nodes")
                ylabel("Nodes")
                saveas(gcf,strcat('Sheik2Adjt',num2str(t),'.png'))

            end
            for j =1:M
                figure(T+j)
                imagesc(AttrOverTime{j})
                colormap(gray(256))
                c = colorbar;
                c.FontSize = 16;
                xlabel(strcat("Timestamps"))
                ylabel("Nodes")
                ax = gca;
                ax.XAxis.FontSize = 16;
                ax.YAxis.FontSize = 16;  

                saveas(gcf,strcat('Sheik2Attr',num2str(j),'.png'))
            end
        end

        %Update of the name of the array
        Net = adjt';

        %Number of communities at each snapshot
        K = [2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2];
        K(initT:20)=3;
    end
    GT = cell(T,1);
    Vindex = cell(T,1);
    for t = 1:T
        GT{t} = GTarray(t,:)';
        Vindex{t} = 1:size(Net{t},1);
    end
end
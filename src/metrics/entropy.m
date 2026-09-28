function Entropy = entropy(partition,AttrTimet,nbins)


    if size(AttrTimet,1) > size(AttrTimet,2) 
        AttrTimet = AttrTimet;
    else 
        AttrTimet = AttrTimet';
    end

    if nbins ~= 0
        AttrTimet = discretize(AttrTimet,nbins,'IncludedEdge','right');
    end
    partitionOrderedNodes = zeros(size(nonzeros(partition),1),1);

    posNodes = 1;
    for i=1:size(partition,1)
        for j=1:size(partition,2)
            if partition(i,j) ~= 0
                partitionOrderedNodes(posNodes)=partition(i,j);
                posNodes=posNodes+1;
            end
        end
    end

    partitionOrderedNodes = sort(partitionOrderedNodes);
    AttrWeights = ones(1,size(AttrTimet,2))/size(AttrTimet,2);

    Entropy = 0;
    dataCell = cell(size(partition,1),1);
    commsCounts = zeros(size(partition,1),1);
    for i=1:size(partition,1)
        row = nonzeros(partition(i,:));
        %row(isnan(row))=[];
        dataCell{i}=row;
        commsCounts(i)=size(row,1);
    end

    commsVals = 1:size(partition,1);

    mOrig = 1;
    
    posNodes = posNodes - 1;
    Attrs = zeros(posNodes,mOrig);
    m = size(AttrTimet,2);%[4]  %17052023 changed cambiado
    m_same = 0;
    if m_same == 0
        for l = 1:mOrig
            for i = 1:m(l)
                for j = 1:posNodes                    
                    if AttrTimet(j,i) > 0
                        Attrs(j,l) = i;
                    end
                end
            end
        end
    end
    AttrTimet = Attrs;
    
    maxAttrVals = 0;
    for m=1:size(AttrTimet,2)
        [AttrsVals,y,z] = unique(AttrTimet(:,m));
        AttrsCounts = accumarray(z,1);
        if length(AttrsVals)>maxAttrVals
            maxAttrVals = length(AttrsVals);
        end

    end
    sumprobslog = zeros(size(AttrTimet,2),1);
    probs = zeros(size(AttrTimet,2),maxAttrVals,length(commsVals));                      
    probslog = zeros(size(AttrTimet,2),length(commsVals));
    for m = 1:size(AttrTimet,2)
        [AttrsVals,y,z] = unique(AttrTimet(:,m));
        AttrsCounts = accumarray(z,1);
        k = 1;
        for commPos = 1:size(partition,1)
            comm = nonzeros(partition(commPos,:));
            templist = zeros(1,length(comm));
            posTempList = 1;
            for j=1:length(comm)
                templist(posTempList) = AttrTimet(find(partitionOrderedNodes==comm(j)),m);
                posTempList = posTempList + 1;
            end
            [AttrsCommVals,y,z] = unique(templist);
            AttrsCommCounts = accumarray(z,1);
            %disp(AttrsCommCounts)
            %disp(AttrsCommVals)
            %disp(AttrsVals)
            reps = 0;
            for valAttrIdx=1:length(AttrsVals)
                valtemp=ismember(AttrsCommVals,AttrsVals(valAttrIdx));
                idx = nan;
                for i = 1:length(valtemp)
                    if valtemp(i) == true
                        idx = i;
                    end
                end
                if ~isnan(idx)
                    probs(m,valAttrIdx,k) = AttrsCommCounts(idx)/commsCounts(k);
                else
                    probs(m,valAttrIdx,k) = 0;
                end

                if probs(m,valAttrIdx,k) > 0 
                    probslog(m,k) = probslog(m,k) -probs(m,valAttrIdx,k)*log2(probs(m,valAttrIdx,k));
                else
                    probslog(m,k) = probslog(m,k) + 0;
                end
                
                reps = reps +1;
            end
        k = k + 1;
        end
    end

    for  m = 1:size(AttrTimet,2)
        for k = 1:length(commsVals)    
            sumprobslog(m) = sumprobslog(m) + probslog(m,k)*commsCounts(k)/sum(commsCounts);
        end
        Entropy = Entropy + sumprobslog(m)*AttrWeights(m);
    end


end
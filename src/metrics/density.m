function Density = density(V,A)

numComms = unique(V);
partition = zeros(size(numComms,1),size(V,1));
k = ones(size(numComms,1),1);

for i = 1:size(V,1)
    for j = 1:size(numComms,1)
        if V(i) == numComms(j)
            partition(j,k(j)) = i;
            k(j) = k(j) + 1;
        end
    end
end

Density = 0;
for j = 1:size(numComms,1)
    Density = Density + numEdges(A(partition(j,partition(j,:)>0),partition(j,partition(j,:)>0)));
end
Density = Density/numEdges(A);

end
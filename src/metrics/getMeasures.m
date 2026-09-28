function [Jaccard,Precision,Sensitivity,Specificity,RandIndex,AdjustedRandIndex] = getMeasures(A,B)

% INPUT
% 
%      A    :   Community partition of graph A *
%      B    :   Ground truth
% 
%      * A and B are N-length vectors, where each i-th element is the integer 
%        labeling the k-th community to which node i-th was assigned.
%        
%        
% OUTPUT
% 
%      Specificity
%      

% ------------------------------------------------------------------------------------------------------------------------------------------------------------
if nargin < 2
    error('One of the two inputs is missing !!!')
end
% ASSURE A; B INTEGERS!        
N  = numel(A);
TP = 0;
FN = 0;
FP = 0;
TN = 0;

for i=1:N
    for j=i+1:N
       TP = TP + sum(A(i)==A(j) && B(i)==B(j));
       TN = TN + sum(A(i)~=A(j) && B(i)~=B(j));
       FP = FP + sum(A(i)==A(j) && B(i)~=B(j));
       FN = FN + sum(A(i)~=A(j) && B(i)==B(j));
    end
end

Jaccard = TP/(TP+FN+FP);
Precision = TP/(TP+FP);
Sensitivity = TP/(TP+FN);
Specificity = TN/(TN+FP);
RandIndex = (TP+TN)/(TP+TN+FP+FN);
AdjustedRandIndex = (2*(TP*TN-FP*FN))/((TN+FN)*(FN+TP)+(TN+FP)*(FP+TP));


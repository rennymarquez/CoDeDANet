%Taken from https://www.mathworks.com/matlabcentral/fileexchange/62974-getnmi-a-b

function VI = getVI(A,B)
if nargin < 2
    error('One of the two inputs is missing !!!')
end
% ASSURE A; B INTEGERS!        
N  = numel(A);
Ca = max(A);
Cb = max(B);
IUV = zeros(Ca*Cb,1);
HU = zeros(Ca,1);
HV = zeros(Cb,1);
n1_k = 0;
for i = 1:Ca%1:unique(A)
    
    N_idot   = sum(A==i);
    HU(i) = N_idot / N * log(N_idot/N);
    
   for j = 1:Cb%unique(B) 
       
       n1_k = n1_k + 1;
       
       N_dotj = sum(B==j);
       N_ij   = sum(((A==i) + (B==j))==2);
       
       if N_ij == 0
           IUV(n1_k) = 0;
           HUV(n1_k) = 0;
           HUgV(n1_k) = 0;
           HVgU(n1_k) = 0;
       else
           IUV(n1_k) = N_ij / N * log( (N_ij*N)/(N_idot*N_dotj)  );
           HUV(n1_k) = N_ij / N * log( (N_ij/N));
           HUgV(n1_k) = - N_ij / N * log( (N_ij)/(N_dotj)  );
           HVgU(n1_k) = - N_ij / N * log( (N_ij)/(N_idot)  );
       end
       
       HV(j) = N_dotj / N * log(N_dotj/N);
       
   end
end

VI = sum(HUgV)+sum(HVgU);

function N=round_sf(X,SF)
%Use this function to round to a specified # of significant figures
%(part of the discretizing step)

N= num2str(X,SF);
N= str2num(N);
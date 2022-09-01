function [T,E]=hmm_MLE_V3(obs,states)
%this function calculates the transition and emission probability matrices
%of an hmm given the states and observations using a simple maximum likelihood solution

%initialization
seq_len = length(obs);

unique_obs = unique(obs);
unique_states = unique(states);
num_obs = max(unique_obs);
num_states = max(unique_states);

T = zeros(num_states);
E = zeros(num_states, num_obs);

% do the counts for the transition in the states
for i = 1:seq_len-1
    T(states(i),states(i+1)) = T(states(i),states(i+1)) + 1;
end

%count the emissions
for j = 1:seq_len
    E(states(j),obs(j)) = E(states(j),obs(j)) + 1;
end

%Let's pad the transition and emission probabilities if we have a zeros
[a,b]=size(T);
[c,d]=size(E);

pad_=10e-5;
for q=1:a
    for w=1:b
        if T(a,b)==0, T(a,b)=pad_; end
    end
end

for o=1:c
    for p=1:d
        if E(o,p)==0, E(o,p)=pad_; end
    end
end

%get the norm factors
T_norm = sum(T,2);
E_norm = sum(E,2);

% if we don't have any values then give 0's
T_norm(T_norm == 0) = -inf;
E_norm(E_norm == 0) = -inf;

% normalize to get the probabilities
T = T./repmat(T_norm,1,num_states);
E = E./repmat(E_norm,1,num_obs);
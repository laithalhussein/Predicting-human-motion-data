function P_hidden=fb_alg(obs,T,E)
%This is the forward-backward algorithm

% This function will calculate the probability of a hidden state ocurring
% given all the observations in "obs" (i.e. P(state at step i = t | obs), referred to as the
% posterior probability).

num_states=size(T,1);
num_obs=size(E,2);

% add an extra observation to make the algorithm smoother at the intial point
obs =[num_obs+1,obs];
L = length(obs);

% Now we do the forward algorithm in proper, but use a scaling factor S to deal with numerically unstable results
fstate = zeros(num_states,L);
fstate(1,1) = 1;  % assume that we start in state 1
S=zeros(1,L);
S(1)=1;
for c = 2:L
    for state = 1:num_states
        fstate(state,c) = E(state,obs(c)).*(sum(fstate(:,c-1).*T(:,state))); %calculate the forward part
    end
    % scale factor normalizes sum(fstate,c) to be 1
    S(c)= sum(fstate(:,c));
    fstate(:,c)= fstate(:,c)./S(c);
end

%now do the analogous case for the backward part
bstate = ones(num_states,L);
for c = L-1:-1:1
    for state = 1:num_states
      bstate(state,c) = (1/S(c+1)) * sum(T(state,:)'.* bstate(:,c+1) .* E(:,obs(c+1))); 
    end
end

P_hidden = fstate.*bstate; %The final posterior

% get rid of the column that we stuck in to deal with the intial values
P_hidden(:,1) = [];

%if you're only interested in updating the future predictions, you can
%just return the posterior of the current state, as follows:

%P_hidden=P_hidden(:,end);

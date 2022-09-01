function hs=get_hidden_state_V2(observation,steps)
%This function will return the hidden states. In our case, we know the true
%hidden states come from the observations themselves--they are simply
%future observations

% steps is how many points in the future we want to predict

%steps=15; 
cc=1;
hs=zeros(length(observation)-(steps-1),1); %hidden states
for i=steps:length(observation)
    hs(cc)=observation(i); 
    cc=cc+1;
end
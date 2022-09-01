function [seq,table]=assign_state(data)

%this function will essentially discretize our data so that we can use it for an hmm
%We will assign arbitrary states (in the form of integers) to each unique
%observation that we observe in the data. The number of unique observations
%is determined from our desired resolution, which here is specified by the
%number of significant figures, so we do the following:
%1) Round our observations to a specified number of significant figures
%2) Assign states to these new observations
%3) Find the emission and transition probabilities from these
%4) Calculate the posterior to give the hidden state
%This function takes care of #1 and #2

N=length(data);

%first round the data to a desired resolution
sf=3; %# of sig figs-the bigger this is, the larger the number of unique observations, and the larger the hmm parameters will be

new_data=data*0;
for i=1:N
    new_data(i)=round_sf(data(i),sf); %round_sf actually does the rounding...
end

%next we will assign integers to represent the distinct states in our sequence
state=1; %value that represents the first observation

%Need to be careful in assigning states here because the data need not be monotonic
seq=zeros(N,1);
old_values=[];
c=1;
for j=1:N
    value_=new_data(j);
    if sum(ismember(old_values,value_))==0 %only assign a new state to an observation that hasnt been seen before
        value_ind=find(new_data==value_);
        seq(value_ind)=state;
        state=state+1; %Update the state
        old_values(c)=value_; %save what we've already observed
        c=c+1;
    end
end

[obs,obs_ind]=unique(new_data); %
table=[obs,seq(obs_ind)]; %table is a map between the actual observations and the states, which we need to convert between the two
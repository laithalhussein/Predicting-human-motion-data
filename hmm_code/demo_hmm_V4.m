close all;
home;
if ~exist('data')
    error('Error: The data is not loaded in the workspace');
end
clearvars -except data;

%Unfortunately, we have found that calculating the posterior in the context
%of our problem is unrealistic, and even with a resolution of 3 sig figs,
%the transition and emission probabilities blow up very quickly, and are
%STILL not enough to account for all possible unique states/observation.
%However, to demonstrate that our implementation is sound, we will demo our
%algorithm on a contrived, unrealistic example

%Let us calculate the error b/w our hmm prediction and the true hidden
%state by running the following simulation multiple times:

iter=50;
error_hmm=zeros(iter,1);

for i=1:iter

    %We will sample only 2 trials, and then test on part of the actual samples
    %First let's get the data
    num_trials=2; %how many trials we want to sample
    
    sample_seq=[]; %preallocation would be too cumbersome given the different lengths of all trials
    
    %In a real scenario, we would train the hmm on a per subject basis, as
    %inspecting the data has shown that each person has their own movement
    %tendencies, and thus their own unique state space
    
    sub=1; %the actual subject shouldnt matter
    
    %Sample the data
    trial_sample=zeros(num_trials,1);
    ii=0;
    c=1;
    for k=1:num_trials+ii
        trial_num=randi([1,length(data{sub})],1,1);
        if sum(ismember(trial_sample,trial_num))==0
            trial=data{sub}{trial_num}.z0_;
            sample_{k}=trial(:,1); %sample only the x dimension
            sample_seq=[trial(:,1);sample_seq];
            trial_sample(c)=trial_num;
            c=c+1;
        else
            ii=ii+1;
        end
    end
    
    steps=15;
    
    %Next we will assign states to our data
    [observation,t]=assign_state(sample_seq);
    
    %Now that we have our observations (sequences), we will get the hidden states, which actually just come from the
    %observations themselves (future positions)
    [hs]=get_hidden_state_V2(observation,steps);
    
    % parse the data so the theoretical observations and hidden states are of
    % the same length (not actually necessary)
    observation_parse=observation(1:end-(steps-1));
    
    % Now we calculate the maximum likelihood estimation of the transition and emission probabilities
    [tr_,em_]=hmm_MLE_V3(observation_parse,hs);
    
    %Now let's test it on part of the data we trained on. The reason this can
    %work is because we know the state space of our test is the same as what we
    %trained on, so there's no reason to blow up our
    %emission/transition/posterior by training on a lot of data. This of course
    %is not realistic since a person's state could increase trial to trial.
    
    posterior_=fb_alg(assign_state(sample_{1})',tr_,em_); %Note that our implementation returns the posterior for ALL the states in the sequence, not just current state
    
    %Now let's find the states that corresponded to the largest probabilities
    [~,max_p]=max(posterior_);
    
    %Now we use the table we constructed in the beginning to map from the index
    %of states to the actual values
    estimated_hs=t(max_p,1);
    %Getting the true hidden state
    true_hs=get_hidden_state_V2(sample_{1},15);
    
    %Although we have the posterior for ALL the states, we're really only
    %interested in the last (current) state, so let's compare those estimated
    %and true values
    
    error_hmm(i)=true_hs(end)/1000-estimated_hs(length(true_hs))/1000;

end

%Now just plot the result
bar([2],[mean(error_hmm)]);
hold on;
errorbar([2],[mean(error_hmm)],[std(error_hmm)]);
set(gca,'XTickLabel',[' ','X data only',' ']);
ylabel('error in cm');
title('Average error of HMM prediction');
axis([1 3 (0-std(error_hmm)) (mean(error_hmm)+std(error_hmm)+2)]);



% this script will demo the Klaman Filter (KF)
% We will plot a Kalman Filter prediction for a random trial, and then
% calculate the average error of the kalman filter prediction from 2000
% randomly sampled trials
close all;
tic
home;
if ~exist('data')
    error('Error: The data is not loaded in the workspace');
end
clearvars -except data;

%First, let's just demonstrate the KF for a random trial
sample_subject=randi([1,length(data)],1,1); %sampling a random subject
sample_trial_num=randi([1,length(data{sample_subject})],1,1); %sampling a random trial
sample_trial=data{sample_subject}{sample_trial_num}.z0_; %getting the data
%Let's first run a version where we say we fully trust our observation (set
%the 3rd argument to 0)
dummy=kalman_xy_V2(sample_trial(:,1),sample_trial(:,2),0,1);
%Now look at a version where noise is added
dummy=kalman_xy_V2(sample_trial(:,1),sample_trial(:,2),1,1);

% Now, let's randomly sample, without replacement, 2000 trials from the
% data

num_trials=2000; %how many trials we want to sample

error_kf=zeros(num_trials,2); %preallocate array to hold error data


sub=randi([1,length(data)],1,1); %randomly sample a subject

trial_sample=zeros(num_trials,2); %make an array to keep track of the trials we've already sampled
ii=0;
c=1;
for k=1:num_trials+ii
    trial_num=randi([1,length(data{sub})],1,1);
    if sum(ismember(trial_sample,trial_num))==0
        trial=data{sub}{trial_num}.z0_;
        error_kf(k,:)=kalman_xy_V2(trial(:,1),trial(:,2),1,0); %We'll add noise just to look at the worst case scenario
        trial_sample(c)=trial_num;
        c=c+1;
    else
        ii=ii+1;
    end
end
%Now get the average mean and std
% errorx=mean(error_kf(:,1))/1000;
% stdx=std(error_kf(:,1))/1000;
% 
% errory=mean(error_kf(:,2));
% stdy=std(error_kf(:,2));
% % plot on a bar graph
% bar(1:2,[errorx,errory]);
% hold on;
% errorbar(1:2,[errorx,errory],[stdx,stdy],'.');
% set(gca,'XTickLabel',{'X Error','Y Error'});
% ylabel('error in cm');
% title('Average error of KF prediction of 2000 randomly sampled trials');
% toc
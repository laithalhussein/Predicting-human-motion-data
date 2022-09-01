% This is a function which, given the data "movedat", the set of
% coefficients "A", the desired forward delay "delay", and an array
% describing which subjects to test, will calculate the overall MSE "ee" of the
% prediction model, as well as an output array that records the individual MSE of
% each movement "e"

% the order of the model is automatically assumed by the number of
% coefficients in "A"

% AutoRegressive model

% model is the following:
% x(t+delta_t) = A(1)*x(t) + A(2)*x(t-dt) + ... + A(n)*x(t-(n-1))*dt)



function [ee,e] = MLP_filt_subjectlist(movedat,A,delay,subject_list) %,i1]
dt = 0.005; % sampling rate
delay_p = round((delay*1000)/(dt*1000));  % number of points equivalent to delay
disp(A);  % useful to spit out A when optimizing, each iteration will display changes in A
AA= flipud(A);
count=0;
N=0; for aa = 1:length(subject_list), kk1 = subject_list(aa); N=N+length(movedat{kk1}); end
e = zeros(N,1);


for aa = 1:length(subject_list); % going through participants
    kk = subject_list(aa);
    for bb = 1:length(movedat{kk}); % going through trials
        pos = (movedat{kk}{bb}.z0)/100; % filtered data
        pos_ = (movedat{kk}{bb}.z0_)/100; pos_=pos_(length(A)+delay_p:end,:); % unfiltered data, also cutting the data
        posf = zeros(size(pos));
        posf(:,1) = filter(AA,1,pos(:,1));  % using the filter function to carry out the AR model through each successive point
        posf(:,2) = filter(AA,1,pos(:,2)); 
       % taking out the first few points (which can't be used due to the 
       % minimum number of points needed to calculate the first predicted 
       % point)
        posf=posf(length(A):end-delay_p,:); 
        count=count+1;  e(count)=nansum(nanmean((pos_-posf).^2,1),2); % calculating MSE
    end     
end
 ee = double(nanmean(e));
 %keyboard   
 disp(ee)



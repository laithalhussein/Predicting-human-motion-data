% This function is identical to the MLP_filt_subjectlist function, except
% instead of calculating the MSE, it calculates the AIC

% AutoRegressive Model

% model is the following:
% x(t+delta_t) = A(1)*x(t) + A(2)*x(t-dt) + ... + A(n)*x(t-(n-1))*dt)

function [AICx,AICy] = MLP_filt_subjectlist_AIC(movedat,A,delay,subject_list,filt_window)
dt = 0.005;
delay_p = round((delay*1000)/(dt*1000));
disp(A);
AA= flipud(A);
count=0;
N=0; for aa = 1:length(subject_list), kk1 = subject_list(aa); N=N+length(movedat{kk1}); end
Ax = zeros(N,1);
Ay = zeros(N,1);
for aa = 1:length(subject_list);
    kk = subject_list(aa);
    for bb = 1:length(movedat{kk});
        pos = (movedat{kk}{bb}.z0(filt_window:end,:))/100;
        cutoff = filt_window+length(A)+delay_p-1;
        pos_ = (movedat{kk}{bb}.z0_)/100; pos_=pos_(cutoff:end,:);
        posf = zeros(size(pos));
        posf(:,1) = filter(AA,1,pos(:,1)); 
        posf(:,2) = filter(AA,1,pos(:,2)); 
        posf=posf(length(A):end,:);
        posfx = posf(1:end-delay_p,1);
        posfy = posf(1:end-delay_p,2);
        
        count=count+1;
        Ax(count) = log((1/(length(posfx)))*(pos_(:,1)-posfx)'*(pos_(:,1)-posfx))+2*length(A)/length(posfx);
        Ay(count) = log((1/(length(posfy)))*(pos_(:,2)-posfy)'*(pos_(:,2)-posfy))+2*length(A)/length(posfy);
    end     
end
 AICx = double(mean(Ax));
 AICy = double(mean(Ay));





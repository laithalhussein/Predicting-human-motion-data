%%%%%%%%%%%%%%% FUNCTION TO DETERMINE THE ORDER OF THE AR(P) %%%%%%%%%%%%%%% MODEL%%%%%%%%%%%%%%%%%%

% This function is designed to calculate the MSE and AIC values for x and y
% coordinates. 

% It gives us an estimate of, for a given delay, how well a certain AR
% model is predicting the future points.

% the inputs to this function are the data containing the movements. There
% is also an input for changing the amount of data that will be tested
% (used mostly for debugging and running small subsets of the data)


function [MSEx,MSEy,AICx,AICy] = determine_ar_order(data,test_amount)


% data=load('C:\Users\rishi_000\Documents\Code for visual lag experiment\prediction algorithms');

filt_window = 15;       % this is the filtering window size used on the filtered data
delay = 0.075;          % as an example, a 75 ms delay
delay_p = round(delay/0.005); % calculating the corresponding number of points associated with the delay
p_order=[2:20];         % want to test AR model orders from 2 until 20
fun = @(A,points)MLPdegree_check_filt(points,A,delay); %define the function to be minimized
cnt = 0;

% Now we are just initializing variables in order to run the code more quickly
N=0; for aa = 1:length(data)-test_amount, N=N+length(data{aa}); end
MSEx = zeros(length(p_order),N);
MSEy = zeros(length(p_order),N);
AICx = zeros(length(p_order),N);
AICy = zeros(length(p_order),N);

for i=1:length(data)-test_amount % this loops through all participants
    subject=data{i};
    for j=1:length(subject) %then loop through all movements from each participant
        cnt=cnt+1;
        trial=subject{j}.z0/100; % this calls up the filtered position data
        filt_xpos=trial(filt_window:end,1); % remove NaNs at the beginning of movement data (due to filtering window)
        filt_ypos=trial(filt_window:end,2);
        unfilt_xpos = subject{j}.z0_(:,1)/100; % this calls up the unfiltered position data (this needs to be used to calculate error, since it is the actual xy points)
        unfilt_ypos = subject{j}.z0_(:,2)/100;
            for q=1:length(p_order) % now we loop through each order of the AR model
                x0=[[(delay_p+1), -delay_p], zeros(1,(p_order(q)-2))];
                % cutting off the first points of the movement, since the 
                % AR model needs a certain number of initial points before 
                % calculating the first predicted point
                cutoff = filt_window+p_order(q)-1+delay_p; 
                x_cut = unfilt_xpos(cutoff:end);
                y_cut = unfilt_ypos(cutoff:end);
                
                % Now we use lsqcurvefit to optimize the coefficients of
                % the AR model. The number of parameters to optimize
                % depends on the order of the AR model being tested
                opt_Ax = lsqcurvefit(fun,x0,filt_xpos,x_cut); 
                opt_Ay = lsqcurvefit(fun,x0,filt_ypos,y_cut);
                
                % Using those optimized coefficients we calculate what the
                % predicted set of points were
                [posfx] = MLPdegree_check_filt(filt_xpos,opt_Ax,delay);
                [posfy] = MLPdegree_check_filt(filt_ypos,opt_Ay,delay);
                
                % Finally we calculate and save, for a given model order,
                % what the MSE and AIC values were
                MSEx(q,cnt) = mean((x_cut-posfx).^2);
                MSEy(q,cnt) = mean((y_cut-posfy).^2);
                AICx(q,cnt) = log((1/(length(posfx)))*(x_cut-posfx)'*(x_cut-posfx))+2*p_order(q)/length(posfx);
                AICy(q,cnt) = log((1/(length(posfy)))*(y_cut-posfy)'*(y_cut-posfy))+2*p_order(q)/length(posfy);
            end
    end
end

% Save all the data
save('order_comparison.mat','MSEx','MSEy','AICx','AICy')             
                
                
                
            
        
    



end
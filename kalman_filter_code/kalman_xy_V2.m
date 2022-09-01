
function er=kalman_xy_V2(xp,yp,noise,PL)
x = zeros(4,1); %our state update vector-this will include position and velocity (it is also our intial state)
P = eye(4)*1000; % initial uncertainty for covariance matrix

N = length(xp);
true_x = xp; %renaming it for clarity
true_y = yp;
if noise==1
    observed_x = true_x + 0.05*rand(1,N)*true_x; %add some noise if we dont trust the data
    observed_y = true_y + 0.05*rand(1,N)*true_y;
else
    observed_x = true_x;
    observed_y = true_y;
end

result = []; %append results here
R = 0.01^2; %this is the measurement noise
pos=[observed_x,observed_y];
for meas=1 :N
    [x, P] = kalman_xy(x, P, pos(meas,:), R);
    result=[x(1:2),result];    
end
if PL==1 %plot the result if desired
    figure;
    plot(observed_x/1000, observed_y/1000, 'ro','Displayname','Observed Data')
    hold on;
    plot(result(1,:)/1000, result(2,:)/1000, 'g.','Displayname','Kalman Filter Prediction')
    axis equal;
    legend('show')
    xlabel('x position (cm)')
    ylabel('y position (cm)');
    title('Kalman filter prediction of the cursor')
    hold off;
end

er=sum(abs((flipud(result)/1000)'-(pos/1000))); %this is the error
end


function [x,P]=kalman_xy(x, P, measurement, R)
              
motion=zeros(4,1); %if we had an external disturbance afecting our system, it would go here (affecting the state vector)
Q=eye(4); %noise associated with motion

F = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1]; %Function for the next state, i.e. x prime = F*x
H = [1 0 0 0; 0 1 0 0]; %measurement function i.e. position= H*x
[x,P]= kalman(x, P, measurement, R, motion, Q, F,H);
end

function [x,P]=kalman(x, P, measurement, R, motion, Q, F, H)
    %First we update x/P based on the measurement  
   % Our 'belief' will be the distance between the measure and current
   % position
    y = measurement' - H * x;
    S = H * P * H' + R; % residual convariance
    K = P * H' * inv(S);    % Kalman gain
    x = x + K*y;
    [sh_,~]=size(F);
    I = eye(sh_); % identity matrix
    P = (I - K*H)*P;

    % PREDICT x, P based on motion
    x = F*x + motion;
    P = F*P*F' + Q;
end





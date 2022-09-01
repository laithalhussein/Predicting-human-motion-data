%% Plotting routine for video (show actual and predicted points one at a time)
% this function was created to make the "real"-time plot seen in the video.

% by putting the program in debug mode in the for loop which plots each
% point, we can then have the program plot the measure point at t=t and
% also then show the predicted point given the current set of points at
% t=t+delta



% for 50 ms forward prediction
clear flag;
close all;
p = 2; % participant (randomly chosen)
tr = 100; % trial number (randomly chosen)
A = CO(2,:,1); % taking optimized coefficients for 50 ms delay from generated data
posx = dat{p}{tr}.z0_(:,1); posy = dat{p}{tr}.z0_(:,2); % unfiltered points
px = dat{p}{tr}.z0(:,1); % filtered positions to be used in prediction 
py = dat{p}{tr}.z0(:,2);
posfy = filter(A,1,py); posfx = filter(A,1,px); % predicted forward the filtered points using optimized coefficients
posfy(1:2) = nan; % removing the first two points (garbage points generated from using the filter function)
posfx(1:2) = nan;


figure(1); 
xlabel('X position (cm)','Fontsize',26);
ylabel('Y position (cm)','Fontsize',26);

title('AR(3) prediction','Fontsize',26)
set(gca,'Fontsize',26);
hold on;
shg
xlim([min(posfx/100)-1,max(posfx/100)+1]); xlabel('x-coordinate [cm]')
ylim([min(posfy/100)-1,max(posfy/100)+1]); ylabel('y-coordinate [cm]')

% for loop which can be paused, allowing sequential plotting of current
% point and future predicted point
for i = [3:length(posx)],

    xlim([min(posx/100)-1,max(posx/100)+1]); xlabel('x-coordinate [mm]')
    ylim([-0.3,0.2]); ylabel('y-coordinate [mm]')
   % ylim([min(posy/100),max(posy/100)]); ylabel('y-coordinate [mm]')
    plot(posx(i)/100,posy(i)/1000,'-ob');
    plot(posfx(i)/100,posfy(i)/1000,'.r'); 

end




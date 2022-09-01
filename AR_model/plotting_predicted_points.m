% plotting routine for showing predicted vs actual points for 10 ms delay
% and 100 ms delay (shown on poster and included in paper)

%load('fmove_ord3win15_clean.mat')
%dat = fmove_ord3win15_clean;
tr = 5;


A = CO(26,:,1); % taking previously calculated optimized coefficients for 10 ms delay
posx = dat{1}{tr}.z0_(:,1); posy = dat{1}{tr}.z0_(:,2);
posfy = filter(A,1,posy); posfx = filter(A,1,posx);
posfy(1:2) = nan;
posfx(1:2) = nan;
figure; plot(posx/100,posy/100,'-bo'); hold on; plot(posfx/100,posfy/100,'-ro');
title('Forward Delay = 10 ms')
xlabel('x-coordinate [cm]')
ylabel('y-coordinate [cm]')
legend('Actual Movement','Predicted Movement')
grid on
axis equal

A = CO(26,:,3); % taking previously calculated optimized coefficients for 100 ms delay
posx = dat{1}{tr}.z0_(:,1); posy = dat{1}{tr}.z0_(:,2);
posfy = filter(A,1,posy); posfx = filter(A,1,posx);
posfy(1:2) = nan;
posfx(1:2) = nan;
figure; plot(posx/100,posy/100,'-bo'); hold on; plot(posfx/100,posfy/100,'-ro');
title('Forward Delay = 100 ms')
xlabel('x-coordinate [cm]')
ylabel('y-coordinate [cm]')
legend('Actual Movement','Predicted Movement')
grid on
axis equal

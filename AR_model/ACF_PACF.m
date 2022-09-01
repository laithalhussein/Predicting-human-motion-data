h1=figure(1);
h2=figure(2);
c=1;
d=1;
for i=1:length(data)-15
    sub=data{i};
    ind=randi([1,length(sub)],1,2);
    temp1=sub{ind(1)}.z0_;
    temp2=sub{ind(2)}.z0_;
    xp1=temp1(:,1);
    xp2=temp2(:,1);
%     yp1=temp1(:,2);
%     yp2=temp2(:,2);
    figure(1);
    subplot(2,2,c)
    autocorr(xp1,length(xp1)-1)
    subplot(2,2,c+1)
    autocorr(xp2,length(xp2)-1)
    c=c+2;
    figure(2);
    subplot(2,2,d)
    parcorr(xp1)
    subplot(2,2,d+1)
    parcorr(xp2)
    d=d+2;
end
       
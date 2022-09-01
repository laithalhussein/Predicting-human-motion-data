%% This is a function which performs cross validation
% first, it optimizes the coefficients based on one participant's data
% (1-25), or all the participants' data.

% second, it uses these optimized coefficients to forward predict data from
% every other participant's data individually, (e.g., optimize my
% parameters from participant #1's data, test how well these coefficients
% perform when predicted participant #13's data).

% it also tests each set of coefficients on the entire data set

% finally, it repeats this procedure for 5 different AR model orders: 10,
% 50, and 100 ms

% the resulting [26x26x3] matrix of MSE values is set up as the following:

% [ participant over which coefficients were optimized, participant's data
% upon which said coefficients were tested, AR model order ]

% NOTE: row 26 uses coefficients OPTIMIZED over the entire dataset
% NOTE: column 26 contains MSE values from coefficients TESTED on the
%       entire dataset

%%%% Comparing optimizations from individual participants across the data
%%%% Version with AICx and AICy
tic;
d = dat;
del_values = [0.075]; % forward delay
orders = [1 2 3 4 5]; % orders to test
filt_window = 15; % filtering window used on data
ERR = zeros([26,26,length(del_values)]);
AICx = zeros([26,26,length(del_values)]);
AICy = zeros([26,26,length(del_values)]);

for zz = 1:length(orders),
    degree = orders(zz)+1;
    CO = zeros(26,degree);
    for aa = 1:length(del_values)
        del_steps=round(del_values(aa)/0.005);
        x0=[[(del_steps+1), -del_steps], zeros(1,(degree-2))]; % initial guess based on rearranging AR model parameters to fit basic kinematic equation with position and velocity
        CO(26,:) = x0;
        f = @(x0)MLP_filt_subjectlist(d,x0,del_values(aa),[1:25]); % define function to be optimized with fminunc (quasi-newton method)
        [x,fval] = fminunc(f,x0); % calling optimization

        CO(26,:) = x; % coefficients optimized over entire dataset
        ERR(26,26,zz) = fval; %MSE from: coefficients from entire dataset, tested against entire dataset
        [AICx(26,26,zz),AICy(26,26,zz)] = MLP_filt_subjectlist_AIC(d,x,del_values(aa),[1:25],filt_window); %AIC from: coefficients from entire dataset, tested against entire dataset
        x0_all = x;

    %     x0_all = [3 -2 0];
        for bb = 1:25; % now we loop through each subject's data individually
            str = sprintf('          *********************************************************************    The participant being optimized is %d',bb);
            disp(str);
            ERR(26,bb,zz) = MLP_filt_subjectlist(d,x0_all,del_values(aa),bb); % MSE from: coefficients from entire data, tested against individual participants (bb)
            [AICx(26,bb,zz),AICy(26,bb,zz)] = MLP_filt_subjectlist_AIC(d,x0_all,del_values(aa),bb,filt_window); % AIC from: coefficients from entire data, tested against individual participants (bb)
            x0 = x0_all; %initial guess for individual participant optimization is optimal from entire dataset
            f = @(x0)MLP_filt_subjectlist(d,x0,del_values(aa),bb); %optimizing coefficients for one participant at a time
            [x,fval] = fminunc(f,x0);

            CO(bb,:)=x; % recording optimized coefficients from that one participant's data
            ERR(bb,bb,zz) = fval; % MSE from: coefficient from one participant, tested against same participant
            [AICx(bb,bb,zz),AICy(bb,bb,zz)] = MLP_filt_subjectlist_AIC(d,x,del_values(aa),bb,filt_window); % AIC from: coefficient from one participant, tested against same participant
            optA = x;
            ERR(bb,26,zz) = MLP_filt_subjectlist(d,optA,del_values(aa),[1:25]); % MSE from: coefficient from one participant, tested against entire dataset
            [AICx(bb,26,zz),AICy(bb,26,zz)] = MLP_filt_subjectlist_AIC(d,optA,del_values(aa),[1:25],filt_window); % AIC from: coefficient from one participant, tested against entire dataset
            subs = [[1:(bb-1)],[(bb+1):25]]; %list of subjects to go through individually

            for cc = 1:24;
                [ERR(bb,subs(cc),zz)] = MLP_filt_subjectlist(d,optA,del_values(aa),subs(cc)); % MSE from: coefficient from one participant (bb), tested against each other participant individually
                [AICx(bb,subs(cc),zz),AICy(bb,subs(cc),zz)] = MLP_filt_subjectlist_AIC(d,optA,del_values(aa),subs(cc),filt_window); % AIC from: coefficient from one participant (bb), tested against each other participant individually
            end

        end
    end
    COEFF_cellarray{zz} = CO; % save all the coefficients for each order (different sized matrices) into a cell array for later use if needed
    clear CO
end
toc
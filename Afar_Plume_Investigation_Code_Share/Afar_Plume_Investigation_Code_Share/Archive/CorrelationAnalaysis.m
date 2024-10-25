% Script to investigate the correlations between each of the 
% variables with specific interest interest in the correlation between the 
% Moho and other indicators and La/Sm with the geophyscial variables

% Written by Emma J. Watts on the 13th April 2023

clear all; clc; clf;
addpath('C:\Users\emmaj\Documents\PhD\Chapter_3\Modelling_Phil\EmmaWatts\2024_02_07_Pb_100replicates');
%% Prepping the data
% Load raw data
[AN,AT] = xlsread('data_phil_spline_longlat_dist_update_Ce_Pb_100km_Pb.xlsx'); % raw data
AN2 = AN(:,5:18); % Dropping the longitude and latitude values and distance to centre

%% Use Matlabs inbuilt function corrcoef - pearson correlation
%[R, P, RL, RU] = corrcoef(A) where R is a matrix of correlation coefficients 
% P is a matrix of P values (testing the null hypothesis), RU and RL are the 
% 95% confidence intervals of the upper and lower bounds respectively. 
[R, P, RL, RU] = corrcoef(AN2,'rows','pairwise'); 

% Analysis uses the whole dataset. The 'rows' and 'pairwise' only 
% removes the rows is NaN is present in the pairing of two columns. 
% I have done this to use the maximum amount of the data. 

% Results shows a strong correlation (i.e. R-square >0.6) for Latitude, 
% Ce/Pb and Vs40 and delta84 is almost 0.6

% if P <0.05 then the correlation is significant. This means texting the 
% null hypothesis that there is no relationship between the groups. 
% Whether we accept or reject the nulll hypthesis depends on what we set 
% the alpha value to be. It is often set to 0.05. If the p < a then we 
% reject the null hypothesis.
% The only correlations which are not significant are 207/204Pb (6) and Vs120 (17).

%% Making a plot to show the results of the corrleations between Moho and other variables
% Plot the R squared values as a coloured square and the Upper and lower as lines 
x = [1 2 3 4 5 6 7 8 9 10 11 12 13];
err = R(:,14)-RL(:,14) % difference for lower bounds
err2 = RU(:,14)-R(:,14);
errorbar(x, R(1:13,14),err(1:13), 'LineStyle','none','Marker','.', 'MarkerSize',10,'Color', 'k','linewidth', 1)
hold on
%variables = ['206Pb/204Pb', '207Pb/204Pb','208Pb/204Pb','Delta 207Pb/204Pb','Delta 208Pb/204Pb', '143Nd/144Nd', '87Sr/86Sr','Ce/Pb','La/Sm','delta Nb', 'Vs 40 km','Vs 80 km','Vs 120 km'];
scatter(x, R(1:13,14), 150, 'square','MarkerFaceColor', '#0072BD', 'MarkerEdgeColor','k');
hold on
scatter(1, R(1,14), 150, 'square','MarkerFaceColor', '#A2142F', 'MarkerEdgeColor','k');
scatter(3, R(3,14), 150, 'square','MarkerFaceColor', '#A2142F', 'MarkerEdgeColor','k');
scatter(4, R(4,14), 150, 'square','MarkerFaceColor', '#A2142F', 'MarkerEdgeColor','k');
scatter(5, R(5,14), 150, 'square','MarkerFaceColor', '#A2142F', 'MarkerEdgeColor','k');
scatter(6, R(6,14), 150, 'square','MarkerFaceColor', '#A2142F', 'MarkerEdgeColor','k');
scatter(7, R(7,14), 150, 'square','MarkerFaceColor', '#A2142F', 'MarkerEdgeColor','k');
scatter(8, R(8,14), 150, 'square','MarkerFaceColor', '#A2142F', 'MarkerEdgeColor','k');
scatter(9, R(9,14), 150, 'square','MarkerFaceColor', '#A2142F', 'MarkerEdgeColor','k');
scatter(10, R(10,14), 150, 'square','MarkerFaceColor', '#A2142F', 'MarkerEdgeColor','k');
scatter(11, R(11,14), 150, 'square','MarkerFaceColor', '#A2142F', 'MarkerEdgeColor','k');
%scatter(x, RL(5:17,18), 200, '_', 'k');
%scatter(x, RU(5:17,18), 200, '_', 'k');
yline(0.7, '--',LineWidth=1);
yline(-0.7,'--',LineWidth=1);
xlim([0 14]);
ylim([-1 1]);
xticks(x)
xticklabels({'206Pb/204Pb', '207Pb/204Pb','208Pb/204Pb','143Nd/144Nd', '87Sr/86Sr','Ce/Pb','La/Sm','delta Nb', 'Vs 40 km','Vs 60 km','Vs 80 km','Vs 100 km','Vs 120 km'})
xtickangle(90)
set(gca,'FontSize',12,'box','on','linewidth',0.8);
ylabel('Pearson Correlation Coefficent','FontSize',16,'FontWeight','bold')
xlabel('Variable','FontSize',16,'FontWeight','bold')
grid on

% change the colours of the squares if the significance if p>0.05

%% Investigating the correlation between the La/Sm and Geophysical variables. 
% Load raw data
[BN,BT] = xlsread('data_phil_spline_longlat_dist_update_all_geophysics.xlsx'); % raw data
BN2 = BN(:,3:28); % Dropping the longitude and latitude values % Geophysical data starts at column 13

[R, P, RL, RU] = corrcoef(BN2,'rows','pairwise');   % La/Sm is in row 11. 
EmMarker = {'o','square','diamond','^','v','>','<','+','x','*'}
%subplot(2,2,1) %subplot showing La/Sm with Vs at different depths
for i=1:3
scatter(BN2(:,11), BN2(:,21+i), 100,'filled','marker', EmMarker(i), 'ColorVariable', pClr(i),'MarkerEdgeColor','k')
hold on
end
legend('Vs @ 100 km, R^{2} = -0.13', 'Vs @ 110 km, R^{2} = -0.16', 'Vs @ 120 km, R^{2} = -0.20')
box on, grid on,
xlabel('La/Sm','FontSize',16,'FontWeight','bold')
ylabel('Shear Velocity','FontSize',16,'FontWeight','bold')
ylim([3.96 4.14])
set(gca,'FontSize',13,'box','on','linewidth',0.8);
grid on


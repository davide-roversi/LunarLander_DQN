function [] = f_rewards_plot(episodeRewardCell, averageRewardCell, variable, settings)

% Retrieve nominal data for combined plot
load(pwd + "/SimOut_Data/trainingStats_nominal.mat", 'trainingStats');
episodeReward_nominal = trainingStats.EpisodeReward;
averageReward_nominal = trainingStats.AverageReward;

% Plot episode reward
figure('Position',[300 70 600 400]) % 
title('Episode rewards as function of update frequency')
hold on
grid on
episodes = 0 : 1 : length(episodeReward_nominal)-1;
plot(episodes, episodeReward_nominal, 'LineWidth', 2, 'DisplayName', "Nominal" )
for i = 1:length(episodeRewardCell)
    episodes = 0 : 1 : length(episodeRewardCell{i})-1;
    plot(episodes, episodeRewardCell{i}, 'LineWidth', 2, 'DisplayName', "f_{update} = " + num2str(variable(i)))
end
xlabel('Episodes [-]')
ylabel('Episode rewards [-]')
legend('Location','northeast' )
%xlim([episodes(1), episodes(end)])
ylim([-150, 200])
set(gca,'fontsize', 15)
hold off

% Save plot in specified directory
if settings.saveResults == true
    saveas(gcf, pwd + "/SimOut_Media/episodeRewardPlot_" + settings.plot_reward_filename);
end

% Plot average reward
figure('Position',[300 70 600 400]) % 
title('Average rewards as function of update frequency')
hold on
grid on
plot([0, 1500], [70, 70], 'g--', 'LineWidth', 1.5, 'DisplayName', "Reward threshold" )
episodes = 0 : 1 : length(averageReward_nominal)-1;
plot(episodes, averageReward_nominal, 'LineWidth', 2, 'DisplayName', "Nominal" )
for i = 1:length(averageRewardCell)
    episodes = 0 : 1 : length(averageRewardCell{i})-1;
    plot(episodes, averageRewardCell{i}, 'LineWidth', 2, 'DisplayName', "f_{update} = " + num2str(variable(i)))
end
xlabel('Episodes [-]')
ylabel('Average rewards [-]')
legend('Location','northeast' )
%xlim([episodes(1), episodes(end)])
ylim([-150, 200])
set(gca,'fontsize', 15)
hold off

% Save plot in specified directory
if settings.saveResults == true
    saveas(gcf, pwd + "/SimOut_Media/averageRewardPlot_" + settings.plot_reward_filename);
end

end
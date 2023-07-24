function [] = f_rewards_plot(trainingStats, settings)

% Define filename for plot
filename = "/SimOut_Media/training_rewards.jpg";
    
% Extract data and generate timeseries
episodeReward = trainingStats.EpisodeReward;
averageReward = trainingStats.AverageReward;
projectedReward = trainingStats.EpisodeQ0;
t = 0 : 1 : (length(episodeReward) - 1 );

% Plot stuff
figure('Position',[300 70 600 400]) % 
title('Rewards in time')
hold on
grid on
plot(t, episodeReward, 'Color', [0.3010 0.7450 0.9330], 'LineWidth', 2, 'DisplayName', 'Episode Reward')
plot(t, averageReward, 'Color', [0 0.4470 0.7410], 'LineWidth', 2, 'DisplayName', 'Average reward (50 episodes)')
% plot(t, projectedReward, 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 2, 'DisplayName', 'Estimated reward')
xlabel('Episodes [-]')
ylabel('Reward values [-]')
legend('Location','northeast' )
xlim([t(1), t(end)])
ylim([-150, 200])
set(gca,'fontsize', 15)
hold off

% Save plot in specified directory
if settings.saveResults == true
    saveas(gcf, pwd + filename);
end

end
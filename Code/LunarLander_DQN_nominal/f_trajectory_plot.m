function [] = f_trajectory_plot(Y, T, settings)

% Check which case has been simulated
if settings.resultType == "training"
    if settings.plotBadTrajectory == true
        filename = "/SimOut_Media/training_badTrajectory.jpg";
    else
        filename = "/SimOut_Media/training_goodTrajectory.jpg";
    end
elseif settings.resultType == "simulation"
    if settings.plotBadTrajectory == true
        filename = "/SimOut_Media/sim_badTrajectory.jpg";
    else
        filename = "/SimOut_Media/sim_goodTrajectory.jpg";
    end
end

% Extract timeseries
t = 0 : settings.dt : (length(Y(1,:))*settings.dt - settings.dt );

% Plot stuff
figure('Position',[300 70 700 700]) % 

subplot(2,2,1)
title('Trajectory')
hold on
fill([settings.ground_nodes(1,:), settings.box_coordinates(1,3), settings.box_coordinates(1,4)], ...
     [settings.ground_nodes(2,:), settings.box_coordinates(2,3), settings.box_coordinates(2,4)], ...
     'k')
c = sqrt(Y(3,:).^2 + Y(4,:).^2);
plot([-settings.landing_pad_width/2, settings.landing_pad_width/2], [0, 0], 'r', 'LineWidth', 2)
scatter(Y(1,:), Y(2,:), 10, c, 'filled')
cbar = colorbar;
cbar.Label.String = "Vehicle velocity [m/s]";
colormap jet
xlabel('[m]')
ylabel('[m]')
set(gca,'fontsize', 15)
axis square
hold off

subplot(2,2,2)
title('Vehicle position in time')
hold on
grid on
plot([t(1), t(end)], [0, 0], 'k--', 'LineWidth', 1.5, 'DisplayName', 'Landing pad center')
plot(t, Y(1,:), 'r', 'LineWidth', 2, 'DisplayName', 'x_{vehicle}')
plot(t, Y(2,:), 'b', 'LineWidth', 2, 'DisplayName', 'y_{vehicle}')
xlabel('Simulation time [s]')
ylabel('Position [m]')
legend('Location','northeast' )
xlim([t(1), t(end)])
pbaspect([2 1 1])
set(gca,'fontsize', 15)
hold off

subplot(2,2,3)
title('Velocity as function of time')
hold on
grid on
plot(t, sqrt(Y(3,:).^2 + Y(4,:).^2), 'k', 'LineWidth', 1, 'DisplayName', 'v_{vehicle}')
plot([t(1), t(end)], [settings.v_limit, settings.v_limit], 'r--', 'DisplayName', 'v_{limit} for landing')
fill([t(1), t(end), t(end), t(1)], ...
     [0, 0, settings.v_limit, settings.v_limit], ...
     'green', ...
     'FaceAlpha', 0.2, ...
     'EdgeColor', 'none', ...
     'DisplayName', 'Acceptable region')
xlim([t(1), t(end)]);
ylim([0, 13]);
xlabel('Simulation time [s]')
ylabel('Vehicle velocity [m/s]')
legend('Location','best' )
pbaspect([2 1 1])
set(gca,'fontsize', 15)
hold off

subplot(2,2,4)
title('Thrust commands')
hold on
grid on
plot(t, T(1,:), 'b', 'LineWidth', 1, 'DisplayName', 'T_x')
plot(t, T(2,:), 'r', 'LineWidth', 1, 'DisplayName', 'T_y')
xlim([t(1), t(end)]);
ylim([-20000, 60000]);
xlabel('Simulation time [s]')
ylabel('Thrust [N]')
legend
pbaspect([2 1 1])
set(gca,'fontsize', 15)
hold off

% Save plot in specified directory
if settings.saveResults == true
    saveas(gcf, pwd + filename);
end

end
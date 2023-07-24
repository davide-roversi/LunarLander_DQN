function [] = f_trajectory_animation (Y, T, settings)

% Check which case has been simulated
if settings.resultType == "training"
    if settings.plotBadTrajectory == true
        filename = "/SimOut_Media/training_badTrajectoryAnimation.avi";
    else
        filename = "/SimOut_Media/training_goodTrajectoryAnimation.avi";
    end
elseif settings.resultType == "simulation"
    if settings.plotBadTrajectory == true
        filename = "/SimOut_Media/sim_badTrajectoryAnimation.avi";
    else
        filename = "/SimOut_Media/sim_goodTrajectoryAnimation.avi";
    end
end

if settings.saveResults ==  true
    % Extract timeseries
    t = 0 : settings.dt : (length(Y(1,:))*settings.dt - settings.dt );
    frames = length(t);
    
    % Initialize matrix of frames
    M_frames(frames) = struct('cdata',[],'colormap',[]);
    
    % Disable view for every frame
    figure('visible','off','position',[100 100 600 600]);
    
    % Draw terrain and background
    hold on
    fill([settings.ground_nodes(1,:), settings.box_coordinates(1,3), settings.box_coordinates(1,4)], ...
         [settings.ground_nodes(2,:), settings.box_coordinates(2,3), settings.box_coordinates(2,4)], ...
         'k');
    plot([-settings.landing_pad_width/2, settings.landing_pad_width/2], [0, 0], 'r', 'LineWidth', 2)
    fill(settings.shape_x + Y(1,1)*ones(1, length(settings.shape_x)), ...
         settings.shape_y + Y(2,1)*ones(1, length(settings.shape_y)), 'm')
    text(0.4*settings.box_coordinates(1,2), 0.95*settings.box_coordinates(2,3), "V_x = " + num2str(Y(3,1)) + " [m/s]", 'Color','white')
    text(0.4*settings.box_coordinates(1,2), 0.90*settings.box_coordinates(2,3), "V_y = " + num2str(Y(4,1)) + " [m/s]", 'Color','white')
    text(0.4*settings.box_coordinates(1,2), 0.85*settings.box_coordinates(2,3), "Altitude = " + num2str(Y(2,1)) + " [m]", 'Color','white')
    xlabel('[m]')
    ylabel('[m]')
    xlim([settings.box_coordinates(1,1), settings.box_coordinates(1,2)])
    ylim([settings.box_coordinates(2,1), settings.box_coordinates(2,3)])
    hold off
    M_frames(1)=getframe(gcf); % Save first frame in matrix
    closereq
    
    % Iterate every frame
    for frame=2:frames
        figure('visible','off','position',[100 100 600 600]);
        hold on
        fill([settings.ground_nodes(1,:), settings.box_coordinates(1,3), settings.box_coordinates(1,4)], ...
             [settings.ground_nodes(2,:), settings.box_coordinates(2,3), settings.box_coordinates(2,4)], ...
             'k');
        plot([-settings.landing_pad_width/2, settings.landing_pad_width/2], [0, 0], 'r', 'LineWidth', 2)
        if T(:, frame) == [0; settings.ActionSpace(2)]
            fill(settings.main_low_thrust_x + Y(1,frame)*ones(1, length(settings.main_low_thrust_x)), ...
                 settings.main_low_thrust_y + Y(2,frame)*ones(1, length(settings.main_low_thrust_y)), 'y')
        elseif T(:, frame) == [0; settings.ActionSpace(3)]
            fill(settings.main_high_thrust_x + Y(1,frame)*ones(1, length(settings.main_high_thrust_x)), ...
                 settings.main_high_thrust_y + Y(2,frame)*ones(1, length(settings.main_high_thrust_x)), [0.8500 0.3250 0.0980])
        elseif T(:, frame) == [settings.ActionSpace(4); 0]
            fill(settings.left_thrust_x + Y(1,frame)*ones(1, length(settings.left_thrust_x)), ...
                 settings.left_thrust_y + Y(2,frame)*ones(1, length(settings.left_thrust_y)), 'y')
        elseif T(:, frame) == [settings.ActionSpace(5); 0]
            fill(settings.right_thrust_x + Y(1,frame)*ones(1, length(settings.right_thrust_x)), ...
                 settings.right_thrust_y + Y(2,frame)*ones(1, length(settings.right_thrust_y)), 'y')
        end
        fill(settings.shape_x + Y(1,frame)*ones(1, length(settings.shape_x)), ...
             settings.shape_y + Y(2,frame)*ones(1, length(settings.shape_y)), ...
             'm', 'EdgeColor', 'white')
        text(0.4*settings.box_coordinates(1,2), 0.95*settings.box_coordinates(2,3), "V_x = " + num2str(Y(3,frame)) + " [m/s]", 'Color','white')
        text(0.4*settings.box_coordinates(1,2), 0.90*settings.box_coordinates(2,3), "V_y = " + num2str(Y(4,frame)) + " [m/s]", 'Color','white')
        text(0.4*settings.box_coordinates(1,2), 0.85*settings.box_coordinates(2,3), "Altitude = " + num2str(Y(2,frame)) + " [m]", 'Color','white')
        xlabel('[m]')
        ylabel('[m]')
        xlim([settings.box_coordinates(1,1), settings.box_coordinates(1,2)])
        ylim([settings.box_coordinates(2,1), settings.box_coordinates(2,3)])
        hold off
        M_frames(frame)=getframe(gcf);
        closereq
    end
    
    video = VideoWriter(pwd + filename);
    video.FrameRate = 10;
    open(video)
    writeVideo(video,M_frames)
    close(video)
end
end

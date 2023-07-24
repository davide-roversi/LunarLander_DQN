function [Reward_vec] = f_rewards(Y, T, v_touchdown, settings)

%% Retrieve state at current timestep
x = Y(1);
y = Y(2);
vx = Y(3);
vy = Y(4);
c = Y(5);

%% Assign rewards
% Initialize rewards
R_side_engines = 0;
R_main_engine = 0;
R_exit_boundaries = 0;
R_crash_outside_landing_pad = 0;
R_crash_inside_landing_pad = 0;
R_landing = 0;

%%% PROPORTIONAL REWARDS %%%
R_proportional_dist = 0.001*(norm([settings.box_height, settings.box_width] - norm([x, y])));
R_proportional_speed = - 0.01*(norm([vx, vy]));

%%% NON TERMINATING EVENTS %%%
% Penalty for engines firing
if T(1) ~= 0
    R_side_engines = - 0.03;
end
if T(2) ~= 0
    R_main_engine = - 0.3;
end

%%% TERMINATING EVENTS %%%
% Penalty for exiting the box environment (+ termination condition)
if c == 2
    R_exit_boundaries = - 100;
end
% Penalty or reward for crashing or landing
if c == 1
    if x < -settings.landing_pad_width/2 || x > settings.landing_pad_width/2 
        R_crash_outside_landing_pad = - 50 - norm([v_touchdown(1), v_touchdown(2)]); 
    end
    if x >= -settings.landing_pad_width/2 && x <= settings.landing_pad_width/2 
        if norm([v_touchdown(1), v_touchdown(2)]) < settings.v_limit 
            R_landing = + 100;
        else
            R_crash_inside_landing_pad = - norm([v_touchdown(1), v_touchdown(2)]) ;
        end
    end
end

% Save everything in reward vector
Reward_vec = [R_proportional_dist;
              R_proportional_speed;
              R_side_engines;
              R_main_engine;
              R_exit_boundaries;
              R_crash_outside_landing_pad;
              R_crash_inside_landing_pad;
              R_landing];
 


end
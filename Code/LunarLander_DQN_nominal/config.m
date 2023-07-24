%%% -- Simulation, vehicle and environment variables -- %%%

%% Simulation

% True-False settings
settings.trainAgent = false; % If set to false, the agentToLoad file will be loaded and simulated directly
settings.runParallel = false; % Choose to use parallelization or not (only applies for plotFrequently = false and settings.trainAgent = true)
settings.plotBadTrajectory = false; % Choose whether to plot every given number of episodes or only at last episode (only applies for and settings.trainAgent = true)
settings.saveResults = true; % Choose whether to save plots and animations or not

% String settings
settings.mainDevice = 'cpu'; % Choose to run on cpu or gpu

% Numeric settings
settings.dt = 0.1; % [s] sample time (coincides with integration step size for Euler forward)
settings.episodes_before_plot = 30; % which initial trajectory gets plotted (only applies for plotBadTrajectory = true)
settings.total_max_episodes = 3000; % maximum episodes for agent training (only applies for plotBadTrajectory = false)

%% Vehicle
settings.m = 5000; % [Kg] vehicle mass
settings.shape_x = 0.6.*[-5, -4, -2, -2, 2, 2, 4, 5, 2, 2, -2, -2, -5]; % [m] x nodes of vehicle shape
settings.shape_y = 0.6.*[0, 0, 3.5, 2, 2, 3.5, 0, 0, 5, 7, 7, 5, 0]; % [m] y nodes of vehicle shape
settings.left_thrust_x = 0.6.*[-2, -4, -4, -2];
settings.left_thrust_y = 0.6.*[6, 5, 7, 6];
settings.right_thrust_x = 0.6.*[2, 4, 4, 2];
settings.right_thrust_y = 0.6.*[6, 5, 7, 6];
settings.main_low_thrust_x = 0.6.*[0, 1, -1, 0];
settings.main_low_thrust_y = 0.6.*[0, 2, 2, 0]; 
settings.main_high_thrust_x = 0.6.*[0, 1, -1, 0];
settings.main_high_thrust_y = 0.6.*[-1.5, 2, 2, -1.5]; 
settings.ActionSpace = [0, 22000, 32000, 9000, -9000]; 
                  % [N] four possible actions: [nothing, main engine low, main engine high, left engine, right engine]
settings.v_limit = 2; % [m/s] limit value for touchdown speed (as norm of vx and vy at touchdown)

%% Environment
settings.g = 1.62; % [m/s^2] gravitational acceleration
settings.box_width = 50;
settings.box_height = 50;
settings.landing_pad_width = 10;
settings.landing_pad_altitude = 10;
settings.box_coordinates = [-settings.box_width/2, ...
                            settings.box_width/2, ...
                            settings.box_width/2, ...
                            -settings.box_width/2; ...
                           -settings.landing_pad_altitude, ...
                           -settings.landing_pad_altitude, ...
                           settings.box_height - settings.landing_pad_altitude, ...
                           settings.box_height - settings.landing_pad_altitude]; 
                           % First row are vertices x coords, second row are vertices y coords 

left_side_x = linspace(settings.box_coordinates(1,1), -settings.landing_pad_width/2, 4);
left_side_y = [-settings.landing_pad_altitude, 0.15*rand*settings.box_height, 0.15*rand*settings.box_height, 0];
right_side_x = linspace(settings.landing_pad_width/2, settings.box_coordinates(1,2), 4);
right_side_y = [0, 0.15*rand*settings.box_height, 0.15*rand*settings.box_height, -settings.landing_pad_altitude];
settings.ground_nodes = [left_side_x, right_side_x;
                         left_side_y, right_side_y];
                         % First row are x vertices, second row are y vertices








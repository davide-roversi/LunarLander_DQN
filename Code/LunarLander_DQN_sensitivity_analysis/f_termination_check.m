function [Y_new, v_touchdown] = f_termination_check(Y, settings)

%% Extract position from current state
x = Y(1);
y = Y(2);
vx = Y(3);
vy = Y(4);

%% Evaluate if the vehicle has made contact with the ground
y_impact = interp1(settings.ground_nodes(1,:), settings.ground_nodes(2,:), x);
if y < y_impact
    c = 1;
    y = y_impact;
elseif x < settings.box_coordinates(1,1) || x > settings.box_coordinates(1,2) || ...
       y < settings.box_coordinates(2,1) || y > settings.box_coordinates(2,3)
        c = 2;
else
    c = 0;
end

%% In case contact has been made, save touchdown speeds
if c == 0
    vx_touchdown = 0;
    vy_touchdown = 0;
elseif c == 1
    vx_touchdown = vx;
    vy_touchdown = vy;
elseif c == 2
    vx_touchdown = inf;
    vy_touchdown = inf;
end

%% Return updated state vector
Y_new = [x; y; vx; vy; c];
v_touchdown = [vx_touchdown, vy_touchdown];

end
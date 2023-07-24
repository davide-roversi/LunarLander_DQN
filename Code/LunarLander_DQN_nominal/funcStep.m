function [NextObs, Reward, IsDone, LoggedSignals, settings] = funcStep(Action, LoggedSignals, settings)

%% Retrieve variables from settings
ActionSpace = settings.ActionSpace;
m = settings.m;
g = settings.g;
dt = settings.dt; 

%% Retrieve current state
Y = LoggedSignals.State;
x = Y(1);
y = Y(2);
vx = Y(3);
vy = Y(4);
c = Y(5);

%% Extract current action
ChosenAction = Action;
if ChosenAction == ActionSpace(1)
    T = [0, 0]; % T = [Tx, Ty]
elseif ChosenAction == ActionSpace(2)
    T = [0, ChosenAction]; % T = [Tx, Ty]
elseif ChosenAction == ActionSpace(3)
    T = [0, ChosenAction]; % T = [Tx, Ty]
elseif ChosenAction == ActionSpace(4)
    T = [ChosenAction, 0]; % T = [Tx, Ty]
elseif ChosenAction == ActionSpace(5)
    T = [ChosenAction, 0]; % T = [Tx, Ty]
else
    error('Action is not within accepted values');
end
LoggedSignals.cumulativeThrust = [LoggedSignals.cumulativeThrust, T'];

%% Integrate equations of motion
if c == 0
    dxdt = vx;
    dydt = vy;
    dvxdt = T(1)/m;
    dvydt = T(2)/m - g;
    dcdt = 0;
else
    dxdt = 0;
    dydt = 0;
    dvxdt = 0;
    dvydt = 0;
    dcdt = 0;
end

dYdt = [dxdt; dydt; dvxdt; dvydt; dcdt];
Y = Y + dt.*dYdt;

%% Check terminal conditions
[Y_new, v_touchdown] = f_termination_check(Y, settings);
LoggedSignals.State = Y_new;
LoggedSignals.cumulativeState = [LoggedSignals.cumulativeState, Y_new];
LoggedSignals.velocityTouchdown = v_touchdown;
NextObs = LoggedSignals.State;

if Y_new(end) ~= 0
    IsDone = 1;
else
    IsDone = 0;
end

%% Compute total reward given new state
[Reward_vec] = f_rewards(Y_new, T, v_touchdown, settings);
Reward = sum(Reward_vec);
LoggedSignals.cumulativeReward = [LoggedSignals.cumulativeReward, Reward_vec];

end
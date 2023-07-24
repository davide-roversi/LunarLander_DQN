function [InitialObservation, LoggedSignals] = funcReset(settings)

% Generate initial state vector
x0 = 0.8*settings.box_coordinates(1,end);
y0 = 0.9*settings.box_coordinates(2,end);
vx0 = 0;
vy0 = 0;
c0 = 0;

% Return initial environment state variables as logged signal
LoggedSignals.State = [x0; y0; vx0; vy0; c0];
LoggedSignals.cumulativeState = [x0; y0; vx0; vy0; c0];
LoggedSignals.cumulativeReward = [0; 0; 0; 0; 0; 0; 0; 0];
LoggedSignals.cumulativeThrust = [0; 0];
InitialObservation = LoggedSignals.State;

end
function [scenariostring] = scenarios(scenario)

if scenario == 1,
    scenariostring = strcat('none');
elseif scenario == 2,
    scenariostring = strcat('sync');
elseif scenario == 3,
    scenariostring = strcat('random');
elseif scenario == 4,
    scenariostring = strcat('rotate');
elseif scenario == 5, %starting from source
    scenariostring = strcat('source');
elseif scenario == 6, % starting furthest from source
    scenariostring = strcat('furthest');
elseif scenario == 7,
    scenariostring = strcat('partial');
elseif scenario == 8,
    scenariostring = strcat('jembrana');
elseif scenario == 9,
    scenariostring = strcat('missKlung');
elseif scenario == 10,
    scenariostring = strcat('reactive1');
elseif scenario == 11,%used to be randrepeat
     scenariostring = strcat('reactive2');
elseif scenario == 12,
    scenariostring = strcat('missRand');
end

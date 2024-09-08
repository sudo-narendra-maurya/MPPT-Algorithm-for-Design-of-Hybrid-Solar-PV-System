function duty = MPPT_algorithm(vpv, ipv, delta)
    % MPPT Algorithm: Incremental Conductance Method
    % Inputs:
    %   vpv: Current PV voltage
    %   ipv: Current PV current
    %   delta: Step size for adjusting the duty cycle
    % Output:
    %   duty: Updated duty cycle

    % Initialization of constants
    duty_init = 0.1;          % Initial duty cycle
    duty_min = 0;             % Minimum duty cycle
    duty_max = 1.06;          % Maximum duty cycle to ensure safe operation

    persistent Vold Pold duty_old;
    % Persistent variables store the previous values of voltage, power, and duty cycle

    % Initialize persistent variables if first run
    if isempty(Vold)
        Vold = 0;
        Pold = 0;
        duty_old = duty_init;
    end

    % Calculate current power
    P = vpv * ipv;

    % Voltage and power differences (increments)
    dV = vpv - Vold;
    dP = P - Pold;

    % Incremental Conductance MPPT logic
    if dP ~= 0 && vpv > 30  % Algorithm operates only if power is changing and voltage is significant
        if dP < 0
            % If power decreases, adjust duty based on voltage trend
            if dV < 0
                duty = duty_old - delta;  % Decrease duty if voltage also drops
            else
                duty = duty_old + delta;  % Increase duty if voltage rises
            end
        else
            % If power increases, adjust duty based on voltage trend
            if dV < 0
                duty = duty_old + delta;  % Increase duty if voltage drops
            else
                duty = duty_old - delta;  % Decrease duty if voltage rises
            end
        end
    else
        duty = duty_old;  % No change in duty if no significant change in power or voltage
    end

    % Clamp duty cycle between minimum and maximum values
    duty = max(duty_min, min(duty, duty_max));

    % Store current values for the next iteration
    duty_old = duty;
    Vold = vpv;
    Pold = P;
end

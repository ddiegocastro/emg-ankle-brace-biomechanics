function vicon_data_kinetics = calculateJumpKinetics(vicon_data_angles, fs)
% CALCULATEJUMPKINETICS Calcula velocidad y aceleración angular a partir
% de los ángulos, adaptado para movimientos explosivos (Salto Vertical).

disp('================ CALCULANDO CINÉTICA DE SALTO ================');
vicon_data_kinetics = vicon_data_angles;
archivos = fieldnames(vicon_data_angles);

dt = 1 / fs; 

% AJUSTE BIOMECÁNICO CLAVE: Frecuencia de corte a 15 Hz
% Permite capturar la explosividad del despegue y el impacto del
% aterrizaje sin distorsionar ni "aplanar" los picos reales.
fc_kinetics = 15; 
[b, a] = butter(4, fc_kinetics / (fs / 2), 'low');

for f = 1:length(archivos)
    file_name = archivos{f};
    tabla = vicon_data_kinetics.(file_name);
    cols = tabla.Properties.VariableNames;

    % --- TOBILLO IZQUIERDO (L) ---
    if any(contains(cols, 'L_Ankle_Angle'))
        angulo_L = tabla.L_Ankle_Angle;

        % 1ra Derivada: Velocidad
        vel_L = gradient(angulo_L, dt);
        vel_L_filt = filtfilt(b, a, vel_L); 

        % 2da Derivada: Aceleración
        acc_L = gradient(vel_L_filt, dt);
        acc_L_filt = filtfilt(b, a, acc_L);

        vicon_data_kinetics.(file_name).L_Ankle_Velocity = vel_L_filt;
        vicon_data_kinetics.(file_name).L_Ankle_Acceleration = acc_L_filt;
    end

    % --- TOBILLO DERECHO (R) ---
    if any(contains(cols, 'R_Ankle_Angle'))
        angulo_R = tabla.R_Ankle_Angle;

        % 1ra Derivada: Velocidad
        vel_R = gradient(angulo_R, dt);
        vel_R_filt = filtfilt(b, a, vel_R);

        % 2da Derivada: Aceleración
        acc_R = gradient(vel_R_filt, dt);
        acc_R_filt = filtfilt(b, a, acc_R);

        vicon_data_kinetics.(file_name).R_Ankle_Velocity = vel_R_filt;
        vicon_data_kinetics.(file_name).R_Ankle_Acceleration = acc_R_filt;
    end
end
disp('-> Velocidad y aceleración de salto filtradas a 15 Hz.');
end
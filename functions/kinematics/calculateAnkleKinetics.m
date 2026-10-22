function vicon_data_kinetics = calculateAnkleKinetics(vicon_data_angles, fs)
% CALCULATEANKLEKINETICS Calcula la velocidad y aceleración angular a partir
% de los ángulos previamente calculados usando derivación numérica adaptada
% para protocolos de movimiento lento (10 segundos).

    disp('================ CALCULANDO CINÉTICA ANGULAR ================');
    vicon_data_kinetics = vicon_data_angles;
    archivos = fieldnames(vicon_data_angles);
    
    dt = 1 / fs; 
    
    % SOLUCIÓN CLÍNICA: Bajamos la frecuencia de corte a 1.2 Hz para limpiar
    % el ruido instrumental que la doble derivación amplifica exponencialmente.
    fc_kinetics = 1.2; 
    [b, a] = butter(4, fc_kinetics / (fs / 2), 'low');
    
    for f = 1:length(archivos)
        file_name = archivos{f};
        tabla = vicon_data_kinetics.(file_name);
        cols = tabla.Properties.VariableNames;
        
        % --- TOBILLO IZQUIERDO (L) ---
        if any(contains(cols, 'L_Ankle_Angle'))
            angulo_L = tabla.L_Ankle_Angle;
            
            % 1ra Derivada: Velocidad Angular (grados/s)
            vel_L = gradient(angulo_L, dt);
            vel_L_filt = filtfilt(b, a, vel_L); 
            
            % 2da Derivada: Aceleración Angular (grados/s^2)
            acc_L = gradient(vel_L_filt, dt);
            acc_L_filt = filtfilt(b, a, acc_L);
            
            vicon_data_kinetics.(file_name).L_Ankle_Velocity = vel_L_filt;
            vicon_data_kinetics.(file_name).L_Ankle_Acceleration = acc_L_filt;
        end
        
        % --- TOBILLO DERECHO (R) ---
        if any(contains(cols, 'R_Ankle_Angle'))
            angulo_R = tabla.R_Ankle_Angle;
            
            % 1ra Derivada: Velocidad Angular (grados/s)
            vel_R = gradient(angulo_R, dt);
            vel_R_filt = filtfilt(b, a, vel_R);
            
            % 2da Derivada: Aceleración Angular (grados/s^2)
            acc_R = gradient(vel_R_filt, dt);
            acc_R_filt = filtfilt(b, a, acc_R);
            
            vicon_data_kinetics.(file_name).R_Ankle_Velocity = vel_R_filt;
            vicon_data_kinetics.(file_name).R_Ankle_Acceleration = acc_R_filt;
        end
    end
    disp('-> Velocidad y aceleración angular filtradas dinámicamente.');
end
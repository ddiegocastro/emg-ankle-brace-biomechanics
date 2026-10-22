function features_table = extractKinematicFeatures(vicon_data_kinetics, subject_id, tipo_movimiento)
% EXTRACTKINEMATICFEATURES Extrae métricas clínicas clave (picos de posición,
% velocidad y aceleración, y desviación Inv/Ev) de las series de tiempo.
%
% Inputs:
%   vicon_data_kinetics - Struct con datos cinemáticos (pos, vel, acc, inv/ev).
%   subject_id          - String con el identificador del sujeto (ej. 'INJ').
%   tipo_movimiento     - String para filtrar intentos (ej. 'EP').
%
% Output:
%   features_table      - Tabla de MATLAB con las métricas extraídas.

    % Inicializar arreglos para las columnas de la tabla (incluyendo las nuevas)
    Trial_Name = {}; Subject = {}; Condition = {};
    Max_Plantarflexion = []; Peak_Descent_Vel = []; 
    Peak_Return_Vel = []; Max_Acceleration = []; Acc_Variability = [];
    Max_Inversion = []; Max_Eversion = []; Inv_Ev_ROM = [];
    
    archivos = fieldnames(vicon_data_kinetics);
    
    for i = 1:length(archivos)
        file_name = archivos{i};
        
        % Filtrar por tipo de movimiento
        if ~contains(file_name, tipo_movimiento, 'IgnoreCase', true)
            continue;
        end
        
        % Identificar condición (Sin Tobillera vs Con Tobillera)
        if contains(file_name, 'st', 'IgnoreCase', true)
            cond = 'ST';
        elseif contains(file_name, 'ct', 'IgnoreCase', true)
            cond = 'CT';
        else
            continue;
        end
        
        tabla = vicon_data_kinetics.(file_name);
        
        % Verificar que existan las variables principales
        if ~ismember('R_Ankle_Angle', tabla.Properties.VariableNames)
            continue;
        end
        
        % --- EXTRACCIÓN PLASNO SAGITAL ---
        ang = tabla.R_Ankle_Angle;
        vel = tabla.R_Ankle_Velocity;
        acc = tabla.R_Ankle_Acceleration;
        
        % 1. Máxima Plantiflexión (Ángulo más negativo)
        min_ang = min(ang);
        % 2. Velocidad Pico de Descenso (Velocidad más negativa)
        min_vel = min(vel);
        % 3. Velocidad Pico de Regreso (Velocidad más positiva)
        max_vel = max(vel);
        % 4. Aceleración Máxima (Fuerza de arranque)
        max_acc = max(acc);
        
        % 5. Variabilidad de Aceleración en Mantenimiento (Control motor)
        maint_idx = ang < (min_ang * 0.90); 
        if any(maint_idx)
            acc_var = std(acc(maint_idx), 'omitnan'); 
        else
            acc_var = NaN;
        end
        
        % --- EXTRACCIÓN PLANO FRONTAL (INVERSIÓN/EVERSIÓN) ---
        if ismember('R_Inv_Ev_Angle', tabla.Properties.VariableNames)
            inv_ev_ang = tabla.R_Inv_Ev_Angle;
            
            % Dependiendo de tu sistema de coordenadas, uno será positivo y otro negativo
            pico_max = max(inv_ev_ang); 
            pico_min = min(inv_ev_ang); 
            rango_total = pico_max - pico_min;
        else
            pico_max = NaN;
            pico_min = NaN;
            rango_total = NaN;
        end
        
        % Llenar arreglos
        Trial_Name{end+1, 1} = file_name;
        Subject{end+1, 1} = subject_id;
        Condition{end+1, 1} = cond;
        Max_Plantarflexion(end+1, 1) = min_ang;
        Peak_Descent_Vel(end+1, 1) = min_vel;
        Peak_Return_Vel(end+1, 1) = max_vel;
        Max_Acceleration(end+1, 1) = max_acc;
        Acc_Variability(end+1, 1) = acc_var;
        Max_Inversion(end+1, 1) = pico_max;
        Max_Eversion(end+1, 1) = pico_min;
        Inv_Ev_ROM(end+1, 1) = rango_total;
    end
    
    % Construir tabla final con las nuevas variables integradas
    features_table = table(Trial_Name, Subject, Condition, Max_Plantarflexion, ...
        Peak_Descent_Vel, Peak_Return_Vel, Max_Acceleration, Acc_Variability, ...
        Max_Inversion, Max_Eversion, Inv_Ev_ROM);
end
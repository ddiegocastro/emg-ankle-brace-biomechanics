function trial_features_table = extractAllTrialsFeatures(vicon_kinetics, vicon_corrected, subject_name, marker_name, fs, test_keyword)
% EXTRACTALLTRIALSFEATURES Extrae las 8 métricas (espaciales y angulares)
% de cada ensayo individual para armar la tabla estadística.

    % Inicializar celdas y vectores exactos del reporte (Paso 7)
    Subject = {}; Condition = {}; Trial_Name = {};
    
    Altura_Salto_cm = [];
    Delta_X_mm = [];
    Delta_Y_mm = [];
    Distancia_Total_cm = [];
    Pico_Vel_Empuje = [];
    Pico_Vel_Aterrizaje = [];
    Acc_Impacto = [];
    Tiempo_Estabilizacion = [];

    % CORRECCIÓN CRÍTICA: Detectar correctamente el formato de la estructura de Vicon
    if isstruct(vicon_kinetics) && numel(vicon_kinetics) == 1 && ~isfield(vicon_kinetics, 'name')
        % Caso: Estructura 1x1 donde cada campo es un ensayo (.SV_ST_01, .EP_ST_01...)
        campos = fieldnames(vicon_kinetics);
        num_ensayos = length(campos);
        es_estructura_campos = true;
    else
        % Caso: Arreglo de estructuras (vicon_kinetics(1), vicon_kinetics(2)...)
        num_ensayos = length(vicon_kinetics);
        es_estructura_campos = false;
    end

    % Recorrer todos los ensayos reales
    for i = 1:num_ensayos
        
        % Obtener el nombre del ensayo y aislar los datos según el formato estructurado
        if es_estructura_campos
            t_name = campos{i};
            ensayo_kin = vicon_kinetics.(t_name);
            ensayo_spat = vicon_corrected.(t_name);
        else
            if isfield(vicon_kinetics, 'name')
                t_name = vicon_kinetics(i).name;
            else
                t_name = sprintf('Trial_%d', i);
            end
            ensayo_kin = vicon_kinetics(i);
            ensayo_spat = vicon_corrected(i);
        end
        
        % --- FILTRO 1: Verificar que pertenezca a la prueba indicada (ej: 'SV') ---
        if ~contains(t_name, test_keyword, 'IgnoreCase', true)
            continue; 
        end
        
        % --- FILTRO 2: Identificar la condición (ST o CT) ---
        if contains(t_name, 'ST', 'IgnoreCase', true)
            cond = 'ST';
        elseif contains(t_name, 'CT', 'IgnoreCase', true)
            cond = 'CT';
        else
            continue; % Se salta el archivo si no es ST ni CT
        end

        %% --- A. EXTRACCIÓN CINEMÁTICA (Usando tu función extractJumpFeatures) ---
        try
            pos = ensayo_kin.R_Ankle_Angle;
            vel = ensayo_kin.R_Ankle_Velocity;
            acc = ensayo_kin.R_Ankle_Acceleration;
            
            ft = extractJumpFeatures(pos, vel, acc, fs);
            
            p_vel_emp = ft.pico_vel_empuje;
            p_vel_ate = ft.pico_vel_aterrizaje;
            a_imp     = ft.pico_acc_impacto;
            t_est     = ft.tiempo_estabilizacion_seg;
        catch
            p_vel_emp = NaN; p_vel_ate = NaN; a_imp = NaN; t_est = NaN;
        end

        %% --- B. EXTRACCIÓN ESPACIAL INDIVIDUAL (Misma lógica de calculateSpatialMetrics) ---
        col_X = [marker_name, '_X']; col_Y = [marker_name, '_Y']; col_Z = [marker_name, '_Z'];
        coords = [];
        
        if istable(ensayo_spat)
            vars = ensayo_spat.Properties.VariableNames;
            if ismember(col_X, vars) && ismember(col_Y, vars) && ismember(col_Z, vars)
                coords = [ensayo_spat.(col_X), ensayo_spat.(col_Y), ensayo_spat.(col_Z)];
            elseif ismember(marker_name, vars)
                coords = ensayo_spat.(marker_name);
            end
        elseif isstruct(ensayo_spat)
            if isfield(ensayo_spat, col_X) && isfield(ensayo_spat, col_Y) && isfield(ensayo_spat, col_Z)
                coords = [ensayo_spat.(col_X), ensayo_spat.(col_Y), ensayo_spat.(col_Z)];
            elseif isfield(ensayo_spat, marker_name)
                coords = ensayo_spat.(marker_name);
            end
        end
        
        h_salto = NaN; dX_val = NaN; dY_val = NaN; d_tot = NaN;
        
        if ~isempty(coords)
            z_inicial = mean(coords(1:10, 3), 'omitnan');
            z_maxima = max(coords(:, 3), [], 'omitnan');
            h_salto = (z_maxima - z_inicial) / 10; % cm
            
            pos_ini_X = mean(coords(1:10, 1), 'omitnan'); pos_ini_Y = mean(coords(1:10, 2), 'omitnan');
            pos_fin_X = mean(coords(end-9:end, 1), 'omitnan'); pos_fin_Y = mean(coords(end-9:end, 2), 'omitnan');
            
            dX_val = pos_fin_X - pos_ini_X; % mm
            dY_val = pos_fin_Y - pos_ini_Y; % mm
            d_tot = sqrt(dX_val^2 + dY_val^2) / 10; % cm
        end

        %% --- C. GUARDAR EN VECTORES ---
        Subject{end+1, 1} = subject_name;
        Condition{end+1, 1} = cond;
        Trial_Name{end+1, 1} = t_name;
        
        Altura_Salto_cm(end+1, 1) = h_salto;
        Delta_X_mm(end+1, 1) = dX_val;
        Delta_Y_mm(end+1, 1) = dY_val;
        Distancia_Total_cm(end+1, 1) = d_tot;
        Pico_Vel_Empuje(end+1, 1) = p_vel_emp;
        Pico_Vel_Aterrizaje(end+1, 1) = p_vel_ate;
        Acc_Impacto(end+1, 1) = a_imp;
        Tiempo_Estabilizacion(end+1, 1) = t_est;
    end

    % --- D. CONSTRUIR TABLA FINAL ---
    trial_features_table = table(Subject, Condition, Trial_Name, ...
        Altura_Salto_cm, Delta_X_mm, Delta_Y_mm, Distancia_Total_cm, ...
        Pico_Vel_Empuje, Pico_Vel_Aterrizaje, Acc_Impacto, Tiempo_Estabilizacion);
end
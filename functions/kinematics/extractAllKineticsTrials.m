function trial_kinetics_table = extractAllKineticsTrials(vicon_kinetics, subject_name, fs, test_keyword)
% EXTRACTALLKINETICSTRIALS Extrae las 4 características cinemáticas angulares 
% de cada ensayo individual a partir de las series de tiempo completas.
%
% INPUTS:
%   vicon_kinetics : Estructura (INJ o CTRL) cuyos campos son las tablas de cada ensayo.
%   subject_name   : String ('INJ' o 'CTRL') para identificar al sujeto.
%   fs             : Frecuencia de muestreo (Hz).
%   test_keyword   : Palabra clave para filtrar la prueba (ej. 'Sv').

    % Inicializar los contenedores de datos para armar la tabla final
    Subject = {};
    Condition = {};
    Trial_Name = {};
    Pico_Vel_Empuje = [];
    Pico_Vel_Aterrizaje = [];
    Acc_Impacto = [];
    Tiempo_Estabilizacion = [];

    % Obtener los nombres de todos los campos (ensayos) dentro de la estructura
    campos = fieldnames(vicon_kinetics);
    num_ensayos = length(campos);

    % Recorrer cada ensayo individual
    for i = 1:num_ensayos
        t_name = campos{i};
        
        % --- FILTRO 1: Validar si el ensayo pertenece a la prueba (ej: 'Sv') ---
        if ~contains(t_name, test_keyword, 'IgnoreCase', true)
            continue; 
        end
        
        % --- FILTRO 2: Identificar la condición clínica (ST o CT) ---
        if contains(t_name, 'ST', 'IgnoreCase', true)
            cond = 'ST';
        elseif contains(t_name, 'CT', 'IgnoreCase', true)
            cond = 'CT';
        else
            continue; % Se salta el ensayo si no se puede determinar la condición
        end
        
        % Extraer la tabla de datos cinemáticos del ensayo actual
        ensayo_tabla = vicon_kinetics.(t_name);
        
        % Extraer los vectores correspondientes a la cinemática del tobillo derecho
        vel = ensayo_tabla.R_Ankle_Velocity;
        acc = ensayo_tabla.R_Ankle_Acceleration;
        
        % Reconstrucción de la escala de tiempo real para este ensayo específico
        dt = 1 / fs;
        tiempo_seg = (0:length(acc)-1) * dt; 

        %% =================================================================
        %% METODOLOGÍA MATEMÁTICA EN SERIE DE TIEMPO INDIVIDUAL
        %% =================================================================
        try
            % 1. VELOCIDADES Y ACELERACIONES PICO
            p_vel_emp = min(vel);      % Pico de extensión violenta (Dorsiflexión a Plantarflexión)
            p_vel_ate = max(vel);      % Pico de flexión de frenado tras impacto
            a_imp     = max(acc);      % Impacto contra el suelo
            
            % 2. TIEMPO DE ESTABILIZACIÓN POST-ATERRIZAJE (Banda de estabilidad)
            % El aterrizaje relativo ocurre en el pico máximo de aceleración (segunda mitad de la serie)
            mitad_ciclo = round(length(acc) / 2);
            [~, idx_impacto_rel] = max(acc(mitad_ciclo:end));
            idx_aterrizaje = mitad_ciclo + idx_impacto_rel - 1;
            
            % Definimos el reposo pasivo usando el último 10% del ensayo actual
            idx_reposo = round(length(acc) * 0.9):length(acc);
            std_reposo = std(acc(idx_reposo), 'omitnan');
            banda_tolerancia = 2 * std_reposo; % Umbral clásico de ±2 STD
            
            % Buscamos desde el final de la señal regresando hacia el impacto el punto de estabilización
            idx_estabilizado = length(acc);
            for k = length(acc):-1:idx_aterrizaje
                if abs(acc(k)) > banda_tolerancia
                    idx_estabilizado = k + 1;
                    break;
                end
            end
            
            % Calcular la duración en segundos desde el choque hasta la estabilización estable
            if idx_estabilizado <= length(acc)
                t_est = tiempo_seg(idx_estabilizado) - tiempo_seg(idx_aterrizaje);
            else
                t_est = 0; % Ya se encontraba estable
            end
            
        catch ME
            % En caso de que un ensayo falle por falta de filas o datos corruptos
            warning('Error al procesar métricas en el ensayo %s: %s', t_name, ME.message);
            p_vel_emp = NaN; p_vel_ate = NaN; a_imp = NaN; t_est = NaN;
        end

        %% =================================================================
        %% ACUMULAR RESULTADOS EN LOS VECTORES DE LA TABLA
        %% =================================================================
        Subject{end+1, 1} = subject_name;
        Condition{end+1, 1} = cond;
        Trial_Name{end+1, 1} = t_name;
        
        Pico_Vel_Empuje(end+1, 1)     = p_vel_emp;
        Pico_Vel_Aterrizaje(end+1, 1) = p_vel_ate;
        Acc_Impacto(end+1, 1)         = a_imp;
        Tiempo_Estabilizacion(end+1, 1) = t_est;
    end

    % --- CONSTRUCCIÓN DE LA TABLA FINAL DE SALIDA ---
    trial_kinetics_table = table(Subject, Condition, Trial_Name, ...
        Pico_Vel_Empuje, Pico_Vel_Aterrizaje, Acc_Impacto, Tiempo_Estabilizacion);
end
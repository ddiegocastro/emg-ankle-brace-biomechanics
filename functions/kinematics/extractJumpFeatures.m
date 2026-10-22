function features_table = extractJumpFeatures(vicon_kinetics, condition_keyword, fs)
% EXTRACTJUMPFEATURES Extrae métricas cinemáticas de TODOS los ensayos individuales
% para una condición específica (ST o CT) a partir de sus series de tiempo originales.
%
% INPUTS:
%   vicon_kinetics    - Struct con los datos cinemáticos individuales (ej: vicon_data_kinetics_INJ)
%   condition_keyword - String que define la condición a extraer ('ST' o 'CT')
%   fs                - Frecuencia de muestreo (Hz)

    % Inicializar vectores para almacenar los datos de cada ensayo válido
    Trial_Name = {};
    Pico_Vel_Empuje = [];
    Pico_Vel_Aterrizaje = [];
    Acc_Impacto = [];
    Tiempo_Estabilizacion = [];

    % Obtener los nombres de todos los archivos/ensayos cargados
    archivos = fieldnames(vicon_kinetics);
    
    for i = 1:length(archivos)
        t_name = archivos{i};
        
        % --- FILTROS DE ASIGNACIÓN: Solo procesar 'Sv' y la condición solicitada ('ST' o 'CT') ---
        if ~contains(t_name, 'Sv', 'IgnoreCase', true) || ...
           ~contains(t_name, condition_keyword, 'IgnoreCase', true)
            continue;
        end
        
        % Extraer la tabla del ensayo actual
        tabla = vicon_kinetics.(t_name);
        
        % Capturar las series de tiempo cinemáticas del tobillo
        vel = tabla.R_Ankle_Velocity;
        acc = tabla.R_Ankle_Acceleration;
        
        % Reconstrucción de la escala temporal real en segundos para este ensayo
        dt = 1 / fs;
        tiempo_seg = (0:length(acc)-1) * dt; 
        
        %% 1. VELOCIDADES Y ACELERACIONES PICO
        p_vel_emp = min(vel);      % Pico de extensión violenta (Dorsiflexión a Plantarflexión)
        p_vel_ate = max(vel);      % Pico de flexión de frenado tras impacto
        a_imp     = max(acc);      % Impacto contra el suelo
        
        %% 2. TIEMPO DE ESTABILIZACIÓN POST-ATERRIZAJE (Banda de estabilidad)
        % El aterrizaje relativo ocurre en el pico máximo de aceleración (segunda mitad del ciclo)
        mitad_ciclo = round(length(acc)/2);
        [~, idx_impacto_rel] = max(acc(mitad_ciclo:end));
        idx_aterrizaje = mitad_ciclo + idx_impacto_rel - 1;
        
        % Definimos el reposo final usando el último 10% de la señal real de este ensayo
        idx_reposo = round(length(acc)*0.9):length(acc);
        std_reposo = std(acc(idx_reposo), 'omitnan');
        banda_tolerancia = 2 * std_reposo; % Umbral clásico de ±2 STD
        
        % Buscamos desde el final hacia el impacto el punto exacto de estabilización
        idx_estabilizado = length(acc);
        for k = length(acc):-1:idx_aterrizaje
            if abs(acc(k)) > banda_tolerancia
                idx_estabilizado = k + 1;
                break;
            end
        end
        
        % Calcular la duración en segundos desde que chocó hasta que se estabilizó
        if idx_estabilizado <= length(acc)
            t_est = tiempo_seg(idx_estabilizado) - tiempo_seg(idx_aterrizaje);
        else
            t_est = 0; 
        end
        
        % --- ACUMULAR DATOS DEL ENSAYO EN LOS VECTORES ---
        Trial_Name{end+1, 1}            = t_name;
        Pico_Vel_Empuje(end+1, 1)       = p_vel_emp;
        Pico_Vel_Aterrizaje(end+1, 1)   = p_vel_ate;
        Acc_Impacto(end+1, 1)           = a_imp;
        Tiempo_Estabilizacion(end+1, 1) = t_est;
    end
    
    % --- CONSTRUIR LA TABLA RESULTANTE PARA ESTA CONDICIÓN ---
    features_table = table(Trial_Name, Pico_Vel_Empuje, Pico_Vel_Aterrizaje, ...
                           Acc_Impacto, Tiempo_Estabilizacion);
end
function median_data = calculateMedianKinematics(data_struct, tipo_movimiento, var_name)
% CALCULATEMEDIANKINEMATICS Calcula la mediana y desviación estándar de
% cualquier variable cinemática (Posición, Velocidad o Aceleración).
%
% Inputs:
%   data_struct     - Struct con los datos cinemáticos
%   tipo_movimiento - String para filtrar ('EP')
%   var_name        - Nombre exacto de la columna (ej. 'R_Ankle_Velocity')

    condiciones = {'st', 'ct'};
    median_data = struct();
    archivos = fieldnames(data_struct);
    num_puntos = 101; % Normalizado al 0-100% del ciclo
    
    for c = 1:length(condiciones)
        cond = condiciones{c};
        idx = find(contains(archivos, tipo_movimiento, 'IgnoreCase', true) & ...
                   contains(archivos, cond, 'IgnoreCase', true));
               
        if isempty(idx)
            continue;
        end
        
        curvas_interp = zeros(length(idx), num_puntos);
        
        for i = 1:length(idx)
            tabla = data_struct.(archivos{idx(i)});
            
            % Extracción dinámica de la variable solicitada
            senal = tabla.(var_name); 
            
            % Interpolar al ciclo estándar 0-100%
            t_orig = linspace(0, 100, length(senal));
            t_new = linspace(0, 100, num_puntos);
            curvas_interp(i, :) = interp1(t_orig, senal, t_new, 'spline');
        end
        
        % Cálculo directo de Mediana y Std
        median_data.(cond).median = median(curvas_interp, 1, 'omitnan');
        median_data.(cond).std = std(curvas_interp, 0, 1, 'omitnan');
        median_data.(cond).t_pct = t_new;
    end
end
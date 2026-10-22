function [emg_data_norm, max_peaks_by_task] = NormalizeEMGPk(emg_data)
% NormalizeEMGPk Normaliza cada ensayo respecto a SU PROPIO pico máximo (Opción A)
% e implemementa un filtro de percentil para evadir artefactos de ruido (Opción C).
%
% INPUT:
%   emg_data - (Struct) Estructura con las envolventes lineales.
%
% OUTPUT:
%   emg_data_norm     - (Struct) Datos normalizados (0 a 100%).
%   max_peaks_by_task - (Struct) Picos limpios máximos encontrados por tarea.

    emg_data_norm = emg_data;
    fields = fieldnames(emg_data);
    
    if isempty(fields)
        error('La estructura de datos está vacía.');
    end
    
    % Identificar las tareas únicas usando los primeros 2 caracteres del nombre
    tareas_unicas = {};
    for k = 1:length(fields)
        prefijo_tarea = fields{k}(1:2); % Extrae 'EP' o 'SV'
        if ~ismember(prefijo_tarea, tareas_unicas)
            tareas_unicas{end+1} = prefijo_tarea;
        end
    end
    
    max_peaks_by_task = struct();
    num_muscles = size(emg_data.(fields{1}), 2);
    
    % Procesar cada tarea de forma independiente
    for t = 1:length(tareas_unicas)
        tarea_actual = tareas_unicas{t};
        picos_maximos_tarea = zeros(1, num_muscles);
        
        for k = 1:length(fields)
            if startsWith(fields{k}, tarea_actual, 'IgnoreCase', true)
                tabla_actual = emg_data_norm.(fields{k});
                data_array = table2array(tabla_actual);
                
                % =========================================================
                % IMPLEMENTACIÓN DE LA OPCIÓN C: FILTRADO DE ARTEFACTOS
                % =========================================================
                % Ordenamos los datos de menor a mayor por cada columna (músculo)
                n_samples = size(data_array, 1);
                sorted_data = sort(data_array, 1);
                
                % Tomamos el percentil 99 en lugar del Máximo Absoluto.
                % Esto descarta picos de milisegundos provocados por ruido eléctrico.
                idx_99 = max(1, round(0.99 * n_samples)); 
                pico_limpio_ensayo = sorted_data(idx_99, :);
                
                % Guardar un escudo contra división por cero (músculos inactivos)
                pico_limpio_ensayo(pico_limpio_ensayo == 0) = 1;
                
                % =========================================================
                % IMPLEMENTACIÓN DE LA OPCIÓN A: NORMALIZACIÓN INDIVIDUAL
                % =========================================================
                % Cada ensayo se divide estrictamente entre su propio pico limpio
                data_norm_array = (data_array ./ pico_limpio_ensayo) * 100;
                
                % Asegurar que si algún valor real superó el percentil 99 
                % no exceda drásticamente el 100% en la gráfica
                data_norm_array(data_norm_array > 100) = 100;
                
                % Guardar los datos normalizados en la estructura
                tabla_actual{:,:} = data_norm_array;
                emg_data_norm.(fields{k}) = tabla_actual;
                
                % Registramos el pico más alto de la tarea completa para el output
                picos_maximos_tarea = max([picos_maximos_tarea; pico_limpio_ensayo], [], 1);
            end
        end
        
        % Guardar el reporte de picos máximos limpios por tarea
        max_peaks_by_task.(tarea_actual) = picos_maximos_tarea;
    end
end
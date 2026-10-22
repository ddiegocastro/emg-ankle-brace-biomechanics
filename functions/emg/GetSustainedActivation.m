function results_table = GetSustainedActivation(emg_data_norm, fs)
% GetSustainedActivation Calcula la activación media (sostenida) durante
% la fase isométrica (segundos 3 a 5) en Elevación de Puntillas (EP).
%
% INPUT:
%   emg_data_norm - (Struct) Datos normalizados (% Máximo).
%   fs            - (Double) Frecuencia de muestreo (ej. 2000).
%
% OUTPUT:
%   results_table - (Table) Tabla resumen con la activación media por músculo.

field = fieldnames(emg_data_norm);

% Inicializamos variables para construir la tabla final
Ensayo = {};
L_TA_Mean = []; L_SL_Mean = []; L_GR_Mean = [];
R_TA_Mean = []; R_SL_Mean = []; R_GR_Mean = [];

% Definir la ventana de tiempo en muestras (índices)
inicio_idx = round(3.0 * fs) + 1;
fin_idx    = round(5.0 * fs);

for k = 1:length(field)
    nombre_ensayo = field{k};

    % Solo procesamos si es un ensayo de Elevación de Puntillas (EP)
    if contains(nombre_ensayo, 'EP', 'IgnoreCase', true)

        tabla_actual = emg_data_norm.(nombre_ensayo);
        data_array = table2array(tabla_actual);

        % Seguro de errores: verificar que el archivo dure al menos 5 segundos
        if size(data_array, 1) < fin_idx
            warning('El ensayo %s dura menos de 5 segundos. Se omitirá.', nombre_ensayo);
            continue;
        end

        % 1. Recortar la ventana de interés (3 a 5 segundos)
        data_window = data_array(inicio_idx:fin_idx, :);

        % 2. Calcular el promedio (Mean) de cada columna en esa ventana
        promedios = mean(data_window, 1);

        % 3. Almacenar los resultados para la tabla
        Ensayo{end+1, 1} = nombre_ensayo;
        L_TA_Mean(end+1, 1) = promedios(1);
        L_SL_Mean(end+1, 1) = promedios(2);
        L_GR_Mean(end+1, 1) = promedios(3);
        R_TA_Mean(end+1, 1) = promedios(4);
        R_SL_Mean(end+1, 1) = promedios(5);
        R_GR_Mean(end+1, 1) = promedios(6);
    end
end

% Construir la tabla final
results_table = table(Ensayo, L_TA_Mean, L_SL_Mean, L_GR_Mean, ...
    R_TA_Mean, R_SL_Mean, R_GR_Mean);
end
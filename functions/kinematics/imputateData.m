function vicon_data_corrected = imputateData(vicon_data, modelos_entrenados)
% IMPUTATEDATA Utiliza modelos de regresión entrenados para rellenar
% los fotogramas perdidos (NaNs) en los datos cinemáticos de Vicon.
%
% Inputs:
%   vicon_data         - Struct con los datos crudos originales.
%   modelos_entrenados - Struct con los modelos entrenados y parámetros (output de trainMarkers).
%
% Output:
%   vicon_data_corrected - Struct con los datos reparados (imputados).

disp('================ INICIANDO IMPUTACIÓN DE DATOS ================');

% Clonar la estructura original para rellenar los NaNs sin destruir el set crudo
vicon_data_corrected = vicon_data; 

% Extraer dinámicamente los archivos procesados desde la estructura de modelos
archivos_con_errores = fieldnames(modelos_entrenados);

for f = 1:length(archivos_con_errores)
    file_name = archivos_con_errores{f};

    % Comprobar si este archivo realmente generó algún modelo de corrección
    if isfield(modelos_entrenados, file_name)
        marcadores_perdidos = fieldnames(modelos_entrenados.(file_name));

        for m = 1:length(marcadores_perdidos)
            target_marker = marcadores_perdidos{m};
            modelo_info = modelos_entrenados.(file_name).(target_marker);

            % Extraer coordenadas vectoriales completas del marcador con problemas
            data_table = vicon_data_corrected.(file_name);
            Y_full = data_table.(target_marker);

            % Ubicar de forma exacta las filas que contienen NaNs
            idx_missing = find(isnan(Y_full));

            if ~isempty(idx_missing)
                % Extraer la submatriz de predictores asociada en los fotogramas perdidos
                X_missing = table2array(data_table(idx_missing, modelo_info.Predictors));

                % Normalizar bajo la misma transformación Z calculada en el set de entrenamiento
                X_missing_z = (X_missing - modelo_info.Mu) ./ modelo_info.Sigma;

                % Computar predictores mediante regresión
                Y_pred = predict(modelo_info.Model, X_missing_z);

                % Inyectar la reconstrucción del modelo de vuelta en la tabla limpia
                vicon_data_corrected.(file_name).(target_marker)(idx_missing) = Y_pred;

                fprintf('Archivo: %s -> Reconstruidos %d frames para el marcador %s\n', ...
                    file_name, length(idx_missing), target_marker);
            end
        end
    end
end
disp('================ IMPUTACIÓN FINALIZADA ================');
end
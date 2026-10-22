function modelos_entrenados = trainMarkers(vicon_data, predictors_dict)
% TRAINMARKERS Entrena modelos de regresión lineal para imputar marcadores perdidos.
%
% Inputs:
%   vicon_data      - Struct con los datos crudos de Vicon (tablas por archivo).
%   predictors_dict - Struct con los predictores identificados para cada marcador/archivo.
%
% Output:
%   modelos_entrenados - Struct con los modelos entrenados, parámetros de 
%                        estandarización (Mu, Sigma) y métricas (RMSE, R2).
    
% Fijar la semilla de aleatoridad para garantizar la reproducibilidad de los resultados
    rng(42);
    disp('================ INICIANDO ENTRENAMIENTO DE MODELOS ================');
    
    % Estructura para guardar los modelos entrenados y sus métricas
    modelos_entrenados = struct(); 
    
    % Obtener los archivos que tienen marcadores para corregir
    archivos_con_errores = fieldnames(predictors_dict);
    
    for f = 1:length(archivos_con_errores)
        file_name = archivos_con_errores{f};
        marcadores_perdidos = fieldnames(predictors_dict.(file_name));
        
        fprintf('\n--- Procesando Archivo: %s ---\n', file_name);
        
        for m = 1:length(marcadores_perdidos)
            target_marker = marcadores_perdidos{m};
            
            % Obtener la lista de predictores para este marcador específico
            predictors = predictors_dict.(file_name).(target_marker);
            
            % Extraer la tabla de datos completa de este archivo
            data_table = vicon_data.(file_name);
            
            % Extraer la variable dependiente (Y) y las independientes (X)
            Y_full = data_table.(target_marker);
            X_full = table2array(data_table(:, predictors));
            
            % 1. Extraer solo los fotogramas válidos (donde Y NO es NaN) para entrenar
            valid_idx = ~isnan(Y_full);
            X_valid = X_full(valid_idx, :);
            Y_valid = Y_full(valid_idx);
            
            n_samples = length(Y_valid);
            
            % Si por alguna razón hay muy pocos datos válidos, omitimos (filtro de seguridad)
            if n_samples < 10
                fprintf('[!] %s: Datos insuficientes para entrenar.\n', target_marker);
                continue;
            end
            
            % 2. División 70/30 (Train / Test Split)
            n_train = round(0.70 * n_samples);
            
            % Usamos randperm para mezclar los datos aleatoriamente. 
            rand_idx = randperm(n_samples);
            train_idx = rand_idx(1:n_train);
            test_idx = rand_idx(n_train+1:end);
            
            % Asignación de datos
            X_train = X_valid(train_idx, :);
            Y_train = Y_valid(train_idx);
            
            X_test = X_valid(test_idx, :);
            Y_test = Y_valid(test_idx);
            
            % 3. Estandarización de distribución Z (Z-Score)
            mu_X = mean(X_train);
            sigma_X = std(X_train);
            
            % Prevención de división por cero si un marcador de referencia no se movió nada
            sigma_X(sigma_X == 0) = 1; 
            
            % Aplicamos la distribución Z a X_train y X_test
            X_train_z = (X_train - mu_X) ./ sigma_X;
            X_test_z = (X_test - mu_X) ./ sigma_X;
            
            % 4. Entrenamiento del Modelo (Regresión Lineal)
            mdl = fitlm(X_train_z, Y_train);
            
            % 5. Evaluación (Predicción en el 30% nunca antes visto)
            Y_pred = predict(mdl, X_test_z);
            
            % Cálculo de Root Mean Square Error (RMSE)
            rmse = sqrt(mean((Y_test - Y_pred).^2));
            
            % Extracción de R Cuadrada 
            r2 = mdl.Rsquared.Ordinary;
            
            % 6. Guardar todo en la estructura principal para su uso posterior
            modelos_entrenados.(file_name).(target_marker).Model = mdl;
            modelos_entrenados.(file_name).(target_marker).Mu = mu_X;
            modelos_entrenados.(file_name).(target_marker).Sigma = sigma_X;
            modelos_entrenados.(file_name).(target_marker).RMSE = rmse;
            modelos_entrenados.(file_name).(target_marker).R2 = r2;
            modelos_entrenados.(file_name).(target_marker).Predictors = predictors;
            
            % Reporte en consola
            fprintf('Marcador: %s | RMSE: %6.2f mm | R2: %.4f\n', target_marker, rmse, r2);
        end
    end
    disp('================ ENTRENAMIENTO FINALIZADO ================');
end
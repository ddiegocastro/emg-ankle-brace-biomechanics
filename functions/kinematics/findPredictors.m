function all_predictors_dict = findPredictors(vicon_data, nans_table)
% FINDPREDICTORS Encuentra marcadores predictores altamente correlacionados 
% para los marcadores con pérdida de datos (NaNs).
%
%   Sintaxis:
%       all_predictors_dict = findPredictors(vicon_data, nans_table)
%
%   Inputs:
%       vicon_data - Struct donde cada campo es una tabla de datos Vicon.
%       nans_table - Tabla lógica de diagnóstico generada por findNaNs.
%
%   Outputs:
%       all_predictors_dict - Struct anidado con los predictores encontrados.

% 1. Inicializamos la variable principal de salida
all_predictors_dict = struct(); 

% 2. Identificar ÚNICAMENTE los archivos con NaNs usando la tabla de entrada
matrix_nans = table2array(nans_table);
filas_con_errores = any(matrix_nans == 1, 2); 
files_wnans = nans_table.Properties.RowNames(filas_con_errores);

% Si ningún archivo tiene errores, terminamos la función rápido
if isempty(files_wnans)
    disp('Todos los archivos están limpios. No se requieren predictores.');
    return;
end

% 3. Bucle principal: Recorrer SOLO los archivos problemáticos
for f = 1:length(files_wnans)

    current_file = files_wnans{f};
    data_table = vicon_data.(current_file);
    matrix_data = table2array(data_table);
    cols_names = data_table.Properties.VariableNames;

    % Necesitamos saber exactamente qué marcadores fallaron en ESTE archivo
    clean_markers = all(~isnan(matrix_data), 1); 
    idx_lost = find(~clean_markers); 

    % Calcular la matriz de correlación
    corr_matrix = corr(matrix_data, 'Rows', 'pairwise');

    % Estructura temporal para guardar los predictores de este archivo
    predictores_dict = struct(); 

    % 4. Bucle secundario: Recorrer cada marcador perdido del archivo actual
    for i = 1:length(idx_lost)
        lost_col = idx_lost(i); 
        lost_name = cols_names{lost_col};

        % Correlación absoluta con el marcador perdido
        corr_abs = abs(corr_matrix(:, lost_col));

        % Inicializamos el umbral y los predictores
        umbral_actual = 0.75;
        name_predictors = {};

        % Bucle adaptativo: disminuye el umbral si no encuentra predictores
        while isempty(name_predictors) && umbral_actual >= 0.20
            predictor_condition = (corr_abs >= umbral_actual) & clean_markers';
            name_predictors = cols_names(predictor_condition);

            if isempty(name_predictors)
                umbral_actual = umbral_actual - 0.05;
            end
        end

        % Guardar en el struct temporal del archivo
        field_struct = matlab.lang.makeValidName(lost_name);
        predictores_dict.(field_struct) = name_predictors;
    end

    % 5. Guardar el diccionario del archivo actual en la variable principal
    all_predictors_dict.(current_file) = predictores_dict;

end
end
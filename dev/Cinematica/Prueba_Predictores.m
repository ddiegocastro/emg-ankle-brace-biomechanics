% Auto-exported from Cinematica/Prueba_Predictores.mlx (code cells only).

% Buscar marcadores perdidos en mediciones 
clear; clc; close all; 

% Rutas utilizadas: 
ruta_datos = '<project_root>\ProyectoFinal\InputData\Injured\Vicon'; 
ruta_funciones = '<project_root>\ProyectoFinal\Functions';
addpath(ruta_funciones);

% Cargar datos
vicon_data = loadVicon(ruta_datos);

% Cargar matriz de detección de NaNs. 
nans_table = findNaNs(vicon_data);
disp(nans_table);

field = fieldnames(vicon_data); 
matrix_nans = table2array(nans_table);
row_nans = any(matrix_nans == 1, 2); 
files_wnans = nans_table.Properties.RowNames(row_nans); 


% Prueba individual: 
missing_data = vicon_data.(files_wnans{1});

matrix_data = table2array(missing_data); 

% Obtener columnas de los marcadores limpios.
clean_markers = all(~isnan(matrix_data), 1); 
clean_data = matrix_data(:, clean_markers); % Obtener marcadores limpios. 

% Ver matriz de correlación. 
corr_matrix = corr(matrix_data, 'Rows','pairwise');
rows_names = missing_data.Properties.VariableNames;
cols_names = rows_names;

figure('Position',[100, 100, 900, 800]); 
h = heatmap(cols_names, rows_names, corr_matrix);

h.Title = 'Matriz de Correlación de Marcadores Biomecánicos';
h.Colormap = jet;           
h.ColorLimits = [-1 1];            
h.CellLabelColor = 'none';

h.XDisplayLabels = cols_names;
h.YDisplayLabels = cols_names;

% En base a la matriz de correlación, obtener los marcadores que tengan una
% correlación mayor o igual a 0.75 para la predicción de los marcadores perdidos.
% Si no se encuentran, el umbral se reduce de 0.05 en 0.05 dinámicamente.

idx_lost = find(~clean_markers); 

% Estructura para guardar el diccionario de {MarcadorPerdido: [Predictores]}
predictores_dict = struct(); 

for i = 1:length(idx_lost)
    lost_col = idx_lost(i); 
    lost_name = cols_names{lost_col};

    corr_abs = abs(corr_matrix(:, lost_col));
    
    % Inicializamos el umbral y los predictores para este marcador
    umbral_actual = 0.75;
    name_predictors = {};
    
    % Bucle adaptativo: mientras no haya predictores Y el umbral sea aceptable (> 0.20)
    while isempty(name_predictors) && umbral_actual >= 0.20
        predictor_condition = (corr_abs >= umbral_actual) & clean_markers';
        name_predictors = cols_names(predictor_condition);
        
        % Si sigue vacío, disminuimos el umbral para la siguiente iteración del while
        if isempty(name_predictors)
            umbral_actual = umbral_actual - 0.05;
        end
    end

    % Guardar en el struct
    field_struct = matlab.lang.makeValidName(lost_name);
    predictores_dict.(field_struct) = name_predictors;

    % Imprimir resultados detallados
    fprintf('Marcador a corregir: %s\n', lost_name);
    
    if isempty(name_predictors)
        % Si el bucle terminó por llegar al límite mínimo de correlación
        fprintf('  [!] Alerta Crítica: No se encontraron predictores limpios ni siquiera bajando el umbral.\n');
    else
        % Informar si se tuvo que bajar el umbral
        if umbral_actual < 0.75
            fprintf('  [!] Umbral reducido automáticamente a: %.2f\n', umbral_actual);
        end
        % Unir los nombres con comas para mostrarlos en una sola línea
        fprintf('  -> %d Predictores listos: %s\n', ...
            length(name_predictors), strjoin(name_predictors, ', '));
    end
    fprintf('--------------------------------------------------------\n');
end

% Prueba con múltiples archivos. 
% Inicializamos la variable principal que guardará todos los resultados
all_predictors_dict = struct(); 

fprintf('\nINICIANDO BÚSQUEDA DE PREDICTORES PARA MÚLTIPLES ARCHIVOS...\n');

% Bucle externo: Recorrer cada archivo que tiene NaNs
for f = 1:length(files_wnans)

    % 1. Obtener el nombre y los datos del archivo actual
    current_file = files_wnans{f};
    missing_data = vicon_data.(current_file);
    matrix_data = table2array(missing_data);
    cols_names = missing_data.Properties.VariableNames;

    fprintf('\n========================================================\n');
    fprintf('PROCESANDO ARCHIVO: %s\n', current_file);
    fprintf('========================================================\n');

    % 2. Identificar marcadores limpios y calcular correlación del archivo actual
    clean_markers = all(~isnan(matrix_data), 1); 
    idx_lost = find(~clean_markers); 
    corr_matrix = corr(matrix_data, 'Rows', 'pairwise');

    % Estructura temporal para guardar los predictores de este archivo específico
    predictores_dict = struct(); 

    % Bucle interno: Recorrer cada marcador perdido del archivo actual
    for i = 1:length(idx_lost)
        lost_col = idx_lost(i); 
        lost_name = cols_names{lost_col};

        corr_abs = abs(corr_matrix(:, lost_col));

        % Inicializamos el umbral y los predictores
        umbral_actual = 0.75;
        name_predictors = {};

        % Bucle adaptativo
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

        % Imprimir resultados detallados
        fprintf('Marcador a corregir: %s\n', lost_name);
        if isempty(name_predictors)
            fprintf('  [!] Alerta Crítica: No se encontraron predictores limpios.\n');
        else
            if umbral_actual < 0.75
                fprintf('  [!] Umbral reducido automáticamente a: %.2f\n', umbral_actual);
            end
            fprintf('  -> %d Predictores listos: %s\n', ...
                length(name_predictors), strjoin(name_predictors, ', '));
        end
        fprintf('--------------------------------------------------------\n');
    end

    % 3. Guardar el diccionario del archivo actual en la variable principal
    all_predictors_dict.(current_file) = predictores_dict;

end

disp('PROCESO FINALIZADO CON ÉXITO.');

all_predictors_dict_func = findPredictors(vicon_data, nans_table);
isequal(all_predictors_dict, all_predictors_dict_func)

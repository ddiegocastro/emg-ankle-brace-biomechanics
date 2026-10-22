% Auto-exported from Cinematica/Prueba_LostMarkers.mlx (code cells only).

% Buscar marcadores perdidos en mediciones 
clear; clc; close all; 

% Rutas utilizadas: 
ruta_datos = '<project_root>\ProyectoFinal\InputData\Injured\Vicon'; 
ruta_funciones = '<project_root>\ProyectoFinal\Functions';
addpath(ruta_funciones);

% Cargar datos
vicon_data = loadVicon(ruta_datos);

field = fieldnames(vicon_data); 
n_files = length(field);

% Primer archivo como plantilla para extraer los nombres de las columnas. 
template_table = vicon_data.(field{1}); 
col_markers = template_table.Properties.VariableNames;
n_markers = length(col_markers); % Número de marcadores 

matriz_nans = zeros(n_files, n_markers);

for k = 1:n_files
    t = vicon_data.(field{k});
    data_matrix = table2array(t);
    matriz_nans(k,:) = any(isnan(data_matrix), 1);
end

reporte_nans = array2table(matriz_nans, 'VariableNames', col_markers,...
    'RowNames',field);


tabla_errores = findNaNs(vicon_data);
isequal(tabla_errores,reporte_nans)

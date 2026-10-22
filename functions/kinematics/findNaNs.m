function reporte_nans = findNaNs(vicon_data)
% FINDNANS Detecta la presencia de NaNs en las tablas de un struct.
%
%   Sintaxis:
%       reporte_nans = findNaNs(vicon_data)
%
%   Inputs:
%       vicon_data   - Estructura donde cada campo contiene una tabla de datos.
%
%   Outputs:
%       reporte_nans - Tabla lógica (Matriz de Diagnóstico) con el reporte de NaNs.
%                      (Filas: Archivos / Columnas: Marcadores)

% 1. Obtener los nombres de los archivos presentes en el struct
field = fieldnames(vicon_data); 
n_files = length(field);

% 2. Primer archivo como plantilla para extraer los nombres de las columnas
template_table = vicon_data.(field{1}); 
col_markers = template_table.Properties.VariableNames;
n_markers = length(col_markers); % Número de marcadores 

% 3. Preasignar la matriz de ceros (Filas: Archivos x Columnas: Marcadores)
matriz_nans = zeros(n_files, n_markers);

% 4. Bucle para evaluar archivo por archivo la presencia de NaNs
for k = 1:n_files
    t = vicon_data.(field{k});
    data_matrix = table2array(t);
    matriz_nans(k,:) = any(isnan(data_matrix), 1);
end

% 5. Construcción y asignación del formato final de tabla de reporte
reporte_nans = array2table(matriz_nans, 'VariableNames', col_markers,...
    'RowNames', field);

end
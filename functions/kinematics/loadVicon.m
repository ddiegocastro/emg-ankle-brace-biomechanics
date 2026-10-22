function vicon_data = loadVicon(ruta_datos)
% CARGAR_Y_LIMPIAR_VICON Carga archivos de Vicon y los estructura en un struct.
%
%   Sintaxis:
%       vicon_data = loadVicon(ruta_datos)
%
%   Inputs:
%       ruta_datos - String o vector de caracteres con la ruta absoluta de la carpeta.
%
%   Outputs:
%       vicon_data - Estructura donde cada campo es una tabla limpia con los marcadores.

    %% 1. Obtener y filtrar los archivos de la carpeta
    files = dir(fullfile(ruta_datos, '*.*'));
    files = files(~[files.isdir]); 

    % Inicializar el struct vacío de salida
    vicon_data = struct();

    %% 2. Construcción de los nombres de las columnas (Títulos)
    markers_names = {'LASI', 'RASI', 'LPSI', 'RPSI', 'LTHI', 'LKNE', 'LTIB', 'LANK', 'LHEE', ...
                     'LTOE', 'RTHI', 'RKNE', 'RTIB', 'RANK', 'RHEE', 'RTOE'}; % 16 Marcadores
    dim = 'XYZ';
    markers_dim = cell(1, length(markers_names) * 3);

    idx = 1; 
    for i = 1:length(markers_names)
        for j = 1:length(dim)
            markers_dim{idx} = [markers_names{i}, '_', dim(j)];
            idx = idx + 1; 
        end
    end

    % Combinación final de nombres para la tabla
    first_cols = {'Frame', 'Sub Frame'}; 
    cols_names = [first_cols, markers_dim, {'Trajectory Count'}];

    %% 3. Bucle principal: Carga, asignación de títulos y limpieza de tablas
    warning('off'); % Desactivar alertas temporales por nombres automáticos al leer
    
    for k = 1:length(files)
        % Construir ruta y leer tabla
        file_rute = fullfile(ruta_datos, files(k).name); 
        data_table = readtable(file_rute); 
        
        % Asignar los nombres de columnas construidos
        data_table.Properties.VariableNames = cols_names; 
        
        % Eliminar la primera fila de la tabla
        data_table(1, :) = [];
        
        % Eliminar la columna 1 ('Frame') y 2 ('Sub Frame') y la última columna ('Trajectory Count')
        data_table(:, [1, 2, end]) = [];
        
        % --- TIP BIOBIOMECÁNICO Opcional ---
        % Convertir los datos a tipo numérico si se importaron como texto
        % (Suele pasar si el archivo original de Vicon tenía filas de texto arriba)
        data_table = convertvars(data_table, data_table.Properties.VariableNames, 'double');
        
        % Obtener un nombre de campo válido para el struct (sin extensiones ni caracteres ilegales)
        [~, name, ~] = fileparts(files(k).name);
        valid_name = matlab.lang.makeValidName(name);
        
        % Guardar la tabla procesada en la estructura
        vicon_data.(valid_name) = data_table; 
    end
    
    warning('on'); % Reactivar alertas de MATLAB
end
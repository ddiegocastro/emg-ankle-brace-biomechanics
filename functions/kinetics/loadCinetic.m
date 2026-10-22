function cinetic_data = loadCinetic(ruta_archivo)
% LOADCINETIC Carga y limpia datos cinéticos de un directorio especificado.
%   cinetic_data = loadCinetic(ruta_archivo) lee todos los archivos en
%   la carpeta, extrae las columnas 3 a 20, aplica etiquetas estándar y
%   elimina las filas con valores faltantes (NaN).
%
%   Input:
%       ruta_archivo - String o vector de caracteres con la ruta a los datos.
%   Output:
%       cinetic_data - Struct con tablas limpias para cada archivo.

% Obtener la lista de archivos en el directorio
files = dir(fullfile(ruta_archivo, '*.*'));
files = files(~[files.isdir]); % Ignorar carpetas

% Inicializar el struct vacío
cinetic_data = struct();

% Etiquetas para las columnas 3 a la 20
cin_labels = {'R_Fx', 'R_Fy', 'R_Fz', 'R_Mx', 'R_My', 'R_Mz',...
    'R_Cx', 'R_Cy', 'R_Cz', 'L_Fx', 'L_Fy', 'L_Fz', 'L_Mx', 'L_My', 'L_Mz',...
    'L_Cx', 'L_Cy', 'L_Cz'};

% Desactivar warnings de readtable temporalmente
warning off

for k = 1:length(files)
    file_rute = fullfile(ruta_archivo, files(k).name); 

    % Leer los datos
    data = readtable(file_rute); 

    % Crear un nombre de variable válido para el struct
    [~, name, ~] = fileparts(files(k).name);
    valid_name = matlab.lang.makeValidName(name);

    % Limpieza de tabla (Directamente al cargar)
    if size(data, 2) >= 20
        % Extraer columnas 3 a la 20
        cinetic_table = data(:, 3:20);

        % Renombrar columnas
        cinetic_table.Properties.VariableNames = cin_labels;

        % Eliminar valores NaN
        cinetic_table = rmmissing(cinetic_table);

        % Guardar en el struct
        cinetic_data.(valid_name) = cinetic_table; 
    else
        warning('El archivo %s no tiene 20 columnas. Se omitió su lectura.', files(k).name);
    end
end

% Reactivar warnings
warning on
end
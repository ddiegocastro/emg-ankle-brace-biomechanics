function emg_data = loadEMG(ruta_datos)
% loadEMG Lee archivos de datos, extrae señales de EMG y limpia valores faltantes.
%
% INPUT:
%   ruta_datos - (String o Char) Ruta de la carpeta donde se encuentran los archivos.
%
% OUTPUT:
%   emg_data   - (Struct) Estructura con tablas limpias para cada archivo.

% 1. Verificar que la ruta exista para evitar errores
if ~isfolder(ruta_datos)
    error('La ruta especificada no existe: %s', ruta_datos);
end

% 2. Obtener la lista de archivos (omitiendo carpetas)
files = dir(fullfile(ruta_datos, '*.*'));
files = files(~[files.isdir]);

% Inicializar el struct de salida y definir los nombres de los sensores
emg_data = struct();
EMG_sensors = {'EMG2', 'EMG3', 'EMG4', 'EMG5', 'EMG6', 'EMG7'};

% 3. Procesar cada archivo
warning off % Apagamos warnings temporales que suele dar readtable
for k = 1:length(files)
    file_rute = fullfile(ruta_datos, files(k).name); 

    % Leer los datos
    data = readtable(file_rute); 

    % Generar un nombre válido para el campo del struct
    [~, name, ~] = fileparts(files(k).name);
    valid_name = matlab.lang.makeValidName(name);

    % Extraer solo las columnas 22 a 27
    emg_table = data(:, 22:27);

    % Renombrar las columnas
    emg_table.Properties.VariableNames = EMG_sensors;

    % Limpiar filas con NaNs (usando el método que vimos antes)
    emg_table = rmmissing(emg_table);

    % Guardar la tabla ya procesada en la estructura
    emg_data.(valid_name) = emg_table; 
end
warning on % Volvemos a encender los warnings

end
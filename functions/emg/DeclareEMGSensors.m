function emg_data = DeclareEMGSensors(emg_data, emg_sensors)
% DeclareEMGSensors Cambia los nombres de las variables (columnas) de las tablas dentro del struct.
%
% INPUT:
%   emg_data    - (Struct) Estructura que contiene las tablas con los datos EMG.
%   emg_sensors - (Cell of strings) Lista con los nuevos nombres para las columnas.
%
% OUTPUT:
%   emg_data    - (Struct) Estructura con los nombres de las columnas actualizados.

% 1. Validar que el número de nombres coincida con el número de columnas de las tablas
campos = fieldnames(emg_data);
if ~isempty(campos)
    num_columnas = width(emg_data.(campos{1}));
    if length(emg_sensors) ~= num_columnas
        error('El número de nombres en emg_sensors (%d) no coincide con el número de columnas en la tabla (%d).', ...
            length(emg_sensors), num_columnas);
    end
end

% 2. Recorrer el struct y renombrar las variables de cada tabla
for k = 1:length(campos)
    tabla_actual = emg_data.(campos{k});

    % Asignar los nuevos nombres usando 'Properties.VariableNames'
    tabla_actual.Properties.VariableNames = emg_sensors; 

    % Guardar la tabla actualizada de vuelta en el struct
    emg_data.(campos{k}) = tabla_actual; 
end

end
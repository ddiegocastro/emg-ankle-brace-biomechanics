function filtered_struct = FilterCineticData(cinetic_struct, fs, order)
% FILTERCINETICDATA Aplica un filtro Butterworth pasabajas a tablas dentro de un struct.
% Detecta automáticamente el tipo de movimiento ('Ep' o 'Sv') para asignar
% la frecuencia de corte adecuada (10 Hz o 50 Hz respectivamente).
%
%   filtered_struct = FilterCineticData(cinetic_struct, fs, order)
%
%   INPUTS:
%       cinetic_struct : Struct donde cada campo es una tabla de datos cinéticos.
%       fs             : Frecuencia de muestreo en Hz (ej. 2000).
%       order          : Orden EFECTIVO del filtro (opcional, por defecto 4).
%
%   OUTPUT:
%       filtered_struct: El mismo struct pero con los datos numéricos filtrados.

    % Valores por defecto
    if nargin < 3
        order = 4; % Orden efectivo deseado (estándar biomecánico)
    end

    % Dividimos el orden entre 2 porque filtfilt duplica el orden efectivo
    butter_order = round(order / 2); 
    
    % Inicializar la estructura de salida y obtener los nombres de los ensayos
    filtered_struct = cinetic_struct;
    campos_ensayos = fieldnames(cinetic_struct);

    % Iterar sobre cada ensayo (campo del struct)
    for i = 1:length(campos_ensayos)
        nombre_ensayo = campos_ensayos{i};
        tabla_datos = cinetic_struct.(nombre_ensayo);
        
        % =========================================================
        % DETECCIÓN AUTOMÁTICA DEL TIPO DE MOVIMIENTO
        % =========================================================
        if contains(nombre_ensayo, 'Ep', 'IgnoreCase', true)
            fc = 10; % Elevación de puntillas: 10 Hz
        elseif contains(nombre_ensayo, 'Sv', 'IgnoreCase', true)
            fc = 50; % Salto Vertical: 50 Hz (preserva el impacto)
        else
            % Si por alguna razón hay un archivo con otro nombre
            warning(['No se detectó "Ep" ni "Sv" en el ensayo: ', nombre_ensayo, '. Se usará 10 Hz por defecto para evitar perder datos de impacto.']);
            fc = 10; 
        end
        
        % Calcular los coeficientes del filtro para ESTA iteración específica
        Wn = fc / (fs / 2); 
        [b, a] = butter(butter_order, Wn, 'low');
        
        % =========================================================
        % FILTRADO DE COLUMNAS
        % =========================================================
        nombres_columnas = tabla_datos.Properties.VariableNames;
        
        for j = 1:length(nombres_columnas)
            col_name = nombres_columnas{j};
            datos_columna = tabla_datos.(col_name);
            
            % Criterio: Debe ser numérico y no ser columna de tiempo
            if isnumeric(datos_columna) && ~strcmpi(col_name, 'Time') && ...
               ~strcmpi(col_name, 'Tiempo') && ~strcmpi(col_name, 'Frame')
                
                % Aplicar filtfilt (Zero-phase filtering)
                tabla_datos.(col_name) = filtfilt(b, a, datos_columna);
            end
        end
        
        % Guardar la tabla ya filtrada de vuelta en el struct
        filtered_struct.(nombre_ensayo) = tabla_datos;
    end
end
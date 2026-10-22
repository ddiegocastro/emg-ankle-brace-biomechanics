function emg_data_env = GetLinearEnvelope(emg_data, fs)
% GetLinearEnvelope Calcula la envolvente lineal de las señales EMG.
% Asigna automáticamente la frecuencia de corte (fc) dependiendo
% del nombre del ensayo: 'EP' (6 Hz), 'SV' (12 Hz), 'RP' (6 Hz).
%
% INPUT:
%   emg_data - (Struct) Estructura con los datos EMG filtrados.
%   fs       - (Double) Frecuencia de muestreo en Hz (ej. 2000).
%
% OUTPUT:
%   emg_data_env - (Struct) Estructura con las envolventes lineales.

    emg_data_env = emg_data;
    field = fieldnames(emg_data_env);
    f_nyq = fs / 2;
    n = 2; % Filtro efectivo de 4to orden (filtfilt)

    for k = 1:length(field)
        nombre_ensayo = field{k};
        
        % 1. Determinar la frecuencia de corte (fc) leyendo el nombre
        if contains(nombre_ensayo, 'EP', 'IgnoreCase', true)
            fc = 6;
        elseif contains(nombre_ensayo, 'SV', 'IgnoreCase', true)
            fc = 12;
        elseif contains(nombre_ensayo, 'RP', 'IgnoreCase', true)
            fc = 6; % Para el reposo usamos 6 Hz
        else
            warning('El ensayo "%s" no contiene "EP", "SV" ni "RP". Se usará fc = 6 Hz por defecto.', nombre_ensayo);
            fc = 6; 
        end
        
        % 2. Diseñar el filtro pasa-bajas para la fc actual
        Wn = fc / f_nyq;
        [b, a] = butter(n, Wn, 'low'); 

        % 3. Procesar los datos
        tabla_actual = emg_data_env.(nombre_ensayo);
        datos_array = table2array(tabla_actual);

        % Rectificación de onda completa
        datos_rectificados = abs(datos_array);

        % Suavizado con la fc seleccionada
        datos_envolvente = filtfilt(b, a, datos_rectificados);

        % Reasignar a la tabla y al struct
        tabla_actual{:,:} = datos_envolvente;
        emg_data_env.(nombre_ensayo) = tabla_actual;
    end
end
function emg_data = filterEMG_BP(emg_data)
% filterEMG_BP Aplica un filtro Butterworth pasabandas (20-450 Hz) de 4to orden.
%
% INPUT:
%   emg_data - (Struct) Estructura que contiene las tablas con los datos EMG.
%
% OUTPUT:
%   emg_data - (Struct) Misma estructura con las señales ya filtradas.

% Parámetros del Filtro
fs = 2000;              % Frecuencia de muestreo (Hz)
f_nyq = fs / 2;         % Frecuencia de Nyquist
Wn = [20 450] / f_nyq;  % Frecuencias de corte normalizadas
n = 2;                  % Orden 2 en MATLAB equivale a 4to orden pasabandas

% Diseño del filtro Butterworth
[b, a] = butter(n, Wn, 'bandpass');

% Aplicar el filtro a cada campo del struct
field = fieldnames(emg_data);
for k = 1:length(field)
    tabla_actual = emg_data.(field{k});

    % Convertir, filtrar y reasignar
    datos_array = table2array(tabla_actual); 
    datos_filtrados = filtfilt(b, a, datos_array); 
    tabla_actual{:,:} = datos_filtrados;

    % Guardar de vuelta
    emg_data.(field{k}) = tabla_actual;
end
end
% Auto-exported from EMG/Prueba_FiltroPB.mlx (code cells only).

clear; close all; clc; 

ruta_datos = '<project_root>\ProyectoFinal\InputData\Injured\EMG y Cinetica'; 
ruta_funciones = '<project_root>\ProyectoFinal\Functions\EMG';
addpath(ruta_funciones);

emg_data = loadEMG(ruta_datos);

emg_data_filter = emg_data;
% Datos del Filtro
fs = 2000; 
f_nyq = fs/2; 
Wn = [20 450]/f_nyq; 
n = 2;

[b,a] = butter(n,Wn, 'bandpass');

field = fieldnames(emg_data_filter);
for k=1:length(field)
    tabla_actual = emg_data_filter.(field{k});
    datos_array = table2array(tabla_actual); 
    datos_filtrados = filtfilt(b,a, datos_array); 
    tabla_actual{:,:} = datos_filtrados;
    emg_data_filter.(field{k}) = tabla_actual;
end

emg_data_func = filterEMG_BP(emg_data);
isequal(emg_data_func, emg_data_filter)

% Auto-exported from EMG/Prueba_InputEMG.mlx (code cells only).

clear; close all; clc; 

ruta_datos = '<project_root>\ProyectoFinal\InputData\Injured\EMG y Cinetica'; 
ruta_funciones = '<project_root>\ProyectoFinal\Functions\EMG';
addpath(ruta_funciones);

files = dir(fullfile(ruta_datos, '*.*'));
files = files(~[files.isdir]);

emg_data = struct();

warning off
for k = 1:length(files)
    file_rute = fullfile(ruta_datos, files(k).name); 

    data = readtable(file_rute); 

    [~, name, ~] = fileparts(files(k).name);
    valid_name = matlab.lang.makeValidName(name);
    emg_data.(valid_name) = data; 
end
warning on 

% Limpieza de tablas
EMG_sensors = {'EMG2', 'EMG3', 'EMG4', 'EMG5', 'EMG6', 'EMG7'}; 

% Columna 22 a la 27 de los datos. 
n_measures = length(fieldnames(emg_data));
field = fieldnames(emg_data); 
for k=1:n_measures
    emg_table = emg_data.(field{k}); 
    emg_table = emg_table(:,22:27);
    emg_table.Properties.VariableNames = EMG_sensors;
    emg_table = rmmissing(emg_table);
    emg_data.(field{k}) = emg_table; 
end

emg_data_func = loadEMG(ruta_datos);
isequal(emg_data_func, emg_data);

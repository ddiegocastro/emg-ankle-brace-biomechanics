% Auto-exported from Cinematica/Prueba_Input.mlx (code cells only).

clear; close all; clc; 

% Dirección de datos 
ruta_datos = '<project_root>\ProyectoFinal\InputData\Injured\Vicon'; 

% Dirección de funciones. 
ruta_funciones = '<project_root>\ProyectoFinal\Functions\Cinematica';
addpath(ruta_funciones)

files = dir(fullfile(ruta_datos, '*.*'));
files = files(~[files.isdir]); 

vicon_data = struct();

% Carga de datos: 
warning off
for k = 1:length(files)
    file_rute = fullfile(ruta_datos, files(k).name); 
    
    data = readtable(file_rute); 
    
    [~, name, ~] = fileparts(files(k).name);
    valid_name = matlab.lang.makeValidName(name);
    vicon_data.(valid_name) = data; 
end
warning on 

% Limpieza de tablas: 
markers_names = {'LASI', 'RASI', 'LPSI', 'RPSI', 'LTHI', 'LKNE', 'LTIB', 'LANK', 'LHEE', ...
    'LTOE', 'RTHI', 'RKNE', 'RTIB', 'RANK', 'RHEE', 'RTOE'}; % 16 Marcadores.
markers_dim = cell(1, length(markers_names)*3);
dim = 'XYZ';

idx = 1; 
for i = 1:length(markers_names)
    for j = 1:length(dim)
        % Combinamos el nombre del marcador con la letra de la dimensión
        % Ejemplo: 'LASI' + '_' + 'X' -> 'LASI_X'
        markers_dim{idx} = [markers_names{i}, '_', dim(j)];
        
        idx = idx + 1; % Avanzamos a la siguiente celda
    end
end

first_cols = {'Frame', 'Sub Frame'}; 
cols_names = [first_cols markers_dim 'Trajectory Count'];

n_measures = length(fieldnames(vicon_data));
field = fieldnames(vicon_data);
for k=1:n_measures
    table = vicon_data.(field{k}); 
    table.Properties.VariableNames = cols_names; 
    table(1, :) = [];
    table(:, [2, end]) = [];
    vicon_data.(field{k}) = table; 
end

vicon_data_2 = loadVicon(ruta_datos);
isequaln(vicon_data, vicon_data_2); 

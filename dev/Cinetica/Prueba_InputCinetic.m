% Auto-exported from Cinetica/Prueba_InputCinetic.mlx (code cells only).

clear; close all; clc; 

ruta_datos = '<project_root>\ProyectoFinal\InputData\Injured\EMG y Cinetica'; 
ruta_funciones = '<project_root>\ProyectoFinal\Functions\Cinetica';
addpath(ruta_funciones);

files = dir(fullfile(ruta_datos, '*.*'));
files = files(~[files.isdir]);

cinetic_data = struct();

warning off
for k = 1:length(files)
    file_rute = fullfile(ruta_datos, files(k).name); 

    data = readtable(file_rute); 

    [~, name, ~] = fileparts(files(k).name);
    valid_name = matlab.lang.makeValidName(name);
    cinetic_data.(valid_name) = data; 
end
warning on

% Limpieza de Tablas: 
cin_labels = {'P1_Fx', 'P1_Fy', 'P1_Fz', 'P1_Mx', 'P1_My', 'P1_Mz',...
    'P1_Cx', 'P1_Cy', 'P1_Cz', 'P2_Fx', 'P2_Fy', 'P2_Fz', 'P2_Mx', 'P2_My', 'P2_Mz',...
    'P2_Cx', 'P2_Cy', 'P2_Cz'};
% Columna 3 a la 20 de los datos. 
n_measures = length(fieldnames(cinetic_data));
field = fieldnames(cinetic_data); 
for k=1:n_measures
    cinetic_table = cinetic_data.(field{k}); 
    cinetic_table = cinetic_table(:, 3:20);
    cinetic_table.Properties.VariableNames = cin_labels;
    cinetic_table = rmmissing(cinetic_table);
    cinetic_data.(field{k}) = cinetic_table; 
end

% Auto-exported from EMG/Prueba_NameEMGSensors.mlx (code cells only).

clear; close all; clc; 

ruta_datos = '<project_root>\ProyectoFinal\InputData\Injured\EMG y Cinetica'; 
ruta_funciones = '<project_root>\ProyectoFinal\Functions\EMG';
addpath(ruta_funciones);

emg_data = loadEMG(ruta_datos);
emg_data_filter = filterEMG_BP(emg_data);

emg_sensors = {'L_TA', 'L_SL', 'L_GR', 'R_TA', 'R_SL', 'R_GR'};
field = fieldnames(emg_data_filter); 
for k = 1:length(field)
    tabla_actual = emg_data_filter.(field{k});
    tabla_actual.Properties.VariableNames = emg_sensors; 
    emg_data_filter.(field{k}) = tabla_actual; 
end

emg_data_func = DeclareEMGSensors(emg_data_filter, emg_sensors); 
isequal(emg_data_func, emg_data_filter)

% Auto-exported from Prueba_Fs.mlx (code cells only).

clear; close all; clc; 

ruta_datos_INJ = '<project_root>\ProyectoFinal\InputData\Injured\Cinetica'; 
ruta_datos_CTRL = '<project_root>\ProyectoFinal\InputData\Control\Cinetica'; 
ruta_funciones = '<project_root>\ProyectoFinal\Functions\Cinetica';
addpath(ruta_funciones);

cinetic_data_INJ = loadCinetic(ruta_datos_INJ); 
cinetic_data_CTRL = loadCinetic(ruta_datos_CTRL);

fs = getFs(cinetic_data_INJ, cinetic_data_CTRL);

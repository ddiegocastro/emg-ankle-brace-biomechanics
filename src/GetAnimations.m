% Auto-exported from GetAnimations.mlx (code cells only).

%% =========================================================================
%% ANÁLISIS CINEMÁTICO Y CINÉTICO DE MIEMBRO INFERIOR (TOBILLO DERECHO)
%% =========================================================================
clear; clc; close all; 

rng(42); % Semilla para controlar repetibilidad de modelos de imputación. 

% --- RUTAS DE ACCESO ---
ruta_datos_INJ  = '<project_root>\ProyectoFinal\InputData\Injured\Vicon'; 
ruta_datos_CTRL  = '<project_root>\ProyectoFinal\InputData\Control\Vicon';
ruta_funciones = '<project_root>\ProyectoFinal\Functions\Cinematica';
addpath(ruta_funciones);

disp('--- PROCESANDO SUJETO LESIONADO (INJ) ---');
vicon_data_INJ           = loadVicon(ruta_datos_INJ);
nans_table_INJ           = findNaNs(vicon_data_INJ);
predictors_dict_INJ      = findPredictors(vicon_data_INJ, nans_table_INJ);
modelos_entrenados_INJ   = trainMarkers(vicon_data_INJ, predictors_dict_INJ); 
vicon_data_corrected_INJ = imputateData(vicon_data_INJ, modelos_entrenados_INJ);

disp('--- PROCESANDO SUJETO CONTROL (CTRL) ---');
vicon_data_CTRL           = loadVicon(ruta_datos_CTRL);
nans_table_CTRL           = findNaNs(vicon_data_CTRL);
predictors_dict_CTRL      = findPredictors(vicon_data_CTRL, nans_table_CTRL); 
modelos_entrenados_CTRL   = trainMarkers(vicon_data_CTRL, predictors_dict_CTRL);
vicon_data_corrected_CTRL = imputateData(vicon_data_CTRL, modelos_entrenados_CTRL);

ruta_resultados = '<project_root>\ProyectoFinal\Resultados\Cinematica\AnimacionModelosNoCorregidos'; 
ruta_videos_INJ = fullfile(ruta_resultados, 'Videos', 'INJ');
ruta_videos_CTRL = fullfile(ruta_resultados, 'Videos', 'CTRL');
% animateSkeleton(vicon_data_corrected_INJ, ruta_videos_INJ);

% animateSkeleton(vicon_data_corrected_CTRL, ruta_videos_CTRL);

% fields = fieldnames(vicon_data_INJ)
% fields = fields(1:6)
% vicon_data_INJ_SV = rmfield(vicon_data_INJ, fields)
animateSkeleton(vicon_data_INJ_SV, ruta_videos_INJ);

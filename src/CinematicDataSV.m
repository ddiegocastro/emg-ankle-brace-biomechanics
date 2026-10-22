% Auto-exported from CinematicDataSV.mlx (code cells only).

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

fs = 100; 

% A. Ángulos de posición (Filtro Butterworth 6Hz integrado)
vicon_data_angles_INJ = calculateAnkleAngles(vicon_data_corrected_INJ, fs); 
vicon_data_angles_CTRL = calculateAnkleAngles(vicon_data_corrected_CTRL, fs); 

% B. Velocidad y Aceleración Angular (Derivación numérica + Filtro de suavizado)
vicon_data_kinetics_INJ = calculateJumpKinetics(vicon_data_angles_INJ, fs);
vicon_data_kinetics_CTRL = calculateJumpKinetics(vicon_data_angles_CTRL, fs);

% --- 5.1 POSICIÓN ANGULAR ---
% Nota el cambio a 'Sv' y la escala angular ligeramente ampliada
med_pos_INJ = calculateMedianKinematics(vicon_data_kinetics_INJ, 'Sv', 'R_Ankle_Angle');
med_pos_CTRL = calculateMedianKinematics(vicon_data_kinetics_CTRL, 'Sv', 'R_Ankle_Angle');
plotMedianKinematics(med_pos_INJ, med_pos_CTRL, 'Sv', 'Posición Angular (Salto)', 'Ángulo (Grados)', [-50 30]);

% --- 5.2 VELOCIDAD ANGULAR ---
% Límites amplios para capturar el pico de despegue
med_vel_INJ = calculateMedianKinematics(vicon_data_kinetics_INJ, 'Sv', 'R_Ankle_Velocity');
med_vel_CTRL = calculateMedianKinematics(vicon_data_kinetics_CTRL, 'Sv', 'R_Ankle_Velocity');
plotMedianKinematics(med_vel_INJ, med_vel_CTRL, 'Sv', 'Velocidad Angular (Salto)', 'Velocidad (Grados/s)', [-800 800]);

% --- 5.3 ACELERACIÓN ANGULAR ---
% Límites muy altos para capturar el impacto
med_acc_INJ = calculateMedianKinematics(vicon_data_kinetics_INJ, 'Sv', 'R_Ankle_Acceleration');
med_acc_CTRL = calculateMedianKinematics(vicon_data_kinetics_CTRL, 'Sv', 'R_Ankle_Acceleration');
plotMedianKinematics(med_acc_INJ, med_acc_CTRL, 'Sv', 'Aceleración Angular (Salto)', 'Aceleración (Grados/s^2)', [-5000 5000]);

%--- 6.1 Cinemática Angular (Desde Curvas Medianas Segmentadas) ---
table_INJ_ST = extractJumpFeatures(vicon_data_kinetics_INJ, 'ST', fs);
table_INJ_CT = extractJumpFeatures(vicon_data_kinetics_INJ, 'CT', fs);

% --- EXTRACCIÓN PARA EL SUJETO CONTROL (CTRL) ---
table_CTRL_ST = extractJumpFeatures(vicon_data_kinetics_CTRL, 'ST', fs);
table_CTRL_CT = extractJumpFeatures(vicon_data_kinetics_CTRL, 'CT', fs);

table_INJ_cinematica = [table_INJ_CT; table_INJ_ST];
table_CTRL_cinematica = [table_CTRL_CT; table_CTRL_ST];

table_INJ_cinematica.Trial_Name = []; 
table_CTRL_cinematica.Trial_Name = [];

% --- 6.2 Cinemática Espacial 3D (Desde Datos Globales Originales) ---
marcador_referencia = 'RANK'; 
% 
% spatial_INJ_ST = calculateSpatialMetrics(vicon_data_corrected_INJ, marcador_referencia, 'ST');
% spatial_CTRL_ST = calculateSpatialMetrics(vicon_data_corrected_CTRL, marcador_referencia, 'ST');
% spatial_INJ_CT = calculateSpatialMetrics(vicon_data_corrected_INJ, marcador_referencia, 'CT');
% spatial_CTRL_CT = calculateSpatialMetrics(vicon_data_corrected_CTRL, marcador_referencia, 'CT');

% fprintf('\n========================================================================================================\n');
% fprintf('                               REPORTE BIOMECÁNICO COMPLETO: SALTO VERTICAL\n');
% fprintf('========================================================================================================\n');
% fprintf('%-34s | %-19s | %-19s | %-19s | %-19s\n', 'Métrica Clínica', 'Lesionado ST (INJ)', 'Control ST (CTRL)', 'Lesionado CT (INJ)', 'Control CT (CTRL)');
% fprintf('--------------------------------------------------------------------------------------------------------\n');
% % Datos Espaciales Puros (Eje Z, X, Y)
% fprintf('%-34s | %7.2f cm          | %7.2f cm          | %7.2f cm          | %7.2f cm\n', 'Altura Real del Salto (Z)', spatial_INJ_ST.altura_salto_cm, spatial_CTRL_ST.altura_salto_cm, spatial_INJ_CT.altura_salto_cm, spatial_CTRL_CT.altura_salto_cm);
% fprintf('%-34s | %7.2f mm          | %7.2f mm          | %7.2f mm          | %7.2f mm\n', 'Desfase Aterrizaje X (AP)', spatial_INJ_ST.delta_X_mm, spatial_CTRL_ST.delta_X_mm, spatial_INJ_CT.delta_X_mm, spatial_CTRL_CT.delta_X_mm);
% fprintf('%-34s | %7.2f mm          | %7.2f mm          | %7.2f mm          | %7.2f mm\n', 'Desfase Aterrizaje Y (ML)', spatial_INJ_ST.delta_Y_mm, spatial_CTRL_ST.delta_Y_mm, spatial_INJ_CT.delta_Y_mm, spatial_CTRL_CT.delta_Y_mm);
% fprintf('%-34s | %7.2f cm          | %7.2f cm          | %7.2f cm          | %7.2f cm\n', 'Distancia Total de Deriva', spatial_INJ_ST.distancia_total_cm, spatial_CTRL_ST.distancia_total_cm, spatial_INJ_CT.distancia_total_cm, spatial_CTRL_CT.distancia_total_cm);
% fprintf('--------------------------------------------------------------------------------------------------------\n');
% % Datos de Dinámica Angular
% fprintf('%-34s | %7.2f º/s         | %7.2f º/s         | %7.2f º/s         | %7.2f º/s\n', 'Pico Vel. Angular Empuje', ft_INJ_ST.pico_vel_empuje, ft_CTRL_ST.pico_vel_empuje, ft_INJ_CT.pico_vel_empuje, ft_CTRL_CT.pico_vel_empuje);
% fprintf('%-34s | %7.2f º/s         | %7.2f º/s         | %7.2f º/s         | %7.2f º/s\n', 'Pico Vel. Angular Aterrizaje', ft_INJ_ST.pico_vel_aterrizaje, ft_CTRL_ST.pico_vel_aterrizaje, ft_INJ_CT.pico_vel_aterrizaje, ft_CTRL_CT.pico_vel_aterrizaje);
% fprintf('%-34s | %7.2f º/s²        | %7.2f º/s²        | %7.2f º/s²        | %7.2f º/s²\n', 'Aceleración Angular Impacto', ft_INJ_ST.pico_acc_impacto, ft_CTRL_ST.pico_acc_impacto, ft_INJ_CT.pico_acc_impacto, ft_CTRL_CT.pico_acc_impacto);
% fprintf('%-34s | %7.2f seg         | %7.2f seg         | %7.2f seg         | %7.2f seg\n', 'Tiempo Estabilización Post-Impacto', ft_INJ_ST.tiempo_estabilizacion_seg, ft_CTRL_ST.tiempo_estabilizacion_seg, ft_INJ_CT.tiempo_estabilizacion_seg, ft_CTRL_CT.tiempo_estabilizacion_seg);
% fprintf('========================================================================================================\n');

disp('--- CONSTRUYENDO TABLA MAESTRA Y EJECUTANDO ESTADÍSTICA ---');

% 8.1 Extraer datos de todos los ensayos individuales (Filtrando solo 'Sv')
tabla_INJ = extractAllTrialsFeatures(vicon_data_kinetics_INJ, vicon_data_corrected_INJ, 'INJ', marcador_referencia, fs, 'Sv');
tabla_CTRL = extractAllTrialsFeatures(vicon_data_kinetics_CTRL, vicon_data_corrected_CTRL, 'CTRL', marcador_referencia, fs, 'Sv');

tabla_INJ.Pico_Vel_Empuje = []; 
tabla_INJ.Pico_Vel_Aterrizaje = []; 
tabla_INJ.Acc_Impacto = []; 
tabla_INJ.Tiempo_Estabilizacion = []; 
tabla_CTRL.Pico_Vel_Empuje = []; 
tabla_CTRL.Pico_Vel_Aterrizaje = []; 
tabla_CTRL.Acc_Impacto = []; 
tabla_CTRL.Tiempo_Estabilizacion = []; 

% 8.2 Tabla Maestra
table_master = [tabla_INJ table_INJ_cinematica; tabla_CTRL table_CTRL_cinematica];
disp(table_master);

ruta_resultados = '<project_root>\ProyectoFinal\Resultados\Cinematica\SV'; 
nombre_archivo = 'TablaMaestra_Salto_Vertical.csv';
ruta_completa = fullfile(ruta_resultados, nombre_archivo);
writetable(table_master, ruta_completa);

% 8.3 Ejecutar el Análisis Estadístico
resultados_estadisticos = calculateJumpKinematicStatistics(table_master);

% 8.4 Desplegar tabla en consola
disp(' ')
disp('=== RESULTADOS ESTADÍSTICOS (VALORES P - WILCOXON) ===')
disp(resultados_estadisticos); 

ruta_resultados = '<project_root>\ProyectoFinal\Resultados\Cinematica\SV'; 
nombre_archivo = 'ResultadosEstadisticos_Salto_Vertical.csv';
ruta_completa = fullfile(ruta_resultados, nombre_archivo);
writetable(resultados_estadisticos, ruta_completa);

disp(['Tabla guardada exitosamente en: ', ruta_completa]);

% Auto-exported from CinematicDataEP.mlx (code cells only).

%% =========================================================================
%% ANÁLISIS CINEMÁTICO Y CINÉTICO DE MIEMBRO INFERIOR (TOBILLO DERECHO)
%% =========================================================================
clear; clc; close all; 

rng(42); % Semilla para controlar repetibilidad de modelos de imputación. 

% --- RUTAS DE ACCESO ---
ruta_datos_INJ  = '<project_root>\ProyectoFinal\InputData\Injured\Vicon'; 
ruta_datos_CTRL  = '<project_root>\ProyectoFinal\InputData\Control\Vicon';
ruta_funciones = '<project_root>\ProyectoFinal\Functions';
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

fs = getFs(vicon_data_corrected_INJ, vicon_data_corrected_CTRL); 

% A. Ángulos de posición (Filtro Butterworth 6Hz integrado)
vicon_data_angles_INJ = calculateAnkleAngles(vicon_data_corrected_INJ, fs); 
vicon_data_angles_CTRL = calculateAnkleAngles(vicon_data_corrected_CTRL, fs); 

vicon_data_angles_INJ = appendInversionEversionAngle(vicon_data_corrected_INJ, vicon_data_angles_INJ);
vicon_data_angles_CTRL = appendInversionEversionAngle(vicon_data_corrected_CTRL, vicon_data_angles_CTRL);

% B. Velocidad y Aceleración Angular (Derivación numérica + Filtro de suavizado)
vicon_data_kinetics_INJ = calculateAnkleKinetics(vicon_data_angles_INJ, fs);
vicon_data_kinetics_CTRL = calculateAnkleKinetics(vicon_data_angles_CTRL, fs);

% Grafica las curvas individuales de posición (ST vs CT / Intersujeto)
plotAnkleComparisons(vicon_data_kinetics_INJ, vicon_data_kinetics_CTRL, 'EP');

disp('================ GENERANDO GRÁFICAS DE TENDENCIA CENTRAL ================');

% --- 5.1 POSICIÓN ANGULAR ---
med_pos_INJ = calculateMedianKinematics(vicon_data_kinetics_INJ, 'EP', 'R_Ankle_Angle');
med_pos_CTRL = calculateMedianKinematics(vicon_data_kinetics_CTRL, 'EP', 'R_Ankle_Angle');
plotMedianKinematics(med_pos_INJ, med_pos_CTRL, 'EP', 'Posición Angular', 'Ángulo (Grados)', [-35 15]);

% --- 5.2 VELOCIDAD ANGULAR ---
med_vel_INJ = calculateMedianKinematics(vicon_data_kinetics_INJ, 'EP', 'R_Ankle_Velocity');
med_vel_CTRL = calculateMedianKinematics(vicon_data_kinetics_CTRL, 'EP', 'R_Ankle_Velocity');
plotMedianKinematics(med_vel_INJ, med_vel_CTRL, 'EP', 'Velocidad Angular', 'Velocidad (Grados/s)', [-60 60]);

% --- 5.3 ACELERACIÓN ANGULAR ---
med_acc_INJ = calculateMedianKinematics(vicon_data_kinetics_INJ, 'EP', 'R_Ankle_Acceleration');
med_acc_CTRL = calculateMedianKinematics(vicon_data_kinetics_CTRL, 'EP', 'R_Ankle_Acceleration');
plotMedianKinematics(med_acc_INJ, med_acc_CTRL, 'EP', 'Aceleración Angular', 'Aceleración (Grados/s^2)', [-150 150]);

% --- 5.4 POSICIÓN ANGULAR INV EV ---
med_posev_INJ = calculateMedianKinematics(vicon_data_kinetics_INJ, 'EP', 'R_Inv_Ev_Angle');
med_posev_CTRL = calculateMedianKinematics(vicon_data_kinetics_CTRL, 'EP', 'R_Inv_Ev_Angle');
plotMedianKinematics(med_posev_INJ, med_posev_CTRL, 'EP', 'Posición Angular (Inv/Ev)', 'Ángulo (Grados)', [5 20])
disp('-> Todo el flujo se ejecutó de forma correcta. Gráficas listas.');

% Extraer tablas por sujeto
tabla_metricas_INJ = extractKinematicFeatures(vicon_data_kinetics_INJ, 'INJ', 'EP');
tabla_metricas_CTRL = extractKinematicFeatures(vicon_data_kinetics_CTRL, 'CTRL', 'EP');

% Concatenar en una sola Base de Datos Maestra
master_kinematic_table = [tabla_metricas_INJ; tabla_metricas_CTRL];

% Mostrar los primeros resultados en consola
disp('Tabla Maestra de Métricas Biomecánicas Extraídas:');
disp(master_kinematic_table);

% writetable(master_kinematic_table, 'Resultados_Biomecanicos_EP.xlsx');

ruta_resultados = '<project_root>\ProyectoFinal\Resultados\Cinematica\EP'; 
nombre_archivo = 'TablaMaestra_Elevacion_Puntillas.csv';
ruta_completa = fullfile(ruta_resultados, nombre_archivo);
writetable(master_kinematic_table, ruta_completa);

% Calcular los p-values usando la prueba de suma de rangos de Wilcoxon
tabla_estadistica = calculateKinematicStatistics(master_kinematic_table);

disp('Valores p (p-values) para las métricas cinemáticas:');
disp('(Valores p < 0.05 indican una diferencia estadísticamente significativa)');
disp('-------------------------------------------------------------------------');
disp(tabla_estadistica);

% writetable(tabla_estadistica, 'Resultados_Estadisticos_EP.xlsx');

ruta_resultados = '<project_root>\ProyectoFinal\Resultados\Cinematica\EP'; 
nombre_archivo = 'ResultadosEstadisticos_Elevacion_Puntillas.csv';
ruta_completa = fullfile(ruta_resultados, nombre_archivo);
writetable(tabla_estadistica, ruta_completa);

disp(['Tabla guardada exitosamente en: ', ruta_completa]);

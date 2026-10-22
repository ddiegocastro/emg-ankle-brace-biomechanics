% Auto-exported from EMGDataEP.mlx (code cells only).

clear; close all; clc; 

% 1. Configurar rutas
ruta_datos_INJ = '<project_root>\ProyectoFinal\InputData\Injured\EMG'; 
ruta_datos_HC = '<project_root>\ProyectoFinal\InputData\Control\EMG'; 

ruta_funciones = '<project_root>\ProyectoFinal\Functions\EMG';
addpath(ruta_funciones);

% Parámetros del experimento
fs = 2000;
colnames = {'L_TA', 'L_SL', 'L_GR', 'R_TA', 'R_SL', 'R_GR'};

emg_data_INJ = loadEMG(ruta_datos_INJ);

% Procesamiento de la señal
emg_data_filter_INJ = filterEMG_BP(emg_data_INJ);                    % Filtro Butterworth
emg_data_filter_INJ = DeclareEMGSensors(emg_data_filter_INJ, colnames); % Renombrar columnas

% Extraer la Envolvente Lineal
emg_data_env_INJ = GetLinearEnvelope(emg_data_filter_INJ, fs);

% Normalización (% Máximo Dinámico)
[emg_data_norm_INJ, picos_voltaje_INJ] = NormalizeEMGPk(emg_data_env_INJ);

% Mostrar los voltajes máximos en consola
disp('Picos máximos encontrados (en Volts) para normalizar:');
disp(picos_voltaje_INJ);

% PlotEMG(emg_data_norm_INJ, fs);

emg_data_CTRL = loadEMG(ruta_datos_HC); 

% Procesamiento de la señal
emg_data_filter_CTRL = filterEMG_BP(emg_data_CTRL);                    % Filtro Butterworth
emg_data_filter_CTRL = DeclareEMGSensors(emg_data_filter_CTRL, colnames); % Renombrar columnas

% Extraer la Envolvente Lineal
emg_data_env_CTRL = GetLinearEnvelope(emg_data_filter_CTRL, fs);

% Normalización (% Máximo Dinámico)
[emg_data_norm_CTRL, picos_voltaje_CTRL] = NormalizeEMGPk(emg_data_env_CTRL);

% Mostrar los voltajes máximos en consola
disp('Picos máximos encontrados (en Volts) para normalizar:');
disp(picos_voltaje_CTRL);

% 5. Visualizar resultados (Ahora estarán en escala de 0 a 100)
% PlotEMG(emg_data_norm_INJ, fs);

% PlotEMG(emg_data_norm_CTRL, fs);

tabla_activacion_EP_INJ = GetSustainedActivation(emg_data_norm_INJ, fs);
tabla_activacion_EP_CTRL = GetSustainedActivation(emg_data_norm_CTRL, fs);

disp('--- SUJETO LESIONADO: Activación Sostenida (EP) [% Max] ---');
disp(tabla_activacion_EP_INJ);

disp('--- SUJETO CONTROL: Activación Sostenida (EP) [% Max] ---');
disp(tabla_activacion_EP_CTRL);

stats_intra_activacion_INJ = GetDescriptiveStats(tabla_activacion_EP_INJ); 
stats_intra_activacion_CTRL = GetDescriptiveStats(tabla_activacion_EP_CTRL); 


disp('=== ESTADÍSTICA: ACTIVACIÓN Sujeto Lesionado (INJ) ===');
disp(stats_intra_activacion_INJ);

disp('=== ESTADÍSTICA: ACTIVACIÓN Sujeto Control (CTRL) ===');
disp(stats_intra_activacion_CTRL);

stats_inter_Activacion = GetInterSubjectStats(tabla_activacion_EP_INJ, tabla_activacion_EP_CTRL, 'INJ_Lesionado', 'CTRL_Control');

disp('=== ESTADÍSTICA INTER-SUJETO: Comparación Activación Sostenida ===');
disp(stats_inter_Activacion);

tabla_cci_EP_INJ = GetCoContractionEP(emg_data_env_INJ, fs);
tabla_cci_EP_CTRL = GetCoContractionEP(emg_data_env_CTRL, fs);

disp('--- [Sujeto Lesionado] Índice de Co-contracción (CCI) [%] ---');
disp(tabla_cci_EP_INJ);
disp('--- [Sujeto Control] Índice de Co-contracción (CCI) [%] ---');
disp(tabla_cci_EP_CTRL);

stats_cci_INJ = GetDescriptiveStats(tabla_cci_EP_INJ);
stats_cci_CTRL = GetDescriptiveStats(tabla_cci_EP_CTRL);

disp('=== ESTADÍSTICA: CCI Sujeto Lesionado (INJ) ===');
disp(stats_cci_INJ);

disp('=== ESTADÍSTICA: CCI Sujeto Control (CTRL) ===');
disp(stats_cci_CTRL);

stats_inter_CCI = GetInterSubjectStats(tabla_cci_EP_INJ, tabla_cci_EP_CTRL, 'INJ_Lesionado', 'CTRL_Control');

disp('=== ESTADÍSTICA INTER-SUJETO: Comparación CCI (INJ vs CTRL) ===');
disp(stats_inter_CCI);

% =========================================================================
% ANÁLISIS INTRASUJETO (Con Tobillera vs Sin Tobillera)
% =========================================================================

% 1. Estadística Intrasujeto para Activación Sostenida
stats_intra_activacion_INJ = GetIntraSubjectStats(tabla_activacion_EP_INJ, 'INJ_Lesionado'); 
stats_intra_activacion_CTRL = GetIntraSubjectStats(tabla_activacion_EP_CTRL, 'CTRL_Control'); 

disp('=== ESTADÍSTICA INTRASUJETO: ACTIVACIÓN Sujeto Lesionado (INJ) ===');
disp(stats_intra_activacion_INJ);

disp('=== ESTADÍSTICA INTRASUJETO: ACTIVACIÓN Sujeto Control (CTRL) ===');
disp(stats_intra_activacion_CTRL);

% 2. Estadística Intrasujeto para Índice de Co-contracción (CCI)
stats_cci_intra_INJ = GetIntraSubjectStats(tabla_cci_EP_INJ, 'INJ_Lesionado');
stats_cci_intra_CTRL = GetIntraSubjectStats(tabla_cci_EP_CTRL, 'CTRL_Control');

disp('=== ESTADÍSTICA INTRASUJETO: CCI Sujeto Lesionado (INJ) ===');
disp(stats_cci_intra_INJ);

disp('=== ESTADÍSTICA INTRASUJETO: CCI Sujeto Control (CTRL) ===');
disp(stats_cci_intra_CTRL);

% =========================================================================
% EXPORTAR RESULTADOS A EXCEL
% =========================================================================
disp('Guardando resultados en Excel...');

% Definir el nombre del archivo de salida (puedes cambiar la ruta si lo deseas)
nombre_archivo_excel = 'Resultados_EMG_ProyectoFinal.xlsx';

% 1. Guardar Activación Intra-sujeto
writetable(stats_intra_activacion_INJ, nombre_archivo_excel, 'Sheet', 'Activacion_Intra_INJ');
writetable(stats_intra_activacion_CTRL, nombre_archivo_excel, 'Sheet', 'Activacion_Intra_CTRL');

% 2. Guardar CCI Intra-sujeto
writetable(stats_cci_intra_INJ, nombre_archivo_excel, 'Sheet', 'CCI_Intra_INJ');
writetable(stats_cci_intra_CTRL, nombre_archivo_excel, 'Sheet', 'CCI_Intra_CTRL');

% 3. Guardar Análisis Inter-sujeto (Comparación INJ vs CTRL)
writetable(stats_inter_Activacion, nombre_archivo_excel, 'Sheet', 'InterSujeto_Activacion');
writetable(stats_inter_CCI, nombre_archivo_excel, 'Sheet', 'InterSujeto_CCI');

disp(['¡Listo! Todos los resultados se han guardado exitosamente en el archivo: ', nombre_archivo_excel]);

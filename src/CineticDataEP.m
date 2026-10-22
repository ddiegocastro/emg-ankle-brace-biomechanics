% Auto-exported from CineticDataEP.mlx (code cells only).

clear; close all; clc; 

ruta_datos_INJ = '<project_root>\ProyectoFinal\InputData\Injured\Cinetica'; 
ruta_datos_CTRL = '<project_root>\ProyectoFinal\InputData\Control\Cinetica'; 

ruta_funciones_cinetic = '<project_root>\ProyectoFinal\Functions\Cinetica';
addpath(ruta_funciones_cinetic);

cinetic_data_INJ = loadCinetic(ruta_datos_INJ);
cinetic_data_CTRL = loadCinetic(ruta_datos_CTRL); 

% Parámetros del experimento
fs = 2000; % Frecuencia de muestreo (Hz)

% Filtrar datos
cinetic_data_INJ = FilterCineticData(cinetic_data_INJ, fs, 4);
cinetic_data_CTRL = FilterCineticData(cinetic_data_CTRL, fs, 4);


% =========================================================================
% 4. OBTENCIÓN DE MÉTRICAS CLÍNICAS (Elevación de Puntillas)
% =========================================================================

% Procesar Sujeto Lesionado (INJ)
tabla_kinetics_EP_INJ = GetEPKinetics(cinetic_data_INJ, fs);

% Procesar Sujeto Control (CTRL)
tabla_kinetics_EP_CTRL = GetEPKinetics(cinetic_data_CTRL, fs);

% =========================================================================
% 5. VISUALIZACIÓN DE RESULTADOS EN CONSOLA
% =========================================================================

disp('===================================================================');
disp('   CINÉTICA EP: SUJETO LESIONADO (INJ) - Distribución y CoP Sway    ');
disp('===================================================================');
disp(tabla_kinetics_EP_INJ);

disp(' ');
disp('===================================================================');
disp('    CINÉTICA EP: SUJETO CONTROL (CTRL) - Distribución y CoP Sway     ');
disp('===================================================================');
disp(tabla_kinetics_EP_CTRL);

% =========================================================================
% 6. ANÁLISIS ESTADÍSTICO Y TAMAÑO DEL EFECTO (d de Cohen)
% =========================================================================

% Llamamos a la función de estadística pasando ambas tablas
tabla_estadistica_EP = CompareEP_CohenD(tabla_kinetics_EP_CTRL, tabla_kinetics_EP_INJ);

disp(' ');
disp('===================================================================');
disp('   ESTADÍSTICA EP: TAMAÑO DEL EFECTO (Control vs Lesionado)        ');
disp('===================================================================');
disp(tabla_estadistica_EP);

% =========================================================================
% OBTENCIÓN DE MÉTRICAS DINÁMICAS (Salto Vertical)
% =========================================================================

% Procesar Sujeto Lesionado (INJ)
tabla_kinetics_SV_INJ = GetSVKinetics(cinetic_data_INJ);

% Procesar Sujeto Control (CTRL)
tabla_kinetics_SV_CTRL = GetSVKinetics(cinetic_data_CTRL);

% Visualización en consola
disp(' ');
disp('===================================================================');
disp('      CINÉTICA SV: SUJETO LESIONADO (INJ) - Fuerza Máxima y LSI     ');
disp('===================================================================');
disp(tabla_kinetics_SV_INJ);

disp(' ');
disp('===================================================================');
disp('       CINÉTICA SV: SUJETO CONTROL (CTRL) - Fuerza Máxima y LSI      ');
disp('===================================================================');
disp(tabla_kinetics_SV_CTRL);

% =========================================================================
% 8. ANÁLISIS ESTADÍSTICO SV Y TAMAÑO DEL EFECTO (d de Cohen)
% =========================================================================

% Llamamos a la función de estadística pasando ambas tablas dinámicas
tabla_estadistica_SV = CompareSV_CohenD(tabla_kinetics_SV_CTRL, tabla_kinetics_SV_INJ);

disp(' ');
disp('===================================================================');
disp('   ESTADÍSTICA SV: TAMAÑO DEL EFECTO (Control vs Lesionado)        ');
disp('===================================================================');
disp(tabla_estadistica_SV);

% =========================================================================
% 9. ANÁLISIS INTRASUJETO: EFECTO DE LA ORTESIS (Tobillera vs Sin Tobillera)
% =========================================================================

% Evaluamos el efecto en el Sujeto Lesionado (INJ) para Elevación de Puntillas
efecto_ortesis_EP_INJ = CompareCondition_CohenD(tabla_kinetics_EP_INJ, '_ct_', '_st_');

% Evaluamos el efecto en el Sujeto Lesionado (INJ) para Salto Vertical
efecto_ortesis_SV_INJ = CompareCondition_CohenD(tabla_kinetics_SV_INJ, '_ct_', '_st_');


disp(' ');
disp('===================================================================');
disp(' EFECTO DE LA ORTESIS EN EP (Sujeto INJ): Con Tobillera vs Sin Tobillera ');
disp('===================================================================');
disp(efecto_ortesis_EP_INJ);

disp(' ');
disp('===================================================================');
disp(' EFECTO DE LA ORTESIS EN SV (Sujeto INJ): Con Tobillera vs Sin Tobillera ');
disp('===================================================================');
disp(efecto_ortesis_SV_INJ);

% Evaluamos el efecto en el Sujeto Lesionado (INJ) para Elevación de Puntillas
efecto_ortesis_EP_CTRL = CompareCondition_CohenD(tabla_kinetics_EP_CTRL, '_ct_', '_st_');

% Evaluamos el efecto en el Sujeto Lesionado (INJ) para Salto Vertical
efecto_ortesis_SV_CTRL = CompareCondition_CohenD(tabla_kinetics_SV_CTRL, '_ct_', '_st_');


disp(' ');
disp('===================================================================');
disp(' EFECTO DE LA ORTESIS EN EP (Sujeto CTRL): Con Tobillera vs Sin Tobillera ');
disp('===================================================================');
disp(efecto_ortesis_EP_CTRL);

disp(' ');
disp('===================================================================');
disp(' EFECTO DE LA ORTESIS EN SV (Sujeto CTRL): Con Tobillera vs Sin Tobillera ');
disp('===================================================================');
disp(efecto_ortesis_SV_CTRL);

% =========================================================================
% 10. VISUALIZACIÓN GRÁFICA MEDIANTE FUNCIONES
% =========================================================================

% ELEVACIÓN DE PUNTILLAS 
% 10.1 Curvas Medianas de Distribución de Carga (Elevación de Puntillas)
% Usamos el struct original. Comparamos Sin Tobillera vs Con Tobillera para INJ.
% PlotEnsembleLoadEP(cinetic_data_INJ, '_st_', 'Lesionado (INJ)', fs);
% PlotEnsembleLoadEP(cinetic_data_INJ, '_ct_', 'Lesionado (INJ)', fs);
% 
% % Si quieres ver el comportamiento del Control, descomenta la siguiente línea:
% PlotEnsembleLoadEP(cinetic_data_CTRL, '_st_', 'Control (CTRL)', fs);
% PlotEnsembleLoadEP(cinetic_data_CTRL, '_ct_', 'Control (CTRL)', fs);

% PlotEnsembleCoPEP(cinetic_data_INJ, '_st_', 'Lesionado (INJ)', fs);
% PlotEnsembleCoPEP(cinetic_data_INJ, '_ct_', 'Lesionado (INJ)', fs);
% 
% % % Para el control (descomenta si lo necesitas visualizar)
% PlotEnsembleCoPEP(cinetic_data_CTRL, '_st_', 'Control (CTRL)', fs);
% PlotEnsembleCoPEP(cinetic_data_CTRL, '_ct_', 'Control (CTRL)', fs);

% % % Graficar el comportamiento general del Sujeto Lesionado (INJ) - Sin Tobillera
% % PlotEnsembleFzSV(cinetic_data_INJ, '_st_', 'INJ (Lesionado)', fs);
% % 
% % % Graficar el comportamiento general del Sujeto Lesionado (INJ) - Con Tobillera
% % PlotEnsembleFzSV(cinetic_data_INJ, '_ct_', 'INJ (Lesionado)', fs);
% % 
% % % Graficar el comportamiento general del Sujeto Control (CTRL) - Sin Tobillera
% % PlotEnsembleFzSV(cinetic_data_CTRL, '_st_', 'CTRL (Control)', fs);
% % 
% % % Graficar el comportamiento general del Sujeto Control (CTRL) - Con Tobillera
% % PlotEnsembleFzSV(cinetic_data_CTRL, '_ct_', 'CTRL (Control)', fs);

% % Simetría en Salto Vertical - Sujeto Lesionado Sin Tobillera
% PlotSymmetryFz(cinetic_data_INJ, 'Sv', '_st_', 'Lesionado (INJ)', fs);
% 
% % Simetría en Salto Vertical - Sujeto Lesionado Con Tobillera
% PlotSymmetryFz(cinetic_data_INJ, 'Sv', '_ct_', 'Lesionado (INJ)', fs);
% 
% % Simetría en Salto Vertical - Sujeto Lesionado Sin Tobillera
% PlotSymmetryFz(cinetic_data_CTRL, 'Sv', '_st_', 'Control (CTRL)', fs);
% 
% % Simetría en Salto Vertical - Sujeto Lesionado Con Tobillera
% PlotSymmetryFz(cinetic_data_CTRL, 'Sv', '_ct_', 'Control (CTRL)', fs);

% =========================================================================
% 11. EXPORTACIÓN DE RESULTADOS A EXCEL (.xlsx)
% =========================================================================
disp('Guardando resultados en archivo de Excel...');

% Definir el nombre del archivo de salida
nombre_archivo_excel = 'Reporte_Cinetica_Final.xlsx';

% 1. Guardar tablas descriptivas de Elevación de Puntillas (EP)
writetable(tabla_kinetics_EP_INJ, nombre_archivo_excel, 'Sheet', 'Cinética EP (Lesionado INJ)', 'WriteRowNames', true);
writetable(tabla_kinetics_EP_CTRL, nombre_archivo_excel, 'Sheet', 'Cinética EP (Control CTRL)', 'WriteRowNames', true);

% 2. Guardar tablas descriptivas de Salto Vertical (SV)
writetable(tabla_kinetics_SV_INJ, nombre_archivo_excel, 'Sheet', 'Cinética SV (Lesionado INJ)', 'WriteRowNames', true);
writetable(tabla_kinetics_SV_CTRL, nombre_archivo_excel, 'Sheet', 'Cinética SV (Control CTRL)', 'WriteRowNames', true);

% 3. Guardar estadística Inter-Sujeto (Tamaño del Efecto Control vs Lesionado)
writetable(tabla_estadistica_EP, nombre_archivo_excel, 'Sheet', 'Stats EP (Inter-Sujeto)', 'WriteRowNames', true);
writetable(tabla_estadistica_SV, nombre_archivo_excel, 'Sheet', 'Stats SV (Inter-Sujeto)', 'WriteRowNames', true);

% 4. Guardar estadística Intra-Sujeto (Efecto de la Ortesis / Tobillera)
% INJ (Lesionado)
writetable(efecto_ortesis_EP_INJ, nombre_archivo_excel, 'Sheet', 'Stats Ortesis INJ (EP)', 'WriteRowNames', true);
writetable(efecto_ortesis_SV_INJ, nombre_archivo_excel, 'Sheet', 'Stats Ortesis INJ (SV)', 'WriteRowNames', true);

% CTRL (Control)
writetable(efecto_ortesis_EP_CTRL, nombre_archivo_excel, 'Sheet', 'Stats Ortesis CTRL (EP)', 'WriteRowNames', true);
writetable(efecto_ortesis_SV_CTRL, nombre_archivo_excel, 'Sheet', 'Stats Ortesis CTRL (SV)', 'WriteRowNames', true);

disp(['¡Éxito! Todos los datos han sido exportados a: ', nombre_archivo_excel]);

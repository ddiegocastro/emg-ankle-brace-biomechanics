% Auto-exported from EMG/Prueba_EnvolventeEMG.mlx (code cells only).

clear; close all; clc; 

% 1. Configurar rutas
ruta_datos = '<project_root>\ProyectoFinal\InputData\Injured\EMG y Cinetica'; 
ruta_datos_HC = '<project_root>\ProyectoFinal\InputData\Control\EMG y Cinetica'; 

ruta_funciones = '<project_root>\ProyectoFinal\Functions\EMG';
addpath(ruta_funciones);

emg_data = loadEMG(ruta_datos);

% 2. Parámetros del experimento
fs = 2000;
colnames = {'L_TA', 'L_SL', 'L_GR', 'R_TA', 'R_SL', 'R_GR'}; 

% 3. Procesamiento de la señal
emg_data_filter = filterEMG_BP(emg_data);                    % Filtro Butterworth
emg_data_filter = DeclareEMGSensors(emg_data_filter, colnames); % Renombrar columnas

% 4. Extraer la Envolvente Lineal
emg_data_env = GetLinearEnvelope(emg_data_filter, fs);

% 5. Visualizar resultados
PlotEMG(emg_data_env, fs);

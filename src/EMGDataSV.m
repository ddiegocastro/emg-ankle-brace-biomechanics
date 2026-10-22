% Auto-exported from EMGDataSV.mlx (code cells only).

% =========================================================================
% Datos EMG - Salto Vertical (SV) con Normalización Cruzada y Tamaño del Efecto
% =========================================================================
clear; close all; clc; 

% =========================================================================
% 1. Configurar rutas
% =========================================================================
ruta_datos_INJ = '<project_root>\ProyectoFinal\InputData\Injured\EMG'; 
ruta_datos_cinetic_INJ = '<project_root>\ProyectoFinal\InputData\Injured\Cinetica'; 
ruta_datos_HC = '<project_root>\ProyectoFinal\InputData\Control\EMG'; 
ruta_datos_cinetic_CTRL = '<project_root>\ProyectoFinal\InputData\Control\Cinetica'; 

ruta_funciones = '<project_root>\ProyectoFinal\Functions\EMG';
ruta_funciones_cinetic = '<project_root>\ProyectoFinal\Functions\Cinetica';
addpath(ruta_funciones_cinetic);
addpath(ruta_funciones);

% Parámetros del experimento
fs = 2000;
colnames = {'L_TA', 'L_SL', 'L_GR', 'R_TA', 'R_SL', 'R_GR'};

% =========================================================================
% 2. Cargar Datos y Procesamiento de Señal
% =========================================================================
emg_data_INJ = loadEMG(ruta_datos_INJ); 
emg_data_filter_INJ = filterEMG_BP(emg_data_INJ);
emg_data_filter_INJ = DeclareEMGSensors(emg_data_filter_INJ, colnames);
emg_data_env_INJ = GetLinearEnvelope(emg_data_filter_INJ, fs);

emg_data_CTRL = loadEMG(ruta_datos_HC); 
emg_data_filter_CTRL = filterEMG_BP(emg_data_CTRL);
emg_data_filter_CTRL = DeclareEMGSensors(emg_data_filter_CTRL, colnames);
emg_data_env_CTRL = GetLinearEnvelope(emg_data_filter_CTRL, fs);

% =========================================================================
% 3. NORMALIZACIÓN CRUZADA (Salto Vertical normalizado con picos de Ep)
% =========================================================================
[~, picos_INJ] = NormalizeEMGPk(emg_data_env_INJ);
[~, picos_CTRL] = NormalizeEMGPk(emg_data_env_CTRL);

emg_data_norm_INJ = emg_data_env_INJ;
emg_data_norm_CTRL = emg_data_env_CTRL;

% Normalización Sujeto Lesionado (INJ)
fields_INJ = fieldnames(emg_data_env_INJ);
for k = 1:length(fields_INJ)
    if startsWith(fields_INJ{k}, 'Sv', 'IgnoreCase', true)
        matriz_cruda = table2array(emg_data_env_INJ.(fields_INJ{k}));
        if isfield(picos_INJ, 'Ep')
            matriz_norm = (matriz_cruda ./ picos_INJ.Ep) * 100;
        elseif isfield(picos_INJ, 'EP')
            matriz_norm = (matriz_cruda ./ picos_INJ.EP) * 100;
        else
            matriz_norm = (matriz_cruda ./ picos_INJ.Sv) * 100; 
        end
        emg_data_norm_INJ.(fields_INJ{k}){:,:} = matriz_norm;
    end
end

% Normalización Sujeto Control (CTRL)
fields_CTRL = fieldnames(emg_data_env_CTRL);
for k = 1:length(fields_CTRL)
    if startsWith(fields_CTRL{k}, 'Sv', 'IgnoreCase', true)
        matriz_cruda = table2array(emg_data_env_CTRL.(fields_CTRL{k}));
        if isfield(picos_CTRL, 'Ep')
            matriz_norm = (matriz_cruda ./ picos_CTRL.Ep) * 100;
        elseif isfield(picos_CTRL, 'EP')
            matriz_norm = (matriz_cruda ./ picos_CTRL.EP) * 100;
        else
            matriz_norm = (matriz_cruda ./ picos_CTRL.Sv) * 100;
        end
        emg_data_norm_CTRL.(fields_CTRL{k}){:,:} = matriz_norm;
    end
end

% =========================================================================
% 4. IDENTIFICACIÓN DE FASES DEL SALTO
% =========================================================================
cinetic_data_INJ = loadCinetic(ruta_datos_cinetic_INJ); 
cinetic_data_CTRL = loadCinetic(ruta_datos_cinetic_CTRL);

fases_INJ = DetectJumpPhases(cinetic_data_INJ, fs);
fases_CTRL = DetectJumpPhases(cinetic_data_CTRL, fs);

% =========================================================================
% 5. EXTRACCIÓN DE MÉTRICAS CLÍNICAS (EMG)
% =========================================================================
tabla_act_SV_INJ = GetSVActivation(emg_data_norm_INJ, fases_INJ);
tabla_cci_SV_INJ = GetSVCoContraction(emg_data_norm_INJ, fases_INJ, fs);

tabla_act_SV_CTRL = GetSVActivation(emg_data_norm_CTRL, fases_CTRL);
tabla_cci_SV_CTRL = GetSVCoContraction(emg_data_norm_CTRL, fases_CTRL, fs);

% =========================================================================
% 6. CORRECCIÓN METODOLÓGICA (SIMETRÍA SUJETO CONTROL)
% =========================================================================
[tabla_act_SV_CTRL, tabla_cci_SV_CTRL] = FixControlSymmetry(tabla_act_SV_CTRL, tabla_cci_SV_CTRL);

% =========================================================================
% 7. REPORTE ESTADÍSTICO BIOMECÁNICO CLÍNICO
% =========================================================================
clc;
disp('===================================================================');
disp('          REPORTE CLÍNICO AVANZADO: SALTO VERTICAL (SV)            ');
disp('===================================================================');

% --- A. Intra-sujeto: Efecto de la Tobillera (CT vs ST) ---
disp('>>> 1. ANÁLISIS INTRA-SUJETO: SIN TOBILLERA (ST) vs CON TOBILLERA (CT)');
RunIntraStats(tabla_act_SV_INJ, 'Sujeto Lesionado (INJ) - Activación Propulsión (%EP)');
RunIntraStats(tabla_cci_SV_INJ, 'Sujeto Lesionado (INJ) - Co-contracción Aterrizaje (CCI)');

% ¡NUEVO! Análisis Intra-sujeto para el Control
RunIntraStats(tabla_act_SV_CTRL, 'Sujeto Control (CTRL) - Activación Propulsión (%EP)');
RunIntraStats(tabla_cci_SV_CTRL, 'Sujeto Control (CTRL) - Co-contracción Aterrizaje (CCI)');

% --- B. Inter-sujeto: Control vs Lesionado ---
disp(' ');
disp('>>> 2. ANÁLISIS INTER-SUJETO: CONTROL (CTRL) vs LESIONADO (INJ)');
RunInterStats(tabla_act_SV_INJ, tabla_act_SV_CTRL, 'Activación Propulsión (%EP) - General');
RunInterStats(tabla_cci_SV_INJ, tabla_cci_SV_CTRL, 'Co-contracción Aterrizaje (CCI) - General');


% =========================================================================
% 8. EXPORTACIÓN DE RESULTADOS (SIN ALTERAR FUNCIONES ORIGINALES)
% =========================================================================
disp('Guardando resultados en archivos (Excel y Texto)...');

% -------------------------------------------------------------------------
% A. Guardar las Tablas Base en Excel (.xlsx)
% -------------------------------------------------------------------------
nombre_archivo_excel = 'Resultados_EMG_SaltoVertical_DatosBase.xlsx';

% Tablas de Activación SV
writetable(tabla_act_SV_INJ, nombre_archivo_excel, 'Sheet', 'Activacion_SV_Lesionado', 'WriteRowNames', true);
writetable(tabla_act_SV_CTRL, nombre_archivo_excel, 'Sheet', 'Activacion_SV_Control', 'WriteRowNames', true);

% Tablas de Co-contracción (CCI) SV
writetable(tabla_cci_SV_INJ, nombre_archivo_excel, 'Sheet', 'CCI_SV_Lesionado', 'WriteRowNames', true);
writetable(tabla_cci_SV_CTRL, nombre_archivo_excel, 'Sheet', 'CCI_SV_Control', 'WriteRowNames', true);

disp(['Tablas base exportadas a: ', nombre_archivo_excel]);

% -------------------------------------------------------------------------
% B. Capturar y Guardar el Reporte Clínico (Consola) en Texto (.txt)
% -------------------------------------------------------------------------
nombre_archivo_texto = 'Reporte_Estadistico_Consola_SV.txt';

% Se activa el diario para que todo lo que salga en consola se guarde en el txt
diary(nombre_archivo_texto);

disp('===================================================================');
disp('          REPORTE CLÍNICO AVANZADO: SALTO VERTICAL (SV)            ');
disp('===================================================================');

% --- A. Intra-sujeto: Efecto de la Tobillera (CT vs ST) ---
disp('>>> 1. ANÁLISIS INTRA-SUJETO: SIN TOBILLERA (ST) vs CON TOBILLERA (CT)');
RunIntraStats(tabla_act_SV_INJ, 'Sujeto Lesionado (INJ) - Activación Propulsión (%EP)');
RunIntraStats(tabla_cci_SV_INJ, 'Sujeto Lesionado (INJ) - Co-contracción Aterrizaje (CCI)');
RunIntraStats(tabla_act_SV_CTRL, 'Sujeto Control (CTRL) - Activación Propulsión (%EP)'); % Agregado
RunIntraStats(tabla_cci_SV_CTRL, 'Sujeto Control (CTRL) - Co-contracción Aterrizaje (CCI)'); % Agregado

% --- B. Inter-sujeto: Control vs Lesionado ---
disp(' ');
disp('>>> 2. ANÁLISIS INTER-SUJETO: CONTROL (CTRL) vs LESIONADO (INJ)');
RunInterStats(tabla_act_SV_INJ, tabla_act_SV_CTRL, 'Activación Propulsión (%EP) - General');
RunInterStats(tabla_cci_SV_INJ, tabla_cci_SV_CTRL, 'Co-contracción Aterrizaje (CCI) - General');

% Se apaga el diario
diary off;

disp(['Reporte estadístico de consola exportado a: ', nombre_archivo_texto]);
disp('¡Proceso de exportación finalizado exitosamente!');

% =========================================================================
% 9. CÁLCULO EXTERNO DE COHEN Y EXPORTACIÓN (EXCEL Y CSV)
% =========================================================================
disp('Calculando el d de Cohen externamente y guardando en Excel/CSV...');

nombre_excel_cohen = 'Resultados_Estadisticos_CohenD_SV.xlsx';

% --- 1. Calcular Cohen's d: INTRA-SUJETO (Activación) ---
vars_act = tabla_act_SV_INJ.Properties.VariableNames(2:end);
idx_ct_INJ = contains(tabla_act_SV_INJ.Ensayo, '_ct_', 'IgnoreCase', true);
idx_st_INJ = contains(tabla_act_SV_INJ.Ensayo, '_st_', 'IgnoreCase', true);
idx_ct_CTRL = contains(tabla_act_SV_CTRL.Ensayo, '_ct_', 'IgnoreCase', true);
idx_st_CTRL = contains(tabla_act_SV_CTRL.Ensayo, '_st_', 'IgnoreCase', true);

Resultados_Intra_Act_INJ = table();
Resultados_Intra_Act_CTRL = table();

for i = 1:length(vars_act)
    v = vars_act{i};
    % Para Lesionado (INJ)
    g1_INJ = tabla_act_SV_INJ.(v)(idx_ct_INJ);
    g2_INJ = tabla_act_SV_INJ.(v)(idx_st_INJ);
    d_val_INJ = calcularCohenD(g1_INJ, g2_INJ);
    Resultados_Intra_Act_INJ = [Resultados_Intra_Act_INJ; {string(v), mean(g2_INJ,'omitnan'), mean(g1_INJ,'omitnan'), d_val_INJ, string(interpretarCohen(d_val_INJ))}];
    
    % Para Control (CTRL)
    g1_CTRL = tabla_act_SV_CTRL.(v)(idx_ct_CTRL);
    g2_CTRL = tabla_act_SV_CTRL.(v)(idx_st_CTRL);
    d_val_CTRL = calcularCohenD(g1_CTRL, g2_CTRL);
    Resultados_Intra_Act_CTRL = [Resultados_Intra_Act_CTRL; {string(v), mean(g2_CTRL,'omitnan'), mean(g1_CTRL,'omitnan'), d_val_CTRL, string(interpretarCohen(d_val_CTRL))}];
end
Resultados_Intra_Act_INJ.Properties.VariableNames = {'Variable_Act', 'Media_ST_INJ', 'Media_CT_INJ', 'Cohen_d', 'Interpretacion'};
Resultados_Intra_Act_CTRL.Properties.VariableNames = {'Variable_Act', 'Media_ST_CTRL', 'Media_CT_CTRL', 'Cohen_d', 'Interpretacion'};

% --- 2. Calcular Cohen's d: INTRA-SUJETO (CCI) ---
vars_cci = tabla_cci_SV_INJ.Properties.VariableNames(2:end);
Resultados_Intra_CCI_INJ = table();
Resultados_Intra_CCI_CTRL = table();

for i = 1:length(vars_cci)
    v = vars_cci{i};
    % Para Lesionado (INJ)
    g1_INJ = tabla_cci_SV_INJ.(v)(idx_ct_INJ);
    g2_INJ = tabla_cci_SV_INJ.(v)(idx_st_INJ);
    d_val_INJ = calcularCohenD(g1_INJ, g2_INJ);
    Resultados_Intra_CCI_INJ = [Resultados_Intra_CCI_INJ; {string(v), mean(g2_INJ,'omitnan'), mean(g1_INJ,'omitnan'), d_val_INJ, string(interpretarCohen(d_val_INJ))}];
    
    % Para Control (CTRL)
    g1_CTRL = tabla_cci_SV_CTRL.(v)(idx_ct_CTRL);
    g2_CTRL = tabla_cci_SV_CTRL.(v)(idx_st_CTRL);
    d_val_CTRL = calcularCohenD(g1_CTRL, g2_CTRL);
    Resultados_Intra_CCI_CTRL = [Resultados_Intra_CCI_CTRL; {string(v), mean(g2_CTRL,'omitnan'), mean(g1_CTRL,'omitnan'), d_val_CTRL, string(interpretarCohen(d_val_CTRL))}];
end
Resultados_Intra_CCI_INJ.Properties.VariableNames = {'Variable_CCI', 'Media_ST_INJ', 'Media_CT_INJ', 'Cohen_d', 'Interpretacion'};
Resultados_Intra_CCI_CTRL.Properties.VariableNames = {'Variable_CCI', 'Media_ST_CTRL', 'Media_CT_CTRL', 'Cohen_d', 'Interpretacion'};

% --- 3. Calcular Cohen's d: INTER-SUJETO (Activación) ---
Resultados_Inter_Act = table();
for i = 1:length(vars_act)
    v = vars_act{i};
    g1 = tabla_act_SV_INJ.(v); 
    g2 = tabla_act_SV_CTRL.(v); 
    d_val = calcularCohenD(g1, g2);
    Resultados_Inter_Act = [Resultados_Inter_Act; {string(v), mean(g2,'omitnan'), mean(g1,'omitnan'), d_val, string(interpretarCohen(d_val))}];
end
Resultados_Inter_Act.Properties.VariableNames = {'Variable_Act', 'Media_Control_CTRL', 'Media_Lesionado_INJ', 'Cohen_d', 'Interpretacion'};

% --- 4. Calcular Cohen's d: INTER-SUJETO (CCI) ---
Resultados_Inter_CCI = table();
for i = 1:length(vars_cci)
    v = vars_cci{i};
    g1 = tabla_cci_SV_INJ.(v);
    g2 = tabla_cci_SV_CTRL.(v);
    d_val = calcularCohenD(g1, g2);
    Resultados_Inter_CCI = [Resultados_Inter_CCI; {string(v), mean(g2,'omitnan'), mean(g1,'omitnan'), d_val, string(interpretarCohen(d_val))}];
end
Resultados_Inter_CCI.Properties.VariableNames = {'Variable_CCI', 'Media_Control_CTRL', 'Media_Lesionado_INJ', 'Cohen_d', 'Interpretacion'};

% --- 5. Exportar a Excel (.xlsx) en diferentes pestañas ---
writetable(Resultados_Intra_Act_INJ, nombre_excel_cohen, 'Sheet', 'Intra_Act_INJ');
writetable(Resultados_Intra_Act_CTRL, nombre_excel_cohen, 'Sheet', 'Intra_Act_CTRL'); % Agregado
writetable(Resultados_Intra_CCI_INJ, nombre_excel_cohen, 'Sheet', 'Intra_CCI_INJ');
writetable(Resultados_Intra_CCI_CTRL, nombre_excel_cohen, 'Sheet', 'Intra_CCI_CTRL'); % Agregado
writetable(Resultados_Inter_Act, nombre_excel_cohen, 'Sheet', 'Inter_Activacion');
writetable(Resultados_Inter_CCI, nombre_excel_cohen, 'Sheet', 'Inter_CCI');

% --- 6. Exportar a CSV (Consolidado) ---
% Concatenamos las tablas verticalmente asegurándonos de que los nombres de variables coincidan genéricamente
Tabla_CSV_Intra_INJ = renamevars(Resultados_Intra_Act_INJ, {'Variable_Act', 'Media_ST_INJ', 'Media_CT_INJ'}, {'Variable', 'Media_ST', 'Media_CT'});
Tabla_CSV_Intra_CCI_INJ = renamevars(Resultados_Intra_CCI_INJ, {'Variable_CCI', 'Media_ST_INJ', 'Media_CT_INJ'}, {'Variable', 'Media_ST', 'Media_CT'});

Tabla_CSV_Intra_CTRL = renamevars(Resultados_Intra_Act_CTRL, {'Variable_Act', 'Media_ST_CTRL', 'Media_CT_CTRL'}, {'Variable', 'Media_ST', 'Media_CT'});
Tabla_CSV_Intra_CCI_CTRL = renamevars(Resultados_Intra_CCI_CTRL, {'Variable_CCI', 'Media_ST_CTRL', 'Media_CT_CTRL'}, {'Variable', 'Media_ST', 'Media_CT'});

% Se agregan etiquetas para diferenciar en el CSV consolidado
Tabla_CSV_Intra_INJ.Sujeto = repmat("INJ_Lesionado", height(Tabla_CSV_Intra_INJ), 1);
Tabla_CSV_Intra_CCI_INJ.Sujeto = repmat("INJ_Lesionado", height(Tabla_CSV_Intra_CCI_INJ), 1);
Tabla_CSV_Intra_CTRL.Sujeto = repmat("CTRL_Control", height(Tabla_CSV_Intra_CTRL), 1);
Tabla_CSV_Intra_CCI_CTRL.Sujeto = repmat("CTRL_Control", height(Tabla_CSV_Intra_CCI_CTRL), 1);

Tabla_CSV_Intra_Completo = [Tabla_CSV_Intra_INJ; Tabla_CSV_Intra_CCI_INJ; Tabla_CSV_Intra_CTRL; Tabla_CSV_Intra_CCI_CTRL];

Tabla_CSV_Inter_Act = renamevars(Resultados_Inter_Act, 'Variable_Act', 'Variable');
Tabla_CSV_Inter_CCI = renamevars(Resultados_Inter_CCI, 'Variable_CCI', 'Variable');
Tabla_CSV_Inter_Completo = [Tabla_CSV_Inter_Act; Tabla_CSV_Inter_CCI];

writetable(Tabla_CSV_Intra_Completo, 'Intra_Sujeto_SV.csv');
writetable(Tabla_CSV_Inter_Completo, 'Inter_Sujeto_SV.csv');

disp(['¡Proceso finalizado! Se guardaron: ', nombre_excel_cohen, ' y los archivos .csv.']);

% =========================================================================
% 8. CÁLCULO EXTERNO DE COHEN Y EXPORTACIÓN (EXCEL Y CSV)
% =========================================================================
disp('Calculando el d de Cohen externamente y guardando en Excel/CSV...');

nombre_excel = 'Resultados_Estadisticos_CohenD_SV.xlsx';
nombre_csv = 'Resultados_Estadisticos_CohenD_SV.csv';

% --- 1. Calcular Cohen's d: INTRA-SUJETO (Activación) ---
vars_act = tabla_act_SV_INJ.Properties.VariableNames(2:end);
idx_ct = contains(tabla_act_SV_INJ.Ensayo, '_ct_', 'IgnoreCase', true);
idx_st = contains(tabla_act_SV_INJ.Ensayo, '_st_', 'IgnoreCase', true);

Resultados_Intra_Act = table();
for i = 1:length(vars_act)
    v = vars_act{i};
    g1 = tabla_act_SV_INJ.(v)(idx_ct); % Grupo 1: Con Tobillera
    g2 = tabla_act_SV_INJ.(v)(idx_st); % Grupo 2: Sin Tobillera
    d_val = calcularCohenD(g1, g2);   % Usa tu función que está al final del código
    interp = interpretarCohen(d_val);
    Resultados_Intra_Act = [Resultados_Intra_Act; {string(v), mean(g2,'omitnan'), mean(g1,'omitnan'), d_val, string(interp)}];
end
Resultados_Intra_Act.Properties.VariableNames = {'Variable_Act', 'Media_ST', 'Media_CT', 'Cohen_d', 'Interpretacion'};

% --- 2. Calcular Cohen's d: INTRA-SUJETO (CCI) ---
vars_cci = tabla_cci_SV_INJ.Properties.VariableNames(2:end);
Resultados_Intra_CCI = table();
for i = 1:length(vars_cci)
    v = vars_cci{i};
    g1 = tabla_cci_SV_INJ.(v)(idx_ct);
    g2 = tabla_cci_SV_INJ.(v)(idx_st);
    d_val = calcularCohenD(g1, g2);
    interp = interpretarCohen(d_val);
    Resultados_Intra_CCI = [Resultados_Intra_CCI; {string(v), mean(g2,'omitnan'), mean(g1,'omitnan'), d_val, string(interp)}];
end
Resultados_Intra_CCI.Properties.VariableNames = {'Variable_CCI', 'Media_ST', 'Media_CT', 'Cohen_d', 'Interpretacion'};

% --- 3. Calcular Cohen's d: INTER-SUJETO (Activación) ---
Resultados_Inter_Act = table();
for i = 1:length(vars_act)
    v = vars_act{i};
    g1 = tabla_act_SV_INJ.(v); % Grupo 1: Lesionado
    g2 = tabla_act_SV_CTRL.(v); % Grupo 2: Control
    d_val = calcularCohenD(g1, g2);
    interp = interpretarCohen(d_val);
    Resultados_Inter_Act = [Resultados_Inter_Act; {string(v), mean(g2,'omitnan'), mean(g1,'omitnan'), d_val, string(interp)}];
end
Resultados_Inter_Act.Properties.VariableNames = {'Variable_Act', 'Media_Control_CTRL', 'Media_Lesionado_INJ', 'Cohen_d', 'Interpretacion'};

% --- 4. Calcular Cohen's d: INTER-SUJETO (CCI) ---
Resultados_Inter_CCI = table();
for i = 1:length(vars_cci)
    v = vars_cci{i};
    g1 = tabla_cci_SV_INJ.(v);
    g2 = tabla_cci_SV_CTRL.(v);
    d_val = calcularCohenD(g1, g2);
    interp = interpretarCohen(d_val);
    Resultados_Inter_CCI = [Resultados_Inter_CCI; {string(v), mean(g2,'omitnan'), mean(g1,'omitnan'), d_val, string(interp)}];
end
Resultados_Inter_CCI.Properties.VariableNames = {'Variable_CCI', 'Media_Control_CTRL', 'Media_Lesionado_INJ', 'Cohen_d', 'Interpretacion'};

% --- 5. Exportar a Excel (.xlsx) en diferentes pestañas ---
writetable(Resultados_Intra_Act, nombre_excel, 'Sheet', 'Intra_Activacion');
writetable(Resultados_Intra_CCI, nombre_excel, 'Sheet', 'Intra_CCI');
writetable(Resultados_Inter_Act, nombre_excel, 'Sheet', 'Inter_Activacion');
writetable(Resultados_Inter_CCI, nombre_excel, 'Sheet', 'Inter_CCI');


% --- 6. Exportar a CSV (Consolidado) ---
% Como los CSV no soportan pestañas, concatenamos las tablas verticalmente de forma sencilla
Tabla_CSV_Intra = [Resultados_Intra_Act; Resultados_Intra_CCI];
Tabla_CSV_Inter = [Resultados_Inter_Act; Resultados_Inter_CCI];

writetable(Tabla_CSV_Intra, 'Intra_Sujeto_SV.csv');
writetable(Tabla_CSV_Inter, 'Inter_Sujeto_SV.csv');

disp(['¡Proceso finalizado! Se guardaron: ', nombre_excel, ' y los archivos .csv.']);

% =========================================================================
% --- FUNCIONES AUXILIARES DE ESTADÍSTICA Y PROCESAMIENTO ---
% =========================================================================

function [tabla_act_out, tabla_cci_out] = FixControlSymmetry(tabla_act_in, tabla_cci_in)
    % Duplica los datos de la extremidad izquierda a la derecha en el sujeto control
    tabla_act_out = tabla_act_in;
    tabla_act_out.R_Gastrocnemio = tabla_act_out.L_Gastrocnemio;
    tabla_act_out.R_TricepsSural = tabla_act_out.L_TricepsSural;
    
    tabla_cci_out = tabla_cci_in;
    tabla_cci_out.R_CCI_Landing = tabla_cci_out.L_CCI_Landing;
end

function RunIntraStats(tabla, titulo)
    % Analiza descriptivamente el cambio clínico provocado por la tobillera (n=3 vs n=2)
    disp('-------------------------------------------------------------------');
    disp([' CLINICO INTRA: ', titulo]);
    disp('-------------------------------------------------------------------');
    
    idx_ct = contains(tabla.Ensayo, '_ct_', 'IgnoreCase', true);
    idx_st = contains(tabla.Ensayo, '_st_', 'IgnoreCase', true);
    
    vars_analizar = tabla.Properties.VariableNames(2:end); 
    
    for i = 1:length(vars_analizar)
        var_name = vars_analizar{i};
        data_ct = tabla.(var_name)(idx_ct);
        data_st = tabla.(var_name)(idx_st);
        
        m_st = mean(data_st, 'omitnan');
        std_st = std(data_st, 'omitnan');
        m_ct = mean(data_ct, 'omitnan');
        std_ct = std(data_ct, 'omitnan');
        
        pct_cambio = ((m_ct - m_st) / m_st) * 100;
        
        % Cálculo de d de Cohen adaptado a muestras pequeñas
        d = calcularCohenD(data_ct, data_st);
        interpretar = interpretarCohen(d);
        
        fprintf('%-18s | ST: %5.2f ± %4.2f | CT: %5.2f ± %4.2f | Cambio: %6.1f%% | d: %4.2f (%s)\n', ...
            var_name, m_st, std_st, m_ct, std_ct, pct_cambio, abs(d), interpretar);
    end
    disp(' ');
end

function RunInterStats(tabla_INJ, tabla_CTRL, titulo)
    % Compara el perfil completo del sujeto lesionado contra el control sano
    disp('-------------------------------------------------------------------');
    disp([' CLINICO INTER: ', titulo]);
    disp('-------------------------------------------------------------------');
    
    vars_analizar = tabla_INJ.Properties.VariableNames(2:end);
    
    for i = 1:length(vars_analizar)
        var_name = vars_analizar{i};
        data_INJ = tabla_INJ.(var_name);
        data_CTRL = tabla_CTRL.(var_name);
        
        m_CTRL = mean(data_CTRL, 'omitnan');
        std_CTRL = std(data_CTRL, 'omitnan');
        m_INJ = mean(data_INJ, 'omitnan');
        std_INJ = std(data_INJ, 'omitnan');
        
        dif_relativa = ((m_INJ - m_CTRL) / m_CTRL) * 100;
        
        % Cálculo de d de Cohen adaptado a muestras pequeñas
        d = calcularCohenD(data_INJ, data_CTRL);
        interpretar = interpretarCohen(d);
        
        fprintf('%-18s | Control: %5.2f ± %4.2f | Lesonado: %5.2f ± %4.2f | Dif: %6.1f%% | d: %4.2f (%s)\n', ...
            var_name, m_CTRL, std_CTRL, m_INJ, std_INJ, dif_relativa, abs(d), interpretar);
    end
    disp(' ');
end

function d = calcularCohenD(grupo1, grupo2)
    % Calcula d de Cohen con Desviación Estándar Ponderada (Pooled SD) para muestras pequeñas
    n1 = sum(~isnan(grupo1));
    n2 = sum(~isnan(grupo2));
    
    m1 = mean(grupo1, 'omitnan');
    m2 = mean(grupo2, 'omitnan');
    
    v1 = var(grupo1, 'omitnan');
    v2 = var(grupo2, 'omitnan');
    
    % Fórmula oficial de varianza combinada para grados de libertad pequeños
    sd_pooled = sqrt(((n1 - 1)*v1 + (n2 - 1)*v2) / (n1 + n2 - 2));
    
    if sd_pooled == 0 || isnan(sd_pooled)
        d = 0;
    else
        d = (m1 - m2) / sd_pooled;
    end
end

function texto = interpretarCohen(d)
    % Escala de Sawilowsky para la magnitud clínica del efecto
    val = abs(d);
    if val < 0.2
        texto = 'Despreciable';
    elseif val < 0.5
        texto = 'Pequeño';
    elseif val < 0.8
        texto = 'Mediano';
    elseif val < 1.2
        texto = 'Grande';
    else
        texto = 'Muy Grande';
    end
end

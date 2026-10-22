function stats_table = calculateKinematicStatistics(master_table)
% CALCULATEKINEMATICSTATISTICS Realiza pruebas no paramétricas (Wilcoxon 
% Rank-Sum / Mann-Whitney U) para comparaciones Intersujeto e Intrasujeto.
%
% Inputs:
%   master_table - Tabla generada por extractKinematicFeatures
% Output:
%   stats_table  - Tabla con los p-values de las comparaciones

    % Definir TODAS las métricas numéricas a evaluar (incluyendo Inv/Ev)
    metricas = {'Max_Plantarflexion', 'Peak_Descent_Vel', 'Peak_Return_Vel', ...
        'Max_Acceleration', 'Acc_Variability', 'Max_Inversion', 'Max_Eversion', 'Inv_Ev_ROM'};
        
    % Preparar celdas para los resultados
    Comparacion = {};
    Tipo = {};
    
    % Matrices temporales para guardar los p-values
    p_values = zeros(4, length(metricas));
    
    %% --- 1. COMPARACIONES INTRASUJETO (ST vs CT en el mismo sujeto) ---
    % Sujeto Lesionado (INJ)
    Comparacion{1,1} = 'INJ: ST vs CT'; Tipo{1,1} = 'Intrasujeto';
    idx_INJ_ST = strcmp(master_table.Subject, 'INJ') & strcmp(master_table.Condition, 'ST');
    idx_INJ_CT = strcmp(master_table.Subject, 'INJ') & strcmp(master_table.Condition, 'CT');
    
    % Sujeto Control (CTRL)
    Comparacion{2,1} = 'CTRL: ST vs CT'; Tipo{2,1} = 'Intrasujeto';
    idx_CTRL_ST = strcmp(master_table.Subject, 'CTRL') & strcmp(master_table.Condition, 'ST');
    idx_CTRL_CT = strcmp(master_table.Subject, 'CTRL') & strcmp(master_table.Condition, 'CT');
    
    %% --- 2. COMPARACIONES INTERSUJETO (INJ vs CTRL en la misma condición) ---
    % Condición Sin Tobillera (ST)
    Comparacion{3,1} = 'ST: INJ vs CTRL'; Tipo{3,1} = 'Intersujeto';
    % Condición Con Tobillera (CT)
    Comparacion{4,1} = 'CT: INJ vs CTRL'; Tipo{4,1} = 'Intersujeto';
    
    %% --- EJECUCIÓN DE PRUEBAS (Mann-Whitney U / ranksum) ---
    for m = 1:length(metricas)
        var = metricas{m};
        
        % Validar que la variable exista en la tabla para evitar errores
        if ismember(var, master_table.Properties.VariableNames)
            % 1. Intrasujeto INJ
            p_values(1, m) = ranksum(master_table{idx_INJ_ST, var}, master_table{idx_INJ_CT, var});
            % 2. Intrasujeto CTRL
            p_values(2, m) = ranksum(master_table{idx_CTRL_ST, var}, master_table{idx_CTRL_CT, var});
            % 3. Intersujeto ST
            p_values(3, m) = ranksum(master_table{idx_INJ_ST, var}, master_table{idx_CTRL_ST, var});
            % 4. Intersujeto CT
            p_values(4, m) = ranksum(master_table{idx_INJ_CT, var}, master_table{idx_CTRL_CT, var});
        else
            % Si por alguna razón la columna no existe, llenamos con NaNs
            p_values(:, m) = NaN;
        end
    end
    
    %% --- CONSTRUIR TABLA DE RESULTADOS DINÁMICA ---
    % 1. Inicializar la tabla base con las dos primeras columnas descriptivas
    stats_table = table(Comparacion, Tipo, 'VariableNames', {'Comparacion', 'Tipo_Analisis'});
    
    % 2. Asignar dinámicamente cada columna de p-values con el nombre correcto de la métrica
    for m = 1:length(metricas)
        stats_table.(metricas{m}) = p_values(:, m);
    end
end
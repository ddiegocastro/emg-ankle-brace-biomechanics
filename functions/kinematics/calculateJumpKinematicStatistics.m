function stats_table = calculateJumpKinematicStatistics(master_table)
% CALCULATEJUMPKINEMATICSTATISTICS
% Realiza pruebas de Wilcoxon para las 8 variables del Salto Vertical.

    % Las 8 variables exactas
    metricas = {'Altura_Salto_cm', 'Delta_X_mm', 'Delta_Y_mm', 'Distancia_Total_cm', ...
                'Pico_Vel_Empuje', 'Pico_Vel_Aterrizaje', 'Acc_Impacto', 'Tiempo_Estabilizacion'};
        
    p_values = zeros(4, length(metricas));
    
    idx_INJ_ST = strcmp(master_table.Subject, 'INJ') & strcmp(master_table.Condition, 'ST');
    idx_INJ_CT = strcmp(master_table.Subject, 'INJ') & strcmp(master_table.Condition, 'CT');
    idx_CTRL_ST = strcmp(master_table.Subject, 'CTRL') & strcmp(master_table.Condition, 'ST');
    idx_CTRL_CT = strcmp(master_table.Subject, 'CTRL') & strcmp(master_table.Condition, 'CT');
    
    Comparacion = {'INJ: ST vs CT'; 'CTRL: ST vs CT'; 'ST: INJ vs CTRL'; 'CT: INJ vs CTRL'};
    Tipo = {'Intrasujeto'; 'Intrasujeto'; 'Intersujeto'; 'Intersujeto'};
    
    for m = 1:length(metricas)
        var = metricas{m};
        
        data_INJ_ST = rmmissing(master_table{idx_INJ_ST, var});
        data_INJ_CT = rmmissing(master_table{idx_INJ_CT, var});
        data_CTRL_ST = rmmissing(master_table{idx_CTRL_ST, var});
        data_CTRL_CT = rmmissing(master_table{idx_CTRL_CT, var});
        
        % 1. Intrasujeto INJ
        if ~isempty(data_INJ_ST) && ~isempty(data_INJ_CT), p_values(1, m) = ranksum(data_INJ_ST, data_INJ_CT); else, p_values(1, m) = NaN; end
        % 2. Intrasujeto CTRL
        if ~isempty(data_CTRL_ST) && ~isempty(data_CTRL_CT), p_values(2, m) = ranksum(data_CTRL_ST, data_CTRL_CT); else, p_values(2, m) = NaN; end
        % 3. Intersujeto ST
        if ~isempty(data_INJ_ST) && ~isempty(data_CTRL_ST), p_values(3, m) = ranksum(data_INJ_ST, data_CTRL_ST); else, p_values(3, m) = NaN; end
        % 4. Intersujeto CT
        if ~isempty(data_INJ_CT) && ~isempty(data_CTRL_CT), p_values(4, m) = ranksum(data_INJ_CT, data_CTRL_CT); else, p_values(4, m) = NaN; end
    end
    
    stats_table = table(Comparacion, Tipo, p_values(:,1), p_values(:,2), ...
        p_values(:,3), p_values(:,4), p_values(:,5), p_values(:,6), ...
        p_values(:,7), p_values(:,8), ...
        'VariableNames', [{'Comparacion', 'Tipo_Analisis'}, metricas]);
end
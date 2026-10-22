function stats_inter = GetInterSubjectStats(tabla_subj1, tabla_subj2, nombre_s1, nombre_s2)
% GetInterSubjectStats Compara estadísticamente dos sujetos usando la d de Cohen.
% Analiza las diferencias entre sujetos aislando por condición ('ct' y 'st').
%
% INPUT:
%   tabla_subj1 - Tabla de resultados del Sujeto 1 (ej. Lesionado).
%   tabla_subj2 - Tabla de resultados del Sujeto 2 (ej. Control).
%   nombre_s1   - (String) Etiqueta para el Sujeto 1 (ej. 'Lesionado').
%   nombre_s2   - (String) Etiqueta para el Sujeto 2 (ej. 'Control').
%
% OUTPUT:
%   stats_inter - Tabla resumen con las comparaciones y tamaños de efecto.

nombres_vars = tabla_subj1.Properties.VariableNames(2:end);
num_vars = length(nombres_vars);

condiciones = {'ct', 'st'};
num_conds = length(condiciones);

% Preasignar vectores para construir la tabla final
Variable = strings(num_vars * num_conds, 1);
Condicion = strings(num_vars * num_conds, 1);
Media_S1 = zeros(num_vars * num_conds, 1);
SD_S1 = zeros(num_vars * num_conds, 1);
Media_S2 = zeros(num_vars * num_conds, 1);
SD_S2 = zeros(num_vars * num_conds, 1);
Cohen_d = zeros(num_vars * num_conds, 1);
Interpretacion = strings(num_vars * num_conds, 1);

row_idx = 1;

for c = 1:num_conds
    cond = condiciones{c};
    str_busca = ['_', cond, '_'];

    % Filtrar filas correspondientes a la condición actual ('ct' o 'st')
    idx_s1 = contains(tabla_subj1{:, 1}, str_busca, 'IgnoreCase', true);
    idx_s2 = contains(tabla_subj2{:, 1}, str_busca, 'IgnoreCase', true);

    datos_s1 = table2array(tabla_subj1(idx_s1, 2:end));
    datos_s2 = table2array(tabla_subj2(idx_s2, 2:end));

    n1 = size(datos_s1, 1);
    n2 = size(datos_s2, 1);

    % Calcular estadísticas por cada variable (L_CCI, R_CCI)
    for v = 1:num_vars
        m1 = mean(datos_s1(:, v));
        s1 = std(datos_s1(:, v));

        m2 = mean(datos_s2(:, v));
        s2 = std(datos_s2(:, v));

        % Varianza combinada (Pooled SD)
        sd_pooled = sqrt( ((n1 - 1)*s1^2 + (n2 - 1)*s2^2) / (n1 + n2 - 2) );

        % Tamaño del efecto (Cohen's d)
        if sd_pooled == 0
            d_val = 0;
        else
            d_val = abs(m1 - m2) / sd_pooled;
        end

        % Llenar registros
        Variable(row_idx) = string(nombres_vars{v});
        Condicion(row_idx) = upper(cond);
        Media_S1(row_idx) = m1;
        SD_S1(row_idx) = s1;
        Media_S2(row_idx) = m2;
        SD_S2(row_idx) = s2;
        Cohen_d(row_idx) = d_val;

        % Interpretación clásica de Cohen
        if d_val < 0.2
            Interpretacion(row_idx) = "Trivial";
        elseif d_val < 0.5
            Interpretacion(row_idx) = "Pequeño";
        elseif d_val < 0.8
            Interpretacion(row_idx) = "Mediano";
        else
            Interpretacion(row_idx) = "Grande";
        end

        row_idx = row_idx + 1;
    end
end

% Construir tabla final renombrando dinámicamente las columnas de los sujetos
stats_inter = table(Variable, Condicion, Media_S1, SD_S1, Media_S2, SD_S2, Cohen_d, Interpretacion);
stats_inter.Properties.VariableNames{'Media_S1'} = ['Media_', nombre_s1];
stats_inter.Properties.VariableNames{'SD_S1'} = ['SD_', nombre_s1];
stats_inter.Properties.VariableNames{'Media_S2'} = ['Media_', nombre_s2];
stats_inter.Properties.VariableNames{'SD_S2'} = ['SD_', nombre_s2];
end
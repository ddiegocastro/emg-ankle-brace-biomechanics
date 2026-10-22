function stats_results = CompareCondition_CohenD(tabla_datos, cond1_str, cond2_str)
% CompareCondition_CohenD Calcula el d de Cohen entre dos condiciones 
% (ej. '_ct_' vs '_st_') dentro de la misma tabla de resultados de un sujeto.

% Extraer los nombres de los ensayos (asumimos que están en la primera columna 'Ensayo')
ensayos = tabla_datos.Ensayo;

% Encontrar los índices de las filas que corresponden a cada condición
idx1 = contains(ensayos, cond1_str, 'IgnoreCase', true);
idx2 = contains(ensayos, cond2_str, 'IgnoreCase', true);

% Extraemos los nombres de las variables numéricas (ignoramos 'Ensayo')
var_names = tabla_datos.Properties.VariableNames(2:end)';
num_vars = length(var_names);

% Inicializamos vectores para construir la tabla final
Media_C1 = zeros(num_vars, 1);
SD_C1 = zeros(num_vars, 1);
Media_C2 = zeros(num_vars, 1);
SD_C2 = zeros(num_vars, 1);
Cohen_d = zeros(num_vars, 1);
Magnitud = strings(num_vars, 1);

for i = 1:num_vars
    var = var_names{i};

    % Extraer los datos numéricos de cada condición
    val1 = tabla_datos{idx1, var};
    val2 = tabla_datos{idx2, var};

    % Calcular Medias y Desviaciones Estándar
    m1 = mean(val1, 'omitnan');
    sd1 = std(val1, 'omitnan');
    n1 = sum(~isnan(val1));

    m2 = mean(val2, 'omitnan');
    sd2 = std(val2, 'omitnan');
    n2 = sum(~isnan(val2));

    % Calcular SD Pooled (Desviación Estándar Agrupada)
    if (n1 + n2 - 2) > 0
        sd_pool = sqrt( ((n1-1)*sd1^2 + (n2-1)*sd2^2) / (n1+n2-2) );
    else
        sd_pool = NaN;
    end

    % Calcular d de Cohen (Condición 1 - Condición 2)
    % Si m1 > m2, el valor será positivo.
    if isnan(sd_pool) || sd_pool == 0
        d = NaN;
    else
        d = (m1 - m2) / sd_pool;
    end

    % Asignar a los vectores
    Media_C1(i) = m1;
    SD_C1(i) = sd1;
    Media_C2(i) = m2;
    SD_C2(i) = sd2;
    Cohen_d(i) = d;

    % Clasificar la magnitud
    if isnan(d)
        Magnitud(i) = "N/A";
    else
        abs_d = abs(d);
        if abs_d < 0.2
            Magnitud(i) = "Insignificante";
        elseif abs_d >= 0.2 && abs_d < 0.5
            Magnitud(i) = "Pequeño";
        elseif abs_d >= 0.5 && abs_d < 0.8
            Magnitud(i) = "Mediano";
        else
            Magnitud(i) = "Grande";
        end
    end
end

% Nombres dinámicos para las columnas dependiendo de los strings introducidos
col_mean1 = ['Media', cond1_str];
col_sd1 = ['SD', cond1_str];
col_mean2 = ['Media', cond2_str];
col_sd2 = ['SD', cond2_str];

% Ensamblar la tabla final
stats_results = table(var_names, Media_C1, SD_C1, Media_C2, SD_C2, Cohen_d, Magnitud, ...
    'VariableNames', {'Metrica', col_mean1, col_sd1, col_mean2, col_sd2, 'Cohen_d', 'Efecto'});
end
function stats_results = CompareEP_CohenD(tabla_CTRL, tabla_INJ)
% CompareEP_CohenD Calcula la estadística descriptiva y el tamaño del
% efecto (d de Cohen) entre dos tablas de resultados cinéticos.

% Extraemos los nombres de las variables numéricas (ignoramos la columna 'Ensayo')
var_names = tabla_CTRL.Properties.VariableNames(2:end)';
num_vars = length(var_names);

% Inicializamos vectores para construir la tabla final
Media_Control = zeros(num_vars, 1);
SD_Control = zeros(num_vars, 1);
Media_Lesionado = zeros(num_vars, 1);
SD_Lesionado = zeros(num_vars, 1);
Cohen_d = zeros(num_vars, 1);
Magnitud = strings(num_vars, 1);

for i = 1:num_vars
    var = var_names{i};

    % Extraer los datos de cada grupo
    val_CTRL = tabla_CTRL.(var);
    val_INJ = tabla_INJ.(var);

    % Calcular Medias y Desviaciones Estándar
    m1 = mean(val_CTRL, 'omitnan');
    sd1 = std(val_CTRL, 'omitnan');
    n1 = sum(~isnan(val_CTRL));

    m2 = mean(val_INJ, 'omitnan');
    sd2 = std(val_INJ, 'omitnan');
    n2 = sum(~isnan(val_INJ));

    % Calcular SD Pooled (Desviación Estándar Agrupada)
    sd_pool = sqrt( ((n1-1)*sd1^2 + (n2-1)*sd2^2) / (n1+n2-2) );

    % Calcular d de Cohen (Lesionado - Control)
    % Positivo = Lesionado tiene valores más altos
    % Negativo = Control tiene valores más altos
    d = (m2 - m1) / sd_pool;

    % Asignar a los vectores
    Media_Control(i) = m1;
    SD_Control(i) = sd1;
    Media_Lesionado(i) = m2;
    SD_Lesionado(i) = sd2;
    Cohen_d(i) = d;

    % Clasificar la magnitud del efecto basado en el valor absoluto
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

% Ensamblar la tabla final
stats_results = table(var_names, Media_Control, SD_Control, Media_Lesionado, SD_Lesionado, Cohen_d, Magnitud, ...
    'VariableNames', {'Metrica', 'Media_CTRL', 'SD_CTRL', 'Media_INJ', 'SD_INJ', 'Cohen_d', 'Efecto'});
end
function stats_intra = GetIntraSubjectStats(resultados_tabla, nombre_sujeto)
% GetIntraSubjectStats Compara estadísticamente las condiciones 'ct' y 'st'
% dentro de un mismo sujeto utilizando una prueba t para muestras independientes
% y el tamaño de efecto (d de Cohen).
%
% INPUT:
%   resultados_tabla - (Table) Tabla con ensayos y variables numéricas (Activación o CCI).
%   nombre_sujeto    - (String) Etiqueta del sujeto para la tabla final (ej. 'INJ_Lesionado').
%
% OUTPUT:
%   stats_intra      - (Table) Tabla resumen con medias, SD, valor p y Cohen's d.

ensayos = resultados_tabla{:, 1};
nombres_vars = resultados_tabla.Properties.VariableNames(2:end);
num_vars = length(nombres_vars);

% Encontrar índices para 'ct' y 'st'
idx_ct = contains(ensayos, '_ct_', 'IgnoreCase', true);
idx_st = contains(ensayos, '_st_', 'IgnoreCase', true);

% Extraer datos numéricos
datos_num = table2array(resultados_tabla(:, 2:end));
datos_ct = datos_num(idx_ct, :);
datos_st = datos_num(idx_st, :);

n_ct = size(datos_ct, 1);
n_st = size(datos_st, 1);

% Preasignar vectores para la tabla final
Sujeto = repmat(string(nombre_sujeto), num_vars, 1);
Variable = string(nombres_vars');
Media_CT = zeros(num_vars, 1);
SD_CT = zeros(num_vars, 1);
Media_ST = zeros(num_vars, 1);
SD_ST = zeros(num_vars, 1);
P_Value = zeros(num_vars, 1);
Significancia = strings(num_vars, 1);
Cohen_d = zeros(num_vars, 1);
Interpretacion = strings(num_vars, 1);

for i = 1:num_vars
    var_ct = datos_ct(:, i);
    var_st = datos_st(:, i);

    Media_CT(i) = mean(var_ct);
    SD_CT(i) = std(var_ct);
    Media_ST(i) = mean(var_st);
    SD_ST(i) = std(var_st);

    % 1. Estadística Inferencial: Prueba T para muestras independientes
    % Se utiliza ttest2 asumiendo que los ensayos son eventos independientes
    [~, p] = ttest2(var_ct, var_st);
    P_Value(i) = p;

    if p < 0.05
        Significancia(i) = "Significativo";
    else
        Significancia(i) = "No Sig.";
    end

    % 2. Tamaño del Efecto: d de Cohen (Pooled SD)
    sd_pooled = sqrt( ((n_ct - 1)*SD_CT(i)^2 + (n_st - 1)*SD_ST(i)^2) / (n_ct + n_st - 2) );
    if sd_pooled == 0
        d_val = 0;
    else
        d_val = abs(Media_CT(i) - Media_ST(i)) / sd_pooled;
    end
    Cohen_d(i) = d_val;

    if d_val < 0.2
        Interpretacion(i) = "Trivial";
    elseif d_val < 0.5
        Interpretacion(i) = "Pequeño";
    elseif d_val < 0.8
        Interpretacion(i) = "Mediano";
    else
        Interpretacion(i) = "Grande";
    end
end

% Construir tabla final
stats_intra = table(Sujeto, Variable, Media_CT, SD_CT, Media_ST, SD_ST, ...
    P_Value, Significancia, Cohen_d, Interpretacion);
end
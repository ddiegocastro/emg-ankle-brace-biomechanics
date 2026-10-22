function stats_table = GetDescriptiveStats(resultados_tabla)
% GetDescriptiveStats Calcula Media, SD y el Tamaño de Efecto (Cohen's d)
% comparando las condiciones 'ct' (Con Tobillera) y 'st' (Sin Tobillera).
% 
% INPUT:
%   resultados_tabla - Tabla con ensayos en la columna 1 y variables numéricas en el resto.
%
% OUTPUT:
%   stats_table - Tabla resumen con estadísticas descriptivas.

ensayos = resultados_tabla{:, 1};
nombres_vars = resultados_tabla.Properties.VariableNames(2:end);
num_vars = length(nombres_vars);

% Encontrar índices para 'ct' y 'st' ignorando mayúsculas/minúsculas
idx_ct = contains(ensayos, '_ct_', 'IgnoreCase', true);
idx_st = contains(ensayos, '_st_', 'IgnoreCase', true);

% Extraer solo los datos numéricos
datos_num = table2array(resultados_tabla(:, 2:end));

datos_ct = datos_num(idx_ct, :);
datos_st = datos_num(idx_st, :);

n_ct = size(datos_ct, 1);
n_st = size(datos_st, 1);

% Preasignar vectores de resultados
Media_CT = zeros(num_vars, 1);
SD_CT = zeros(num_vars, 1);
Media_ST = zeros(num_vars, 1);
SD_ST = zeros(num_vars, 1);
Cohen_d = zeros(num_vars, 1);
Interpretacion = strings(num_vars, 1);

for i = 1:num_vars
    % Estadísticas descriptivas
    m_ct = mean(datos_ct(:, i));
    s_ct = std(datos_ct(:, i));

    m_st = mean(datos_st(:, i));
    s_st = std(datos_st(:, i));

    Media_CT(i) = m_ct;
    SD_CT(i) = s_ct;
    Media_ST(i) = m_st;
    SD_ST(i) = s_st;

    % Cálculo de la SD agrupada (Pooled SD)
    sd_pooled = sqrt( ((n_ct - 1)*s_ct^2 + (n_st - 1)*s_st^2) / (n_ct + n_st - 2) );

    % Cálculo de Cohen's d
    if sd_pooled == 0
        d_val = 0;
    else
        d_val = abs(m_ct - m_st) / sd_pooled;
    end
    Cohen_d(i) = d_val;

    % Interpretación del tamaño de efecto
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
Variable = nombres_vars';
stats_table = table(Variable, Media_CT, SD_CT, Media_ST, SD_ST, Cohen_d, Interpretacion);
end
function PlotEnsemblePctEP(struct_cinetica, condition_str, subject_label, fs)
% PlotEnsemblePctEP Calcula el Ensemble Median de la distribución de carga (%)
% a partir de las 3 repeticiones dentro del struct y genera la gráfica cinemática.

% 1. Buscar automáticamente los ensayos del struct que correspondan a EP y la condición (ej. '_st_')
nombres_ensayos = fieldnames(struct_cinetica);
idx_validos = contains(nombres_ensayos, 'Ep', 'IgnoreCase', true) & ...
    contains(nombres_ensayos, condition_str, 'IgnoreCase', true);
ensayos_objetivo = nombres_ensayos(idx_validos);

num_ensayos = length(ensayos_objetivo);
if num_ensayos == 0
    warning(['No se encontraron ensayos de EP con la condición "', condition_str, '" en el struct proporcionado.']);
    return;
end

% 2. Encontrar la longitud mínima (filas) para truncar y alinear los ensayos
longitudes = zeros(num_ensayos, 1);
for r = 1:num_ensayos
    longitudes(r) = height(struct_cinetica.(ensayos_objetivo{r}));
end
largo_minimo = min(longitudes);

% 3. Matrices para almacenar los porcentajes de cada repetición
Matriz_Pct_R = zeros(largo_minimo, num_ensayos);
Matriz_Pct_L = zeros(largo_minimo, num_ensayos);

% 4. Calcular el porcentaje de carga para cada ensayo de forma independiente
for r = 1:num_ensayos
    trial_data = struct_cinetica.(ensayos_objetivo{r});

    % Usamos valor absoluto para asegurar fuerzas positivas en el cálculo
    R_Fz = abs(trial_data.R_Fz(1:largo_minimo));
    L_Fz = abs(trial_data.L_Fz(1:largo_minimo));

    Total_Fz = R_Fz + L_Fz;
    Matriz_Pct_R(:, r) = (R_Fz ./ Total_Fz) * 100;
    Matriz_Pct_L(:, r) = (L_Fz ./ Total_Fz) * 100;
end

% 5. Obtener el comportamiento normalizado (Mediana punto por punto en la dimensión 2)
Pct_R_Mediana = median(Matriz_Pct_R, 2);
Pct_L_Mediana = median(Matriz_Pct_L, 2);

% 6. Generar vector de tiempo alineado
time = (0:largo_minimo-1)' / fs;

% 7. Graficar con el formato limpio que necesitas
figure('Units', 'normalized', 'Position', [0.2 0.2 0.6 0.5]);
hold on; grid on;

% Curvas del comportamiento general (Medianas)
plot(time, Pct_R_Mediana, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2, 'DisplayName', 'Pierna Derecha');
plot(time, Pct_L_Mediana, 'Color', [0 0.4470 0.7410], 'LineWidth', 2, 'DisplayName', 'Pierna Izquierda');

% Línea del ideal biomecánico (50%)
yline(50, '--k', 'Ideal 50/50', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left', 'HandleVisibility','off');

% Formato e intervalos solicitados
xlabel('Tiempo (s)', 'FontWeight', 'bold');
ylabel('Distribución de Carga (%)', 'FontWeight', 'bold');

% Limpiar el string de la condición para el título (ej. '_st_' -> ST)
clean_cond = upper(strrep(condition_str, '_', ''));

title({'Comportamiento Cinético General: Distribución de Peso en Elevación de Puntillas', ...
    ['Sujeto: ', subject_label, ' - Condición: ', clean_cond, ' (Ensemble Median)']}, 'FontSize', 12);

ylim([0 100]); % Escala completa de porcentaje para ver la realidad del desbalance
xlim([0 10]);  % Forzado a tus 10 segundos de visualización
legend('Location', 'best');
set(gca, 'FontSize', 11);
end
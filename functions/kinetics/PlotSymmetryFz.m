function PlotSymmetryFz(struct_cinetica, trial_type, condition_str, subject_label, fs)
% PLOTSYMMETRYFZ Grafica la simetría de la Fuerza Vertical (Fz) entre ambas piernas.
% Rellena el área entre las curvas para evidenciar la magnitud de la asimetría.
%
%   INPUTS:
%   - trial_type: 'Sv' (Salto Vertical) o 'Ep' (Elevación de Puntillas)

% 1. Buscar automáticamente los ensayos
nombres_ensayos = fieldnames(struct_cinetica);
idx_validos = contains(nombres_ensayos, trial_type, 'IgnoreCase', true) & ...
    contains(nombres_ensayos, condition_str, 'IgnoreCase', true);
ensayos_objetivo = nombres_ensayos(idx_validos);
num_ensayos = length(ensayos_objetivo);

if num_ensayos == 0
    warning(['No se encontraron ensayos de ', trial_type, ' con la condición "', condition_str, '".']);
    return;
end

% 2. Encontrar la longitud mínima para alinear
longitudes = zeros(num_ensayos, 1);
for r = 1:num_ensayos
    longitudes(r) = height(struct_cinetica.(ensayos_objetivo{r}));
end
largo_minimo = min(longitudes);

% 3. Pre-asignar matrices
Fz_R_Matriz = zeros(largo_minimo, num_ensayos);
Fz_L_Matriz = zeros(largo_minimo, num_ensayos);

% 4. Extraer datos (Fz suele ser negativo en plataformas, aplicamos abs() o *-1)
for r = 1:num_ensayos
    datos_ensayo = struct_cinetica.(ensayos_objetivo{r});
    Fz_R_Matriz(:, r) = abs(datos_ensayo.R_Fz(1:largo_minimo));
    Fz_L_Matriz(:, r) = abs(datos_ensayo.L_Fz(1:largo_minimo));
end

% 5. Calcular la mediana de los ensayos
Fz_R_Mediana = median(Fz_R_Matriz, 2, 'omitnan');
Fz_L_Mediana = median(Fz_L_Matriz, 2, 'omitnan');
tiempo = (0:largo_minimo-1)' / fs;

% =====================================================================
% 6. GRAFICACIÓN CON ÁREA DE ASIMETRÍA
% =====================================================================
clean_cond = upper(strrep(condition_str, '_', ''));

figure('Units', 'normalized', 'Position', [0.2 0.2 0.6 0.6], 'Color', 'w');
hold on;

% Título dinámico
title({'Simetría de Fuerza Vertical (Fz)', ...
    ['Sujeto: ', subject_label, ' | Condición: ', clean_cond]}, ...
    'FontSize', 14, 'FontWeight', 'bold');

% Polígono de asimetría (Sombreado entre curvas)
% Se hace uniendo el vector de tiempo hacia adelante y hacia atrás
x_fill = [tiempo; flipud(tiempo)];
y_fill = [Fz_R_Mediana; flipud(Fz_L_Mediana)];

% Dibujar el sombreado gris/rojo claro
fill(x_fill, y_fill, [0.85 0.33 0.1], 'FaceAlpha', 0.2, 'EdgeColor', 'none', ...
    'DisplayName', 'Área de Asimetría');

% Dibujar las curvas principales encima
plot(tiempo, Fz_R_Mediana, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2.5, 'DisplayName', 'Fz Pierna Derecha');
plot(tiempo, Fz_L_Mediana, 'Color', [0 0.4470 0.7410], 'LineWidth', 2.5, 'DisplayName', 'Fz Pierna Izquierda');

% Formato estético
xlabel('Tiempo (s)', 'FontWeight', 'bold');
ylabel('Fuerza Vertical (N)', 'FontWeight', 'bold');
set(gca, 'FontSize', 11, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.2);
grid on; set(gca, 'GridAlpha', 0.2);
legend('Location', 'northeast', 'Box', 'off');

% Ajustar ejes
xlim([0 max(tiempo)]);
ylim([0 max(max(Fz_R_Mediana, Fz_L_Mediana)) * 1.1]);
end
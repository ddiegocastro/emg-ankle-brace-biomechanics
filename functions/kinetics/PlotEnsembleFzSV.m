function PlotEnsembleFzSV(struct_cinetica, condition_str, subject_label, fs)
% PlotEnsembleFzSV Calcula el Ensemble Median de la Fuerza Vertical (Fz)
% a partir de las repeticiones dentro del struct para Salto Vertical (SV).

    % 1. Búsqueda y Validación
    nombres_ensayos = fieldnames(struct_cinetica);
    idx_validos = contains(nombres_ensayos, 'Sv', 'IgnoreCase', true) & ...
        contains(nombres_ensayos, condition_str, 'IgnoreCase', true);
    ensayos_objetivo = nombres_ensayos(idx_validos);
    num_ensayos = length(ensayos_objetivo);
    
    if num_ensayos == 0
        warning(['No se encontraron ensayos de SV con la condición "', condition_str, '" en el struct.']);
        return;
    end
    
    % 2. Alineación y Extracción
    longitudes = zeros(num_ensayos, 1);
    for r = 1:num_ensayos
        longitudes(r) = height(struct_cinetica.(ensayos_objetivo{r}));
    end
    largo_minimo = min(longitudes);
    
    Matriz_Fz_R = zeros(largo_minimo, num_ensayos);
    Matriz_Fz_L = zeros(largo_minimo, num_ensayos);
    for r = 1:num_ensayos
        trial_data = struct_cinetica.(ensayos_objetivo{r});
        Matriz_Fz_R(:, r) = abs(trial_data.R_Fz(1:largo_minimo));
        Matriz_Fz_L(:, r) = abs(trial_data.L_Fz(1:largo_minimo));
    end
    
    % 3. Comportamiento general
    Fz_R_Mediana = median(Matriz_Fz_R, 2);
    Fz_L_Mediana = median(Matriz_Fz_L, 2);
    time = (0:largo_minimo-1)' / fs;
    
    % =====================================================================
    % 4. GRAFICACIÓN ESTÉTICA
    % =====================================================================
    figure('Units', 'normalized', 'Position', [0.25 0.25 0.6 0.5], 'Color', 'w'); % Fondo blanco
    hold on;
    
    % --- Estilización de la Fase de Vuelo ---
    vuelo_idx = (Fz_R_Mediana + Fz_L_Mediana) < 20;
    if any(vuelo_idx)
        max_fz = max(max(Fz_R_Mediana), max(Fz_L_Mediana)) * 1.1; % 10% más alto que el pico
        area(time, double(vuelo_idx) * max_fz, 'FaceColor', [0.2 0.2 0.2], ...
            'FaceAlpha', 0.08, 'EdgeColor', 'none', 'DisplayName', 'Fase de Vuelo');
    end

    % --- Trazado de Curvas ---
    plot(time, Fz_R_Mediana, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2.5, 'DisplayName', 'Fz Derecha');
    plot(time, Fz_L_Mediana, 'Color', [0 0.4470 0.7410], 'LineWidth', 2.5, 'DisplayName', 'Fz Izquierda');

    % --- Formato y Estética Final ---
    xlabel('Tiempo (s)', 'FontWeight', 'bold', 'FontSize', 11);
    ylabel('Fuerza Vertical Fz (N)', 'FontWeight', 'bold', 'FontSize', 11);
    
    clean_cond = upper(strrep(condition_str, '_', ''));
    title({'Perfil de Impulso: Salto Vertical', ...
        ['Sujeto: ', subject_label, ' | Condición: ', clean_cond]}, 'FontSize', 14, 'FontWeight', 'bold');
    
    xlim([0 time(end)]); 
    ylim([0 max(max(Fz_R_Mediana), max(Fz_L_Mediana)) * 1.1]); % Ajuste perfecto al pico
    
    % Estilo del recuadro
    set(gca, 'FontSize', 11, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.2);
    grid on;
    set(gca, 'GridAlpha', 0.2);
    
    % Leyenda estética
    legend('Location', 'northeast', 'Box', 'off', 'FontSize', 11);
end
function PlotEnsembleLoadEP(struct_cinetica, condition_str, subject_label, fs)
% PlotEnsembleLoadEP Genera la curva mediana representativa de la
% distribución de carga (%) para los ensayos de Elevación de Puntillas.

    % Extraer los nombres de todos los ensayos en el struct
    nombres_ensayos = fieldnames(struct_cinetica);
    idx_validos = contains(nombres_ensayos, 'Ep', 'IgnoreCase', true) & ...
        contains(nombres_ensayos, condition_str, 'IgnoreCase', true);
    ensayos_objetivo = nombres_ensayos(idx_validos);
    num_ensayos = length(ensayos_objetivo);
    
    if num_ensayos == 0
        warning(['No se encontraron ensayos de EP con la condición "', condition_str, '" en el struct.']);
        return;
    end
    
    % 1. Encontrar la longitud mínima entre las repeticiones
    longitudes = zeros(num_ensayos, 1);
    for r = 1:num_ensayos
        longitudes(r) = height(struct_cinetica.(ensayos_objetivo{r}));
    end
    largo_minimo = min(longitudes);
    
    % 2. Matrices y extracción
    Fz_Der_Matriz = zeros(largo_minimo, num_ensayos);
    Fz_Izq_Matriz = zeros(largo_minimo, num_ensayos);
    for r = 1:num_ensayos
        datos_ensayo = struct_cinetica.(ensayos_objetivo{r});
        Fz_Der_Matriz(:, r) = abs(datos_ensayo.R_Fz(1:largo_minimo));
        Fz_Izq_Matriz(:, r) = abs(datos_ensayo.L_Fz(1:largo_minimo));
    end
    
    % 3. Cálculos de Mediana y Porcentajes
    Fz_Der_Mediana = median(Fz_Der_Matriz, 2);
    Fz_Izq_Mediana = median(Fz_Izq_Matriz, 2);
    Total_Fz_Mediana = Fz_Der_Mediana + Fz_Izq_Mediana;
    Pct_R_Mediana = (Fz_Der_Mediana ./ Total_Fz_Mediana) * 100;
    Pct_L_Mediana = (Fz_Izq_Mediana ./ Total_Fz_Mediana) * 100;
    
    % 4. Vector de tiempo
    tiempo_alineado = (0:largo_minimo-1)' / fs;
    
    % =====================================================================
    % 5. GRAFICACIÓN ESTÉTICA
    % =====================================================================
    figure('Units', 'normalized', 'Position', [0.15 0.15 0.7 0.6], 'Color', 'w'); % Fondo blanco
    hold on;
    
    % --- Segmentación Visual de Fases ---
    y_lims = [20 80]; % Límites del eje Y
    
    % Fase 1: Elevación (0 a 3s) - Gris muy claro
    patch([0 3 3 0], [y_lims(1) y_lims(1) y_lims(2) y_lims(2)], [0.95 0.95 0.95], 'FaceAlpha', 1, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    text(1.5, 78, 'Elevación', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10, 'Color', [0.4 0.4 0.4]);
    
    % Fase 2: Mantenimiento (3 a 5s) - Verde muy suave
    patch([3 5 5 3], [y_lims(1) y_lims(1) y_lims(2) y_lims(2)], [0.9 0.95 0.9], 'FaceAlpha', 1, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    text(4, 78, 'Mantenimiento', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10, 'Color', [0.2 0.6 0.2]);
    
    % Fase 3: Descenso (5 a 8s) - Gris muy claro
    patch([5 8 8 5], [y_lims(1) y_lims(1) y_lims(2) y_lims(2)], [0.95 0.95 0.95], 'FaceAlpha', 1, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    text(6.5, 78, 'Descenso', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10, 'Color', [0.4 0.4 0.4]);
    
    % Fase 4: Original (8 a 10s) - Blanco puro (fondo normal)
    text(9, 78, 'Reposo', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10, 'Color', [0.4 0.4 0.4]);

    % --- Trazado de las Curvas ---
    % Dibujamos primero el sombreado de oscilación para que quede de fondo
    fill([tiempo_alineado; flipud(tiempo_alineado)], [Pct_R_Mediana; flipud(Pct_L_Mediana)], 'k', ...
        'FaceAlpha', 0.05, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        
    % Línea del ideal biomecánico (50%)
    yline(50, '--k', 'Ideal 50/50', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left', 'HandleVisibility','off');
    
    % Líneas principales de las piernas
    plot(tiempo_alineado, Pct_R_Mediana, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2.5, 'DisplayName', 'Pierna Derecha');
    plot(tiempo_alineado, Pct_L_Mediana, 'Color', [0 0.4470 0.7410], 'LineWidth', 2.5, 'DisplayName', 'Pierna Izquierda');

    % --- Formato y Estética Final ---
    xlabel('Tiempo (s)', 'FontWeight', 'bold', 'FontSize', 11);
    ylabel('Distribución de Carga (%)', 'FontWeight', 'bold', 'FontSize', 11);
    str_cond = strrep(condition_str, '_', '');
    title({'Distribución de Peso: Elevación de Puntillas', ...
        ['Sujeto: ', subject_label, ' | Condición: ', upper(str_cond)]}, 'FontSize', 14, 'FontWeight', 'bold');
    
    ylim(y_lims); 
    xlim([0 10]); % Forzado a 10 segundos según tu protocolo
    
    % Estilo del recuadro
    set(gca, 'FontSize', 11, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.2);
    grid on;
    set(gca, 'GridAlpha', 0.2); % Cuadrícula sutil
    
    % Leyenda estética
    legend('Location', 'southwest', 'Box', 'off', 'FontSize', 11);
end
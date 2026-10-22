function PlotEnsembleCoPEP(struct_cinetica, condition_str, subject_label, fs)
% PlotEnsembleCoPEP Calcula y grafica la oscilación mediana (Ensemble Median) 
% del Centro de Presión (CoP) Anteroposterior y Mediolateral para Elevación de Puntillas.

    % 1. Buscar automáticamente los ensayos del struct
    nombres_ensayos = fieldnames(struct_cinetica);
    idx_validos = contains(nombres_ensayos, 'Ep', 'IgnoreCase', true) & ...
        contains(nombres_ensayos, condition_str, 'IgnoreCase', true);
    ensayos_objetivo = nombres_ensayos(idx_validos);
    num_ensayos = length(ensayos_objetivo);
    
    if num_ensayos == 0
        warning(['No se encontraron ensayos de EP con la condición "', condition_str, '" en el struct.']);
        return;
    end
    
    % 2. Encontrar la longitud mínima para alinear repeticiones
    longitudes = zeros(num_ensayos, 1);
    for r = 1:num_ensayos
        longitudes(r) = height(struct_cinetica.(ensayos_objetivo{r}));
    end
    largo_minimo = min(longitudes);
    
    % 3. Pre-asignar matrices
    AP_R_Matriz = zeros(largo_minimo, num_ensayos);
    AP_L_Matriz = zeros(largo_minimo, num_ensayos);
    ML_R_Matriz = zeros(largo_minimo, num_ensayos);
    ML_L_Matriz = zeros(largo_minimo, num_ensayos);
    
   
    % 4. Extracción y Normalización (Encerado) de las Señales
    % =====================================================================
    for r = 1:num_ensayos
        datos_ensayo = struct_cinetica.(ensayos_objetivo{r});
        
        % CRUCE DE EJES: En tu lab, X es Adelante/Atrás y Y es Izquierda/Derecha
        R_AP_raw = datos_ensayo.R_Cx(1:largo_minimo);
        L_AP_raw = datos_ensayo.L_Cx(1:largo_minimo);
        R_ML_raw = datos_ensayo.R_Cy(1:largo_minimo);
        L_ML_raw = datos_ensayo.L_Cy(1:largo_minimo);
        
        % Encerado baseline: Usamos el primer medio segundo (0.5s) de reposo
        idx_reposo = 1:round(0.5 * fs); 
        
        AP_R_Matriz(:, r) = R_AP_raw - mean(R_AP_raw(idx_reposo), 'omitnan');
        AP_L_Matriz(:, r) = L_AP_raw - mean(L_AP_raw(idx_reposo), 'omitnan');
        ML_R_Matriz(:, r) = R_ML_raw - mean(R_ML_raw(idx_reposo), 'omitnan');
        ML_L_Matriz(:, r) = L_ML_raw - mean(L_ML_raw(idx_reposo), 'omitnan');
    end
    
   

    % 5. Calcular la mediana punto por punto (dimensión 2)
    AP_R_Mediana = median(AP_R_Matriz, 2, 'omitnan');
    AP_L_Mediana = median(AP_L_Matriz, 2, 'omitnan');
    ML_R_Mediana = median(ML_R_Matriz, 2, 'omitnan');
    ML_L_Mediana = median(ML_L_Matriz, 2, 'omitnan');
    
    % 6. Vector de tiempo
    tiempo_alineado = (0:largo_minimo-1)' / fs;
    
    % =====================================================================
    % 7. GRAFICACIÓN ESTÉTICA (Subplots para AP y ML)
    % =====================================================================
    clean_cond = upper(strrep(condition_str, '_', ''));
    
    fig = figure('Units', 'normalized', 'Position', [0.1 0.1 0.7 0.8], 'Color', 'w');
    sgtitle({'Oscilación del Centro de Presión (CoP) en Elevación de Puntillas', ...
             ['Sujeto: ', subject_label, ' | Condición: ', clean_cond]}, ...
             'FontSize', 15, 'FontWeight', 'bold');
             
    % --- CONFIGURACIÓN DE FASES COMUNES ---
    y_lims_AP = [-20 20]; % Rango amplio para ver el avance a puntillas
    y_lims_ML = [-100 20];  % Rango pequeño para ver el temblor lateral

    
    % --- PANEL 1: SWAY ANTEROPOSTERIOR (Frente - Atrás) ---
    subplot(2, 1, 1); hold on;
    
    % Fondos de segmentación
    patch([0 3 3 0], [y_lims_AP(1) y_lims_AP(1) y_lims_AP(2) y_lims_AP(2)], [0.95 0.95 0.95], 'FaceAlpha', 1, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    text(1.5, y_lims_AP(2)*0.9, 'Elevación', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10, 'Color', [0.4 0.4 0.4]);
    
    patch([3 5 5 3], [y_lims_AP(1) y_lims_AP(1) y_lims_AP(2) y_lims_AP(2)], [0.9 0.95 0.9], 'FaceAlpha', 1, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    text(4, y_lims_AP(2)*0.9, 'Mantenimiento', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10, 'Color', [0.2 0.6 0.2]);
    
    patch([5 8 8 5], [y_lims_AP(1) y_lims_AP(1) y_lims_AP(2) y_lims_AP(2)], [0.95 0.95 0.95], 'FaceAlpha', 1, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    text(6.5, y_lims_AP(2)*0.9, 'Descenso', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10, 'Color', [0.4 0.4 0.4]);
    
    text(9, y_lims_AP(2)*0.9, 'Reposo', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10, 'Color', [0.4 0.4 0.4]);
    
    % Línea Cero (Punto de inicio)
    yline(0, '--k', 'Inicio', 'LineWidth', 1.5, 'HandleVisibility','off');
    
    % Curvas AP
    plot(tiempo_alineado, AP_R_Mediana, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2, 'DisplayName', 'Pierna Derecha');
    plot(tiempo_alineado, AP_L_Mediana, 'Color', [0 0.4470 0.7410], 'LineWidth', 2, 'DisplayName', 'Pierna Izquierda');
    
    ylabel({'Desplazamiento', 'Anteroposterior (mm)'}, 'FontWeight', 'bold', 'FontSize', 11);
    ylim(y_lims_AP); xlim([0 10]);
    set(gca, 'FontSize', 11, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.2);
    grid on; set(gca, 'GridAlpha', 0.2);
    legend('Location', 'southwest', 'Box', 'off', 'FontSize', 10);
    
    % --- PANEL 2: SWAY MEDIOLATERAL (Izquierda - Derecha) ---
    subplot(2, 1, 2); hold on;
    
    % Fondos de segmentación
    patch([0 3 3 0], [y_lims_ML(1) y_lims_ML(1) y_lims_ML(2) y_lims_ML(2)], [0.95 0.95 0.95], 'FaceAlpha', 1, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    patch([3 5 5 3], [y_lims_ML(1) y_lims_ML(1) y_lims_ML(2) y_lims_ML(2)], [0.9 0.95 0.9], 'FaceAlpha', 1, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    patch([5 8 8 5], [y_lims_ML(1) y_lims_ML(1) y_lims_ML(2) y_lims_ML(2)], [0.95 0.95 0.95], 'FaceAlpha', 1, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    
    % Línea Cero (Punto de inicio)
    yline(0, '--k', 'Inicio', 'LineWidth', 1.5, 'HandleVisibility','off');
    
    % Curvas ML
    plot(tiempo_alineado, ML_R_Mediana, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2, 'DisplayName', 'Pierna Derecha');
    plot(tiempo_alineado, ML_L_Mediana, 'Color', [0 0.4470 0.7410], 'LineWidth', 2, 'DisplayName', 'Pierna Izquierda');
    
    xlabel('Tiempo (s)', 'FontWeight', 'bold', 'FontSize', 11);
    ylabel({'Desplazamiento', 'Mediolateral (mm)'}, 'FontWeight', 'bold', 'FontSize', 11);
    ylim(y_lims_ML); xlim([0 10]);
    set(gca, 'FontSize', 11, 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.2);
    grid on; set(gca, 'GridAlpha', 0.2);
end
function plotAnkleComparisons(data_INJ, data_CTRL, tipo_movimiento)
% PLOTANKLECOMPARISONS Genera gráficas comparativas normalizadas al 100% 
% de la prueba, enfocadas EXCLUSIVAMENTE en el TOBILLO DERECHO (Lado lesionado).
%
% Inputs:
%   data_INJ         - Struct de ángulos del sujeto lesionado.
%   data_CTRL         - Struct de ángulos del sujeto control.
%   tipo_movimiento - String para filtrar archivos (ej. 'EP').

    disp(['================ GRAFICANDO FASES (TOBILLO DERECHO): ', upper(tipo_movimiento), ' ================']);
    
    % Configurar la figura principal
    fig = figure('Name', ['Análisis Biomecánico Tobillo Derecho - ', upper(tipo_movimiento)], 'Position', [100, 100, 1200, 800]);
    set(fig, 'Color', 'w');
    
    % Porcentajes de corte basados en el protocolo (10 segundos total = 100%)
    p_asc = 30;   % 3s / 10s -> Elevación
    p_hold = 50;  % 5s / 10s -> Mantenimiento
    p_desc = 80;  % 8s / 10s -> Descenso
    
    % --- FUNCIÓN PARA DIBUJAR FASES (Ocultas de la leyenda) ---
    function draw_phases(ax)
        ylim(ax, [-35 15]); 
        yl = ylim(ax);
        
        % Dibujar rectángulos sombreados (RGB + Transparencia) e ignorarlos en la leyenda
        patch(ax, [0 p_asc p_asc 0], [yl(1) yl(1) yl(2) yl(2)], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.4, 'HandleVisibility', 'off'); 
        patch(ax, [p_asc p_hold p_hold p_asc], [yl(1) yl(1) yl(2) yl(2)], [0.8 0.9 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.4, 'HandleVisibility', 'off'); 
        patch(ax, [p_hold p_desc p_desc p_hold], [yl(1) yl(1) yl(2) yl(2)], [0.9 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.4, 'HandleVisibility', 'off'); 
        patch(ax, [p_desc 100 100 p_desc], [yl(1) yl(1) yl(2) yl(2)], [0.8 0.8 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.4, 'HandleVisibility', 'off'); 
        
        % Líneas y etiquetas divisorias (también ocultas de la leyenda)
        xline(ax, p_asc, '--k', 'Elev.', 'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
        xline(ax, p_hold, '--k', 'Mant.', 'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
        xline(ax, p_desc, '--k', 'Desc.', 'LabelVerticalAlignment', 'bottom', 'HandleVisibility', 'off');
    end

    % --- FUNCIÓN PARA EXTRAER Y GRAFICAR NORMALIZADO ---
    function plot_condition(ax, data_struct, keyword1, keyword2, color, line_style)
        archivos = fieldnames(data_struct);
        idx = find(contains(archivos, keyword1, 'IgnoreCase', true) & contains(archivos, keyword2, 'IgnoreCase', true));
        
        hold(ax, 'on');
        
        for i = 1:length(idx)
            file_name = archivos{idx(i)};
            tabla = data_struct.(file_name);
            
            % FILTRADO CRUCIAL: Solo extrae cinemática del Tobillo Derecho
            if ismember('R_Ankle_Angle', tabla.Properties.VariableNames)
                angulo = tabla.R_Ankle_Angle;
                
                % Transformación de tiempo a 0-100% de la prueba
                t_pct = linspace(0, 100, length(angulo)); 
                
                plot(ax, t_pct, angulo, 'Color', color, 'LineStyle', line_style, 'LineWidth', 1.5, ...
                    'DisplayName', strrep(file_name, '_', '\_'));
            end
        end
        grid(ax, 'on');
        xlabel(ax, 'Ciclo de la Prueba (%)'); ylabel(ax, 'Ángulo (Grados)');
    end

    % -----------------------------------------------------------------------
    % 1. INTRASUJETO: Lesionado (INJ) -> ST vs CT (Derecho)
    ax1 = subplot(2, 2, 1); title(ax1, 'INTRASUJETO: Lesionado (INJ) - ST vs CT (Tobillo Derecho)');
    draw_phases(ax1); 
    plot_condition(ax1, data_INJ, tipo_movimiento, 'st', [0 0.4470 0.7410], '-'); 
    plot_condition(ax1, data_INJ, tipo_movimiento, 'ct', [0.8500 0.3250 0.0980], '--');
    legend(ax1, 'Location', 'best', 'FontSize', 8);
    
    % 2. INTRASUJETO: Control (CTRL) -> ST vs CT (Derecho)
    ax2 = subplot(2, 2, 2); title(ax2, 'INTRASUJETO: Control (CTRL) - ST vs CT (Tobillo Derecho)');
    draw_phases(ax2);
    plot_condition(ax2, data_CTRL, tipo_movimiento, 'st', [0 0.4470 0.7410], '-');
    plot_condition(ax2, data_CTRL, tipo_movimiento, 'ct', [0.8500 0.3250 0.0980], '--');
    legend(ax2, 'Location', 'best', 'FontSize', 8);

    % 3. INTERSUJETO: Lesionado vs Control (Sin Tobillera - ST)
    ax3 = subplot(2, 2, 3); title(ax3, 'INTERSUJETO: INJ vs CTRL (ST - Tobillo Derecho)');
    draw_phases(ax3);
    plot_condition(ax3, data_INJ, tipo_movimiento, 'st', [0 0.4470 0.7410], '-');
    plot_condition(ax3, data_CTRL, tipo_movimiento, 'st', [0.4660 0.6740 0.1880], '-');
    legend(ax3, 'Location', 'best', 'FontSize', 8);

    % 4. INTERSUJETO: Lesionado vs Control (Con Tobillera - CT)
    ax4 = subplot(2, 2, 4); title(ax4, 'INTERSUJETO: INJ vs CTRL (CT - Tobillo Derecho)');
    draw_phases(ax4);
    plot_condition(ax4, data_INJ, tipo_movimiento, 'ct', [0.8500 0.3250 0.0980], '--');
    plot_condition(ax4, data_CTRL, tipo_movimiento, 'ct', [0.4940 0.1840 0.5560], '--');
    legend(ax4, 'Location', 'best', 'FontSize', 8);

    % Título general explícito para la extremidad afectada
    sgtitle(fig, ['Fases Clínicas Dorsiflexión/Plantiflexión (Tobillo Derecho) - ', upper(tipo_movimiento)], 'FontWeight', 'bold', 'FontSize', 14);
end
function plotMedianKinematics(median_INJ, median_CTRL, tipo_movimiento, titulo_metrica, y_label, lim_y)
% PLOTMEDIANKINEMATICS Grafica curvas medianas con desviación estándar
% adaptándose dinámicamente a la métrica seleccionada y al tipo de protocolo.
    fig = figure('Name', [titulo_metrica, ' Usual (Mediana) - ', upper(tipo_movimiento)], 'Position', [100, 100, 1200, 800]);
    set(fig, 'Color', 'w');
    
    function draw_phases(ax)
        ylim(ax, lim_y); % Aplica los límites dinámicos
        yl = ylim(ax);
        
        % =========================================================================
        % CONFIGURACIÓN DINÁMICA DE FASES Y COLORES SEGÚN EL PROTOCOLO
        % =========================================================================
        if strcmpi(tipo_movimiento, 'EP')
            % --- Fases para Elevación de Puntillas ---
            pts = [30, 50, 80];
            etiquetas = {'Elev.', 'Mant.', 'Desc.'};
            % Colores de fondo para las 4 zonas
            colors = {[0.9 0.9 0.9], [0.8 0.9 0.8], [0.9 0.8 0.8], [0.8 0.8 0.9]};
            
            % --- DIBUJAR LOS PARCHES DE COLOR (FONDOS) SOLO PARA EP ---
            x_edges = [0, pts, 100];
            for i = 1:(length(x_edges)-1)
                x_start = x_edges(i);
                x_end = x_edges(i+1);
                patch(ax, [x_start x_end x_end x_start], [yl(1) yl(1) yl(2) yl(2)], ...
                    colors{i}, 'EdgeColor', 'none', 'FaceAlpha', 0.4, 'HandleVisibility', 'off');
            end
            
            % --- DIBUJAR LÍNEAS Y TEXTOS SOLO PARA EP ---
            for i = 1:length(pts)
                % Línea vertical discontinua
                xline(ax, pts(i), '--k', 'LineWidth', 1.2, 'HandleVisibility', 'off');
                
                % Texto al fondo de la gráfica
                pos_y = yl(1) + (yl(2) - yl(1)) * 0.05; 
                text(ax, pts(i) + 0.5, pos_y, etiquetas{i}, ...
                    'Rotation', 90, ...
                    'FontSize', 9, ...
                    'FontWeight', 'bold', ...
                    'Color', [0.2 0.2 0.2], ...
                    'HandleVisibility', 'off');
            end
            
        elseif strcmpi(tipo_movimiento, 'Sv')
            % Para Salto Vertical no hacemos nada en las fases.
            % Al dejar este bloque vacío, la gráfica para 'Sv' se mantiene completamente
            % limpia, mostrando únicamente las curvas cinemáticas sin artefactos visuales.
        end
    end

    function plot_band(ax, t, mu, sigma, color, nombre, line_style)
        t_fill = [t, fliplr(t)];
        y_fill = [mu + sigma, fliplr(mu - sigma)];
        valid_idx = ~isnan(y_fill);
        patch(ax, t_fill(valid_idx), y_fill(valid_idx), color, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        hold(ax, 'on');
        plot(ax, t, mu, 'Color', color, 'LineStyle', line_style, 'LineWidth', 2, 'DisplayName', nombre);
    end

    % 1. Lesionado (INJ)
    ax1 = subplot(2, 2, 1); title(ax1, 'INTRASUJETO: Lesionado (INJ) - ST vs CT'); 
    hold(ax1, 'on'); grid(ax1, 'on'); xlabel(ax1, 'Ciclo (%)'); ylabel(ax1, y_label); draw_phases(ax1);
    plot_band(ax1, median_INJ.st.t_pct, median_INJ.st.median, median_INJ.st.std, [0 0.4470 0.7410], 'INJ - ST', '-');
    plot_band(ax1, median_INJ.ct.t_pct, median_INJ.ct.median, median_INJ.ct.std, [0.8500 0.3250 0.0980], 'INJ - CT', '--');
    legend(ax1, 'Location', 'best', 'FontSize', 8);

    % 2. Control (CTRL)
    ax2 = subplot(2, 2, 2); title(ax2, 'INTRASUJETO: Control (CTRL) - ST vs CT'); 
    hold(ax2, 'on'); grid(ax2, 'on'); xlabel(ax2, 'Ciclo (%)'); ylabel(ax2, y_label); draw_phases(ax2);
    plot_band(ax2, median_CTRL.st.t_pct, median_CTRL.st.median, median_CTRL.st.std, [0 0.4470 0.7410], 'CTRL - ST', '-');
    plot_band(ax2, median_CTRL.ct.t_pct, median_CTRL.ct.median, median_CTRL.ct.std, [0.8500 0.3250 0.0980], 'CTRL - CT', '--');
    legend(ax2, 'Location', 'best', 'FontSize', 8);

    % 3. INJ vs CTRL (ST)
    ax3 = subplot(2, 2, 3); title(ax3, 'INTERSUJETO: INJ vs CTRL (ST)'); 
    hold(ax3, 'on'); grid(ax3, 'on'); xlabel(ax3, 'Ciclo (%)'); ylabel(ax3, y_label); draw_phases(ax3);
    plot_band(ax3, median_INJ.st.t_pct, median_INJ.st.median, median_INJ.st.std, [0 0.4470 0.7410], 'INJ - ST', '-');
    plot_band(ax3, median_CTRL.st.t_pct, median_CTRL.st.median, median_CTRL.st.std, [0.4660 0.6740 0.1880], 'CTRL - ST', '-');
    legend(ax3, 'Location', 'best', 'FontSize', 8);

    % 4. INJ vs CTRL (CT)
    ax4 = subplot(2, 2, 4); title(ax4, 'INTERSUJETO: INJ vs CTRL (CT)'); 
    hold(ax4, 'on'); grid(ax4, 'on'); xlabel(ax4, 'Ciclo (%)'); ylabel(ax4, y_label); draw_phases(ax4);
    plot_band(ax4, median_INJ.ct.t_pct, median_INJ.ct.median, median_INJ.ct.std, [0.8500 0.3250 0.0980], 'INJ - CT', '--');
    plot_band(ax4, median_CTRL.ct.t_pct, median_CTRL.ct.median, median_CTRL.ct.std, [0.4940 0.1840 0.5560], 'CTRL - CT', '--');
    legend(ax4, 'Location', 'best', 'FontSize', 8);

    sgtitle(fig, [titulo_metrica, ' (Mediana ± Std) - Tobillo Derecho - ', upper(tipo_movimiento)], 'FontWeight', 'bold', 'FontSize', 14);
end
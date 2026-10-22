function PlotEnsembleEMG_Fases(struct_emg, fs, titulo_sujeto)
% PlotEnsembleEMG_Fases Grafica el ensemble (mediana) de EMG separando por condición
% (ST y CT) y agregando los parches de fondo para las fases del protocolo EP.
%
% INPUT:
%   struct_emg    - (Struct) Estructura con las tablas de los datos EMG normalizados.
%   fs            - (Double) Frecuencia de muestreo.
%   titulo_sujeto - (String) Nombre o identificador para el título de la figura.

    condiciones = {'st', 'ct'};
    titulos_cond = {'Sin Tobillera (ST)', 'Con Tobillera (CT)'};
    musculos = {'TA', 'SL', 'GR'};
    nombres_musculos = {'Tibial Anterior', 'Sóleo', 'Gastrocnemio'};
    colores = struct('Izq', [0 0.4470 0.7410], 'Der', [0.8500 0.3250 0.0980]);

    figure('Name', ['Ensemble EMG Fases - ', titulo_sujeto], 'Position', [100, 100, 1200, 800], 'Color', 'w');
    sgtitle(['Patrón de Activación Muscular (EP) - ', titulo_sujeto], 'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.15 0.15 0.15]);

    nombres_ensayos = fieldnames(struct_emg);

    % Iterar sobre las condiciones para llenar las dos columnas de la figura
    for i = 1:length(condiciones)
        cond = condiciones{i};
        
        % 1. Filtrar ensayos por condición excluyendo el ensayo defectuoso 'ep ct 01'
        idx = contains(nombres_ensayos, 'Ep', 'IgnoreCase', true) & ...
              contains(nombres_ensayos, cond, 'IgnoreCase', true) & ...
              ~contains(nombres_ensayos, 'ep ct 01', 'IgnoreCase', true);
        ensayos_objetivo = nombres_ensayos(idx);
        num_ensayos = length(ensayos_objetivo);
        
        if num_ensayos == 0
            warning(['No se encontraron ensayos de EP-', cond, ' válidos para ', titulo_sujeto]);
            continue; 
        end
        
        % 2. Encontrar longitud mínima para poder alinear las matrices
        longitudes = zeros(num_ensayos, 1);
        for r = 1:num_ensayos
            longitudes(r) = height(struct_emg.(ensayos_objetivo{r}));
        end
        largo_minimo = min(longitudes);
        
        % 3. Pre-asignar matrices para alinear Izquierda y Derecha
        datos_alineados = struct();
        canales = {'L_TA', 'L_SL', 'L_GR', 'R_TA', 'R_SL', 'R_GR'};
        for c = 1:length(canales)
            datos_alineados.(canales{c}) = zeros(largo_minimo, num_ensayos);
        end
        
        % Extraer los datos y recortarlos al largo mínimo
        for r = 1:num_ensayos
            datos_ensayo = struct_emg.(ensayos_objetivo{r});
            for c = 1:length(canales)
                canal = canales{c};
                datos_alineados.(canal)(:, r) = datos_ensayo.(canal)(1:largo_minimo);
            end
        end
        
        % 4. Calcular la mediana (ensemble) de todos los ensayos
        mediana = struct();
        for c = 1:length(canales)
            canal = canales{c};
            mediana.(canal) = median(datos_alineados.(canal), 2, 'omitnan');
        end
        
        t = (0:largo_minimo-1)' / fs;
        
        % =================================================================
        % 5. GRAFICACIÓN POR FILAS (Músculos) Y COLUMNAS (ST/CT)
        % =================================================================
        for m = 1:length(musculos)
            musculo = musculos{m};
            canal_L = ['L_', musculo];
            canal_R = ['R_', musculo];
            
            % Posición del subplot: (Fila - 1) * 2 + Columna
            subplot(3, 2, (m-1)*2 + i);
            hold on;
            
            % Trazar la señal de ambas piernas
            p_L = plot(t, mediana.(canal_L), 'Color', colores.Izq, 'LineWidth', 1.5, 'DisplayName', 'Izquierdo');
            p_R = plot(t, mediana.(canal_R), 'Color', colores.Der, 'LineWidth', 1.5, 'DisplayName', 'Derecho');
            
            % --- CÁLCULO DEL YLIM INDIVIDUAL Y DINÁMICO ---
            max_val = max(max(mediana.(canal_L)), max(mediana.(canal_R)));
            min_val = min(min(mediana.(canal_L)), min(mediana.(canal_R)));
            rango = max_val - min_val;
            if rango == 0
                rango = 0.1; % Por si la señal fuera 0 absoluto
            end
            
            % Aseguramos un mínimo margen superior visual (al menos escala de 10%)
            y_max_lim = max(max_val + (rango * 0.25), 10); 
            yl_local = [min_val - (rango * 0.05), y_max_lim];
            
            xlim([0 t(end)]);
            ylim(yl_local);
            
            % --- FONDOS DE COLORES (FASES DEL PROTOCOLO) ---
            c1 = [0.2 0.6 1.0]; % Azul suave
            c2 = [0.2 0.8 0.4]; % Verde suave
            c3 = [1.0 0.6 0.2]; % Naranja suave
            c4 = [0.6 0.6 0.6]; % Gris suave
            
            y_min_patch = yl_local(1);
            y_max_patch = yl_local(2);
            
            p1 = patch([0 3 3 0], [y_min_patch y_min_patch y_max_patch y_max_patch], c1, 'FaceAlpha', 0.08, 'EdgeColor', 'none');
            p2 = patch([3 5 5 3], [y_min_patch y_min_patch y_max_patch y_max_patch], c2, 'FaceAlpha', 0.08, 'EdgeColor', 'none');
            p3 = patch([5 8 8 5], [y_min_patch y_min_patch y_max_patch y_max_patch], c3, 'FaceAlpha', 0.08, 'EdgeColor', 'none');
            p4 = patch([8 t(end) t(end) 8], [y_min_patch y_min_patch y_max_patch y_max_patch], c4, 'FaceAlpha', 0.08, 'EdgeColor', 'none');
            
            % Mandar fondos al fondo y señales al frente
            uistack([p1, p2, p3, p4], 'bottom'); 
            uistack([p_L, p_R], 'top');
            
            % Líneas divisorias
            xline(3, '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);
            xline(5, '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);
            xline(8, '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);
            
            % Textos de fases ajustados al techo dinámico
            y_text_pos = y_max_patch - 0.05 * (y_max_patch - y_min_patch); 
            text(1.5, y_text_pos, 'Elevación', 'HorizontalAlignment', 'center', 'FontSize', 8, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]);
            text(4.0, y_text_pos, 'Mantener', 'HorizontalAlignment', 'center', 'FontSize', 8, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]);
            text(6.5, y_text_pos, 'Descenso', 'HorizontalAlignment', 'center', 'FontSize', 8, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]);
            t_mid_retorno = 8 + (t(end) - 8) / 2; 
            text(t_mid_retorno, y_text_pos, 'Retorno', 'HorizontalAlignment', 'center', 'FontSize', 8, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]);
            
            % --- DISEÑO DEL EJE ---
            ax = gca;
            ax.FontSize = 10;           
            ax.LineWidth = 1.2;         
            ax.XColor = [0.3 0.3 0.3];  
            ax.YColor = [0.3 0.3 0.3];  
            box off; grid on; 
            ax.GridLineStyle = '--';    
            ax.GridAlpha = 0.3;
            
            % Títulos y Etiquetas dinámicas (Solo abajo y a la izquierda para no saturar)
            title([nombres_musculos{m}, ' | ', titulos_cond{i}], 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);
            if m == 3, xlabel('Tiempo [s]', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]); end
            if i == 1, ylabel('Activación [% Max]', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]); end
            if m == 1 && i == 1, legend([p_L, p_R], 'Pierna Izquierda', 'Pierna Derecha', 'Location', 'northeast'); end
            
            hold off;
        end
    end
end
function PlotEMG(emg_data, fs)
% PlotEMG Grafica las señales de EMG en subplots de 3x2 con diseño de presentación.
% Organiza automáticamente la pierna izquierda en la columna izquierda y la 
% derecha en la columna derecha, emparejando músculos antagonistas/agonistas.
% Identifica y marca automáticamente las fases del protocolo en ensayos de 
% Elevación de Puntillas (EP), con sombreado de fondo por fase.
% Excluye automáticamente el archivo 'EP ct 01'.
% Calcula un ylim individual y dinámico para cada músculo.
%
% INPUT:
%   emg_data - (Struct) Estructura que contiene las tablas con los datos EMG.
%   fs       - (Double) Frecuencia de muestreo en Hz (ej. 2000).
%
% OUTPUT:
%   Ninguno (Solo genera las figuras).

    % Obtener los nombres de los ensayos (campos del struct)
    field = fieldnames(emg_data); 
    
    if isempty(field)
        warning('La estructura de datos está vacía. No hay nada que graficar.');
        return;
    end
    
    % Extraemos los nombres de los músculos automáticamente de la primera tabla
    colnames = emg_data.(field{1}).Properties.VariableNames;
    
    % Recorrer cada ensayo en el struct
    for k = 1:length(field)
        nombre_ensayo = field{k};
        tabla_actual = emg_data.(nombre_ensayo);
        data_array = table2array(tabla_actual); 
        
        % Vector de tiempo en segundos
        t = (0:size(tabla_actual,1)-1) / fs;
        
        % Figura con fondo blanco ('Color', 'w')
        figure('Name', nombre_ensayo, 'Position', [100, 100, 1200, 800], 'Color', 'w'); 
        
        % Título principal 
        sgtitle(['Activación Muscular - Ensayo: ', strrep(nombre_ensayo, '_', ' ')], ...
            'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.15 0.15 0.15]);
            
        % Condiciones lógicas para pintar las fases
        es_EP = contains(nombre_ensayo, 'EP', 'IgnoreCase', true);
        nombre_limpio = strrep(nombre_ensayo, '_', ' '); 
        es_excepcion = contains(nombre_limpio, 'ep ct 01', 'IgnoreCase', true);
        
        % Ciclo para graficar cada músculo
        for j = 1:size(tabla_actual, 2)
            
            % --- ASIGNACIÓN ANATÓMICA DE SUBPLOTS ---
            nombre_musculo = upper(colnames{j});
            
            % Por defecto, por si hay un músculo que no coincida con los nombres esperados
            subplot_idx = j; 
            
            % Lado Izquierdo (Impares) vs Lado Derecho (Pares)
            if contains(nombre_musculo, 'L_TA') || contains(nombre_musculo, 'TA_L')
                subplot_idx = 1;
            elseif contains(nombre_musculo, 'R_TA') || contains(nombre_musculo, 'TA_R')
                subplot_idx = 2;
            elseif contains(nombre_musculo, 'L_GR') || contains(nombre_musculo, 'GR_L')
                subplot_idx = 3;
            elseif contains(nombre_musculo, 'R_GR') || contains(nombre_musculo, 'GR_R')
                subplot_idx = 4;
            elseif contains(nombre_musculo, 'L_SL') || contains(nombre_musculo, 'SL_L')
                subplot_idx = 5;
            elseif contains(nombre_musculo, 'R_SL') || contains(nombre_musculo, 'SL_R')
                subplot_idx = 6;
            end
            
            subplot(3, 2, subplot_idx); 
            hold on; 
            
            % --- CÁLCULO DEL YLIM INDIVIDUAL (POR MÚSCULO) ---
            % Obtenemos el mínimo y máximo exclusivo de esta señal
            min_val = min(data_array(:,j));
            max_val = max(data_array(:,j));
            
            % Agregamos un margen proporcional
            rango = max_val - min_val;
            if rango == 0
                rango = 0.1; % Por si la señal fuera completamente plana (0)
            end
            yl_local = [min_val - (rango * 0.05), max_val + (rango * 0.15)];
            
            % 1. Trazamos la señal
            p_signal = plot(t, data_array(:,j), 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 1.2); 
            
            % Ajustar los límites del eje X y el nuevo eje Y individual
            xlim([0, t(end)]);
            ylim(yl_local);
            
            % ---------------------------------------------------------
            % IDENTIFICACIÓN DE FASES PARA ELEVACIÓN DE PUNTILLAS (EP)
            % ---------------------------------------------------------
            if es_EP && ~es_excepcion
                
                c1 = [0.2 0.6 1.0]; % Azul suave
                c2 = [0.2 0.8 0.4]; % Verde suave
                c3 = [1.0 0.6 0.2]; % Naranja suave
                c4 = [0.6 0.6 0.6]; % Gris suave
                
                % Usamos yl_local para que los parches cubran exactamente esta gráfica
                y_min_patch = yl_local(1);
                y_max_patch = yl_local(2);
                
                p1 = patch([0 3 3 0], [y_min_patch y_min_patch y_max_patch y_max_patch], c1, 'FaceAlpha', 0.08, 'EdgeColor', 'none');
                p2 = patch([3 5 5 3], [y_min_patch y_min_patch y_max_patch y_max_patch], c2, 'FaceAlpha', 0.08, 'EdgeColor', 'none');
                p3 = patch([5 8 8 5], [y_min_patch y_min_patch y_max_patch y_max_patch], c3, 'FaceAlpha', 0.08, 'EdgeColor', 'none');
                p4 = patch([8 t(end) t(end) 8], [y_min_patch y_min_patch y_max_patch y_max_patch], c4, 'FaceAlpha', 0.08, 'EdgeColor', 'none');
                
                uistack([p1, p2, p3, p4], 'bottom'); 
                uistack(p_signal, 'top');
                
                % Líneas divisorias
                xline(3, '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);
                xline(5, '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);
                xline(8, '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);
                
                % Textos centrados y ajustados al techo de este subplot en específico
                y_text_pos = y_max_patch - 0.05 * rango; 
                text(1.5, y_text_pos, 'Elevación', 'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]);
                text(4.0, y_text_pos, 'Mantener', 'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]);
                text(6.5, y_text_pos, 'Descenso', 'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]);
                
                t_mid_retorno = 8 + (t(end) - 8) / 2; 
                text(t_mid_retorno, y_text_pos, 'Retorno', 'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]);
            end
            
            % --- DISEÑO DEL EJE ---
            ax = gca;
            ax.FontSize = 10;           
            ax.LineWidth = 1.2;         
            ax.XColor = [0.3 0.3 0.3];  
            ax.YColor = [0.3 0.3 0.3];  
            box off;                    
            grid on; 
            ax.GridLineStyle = '--';    
            ax.GridAlpha = 0.3;         
            
            % Título y Etiquetas
            title(colnames{j}, 'Interpreter', 'none', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]); 
            xlabel('Tiempo [s]', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]); 
            ylabel('Activación [% Max]', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]);
            
            hold off; 
        end
    end
end
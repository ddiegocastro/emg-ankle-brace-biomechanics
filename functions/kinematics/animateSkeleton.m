function animateSkeleton(vicon_data_corrected, ruta_salida)
% ANIMATESKELETON Genera una animación 3D de los marcadores cinemáticos
% y guarda cada ensayo como un video MP4 en la ruta especificada.

    disp('================ INICIANDO ANIMACIÓN 3D Y GRABACIÓN ================');
    
    if ~exist(ruta_salida, 'dir')
        mkdir(ruta_salida);
        disp(['Carpeta de salida creada: ', ruta_salida]);
    end
    
    esqueleto_def = { ...
        'LASI', 'RASI'; 'LASI', 'LPSI'; 'RASI', 'RPSI'; 'LPSI', 'RPSI'; ... % Pélvica
        'LASI', 'LKNE'; 'LKNE', 'LANK'; 'LANK', 'LHEE'; 'LANK', 'LTOE'; 'LHEE', 'LTOE'; ... % Izquierdo
        'RASI', 'RKNE'; 'RKNE', 'RANK'; 'RANK', 'RHEE'; 'RANK', 'RTOE'; 'RHEE', 'RTOE'; ... % Derecho
        'LASI', 'LTHI'; 'LTHI', 'LKNE'; ... % Muslo Izquierdo
        'RASI', 'RTHI'; 'RTHI', 'RKNE'; ... % Muslo Derecho
        'LKNE', 'LTIB'; 'LTIB', 'LANK'; ... % Tibia Izquierda
        'RKNE', 'RTIB'; 'RTIB', 'RANK'  ... % Tibia Derecha
    };
    
    fig = figure('Name', 'Validación Cinemática Vicon', 'Position', [100, 100, 900, 800]);
    set(fig, 'Color', [0.1 0.1 0.12]); 
    
    archivos_a_animar = fieldnames(vicon_data_corrected);
    
    for f = 1:length(archivos_a_animar)
        file_demo = archivos_a_animar{f};
        tabla_animacion = vicon_data_corrected.(file_demo);
        nombres_cols = tabla_animacion.Properties.VariableNames;
        
        video_filename = fullfile(ruta_salida, [file_demo, '.mp4']);
        v_writer = VideoWriter(video_filename, 'MPEG-4');
        v_writer.FrameRate = 30; 
        v_writer.Quality = 90;   
        open(v_writer);
        
        clf(fig);
        ax = axes('Parent', fig);
        hold(ax, 'on'); 
        
        set(ax, 'Color', [0.1 0.1 0.12], 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w', 'FontSize', 10);
        grid(ax, 'on'); 
        xlabel(ax, 'Eje X (mm)'); ylabel(ax, 'Eje Y (mm)'); zlabel(ax, 'Eje Z (mm)');
        view(ax, 3); 
        
        % EXTRAER DATOS A MATRICES NUMÉRICAS (Optimización #1)
        idx_X = endsWith(nombres_cols, '_X') | endsWith(nombres_cols, 'X');
        idx_Y = endsWith(nombres_cols, '_Y') | endsWith(nombres_cols, 'Y');
        idx_Z = endsWith(nombres_cols, '_Z') | endsWith(nombres_cols, 'Z');
        
        all_X = table2array(tabla_animacion(:, idx_X));
        all_Y = table2array(tabla_animacion(:, idx_Y));
        all_Z = table2array(tabla_animacion(:, idx_Z));
        
        n_markers = size(all_X, 2);
        n_frames = height(tabla_animacion);
        
        % Obtener los nombres base de los marcadores para mapear el esqueleto
        cols_X_names = nombres_cols(idx_X);
        base_marker_names = cell(1, n_markers);
        for m = 1:n_markers
            if endsWith(cols_X_names{m}, '_X')
                base_marker_names{m} = cols_X_names{m}(1:end-2);
            else
                base_marker_names{m} = cols_X_names{m}(1:end-1);
            end
        end
        
        min_x = min(all_X(:), [], 'omitnan'); max_x = max(all_X(:), [], 'omitnan');
        min_y = min(all_Y(:), [], 'omitnan'); max_y = max(all_Y(:), [], 'omitnan');
        min_z = min(all_Z(:), [], 'omitnan'); max_z = max(all_Z(:), [], 'omitnan');
        
        centro_x = (max_x + min_x) / 2; centro_y = (max_y + min_y) / 2; centro_z = (max_z + min_z) / 2;
        rango_max = max([max_x - min_x, max_y - min_y, max_z - min_z]);
        radio = (rango_max / 2) + 200; 
        
        lim_x = [centro_x - radio, centro_x + radio];
        lim_y = [centro_y - radio, centro_y + radio];
        lim_z = [centro_z - radio, centro_z + radio];
        
        xlim(ax, lim_x); ylim(ax, lim_y); zlim(ax, lim_z);
        axis(ax, 'vis3d'); 
        
        h_scatter = scatter3(ax, NaN, NaN, NaN, 80, 'filled', ...
            'MarkerFaceColor', [0.95 0.95 1], 'MarkerEdgeColor', [0.5 0.5 0.5], 'LineWidth', 1);
        
        % Preparar variables para las líneas del esqueleto
        h_lines = gobjects(0); 
        idx_m1_array = [];
        idx_m2_array = [];
        
        for c = 1:size(esqueleto_def, 1)
            m1 = esqueleto_def{c, 1}; m2 = esqueleto_def{c, 2};
            
            % Encontrar los índices numéricos de estos marcadores (Optimización #3)
            idx1 = find(strcmp(base_marker_names, m1), 1);
            idx2 = find(strcmp(base_marker_names, m2), 1);
            
            if ~isempty(idx1) && ~isempty(idx2)
                if startsWith(m1, 'L') && startsWith(m2, 'L')
                    line_color = [0.9 0.2 0.2]; 
                elseif startsWith(m1, 'R') && startsWith(m2, 'R')
                    line_color = [0.2 0.8 0.2]; 
                else
                    line_color = [0.2 0.7 0.8]; 
                end
                
                h_lines(end+1) = plot3(ax, [NaN, NaN], [NaN, NaN], [NaN, NaN], ...
                    'Color', [line_color, 0.85], 'LineWidth', 3, 'Handlevisibility', 'off');
                
                idx_m1_array(end+1) = idx1;
                idx_m2_array(end+1) = idx2;
            end
        end
        
        % Crear el objeto de título una sola vez (Optimización #4)
        h_title = title(ax, '', 'Interpreter', 'none', 'Color', 'w', 'FontSize', 12);
        
        step = 2; 
        disp(['Grabando video: ', file_demo, '.mp4 ...']);
        
        % --- BUCLE DE ANIMACIÓN ULTRARRÁPIDO ---
        % --- BUCLE DE ANIMACIÓN ULTRARRÁPIDO ---
        for t = 1:step:n_frames
            if ~isgraphics(fig)
                close(v_writer); 
                break; 
            end
            
            % 1. Actualizar Scatter directamente de la matriz
            h_scatter.XData = all_X(t, :); 
            h_scatter.YData = all_Y(t, :); 
            h_scatter.ZData = all_Z(t, :);
            
            % 2. Actualizar Líneas usando los índices precalculados
            for l = 1:length(h_lines)
                i1 = idx_m1_array(l);
                i2 = idx_m2_array(l);
                
                h_lines(l).XData = [all_X(t, i1), all_X(t, i2)];
                h_lines(l).YData = [all_Y(t, i1), all_Y(t, i2)];
                h_lines(l).ZData = [all_Z(t, i1), all_Z(t, i2)];
            end
            
            % 3. Actualizar solo el String del título
            h_title.String = sprintf('Grabando: %s | Frame: %d / %d', file_demo, t, n_frames);
            
            % -> LA CORRECCIÓN: Forzar la actualización visual en la pantalla <-
            drawnow; 
            
            % 4. Capturar el frame
            frame_actual = getframe(fig);
            writeVideo(v_writer, frame_actual);
        end        
        close(v_writer);
        if ~isgraphics(fig), break; end
        
        h_title.String = sprintf('Guardado: %s.mp4', file_demo);
        h_title.Color = [0.4 0.9 0.4];
        pause(1); 
    end
    
    if isgraphics(fig)
        close(fig); 
    end
    disp('================ TODOS LOS VIDEOS HAN SIDO GUARDADOS EXITOSAMENTE ================');
end
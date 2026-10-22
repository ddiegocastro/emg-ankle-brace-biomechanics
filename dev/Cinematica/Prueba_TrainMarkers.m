% Auto-exported from Cinematica/Prueba_TrainMarkers.mlx (code cells only).

% Buscar marcadores perdidos en mediciones 
clear; clc; close all; 
rng(42);
% Rutas utilizadas: 
ruta_datos = '<project_root>\ProyectoFinal\InputData\Injured\Vicon'; 
ruta_funciones = '<project_root>\ProyectoFinal\Functions';
addpath(ruta_funciones);

% Cargar datos
vicon_data = loadVicon(ruta_datos);

% Cargar matriz de detección de NaNs. 
nans_table = findNaNs(vicon_data);
disp(nans_table);

% Cargar struct de predictores
predictors_dict = findPredictors(vicon_data, nans_table);

disp('================ INICIANDO ENTRENAMIENTO DE MODELOS ================');

% Estructura para guardar los modelos entrenados y sus métricas
modelos_entrenados = struct(); 

% Obtener los archivos que tienen marcadores para corregir
archivos_con_errores = fieldnames(predictors_dict);

for f = 1:length(archivos_con_errores)
    file_name = archivos_con_errores{f};
    marcadores_perdidos = fieldnames(predictors_dict.(file_name));
    
    fprintf('\n--- Procesando Archivo: %s ---\n', file_name);
    
    for m = 1:length(marcadores_perdidos)
        target_marker = marcadores_perdidos{m};
        
        % Obtener la lista de predictores para este marcador específico
        predictors = predictors_dict.(file_name).(target_marker);
        
        % Extraer la tabla de datos completa de este archivo
        data_table = vicon_data.(file_name);
        
        % Extraer la variable dependiente (Y) y las independientes (X)
        Y_full = data_table.(target_marker);
        X_full = table2array(data_table(:, predictors));
        
        % 1. Extraer solo los fotogramas válidos (donde Y NO es NaN) para entrenar
        valid_idx = ~isnan(Y_full);
        X_valid = X_full(valid_idx, :);
        Y_valid = Y_full(valid_idx);
        
        n_samples = length(Y_valid);
        
        % Si por alguna razón hay muy pocos datos válidos, omitimos (filtro de seguridad)
        if n_samples < 10
            fprintf('[!] %s: Datos insuficientes para entrenar.\n', target_marker);
            continue;
        end
        
        % 2. División 70/30 (Train / Test Split)
        n_train = round(0.70 * n_samples);
        
        % Usamos randperm para mezclar los datos aleatoriamente. 
        rand_idx = randperm(n_samples);
        train_idx = rand_idx(1:n_train);
        test_idx = rand_idx(n_train+1:end);
        
        % Asignación de datos
        X_train = X_valid(train_idx, :);
        Y_train = Y_valid(train_idx);
        
        X_test = X_valid(test_idx, :);
        Y_test = Y_valid(test_idx);
        
        % 3. Estandarización de distribución Z (Z-Score)
        mu_X = mean(X_train);
        sigma_X = std(X_train);
        
        % Prevención de división por cero si un marcador de referencia no se movió nada
        sigma_X(sigma_X == 0) = 1; 
        
        % Aplicamos la distribución Z a X_train y X_test
        X_train_z = (X_train - mu_X) ./ sigma_X;
        X_test_z = (X_test - mu_X) ./ sigma_X;
        
        % 4. Entrenamiento del Modelo (Regresión Lineal)
        mdl = fitlm(X_train_z, Y_train);
        
        % 5. Evaluación (Predicción en el 30% nunca antes visto)
        Y_pred = predict(mdl, X_test_z);
        
        % Cálculo de Root Mean Square Error (RMSE)
        rmse = sqrt(mean((Y_test - Y_pred).^2));
        
        % Extracción de R Cuadrada 
        r2 = mdl.Rsquared.Ordinary;
        
        % 6. Guardar todo en la estructura principal para su uso posterior
        modelos_entrenados.(file_name).(target_marker).Model = mdl;
        modelos_entrenados.(file_name).(target_marker).Mu = mu_X;
        modelos_entrenados.(file_name).(target_marker).Sigma = sigma_X;
        modelos_entrenados.(file_name).(target_marker).RMSE = rmse;
        modelos_entrenados.(file_name).(target_marker).R2 = r2;
        modelos_entrenados.(file_name).(target_marker).Predictors = predictors;
        
        % Reporte en consola
        fprintf('Marcador: %s | RMSE: %6.2f mm | R2: %.4f\n', target_marker, rmse, r2);
    end
end
disp('================ ENTRENAMIENTO FINALIZADO ================');

modelos_entrenados_func = trainMarkers(vicon_data, predictors_dict); 
disp(isequal(modelos_entrenados,modelos_entrenados_func));

disp('================ INICIANDO IMPUTACIÓN DE DATOS ================');

% Clonar la estructura original para rellenar los NaNs sin destruir el set crudo
vicon_data_corrected = vicon_data; 

for f = 1:length(archivos_con_errores)
    file_name = archivos_con_errores{f};
    
    % Comprobar si este archivo realmente generó algún modelo de corrección
    if isfield(modelos_entrenados, file_name)
        marcadores_perdidos = fieldnames(modelos_entrenados.(file_name));
        
        for m = 1:length(marcadores_perdidos)
            target_marker = marcadores_perdidos{m};
            modelo_info = modelos_entrenados.(file_name).(target_marker);
            
            % Extraer coordenadas vectoriales completas del marcador con problemas
            data_table = vicon_data_corrected.(file_name);
            Y_full = data_table.(target_marker);
            
            % Ubicar de forma exacta las filas que contienen NaNs
            idx_missing = find(isnan(Y_full));
            
            if ~isempty(idx_missing)
                % Extraer la submatriz de predictores asociada en los fotogramas perdidos
                X_missing = table2array(data_table(idx_missing, modelo_info.Predictors));
                
                % Normalizar bajo la misma transformación Z calculada en el set de entrenamiento
                X_missing_z = (X_missing - modelo_info.Mu) ./ modelo_info.Sigma;
                
                % Computar predictores mediante regresión
                Y_pred = predict(modelo_info.Model, X_missing_z);
                
                % Inyectar la reconstrucción del modelo de vuelta en la tabla limpia
                vicon_data_corrected.(file_name).(target_marker)(idx_missing) = Y_pred;
                
                fprintf('Archivo: %s -> Reconstruidos %d frames para el marcador %s\n', ...
                        file_name, length(idx_missing), target_marker);
            end
        end
    end
end
disp('================ IMPUTACIÓN FINALIZADA ================');

vicon_data_corrected_func = imputateData(vicon_data, modelos_entrenados);
isequal(vicon_data_corrected_func, vicon_data_corrected)

disp('================ INICIANDO ANIMACIÓN 3D PARA TODOS LOS ARCHIVOS ================');

% --- DEFINICIÓN DEL ESQUELETO MEJORADO (Estructuración anatómica biomecánica) ---
esqueleto_def = { ...
    'LASI', 'RASI'; 'LASI', 'LPSI'; 'RASI', 'RPSI'; 'LPSI', 'RPSI'; ... % Estructura Pélvica
    'LASI', 'LKNE'; 'LKNE', 'LANK'; 'LANK', 'LHEE'; 'LANK', 'LTOE'; 'LHEE', 'LTOE'; ... % Eje Central Articular Izquierdo
    'RASI', 'RKNE'; 'RKNE', 'RANK'; 'RANK', 'RHEE'; 'RANK', 'RTOE'; 'RHEE', 'RTOE'; ... % Eje Central Articular Derecho
    'LASI', 'LTHI'; 'LTHI', 'LKNE'; ... % Conexiones flotantes del Tracking Muslo Izquierdo
    'RASI', 'RTHI'; 'RTHI', 'RKNE'; ... % Conexiones flotantes del Tracking Muslo Derecho
    'LKNE', 'LTIB'; 'LTIB', 'LANK'; ... % Conexiones flotantes del Tracking Tibia Izquierda
    'RKNE', 'RTIB'; 'RTIB', 'RANK'  ... % Conexiones flotantes del Tracking Tibia Derecha
};

% Preparar la ventana de la figura con estilo Dark Mode
fig = figure('Name', 'Validación Cinemática Vicon', 'Position', [100, 100, 900, 800]);
set(fig, 'Color', [0.1 0.1 0.12]); 

% Ciclo externo: Recorrer TODOS los archivos
for f = 1:length(archivos_con_errores)
    file_demo = archivos_con_errores{f};
    tabla_animacion = vicon_data_corrected.(file_demo);
    nombres_cols = tabla_animacion.Properties.VariableNames;
    
    % Limpiar la figura y configurar los ejes
    clf(fig);
    ax = axes('Parent', fig);
    
    % --- CORRECCIÓN CRÍTICA 1: Activar HOLD ON ANTES de configurar los ejes ---
    hold(ax, 'on'); 
    
    % Configuración visual de los ejes
    set(ax, 'Color', [0.1 0.1 0.12], 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w', 'FontSize', 10);
    grid(ax, 'on'); 
    xlabel(ax, 'Eje X (mm)'); ylabel(ax, 'Eje Y (mm)'); zlabel(ax, 'Eje Z (mm)');
    view(ax, 3); 
    
    % Identificar automáticamente cuáles columnas son X
    cols_X = nombres_cols(endsWith(nombres_cols, '_X') | endsWith(nombres_cols, 'X'));
    n_markers = length(cols_X);
    n_frames = height(tabla_animacion);
    
    % --- CÁLCULO DE LÍMITES FIJOS Y RÍGIDOS ---
    all_X = table2array(tabla_animacion(:, endsWith(nombres_cols, '_X') | endsWith(nombres_cols, 'X')));
    all_Y = table2array(tabla_animacion(:, endsWith(nombres_cols, '_Y') | endsWith(nombres_cols, 'Y')));
    all_Z = table2array(tabla_animacion(:, endsWith(nombres_cols, '_Z') | endsWith(nombres_cols, 'Z')));
    
    min_x = min(all_X(:), [], 'omitnan'); max_x = max(all_X(:), [], 'omitnan');
    min_y = min(all_Y(:), [], 'omitnan'); max_y = max(all_Y(:), [], 'omitnan');
    min_z = min(all_Z(:), [], 'omitnan'); max_z = max(all_Z(:), [], 'omitnan');
    
    centro_x = (max_x + min_x) / 2;
    centro_y = (max_y + min_y) / 2;
    centro_z = (max_z + min_z) / 2;
    
    rango_max = max([max_x - min_x, max_y - min_y, max_z - min_z]);
    radio = (rango_max / 2) + 200; 
    
    % Calcular los límites exactos
    lim_x = [centro_x - radio, centro_x + radio];
    lim_y = [centro_y - radio, centro_y + radio];
    lim_z = [centro_z - radio, centro_z + radio];
    
    % Aplicar los límites de manera estricta
    xlim(ax, lim_x);
    ylim(ax, lim_y);
    zlim(ax, lim_z);
    
    % --- CORRECCIÓN CRÍTICA 2: Imponer valores numéricos duros en los ejes ---
    ax.XTick = round(linspace(lim_x(1), lim_x(2), 5));
    ax.YTick = round(linspace(lim_y(1), lim_y(2), 5));
    ax.ZTick = round(linspace(lim_z(1), lim_z(2), 5));
    
    % --- CORRECCIÓN CRÍTICA 3: Bloquear absolutamente TODOS los modos ---
    ax.XLimMode = 'manual'; ax.YLimMode = 'manual'; ax.ZLimMode = 'manual';
    ax.XTickMode = 'manual'; ax.YTickMode = 'manual'; ax.ZTickMode = 'manual';
    ax.XTickLabelMode = 'manual'; ax.YTickLabelMode = 'manual'; ax.ZTickLabelMode = 'manual';
    
    % Congelar proporción 3D para evitar distorsiones
    axis(ax, 'vis3d'); 
    
    % --- INICIALIZAR GRÁFICOS ---
    h_scatter = scatter3(ax, NaN, NaN, NaN, 80, 'filled', ...
        'MarkerFaceColor', [0.95 0.95 1], ...
        'MarkerEdgeColor', [0.5 0.5 0.5], ...
        'LineWidth', 1);
    
    % (Eliminamos el hold on de aquí, ya está arriba)
    
    % --- INICIALIZAR GRÁFICOS ---
    h_scatter = scatter3(ax, NaN, NaN, NaN, 80, 'filled', ...
        'MarkerFaceColor', [0.95 0.95 1], ...
        'MarkerEdgeColor', [0.5 0.5 0.5], ...
        'LineWidth', 1);
    hold(ax, 'on');
    
    h_lines = gobjects(0); 
    conexiones_validas = [];
    
    % Inicializar las conexiones del esqueleto con lógica cromática biomecánica
    for c = 1:size(esqueleto_def, 1)
        m1 = esqueleto_def{c, 1};
        m2 = esqueleto_def{c, 2};
        
        has_m1 = any(strcmp(nombres_cols, [m1, '_X']) | strcmp(nombres_cols, [m1, 'X']));
        has_m2 = any(strcmp(nombres_cols, [m2, '_X']) | strcmp(nombres_cols, [m2, 'X']));
        
        if has_m1 && has_m2
            % Segmentos izquierdos en Rojo, derechos en Verde, estructuras de acople en Cian
            if startsWith(m1, 'L') && startsWith(m2, 'L')
                line_color = [0.9 0.2 0.2]; 
            elseif startsWith(m1, 'R') && startsWith(m2, 'R')
                line_color = [0.2 0.8 0.2]; 
            else
                line_color = [0.2 0.7 0.8]; 
            end
            
            % Generación de los punteros estables de dibujo lineal
            h_lines(end+1) = plot3(ax, [NaN, NaN], [NaN, NaN], [NaN, NaN], ...
                'Color', [line_color, 0.85], 'LineWidth', 3, 'Handlevisibility', 'off');
            conexiones_validas(end+1) = c; 
        end
    end
    
    % --- BUCLE DE ANIMACIÓN ---
    coords = zeros(n_markers, 3);
    step = 2; % Brinco de frames adaptativo (Modifica para acelerar o ralentizar la reproducción)
    
    for t = 1:step:n_frames
        if ~isgraphics(fig), break; end
        
        % 1. Dibujar nubes dinámicas de Marcadores
        for m = 1:n_markers
            if endsWith(cols_X{m}, '_X')
                base_name = cols_X{m}(1:end-2);
                sufijo = '_';
            else
                base_name = cols_X{m}(1:end-1);
                sufijo = '';
            end
            coords(m, 1) = tabla_animacion.([base_name, sufijo, 'X'])(t);
            coords(m, 2) = tabla_animacion.([base_name, sufijo, 'Y'])(t);
            coords(m, 3) = tabla_animacion.([base_name, sufijo, 'Z'])(t);
        end
        h_scatter.XData = coords(:,1);
        h_scatter.YData = coords(:,2);
        h_scatter.ZData = coords(:,3);
        
        % 2. Actualizar Esqueleto de Vectores Óseos
        for l = 1:length(h_lines)
            idx_c = conexiones_validas(l);
            m1 = esqueleto_def{idx_c, 1};
            m2 = esqueleto_def{idx_c, 2};
            
            if any(strcmp(nombres_cols, [m1, '_X'])), s1 = '_'; else, s1 = ''; end
            if any(strcmp(nombres_cols, [m2, '_X'])), s2 = '_'; else, s2 = ''; end
            
            h_lines(l).XData = [tabla_animacion.([m1, s1, 'X'])(t), tabla_animacion.([m2, s2, 'X'])(t)];
            h_lines(l).YData = [tabla_animacion.([m1, s1, 'Y'])(t), tabla_animacion.([m2, s2, 'Y'])(t)];
            h_lines(l).ZData = [tabla_animacion.([m1, s1, 'Z'])(t), tabla_animacion.([m2, s2, 'Z'])(t)];
        end
        
        title(ax, sprintf('Validación: %s | Frame: %d / %d', file_demo, t, n_frames), ...
            'Interpreter', 'none', 'Color', 'w', 'FontSize', 12);
        drawnow;
    end
    
    if ~isgraphics(fig), break; end
    title(ax, sprintf('Validación: %s (Completado) -> Siguiente archivo en 2s...', file_demo), ...
        'Interpreter', 'none', 'Color', [0.4 0.9 0.4], 'FontSize', 12);
    pause(2); 
end

disp('================ PROCESO TOTAL COMPLETADO CON ÉXITO ================');

animateSkeleton(vicon_data_corrected_func);

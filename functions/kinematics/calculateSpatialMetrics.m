function spatial_feats = calculateSpatialMetrics(vicon_data, marker_name, condicion_keyword)
% CALCULATESPATIALMETRICS Calcula la altura real del salto (Z) y la deriva de aterrizaje (X,Y)
% Soporta datos estructurados en matrices completas o en columnas separadas (_X, _Y, _Z).

    ensayos_filtrados = {}; 

    % 1. Detectar estructura y agrupar los ensayos
    if length(vicon_data) > 1 && isstruct(vicon_data)
        nombres_ensayos = {vicon_data.name}; 
        idx_match = contains(nombres_ensayos, condicion_keyword, 'IgnoreCase', true);
        ensayos_match = vicon_data(idx_match);
        for idx = 1:length(ensayos_match)
            ensayos_filtrados{idx} = ensayos_match(idx);
        end
    elseif isstruct(vicon_data)
        campos = fieldnames(vicon_data);
        idx_match = contains(campos, condicion_keyword, 'IgnoreCase', true);
        campos_filtrados = campos(idx_match);
        
        for idx = 1:length(campos_filtrados)
            ensayos_filtrados{idx} = vicon_data.(campos_filtrados{idx});
        end
    else
        error('El formato de vicon_data no es compatible.');
    end

    if isempty(ensayos_filtrados)
        error(['No se encontraron archivos con la palabra clave: ', condicion_keyword]);
    end

    % Vectores de acumulación
    lista_alturas = [];
    lista_drifts_X = [];
    lista_drifts_Y = [];
    lista_drifts_tot = [];

    % Definir los nombres separados por eje
    col_X = [marker_name, '_X'];
    col_Y = [marker_name, '_Y'];
    col_Z = [marker_name, '_Z'];

    % 2. Procesar cada ensayo filtrado
    for i = 1:length(ensayos_filtrados)
        ensayo_actual = ensayos_filtrados{i}; 
        
        tiene_marcador = false;
        coords = [];
        
        % Comprobar si existen las columnas separadas o la matriz unida
        if istable(ensayo_actual)
            vars = ensayo_actual.Properties.VariableNames;
            if ismember(col_X, vars) && ismember(col_Y, vars) && ismember(col_Z, vars)
                % Construir la matriz Nx3 a partir de las 3 columnas
                coords = [ensayo_actual.(col_X), ensayo_actual.(col_Y), ensayo_actual.(col_Z)];
                tiene_marcador = true;
            elseif ismember(marker_name, vars)
                coords = ensayo_actual.(marker_name);
                tiene_marcador = true;
            end
        elseif isstruct(ensayo_actual)
            if isfield(ensayo_actual, col_X) && isfield(ensayo_actual, col_Y) && isfield(ensayo_actual, col_Z)
                coords = [ensayo_actual.(col_X), ensayo_actual.(col_Y), ensayo_actual.(col_Z)];
                tiene_marcador = true;
            elseif isfield(ensayo_actual, marker_name)
                coords = ensayo_actual.(marker_name);
                tiene_marcador = true;
            end
        end
        
        % Si encontramos el marcador (en cualquier formato), hacemos los cálculos
        if tiene_marcador && ~isempty(coords)
            
            % --- CÁLCULO DE ALTURA REAL EN Z ---
            z_inicial = mean(coords(1:10, 3), 'omitnan');
            z_maxima = max(coords(:, 3), [], 'omitnan');
            altura_ensayo = (z_maxima - z_inicial) / 10; % De mm a cm
            
            % --- CÁLCULO DE DERIVA DE ATERRIZAJE (X, Y) ---
            pos_ini_X = mean(coords(1:10, 1), 'omitnan');
            pos_ini_Y = mean(coords(1:10, 2), 'omitnan');
            
            pos_fin_X = mean(coords(end-9:end, 1), 'omitnan');
            pos_fin_Y = mean(coords(end-9:end, 2), 'omitnan');
            
            dX = pos_fin_X - pos_ini_X; % mm
            dY = pos_fin_Y - pos_ini_Y; % mm
            dTot = sqrt(dX^2 + dY^2) / 10; % Distancia en cm
            
            if ~isnan(altura_ensayo)
                lista_alturas(end+1) = altura_ensayo;
                lista_drifts_X(end+1) = dX;
                lista_drifts_Y(end+1) = dY;
                lista_drifts_tot(end+1) = dTot;
            end
        end
    end

    % 3. Extraer la mediana representativa
    if isempty(lista_alturas)
        error(['El marcador ', marker_name, ' (o sus variantes _X, _Y, _Z) no se encontró.']);
    end
    
    spatial_feats.altura_salto_cm    = median(lista_alturas);
    spatial_feats.delta_X_mm         = median(lista_drifts_X);
    spatial_feats.delta_Y_mm         = median(lista_drifts_Y);
    spatial_feats.distancia_total_cm = median(lista_drifts_tot);
end
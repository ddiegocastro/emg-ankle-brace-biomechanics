function fases = DetectJumpPhases(cetic_data_struct, fs)
% DetectJumpPhases Localiza de forma automática los índices de Despegue (Take-off)
% y Aterrizaje (Touchdown) EXCLUSIVAMENTE para ensayos de Salto Vertical (SV).
% Ignora automáticamente ensayos de otras tareas como EP o RP.

    fases = struct();
    fields = fieldnames(cetic_data_struct);
    
    for k = 1:length(fields)
        ensayo = fields{k};
        
        % --- FILTRO EXCLUSIVO PARA SALTO VERTICAL (SV) ---
        % Si el nombre del ensayo NO empieza con 'SV', se lo salta y va al siguiente
        if ~startsWith(ensayo, 'SV', 'IgnoreCase', true)
            continue; 
        end
        
        tabla_cinetica = cetic_data_struct.(ensayo);
        nombres_columnas = tabla_cinetica.Properties.VariableNames;
        idx_fz = contains(nombres_columnas, 'Fz', 'IgnoreCase', true);
        columnas_fz = nombres_columnas(idx_fz);
        
        % 1. Sumar las fuerzas verticales y aplicar VALOR ABSOLUTO
        if length(columnas_fz) >= 2
            Fz_total = abs(tabla_cinetica.(columnas_fz{1}) + tabla_cinetica.(columnas_fz{2}));
        else
            Fz_total = abs(tabla_cinetica.(columnas_fz{1}));
        end
        
        % 2. CALCULAR UMBRAL ADAPTATIVO
        peso_medio = mean(Fz_total(1:round(0.5 * fs)));
        sd_peso = std(Fz_total(1:round(0.5 * fs)));
        
        % Umbral de vuelo como el 5% de su peso corporal
        umbral_vuelo = 0.05 * peso_medio; 
        
        % 3. DETECCIÓN DE LÓGICA DE VUELO
        en_vuelo = Fz_total < umbral_vuelo;
        cambios_vuelo = diff(en_vuelo);
        
        % Despegue: Primera transición de suelo (0) a aire (1)
        idx_despegue = find(cambios_vuelo == 1, 1, 'first') + 1;
        
        % Aterrizaje: Buscamos el impacto real después del despegue
        if ~isempty(idx_despegue)
            idx_aterrizaje_local = find(Fz_total(idx_despegue:end) >= umbral_vuelo, 1, 'first');
            if ~isempty(idx_aterrizaje_local)
                idx_aterrizaje = idx_despegue + idx_aterrizaje_local - 1;
            else
                idx_aterrizaje = [];
            end
        else
            idx_aterrizaje = [];
        end
        
        % 4. DETECCIÓN INICIO DEL MOVIMIENTO (Fase de agachado)
        if ~isempty(idx_despegue)
            ventana_atras = max(1, idx_despegue - (1.5 * fs));
            desviacion = abs(Fz_total(ventana_atras:idx_despegue) - peso_medio);
            
            idx_inicio_local = find(desviacion > (3 * sd_peso), 1, 'first');
            
            if ~isempty(idx_inicio_local)
                idx_inicio = ventana_atras + idx_inicio_local - 1;
            else
                idx_inicio = max(1, idx_despegue - (1 * fs)); 
            end
        else
            idx_inicio = [];
        end
        
        % Guardar resultados en la estructura solo si se encontraron todas las fases
        if isempty(idx_inicio) || isempty(idx_despegue) || isempty(idx_aterrizaje)
            fases.(ensayo).idx_inicio = NaN;
            fases.(ensayo).idx_despegue = NaN;
            fases.(ensayo).idx_aterrizaje = NaN;
        else
            fases.(ensayo).idx_inicio = idx_inicio;
            fases.(ensayo).idx_despegue = idx_despegue;
            fases.(ensayo).idx_aterrizaje = idx_aterrizaje;
        end
    end
end
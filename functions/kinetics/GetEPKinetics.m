function resultados_EP = GetEPKinetics(cinetic_data, fs)
    % Extraer los nombres de todos los campos (ensayos) del struct
    campos = fieldnames(cinetic_data);
    
    % Inicializar la tabla vacía donde se guardarán los resultados
    resultados_EP = table();
    
    % Definición de la ventana cronológica estandarizada (segundos)
    t_inicio = 3; 
    t_fin = 5;
    
    for k = 1:length(campos)
        nombre_ensayo = campos{k};
        
        % Filtrar y procesar únicamente los ensayos de Elevación de Puntillas (EP)
        if startsWith(nombre_ensayo, 'Ep', 'IgnoreCase', true) || startsWith(nombre_ensayo, 'EP')
            trial_data = cinetic_data.(nombre_ensayo);
            
            % Extraer las Fuerzas Verticales
            R_Fz = trial_data.R_Fz;
            L_Fz = trial_data.L_Fz;
            
            % =========================================================
            % AJUSTE DE EJES: X = Anteroposterior (AP), Y = Mediolateral (ML)
            % =========================================================
            R_CoP_AP = trial_data.R_Cx; 
            R_CoP_ML = trial_data.R_Cy;
            L_CoP_AP = trial_data.L_Cx;
            L_CoP_ML = trial_data.L_Cy;

            % ---------------------------------------------------------
            % 1. DEFINIR VENTANA FIJA (Segundos 3 a 5)
            % ---------------------------------------------------------
            % Convertimos los segundos a índices de la matriz basándonos en 'fs'
            idx_start = round(t_inicio * fs) + 1;
            idx_end = round(t_fin * fs);
            
            % Control de seguridad: asegurar que la ventana no exceda la longitud del archivo
            if idx_end > length(R_Fz)
                idx_end = length(R_Fz);
                warning(['El ensayo ', nombre_ensayo, ' es más corto de 5 segundos. Ajustando al final disponible.']);
            end
            
            idx_sostenido = idx_start : idx_end;

            % ---------------------------------------------------------
            % 2. DISTRIBUCIÓN DE CARGA DURANTE LA VENTANA FIJA
            % ---------------------------------------------------------
            Fz_R_sust = R_Fz(idx_sostenido);
            Fz_L_sust = L_Fz(idx_sostenido);
            Fz_Total_sust = Fz_R_sust + Fz_L_sust;
            
            % Porcentaje promedio de peso cargado en cada pierna
            Carga_R_pct = mean((Fz_R_sust ./ Fz_Total_sust) * 100, 'omitnan');
            Carga_L_pct = mean((Fz_L_sust ./ Fz_Total_sust) * 100, 'omitnan');

            % ---------------------------------------------------------
            % 3. OSCILACIÓN DEL CENTRO DE PRESIÓN (CoP Sway) EN VENTANA FIJA
            % ---------------------------------------------------------
            % Pierna Derecha (R)
            R_CoP_AP_sust = R_CoP_AP(idx_sostenido);
            R_CoP_ML_sust = R_CoP_ML(idx_sostenido);
            
            R_Rango_AP = max(R_CoP_AP_sust) - min(R_CoP_AP_sust);
            R_Rango_ML = max(R_CoP_ML_sust) - min(R_CoP_ML_sust);
            R_RMS_AP   = rms(R_CoP_AP_sust - mean(R_CoP_AP_sust, 'omitnan'), 'omitnan');
            R_RMS_ML   = rms(R_CoP_ML_sust - mean(R_CoP_ML_sust, 'omitnan'), 'omitnan');
            
            % Pierna Izquierda (L)
            L_CoP_AP_sust = L_CoP_AP(idx_sostenido);
            L_CoP_ML_sust = L_CoP_ML(idx_sostenido);
            
            L_Rango_AP = max(L_CoP_AP_sust) - min(L_CoP_AP_sust);
            L_Rango_ML = max(L_CoP_ML_sust) - min(L_CoP_ML_sust);
            L_RMS_AP   = rms(L_CoP_AP_sust - mean(L_CoP_AP_sust, 'omitnan'), 'omitnan');
            L_RMS_ML   = rms(L_CoP_ML_sust - mean(L_CoP_ML_sust, 'omitnan'), 'omitnan');

            % ---------------------------------------------------------
            % 4. AGREGAR RESULTADOS A LA TABLA MAESTRA
            % ---------------------------------------------------------
            fila = table(string(nombre_ensayo), Carga_R_pct, Carga_L_pct, ...
                         R_Rango_AP, R_Rango_ML, R_RMS_AP, R_RMS_ML, ...
                         L_Rango_AP, L_Rango_ML, L_RMS_AP, L_RMS_ML, ...
                         'VariableNames', {'Ensayo', 'Carga_R_pct', 'Carga_L_pct', ...
                                           'R_Rango_AP', 'R_Rango_ML', 'R_RMS_AP', 'R_RMS_ML', ...
                                           'L_Rango_AP', 'L_Rango_ML', 'L_RMS_AP', 'L_RMS_ML'});
            
            resultados_EP = [resultados_EP; fila];
        end
    end
end
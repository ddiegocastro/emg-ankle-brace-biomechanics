function tabla_cci = GetSVCoContraction(emg_env_struct, fases_struct, fs)
% GetSVCoContraction Calcula el índice de co-contracción (CCI) entre el 
% Tibial Anterior y el Gastrocnemio durante los primeros 250 ms del aterrizaje.

    fields = fieldnames(fases_struct);
    num_ensayos = length(fields);
    
    Ensayo = strings(num_ensayos, 1);
    L_CCI_Landing = zeros(num_ensayos, 1);
    R_CCI_Landing = zeros(num_ensayos, 1);
    
    % Ventana de análisis: 250 ms expresada en muestras
    muestras_ventana = round(0.250 * fs); 
    
    for k = 1:num_ensayos
        ensayo = fields{k};
        Ensayo(k) = string(ensayo);
        
        ate = fases_struct.(ensayo).idx_aterrizaje;
        
        if ~isnan(ate)
            tabla_emg = emg_env_struct.(ensayo);
            n_muestras = height(tabla_emg);
            
            % --- AQUÍ ESTABA EL ERROR TIPOGRÁFICO CORREGIDO ---
            fin_ventana = min(ate + muestras_ventana, n_muestras);
            
            ta_L = tabla_emg.L_TA(ate:fin_ventana);
            gr_L = tabla_emg.L_GR(ate:fin_ventana);
            
            ta_R = tabla_emg.R_TA(ate:fin_ventana);
            gr_R = tabla_emg.R_GR(ate:fin_ventana);
            
            % Izquierdo
            menor_L = min([ta_L, gr_L], [], 2);
            mayor_L = max([ta_L, gr_L], [], 2);
            cci_vector_L = (menor_L ./ mayor_L) .* (ta_L + gr_L);
            L_CCI_Landing(k) = mean(cci_vector_L, 'omitnan');
            
            % Derecho
            menor_R = min([ta_R, gr_R], [], 2);
            mayor_R = max([ta_R, gr_R], [], 2);
            cci_vector_R = (menor_R ./ mayor_R) .* (ta_R + gr_R);
            R_CCI_Landing(k) = mean(cci_vector_R, 'omitnan');
        else
            L_CCI_Landing(k) = NaN;
            R_CCI_Landing(k) = NaN;
        end
    end
    
    tabla_cci = table(Ensayo, L_CCI_Landing, R_CCI_Landing);
end
function tabla_activacion = GetSVActivation(emg_norm_struct, fases_struct)
% GetSVActivation Calcula el PICO MÁXIMO de activación (% Máximo de EP) durante 
% la fase de propulsión del salto vertical para el Gastrocnemio y Tríceps Sural.

    fields = fieldnames(fases_struct);
    num_ensayos = length(fields);
    
    Ensayo = strings(num_ensayos, 1);
    L_Gastrocnemio = zeros(num_ensayos, 1);
    R_Gastrocnemio = zeros(num_ensayos, 1);
    L_TricepsSural = zeros(num_ensayos, 1);
    R_TricepsSural = zeros(num_ensayos, 1);
    
    for k = 1:num_ensayos
        ensayo = fields{k};
        Ensayo(k) = string(ensayo);
        
        ini = fases_struct.(ensayo).idx_inicio;
        des = fases_struct.(ensayo).idx_despegue;
        
        if ~isnan(ini) && ~isnan(des)
            tabla_emg = emg_norm_struct.(ensayo);
            
            % Usamos MAX en lugar de mean para capturar la contracción explosiva
            L_Gastrocnemio(k) = max(tabla_emg.L_GR(ini:des));
            R_Gastrocnemio(k) = max(tabla_emg.R_GR(ini:des));
            
            % Para el Tríceps Sural, sacamos el máximo de la señal promediada entre SL y GR
            L_TricepsSural(k) = max((tabla_emg.L_SL(ini:des) + tabla_emg.L_GR(ini:des)) / 2);
            R_TricepsSural(k) = max((tabla_emg.R_SL(ini:des) + tabla_emg.R_GR(ini:des)) / 2);
        else
            L_Gastrocnemio(k) = NaN;
            R_Gastrocnemio(k) = NaN;
            L_TricepsSural(k) = NaN;
            R_TricepsSural(k) = NaN;
        end
    end
    
    tabla_activacion = table(Ensayo, L_Gastrocnemio, R_Gastrocnemio, L_TricepsSural, R_TricepsSural);
end
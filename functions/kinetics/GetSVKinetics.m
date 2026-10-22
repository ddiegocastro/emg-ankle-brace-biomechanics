function resultados_SV = GetSVKinetics(cinetic_data)
    % Extraer los nombres de todos los campos (ensayos) del struct
    campos = fieldnames(cinetic_data);
    
    % Inicializar la tabla vacía donde se guardarán los resultados
    resultados_SV = table();
    
    for k = 1:length(campos)
        nombre_ensayo = campos{k};
        
        % Filtrar y procesar únicamente los ensayos de Salto Vertical (SV)
        if startsWith(nombre_ensayo, 'Sv', 'IgnoreCase', true) || startsWith(nombre_ensayo, 'SV')
            trial_data = cinetic_data.(nombre_ensayo);
            
            % 1. Extraer las Fuerzas Verticales (Fz) y convertir a VALOR ABSOLUTO
            % Esto corrige el problema de los vectores negativos del Vicon
            R_Fz = abs(trial_data.R_Fz);
            L_Fz = abs(trial_data.L_Fz);
            
            % Fuerza Total Combinada (ya usando los valores absolutos)
            Total_Fz = R_Fz + L_Fz;
            
            % 2. Encontrar las Fuerzas de Reacción Máximas (Picos de Fuerza de Impulso)
            R_Fz_max = max(R_Fz, [], 'omitnan');
            L_Fz_max = max(L_Fz, [], 'omitnan');
            Total_Fz_max = max(Total_Fz, [], 'omitnan');
            
            % 3. Calcular la Simetría de Fuerzas (LSI %)
            % LSI = (Derecha / Izquierda) * 100
            Simetria_LSI = (R_Fz_max / L_Fz_max) * 100;
            
            % 4. Agregar resultados a la tabla maestra de SV
            fila = table(string(nombre_ensayo), Total_Fz_max, R_Fz_max, L_Fz_max, Simetria_LSI, ...
                         'VariableNames', {'Ensayo', 'Fz_Max_Total_N', 'Fz_Max_Der_N', 'Fz_Max_Izq_N', 'Simetria_LSI_pct'});
            
            resultados_SV = [resultados_SV; fila];
        end
    end
end
function updated_angles_struct = appendInversionEversionAngle(vicon_corrected, vicon_angles)
% APPENDINVERSIONEVERSIONANGLE Calcula el ángulo absoluto de inclinación de la 
% pierna (correlacionado a Inv/Ev en cadena cerrada) usando los marcadores 
% RANK y RKNE respecto al vector vertical [0 0 1], incluyendo dirección (+/-) basada en el eje Y.

    % Copiamos la estructura original de ángulos para irle agregando la nueva columna
    updated_angles_struct = vicon_angles;
    campos = fieldnames(vicon_corrected);
    
    for i = 1:length(campos)
        t_name = campos{i};
        
        % Extraer la tabla de datos espaciales (X, Y, Z) de este ensayo
        tabla_spat = vicon_corrected.(t_name);
        
        % Extraer los vectores de posición 3D de los marcadores
        rank_pos = [tabla_spat.RANK_X, tabla_spat.RANK_Y, tabla_spat.RANK_Z];
        rkne_pos = [tabla_spat.RKNE_X, tabla_spat.RKNE_Y, tabla_spat.RKNE_Z];
        
        % 1. Definir el vector anatómico de la pierna (Origen en RANK, punta en RKNE)
        vector_pierna = rkne_pos - rank_pos;
        
        % 2. Calcular la magnitud de cada vector en cada cuadro (frame)
        magnitud_pierna = sqrt(sum(vector_pierna.^2, 2));
        
        % 3. Producto punto entre vector_pierna y [0, 0, 1] 
        % (Multiplicar por [0 0 1] simplemente aísla la componente Z)
        dot_product = vector_pierna(:, 3);
        
        % 4. Calcular el ángulo base en radianes y convertir a grados (Siempre es positivo)
        angulo_rad = acos(dot_product ./ magnitud_pierna);
        angulo_deg_absoluto = rad2deg(angulo_rad);
        
        % 5. Extraer la dirección del movimiento usando el Eje Y
        % vector_pierna(:, 2) corresponde a las coordenadas en Y
        signo_direccion = sign(vector_pierna(:, 2));
        
        % Prevención: Si por casualidad el vector es 100% vertical (Y = 0), evitamos que anule el ángulo
        signo_direccion(signo_direccion == 0) = 1; 
        
        % 6. Aplicar el signo al ángulo absoluto
        angulo_deg_con_signo = angulo_deg_absoluto .* signo_direccion;
        
        % 7. Agregar la nueva variable a la tabla de ángulos de este ensayo
        updated_angles_struct.(t_name).R_Inv_Ev_Angle = angulo_deg_con_signo;
    end
end
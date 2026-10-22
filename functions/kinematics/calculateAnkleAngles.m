function vicon_data_angles = calculateAnkleAngles(vicon_data, fs)
% CALCULATEANKLEANGLES Calcula el ángulo de flexión del tobillo en 3D
% (Dorsiflexión/Plantiflexión) y aplica un filtro Butterworth pasabajos.
%
% Inputs:
%   vicon_data - Struct con los datos cinemáticos imputados.
%   fs         - Frecuencia de muestreo en Hz.
%
% Output:
%   vicon_data_angles - Struct original con nuevas columnas añadidas 
%                       ('L_Ankle_Angle' y 'R_Ankle_Angle').

disp('================ CALCULANDO ÁNGULOS DE TOBILLO ================');

vicon_data_angles = vicon_data;
archivos = fieldnames(vicon_data);

% Diseño del Filtro Butterworth (4to orden, Bajo Paso a 6 Hz)
fc = 6; % Frecuencia de corte estándar para miembro inferior
[b, a] = butter(4, fc / (fs / 2), 'low');

for f = 1:length(archivos)
    file_name = archivos{f};
    data = vicon_data.(file_name);
    cols = data.Properties.VariableNames;

    % Función auxiliar interna para extraer coordenadas X, Y, Z
    extraer_xyz = @(marcador) ...
        table2array(data(:, { [marcador, (any(strcmp(cols, [marcador, '_X'])) * '_'), 'X'], ...
        [marcador, (any(strcmp(cols, [marcador, '_Y'])) * '_'), 'Y'], ...
        [marcador, (any(strcmp(cols, [marcador, '_Z'])) * '_'), 'Z'] } ));

    % --- TOBILLO IZQUIERDO (L) ---
    if any(contains(cols, 'LANK')) && any(contains(cols, 'LKNE')) && any(contains(cols, 'LTOE'))
        LANK = extraer_xyz('LANK');
        LKNE = extraer_xyz('LKNE');
        LTOE = extraer_xyz('LTOE');

        % Vectores direccionales
        v_tibia_L = LKNE - LANK;
        v_pie_L = LTOE - LANK;

        % Producto punto y magnitudes
        dot_L = sum(v_tibia_L .* v_pie_L, 2);
        mag_tibia_L = sqrt(sum(v_tibia_L.^2, 2));
        mag_pie_L = sqrt(sum(v_pie_L.^2, 2));

        % Ángulo crudo y ajuste biomecánico: 90 - theta = dorsiflexión(+), plantiflexión(-)
        angulo_L_crudo = 90 - rad2deg(acos(dot_L ./ (mag_tibia_L .* mag_pie_L)));

        % Filtrado de señal (filtfilt evita desfases temporales)
        angulo_L_filt = filtfilt(b, a, angulo_L_crudo);

        % Guardar como nueva columna en la tabla
        vicon_data_angles.(file_name).L_Ankle_Angle = angulo_L_filt;
    end

    % --- TOBILLO DERECHO (R) ---
    if any(contains(cols, 'RANK')) && any(contains(cols, 'RKNE')) && any(contains(cols, 'RTOE'))
        RANK = extraer_xyz('RANK');
        RKNE = extraer_xyz('RKNE');
        RTOE = extraer_xyz('RTOE');

        % Vectores direccionales
        v_tibia_R = RKNE - RANK;
        v_pie_R = RTOE - RANK;

        % Producto punto y magnitudes
        dot_R = sum(v_tibia_R .* v_pie_R, 2);
        mag_tibia_R = sqrt(sum(v_tibia_R.^2, 2));
        mag_pie_R = sqrt(sum(v_pie_R.^2, 2));

        % Ángulo crudo y ajuste biomecánico
        angulo_R_crudo = 90 - rad2deg(acos(dot_R ./ (mag_tibia_R .* mag_pie_R)));

        % Filtrado de señal
        angulo_R_filt = filtfilt(b, a, angulo_R_crudo);

        % Guardar como nueva columna en la tabla
        vicon_data_angles.(file_name).R_Ankle_Angle = angulo_R_filt;
    end
end
disp('-> Ángulos filtrados y agregados exitosamente.');
end
% =========================================================================
% SCRIPT DE DIAGNÓSTICO: VALIDACIÓN DE DURACIÓN DE GRABACIONES VICON
% =========================================================================

% 1. Definir la frecuencia de muestreo (revisa si usas 100 Hz en tu script)
fs_diagnostico = 100; 

% 2. Obtener los nombres de los ensayos del sujeto Control (CTRL)
ensayos_CTRL = fieldnames(vicon_data_corrected_CTRL);

fprintf('\n=====================================================================');
fprintf('\n         REPORTE DE DIAGNÓSTICO: DURACIÓN REAL DE ENSAYOS (CTRL)');
fprintf('\n=====================================================================\n');
fprintf('%-15s | %-12s | %-18s | %-10s\n', 'Ensayo', 'Total Frames', 'Duración Total (s)', 'Estatus');
fprintf('---------------------------------------------------------------------\n');

for i = 1:length(ensayos_CTRL)
    nombre_t = ensayos_CTRL{i};
    tabla_cruda = vicon_data_corrected_CTRL.(nombre_t);

    % Calcular cantidad de cuadros y tiempo total grabado
    num_frames = height(tabla_cruda);
    tiempo_total_seg = num_frames / fs_diagnostico;

    % Diagnóstico clínico del margen de tiempo
    if tiempo_total_seg < 4.0
        estatus = '⚠️ Muy Corto';
    elseif tiempo_total_seg >= 4.0 && tiempo_total_seg < 6.0
        estatus = '👍 Ajustado';
    else
        estatus = '😎 Seguro';
    end

    fprintf('%-15s | %-12d | %-16.2f s | %-10s\n', ...
        nombre_t, num_frames, tiempo_total_seg, estatus);
end
fprintf('=====================================================================\n\n');

%% --- DIAGNÓSTICO ESPECÍFICO DEL INTENTO CRÍTICO ---
if ismember('Sv_ct_03_CTRL', ensayos_CTRL)
    frames_critico = height(vicon_data_corrected_CTRL.Sv_ct_03_CTRL);
    tiempo_critico = frames_critico / fs_diagnostico;

    fprintf('Análisis del caso "Sv_ct_03_CTRL" (Tiempo Estabilización calculado = 3.54s):\n');
    fprintf(' -> El archivo dura exactamente: %.2f segundos.\n', tiempo_critico);

    margen_disponible = tiempo_critico - 3.54;
    if margen_disponible < 0.2
        fprintf(' -> 🚨 ALERTA: El sujeto tardó 3.54s en estabilizarse, pero el video dura %.2f s.\n', tiempo_critico);
        fprintf('    El algoritmo se detuvo porque se acabaron los datos, no porque el sujeto se haya aquietado.\n');
    else
        fprintf(' -> ✅ VALIDADO: Hay un margen de %.2f s al final del video. El dato de 3.54s es real.\n', margen_disponible);
    end
else
    disp('Nota: No se encontró el ensayo Sv_ct_03_CTRL en la estructura actual.');
end
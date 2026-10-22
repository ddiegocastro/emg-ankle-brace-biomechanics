function fs_final = getFs(varargin)
% GETFS Calcula la frecuencia de muestreo (Fs) estandarizada promediando 
% los fotogramas de las pruebas de Elevación de Puntillas (EP).
%
% Inputs:
%   varargin - Uno o múltiples structs con los datos de Vicon 
%              (ej. vicon_data_corrected_INJ, vicon_data_corrected_CTRL).
%
% Output:
%   fs_final - Frecuencia de muestreo estandarizada redondeada (Hz).

disp('================ CÁLCULO DE FRECUENCIA DE MUESTREO (Fs) ================');

% Tiempo que sabemos que dura cada prueba de Elevación de Puntillas (EP)
tiempo_estimado_seg = 10; 
todas_las_fs = []; % Vector para almacenar las estimaciones de todos los archivos

% Recorrer todos los sujetos (structs) ingresados a la función
for subj_idx = 1:length(varargin)
    current_data = varargin{subj_idx};
    archivos = fieldnames(current_data);

    % Buscar archivos que contengan "EP"
    idx_EP = find(contains(archivos, 'EP', 'IgnoreCase', true)); 

    if ~isempty(idx_EP)
        for i = 1:length(idx_EP)
            archivo_actual = archivos{idx_EP(i)};
            frames = height(current_data.(archivo_actual));
            fs_estimada = frames / tiempo_estimado_seg;
            todas_las_fs(end+1) = fs_estimada;

            fprintf('Struct Input %d - Archivo: %s | Frames: %d | Fs estimada: %.2f Hz\n', ...
                subj_idx, archivo_actual, frames, fs_estimada);
        end
    else
        fprintf('No se encontraron archivos EP en el Struct Input %d.\n', subj_idx);
    end
end

% Determinar la Frecuencia Final Promediada
if ~isempty(todas_las_fs)
    fs_promedio = mean(todas_las_fs);

    % Redondeamos a la decena más cercana (estándar de hardware Vicon: 100, 120, 200...)
    fs_final = round(fs_promedio / 10) * 10;

    fprintf('\n----------------------------------------------------------\n');
    fprintf('Promedio crudo calculado: %.2f Hz\n', fs_promedio);
    fprintf('-> Frecuencia de muestreo (Fs) estandarizada: %d Hz\n', fs_final);
    fprintf('----------------------------------------------------------\n');
else
    disp('Error: No se pudo calcular la frecuencia porque no hay datos válidos.');
    fs_final = NaN;
end
end
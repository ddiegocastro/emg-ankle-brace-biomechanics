function results_table = GetCoContractionEP(emg_data_norm, fs)
% GetCoContractionEP Calcula el Índice de Co-contracción (CCI) de Falconer y Winter
% entre el Tibial Anterior y el Tríceps Sural durante la fase isométrica (3-5s).
%
% INPUT:
%   emg_data_norm - (Struct) Datos normalizados (% Máximo).
%   fs            - (Double) Frecuencia de muestreo (ej. 2000).
%
% OUTPUT:
%   results_table - (Table) Tabla resumen con el CCI para pierna izquierda y derecha.

field = fieldnames(emg_data_norm);

% Inicializamos variables
Ensayo = {};
L_CCI = []; 
R_CCI = [];

% Definir la ventana de tiempo (Fase: Mantener)
inicio_idx = round(3.0 * fs) + 1;
fin_idx    = round(5.0 * fs);

for k = 1:length(field)
    nombre_ensayo = field{k};

    if contains(nombre_ensayo, 'EP', 'IgnoreCase', true)

        tabla_actual = emg_data_norm.(nombre_ensayo);
        data_array = table2array(tabla_actual);

        if size(data_array, 1) < fin_idx
            continue; % Saltamos si el archivo está cortado
        end

        % Extraer la ventana de interés (3 a 5 segundos)
        data_window = data_array(inicio_idx:fin_idx, :);

        % --- PIERNA IZQUIERDA (L) ---
        L_TA = data_window(:, 1);
        L_SL = data_window(:, 2);
        L_GR = data_window(:, 3);

        % Crear señal del Tríceps Sural promediando SL y GR
        L_TS = (L_SL + L_GR) / 2;

        % Calcular la integral (Área bajo la curva) usando trapz
        I_L_TA = trapz(L_TA);
        I_L_TS = trapz(L_TS);

        % Fórmula de Falconer y Winter
        cci_izq = (2 * I_L_TA) / (I_L_TS + I_L_TA) * 100;

        % --- PIERNA DERECHA (R) ---
        R_TA = data_window(:, 4);
        R_SL = data_window(:, 5);
        R_GR = data_window(:, 6);

        R_TS = (R_SL + R_GR) / 2;

        I_R_TA = trapz(R_TA);
        I_R_TS = trapz(R_TS);

        cci_der = (2 * I_R_TA) / (I_R_TS + I_R_TA) * 100;

        % --- GUARDAR RESULTADOS ---
        Ensayo{end+1, 1} = nombre_ensayo;
        L_CCI(end+1, 1)  = cci_izq;
        R_CCI(end+1, 1)  = cci_der;
    end
end

% Construir la tabla
results_table = table(Ensayo, L_CCI, R_CCI);
end
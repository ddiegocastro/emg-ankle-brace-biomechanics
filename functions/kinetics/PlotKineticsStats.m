function PlotKineticsStats(tabla_SV_CTRL, tabla_SV_INJ, tabla_EP_CTRL, tabla_EP_INJ)
% PlotKineticsStats Genera las figuras estadísticas comparando al sujeto
% Control (CTRL) vs el Lesionado (INJ).

% =====================================================================
% FIGURA 1: BOXPLOT DE SIMETRÍA LSI EN SALTO VERTICAL
% =====================================================================
lsi_CTRL = tabla_SV_CTRL.Simetria_LSI_pct;
lsi_INJ = tabla_SV_INJ.Simetria_LSI_pct;

datos_lsi = [lsi_CTRL; lsi_INJ];
grupo_lsi = [repmat({'1. Control (CTRL)'}, length(lsi_CTRL), 1); ...
    repmat({'2. Lesionado (INJ)'}, length(lsi_INJ), 1)];

figure('Units', 'normalized', 'Position', [0.1 0.1 0.4 0.6]);
boxplot(datos_lsi, grupo_lsi, 'Colors', 'k', 'Symbol', 'ro');
hold on;

yline(100, '--r', 'Simetría Perfecta (100%)', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'center');

ylabel('Índice de Simetría LSI (%)', 'FontWeight', 'bold');
title({'Comportamiento General en Salto Vertical', 'Dispersión y Mediana del LSI'}, 'FontSize', 12);
grid on; set(gca, 'FontSize', 11);

% =====================================================================
% FIGURA 2: BARRAS DE MEDIANAS PARA SWAY MEDIOLATERAL (EP)
% =====================================================================
mediana_R_CTRL = median(tabla_EP_CTRL.R_Sway_ML_RMS, 'omitnan');
mediana_L_CTRL = median(tabla_EP_CTRL.L_Sway_ML_RMS, 'omitnan');
mediana_R_INJ = median(tabla_EP_INJ.R_Sway_ML_RMS, 'omitnan');
mediana_L_INJ = median(tabla_EP_INJ.L_Sway_ML_RMS, 'omitnan');

datos_barras = [mediana_R_CTRL, mediana_L_CTRL; 
    mediana_R_INJ, mediana_L_INJ];

figure('Units', 'normalized', 'Position', [0.55 0.1 0.4 0.6]);
b = bar(datos_barras, 'grouped', 'EdgeColor', 'k', 'LineWidth', 1);

b(1).FaceColor = [0.8500 0.3250 0.0980]; % Derecha
b(2).FaceColor = [0 0.4470 0.7410];      % Izquierda

set(gca, 'XTickLabel', {'Control (CTRL)', 'Lesionado (INJ)'});
ylabel('Mediana del RMS Mediolateral', 'FontWeight', 'bold');
title({'Estrategia de Estabilización en EP', 'RMS Mediolateral (Medianas)'}, 'FontSize', 12);
legend('Pierna Derecha', 'Pierna Izquierda', 'Location', 'northeast');
grid on; set(gca, 'FontSize', 11);
end
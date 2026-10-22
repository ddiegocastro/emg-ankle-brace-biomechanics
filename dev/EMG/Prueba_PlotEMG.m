% Auto-exported from EMG/Prueba_PlotEMG.mlx (code cells only).

clear; close all; clc; 

ruta_datos = '<project_root>\ProyectoFinal\InputData\Injured\EMG y Cinetica'; 
ruta_funciones = '<project_root>\ProyectoFinal\Functions\EMG';
addpath(ruta_funciones);

emg_data = loadEMG(ruta_datos);
emg_data_filter = filterEMG_BP(emg_data);

colnames = {'L_TA', 'L_SL', 'L_GR', 'R_TA', 'R_SL', 'R_GR'}; 
emg_data_filter = DeclareEMGSensors(emg_data_filter, colnames)

fs = 2000; 
field = fieldnames(emg_data_filter); 

for k = 1:length(field)
    tabla_actual = emg_data_filter.(field{k});
    data_array = table2array(tabla_actual); 
    
    % Vector de tiempo en segundos
    t = (0:size(tabla_actual,1)-1) / fs;

    % Figura con fondo blanco ('Color', 'w') y un poco más ancha
    figure('Name', field{k}, 'Position', [100, 100, 1200, 800], 'Color', 'w'); 
    
    % Título principal con fuente más grande
    sgtitle(['Activación Muscular - Ensayo: ', strrep(field{k}, '_', ' ')], ...
            'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.15 0.15 0.15]);

    % Ciclo para graficar cada músculo
    for j = 1:size(tabla_actual, 2)
        
        subplot(3, 2, j); 
        
        % Señal con nuevo color (Naranja cálido de MATLAB, excelente visibilidad)
        plot(t, data_array(:,j), 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 1.2); 
        
        % Ajustar los límites del eje X para eliminar el hueco a la derecha
        xlim([0, t(end)]);
        
        % Título con 'Interpreter', 'none'
        title(colnames{j}, 'Interpreter', 'none', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]); 
        
        % Etiquetas de los ejes
        xlabel('Tiempo [s]', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]); 
        ylabel('Amplitud [V]', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]);
        
        % --- DISEÑO DEL EJE ---
        ax = gca;
        ax.FontSize = 10;           
        ax.LineWidth = 1.2;         
        ax.XColor = [0.3 0.3 0.3];  
        ax.YColor = [0.3 0.3 0.3];  
        box off;                    
        
        % Cuadrícula sutil
        grid on; 
        ax.GridLineStyle = '--';    
        ax.GridAlpha = 0.3;         
        
    end
end

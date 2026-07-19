current_dir = pwd;
model_folder = fullfile(current_dir, '..', 'Models');
addpath(model_folder);

osr_list = [64, 96, 128, 192, 256];

measured_snr = zeros(1, length(osr_list));
enob_calc = zeros(1, length(osr_list));

f_in = 128000; 
for i = 1:length(osr_list)
    
    assignin('base', 'CURRENT_OSR', osr_list(i));
    
    sim_data = sim('Delta_Sigma_ADC_Deg3'); 
    
    output_signal = sim_data.adc_out;
    
    if length(output_signal) > 100
        output_signal = output_signal(100:end); 
    end
    
    f_out = f_in / osr_list(i);
    
    measured_snr(i) = snr(output_signal, f_out);
    
    enob_calc(i) = (measured_snr(i) - 1.76) / 6.02;
end

disp('===========================================================');
disp('   OSR      f_out (SPS)    Measured SNR (dB)    ENOB (bits)');
disp('===========================================================');
for i = 1:length(osr_list)
    fprintf('   %-8d %-14d %-20.2f %-10.2f\n', ...
        osr_list(i), (f_in/osr_list(i)), measured_snr(i), enob_calc(i));
end
disp('===========================================================');
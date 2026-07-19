
clear; clc; close all;
current_dir = pwd;
model_folder = fullfile(current_dir, '..', 'Models');
addpath(model_folder);

CURRENT_OSR = 128; 
degrees = [1, 2, 3]; 

model_names = {
    'Delta_Sigma_ADC_Deg1', ... 
    'Delta_Sigma_ADC_Deg2', ... 
    'Delta_Sigma_ADC_Deg3'    
};

snr_results = zeros(1, length(degrees));
enob_results = zeros(1, length(degrees));

warning('off', 'all');

disp('Running simulations. Please wait...');

for i = 1:length(degrees)
    current_model = model_names{i};
    current_deg = degrees(i);
    
    load_system(current_model);
    
    out = sim(current_model);
    
    if isprop(out, 'adc_out') || isfield(out, 'adc_out')
        sim_var = out.adc_out;
    elseif isprop(out, 'simout') || isfield(out, 'simout') 
        sim_var = out.simout;
    else
        sim_var = out.get('adc_out'); 
    end
    
    if isnumeric(sim_var)
        raw_adc_out = sim_var; 
    elseif isstruct(sim_var) && isfield(sim_var, 'signals')
        raw_adc_out = sim_var.signals.values;
    else
        raw_adc_out = sim_var.Data; 
    end
    
    cic_gain = CURRENT_OSR ^ current_deg;
    
    normalized_output = double(raw_adc_out) / cic_gain;
    
    trim_index = round(length(normalized_output) * 0.1);
    steady_state_signal = normalized_output(trim_index:end);
    
    measured_snr = snr(steady_state_signal);
    
    measured_enob = (measured_snr - 1.76) / 6.02;
    
    snr_results(i) = measured_snr;
    enob_results(i) = measured_enob;
    
    close_system(current_model, 0);
end

warning('on', 'all');

fprintf('\n===========================================================\n');
fprintf('   CIC Degree    Constant OSR    Measured SNR (dB)    ENOB (bits)\n');
fprintf('===========================================================\n');

for i = 1:length(degrees)
    fprintf('   %-13d %-15d %-20.2f %-10.2f\n', ...
        degrees(i), CURRENT_OSR, snr_results(i), enob_results(i));
end
fprintf('===========================================================\n');
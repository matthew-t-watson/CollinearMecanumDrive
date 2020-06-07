
close all;

data = import_data('data_030518_1253 phi step responses.csv');
data = trim_data(data, 54, 57);




plot_phi_readout(data, constraints, true, 'D:\Google_Drive\Matlab\Matt_MPC\Figures\experimental_phi_step.tex');


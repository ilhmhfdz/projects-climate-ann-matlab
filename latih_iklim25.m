clc; clear; close all; warning off all;
% === MEMBACA DATA DARI EXCEL ===
data = xlsread('Book7.xlsx', 1, 'B2:AK12');  % 11 tahun × 36 kolom
data_tahunan = data(1:10, :);  % Ambil data 2014–2023 (10 tahun)

% === NORMALISASI ===
min_data = min(data_tahunan);
max_data = max(data_tahunan);
data_norm = (data_tahunan - min_data) ./ (max_data - min_data);

% === SUSUN DATA LATIH & TARGET ===
input_latih = data_norm(1:end-1, :)';    % 36 x 9
target_latih = data_norm(2:end, :)';     % 36 x 9

% === MEMBANGUN & MELATIH ANN ===
jumlah_neuron1 = 8;
jumlah_neuron2 = 4;
fungsi_aktifasi1 = 'tansig';
fungsi_aktifasi2 = 'logsig';
fungsi_pelatihan = 'trainlm';

rng('default')
jaringan = newff(minmax(input_latih), ...
                 [jumlah_neuron1 jumlah_neuron2 36], ...
                 {fungsi_aktifasi1, fungsi_aktifasi2, 'purelin'}, ...
                 fungsi_pelatihan);

% Latih jaringan
jaringan = train(jaringan, input_latih, target_latih);

% Simulasi hasil pelatihan
hasil_latih_norm = sim(jaringan, input_latih);
hasil_latih_asli = hasil_latih_norm' .* (max_data - min_data) + min_data;
target_latih_asli = target_latih' .* (max_data - min_data) + min_data;

% === MSE TRAINING ===
error_MSE = mean((hasil_latih_norm - target_latih).^2, 'all');
disp(['MSE Latih: ', num2str(error_MSE)])

% === GRAFIK SALAH SATU VARIABEL (Contoh: CH bulan ke-1) ===
% === GRAFIK CH BULAN JAN–DES DALAM SUBPLOT ===
figure('Name', 'Prediksi vs Target CH Tahun 2014–2023 (12 Bulan)', 'NumberTitle', 'off')
for i = 1:12
    subplot(3,4,i)
    plot(hasil_latih_asli(:,i), 'b-o', 'LineWidth', 1.5)
    hold on
    plot(target_latih_asli(:,i), 'r-*', 'LineWidth', 1.5)
    title(['CH Bulan ', num2str(i)])
    xlabel('Tahun ke-1 s.d. ke-9')
    ylabel('CH (mm)')
    grid on
    if i == 1
        legend('Prediksi', 'Target')
    end
end
sgtitle('Prediksi vs Target CH Bulan Januari–Desember (2014–2023)')


% === SIMPAN JARINGAN ===
save jaringan_iklim jaringan min_data max_data

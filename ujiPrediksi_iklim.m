clc; clear; close all; warning off all;

% === MEMBACA DATA DARI EXCEL ===
data = xlsread('Book7.xlsx', 1, 'B2:AK12');  % Data iklim 2014–2024 (11 tahun)
data_latih = data(1:10, :);     % 2014–2023
input_prediksi = data(11, :)';  % 2024

% === NORMALISASI ===
min_data = min(data_latih);
max_data = max(data_latih);
data_norm = (data_latih - min_data) ./ (max_data - min_data);
input_prediksi_norm = (input_prediksi - min_data') ./ (max_data' - min_data');

% === DATA LATIH ===
input_latih = data_norm(1:end-1, :)';    % Tahun 2014–2022 (input)
target_latih = data_norm(2:end, :)';     % Tahun 2015–2023 (target)

% === MEMUAT JARINGAN ===
load jaringan_iklim jaringan min_data max_data

% === PENGUJIAN (2023 sebagai target) ===
hasil_uji_norm = sim(jaringan, input_latih);
hasil_uji_asli = hasil_uji_norm' .* (max_data - min_data) + min_data;
target_uji_asli = target_latih' .* (max_data - min_data) + min_data;

% === ERROR METRIK ===
error_MSE = mean((hasil_uji_norm - target_latih).^2, 'all');
error_RMSE = sqrt(error_MSE);
error_MAE = mean(abs(hasil_uji_norm - target_latih), 'all');

fprintf('MSE  : %.4f\n', error_MSE);
fprintf('RMSE : %.4f\n', error_RMSE);
fprintf('MAE  : %.4f\n', error_MAE);

% === GRAFIK VALIDASI (Contoh: CH bulan ke-1) ===
figure
plot(hasil_uji_asli(:,1), 'bo-', 'LineWidth', 2)
hold on
plot(target_uji_asli(:,1), 'r*-', 'LineWidth', 2)
grid on
title(['Validasi Prediksi CH Bulan Januari | MSE = ', num2str(error_MSE)])
xlabel('Tahun ke-1 sampai ke-9 (2015–2023)')
ylabel('CH (Curah Hujan)')
legend('Prediksi', 'Target')
hold off

% === PREDIKSI 2025 ===
data_prediksi_norm = input_prediksi_norm;
hasil_prediksi_norm = sim(jaringan, data_prediksi_norm);
hasil_prediksi_asli = hasil_prediksi_norm' .* (max_data - min_data) + min_data;

% === VISUALISASI PREDIKSI 2025 ===
figure
plot(hasil_prediksi_asli(1:12), 'm-o', 'LineWidth', 2)        % CH bulan Jan–Des
hold on
plot(hasil_prediksi_asli(13:24), 'b--*', 'LineWidth', 2)      % Tavg bulan Jan–Des
plot(hasil_prediksi_asli(25:36), 'g--s', 'LineWidth', 2)      % RH bulan Jan–Des
grid on
title('Prediksi Faktor Iklim Tahun 2025')
xlabel('Bulan')
ylabel('Nilai')
legend('CH (mm)', 'Tavg (°C)', 'RH (%)')
xlim([1 12])
hold off

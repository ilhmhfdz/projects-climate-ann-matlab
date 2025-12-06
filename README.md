

````markdown
# 🌦️ Prediksi Iklim Bulanan 2025 Menggunakan ANN (MATLAB)

Repositori ini berisi implementasi **Artificial Neural Network (ANN)** untuk memprediksi
**tiga variabel iklim bulanan**:

- Curah Hujan (CH, mm)
- Suhu Rata-rata (Tavg, °C)
- Kelembapan Relatif (RH, %)

Prediksi dilakukan untuk **tahun 2025** berdasarkan pola iklim tahun-tahun sebelumnya.

---

## 📂 Struktur Proyek

```text
.
├── latih_iklim25.m          % Script pelatihan ANN (2014–2023)
├── ujiPrediksi_iklim.m      % Script validasi (2015–2023) & prediksi iklim 2025
├── Book7.xlsx               % Dataset iklim bulanan BMKG (2014–2024)
└── README.md
````

---

## 📊 Dataset

File: `Book7.xlsx`
Sheet: 1
Range yang digunakan: `B2:AK12`

* Setiap baris mewakili **1 tahun**.
* Setiap kolom adalah fitur iklim bulanan (total 36 kolom = 12 bulan × 3 variabel):

  * CH Jan–Des (12 kolom)
  * Tavg Jan–Des (12 kolom)
  * RH Jan–Des (12 kolom)
* Data yang digunakan:

  * **2014–2023** → data latih (10 tahun)
  * **2024**       → input untuk prediksi 2025

---

## 🧠 Arsitektur Model

Model dibangun sebagai **multi-output ANN** untuk time series yearly-to-year:

* Input  : vektor 36 dimensi (CH, Tavg, RH untuk 12 bulan pada satu tahun)
* Target : vektor 36 dimensi (CH, Tavg, RH 12 bulan tahun berikutnya)
* Arsitektur ANN:

```matlab
jumlah_neuron1  = 8;
jumlah_neuron2  = 4;
fungsi_aktifasi1 = 'tansig';
fungsi_aktifasi2 = 'logsig';
fungsi_pelatihan = 'trainlm';

jaringan = newff(minmax(input_latih), ...
                 [jumlah_neuron1 jumlah_neuron2 36], ...
                 {fungsi_aktifasi1, fungsi_aktifasi2, 'purelin'}, ...
                 fungsi_pelatihan);
```

* Hidden layer 1 : 8 neuron (`tansig`)
* Hidden layer 2 : 4 neuron (`logsig`)
* Output layer   : 36 neuron (`purelin`)
* Fungsi training: `trainlm` (Levenberg–Marquardt)

---

## 🔁 Alur Pelatihan (`latih_iklim25.m`)

1. **Load data**:

   ```matlab
   data = xlsread('Book7.xlsx', 1, 'B2:AK12');  % 11 tahun × 36 kolom
   data_tahunan = data(1:10, :);               % 2014–2023
   ```

2. **Normalisasi Min–Max** per kolom:

   ```matlab
   min_data = min(data_tahunan);
   max_data = max(data_tahunan);
   data_norm = (data_tahunan - min_data) ./ (max_data - min_data);
   ```

3. **Menyusun pasangan input–target**:

   * Input  : tahun ke-1 s.d. ke-9 (2014–2022)
   * Target : tahun ke-2 s.d. ke-10 (2015–2023)

   ```matlab
   input_latih  = data_norm(1:end-1, :)';   % 36 × 9
   target_latih = data_norm(2:end, :)';     % 36 × 9
   ```

4. **Melatih jaringan**:

   ```matlab
   jaringan = train(jaringan, input_latih, target_latih);
   ```

5. **Denormalisasi & evaluasi error**:

   ```matlab
   hasil_latih_norm  = sim(jaringan, input_latih);
   hasil_latih_asli  = hasil_latih_norm' .* (max_data - min_data) + min_data;
   target_latih_asli = target_latih'    .* (max_data - min_data) + min_data;

   error_MSE = mean((hasil_latih_norm - target_latih).^2, 'all');
   ```

6. **Visualisasi**:

   * Subplot 12 grafik: perbandingan **CH bulan Jan–Des** (prediksi vs target) untuk tahun 2014–2023.

7. **Menyimpan model & parameter normalisasi**:

   ```matlab
   save jaringan_iklim jaringan min_data max_data
   ```

---

## 🧪 Validasi & Prediksi (`ujiPrediksi_iklim.m`)

1. **Load data & model**:

   ```matlab
   data = xlsread('Book7.xlsx', 1, 'B2:AK12');   % 2014–2024
   data_latih        = data(1:10, :);           % 2014–2023
   input_prediksi    = data(11, :)';            % 2024
   load jaringan_iklim jaringan min_data max_data
   ```

2. **Normalisasi ulang menggunakan min/max data latih**:

   ```matlab
   min_data = min(data_latih);
   max_data = max(data_latih);
   data_norm           = (data_latih - min_data) ./ (max_data - min_data);
   input_prediksi_norm = (input_prediksi - min_data') ./ (max_data' - min_data');
   ```

3. **Validasi (2015–2023)**

   * Input latih: tahun 2014–2022
   * Target     : tahun 2015–2023

   ```matlab
   input_latih  = data_norm(1:end-1, :)';
   target_latih = data_norm(2:end, :)';

   hasil_uji_norm = sim(jaringan, input_latih);
   hasil_uji_asli = hasil_uji_norm' .* (max_data - min_data) + min_data;
   target_uji_asli = target_latih' .* (max_data - min_data) + min_data;
   ```

4. **Metrik error**:

   ```matlab
   error_MSE  = mean((hasil_uji_norm - target_latih).^2, 'all');
   error_RMSE = sqrt(error_MSE);
   error_MAE  = mean(abs(hasil_uji_norm - target_latih), 'all');
   ```

5. **Visualisasi validasi**:

   * Grafik **CH bulan Januari** (prediksi vs target) untuk tahun 2015–2023.

6. **Prediksi iklim tahun 2025**:

   Menggunakan vektor 36 dimensi tahun 2024 sebagai input:

   ```matlab
   data_prediksi_norm   = input_prediksi_norm;
   hasil_prediksi_norm  = sim(jaringan, data_prediksi_norm);
   hasil_prediksi_asli  = hasil_prediksi_norm' .* (max_data - min_data) + min_data;
   ```

7. **Visualisasi 3 variabel (tahun 2025)**:

   * CH (bulan Jan–Des)   → indeks 1–12
   * Tavg (bulan Jan–Des) → indeks 13–24
   * RH (bulan Jan–Des)   → indeks 25–36

   ```matlab
   plot(hasil_prediksi_asli(1:12),  'm-o',  'LineWidth', 2);   % CH
   hold on
   plot(hasil_prediksi_asli(13:24),'b--*', 'LineWidth', 2);   % Tavg
   plot(hasil_prediksi_asli(25:36),'g--s', 'LineWidth', 2);   % RH
   ```

---

## 🚀 Cara Menjalankan

1. Buka folder proyek ini sebagai *Current Folder* di MATLAB.

2. Pastikan file berikut berada di direktori yang sama:

   * `latih_iklim25.m`
   * `ujiPrediksi_iklim.m`
   * `Book7.xlsx`

3. Jalankan pelatihan model:

   ```matlab
   latih_iklim25
   ```

4. Setelah proses training dan penyimpanan `jaringan_iklim.mat` selesai, jalankan:

   ```matlab
   ujiPrediksi_iklim
   ```

5. Script kedua akan:

   * Menampilkan metrik error (MSE, RMSE, MAE) pada data validasi.
   * Menampilkan grafik validasi CH (2015–2023).
   * Menghasilkan grafik prediksi CH, Tavg, RH untuk tahun **2025**.

---

## 🔧 Kebutuhan

* MATLAB (dengan **Neural Network Toolbox** / Deep Learning Toolbox)
* Dukungan fungsi:

  * `newff`, `train`, `sim`
  * `xlsread` (atau `readmatrix` pada versi lebih baru)

---

## 👨‍💻 Pengembang

**Ilham Hafidz**
AI Engineer & Data Enthusiast
Email: `ilhamhafidz666@gmail.com`

```

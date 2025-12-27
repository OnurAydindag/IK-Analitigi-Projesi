-- ======================================
-- IK ANALİTİĞİ PROJE - SQL SCRIPTLERI
-- ======================================

-- ====== BÖLÜM 1: TABLO OLUŞTURMA ======

-- Departmanlar tablosu
CREATE TABLE IF NOT EXISTS Departmanlar (
    departman_id INT PRIMARY KEY,
    departman_adi VARCHAR(100),
    yonetici_id INT,
    lokasyon VARCHAR(100),
    butce INT
);

-- Calisanlar tablosu
CREATE TABLE IF NOT EXISTS Calisanlar (
    calisan_id INT PRIMARY KEY,
    ad VARCHAR(100),
    soyad VARCHAR(100),
    departman_id INT,
    pozisyon VARCHAR(100),
    ise_giris_tarihi DATE,
    maas INT,
    FOREIGN KEY (departman_id) REFERENCES Departmanlar(departman_id)
);

-- Bordro tablosu
CREATE TABLE IF NOT EXISTS Bordro (
    bordro_id INT PRIMARY KEY,
    calisan_id INT,
    ay INT,
    yil INT,
    net_maas INT,
    prim INT,
    kesinti INT,
    FOREIGN KEY (calisan_id) REFERENCES Calisanlar(calisan_id)
);

-- Izinler tablosu
CREATE TABLE IF NOT EXISTS Izinler (
    izin_id INT PRIMARY KEY,
    calisan_id INT,
    izin_turu VARCHAR(50),
    baslangic DATE,
    bitis DATE,
    onay_durumu VARCHAR(50),
    FOREIGN KEY (calisan_id) REFERENCES Calisanlar(calisan_id)
);


-- ====== BÖLÜM 2: VERİ ANALİZ SORGULARI ======

-- 1. DEPARTMAN BAZINDA ÇALIŞAN SAYISI (HEADCOUNT)
SELECT 
    d.departman_adi,
    COUNT(c.calisan_id) AS calisan_sayisi,
    ROUND(COUNT(c.calisan_id) * 100.0 / (SELECT COUNT(*) FROM Calisanlar), 2) AS yuzde
FROM Departmanlar d
LEFT JOIN Calisanlar c ON d.departman_id = c.departman_id
GROUP BY d.departman_adi
ORDER BY calisan_sayisi DESC;


-- 2. POZİSYON BAZINDA ORTALAMA MAAŞ
SELECT 
    pozisyon,
    COUNT(*) AS calisan_sayisi,
    AVG(maas) AS ortalama_maas,
    MIN(maas) AS min_maas,
    MAX(maas) AS max_maas
FROM Calisanlar
GROUP BY pozisyon
ORDER BY ortalama_maas DESC;


-- 3. DEPARTMAN BAZINDA TOPLAM MAAŞ MALİYETİ
SELECT 
    d.departman_adi,
    COUNT(c.calisan_id) AS calisan_sayisi,
    SUM(c.maas) AS toplam_maas,
    ROUND(AVG(c.maas), 2) AS ortalama_maas
FROM Departmanlar d
LEFT JOIN Calisanlar c ON d.departman_id = c.departman_id
GROUP BY d.departman_adi
ORDER BY toplam_maas DESC;


-- 4. KIDEM ANALİZİ (Çalışanların işte kaç yıldır olduğu)
SELECT 
    ad,
    soyad,
    pozisyon,
    ise_giris_tarihi,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, ise_giris_tarihi)) AS kidem_yil
FROM Calisanlar
ORDER BY kidem_yil DESC
LIMIT 10;


-- 5. AYLIK BORDRO TOPLAMI (Tüm aylar için)
SELECT 
    yil,
    ay,
    SUM(net_maas) AS toplam_net_maas,
    SUM(prim) AS toplam_prim,
    SUM(kesinti) AS toplam_kesinti
FROM Bordro
GROUP BY yil, ay
ORDER BY yil, ay;


-- 6. İZİN KULLANIM ANALİZİ
SELECT 
    izin_turu,
    COUNT(*) AS izin_sayisi,
    onay_durumu,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Izinler), 2) AS yuzde
FROM Izinler
GROUP BY izin_turu, onay_durumu
ORDER BY izin_turu, izin_sayisi DESC;


-- 7. EN YÜKSEK MAAŞLI 10 ÇALIŞAN
SELECT 
    c.ad,
    c.soyad,
    c.pozisyon,
    d.departman_adi,
    c.maas
FROM Calisanlar c
JOIN Departmanlar d ON c.departman_id = d.departman_id
ORDER BY c.maas DESC
LIMIT 10;


-- 8. DEPARTMAN BAZINDA İZİN KULLANIMI
SELECT 
    d.departman_adi,
    COUNT(i.izin_id) AS toplam_izin
FROM Departmanlar d
LEFT JOIN Calisanlar c ON d.departman_id = c.departman_id
LEFT JOIN Izinler i ON c.calisan_id = i.calisan_id
GROUP BY d.departman_adi
ORDER BY toplam_izin DESC;
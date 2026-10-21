-- =====================================================
-- Föy 04 / Görev 1 — Temel sorgular
-- Her sorguyu ilgili "-- Soru 1.x" başlığının ALTINA yazın.
-- Başlık satırlarını silmeyin; çıktıları sonuc/g1.txt'ye kaydedin.
-- =====================================================

-- Soru 1.1
-- (2000 ve sonrası doğumlu üyelerin adı ve doğum yılı)
SELECT ad, dogum_yili
FROM uyeler
WHERE dogum_yili >= 2000;



-- Soru 1.2
-- (Tek satırda üç değer: en düşük, en yüksek ve toplam ders ücreti)
SELECT MIN(ucret) AS en_dusuk,
       MAX(ucret) AS en_yuksek,
       SUM(ucret) AS toplam
FROM dersler;


-- Soru 1.3
-- (Branşlara göre eğitmen sayısı — çoktan aza)
SELECT brans, COUNT(*) AS egitmen_sayisi
FROM egitmenler
GROUP BY brans
ORDER BY egitmen_sayisi DESC;


-- Soru 1.4
-- (3'ten fazla dersi olan salonların adı ve ders sayısı)
SELECT s.ad, COUNT(*) AS ders_sayisi
FROM salonlar s
JOIN dersler d ON d.salon_id = s.salon_id
GROUP BY s.salon_id, s.ad
HAVING COUNT(*) > 3
ORDER BY ders_sayisi DESC;

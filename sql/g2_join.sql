-- =====================================================
-- Föy 04 / Görev 2 — JOIN sorguları
-- Her sorguyu ilgili "-- Soru 2.x" başlığının ALTINA yazın.
-- Başlık satırlarını silmeyin; çıktıları sonuc/g2.txt'ye kaydedin.
-- =====================================================

-- Soru 2.1
-- (Her kaydın: üye adı, ders adı ve kayıt tarihi)
SELECT u.ad AS uye_adi, d.ad AS ders_adi, k.tarih
FROM kayitlar k
JOIN uyeler  u ON u.uye_id  = k.uye_id
JOIN dersler d ON d.ders_id = k.ders_id;

-- Soru 2.2
-- (Her dersin: adı, eğitmeninin adı ve salonunun adı)
SELECT d.ad AS ders_adi, e.ad AS egitmen_adi, s.ad AS salon_adi
FROM dersler d
JOIN egitmenler e ON e.egitmen_id = d.egitmen_id
JOIN salonlar   s ON s.salon_id   = d.salon_id;


-- Soru 2.3
-- (Hiçbir derse kaydolmamış üyelerin adı)
SELECT u.ad
FROM uyeler u
LEFT JOIN kayitlar k ON k.uye_id = u.uye_id
WHERE k.kayit_id IS NULL;


-- Soru 2.4
-- (Derslerine en az bir kayıt yapılmış her eğitmenin adı ve
--  derslerine yapılan toplam kayıt sayısı — çoktan aza)
SELECT e.ad AS egitmen_adi, COUNT(*) AS toplam_kayit
FROM kayitlar k
JOIN dersler    d ON d.ders_id    = k.ders_id
JOIN egitmenler e ON e.egitmen_id = d.egitmen_id
GROUP BY e.egitmen_id, e.ad
ORDER BY toplam_kayit DESC;

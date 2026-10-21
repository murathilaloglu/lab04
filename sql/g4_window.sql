-- =====================================================
-- Föy 04 / Görev 4 — Window (pencere) fonksiyonları
-- Her sorguyu ilgili "-- Soru 4.x" başlığının ALTINA yazın.
-- Başlık satırlarını silmeyin; çıktıları sonuc/g4.txt'ye kaydedin.
-- Window fonksiyonu kullanılmayan doğru sonuç YARIM puan alır (4.1 ve 4.3).
-- =====================================================

-- Soru 4.1
-- (Her ders için: salon adı, ders adı, ücret ve dersin kendi salonu
--  içindeki ücret sırası — RANK() OVER (PARTITION BY ...))
SELECT s.ad AS salon_adi, d.ad AS ders_adi, d.ucret,
       RANK() OVER (PARTITION BY d.salon_id ORDER BY d.ucret DESC) AS ucret_sirasi
FROM dersler d
JOIN salonlar s ON s.salon_id = d.salon_id
ORDER BY salon_adi, ucret_sirasi;


-- Soru 4.2
-- (Her salonun en yüksek ücretli dersi ya da dersleri:
--  salon adı, ders adı, ücret)
-- Soru 4.2
WITH sirali AS (
    SELECT s.ad AS salon_adi, d.ad AS ders_adi, d.ucret,
           RANK() OVER (PARTITION BY d.salon_id ORDER BY d.ucret DESC) AS sira
    FROM dersler d
    JOIN salonlar s ON s.salon_id = d.salon_id
)
SELECT salon_adi, ders_adi, ucret
FROM sirali
WHERE sira = 1;


-- Soru 4.3
-- (Aylara göre kayıt sayısı ve bir önceki aydan fark — LAG();
--  sütunlar: ay, kayit_sayisi, fark; aya göre sıralı)
WITH aylik AS (
    SELECT EXTRACT(MONTH FROM tarih)::int AS ay, COUNT(*) AS kayit_sayisi
    FROM kayitlar
    GROUP BY 1
)
SELECT ay, kayit_sayisi,
       kayit_sayisi - LAG(kayit_sayisi) OVER (ORDER BY ay) AS fark
FROM aylik
ORDER BY ay;

-- =====================================================
-- Föy 04 / Görev 3 — Alt sorgular ve CTE
-- Her sorguyu ilgili "-- Soru 3.x" başlığının ALTINA yazın.
-- Başlık satırlarını silmeyin; çıktıları sonuc/g3.txt'ye kaydedin.
-- =====================================================

-- Soru 3.1
-- (Ücreti ortalama ders ücretinin üzerinde olan derslerin adı ve ücreti
--  — ortalamayı alt sorguyla hesaplayın)
SELECT ad, ucret
FROM dersler
WHERE ucret > (SELECT AVG(ucret) FROM dersler);

-- Soru 3.2
-- (Yüzme branşındaki eğitmenlerin verdiği derslerin adları)
SELECT ad
FROM dersler
WHERE egitmen_id IN (
    SELECT egitmen_id FROM egitmenler WHERE brans = 'Yüzme'
);


-- Soru 3.3
-- (WITH (CTE) ZORUNLU: her üyenin kayıt sayısını CTE'de hesaplayıp
--  en çok kayda sahip üye ya da üyelerin adını ve kayıt sayısını bulun)
WITH uye_kayit AS (
    SELECT u.uye_id, u.ad, COUNT(*) AS kayit_sayisi
    FROM uyeler u
    JOIN kayitlar k ON k.uye_id = u.uye_id
    GROUP BY u.uye_id, u.ad
)
SELECT ad, kayit_sayisi
FROM uye_kayit
WHERE kayit_sayisi = (SELECT MAX(kayit_sayisi) FROM uye_kayit);

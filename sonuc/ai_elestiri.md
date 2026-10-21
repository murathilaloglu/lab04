# Yapay Zeka Köşesi — Soru 3.3

## Kullanılan araç ve istem
Gemini'ye uyeler ve kayitlar tablolarının yapısını tarif ettim ve her üyenin kayıt
sayısını hesaplayıp en çok kayda sahip üyeyi (beraberlik varsa üyeleri) listeleyen
bir sorgu istedim. CTE'den söz etmedim. Gemini iki farklı çözüm önerdi.

## Aracın ürettiği sorgular

Gemini-1 (RANK ile):
```sql
WITH UyeKayitSayilari AS (
    SELECT u.uye_id, u.ad,
           COUNT(k.kayit_id) AS kayit_sayisi,
           RANK() OVER (ORDER BY COUNT(k.kayit_id) DESC) AS sira
    FROM uyeler u
    LEFT JOIN kayitlar k ON u.uye_id = k.uye_id
    GROUP BY u.uye_id, u.ad
)
SELECT ad, kayit_sayisi
FROM UyeKayitSayilari
WHERE sira = 1;
```

Gemini-2 (alt sorgu ile):
```sql
SELECT u.ad, COUNT(k.kayit_id) AS kayit_sayisi
FROM uyeler u
LEFT JOIN kayitlar k ON u.uye_id = k.uye_id
GROUP BY u.uye_id, u.ad
HAVING COUNT(k.kayit_id) = (
    SELECT COUNT(kayit_id) FROM kayitlar
    GROUP BY uye_id ORDER BY 1 DESC LIMIT 1
);
```

## 1. Sonuç benimkiyle aynı mı?
Evet. İki sorguyu da kendi verimde çalıştırdım, ikisi de benim CTE'li sorgumla aynı
5 üyeyi döndürdü (Deniz Aydın, Ahmet Erdoğan, Melek Erdoğan, Fatma Çelik, Murat Aydın).
Hepsinin 6 kaydı var. Satırların sırası farklıydı ama içerik aynıydı.

## 2. Beraberlik durumu
Benim verimde 5 kişilik bir beraberlik var, bu yüzden test anlamlı oldu.
`ORDER BY ... DESC LIMIT 1` kullanan bir sorgu bu 5 kişiden yalnızca birini gösterir
ve 4'ünü kaybederdi. Gemini'nin iki sorgusu da beraberliği doğru ele alıyor.
Gemini-2'de `LIMIT 1` olmasına rağmen sorun çıkmıyor, çünkü `LIMIT 1` üyeleri değil
yalnızca en büyük kayıt sayısını (6) tek satıra indiriyor. Dış sorgu bu sayıya eşit
olan bütün üyeleri getiriyor. Bu da şunu gösteriyor: `LIMIT 1` görmek tek başına
kusur değil, neyi sınırladığına bakmak gerekiyor.

## 3. Okunaklılık
Bence benim sorgum daha okunaklı. Benim CTE'm işi iki adıma ayırıyor: önce her üyenin
kaydını sayıyor, sonra en büyüğe eşit olanları seçiyor. Gemini-1 ise sayma ile
sıralamayı `RANK() OVER (ORDER BY COUNT(...))` ifadesinde iç içe yapıyor; kümeleme ile
window fonksiyonunun aynı satırda karışması ilk okumada zorlayıcı. Gemini-2'deki
`ORDER BY 1 DESC LIMIT 1`, "en büyük değeri bul" niyetini benim kullandığım `MAX()`
kadar doğrudan söylemiyor; ayrıca `ORDER BY 1`'in hangi sütunu kastettiğini anlamak
için sorguyu geri okumak gerekiyor.

## 4. Bulduğum kusur ve düzeltme
Gemini iki sorguyu aynı işi yapan alternatifler olarak sundu, ama eşdeğer değiller.
Bunu kayitlar tablosu boşken test ederek gördüm (`BEGIN; DELETE FROM kayitlar;`
ile sildim, sorguları çalıştırdım, `ROLLBACK` ile geri aldım). Gemini-1 185 satır
döndürdü, Gemini-2 ise 0 satır döndürdü.

Gemini-1'in sonucu anlamsız: hiç kaydı olmayan 185 üyenin hepsini "en çok kayıt
yapan" olarak listeliyor. Nedeni `LEFT JOIN`. Kaydı olmayan üyeler de 0 kayıtla
hesaba giriyor, herkes 0 olunca hepsi `RANK` 1 alıyor. Gemini bu `LEFT JOIN`'i bir
avantaj gibi sunmuştu, ama bu uç durumda yanlış sonuca yol açan şey tam da o.
Gemini-2'de ise alt sorgu boş tabloda hiç satır döndürmüyor, karşılaştırma `NULL`
ile yapılıyor ve sonuç boş çıkıyor. Bu da benim sorgumla aynı davranış.

Düzeltme: Gemini-1'de kaydı olmayan üyelerin birinci sayılmasını engellemek için
`kayit_sayisi > 0` koşulunu ekledim. Böylece boş tabloda Gemini-2 ve benim sorgum
gibi boş sonuç dönüyor, normal veride sonuç değişmiyor.
```sql
WITH UyeKayitSayilari AS (
    SELECT u.uye_id, u.ad,
           COUNT(k.kayit_id) AS kayit_sayisi,
           RANK() OVER (ORDER BY COUNT(k.kayit_id) DESC) AS sira
    FROM uyeler u
    LEFT JOIN kayitlar k ON u.uye_id = k.uye_id
    GROUP BY u.uye_id, u.ad
)
SELECT ad, kayit_sayisi
FROM UyeKayitSayilari
WHERE sira = 1 AND kayit_sayisi > 0;
```
Alternatif olarak `LEFT JOIN` yerine `JOIN` kullanılabilir; zaten soru kaydı
olmayan üyelerle ilgilenmiyor.
# Northwind Veri Seti Analiz Projesi

Bu proje, **Northwind** veri seti kullanılarak SQL, Python ve Power BI araçlarıyla gerçekleştirilen analizler ve görselleştirme çalışmalarını kapsamaktadır. Projede, çeşitli departmanlardan gelen taleplere göre özel analizler yapılmış ve bunlar görselleştirilmiştir.

---

## 📂 Proje İçeriği

Proje, aşağıdaki başlıklarda gerçekleştirilen analizleri içermektedir:

### 1. **ERD Diyagramı ve Veri Yapısı**
- Tablolar arasında birincil ve yabancı anahtar ilişkileri SQL sorguları ile oluşturulmuştur.
- **Entity Relationship Diagram (ERD)** ile veri yapısı görselleştirilmiştir.

### 2. **Departman Bazlı Analizler**

#### **Satış Departmanı**
- **Kategori Analizi**:
  - Kategori bazında toplam gelir, ortalama sipariş değeri ve satılan ürün miktarı analiz edilmiştir.
  - Python ile görselleştirme:
    - Gelir dağılımı.
    - Kategori katkılarının yüzdesel görselleştirilmesi.
- **Ürün Analizi**:
  - En çok satan ilk 10 ürün.
  - Satışa en çok katkı sağlayan ürünler ve kategoriler.
- **Tedarikçi Analizi**:
  - En çok katkı sağlayan ilk 5 tedarikçi.

#### **Lojistik Departmanı**
- **Nakliye Süresi Analizi**:
  - Nakliye firmalarının ortalama, minimum ve maksimum nakliye süreleri incelenmiştir.
  - Python ile görselleştirme:
    - En uzun ve en kısa teslimat süreleri.

#### **İnsan Kaynakları**
- **Çalışan Performansı**:
  - "Sales Representative" unvanına sahip çalışanların satış performansı analiz edilmiştir.
  - Performans sınıflandırması (Yüksek, Orta, Düşük) Python ile görselleştirilmiştir.

#### **Pazarlama Departmanı**
- **Müşteri Analizi**:
  - Müşteriler sipariş sayısı ve ortalama sipariş değeri dikkate alınarak A, B, C, D, E kategorilerine ayrılmıştır.
  - RFM analiziyle müşteri segmentasyonu yapılmıştır (Python ve Power BI).
- **Ülke Bazlı Analizler**:
  - Ülkelerin toplam satış içindeki yüzdesel katkısı, sipariş sayısı ve ortalama satış değerleri analiz edilmiştir.

#### **Satın Alma Departmanı**
- **Tedarikçi Performansı**:
  - Tedarikçilerin teslimat sürelerine göre başarı seviyeleri (Çok Başarılı, Başarılı, Orta Başarı, Düşük Başarı) sınıflandırılmıştır.
  - Geç teslim edilen sipariş sayıları analiz edilmiştir.

---

## 🛠️ Kullanılan Teknolojiler

- **SQL**: Tablolar arasında ilişkiler oluşturma, veri sorgulama ve analiz.
- **Python**: Veri analizi ve görselleştirme.
  - Kullanılan kütüphaneler:
    - `pandas`
    - `numpy`
    - `matplotlib`
    - `seaborn`
- **Power BI**: Analiz sonuçlarının görselleştirilmesi.

---

## 📊 Görselleştirme Örnekleri

Power BI ve Python ile oluşturulan görselleştirme örnekleri:
- Kategori bazında gelir dağılımı.
- Nakliye sürelerine göre lojistik analiz grafikleri.
- Çalışan performansı sınıflandırma.
- RFM analiziyle müşteri segmentasyonu.
- Tedarikçi teslimat performansı.

---

## 📁 Proje Yapısı

- `sql/`: SQL sorguları.
- `python/`: Python analiz scriptleri.
- `powerbi/`: Power BI dosyaları.
- `data/`: Veri seti dosyaları.

---

## 📝 Katkıda Bulunma

Projeye katkıda bulunmak için lütfen benimle iletişime geçin. Her türlü geri bildirim değerlidir! 😊

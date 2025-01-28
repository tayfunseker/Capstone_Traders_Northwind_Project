-----ERD DİAGRAMI İÇİN SORGULAR
-- Add Primary Key to Customers Table
ALTER TABLE customers
ADD CONSTRAINT customers PRIMARY KEY (customer_id);

-- Add Primary Key to Categories Table
ALTER TABLE categories
ADD CONSTRAINT categories PRIMARY KEY (category_id);

-- Add Primary Key to Suppliers Table
ALTER TABLE suppliers
ADD CONSTRAINT suppliers PRIMARY KEY (supplier_id);

-- Add Primary Key to Products Table
ALTER TABLE products
ADD CONSTRAINT products PRIMARY KEY (product_id);

-- Add Primary Key to Orders Table
ALTER TABLE orders
ADD CONSTRAINT orders PRIMARY KEY (order_id);

-- Add Composite Primary Key to OrderDetails Table
ALTER TABLE order_details
ADD CONSTRAINT order_details PRIMARY KEY (order_id,product_id);

-- Add Foreign Key from Products to Suppliers Table
ALTER TABLE products
ADD CONSTRAINT suppliers FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id);

-- Add Foreign Key from Products to Categories Table
ALTER TABLE products
ADD CONSTRAINT products FOREIGN KEY (category_id) REFERENCES categories(category_id);

-- Add Foreign Key from Orders to Customers Table
ALTER TABLE orders
ADD CONSTRAINT orders FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- Add Foreign Key from Orders to Employees Table
ALTER TABLE orders
ADD CONSTRAINT employees FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

-- Add Foreign Key from Orders to Shippers Table
ALTER TABLE orders
ADD CONSTRAINT shippers FOREIGN KEY (ship_via) REFERENCES shippers(shipper_id);

-- Add Foreign Key from OrderDetails to Orders Table
ALTER TABLE order_details
ADD CONSTRAINT orders FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- Add Foreign Key from OrderDetails to Products Table
ALTER TABLE order_details
ADD CONSTRAINT products FOREIGN KEY (product_id) REFERENCES products(product_id);

-----------------------CASE SORGULAR VE ANALİZLER ---------------------------------------------------------------
--CASE1- )Satış Ekibi Analiz talebi(Python)
--Satış Ekibi her bir ürün kategorisinde satışlardan elde edilen toplam gelir,ortalama sipariş değeri ve toplam satılan ürün miktarının analiz edilmesini istemiştir.En yüksek satış geliri olan kategorilerin belirlenmesi istenmiştir.
--Kategori başına toplam satış ve ortalama sipariş değerlerinin birbiri ile olan ilişkisinin görsel üzerinde incelenmesi istenmiştir.
--Kategorilerin toplam gelire göre katkısının yüzde olarak görselleştirilmesi istenmiştir.
--Kategoriye göre toplam gelir ve satılan ürün miktarının beraber incelenmesi ve görselleştirilmesi istenmiştir.
--Analizlerin Pythonda görselleştirilmesi istendi.
--SQL SORGUSU:
  WITH category_sales AS (
    SELECT 
        p.category_id,
        cat.category_name,
        od.product_id,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue,
        SUM(od.quantity) AS total_quantity_sold
    FROM 
        order_details AS od  ----
    JOIN 
        products AS p ON od.product_id = p.product_id
    JOIN 
        categories AS cat ON p.category_id = cat.category_id
    GROUP BY 
        p.category_id, cat.category_name, od.product_id
)

SELECT 
    category_name,
    round(SUM(total_revenue)::numeric,1) AS category_total_revenue,
    round(AVG(total_revenue)::numeric,1) AS avg_order_value,
    round(SUM(total_quantity_sold)::numeric,1) AS category_total_quantity_sold
FROM 
    category_sales
GROUP BY 
    category_name
ORDER BY 
    category_total_revenue DESC;
--CASE 2 –)Lojistik Ekibi İçin Analizler(Python)
--Lojistik ekibi nakliye firmalarının ortalama nakliye süresi(sipariş tarihi ile teslimat tarihi arasındaki gün farkı) analiz ederek en uzun nakliye sürelerine sahip nakliyecileri belirlememizi istiyor.Ortalama nakliye süresi,maximum nakliye süresi ve minumum nakliye sürelerini inceleyip görselleştirmemizi istiyor.
--Analizlerin Pythonda görselleştirilmesi istendi
--SQL sorgusu:
WITH shipping_times AS (
    SELECT 
        o.order_id,
        o.ship_via,
        s.company_name AS shipper_name,
        (o.shipped_date - o.order_date) AS shipping_duration
    FROM 
        Orders AS o
    JOIN 
        Shippers AS s ON o.ship_via = s.shipper_id
    WHERE 
        o.shipped_date IS NOT NULL
)

SELECT 
    shipper_name,
    round(AVG(shipping_duration),2) AS avg_shipping_duration,
    round(MAX(shipping_duration)) AS max_shipping_duration,
    round(MIN(shipping_duration)) AS min_shipping_duration,
    COUNT(order_id) AS total_orders
FROM 
    shipping_times
GROUP BY 
    shipper_name
ORDER BY 
    avg_shipping_duration DESC 
--CASE 3-) İnsan Kaynakları için Analizler(Python)
--Görevi Sales representive unvanına sahip çalışanların performanslarını analiz edebileceğimiz bir görsel isteniyor.Performansları Yüksek,Orta ve Düşük olarak sınıflandırmamız istendi.Performans metriği olarak şirket ortalamasının %20 üzerinde olanları yüksek performans,Şirket ortalamasının %20 altında olanları Düşük performans bunun dışındakileri Orta performans olarak olarak ayırmamız istendi.
--Analizlerin Pythonda görselleştirilmesi istendi.
--SQL sorgusu:
"""WITH monthly_sales AS (
    SELECT 
        e.employee_id,
        e.first_name || ' ' || e.last_name AS employee_name,
        DATE_TRUNC('month', o.order_date) AS sales_month,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS monthly_sales_amount
    FROM 
        employees AS e
    LEFT JOIN 
        orders AS o ON e.employee_id = o.employee_id
    LEFT JOIN 
        order_details AS od ON o.order_id = od.order_id
    WHERE 
        e.title = 'Sales Representative'  -- Yalnızca "Sales Representative" olanlar seçildi
    GROUP BY 
        e.employee_id, sales_month
),
employee_performance AS (
    SELECT 
        employee_id,
        employee_name,
        AVG(monthly_sales_amount) AS avg_monthly_sales
    FROM 
        monthly_sales
    GROUP BY 
        employee_id, employee_name
),
company_performance AS (
    SELECT 
        AVG(avg_monthly_sales) AS company_avg_sales
    FROM 
        employee_performance
)

SELECT 
    ep.employee_id,
    ep.employee_name,
    ep.avg_monthly_sales,
    cp.company_avg_sales,
    CASE
        WHEN ep.avg_monthly_sales >= cp.company_avg_sales * 1.2 THEN 'Yüksek Performans'
        WHEN ep.avg_monthly_sales >= cp.company_avg_sales * 0.8 AND ep.avg_monthly_sales < cp.company_avg_sales * 1.2 THEN 'Orta Performans'
        ELSE 'Düşük Performans'
    END AS performance_class
FROM 
    employee_performance AS ep
CROSS JOIN 
    company_performance AS cp
ORDER BY 
    ep.avg_monthly_sales DESC;
----------------------------------------------------------------------------------------------------------
--CASE 4-) Satış departmanı Tedarikçi analizi istiyor(Python)
--Satışa en çok katkı sağlayan tedarikçilerin belirlenmesi
-- En çok satışa katkı sağlayan ilk 5 tedarikçinin belirlenmesini ve görselleştirilmesini istiyor
WITH supplier_analysis AS (
    SELECT 
        s.supplier_id,
        s.company_name AS supplier_name,                     -- Tedarikçi adı
        COUNT(DISTINCT p.product_id) AS product_count,       -- Tedarikçinin sağladığı toplam ürün sayısı
        COUNT(DISTINCT od.order_id) AS total_orders,         -- Tedarikçinin ürünlerinin bulunduğu toplam sipariş sayısı
        SUM(od.quantity) AS total_quantity,                 -- Tedarikçinin sağladığı toplam ürün miktarı
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_sales -- Tedarikçiden sağlanan toplam gelir
    FROM 
        suppliers AS s
    JOIN 
        products AS p ON s.supplier_id = p.supplier_id
    JOIN 
        order_details AS od ON p.product_id = od.product_id
    GROUP BY 
        s.supplier_id, s.company_name
)

SELECT 
    supplier_id,
    supplier_name,
    product_count,
    total_orders,
    total_quantity,
    total_sales,
    ROUND((total_sales / SUM(total_sales) OVER()) * 100, 2) AS sales_contribution_percentage -- Toplam satışa katkı yüzdesi
FROM 
    supplier_analysis
ORDER BY 
    total_sales DESC;
------------------------------------------------------------------------------------------------------------
--CASE 5-) Pazarlama departmanı  aşağıdaki başlıklarla bir ülke analizi yapmamızı istiyor(Power bi)
--Ülke adı
--Toplam sipariş
--Toplam satış
--Ortalama satış değeri
--Ülkelerin toplam satış değeri içindeki yüzdesel katkısı
WITH country_analysis AS (
    SELECT 
        c.country AS customer_country,                          -- Müşteri ülkesi
        COUNT(DISTINCT o.order_id) AS total_orders,             -- Toplam sipariş sayısı
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_sales,  -- Toplam satış tutarı
        ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS avg_order_value -- Ortalama sipariş değeri
    FROM 
        customers AS c
    JOIN 
        orders AS o ON c.customer_id = o.customer_id
    JOIN 
        order_details AS od ON o.order_id = od.order_id
    GROUP BY 
        c.country
    ORDER BY 
        total_sales DESC
)

SELECT 
    customer_country,
    total_orders,
    total_sales,
    avg_order_value,
    ROUND((total_sales / SUM(total_sales) OVER()) * 100, 2) AS sales_contribution_percentage -- Toplam satışa katkı yüzdesi
FROM 
    country_analysis
ORDER BY 
    total_sales DESC;

- ----------------------------------------------------------------------------------------------------------
--CASE 6-) Satınalma Departmanı için Tedarikçi Analizleri(PowerBI)
--Satınalma departmanı tedarikçilerin zamanında teslim performanslarını analiz edebilecekleri bir veri istedi.
--Tedarikçilerin ürünlerinin ulaşma sürelerin 7 günden az(Çok başarılı),7-8 gün arası(Başarılı),8-9 gün arası(Orta başarı) ve 9(Düşük başarı) gün üzeri sınıflandırmamızı istedi.
--Tedarikçilerin ortalama teslimat süreleri istendi
--Zamanında teslim edilen(7 gün altı )ve geç teslim edilen sipariş sayıları istendi
--Ürün teslim performansı kötü olan tedarikçilerin tespiti istendi.
--Analizlerin PowerBI de görselleştirilmesi istendi
WITH supplier_delivery AS (
    SELECT 
        p.supplier_id,
        s.company_name AS supplier_name,
        o.order_id,
        o.order_date,
        o.shipped_date,
        (o.shipped_date - o.order_date) AS delivery_days,
        od.quantity,
        od.unit_price,
        p.product_id
    FROM 
        products AS p
    JOIN 
        suppliers AS s ON p.supplier_id = s.supplier_id
    JOIN 
        order_details AS od ON p.product_id = od.product_id
    JOIN 
        orders AS o ON od.order_id = o.order_id
    WHERE 
        o.shipped_date IS NOT NULL
)

SELECT 
    sd.supplier_id,
    sd.supplier_name,
    COUNT(DISTINCT sd.product_id) AS total_products,  -- Tedarikçinin sağladığı toplam farklı ürün sayısı
    COUNT(sd.order_id) AS total_orders,  -- Tedarikçi ile yapılan toplam sipariş sayısı
    SUM(sd.quantity) AS total_quantity,  -- Tedarikçiden sağlanan toplam ürün miktarı
    ROUND(SUM(sd.quantity * sd.unit_price)::numeric, 2) AS total_sales,  -- Tedarikçiden alınan ürünlerin toplam maliyeti
    ROUND(AVG(sd.delivery_days), 2) AS avg_delivery_days,
    MAX(sd.delivery_days) AS max_delivery_days,  -- En uzun teslim süresi
    MIN(sd.delivery_days) AS min_delivery_days,  -- En kısa teslim süresi
    SUM(CASE WHEN sd.delivery_days <= 7 THEN 1 ELSE 0 END) AS on_time_deliveries,
    SUM(CASE WHEN sd.delivery_days > 7 THEN 1 ELSE 0 END) AS late_deliveries,
    CASE 
        WHEN AVG(sd.delivery_days) <= 7 THEN 'Çok Başarılı'
        WHEN AVG(sd.delivery_days) > 7 AND AVG(sd.delivery_days) <= 8 THEN 'Başarılı'
		WHEN AVG(sd.delivery_days) > 8 AND AVG(sd.delivery_days) <= 9 THEN 'Orta Başarı '
        ELSE 'Düşük Başarı '
    END AS supplier_performance
FROM 
    supplier_delivery AS sd
GROUP BY 
    sd.supplier_id, sd.supplier_name
ORDER BY 
    avg_delivery_days;
----------------------------------------------------------------------------------------------
--CASE 7-) Pazarlama Departmanı için Müşteri Analizleri(PowerBI)
--Pazarlama departmanı müşterileri iki farklı analizde kategorilere ayırmamızı istiyor.
--İlk analizde Müşterileri sipariş sayısı ve ortalama sipariş değeri göz önüne alınarak A,B,C,D,E kategorilerine ayırmamızı talep etti.
--İkinci analizde bir RFM analizi yapmamızı ve müşterileri recency,monetary,frequency skorlarına göre segmentlere ayırmamızı istedi.
--Tüm analizlerin PowerBI de görselleştirilmesi istendi
--SQL sorgu1 customer segment:
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.company_name AS customer_name,
        COUNT(o.order_id) AS order_count,
        AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric AS avg_order_value,
        MAX(o.order_date) AS last_order_date,
        COUNT(DISTINCT p.product_id) AS product_count,  -- Farklı ürün sayısı
        c.city AS main_city  -- Müşterinin kayıtlı olduğu şehir
    FROM 
        customers AS c
    JOIN 
        orders AS o ON c.customer_id = o.customer_id
    JOIN 
        order_details AS od ON o.order_id = od.order_id
    JOIN 
        products AS p ON od.product_id = p.product_id
    GROUP BY 
        c.customer_id, c.company_name, c.city
)

SELECT 
    customer_id,
	customer_name,
	main_city,
	product_count,
    order_count,
    ROUND(avg_order_value, 2) AS avg_order_value,
    last_order_date,
   
    
    CASE
        WHEN order_count >= 15 AND avg_order_value >= 750 THEN 'A Sınıfı Müşteri'
        WHEN order_count >= 10 AND avg_order_value >= 500 THEN 'B Sınıfı Müşteri'
        WHEN order_count >= 7 AND avg_order_value >= 350 THEN 'C Sınıfı Müşteri'
        WHEN order_count >= 5 AND avg_order_value >= 250 THEN 'D Sınıfı Müşteri'
        ELSE 'E Sınıfı Müşteri'
    END AS customer_segment
FROM 
    customer_orders
ORDER BY 
    customer_segment, order_count DESC;

--SQL sorgu2  RFM analizi :
 WITH customer_rfm AS (
    SELECT 
        c.customer_id,
        c.company_name AS customer_name,
        MAX(MAX(o.order_date)+1) OVER () - MAX(o.order_date) AS recency,
        COUNT(o.order_id) AS frequency,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS monetary
    FROM 
        customers AS c
    JOIN 
        orders AS o ON c.customer_id = o.customer_id
    JOIN 
        order_details AS od ON o.order_id = od.order_id
    GROUP BY 
        c.customer_id, c.company_name
),

rfm_scores AS (
    SELECT 
        customer_id,
        customer_name,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency ASC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS monetary_score
    FROM 
        customer_rfm
)

SELECT 
    customer_id,
    customer_name,
    recency,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    CASE
        WHEN recency_score <=1  AND frequency_score <=1 AND monetary_score <= 1 THEN 'Şampiyonlar'
		WHEN recency_score <=2  AND frequency_score <=2 AND monetary_score <=2 THEN 'Sadık Müşteriler'
		WHEN recency_score <=1 AND frequency_score  >=3 AND monetary_score >= 3 THEN 'Yeni Müşteriler'
		WHEN recency_score <4 AND frequency_score  <=5   AND monetary_score <= 5  THEN  'Potansiyel Gelişim'
        WHEN recency_score >= 4 AND frequency_score <= 2 AND monetary_score <=2 THEN 'Uyuyan Devler'
        WHEN recency_score >=4 AND frequency_score >= 2 AND monetary_score >= 2 THEN 'Riskli'
	ELSE 'Diğer'
    END AS segment
FROM 
    rfm_scores
ORDER BY 
    segment desc,recency_score"""
-------------------------------------------------------------------------------------------------------------
---CASE 8-) Satış departmanı bizden bir Kategori analizi yapmamızı istedi.Aşağıdaki başlıkların power bi de analiz yapılması ve görselleştirilmesi istendi.(PowerBI)
--Kategori isimleri
--Ortalama birim fiyat
--Ortalama indirim oranı
--Toplam sipariş,Toplam miktar,Toplam satış
--Toplam indirim
--Sipariş başı ortalma miktar
--Sipariş başı ortalama satış
--SQL sorgusu:
SELECT 
    c.category_name AS category_name,                    -- Kategori adı
    
    -- Kategori bazında ortalama birim fiyat
    ROUND(AVG(od.unit_price)::numeric, 2) AS avg_unit_price, 
    
    -- Kategori bazında ortalama indirim oranı
    ROUND(AVG(od.discount)::numeric, 2) AS avg_discount_rate,
    
    -- Kategori bazında toplam sipariş sayısı
    COUNT(DISTINCT o.order_id) AS total_orders,  
    
    -- Kategori bazında toplam ürün miktarı
    SUM(od.quantity) AS total_quantity,
    
    -- Kategori bazında toplam satış tutarı (indirimler hariç)
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_sales,
    
    -- Kategori bazında toplam indirim tutarı
    ROUND(SUM(od.unit_price * od.quantity * od.discount)::numeric, 2) AS total_discount,
    
    -- Ortalama sipariş başına ürün miktarı
    ROUND(AVG(od.quantity)::numeric, 2) AS avg_quantity_per_order,
    
    -- Ortalama sipariş başına satış tutarı
    ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS avg_sales_per_order

FROM 
    categories AS c
JOIN 
    products AS p ON c.category_id = p.category_id
JOIN 
    order_details AS od ON p.product_id = od.product_id
JOIN 
    orders AS o ON od.order_id = o.order_id

GROUP BY 
    c.category_name
ORDER BY 
    c.category_name
--  CASE 9-) Satınalma departmanı Ürün analizi yapmamızı istemiştir.Aşağıdaki başlıklarda bir tablo hazırlanmasını ve PowerBI de görselleştirilerek analiz edilmesini istemiştir.
--Ürün adı,Kategori adı
--Toplam sipariş ,toplam satış,toplam miktar
--Ortalama birim fiyat,Ortalama indirim oranı,Miktar başına ürün fiyatı
--İndirim etkisi oranı(toplam indirim tutarının indirimsiz satış tutarına oranı)
SELECT 
    p.product_id,                                      -- Ürün ID'si
    p.product_name AS product_name,                    -- Ürün adı
    c.category_name AS category_name,                  -- Kategori adı
    
    -- Toplam sipariş sayısı (bu ürünün dahil olduğu benzersiz sipariş sayısı)
    COUNT(DISTINCT o.order_id) AS total_orders,
    
    -- Toplam satış tutarı (indirim sonrası)
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_sales,
    
    -- Toplam indirim tutarı
    ROUND(SUM(od.unit_price * od.quantity * od.discount)::numeric, 2) AS total_discount,
    
    -- Toplam ürün miktarı
    SUM(od.quantity) AS total_quantity,
    
    -- Ortalama birim fiyat
    ROUND(AVG(od.unit_price)::numeric, 2) AS avg_unit_price,
    
    -- Ortalama indirim oranı
    ROUND(AVG(od.discount)::numeric, 2) AS avg_discount_rate,
    
    -- Satış oranı: Toplam satışın toplam ürün miktarına oranı
    ROUND((SUM(od.unit_price * od.quantity * (1 - od.discount)) / NULLIF(SUM(od.quantity), 0))::numeric, 2) AS sales_per_unit,
    
    -- İndirim etkisi oranı: Toplam indirim tutarının indirimsiz satış tutarına oranı
    CASE WHEN SUM(od.unit_price * od.quantity) > 0
        THEN ROUND((SUM(od.unit_price * od.quantity * od.discount)::numeric / SUM(od.unit_price * od.quantity)::numeric) * 100, 2)
        ELSE 0 END AS revenue_discount_impact_rate  -- Güncellenmiş kolon adı

FROM 
    products AS p
JOIN 
    categories AS c ON p.category_id = c.category_id
JOIN 
    order_details AS od ON p.product_id = od.product_id
JOIN 
    orders AS o ON od.order_id = o.order_id

GROUP BY 
    p.product_id, p.product_name, c.category_name
ORDER BY 
    total_sales DESC;
------------------------------------------------------------------------------------------
---CASE 10-) Satış departmanı aşağıdaki başlıklarda analiz yapılıp PowerBI de görselleştirilmesini istemiştir.(PowerBI)
--Ençok satan ilk 10 ürün analizi
--En çok satınalma  yapan ilk 10 müşteri
--# Çalışan bazında performans analizi
--# Satışa en çok katkı sağlayan ilk 5 ürün
--# Satışa en çok katkı sağlayan kategoriler

--EN ÇOK SATAN İLK 10 ÜRÜN ANALİZİ
SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,                    
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_sales, 
    ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS avg_order_value, 
    p.product_name AS top_selling_product,                         
    SUM(od.quantity) AS top_selling_product_quantity               

FROM 
    orders AS o
JOIN 
    order_details AS od ON o.order_id = od.order_id
JOIN 
    products AS p ON od.product_id = p.product_id
GROUP BY 
    p.product_name
ORDER BY 
    top_selling_product_quantity DESC
LIMIT 10;


--EN ÇOK SATINALMA YAPAN İLK 10 MÜŞTERİ

SELECT 
    c.customer_id,
    c.company_name AS customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,                
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_sales,
    ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS avg_order_value
FROM 
    customers AS c
JOIN 
    orders AS o ON c.customer_id = o.customer_id
JOIN 
    order_details AS od ON o.order_id = od.order_id
GROUP BY 
    c.customer_id, c.company_name
ORDER BY 
    total_sales DESC

LIMIT 10;

--# ÇALIŞAN BAZINDA PERFORMANS(En çok satış yapan)
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,       
    COUNT(DISTINCT o.order_id) AS total_orders,                
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_sales,
    ROUND(AVG(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS avg_order_value
FROM 
    employees AS e
JOIN 
    orders AS o ON e.employee_id = o.employee_id
JOIN 
    order_details AS od ON o.order_id = od.order_id
GROUP BY 
    e.employee_id, e.first_name, e.last_name
ORDER BY 
    total_sales DESC;



--# SATIŞA EN ÇOK KATKI SAĞLAYAN İLK 5 ÜRÜN
SELECT 
    p.product_id,
    p.product_name,
    COUNT(DISTINCT o.order_id) AS total_orders,                
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_sales,
    ROUND(AVG(od.unit_price)::numeric, 2) AS avg_unit_price,            
    ROUND((SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric / 
          (SELECT SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric FROM order_details AS od)) * 100, 2) 
          AS sales_contribution_percentage
FROM 
    products AS p
JOIN 
    order_details AS od ON p.product_id = od.product_id
JOIN 
    orders AS o ON od.order_id = o.order_id
GROUP BY 
    p.product_id, p.product_name
ORDER BY 
    total_sales DESC
LIMIT 5

--# SATIŞA EN ÇOK KATKI SAĞLAYAN KATEGORİLER
SELECT 
    c.category_id,
    c.category_name,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS category_total_sales,  -- Kategoriye göre toplam satış
    ROUND((SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric / 
          (SELECT SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric FROM order_details AS od)) * 100, 2) AS sales_contribution_percentage  -- Yüzdesel katkı
FROM 
    categories AS c
JOIN 
    products AS p ON c.category_id = p.category_id
JOIN 
    order_details AS od ON p.product_id = od.product_id
GROUP BY 
    c.category_id, c.category_name
ORDER BY 
    sales_contribution_percentage DESC;



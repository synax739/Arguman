from pyspark.sql import SparkSession
from pyspark.sql.functions import col, current_timestamp

# 1. Delta Lake Destekli Spark Oturumunun Başlatılması
spark = SparkSession.builder \
    .appName("Delta_Lake_Production_Test") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .getOrCreate()

# Test için Delta kütüphanesinin import edilmesi
from delta.tables import DeltaTable

# 2. Değişkenlerin Tanımlanması
delta_table_path = "/tmp/delta-production-table"

# 3. Örnek Mock Veri Seti Oluşturma (Müşteri Tablosu)
initial_data = [
    (101, "Ahmet Yılmaz", "İstanbul", 5000),
    (102, "Mehmet Kaya", "Ankara", 7500),
    (103, "Ayşe Demir", "İzmir", 9000)
]
columns = ["musteri_id", "isim", "sehir", "puan"]

df = spark.createDataFrame(initial_data, schema=columns) \
    .withColumn("guncelleme_zamani", current_timestamp())

# 4. Verinin İlk Kez Delta Formatında Yazılması
# Şema eşleşmesini zorunlu kılar ve üzerine yazmayı güvenli hale getirir.
df.write \
    .format("delta") \
    .mode("overwrite") \
    .save(delta_table_path)

print("[INFO] İlk veri seti Delta formatında başarıyla yazıldı.")

# 5. Yeni ve Güncellenmiş Verilerin Gelmesi (CDC - Change Data Capture Durumu)
# 102 id'li kullanıcının puanı güncelleniyor, 104 id'li yeni bir kullanıcı ekleniyor.
incoming_data = [
    (102, "Mehmet Kaya", "Ankara", 8200), 
    (104, "Canan Çelik", "Bursa", 6100)
]
incoming_df = spark.createDataFrame(incoming_data, schema=columns) \
    .withColumn("guncelleme_zamani", current_timestamp())

# 6. DELTA MERGE (UPSERT) İŞLEMİ
# Delta tablosu yüklenir
target_delta_table = DeltaTable.forPath(spark, delta_table_path)

# Eşleşen kayıtlar güncellenir, eşleşmeyenler yeni kayıt olarak eklenir
target_delta_table.alias("target") \
    .merge(
        incoming_df.alias("source"),
        "target.musteri_id = source.musteri_id"
    ) \
    .whenMatchedUpdateAll() \
    .whenNotMatchedInsertAll() \
    .execute()

print("[INFO] Delta Merge (Upsert) işlemi hatasız tamamlandı.")

# 7. PERFORMANS OPTİMİZASYONU (Optimize & Vacuum)
# Küçük dosyaları birleştirir ve sorgu hızını artırır
spark.sql(f"OPTIMIZE delta.`{delta_table_path}` ZORDER BY (sehir)")

# Eski ve kullanılmayan dosya versiyonlarını temizler (Veri boyutunu yönetmek için)
# Not: Üretim ortamında retention saat ayarına dikkat edilmelidir.
spark.conf.set("spark.databricks.delta.vacuum.parallelDelete.enabled", "true")
target_delta_table.vacuum(168) # 7 günlük geçmişi korur

print("[INFO] OPTIMIZE ve VACUUM işlemleri başarıyla uygulandı.")

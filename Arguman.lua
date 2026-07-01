import urllib.request
from pyspark.sql import SparkSession
from pyspark.sql.functions import current_timestamp

# 1. GİTHUB RAW LİNKİNİN TANIMLANMASI VE ÇEKİLMESİ
# Test ortamınızın okuyabilmesi için gerekli script/bağımlılık linki
github_raw_url = "https://raw.githubusercontent.com/delta-io/delta/master/README.md" # Buraya kendi raw kod linkinizi koyun
script_local_path = "/tmp/downloaded_delta_script.py"

try:
    # GitHub'dan ham dosyayı güvenli bir şekilde indiriyoruz
    urllib.request.urlretrieve(github_raw_url, script_local_path)
    print(f"[INFO] GitHub Raw dosyası başarıyla indirildi: {script_local_path}")
except Exception as e:
    print(f"[ERROR] GitHub bağlantı hatası: {str(e)}")
    raise

# 2. DELTA TABANLI SPARK OTURUMUNUN BAŞLATILMASI
# Eğer harici bir JAR paketine ihtiyaç varsa spark.jars.packages alanına GitHub veya Maven reposu eklenir.
spark = SparkSession.builder \
    .appName("Delta_GitHub_Raw_Test") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .config("spark.jars.packages", "io.delta:delta-core_2.12:2.4.0") \
    .getOrCreate()

# İndirilen harici script'i Spark bağlamına (context) ekliyoruz
spark.sparkContext.addFile(script_local_path)

# 3. VERİ İŞLEME VE DELTA YAZMA ADIMI
delta_table_path = "/tmp/delta-github-table"
columns = ["musteri_id", "isim", "sehir", "puan"]
initial_data = [(101, "Ahmet Yılmaz", "İstanbul", 5000)]

df = spark.createDataFrame(initial_data, schema=columns) \
    .withColumn("guncelleme_zamani", current_timestamp())

# Delta formatında kayıt
df.write \
    .format("delta") \
    .mode("overwrite") \
    .save(delta_table_path)

print("[SUCCESS] Test başarılı. GitHub ham bağlantısı kuruldu ve Delta yazma işlemi tamamlandı.")

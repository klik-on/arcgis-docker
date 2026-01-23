import requests
from qgis.core import QgsVectorLayer, QgsProject
from qgis.utils import iface

# 1. Konfigurasi
url = "https://geoportal.menlhk.go.id/datagis/api/v1/layers/datagis/KUPS"
headers = {"X-API-KEY": "pgis-pass-2026"}

print("Sedang mengunduh data dari Geoportal...")

try:
    # 2. Ambil data secara manual (tanpa verifikasi SSL jika perlu)
    response = requests.get(url, headers=headers, verify=False, timeout=30)
    
    if response.status_code == 200:
        # 3. Simpan data sementara ke memory layer QGIS
        # Kita menggunakan prefix 'base64:' atau langsung data mentah
        data_json = response.text
        
        # Load sebagai layer GeoJSON
        vlayer = QgsVectorLayer(data_json, "KUPS - Geoportal KLHK", "ogr")
        
        if vlayer.isValid():
            QgsProject.instance().addMapLayer(vlayer)
            print("Berhasil! Layer KUPS telah ditambahkan ke Map Canvas.")
            
            # Zoom ke layer
            iface.mapCanvas().setExtent(vlayer.extent())
            iface.mapCanvas().refresh()
        else:
            print("Gagal: QGIS tidak dapat mengenali format JSON yang diterima.")
    else:
        print(f"Server merespons dengan status: {response.status_code}")

except Exception as e:
    print(f"Terjadi kesalahan: {str(e)}")

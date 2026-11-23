# ReaperEngine Loader

Roblox için Android loader. Flutter ile yapılmıştır.

## Kurulum

### Gereksinimler
- Android telefon (Suzuki executor yüklü)
- Roblox yüklü
- Root **gerekmez**

### APK Build (GitHub Actions)
1. Bu repoyu GitHub'a push'la
2. Actions sekmesine git → Build ReaperEngine APK
3. Artifact olarak APK indir

### Manuel Build
```bash
flutter pub get
flutter build apk --release
```

## Kullanım

1. Loader'ı aç → `@ReaperEngine` yaz → Giriş Yap
2. **INJECT** butonuna bas (script /sdcard/Suzuki/scripts/ veya /sdcard/Download/ klasörüne yazılır)
3. **OYUNU BAŞLAT** → Roblox açılır
4. Suzuki'yi aç → `ReaperEngine.lua` → Execute
5. Roblox'ta sağ üst köşedeki **☰** butonuna dokun → Menü açılır

## Özellikler

| Kategori | Özellik | Durum |
|---|---|---|
| ESP | Player ESP (Box + Skeleton + Tracer) | ✅ Aktif |
| AimBot | — | 🔒 Yakında |
| Memory | — | 🔒 Yakında |

## Notlar

- `app_launcher.dart` içindeki `_suzukiPackage` değerini Suzuki'nin gerçek package adıyla değiştir
- ESP maksimum mesafe: 300 metre (script içinden değiştirilebilir)
- Tracer: ekranın üst ortasından hedefe yeşil çizgi

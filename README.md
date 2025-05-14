# Ses Yönlendirici

Bu uygulama, macOS sistemlerinde farklı ses giriş cihazlarını farklı ses çıkış cihazlarına yönlendirmenizi sağlayan bir araçtır. Aynı anda birden fazla ses yolunu yönetebilirsiniz.

## Özellikler

- Tüm ses giriş ve çıkış cihazlarını listeler
- Farklı ses giriş cihazlarını farklı çıkış cihazlarına yönlendirme
- Aynı anda birden fazla bağlantıyı yönetme
- Basit ve kullanımı kolay arayüz

## Gereksinimler

- macOS 11.0 veya daha üstü
- Xcode 13.0 veya daha üstü (geliştirme için)

## Kurulum

1. Repo'yu klonlayın:
```bash
git clone https://github.com/kappaborg/ses-yonlendirici.git
cd ses-yonlendirici
```

2. Xcode ile projeyi açın:
```bash
open SesYonlendirici.xcodeproj
```

3. Uygulamayı derleyin ve çalıştırın

## Kullanım

1. Uygulamayı başlatın
2. Sol taraftaki listeden bir giriş cihazı seçin
3. Sağ taraftaki listeden bir çıkış cihazı seçin
4. "Başlat" düğmesine tıklayın
5. Seçilen giriş cihazından gelen ses, seçilen çıkış cihazına yönlendirilecektir
6. Birden fazla ses yolu oluşturmak için adımları tekrarlayın
7. Aktif bağlantıları alt bölümde görebilir ve istediğiniz zaman durdurabilirsiniz

## Önemli Not

macOS, CoreAudio kullanılarak yapılan ses yönlendirmeleri için sistem izinleri isteyebilir. İlk kullanımda mikrofon erişimi için izin vermeniz gerekebilir.

## Teknoloji

Bu uygulama şunları kullanır:
- Swift
- SwiftUI
- CoreAudio
- AVFoundation

## Sorun Giderme

Eğer ses yönlendirme sorunları yaşıyorsanız:

1. Ses cihazlarının sistemde doğru şekilde tanındığından emin olun
2. Uygulamaya mikrofon erişim iznini verdiğinizden emin olun
3. Sistem ses ayarlarını kontrol edin
4. Bazen uygulamayı yeniden başlatmak sorunu çözebilir

## Lisans

MIT 

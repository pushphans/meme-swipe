import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Production Ad Unit IDs (Uncomment for Production, Comment out Test IDs)
  static const String bannerAdUnitIdAndroid =
      'ca-app-pub-2827519271657693/1196646105';
  static const String nativeAdUnitIdAndroid =
      'ca-app-pub-2827519271657693/3133618078';

  // // Test Ad Unit IDs (Comment out for Production, Uncomment Production IDs)
  // static const String bannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111'; // Test Android Banner
  // static const String nativeAdUnitIdAndroid = 'ca-app-pub-3940256099942544/2247696110'; // Test Android Native

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static BannerAd createBannerAd(BannerAdListener listener) {
    return BannerAd(
      adUnitId: bannerAdUnitIdAndroid,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener,
    )..load();
  }

  static void loadNativeAd({required Function(NativeAd) onAdLoaded}) {
    NativeAd(
      adUnitId: nativeAdUnitIdAndroid,
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print('Native ad loaded.');
          onAdLoaded(ad as NativeAd);
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
    ).load();
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract final class AppAds {
  static const Duration finishedScreenLock = Duration(seconds: 5);
  static const AdSize studyBannerSize = AdSize.banner;
  static const AdSize finishedBannerSize = AdSize.mediumRectangle;

  static const String _androidFixedBannerTestUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosFixedBannerTestUnitId =
      'ca-app-pub-3940256099942544/2934735716';

  static const String studyBannerAndroidUnitId = String.fromEnvironment(
    'ADMOB_ANDROID_STUDY_BANNER_UNIT_ID',
    defaultValue: _androidFixedBannerTestUnitId,
  );
  static const String studyBannerIosUnitId = String.fromEnvironment(
    'ADMOB_IOS_STUDY_BANNER_UNIT_ID',
    defaultValue: _iosFixedBannerTestUnitId,
  );
  static const String finishedBannerAndroidUnitId = String.fromEnvironment(
    'ADMOB_ANDROID_FINISHED_BANNER_UNIT_ID',
    defaultValue: _androidFixedBannerTestUnitId,
  );
  static const String finishedBannerIosUnitId = String.fromEnvironment(
    'ADMOB_IOS_FINISHED_BANNER_UNIT_ID',
    defaultValue: _iosFixedBannerTestUnitId,
  );

  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static String get studyBannerUnitId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return studyBannerAndroidUnitId;
      case TargetPlatform.iOS:
        return studyBannerIosUnitId;
      default:
        return '';
    }
  }

  static String get finishedBannerUnitId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return finishedBannerAndroidUnitId;
      case TargetPlatform.iOS:
        return finishedBannerIosUnitId;
      default:
        return '';
    }
  }
}

Future<void> initializeAppAds() async {
  if (!AppAds.isSupportedPlatform) return;
  try {
    await MobileAds.instance.initialize();
  } on MissingPluginException catch (error) {
    debugPrint('Google Mobile Ads no disponible en esta plataforma: $error');
  } catch (error) {
    debugPrint('No se pudo inicializar Google Mobile Ads: $error');
  }
}

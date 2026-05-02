import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:flashcards_app/features/ads/app_ads.dart';

class FixedBannerAdSlot extends StatefulWidget {
  const FixedBannerAdSlot({
    super.key,
    required this.adUnitId,
    required this.size,
    this.loadingLabel,
    this.reserveSpace = true,
  });

  final String adUnitId;
  final AdSize size;
  final String? loadingLabel;
  final bool reserveSpace;

  @override
  State<FixedBannerAdSlot> createState() => _FixedBannerAdSlotState();
}

class _FixedBannerAdSlotState extends State<FixedBannerAdSlot> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void didUpdateWidget(covariant FixedBannerAdSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adUnitId != widget.adUnitId ||
        oldWidget.size != widget.size) {
      _disposeAd();
      _loadAd();
    }
  }

  @override
  void dispose() {
    _disposeAd();
    super.dispose();
  }

  void _loadAd() {
    if (!AppAds.isSupportedPlatform || widget.adUnitId.isEmpty) return;
    final bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      size: widget.size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
        },
      ),
    );
    _bannerAd = bannerAd;
    bannerAd.load();
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!AppAds.isSupportedPlatform || widget.adUnitId.isEmpty) {
      return const SizedBox.shrink();
    }

    final width = widget.size.width.toDouble();
    final height = widget.size.height.toDouble();

    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: width,
        height: height,
        child: AdWidget(ad: _bannerAd!),
      );
    }

    if (!widget.reserveSpace) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Center(
          child: Text(
            widget.loadingLabel ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

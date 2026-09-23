import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/ads_service.dart';

/// Home-screen banner. Hidden gracefully on platforms or when the ad fails.
class BannerAdView extends StatefulWidget {
  const BannerAdView({super.key});

  @override
  State<BannerAdView> createState() => _BannerAdViewState();
}

class _BannerAdViewState extends State<BannerAdView> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final isMobile = Platform.isAndroid || Platform.isIOS;
    if (!isMobile) return;
    AdsService.instance
        .loadBanner(onLoad: (loaded) => setState(() => _loaded = loaded));
  }

  @override
  Widget build(BuildContext context) {
    final ad = AdsService.instance.banner;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: AdWidget(ad: ad),
      ),
    );
  }
}
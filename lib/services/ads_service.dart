import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob ids. Test ids (Google's official sample units) are used by default so
/// the app works before real ad units exist. Swap these with real unit ids
/// before release.
class AdConfig {
  AdConfig._();

  static const bool adsEnabled = true;
  static const String bannerUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String rewardedUnitId = 'ca-app-pub-3940256099942544/5224354917';
}

/// Thin AdMob wrapper. Every ad failure degrades gracefully: the UI simply
/// hides or disables the ad-related affordance, so the core loop never breaks.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  BannerAd? _banner;
  RewardedAd? _rewarded;
  bool _rewardReady = false;

  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
    } catch (_) {}
  }

  /// Kicks off loading a banner. [onLoad] fires with readiness.
  void loadBanner({required void Function(bool loaded) onLoad}) {
    if (!AdConfig.adsEnabled) {
      onLoad(false);
      return;
    }
    final ad = BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _banner = ad as BannerAd;
          onLoad(true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onLoad(false);
        },
      ),
    );
    ad.load();
  }

  BannerAd? get banner => _banner;

  /// Loads a rewarded ad ahead of time.
  Future<void> preloadRewarded() async {
    if (!AdConfig.adsEnabled) return;
    try {
      await RewardedAd.load(
        adUnitId: AdConfig.rewardedUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewarded = ad;
            _rewardReady = true;
          },
          onAdFailedToLoad: (error) {
            _rewardReady = false;
          },
        ),
      );
    } catch (_) {
      _rewardReady = false;
    }
  }

  bool get isRewardedReady => _rewardReady;

  /// Shows the rewarded ad. [onReward] fires if the user watches to the end
  /// and the ad succeeds; otherwise nothing happens (graceful fallback).
  Future<void> showRewarded({
    required void Function() onReward,
    required void Function() onDismissed,
  }) async {
    final ad = _rewarded;
    if (ad == null || !_rewardReady) {
      onDismissed();
      return;
    }
    _rewarded = null;
    _rewardReady = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        onDismissed();
      },
    );
    try {
      await ad.show(onUserEarnedReward: (ad, reward) => onReward());
    } catch (_) {
      onDismissed();
    }
  }
}
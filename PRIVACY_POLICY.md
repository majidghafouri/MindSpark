# NeverMindSpark — Privacy Policy

**Effective date:** September 2025  
**Last updated:** September 2025

---

## 1. Overview

NeverMindSpark ("the App") is a daily brain-training game developed by NeverMindSpark. This policy explains what data we collect, how it is used, and your choices.

We do **not** sell personal data. We do **not** collect your name, email, contacts, location, or any personally identifiable information.

---

## 2. Data We Collect

### 2.1 AdMob (Google Mobile Ads SDK)

The App uses **Google AdMob** to show a small banner ad on the results screen and an optional rewarded ad (watch a short video to earn a small bonus). AdMob may collect:

- **Device identifiers** (Android Advertising ID / AAID)
- **Ad interaction data** (impressions, clicks, reward completions)
- **IP address** (for fraud prevention and geolocation to serve relevant ads)
- **App usage data** (which screens you visit, session length — only as needed for ad delivery)

This data is collected by **Google**, not by us. We have no access to it. See [Google's Privacy Policy](https://policies.google.com/privacy) and [AdMob Data Processing Terms](https://developers.google.com/admob/android/data-processing-terms).

### 2.2 Local Game Progress (stored only on your device)

- Daily challenge results (scores, correct/wrong answers)
- Streak counters (current & longest)
- Badge unlocks
- Coin balance and power-up usage
- Level progress (adventure mode)
- Notification preference (on/off, time)

**This data never leaves your device** unless you explicitly use the "Export backup" feature (which creates a JSON file you can share). We do not operate a backend and do not sync your progress to any server.

---

## 3. How We Use Data

| Data | Purpose |
|------|---------|
| AdMob data | Serve personalized or contextual ads, prevent fraud, measure ad performance |
| Local progress | Provide gameplay features (streaks, badges, levels, coins, stats) |
| Notification time | Schedule the optional daily reminder (only if you enable it) |

---

## 4. Third-Party Services

| Service | Purpose | Data Shared |
|---------|---------|-------------|
| **Google AdMob** | Ad serving | Advertising ID, IP, ad events |
| **Google Play Services** | Ads, notifications | Standard Play Services identifiers |

No other third parties receive your data.

---

## 5. Your Choices

- **Opt out of personalized ads**: Android Settings → Google → Ads → "Opt out of Ads Personalization"
- **Disable ads entirely**: The App has no paid tier; ads are the only revenue source. You can disable the rewarded-ad bonus by simply not tapping it.
- **Disable daily reminder**: Settings → "Remind me to play" → Off
- **Delete all local data**: Uninstall the App (Android clears all app-private storage)
- **Export / import backup**: Settings → "Export backup" / "Import backup" (you control the JSON file)

---

## 6. Children's Privacy

The App is not directed at children under 13. We do not knowingly collect personal data from children. If you believe a child has provided data, contact us and we will delete it.

---

## 7. Data Retention

- **AdMob data**: Retained by Google per [Google's data retention policies](https://policies.google.com/technologies/retention).
- **Local progress**: Stored on your device until you uninstall the App or clear its data.

---

## 8. Security

All local data is stored in your app-private sandbox (Hive/JSON), accessible only by the App. Network traffic for ads uses HTTPS.

---

## 9. Changes to This Policy

We may update this policy for legal or feature changes. The "Last updated" date at the top will reflect the latest revision.

---

## 10. Contact

Questions about this policy? Open an issue at:  
https://github.com/majidghafouri/NeverMindSpark/issues

---

## Data Safety Form (Google Play Console) — Cheat Sheet

When filling out **App content → Data safety**, use this mapping:

| Data Type | Collected? | Purpose | Shared? | Ephemeral? |
|-----------|------------|---------|---------|------------|
| **Device or other IDs** (Advertising ID) | Yes (via AdMob) | Advertising / marketing | Yes (Google) | No |
| **App activity** (ad impressions, clicks) | Yes (via AdMob) | Advertising / marketing | Yes (Google) | No |
| **App info and performance** (crash logs, diagnostics) | No | — | — | — |
| **Personal info** (name, email, etc.) | **No** | — | — | — |
| **Location** (precise/approx) | **No** (AdMob may infer coarse geo from IP) | — | — | — |
| **Photos / videos / audio** | **No** | — | — | — |
| **Files and docs** | **No** | — | — | — |

**Encryption in transit:** Yes (HTTPS for ad requests)  
**Data deletion:** Users can request deletion by uninstalling the app (local data) or via Google's Ads Settings (ad data).

**Privacy policy URL** (enter in Play Console):  
`https://majidghafouri.github.io/NeverMindSpark/PRIVACY_POLICY.html` (after enabling GitHub Pages)
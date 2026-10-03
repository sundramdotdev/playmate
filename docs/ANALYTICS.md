# Analytics & Telemetry Catalog

This document defines the complete catalog of analytics events tracked within **PlayMate**.

---

## 🔒 Privacy & Data Minimization Principles

1. **Zero Personally Identifiable Information (PII):** PlayMate **never** tracks names of players entered in teams, match titles, device phone numbers, precise GPS locations, or IP addresses.
2. **Aggregated Functional Metrics Only:** Telemetry is gathered exclusively to evaluate feature engagement, game balancing, and application stability.
3. **Local Queuing & Opt-Out:** In full offline mode, analytics events remain dormant. Users can opt out of telemetry entirely via the Settings screen.

---

## 📊 Analytics Event Taxonomy

The following table provides the comprehensive catalog of all events dispatched through `AnalyticsService`:

| Event Name | Trigger Condition | Parameters | Analytical Purpose |
| :--- | :--- | :--- | :--- |
| `app_open` | User launches or resumes the application into foreground. | `theme`: `"light"` \| `"dark"`<br>`platform`: `"android"` \| `"ios"` | Measure Daily Active Users (DAU) and platform split. |
| `dice_roll` | User taps "Roll" or shakes device to roll dice. | `count`: `int` (1–6)<br>`type`: `string` (`"d4"`, `"d6"`, `"d8"`, `"d10"`, `"d12"`, `"d20"`)<br>`is_shake`: `bool` | Understand which polyhedral dice types and interaction modes are most popular. |
| `coin_toss` | User flips single or multiple coins. | `result`: `string` (`"heads"` \| `"tails"`)<br>`coin_count`: `int` (1–3) | Track feature usage and verify uniform distribution across hardware devices. |
| `team_generated` | User completes team generation roster split. | `teams`: `int` (2–8)<br>`players`: `int` (2–64)<br>`mode`: `"random"` \| `"balanced"` | Quantify typical squad sizes for athletic/party game optimization. |
| `score_updated` | User increments, decrements, or edits a player score. | `delta`: `int`<br>`player_count`: `int`<br>`game_type`: `string` | Measure session length and interaction frequency during board games. |
| `cricket_match_created`| User starts a new cricket scorecard. | `total_overs`: `int`<br>`is_limited_overs`: `bool` | Measure adoption of the sports scoring feature. |
| `cricket_ball_scored` | User records a delivery on the cricket keypad. | `outcome`: `"dot"` \| `"run"` \| `"boundary"` \| `"wicket"` \| `"wide"` \| `"no_ball"` | Evaluate scoring flow ergonomics and fast-action button accuracy. |
| `spin_wheel_used` | User spins the custom decision wheel. | `slice_count`: `int`<br>`elimination_mode`: `bool` | Understand usage patterns for custom prize/decision picking. |
| `tournament_created` | User generates an elimination bracket. | `teams`: `int` (4, 8, 16, 32)<br>`bracket_type`: `"single_elim"` \| `"double_elim"` | Track tournament organizer adoption and bracket size requirements. |
| `timer_started` | User initiates any timer mode. | `type`: `"stopwatch"` \| `"countdown"` \| `"chess"` \| `"turn"`<br>`duration_sec`: `int` | Determine popularity of various clock modes (e.g., chess vs. board game turns). |
| `achievement_unlocked`| User triggers an in-app milestone or Easter egg. | `id`: `string` (e.g. `"hundredth_roll"`, `"marathon_match"`) | Track player retention, delight, and gamification engagement. |
| `theme_changed` | User toggles between Dark Mode and Light Mode. | `mode`: `"light"` \| `"dark"` | Gauge theme preferences to guide UI/UX palette investments. |
| `data_cleared` | User triggers a local storage reset in Settings. | `reason`: `"user_initiated"` | Monitor data wipe frequencies and verify confirmation sheet efficacy. |

---

## 🛠️ Code Implementation Example

Events are invoked via the centralized static `AnalyticsService` in `lib/services/firebase_service.dart`:

```dart
class AnalyticsService {
  static void logEvent(String name, [Map<String, dynamic>? parameters]) {
    // 1. Output to local debug console in debug mode
    debugPrint("Analytics: $name | Params: $parameters");

    // 2. Dispatch to Firebase Analytics if initialized
    if (!kDebugMode) {
      FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
    }
  }

  static void trackDiceRolled(int count, String diceType, {bool isShake = false}) {
    logEvent('dice_roll', {
      'count': count,
      'type': diceType,
      'is_shake': isShake,
    });
  }

  static void trackCricketMatchCreated({required int totalOvers}) {
    logEvent('cricket_match_created', {'total_overs': totalOvers});
  }
}
```

---

## 📈 Dashboard Funnels & KPIs

The events above populate the following primary product funnels in Google Analytics for Firebase:
1. **Utility Discovery Funnel:** `app_open` $\rightarrow$ Utility Selection (e.g., `dice_roll` / `cricket_match_created`) $\rightarrow$ Repeated interaction.
2. **Game Completion Funnel:** `tournament_created` $\rightarrow$ Match Round Updates $\rightarrow$ Tournament Champion Declared.
3. **Session Retention Rate:** Frequency of weekly return sessions during typical weekend gaming hours (Friday evening – Sunday night).

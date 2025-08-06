# Remote Config Platform (iOS) — LLD (Firebase RC Hybrid, **Personal Project Lean**)

**Doc ID:** RC-IOS-LLD-002-LEAN  
**Owner:** Raul Flores  
**Status:** Personal build spec (non-production)  
**Last Updated:** 2025-08-04

---

## 1) Summary

Personal project to build an **offline-first OTA configuration** system for iOS using **Firebase Remote Config (RC)**. After **login**, the app fetches context-targeted values (by `partner_id`, `plan_tier`, `region` expressed as a single user property) and applies them to **feature flags, theming, and strings**. Client falls back to **Last-Known-Good (LKG)** when offline or on validation failure. This is a **lean** version—no multi-env pipelines, no staged rollouts, no signed payloads.

**Use cases**
- White-label theming per partner/plan for demo.  
- Quickly flip flags/copy **without** App Store releases.  
- Works when users are offline for long periods (rural-friendly).

---

## 2) Scope (What’s in / out)

**In scope (for portfolio/demo)**
- Firebase RC params, conditions, and fetch policy.  
- Context at login via app-set user property.  
- LKG cache on device; validation; kill-switch.  
- Simple metrics/logging via Firebase Analytics (optional).  
- 1–2 diagrams (sequence + simple components).

**Out of scope (for this personal build)**
- Separate config-registry repo & CI pipelines.  
- Multi-environment promotion and staged rollouts.  
- Signed payloads / pinning.  
- Formal SLO dashboards, alerting, on-call runbooks.  
- Canary programs and complex numeric merge strategies.

---

## 3) Assumptions & Constraints

- iOS **16+**, Swift **5.9+** (SwiftUI or UIKit).  
- Context is known **at login**: `{ partner_id, plan_tier, region }`.  
- No PII in config.  
- Firebase RC handles caching; app controls **timeout** and **minFetchInterval**.

---

## 4) Requirements

### 4.1 Functional
1. On login, set a user property that encodes partner/plan (see §6).  
2. Call `fetchAndActivate()`; on success, **validate** and **activate**.  
3. If validation fails or offline, render **LKG** (or bundled defaults).  
4. **Theme policy:** **Top tier wins** (Business > Personal).  
5. **Feature policy:** Union across contexts *(or single context if union is not needed for the demo)*.  
6. Provide simple lookups: `getFlag`, `getString`, `getInt`.  
7. **Kill-switch:** when true, force safe defaults.

### 4.2 Non-Functional (lean)
- **TTL:** 24h in prod build; 0 in debug.  
- **Timeout:** 2s; retries handled by RC SDK.  
- Keep payload small (a few KB).

---

## 5) Architecture (Lean)

**Components**
- **iOS App** with `RemoteConfigKit` (fetch, validate, LKG, policy).  
- **Firebase RC** (single project) for parameters & conditions.  
- **Auth** (mock/login screen) that determines partner/plan and sets the user property.

**Trust**
- App ↔ Firebase RC via TLS. No signed payloads in this build.

---

## 6) Data Contracts (Firebase RC)

### 6.1 User Property (set by app at login)
- **`provider_plan_type`** ∈ { `auralink_personal`, `auralink_business`, `zenithsat_personal`, `zenithsat_business` }

### 6.2 Conditions (Remote Config Console)
- `auralinkPersonal`  → `app.userProperty['provider_plan_type'].exactlyMatches(['auralink_personal'])`  
- `auralinkBusiness`  → `…exactlyMatches(['auralink_business'])`  
- `zenithsatPersonal` → `…exactlyMatches(['zenithsat_personal'])`  
- `zenithsatBusiness` → `…exactlyMatches(['zenithsat_business'])`

### 6.3 Parameters
- `plan_feature_list` (**JSON array** of strings)  
- `plan_priority_support` (**BOOLEAN**)  
- `plan_displayName` (**STRING**)  
- `plan_data_limit` (**NUMBER**)  
- `plan_themeColor` (**STRING**, hex `#RRGGBB`)  
- `meta_config_version` (**STRING**, e.g., ISO timestamp)  
- `meta_ttl_seconds` (**NUMBER**, default `86400`)  
- `kill_switch` (**BOOLEAN**, default `false`)

### 6.4 Client Validation (on device)
- Type checks; color regex; string length limits.  
- Unknown keys ignored (count metric).  
- On failure → reject payload, **keep LKG**.

---

## 7) Client API (Swift, minimal)

```swift
public enum RCError: Error { case network, schema, timeout, stale }

public protocol RemoteConfig {
    func start()  // load bundled defaults or LKG
    func setContext(partnerId: String, planTier: String, region: String, contextVersion: String)
    func fetchAndActivate(force: Bool, _ completion: @escaping (Result<Void,RCError>) -> Void)

    func getFlag(_ key: String, default def: Bool) -> Bool
    func getInt(_ key: String, default def: Int) -> Int
    func getString(_ key: String, default def: String) -> String

    var isKillSwitchOn: Bool { get }
    var lastUpdated: Date? { get }
}
```

**Fetch policy (Firebase RC)**  
- `fetchTimeoutInSeconds = 2`  
- `minimumFetchIntervalInSeconds = 86400` (prod), `0` (debug)

**Policies**  
- **Theme:** choose visuals from highest tier (Business > Personal).  
- **Features:** union *(or single context for demo)*.  
- **Limits:** keep simple; constants per plan are fine.

---

## 8) Sequences

### 8.1 Login → Fetch → Activate (Happy path)
1. `start()` → load defaults/LKG.  
2. User logs in → app sets `provider_plan_type`.  
3. `fetchAndActivate()` → validate → apply theme/features → **write LKG**.

### 8.2 Offline or Validation Failure
1. `fetchAndActivate()` errors or invalid values → keep **LKG**.  
2. UI remains usable; log `stale_config=1` if TTL expired.

---

## 9) Error Handling (Lean)

- **Validation failure** → reject, keep LKG, log `schema_errors+=1`.  
- **TTL expired + fetch fail** → keep LKG, log `stale_config=1`.  
- **Unknown context** → show defaults/LKG and continue.  
- **Kill-switch** → safe defaults only.

---

## 10) Observability (Optional, minimal)

- Log events (Firebase Analytics):  
  `rc_activation_success`, `rc_fetch_latency_ms`, `rc_stale_config`, `rc_schema_validation_errors`, `rc_killswitch_active`.  
- No dashboards/alerts in this build.

---

## 11) Delivery (Manual)

- Edit values in **Firebase RC Console**, or import a prepared JSON template.  
- Bump `meta_config_version` for traceability.  
- Publish; app picks up on next login or when TTL expires (or via debug fetch).  
- Single environment/project is fine.

---

## 12) Security & Privacy (Lean)

- TLS via RC SDK.  
- LKG encrypted at rest; file HMAC for integrity (optional but recommended).  
- No PII in config.

---

## 13) Testing (Minimal checklist)

- Partner/plan switch updates theme and strings.  
- Bad hex color → payload rejected, LKG used.  
- Offline with TTL expired → still renders via LKG.  
- Flip `kill_switch` → safe defaults applied.  
- (Optional) Unit tests for theme priority, union features, LKG fallback.

---

## 14) Two-Week Plan (Lean)

**Week 1**  
- D1: Finalize spec; set RC params/conditions in Console.  
- D2: Implement `RemoteConfigKit` skeleton (fetch, activation, lookups).  
- D3: Add simple validation + LKG store; hook login → set user property.  
- D4: Theme/feature policy application; debug toggle to force fetch.  
- D5: Basic tests; write short README/demo script.

**Week 2**  
- D6: Error paths (validation reject, stale); polish.  
- D7: Debug screen (show config/version/TTL; override partner/plan).  
- D8: Offline testing; edge cases; small performance checks.  
- D9: Record demo video/GIF; finalize docs.  
- D10: Buffer & cleanup.

---

## 15) Diagrams (2 total)

1. **Sequence:** Login → Fetch → Validate → Activate → LKG write.  
2. **Components:** App (`RemoteConfigKit`) ↔ Firebase RC ↔ (mock) Auth.

---

## 16) Appendix

### 16.1 Firebase Parameters (for reference)
- `plan_feature_list`, `plan_priority_support`, `plan_displayName`, `plan_data_limit`, `plan_themeColor`, `meta_config_version`, `meta_ttl_seconds`, `kill_switch`.

### 16.2 Demo Script
1. Launch → login as PartnerA-Personal → Personal theme appears.  
2. Switch to PartnerA-Business → Business visuals; features expanded.  
3. Change `plan_themeColor` in RC → Publish → reopen app (or force fetch) → color updates.  
4. Turn on `kill_switch` → safe defaults.  
5. Go offline; force fetch → LKG keeps UI stable.
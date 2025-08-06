# ConfigHub (iOS)

**Offline‑first OTA remote configuration with Firebase Remote Config.**

> Lean, demo‑ready implementation: Business > Personal theme precedence, union of features across contexts, kill‑switch, Last‑Known‑Good (LKG) cache, stale detection, and a built‑in Debug panel.

---

## Table of contents

- [What this is](#what-this-is)
- [Key decisions](#key-decisions)
- [How it works](#how-it-works)
- [Screens & demo flow](#screens--demo-flow)
- [Project structure](#project-structure)
- [Setup](#setup)
- [Remote Config parameters](#remote-config-parameters)
- [Config‑as‑Data tooling](#config-as-data-tooling)
- [Development notes](#development-notes)
- [LLD](#lld)

---

## What this is

ConfigHub is a SwiftUI sample that shows how to ship **server‑driven UI** safely:

- Fetch configuration from **Firebase Remote Config** (RC)
- Apply **partner/tier targeting** via a user property (`provider_plan_type`)
- Resolve **theme + features** with **Business > Personal** precedence and **union** of features
- **Never brick the UI offline**: load a **Last‑Known‑Good** config from disk
- **Operate safely**: global **kill‑switch**, minimal analytics, and a **Debug panel**

> This repo is designed as a personal portfolio project (no auth, no backend write paths).

---

## Key decisions

- **Author as code, serve as data**: keep human‑edited JSON in `config/` and validate it before publishing.
- **Targeting**: client sets `provider_plan_type` (e.g., `auralink_business`), RC evaluates conditions server‑side.
- **Precedence**: when the app loads two contexts (optional dev toggle), **Business** controls the theme; features are the **union** across contexts.
- **Offline**: on successful activate, write a small rendered config to disk (LKG). If a future fetch fails or schema is invalid, show the **LKG**.
- **Operations**: TTL (24h Release / 0s Debug), kill‑switch, basic metrics.

---

## How it works

1. App starts → loads **LKG** (if any) to paint UI instantly.
2. Debug (or app) selects a **context** (e.g., `auralink_business`).
3. App sets **Analytics user property** `provider_plan_type` to that value.
4. Calls `fetchAndActivate()` → RC resolves parameters for that context.
5. ViewModel builds the final UI config:
   - if **kill\_switch**: enter **Limited mode** (safe defaults, no navigation)
   - else: apply **theme** (Business if present), union **features**, show data limits, etc.
6. Persist the rendered config to **LKG** and compute **stale** based on TTL vs file timestamp.

---

## Screens & demo flow

> 1–2 minute demo

1. **Dashboard** (tab 1)
   - Shows plan chip (name, data limit, priority support)
   - Feature list (rows navigate to detail screens)
2. **Debug panel** (wrench button, Debug builds only)
   - Pick context (e.g., `auralink_business`)
   - *Optional*: toggle “Load both tiers for this partner” to simulate union
   - Buttons: **Fetch Now**, **Reset LKG**
   - Info: `meta_config_version`, Limited Mode flag, Stale flag, TTL remaining
3. **Limited Mode**
   - Flip **kill\_switch** in RC → Publish → Fetch Now → banner appears, feature rows disabled

<p>
  <img src="https://media.giphy.com/media/QH2FmKpvUxkQBMkAja/giphy.gif" width="220" height="480" alt="Demo clip 1" />
  <img src="https://media.giphy.com/media/gkhjWfVOOVIEBcrrOU/giphy.gif" width="220" height="480" alt="Demo clip 2" />
</p>




---

## Project structure

```
/
├─ ConfigHub/                 # Xcode app code (SwiftUI, ViewModel, helpers)
├─ config/                    # Config‑as‑Data: schema + example payloads
│  ├─ config.schema.json
│  ├─ rc.dev.json
│  └─ rc.prod.json            # optional
├─ scripts/                   # Local tooling (not shipped in app)
│  └─ rc_lint.py
├─ ConfigHubTests/            # Unit tests (policy, LKG, etc.)
├─ LLD.md                     # Detailed Low‑Level Design
└─ README.md                  # This file
```

---

## Setup

1. **Clone** the repo and open `ConfigHub.xcodeproj` in Xcode 15+.
2. **Firebase**: create a project, add an iOS app, download `GoogleService-Info.plist`.
   - Put it at `ConfigHub/GoogleService-Info.plist`.
   - This file is **git‑ignored**. Commit a `GoogleService-Info.sample.plist` if you want others to run it.
3. **Analytics user property**
   - In Firebase Console → Analytics → Custom definitions → **User properties** → create `provider_plan_type`.
4. **Remote Config parameters** (see table below)
   - Create the parameters and add **conditions** that key off **User Property** `provider_plan_type` values (e.g., `auralink_personal`, `auralink_business`, etc.).
5. **Build**
   - Run in **Debug** first (RC `minimumFetchInterval = 0`) so switching contexts refetches immediately.
   - Tap the **wrench** to open the Debug panel.

---

## Remote Config parameters

| Key                     | Type                | Example                                      | Notes                                                     |
| ----------------------- | ------------------- | -------------------------------------------- | --------------------------------------------------------- |
| `plan_displayName`      | string              | `AURALINK BUSINESS`                          | Shown in dashboard header                                 |
| `plan_themeColor`       | string              | `#2C3E50`                                    | Hex color (`#RRGGBB`)                                     |
| `plan_data_limit`       | int                 | `750`                                        | In GB                                                     |
| `plan_priority_support` | bool                | `true`                                       | Enables “Priority Support” chip                           |
| `plan_feature_list`     | string (JSON array) | `["billing_portal", "view_data_usage", ...]` | Parsed into a type‑safe `Feature` enum (unknowns ignored) |
| `kill_switch`           | bool                | `false`                                      | Enables **Limited Mode** (rows disabled)                  |
| `meta_config_version`   | string              | `2025-08-06T20:15:00Z`                       | Displayed in Debug; bumped by linter                      |
| `meta_ttl_seconds`      | int                 | `86400`                                      | Used for stale detection                                  |

> **No combo conditions in RC.** If you want to simulate combined plans, use the Debug toggle; the client will fetch both contexts, apply **Business theme**, and union the **features**.

---

## Config‑as‑Data tooling

Keep your human‑edited payloads in `config/` and validate before publishing.

**Schema:** `config/config.schema.json`

**Linter / bumper:** `scripts/rc_lint.py`

```bash
# validate
python3 scripts/rc_lint.py config/rc.dev.json --schema config/config.schema.json

# validate + bump version + write back
python3 scripts/rc_lint.py config/rc.dev.json --schema config/config.schema.json --bump --write
```

The script checks required keys, enums, hex format, and (optional) gzipped size limit; it can also bump `meta_config_version` to the current ISO timestamp.

---

## Development notes

- **Remote Config fetch policy**: `fetchTimeout = 2s`; `minimumFetchInterval = 86400 (Release) / 0 (Debug)`.
- **Theme readability**: Dashboard uses a **subtle tint** over system background; rows are solid system cards with semantic text colors.
- **LKG**: Stored at `Application Support/ConfigHub/remote_config_lkg.json`. Use **Reset LKG** in the Debug panel during demos.
- **Limited Mode**: When `kill_switch` is true (for any fetched context), navigation to features is disabled and rows are dimmed.
- **Tests**: Pure helpers in `ConfigPolicy` (theme precedence + union). Add small tests for `LKGStore` and `Color(hex:)` if desired.
- **Analytics events**: `rc_fetch_latency_ms`, `rc_activation_success`, `rc_killswitch_active`.
- **Security**: Restrict your Firebase API key to your iOS bundle ID. *Note:* LKG is **not encrypted or signed** in this personal build; consider File Protection (complete) and/or an HMAC in a future phase.

---

## LLD

See [**LLD.md**](./LLD.md) for the complete low‑level design (context rules, precedence, caching, observability, and delivery process).


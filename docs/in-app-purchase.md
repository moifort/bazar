# In-App Purchase — Bazar Premium

How the subscription works, end to end: what is sold, what is metered, who decides, and why the
numbers are what they are. The portable rules about quotas and entitlements are not split out —
this is entirely this product's wiring.

## What is sold

| | Free | Premium |
| --- | --- | --- |
| Items, locations, reminders, notifications | unlimited | unlimited |
| AI photo scans | **10 per calendar month** | no monthly allowance |
| Price | — | **1,99 €/month** or **19,99 €/year** (7-day free trial on the yearly) |

Products, identical in App Store Connect, in `ios/Bazar/Bazar.storekit` and in
`SubscriptionProducts.swift` — a typo in any of the three makes the product fail to load, silently:

- `co.polyforms.bazar.premium.monthly`
- `co.polyforms.bazar.premium.yearly`

**Premium is sold as "scannez sans compter", and the app shows no counter for it.** There *is* a
ceiling — 4000 scans over the last 12 months — but it is anti-abuse plumbing, not a plan limit: a
household inventory does not come near it, and a script driving thousands of scans a month is not
one. Never surface it, and never use the word *illimité* in the copy: the ceiling exists, so the
word would be a lie.

## Why these numbers

The only variable cost is the Gemini call behind a scan: roughly **0,25 centime per scan** at
2.5 Flash's pricing for one 800px photo plus its JSON answer. Everything else is flat — the
Apple Developer Program at **99 $/year (~8 €/month)** and a Cloud Function that sits in the free
tier at this scale.

That shapes the whole model:

- **Ten free scans a month cost about 2,5 centimes.** Free users are not what costs money; they
  are what makes the app worth opening. The free tier is generous on purpose — a household
  inventory nobody can fill is worth nothing.
- **A monthly subscriber at 1,99 € pays for ~800 scans.** Nobody photographs their home 800 times
  a month, so a subscriber is comfortably profitable, and the 4000-over-12-months ceiling is set
  where only automated abuse lands (~10 €/year of AI, still under a yearly subscription).
- **The yearly at 19,99 € is 16 % off** the monthly run rate, which is what the "Économisez 16 %"
  badge says. The 7-day trial is on the yearly only: it is the offer put forward.

## The server decides, always

The app never grants Premium to itself. StoreKit hands the app a **signed transaction**; the app
posts it to `syncEntitlement`; the server verifies Apple's signature against the embedded root
certificates (`server/system/apple/`) and only then records the entitlement.

Two checks stand between a claim and Premium:

1. **The signature.** Verified against Production *and* Sandbox unless `NITRO_APPLE_ENVIRONMENT`
   pins one — a shipped app receives both (TestFlight and App Review sign in Sandbox). Set it to
   `Xcode` locally, where the `.storekit` file signs with a throwaway certificate that cannot
   chain to Apple's roots.
2. **The account token.** Every purchase carries an `appAccountToken`, a **version-5 UUID derived
   from the Firebase uid** (`server/domain/entitlement/business-rules.ts`). Derived, never stored:
   no write, and the same value before and after a reinstall. It is what stops a signed
   transaction from being replayed onto another account — a purchase made for someone else simply
   does not match.

**The derivation is frozen.** Its namespace and algorithm are pinned by a tripwire test
(`business-rules.unit.test.ts`, the `dev-user` vector). Changing either silently detaches every
subscription already sold from its owner.

`POST /apple/notifications` is the other way in: Apple pushes renewals, expiries and refunds
there without waiting for the app to open. Unauthenticated by design — the proof of origin is the
signature on the payload. The plan is re-derived from the transaction's own dates, never from the
event name, so there is one code path whatever Apple calls the event. A notification for a token
we have never recorded is acknowledged and dropped: the derivation is one-way, so there is nobody
to attach it to until the app syncs the purchase itself.

## The metering

`server/domain/quota/` counts scans, one document per user and per month
(`scan-quotas/{userId}_{YYYY-MM}`), keyed deterministically so a month is read by key and last
month's document is simply never read again — no purge, no scheduled job.

- The month is **UTC**, so the window does not move with the caller's timezone.
- The allowance is checked **before** the AI is called (a refusal must cost nothing) and the scan
  is recorded **after** it answered (a Gemini failure is not a scan the user spent).
- The increment runs in a **transaction**: two scans finishing together must count two.
- A free check costs **one** read; the Premium ceiling costs **twelve keyed reads** and only
  happens for subscribers.

`ScanUseCase.analyze` is the single enforcement point, and `analyzeItemPhoto` is the only metered
mutation. A refusal comes back as `QUOTA_EXHAUSTED`.

## The app side

- `Features/Subscription/` — `SubscriptionStore` (StoreKit 2: products, purchase, restore, and the
  `Transaction.updates` listener that must live as long as the app), `PremiumSheet` (prices from
  the App Store, never hard-coded — they differ by storefront and Apple raises them without asking).
- `Features/Quota/` — `QuotaSection`, the gauge, **shown on the free plan only**.
- A refused scan opens the Premium sheet rather than an alert: the user asked for something the
  plan does not cover, and the offer is the answer to that.
- "Restaurer mes achats" exists because Apple requires it, and because a subscription bought on
  another device has to be recoverable.
- If Apple takes the money and our own server will not grant the Premium, the sheet says so. The
  one thing that must never happen is a user who paid and sees nothing.

Comped accounts (the maker's own, a reviewer's) go in `NITRO_PREMIUM_USER_IDS` — an override on
top of the App Store entitlement, never a substitute for it.

## Deleting an account does not cancel a subscription

Only the subscriber can, from the App Store settings. Erasing the entitlement stops the app
believing in it; it does not stop the billing. See
[business-rules.md](./business-rules.md#deleting-an-account-erases-everything-in-one-direction).

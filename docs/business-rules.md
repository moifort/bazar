# Business Rules — The Product Model

What Bazar *is*, as a model. Read this before touching `item`, `location`, `reminder` or the AI
prompts. The code that carries these rules lives in each domain's `business-rules.ts` and in the
commands; where those files sit is [architecture.md](./architecture.md).

Bazar is a household inventory: the user photographs their stuff, the AI names it, and the app
remembers **what** they own, **where** it is, **how much** is left and **when** it needs
attention.

## The location hierarchy is exactly four levels

`place > room > zone > storage` — a building, a room in it, an area of that room, the furniture
inside it. The chain is strict and each level points at its parent (`Room.placeId`,
`Zone.roomId`, `Storage.zoneId`). There is no fifth level and no shortcut: a zone always belongs
to a room, never directly to a place.

- **Siblings are user-ordered.** Every level carries an `order`; a new sibling lands last
  (`nextOrder` = max + 1), and reordering rewrites `order`, never the ids.
- **Deleting cascades downward.** Deleting a place deletes its rooms, hence their zones, hence
  their storages. Nothing is orphaned, and nothing cascades *upward*.
- **The path is derived, never stored.** `fullPath` (`"Appartement > Cuisine > Placard > Étagère
  2"`) is recomputed from the four names at read time — renaming a room instantly renames every
  path that runs through it.

## An item is attached to a storage, or to a zone — never both

The attachment is where the object physically sits. The user may be precise (a storage) or vague
(a zone, when the thing is "somewhere in the garage"), and an item may be attached to nothing at
all — just created, not yet put away.

- Providing both `storageId` and `zoneId` is the sentinel `'invalid-location'`; the schema cannot
  express "exactly one of", so the command does.
- Pointing at something that doesn't exist (or belongs to someone else) is
  `'location-not-found'`.
- **`placeId` is denormalised at attach time.** It is derived by walking up from the attachment,
  and rewritten on every `move` — it exists so that "everything in this place" stays a single
  query, and it is never edited on its own.

## Quantity, low stock, and the crossing

An item has a `quantity` (a positive integer) and optionally a `lowStockThreshold`. No threshold
means the user never wants to hear about this item.

- Low stock is `quantity <= lowStockThreshold` — *at or below*, not strictly below.
- What triggers a push is not *being* low, it is **crossing** into low: the item was not low
  before the update and is low after. Re-saving an already-low item stays silent, so a user
  editing a description at 1-left doesn't get notified again.
- Lowering the threshold below the current quantity un-arms the alert; the next crossing will
  fire again.
- The crossing is published as an event (`low-stock-crossed`) — `item` never calls
  `notification`. See [architecture.md](./architecture.md#domain-events).

## A scan produces previews, not items

Photographing is not owning. The AI (Gemini 2.5 Flash vision) returns a batch of **previews** —
name, guessed category, description, quantity — identified by a `previewId`, and **nothing is
persisted at that point**. The user reviews the batch, edits what the AI got wrong, and
**confirms**; only then are items created, all at once, in one place.

- A preview whose category the AI couldn't guess arrives without one — the user picks it; the
  fallback is `other`, never a silent wrong category.
- A refused batch leaves no trace. There is no "draft item" state in the model.
- One photo can yield several items: batch detection is the point, not an edge case.

## A reminder is dated, attached to an item, and either recurring or one-shot

A reminder ("change the water filter") lives on an item and carries a `dueDate`.

- **Frequency drives the lifecycle.** `monthly`, `quarterly`, `biannual`, `annual` and
  `custom-days` are recurring; an **absent** frequency means one-shot.
- `custom-days` — and only `custom-days` — carries `customIntervalDays`. Any other combination
  (an interval without `custom-days`, `custom-days` without an interval) is a rejected input,
  not a stored inconsistency.
- **Completing is the only way forward.** A recurring reminder is *rescheduled* to its next due
  date and its completion is recorded; a one-shot reminder is *finished* — the completion is kept,
  the reminder is deleted.
- The next due date is computed from **the later of** the current due date and the completion
  date: completing a reminder three weeks late doesn't schedule the next one in the past.
- Month arithmetic clamps to the end of the month: a monthly reminder due on the 31st falls on the
  30th, the 28th, then back on the 31st — it never drifts into the following month.
- **Deleting an item deletes its reminders.** A reminder without its item is meaningless, so the
  deletion is orchestrated in `item/use-case.ts`.

## Search and the dashboard derive, they never store

Both are read-only views assembled from the other domains at read time — there is no stored
projection to fall out of sync.

- **Search** is fuzzy and accent-insensitive across items, places and rooms, ranked by how the
  match happened: exact (100), prefix (80), word prefix (60), substring (40), near-miss within
  edit distance 2 (20). Anything scoring zero is not a result.
- **The dashboard** answers "how much do I own, of what, and where": total, breakdown by
  category and by place (both sorted by count, descending), the most recent items, and the
  currently low-stock ones (sorted by name).

## Deleting an account erases everything, in one direction

`deleteAccount` is irreversible and immediate: no grace period, no scheduled job, no soft delete
to reason about. Each domain forgets its own documents — items, the four location levels,
reminders with their completion history, the registered devices — and none of them knows about
the others; `server/system/account/` orchestrates.

The **account itself goes last**. An account deleted before its data would leave documents keyed
to a user nobody can authenticate as: unreachable, unclaimable, and invisible to any later
attempt. The reverse merely leaves an empty account, which a second attempt finishes off.

## Absence, everywhere

A field with no value is **absent**, never `null` and never an empty-string placeholder standing
in for "unknown". `storageId` absent means "not attached", `lowStockThreshold` absent means "no
alert wanted", `frequency` absent means "one-shot". The distinction is load-bearing: `0` is a
real threshold, `''` is a real (if odd) name, and absence is neither.

## The vocabulary is French on screen, English in the model

Enum values, discriminants and identifiers are English technical symbols (`kitchenware`,
`custom-days`, `low-stock-crossed`); the app translates them. The only French the backend holds is
the copy it *sends to the user* — the push notification body — and French sample values quoted in
the AI prompts. See [code-style.md](./code-style.md#language).

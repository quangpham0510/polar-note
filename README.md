# polar-note

Bipolar sleep and energy tracking prototype.

Single-file web app (`index.html`) with **Supabase** for email/password auth and cloud data sync. Per-user tracking data lives in Postgres (protected by Row Level Security); `localStorage` is only a session cache.

## Setup

1. **Create a Supabase project** at [supabase.com](https://supabase.com) (free tier).

2. **Create the database schema** — open *SQL Editor* → *New query*, paste the contents of [`supabase-schema.sql`](supabase-schema.sql), and run it. This creates the `profiles` and `entries` tables with RLS policies.

3. **Add your credentials** — in *Project Settings → API*, copy the **Project URL** and **anon public** key into [`supabase-config.js`](supabase-config.js):

   ```js
   window.SUPABASE_URL = 'https://xxxx.supabase.co';
   window.SUPABASE_ANON_KEY = 'eyJ...';
   ```

   (The anon key is safe to expose in the browser — access is restricted by RLS.)

4. **(Recommended) Simplify sign-up** — in *Authentication → Sign In / Providers → Email*, turn **off** "Confirm email" so users can sign up and start tracking immediately. Leave it on if you want email verification (the app will prompt users to confirm before signing in).

5. **Serve the folder** over HTTP (auth needs a real origin, not `file://`):

   ```bash
   npx serve .
   # or: python -m http.server 8000
   ```

   Open the printed URL, create an account, and start tracking.

## How it works

- **Auth gate** → sign in / sign up (email + password).
- **Onboarding** (first time only) → name + diagnosis, saved to `profiles`.
- **Today / History / Insights / Profile** → daily check-ins upsert to `entries` (one row per user per day).
- **Edit / backfill** → tap any entry in History to edit it, or "Log a missed day" to backfill a past date.
- **Offline** → a service worker caches the app shell; check-ins made offline are queued locally and replayed on reconnect.
- **Reminders** → evening / weekly / red-zone notifications fire while the app is open or returns to the foreground (web PWAs can't run a true background scheduler without a push server).
- **Sign out** clears the local cache; **Reset all data** deletes the account's entries from the database.

## Files

| File | Purpose |
|------|---------|
| `index.html` | The entire app (markup, styles, logic) |
| `sw.js` | Service worker — caches the app shell for offline use |
| `supabase-config.js` | Your project URL + anon key |
| `supabase-schema.sql` | Database schema + RLS policies (run once) |

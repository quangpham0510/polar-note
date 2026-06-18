# polar-note

Bipolar sleep and energy tracking prototype.

Single-file web app (`index.html`) with **Firebase** for email/password auth and cloud data sync. Per-user tracking data lives in Cloud Firestore (protected by security rules); `localStorage` is only a session cache.

## Setup

1. **Create a Firebase project** at [console.firebase.google.com](https://console.firebase.google.com) (free Spark plan).

2. **Enable Email/Password auth** — *Build → Authentication → Get started → Sign-in method → Email/Password → Enable*. (No email confirmation needed; users can sign up and start immediately.)

3. **Create Firestore** — *Build → Firestore Database → Create database* (start in production mode, any region).

4. **Publish security rules** — *Firestore Database → Rules*, paste the contents of [`firestore.rules`](firestore.rules), and click **Publish**.

5. **Register a Web app & copy config** — *Project settings (gear) → General → Your apps → Web (`</>`)*. Copy the `firebaseConfig` values into [`firebase-config.js`](firebase-config.js):

   ```js
   window.FIREBASE_CONFIG = {
     apiKey: '...',
     authDomain: '...firebaseapp.com',
     projectId: '...',
     storageBucket: '...appspot.com',
     messagingSenderId: '...',
     appId: '...',
   };
   ```

   (These values are safe in the browser — access is restricted by the Firestore rules.)

6. **Serve the folder** over HTTP (auth needs a real origin, not `file://`):

   ```bash
   npx serve .
   # or: python -m http.server 8000
   ```

   Open the printed URL, create an account, and start tracking. (Add your dev domain under *Authentication → Settings → Authorized domains* if needed — `localhost` is allowed by default.)

## Data model (Firestore)

```
users/{uid}                       → { name, dx, startDate }
users/{uid}/entries/{YYYY-MM-DD}  → { date, bedMin, wakeMin, sleepH, mood, zone, flags, ts }
```

One entry document per user per day (the date is the doc id, so re-saving a day overwrites it).

## How it works

- **Auth gate** → sign in / sign up (email + password).
- **Onboarding** (first time only) → name + diagnosis, saved to the user profile doc.
- **Today / History / Insights / Profile** → daily check-ins write to the `entries` subcollection.
- **Sign out** clears the local cache; **Reset all data** deletes the account's entries from Firestore.

## Files

| File | Purpose |
|------|---------|
| `index.html` | The entire app (markup, styles, logic) |
| `firebase-config.js` | Your Firebase web config |
| `firestore.rules` | Firestore security rules (publish once) |

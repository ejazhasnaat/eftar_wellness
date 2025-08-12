# Admin Approvals (Next.js + Supabase)

Minimal admin UI to approve/reject Experts & Providers.

## Setup
1. Create `.env.local` from example and set your Supabase values:
```
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
```

2. Install deps and run:
```
npm install
npm run dev
```

3. Open http://localhost:3000/login and sign in with an **admin** user.

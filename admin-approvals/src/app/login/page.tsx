'use client';

import { useState } from 'react';
import { supabase } from '@/lib/supabase';
import { useRouter } from 'next/navigation';

export default function LoginPage() {
  const [email, setEmail] = useState(''); const [password, setPassword] = useState('');
  const [busy, setBusy] = useState(false);
  const router = useRouter();

  async function signIn(e: React.FormEvent) {
    e.preventDefault(); setBusy(true);
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    setBusy(false);
    if (error) alert(error.message); else router.push('/dashboard');
  }

  return (
    <main style={{ display: 'grid', placeItems: 'center', minHeight: '100vh', padding: 24 }}>
      <form onSubmit={signIn} style={{ display: 'grid', gap: 12, width: 320 }}>
        <h2>Admin Login</h2>
        <input placeholder="Email" type="email" value={email} onChange={e=>setEmail(e.target.value)} required />
        <input placeholder="Password" type="password" value={password} onChange={e=>setPassword(e.target.value)} required />
        <button disabled={busy}>{busy ? 'Signing in…' : 'Sign in'}</button>
      </form>
    </main>
  );
}

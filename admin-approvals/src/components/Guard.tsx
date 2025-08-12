// admin-approvals/src/components/Guard.tsx
"use client";

import { useEffect, useState } from "react";
import { createClient } from "../lib/supabase";

export default function Guard({ children }: { children: React.ReactNode }) {
  const [ok, setOk] = useState<boolean | null>(null);

  useEffect(() => {
    const run = async () => {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        window.location.href = "/login";
        return;
      }
      const { data, error } = await supabase
        .from("profiles")
        .select("role")
        .eq("id", user.id)
        .maybeSingle();

      if (error || !data || data.role !== "admin") {
        window.location.href = "/login";
        return;
      }
      setOk(true);
    };
    run();
  }, []);

  if (ok === null) {
    return <div className="p-6 text-sm text-gray-600">Checking access…</div>;
  }
  return <>{children}</>;
}


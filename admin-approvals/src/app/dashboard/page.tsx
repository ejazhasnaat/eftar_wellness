// admin-approvals/src/app/dashboard/page.tsx
import { createClient } from "@/lib/supabase";
import ApprovalTable from "@/components/ApprovalTable";

async function loadRows() {
  const supabase = createClient();

  // Join expert_profiles with profiles and auth.users email
  // If you keep email in profiles, you can remove auth.users join to simplify.
  const { data: experts, error } = await supabase
    .from("expert_profiles")
    .select(
      `
      user_id,
      specialization,
      status,
      submitted_at,
      profiles:profiles!inner(full_name),
      auth_users:auth.users!inner(email)
    `
    )
    .order("submitted_at", { ascending: false });

  if (error) {
    // Allow page to render with an empty state but log for debugging
    console.error(error);
    return [];
  }

  return (experts ?? []).map((row: any) => ({
    user_id: row.user_id as string,
    full_name: row.profiles?.full_name ?? null,
    email: row.auth_users?.email ?? null,
    specialization: row.specialization ?? null,
    status: row.status as "pending" | "approved" | "rejected",
    submitted_at: row.submitted_at ?? null,
  }));
}

export default async function DashboardPage() {
  const rows = await loadRows();

  return (
    <main className="p-6 space-y-6">
      <div>
        <h1 className="text-xl font-semibold">Expert Approvals</h1>
        <p className="text-sm text-gray-600">
          Review expert verification requests and update their status.
        </p>
      </div>
      <ApprovalTable rows={rows} />
    </main>
  );
}


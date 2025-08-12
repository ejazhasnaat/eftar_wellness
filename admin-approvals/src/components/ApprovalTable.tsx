// admin-approvals/src/components/ApprovalTable.tsx
"use client";

import { useCallback, useMemo, useState } from "react";
import { createClient } from "../lib/supabase";

type Row = {
  user_id: string;
  full_name?: string | null;
  email?: string | null;
  specialization?: string | null;
  status: "pending" | "approved" | "rejected";
  submitted_at?: string | null;
};

export default function ApprovalTable({ rows }: { rows: Row[] }) {
  const [busyId, setBusyId] = useState<string | null>(null);
  const supabase = useMemo(() => createClient(), []);

  const review = useCallback(
    async (userId: string, newStatus: "approved" | "rejected") => {
      try {
        setBusyId(userId);
        const { error } = await supabase.rpc("review_expert_profile", {
          p_user_id: userId,
          p_new_status: newStatus,
          p_reviewer_notes: null, // add a notes UI later if desired
        });
        if (error) throw error;
        // simple refresh
        window.location.reload();
      } catch (e: any) {
        alert(e?.message ?? "Failed to update status");
      } finally {
        setBusyId(null);
      }
    },
    [supabase]
  );

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full border border-gray-200 rounded-md">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-3 py-2 text-left text-sm font-semibold">Expert</th>
            <th className="px-3 py-2 text-left text-sm font-semibold">Email</th>
            <th className="px-3 py-2 text-left text-sm font-semibold">Specialization</th>
            <th className="px-3 py-2 text-left text-sm font-semibold">Status</th>
            <th className="px-3 py-2 text-left text-sm font-semibold">Submitted</th>
            <th className="px-3 py-2 text-right text-sm font-semibold">Actions</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((r) => (
            <tr key={r.user_id} className="border-t">
              <td className="px-3 py-2">{r.full_name ?? "—"}</td>
              <td className="px-3 py-2">{r.email ?? "—"}</td>
              <td className="px-3 py-2">{r.specialization ?? "—"}</td>
              <td className="px-3 py-2">
                <span
                  className={
                    "inline-flex rounded px-2 py-0.5 text-xs " +
                    (r.status === "approved"
                      ? "bg-green-100 text-green-700"
                      : r.status === "rejected"
                      ? "bg-red-100 text-red-700"
                      : "bg-amber-100 text-amber-700")
                  }
                >
                  {r.status}
                </span>
              </td>
              <td className="px-3 py-2">{r.submitted_at ? new Date(r.submitted_at).toLocaleString() : "—"}</td>
              <td className="px-3 py-2 text-right space-x-2">
                <button
                  disabled={busyId === r.user_id || r.status === "approved"}
                  onClick={() => review(r.user_id, "approved")}
                  className="rounded border px-3 py-1 text-sm hover:bg-green-50 disabled:opacity-50"
                >
                  {busyId === r.user_id ? "..." : "Approve"}
                </button>
                <button
                  disabled={busyId === r.user_id || r.status === "rejected"}
                  onClick={() => review(r.user_id, "rejected")}
                  className="rounded border px-3 py-1 text-sm hover:bg-red-50 disabled:opacity-50"
                >
                  {busyId === r.user_id ? "..." : "Reject"}
                </button>
              </td>
            </tr>
          ))}
          {rows.length === 0 && (
            <tr>
              <td className="px-3 py-6 text-center text-sm text-gray-500" colSpan={6}>
                No requests.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}


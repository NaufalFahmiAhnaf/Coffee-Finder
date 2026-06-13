import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import axios from "axios";
import {
  CheckCircle2,
  ExternalLink,
  Loader2,
  MapPin,
  ShieldCheck,
  XCircle,
} from "lucide-react";

export default function AdminSubmissions() {
  const [submissions, setSubmissions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState({});
  const [notes, setNotes] = useState({});

  const fetchSubmissions = async () => {
    setLoading(true);
    try {
      const response = await axios.get("/api/admin/coffee-shop-submissions");
      setSubmissions(response.data.data || []);
    } catch (error) {
      console.error("Failed to fetch submissions:", error);
      alert("Unable to load pending submissions right now.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSubmissions();
  }, []);

  const stats = useMemo(() => {
    return submissions.reduce(
      (acc, item) => {
        acc[item.status] = (acc[item.status] || 0) + 1;
        return acc;
      },
      { pending: 0, approved: 0, rejected: 0 },
    );
  }, [submissions]);

  const handleApprove = async (id) => {
    setActionLoading((prev) => ({ ...prev, [id]: "approve" }));
    try {
      await axios.post(`/api/admin/coffee-shop-submissions/${id}/approve`);
      await fetchSubmissions();
    } catch (error) {
      console.error("Failed to approve submission:", error);
      alert("Approval failed. Please try again.");
    } finally {
      setActionLoading((prev) => ({ ...prev, [id]: null }));
    }
  };

  const handleReject = async (id) => {
    setActionLoading((prev) => ({ ...prev, [id]: "reject" }));
    try {
      await axios.post(`/api/admin/coffee-shop-submissions/${id}/reject`, {
        admin_notes: notes[id] || "Rejected by admin.",
      });
      await fetchSubmissions();
    } catch (error) {
      console.error("Failed to reject submission:", error);
      alert("Rejection failed. Please try again.");
    } finally {
      setActionLoading((prev) => ({ ...prev, [id]: null }));
    }
  };

  return (
    <div className="min-h-screen bg-background text-textMain">
      <header className="border-b border-gray-200 bg-surface shadow-sm">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-4 py-6 sm:px-6 lg:px-8">
          <div>
            <p className="text-sm font-semibold uppercase tracking-[0.25em] text-primary">
              Admin Panel
            </p>
            <h1 className="mt-2 text-3xl font-black text-textMain">
              Coffee Shop Approval Queue
            </h1>
            <p className="mt-2 text-sm text-textMuted">
              Review submitted cafes, open Google Maps, and approve or reject
              each request.
            </p>
          </div>
          <Link
            to="/dashboard"
            className="rounded-2xl border border-gray-200 bg-background px-4 py-2 text-sm font-semibold text-textMain transition hover:border-primary hover:text-primary"
          >
            Back to dashboard
          </Link>
        </div>
      </header>

      <main className="mx-auto flex max-w-7xl flex-col gap-8 px-4 py-8 sm:px-6 lg:px-8">
        <section className="grid gap-4 md:grid-cols-3">
          {[
            {
              label: "Pending",
              value: stats.pending,
              tone: "bg-amber-50 text-amber-700 border-amber-200",
            },
            {
              label: "Approved",
              value: stats.approved,
              tone: "bg-emerald-50 text-emerald-700 border-emerald-200",
            },
            {
              label: "Rejected",
              value: stats.rejected,
              tone: "bg-rose-50 text-rose-700 border-rose-200",
            },
          ].map((item) => (
            <article
              key={item.label}
              className={`rounded-3xl border p-5 shadow-sm ${item.tone}`}
            >
              <p className="text-sm font-semibold uppercase tracking-[0.2em]">
                {item.label}
              </p>
              <p className="mt-3 text-4xl font-black">{item.value}</p>
            </article>
          ))}
        </section>

        <section className="rounded-3xl border border-gray-100 bg-surface p-6 shadow-sm">
          <div className="mb-6 flex items-center justify-between gap-3">
            <div>
              <h2 className="text-xl font-black text-textMain">
                Submission List
              </h2>
              <p className="text-sm text-textMuted">
                Use the action buttons to move a cafe into production or reject
                it.
              </p>
            </div>
            <button
              onClick={fetchSubmissions}
              className="rounded-2xl border border-gray-200 bg-background px-4 py-2 text-sm font-semibold text-textMain hover:border-primary hover:text-primary"
            >
              Refresh
            </button>
          </div>

          {loading ? (
            <div className="flex items-center justify-center py-16 text-primary">
              <Loader2 className="mr-3 h-6 w-6 animate-spin" />
              Loading submissions...
            </div>
          ) : submissions.length === 0 ? (
            <div className="rounded-3xl border border-dashed border-gray-200 bg-background py-16 text-center text-textMuted">
              No coffee shop submissions found.
            </div>
          ) : (
            <div className="grid gap-6 xl:grid-cols-2">
              {submissions.map((item) => (
                <article
                  key={item.id}
                  className="rounded-3xl border border-gray-100 bg-background p-5 shadow-sm"
                >
                  <div className="flex items-start justify-between gap-4">
                    <div>
                      <p className="text-xs font-semibold uppercase tracking-[0.25em] text-primary">
                        Submission #{item.id}
                      </p>
                      <h3 className="mt-2 text-2xl font-black text-textMain">
                        {item.name}
                      </h3>
                      <p className="mt-1 text-sm text-textMuted">
                        {item.description || "No description provided yet."}
                      </p>
                    </div>
                    <span
                      className={`rounded-full px-3 py-1 text-xs font-bold uppercase tracking-[0.2em] ${item.status === "approved" ? "bg-emerald-50 text-emerald-700" : item.status === "rejected" ? "bg-rose-50 text-rose-700" : "bg-amber-50 text-amber-700"}`}
                    >
                      {item.status}
                    </span>
                  </div>

                  <div className="mt-5 flex flex-wrap gap-2 text-sm text-textMuted">
                    <span className="rounded-xl border border-gray-200 bg-surface px-3 py-2">
                      ⭐ {item.rating || 0}
                    </span>
                    <span className="rounded-xl border border-gray-200 bg-surface px-3 py-2">
                      Rp {(item.price || 0).toLocaleString("id-ID")}
                    </span>
                    <span className="rounded-xl border border-gray-200 bg-surface px-3 py-2">
                      {item.submitted_by || "Anonymous"}
                    </span>
                  </div>

                  <div className="mt-5 space-y-2 text-sm text-textMuted">
                    <p className="flex items-center gap-2">
                      <MapPin className="h-4 w-4 text-primary" />{" "}
                      {item.address || "Address not provided"}
                    </p>
                    <p className="flex items-center gap-2">
                      <ShieldCheck className="h-4 w-4 text-primary" />{" "}
                      {item.facilities
                        ? Object.entries(item.facilities)
                            .filter(([, value]) => value)
                            .map(([key]) => key)
                            .join(", ") || "No facilities listed"
                        : "No facilities listed"}
                    </p>
                  </div>

                  {item.maps_url && (
                    <a
                      href={item.maps_url}
                      target="_blank"
                      rel="noreferrer"
                      className="mt-5 inline-flex items-center gap-2 rounded-2xl bg-primary px-4 py-2 text-sm font-semibold text-white transition hover:bg-primary-hover"
                    >
                      <ExternalLink className="h-4 w-4" />
                      Open in Google Maps
                    </a>
                  )}

                  {item.admin_notes && (
                    <p className="mt-4 rounded-2xl border border-gray-200 bg-surface p-3 text-sm text-textMuted">
                      Admin note: {item.admin_notes}
                    </p>
                  )}

                  <div className="mt-5 rounded-2xl border border-gray-100 bg-surface p-4">
                    <label className="mb-2 block text-xs font-semibold uppercase tracking-[0.25em] text-textMuted">
                      Reject note (optional)
                    </label>
                    <textarea
                      rows="2"
                      value={notes[item.id] || ""}
                      onChange={(e) =>
                        setNotes((prev) => ({
                          ...prev,
                          [item.id]: e.target.value,
                        }))
                      }
                      placeholder="Reason for rejection"
                      className="w-full rounded-2xl border border-gray-200 bg-background px-4 py-3 text-sm text-textMain outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/20"
                    />

                    <div className="mt-4 flex flex-wrap gap-3">
                      <button
                        onClick={() => handleApprove(item.id)}
                        disabled={
                          actionLoading[item.id] === "approve" ||
                          item.status === "approved"
                        }
                        className="inline-flex items-center gap-2 rounded-2xl bg-emerald-600 px-4 py-2 text-sm font-semibold text-white transition hover:bg-emerald-700 disabled:cursor-not-allowed disabled:opacity-60"
                      >
                        {actionLoading[item.id] === "approve" ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                          <CheckCircle2 className="h-4 w-4" />
                        )}
                        Approve
                      </button>
                      <button
                        onClick={() => handleReject(item.id)}
                        disabled={
                          actionLoading[item.id] === "reject" ||
                          item.status === "rejected"
                        }
                        className="inline-flex items-center gap-2 rounded-2xl bg-rose-600 px-4 py-2 text-sm font-semibold text-white transition hover:bg-rose-700 disabled:cursor-not-allowed disabled:opacity-60"
                      >
                        {actionLoading[item.id] === "reject" ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                          <XCircle className="h-4 w-4" />
                        )}
                        Reject
                      </button>
                    </div>
                  </div>
                </article>
              ))}
            </div>
          )}
        </section>
      </main>
    </div>
  );
}

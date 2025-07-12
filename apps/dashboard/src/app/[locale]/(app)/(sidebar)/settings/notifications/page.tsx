import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Notifications | Midday",
};

export default async function Notifications() {
  return (
    <div className="p-4">
      <h1 className="text-xl font-semibold">Notifications</h1>
      <p className="text-muted-foreground mt-2">
        Notifications feature is temporarily disabled during initial deployment.
      </p>
    </div>
  );
}

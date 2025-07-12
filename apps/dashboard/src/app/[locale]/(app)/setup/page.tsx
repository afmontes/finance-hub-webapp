"use client";

import { Button } from "@midday/ui/button";
import { Input } from "@midday/ui/input";
import { Label } from "@midday/ui/label";
import { useState } from "react";

export default function SetupPage() {
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSubmitting(true);

    const formData = new FormData(e.currentTarget);
    const data = Object.fromEntries(formData);

    try {
      const response = await fetch("/api/setup/create-initial-team", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });

      const result = await response.json();

      if (result.success) {
        alert("Team created successfully!");
        window.location.href = "/";
      } else {
        alert(`Error: ${result.error}`);
      }
    } catch (error) {
      alert(
        `Failed to create team: ${error instanceof Error ? error.message : String(error)}`,
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <div className="w-full max-w-md space-y-6">
        <div className="text-center">
          <h1 className="text-2xl font-bold">Setup Your Team</h1>
          <p className="text-gray-600 mt-2">
            Create your first team to get started with your finance hub.
          </p>
        </div>

        <form className="space-y-4" onSubmit={handleSubmit}>
          <div>
            <Label htmlFor="name">Team Name</Label>
            <Input
              id="name"
              name="name"
              placeholder="My Finance Team"
              required
            />
          </div>

          <div>
            <Label htmlFor="baseCurrency">Currency</Label>
            <select
              id="baseCurrency"
              name="baseCurrency"
              className="w-full p-2 border rounded-md"
              required
            >
              <option value="USD">USD - US Dollar</option>
              <option value="CAD">CAD - Canadian Dollar</option>
              <option value="EUR">EUR - Euro</option>
              <option value="GBP">GBP - British Pound</option>
            </select>
          </div>

          <div>
            <Label htmlFor="countryCode">Country</Label>
            <select
              id="countryCode"
              name="countryCode"
              className="w-full p-2 border rounded-md"
              required
            >
              <option value="US">United States</option>
              <option value="CA">Canada</option>
              <option value="GB">United Kingdom</option>
              <option value="DE">Germany</option>
            </select>
          </div>

          <Button type="submit" className="w-full" disabled={isSubmitting}>
            {isSubmitting ? "Creating Team..." : "Create Team"}
          </Button>
        </form>
      </div>
    </div>
  );
}

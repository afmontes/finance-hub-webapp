import { createClient } from "@midday/supabase/server";
import { cookies } from "next/headers";
import { NextResponse } from "next/server";

export async function GET() {
  try {
    const cookieStore = await cookies();
    const supabase = await createClient();

    // Sign out the user
    await supabase.auth.signOut();

    // Clear all cookies
    for (const cookie of cookieStore.getAll()) {
      cookieStore.delete(cookie.name);
    }

    return NextResponse.json({
      message: "Session cleared successfully",
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    return NextResponse.json(
      {
        error: "Failed to reset session",
        details: error instanceof Error ? error.message : String(error),
      },
      { status: 500 },
    );
  }
}

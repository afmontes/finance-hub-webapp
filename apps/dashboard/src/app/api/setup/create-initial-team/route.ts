import { createClient } from "@midday/supabase/server";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  try {
    const { name, countryCode, baseCurrency } = await request.json();
    const supabase = await createClient();

    // Get the current user
    const {
      data: { session },
      error: sessionError,
    } = await supabase.auth.getSession();

    if (sessionError || !session?.user) {
      return NextResponse.json(
        { error: "No authenticated user found" },
        { status: 401 },
      );
    }

    const userId = session.user.id;

    // Create team
    const { data: team, error: teamError } = await supabase
      .from("teams")
      .insert({
        name: name || "My Team",
        base_currency: baseCurrency || "USD",
      })
      .select()
      .single();

    if (teamError) {
      return NextResponse.json(
        { error: "Failed to create team", details: teamError.message },
        { status: 500 },
      );
    }

    // Add user to team
    const { error: memberError } = await supabase.from("users_on_team").insert({
      user_id: userId,
      team_id: team.id,
      role: "owner",
    });

    if (memberError) {
      return NextResponse.json(
        { error: "Failed to add user to team", details: memberError.message },
        { status: 500 },
      );
    }

    return NextResponse.json({
      success: true,
      team,
      message: "Team created successfully",
    });
  } catch (error) {
    return NextResponse.json(
      {
        error: "Failed to create team",
        details: error instanceof Error ? error.message : String(error),
      },
      { status: 500 },
    );
  }
}

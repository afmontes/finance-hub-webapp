import { createClient } from "@midday/supabase/server";
import { NextResponse } from "next/server";

export async function GET() {
  try {
    const supabase = await createClient();
    
    // Test Supabase connection
    const { data: { session } } = await supabase.auth.getSession();
    
    // Test API connectivity
    const apiUrl = process.env.NEXT_PUBLIC_API_URL;
    
    return NextResponse.json({
      status: "ok",
      timestamp: new Date().toISOString(),
      environment: {
        apiUrl,
        hasSession: !!session,
        userId: session?.user?.id || null,
        userEmail: session?.user?.email || null,
      },
      frontend: {
        url: process.env.NEXT_PUBLIC_URL,
        supabaseUrl: process.env.NEXT_PUBLIC_SUPABASE_URL,
      }
    });
  } catch (error) {
    return NextResponse.json({
      status: "error",
      error: error instanceof Error ? error.message : String(error),
      timestamp: new Date().toISOString()
    }, { status: 500 });
  }
}
"use client";

import { useEffect } from "react";

/**
 * Debug component to intercept and log React errors in development
 */
export function ErrorInterceptor() {
  useEffect(() => {
    if (process.env.NEXT_PUBLIC_DEBUG_MODE !== "true") {
      return;
    }

    // Override console.error to catch React errors
    const originalError = console.error;
    console.error = (...args) => {
      const errorMessage = args.join(" ");
      
      // Check for React Error #419 specifically
      if (errorMessage.includes("419") || errorMessage.includes("flushSync")) {
        console.group("🚨 REACT ERROR #419 DETECTED");
        console.error("Original error:", ...args);
        console.error("Stack trace:", new Error().stack);
        console.groupEnd();
      }
      
      // Check for Server Components errors
      if (errorMessage.includes("Server Components render")) {
        console.group("🚨 SERVER COMPONENTS ERROR DETECTED");
        console.error("Original error:", ...args);
        console.error("Stack trace:", new Error().stack);
        console.groupEnd();
      }
      
      // Log all tRPC errors for debugging
      if (errorMessage.includes("TRPCClientError") || errorMessage.includes("trpc")) {
        console.group("🔍 TRPC ERROR DETECTED");
        console.error("Original error:", ...args);
        console.error("Stack trace:", new Error().stack);
        console.groupEnd();
      }
      
      originalError.apply(console, args);
    };

    // Override window.reportError to catch unhandled errors
    const originalReportError = window.reportError;
    if (originalReportError) {
      window.reportError = (error) => {
        console.group("🚨 UNHANDLED ERROR DETECTED");
        console.error("Error:", error);
        console.error("Stack trace:", error.stack);
        console.groupEnd();
        return originalReportError(error);
      };
    }

    // Add global error handler
    const handleError = (event: ErrorEvent) => {
      console.group("🚨 GLOBAL ERROR DETECTED");
      console.error("Error:", event.error);
      console.error("Message:", event.message);
      console.error("Filename:", event.filename);
      console.error("Line:", event.lineno);
      console.error("Column:", event.colno);
      console.groupEnd();
    };

    window.addEventListener("error", handleError);

    return () => {
      console.error = originalError;
      if (originalReportError) {
        window.reportError = originalReportError;
      }
      window.removeEventListener("error", handleError);
    };
  }, []);

  return null;
}
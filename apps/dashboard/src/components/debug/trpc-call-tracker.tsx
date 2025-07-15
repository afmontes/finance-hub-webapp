"use client";

import { useEffect } from "react";

/**
 * Debug component to track all tRPC calls and identify invoice-related queries
 */
export function TRPCCallTracker() {
  useEffect(() => {
    if (process.env.NEXT_PUBLIC_DEBUG_MODE !== "true") {
      return;
    }

    // Intercept fetch calls to track tRPC requests
    const originalFetch = window.fetch;
    window.fetch = async (...args) => {
      const [input, init] = args;
      const url = typeof input === "string" ? input : input.url;
      
      // Check if this is a tRPC call
      if (url.includes("/trpc/") || url.includes("trpc")) {
        console.group("🔍 tRPC CALL DETECTED");
        console.log("URL:", url);
        console.log("Method:", init?.method || "GET");
        
        // Check for invoice-related calls
        if (url.includes("invoice")) {
          console.warn("⚠️  INVOICE tRPC CALL DETECTED - This should be disabled!");
          console.log("Full URL:", url);
          console.log("Stack trace:", new Error().stack);
        }
        
        console.groupEnd();
      }
      
      return originalFetch.apply(window, args);
    };

    // Track component mounting for invoice-related components
    const invoiceComponentNames = [
      "Invoice",
      "InvoiceWidget", 
      "InvoicesOpen",
      "InvoicesOverdue", 
      "InvoicesPaid",
      "InvoicePaymentScore",
      "InvoiceHeader",
      "InvoiceSheet",
      "InvoiceDetailsSheet",
      "InvoiceActions"
    ];

    // Override React createElement to track component creation
    if (typeof window !== "undefined" && window.React) {
      const originalCreateElement = window.React.createElement;
      window.React.createElement = function(type, props, ...children) {
        if (typeof type === "function" && type.name) {
          if (invoiceComponentNames.some(name => type.name.includes(name))) {
            console.warn("⚠️  INVOICE COMPONENT DETECTED:", type.name);
            console.log("Stack trace:", new Error().stack);
          }
        }
        return originalCreateElement.apply(this, [type, props, ...children]);
      };
    }

    return () => {
      window.fetch = originalFetch;
    };
  }, []);

  return null;
}
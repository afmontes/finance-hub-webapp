/**
 * Feature flag utilities for conditionally enabling/disabling app features
 */

/**
 * Check if invoice functionality is enabled
 * @returns boolean indicating if invoice features should be available
 */
export function isInvoiceFeatureEnabled(): boolean {
  return process.env.NEXT_PUBLIC_ENABLE_INVOICES === "true";
}

/**
 * Check if inbox functionality is enabled
 * @returns boolean indicating if inbox features should be available
 */
export function isInboxFeatureEnabled(): boolean {
  return process.env.NEXT_PUBLIC_ENABLE_INBOX !== "false";
}

/**
 * Check if tracker functionality is enabled
 * @returns boolean indicating if tracker features should be available
 */
export function isTrackerFeatureEnabled(): boolean {
  return process.env.NEXT_PUBLIC_ENABLE_TRACKER !== "false";
}

/**
 * Check if customer management functionality is enabled
 * @returns boolean indicating if customer features should be available
 */
export function isCustomerFeatureEnabled(): boolean {
  return process.env.NEXT_PUBLIC_ENABLE_CUSTOMERS !== "false";
}

/**
 * Check if apps functionality is enabled
 * @returns boolean indicating if apps features should be available
 */
export function isAppsFeatureEnabled(): boolean {
  return process.env.NEXT_PUBLIC_ENABLE_APPS !== "false";
}

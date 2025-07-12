import { Resend } from "resend";

// Initialize with proper API key or a valid dummy key that won't cause validation errors
const apiKey = process.env.RESEND_API_KEY || "re_dummy_key_12345678901234567890123456789012";
export const resend = new Resend(apiKey);

import { Resend } from "resend";

export const resend = new Resend(process.env.RESEND_API_KEY || "dummy_key_for_deployment");

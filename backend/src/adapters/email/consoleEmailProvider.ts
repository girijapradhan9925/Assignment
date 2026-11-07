import type { EnquiryEmailPayload } from "../../domain/enquiry";
import type { EmailProvider } from "../../domain/ports";

/**
 * Zero-setup email provider: logs the enquiry email to stdout.
 * Reviewers need no account. Swap EMAIL_PROVIDER=smtp for a real send.
 */
export class ConsoleEmailProvider implements EmailProvider {
  async send(payload: EnquiryEmailPayload): Promise<void> {
    // Structured so a reviewer can grep the terminal for "ENQUIRY EMAIL"
    console.log(
      [
        "",
        "========== ENQUIRY EMAIL ==========",
        `To:      ${payload.to}`,
        `From:    (reply-to) ${payload.replyTo}`,
        `Subject: ${payload.subject}`,
        "----------------------------------",
        payload.text,
        "==================================",
        "",
      ].join("\n"),
    );
  }
}

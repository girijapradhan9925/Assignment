import nodemailer from "nodemailer";
import type { Transporter } from "nodemailer";
import type { EnquiryEmailPayload } from "../../domain/enquiry";
import type { EmailProvider } from "../../domain/ports";
import { AppError } from "../../domain/errors";

export interface SmtpEmailProviderOptions {
  host: string;
  port: number;
  secure: boolean;
  user?: string;
  pass?: string;
  from: string;
}

/**
 * SMTP adapter — works with Mailpit/Mailhog locally, or any real SMTP host.
 * An AWS SES adapter would implement the same EmailProvider port.
 */
export class SmtpEmailProvider implements EmailProvider {
  private readonly transporter: Transporter;
  private readonly from: string;

  constructor(options: SmtpEmailProviderOptions) {
    this.from = options.from;
    this.transporter = nodemailer.createTransport({
      host: options.host,
      port: options.port,
      secure: options.secure,
      auth:
        options.user && options.pass
          ? { user: options.user, pass: options.pass }
          : undefined,
    });
  }

  async send(payload: EnquiryEmailPayload): Promise<void> {
    try {
      await this.transporter.sendMail({
        from: this.from,
        to: payload.to,
        replyTo: payload.replyTo,
        subject: payload.subject,
        text: payload.text,
      });
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Unknown SMTP error";
      throw new AppError(
        `Failed to send enquiry email: ${message}`,
        502,
        "EMAIL_DELIVERY_FAILED",
      );
    }
  }
}

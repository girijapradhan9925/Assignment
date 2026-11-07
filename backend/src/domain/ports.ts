import type { Product } from "./product";
import type { EnquiryEmailPayload } from "./enquiry";

/**
 * Product data source port.
 * Swap Fake Store for a real catalogue DB/API by implementing this interface.
 */
export interface ProductRepository {
  findAll(): Promise<Product[]>;
  findById(id: number): Promise<Product | null>;
}

/**
 * Email delivery port.
 * Default is console (zero-setup). Swap for SMTP or an AWS SES adapter later.
 */
export interface EmailProvider {
  send(payload: EnquiryEmailPayload): Promise<void>;
}

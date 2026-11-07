import { randomUUID } from "node:crypto";
import type { EmailProvider, ProductRepository } from "../domain/ports";
import type { EnquiryRequest, EnquiryResult } from "../domain/enquiry";
import { NotFoundError } from "../domain/errors";

export interface EnquiryServiceOptions {
  repository: ProductRepository;
  emailProvider: EmailProvider;
  salesInbox: string;
}

export class EnquiryService {
  private readonly repository: ProductRepository;
  private readonly emailProvider: EmailProvider;
  private readonly salesInbox: string;

  constructor(options: EnquiryServiceOptions) {
    this.repository = options.repository;
    this.emailProvider = options.emailProvider;
    this.salesInbox = options.salesInbox;
  }

  async submit(request: EnquiryRequest): Promise<EnquiryResult> {
    const product = await this.repository.findById(request.productId);
    if (!product) {
      throw new NotFoundError(`Product ${request.productId} not found`);
    }

    const reference = randomUUID();
    const phoneLine = request.phone
      ? `Phone:   ${request.phone}`
      : "Phone:   (not provided)";

    await this.emailProvider.send({
      to: this.salesInbox,
      replyTo: request.email,
      subject: `Enquiry #${reference.slice(0, 8)} — ${product.title}`,
      text: [
        `Reference: ${reference}`,
        "",
        "Product",
        `  ID:    ${product.id}`,
        `  Title: ${product.title}`,
        `  Price: ${product.price}`,
        "",
        "Customer",
        `  Name:   ${request.name}`,
        `  Email:  ${request.email}`,
        `  ${phoneLine}`,
        "",
        "Message",
        request.message,
      ].join("\n"),
    });

    return { reference };
  }
}

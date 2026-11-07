import { describe, expect, it } from "vitest";
import { EnquiryService } from "./enquiryService";
import {
  InMemoryProductRepository,
  RecordingEmailProvider,
  sampleProducts,
} from "../test/fixtures";
import { AppError, NotFoundError } from "../domain/errors";

function createService(email = new RecordingEmailProvider()) {
  return {
    service: new EnquiryService({
      repository: new InMemoryProductRepository(sampleProducts),
      emailProvider: email,
      salesInbox: "sales@example.com",
    }),
    email,
  };
}

describe("EnquiryService", () => {
  it("sends an email to the sales inbox and returns a reference", async () => {
    const { service, email } = createService();

    const result = await service.submit({
      productId: 5,
      name: "Ada Lovelace",
      email: "ada@example.com",
      phone: "+44 7700 900123",
      message: "Interested in bulk pricing",
    });

    expect(result.reference).toMatch(
      /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i,
    );
    expect(email.sent).toHaveLength(1);
    expect(email.sent[0].to).toBe("sales@example.com");
    expect(email.sent[0].replyTo).toBe("ada@example.com");
    expect(email.sent[0].subject).toContain("WD 2TB External Hard Drive");
    expect(email.sent[0].text).toContain("Ada Lovelace");
    expect(email.sent[0].text).toContain("Interested in bulk pricing");
    expect(email.sent[0].text).toContain(result.reference);
  });

  it("omits phone when not provided", async () => {
    const { service, email } = createService();

    await service.submit({
      productId: 1,
      name: "Test",
      email: "test@example.com",
      message: "Hello",
    });

    expect(email.sent[0].text).toContain("Phone:   (not provided)");
  });

  it("throws NotFoundError when the product does not exist", async () => {
    const { service, email } = createService();

    await expect(
      service.submit({
        productId: 999,
        name: "Test",
        email: "test@example.com",
        message: "Hello",
      }),
    ).rejects.toBeInstanceOf(NotFoundError);

    expect(email.sent).toHaveLength(0);
  });

  it("surfaces email provider failures", async () => {
    const email = new RecordingEmailProvider();
    email.failWith = new AppError("SMTP down", 502, "EMAIL_DELIVERY_FAILED");
    const { service } = createService(email);

    await expect(
      service.submit({
        productId: 1,
        name: "Test",
        email: "test@example.com",
        message: "Hello",
      }),
    ).rejects.toMatchObject({ code: "EMAIL_DELIVERY_FAILED" });
  });
});

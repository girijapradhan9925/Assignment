import { loadConfig } from "./config";
import { createApp } from "./app";
import { FakeStoreClient } from "./adapters/fakestore/client";
import { FakeStoreProductRepository } from "./adapters/fakestore/repository";
import { ConsoleEmailProvider } from "./adapters/email/consoleEmailProvider";
import { SmtpEmailProvider } from "./adapters/email/smtpEmailProvider";
import { CatalogService } from "./services/catalogService";
import { EnquiryService } from "./services/enquiryService";
import type { EmailProvider } from "./domain/ports";

function createEmailProvider(config: ReturnType<typeof loadConfig>): EmailProvider {
  if (config.EMAIL_PROVIDER === "smtp") {
    return new SmtpEmailProvider({
      host: config.SMTP_HOST,
      port: config.SMTP_PORT,
      secure: config.SMTP_SECURE,
      user: config.SMTP_USER || undefined,
      pass: config.SMTP_PASS || undefined,
      from: config.SMTP_FROM,
    });
  }
  return new ConsoleEmailProvider();
}

async function main(): Promise<void> {
  const config = loadConfig();

  const client = new FakeStoreClient({
    baseUrl: config.FAKE_STORE_BASE_URL,
    timeoutMs: config.UPSTREAM_TIMEOUT_MS,
  });
  const repository = new FakeStoreProductRepository({
    client,
    cacheTtlMs: config.CACHE_TTL_MS,
  });
  const emailProvider = createEmailProvider(config);

  const catalogService = new CatalogService({
    repository,
    featuredLimit: config.FEATURED_LIMIT,
    categoryTopRatedLimit: config.CATEGORY_TOP_RATED_LIMIT,
  });
  const enquiryService = new EnquiryService({
    repository,
    emailProvider,
    salesInbox: config.SALES_INBOX,
  });

  const app = createApp({
    catalogService,
    enquiryService,
    corsOrigins: config.CORS_ORIGINS,
  });

  app.listen(config.PORT, () => {
    console.log(
      `Catalogue API listening on http://localhost:${config.PORT} (email=${config.EMAIL_PROVIDER})`,
    );
  });
}

main().catch((error) => {
  console.error("Failed to start server:", error);
  process.exit(1);
});

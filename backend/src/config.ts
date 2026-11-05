import { config as loadDotenv } from "dotenv";
import { z } from "zod";

loadDotenv();

const envSchema = z.object({
  PORT: z.coerce.number().int().positive().default(3000),
  CORS_ORIGINS: z.string().default("*"),
  FAKE_STORE_BASE_URL: z
    .string()
    .url()
    .default("https://fakestoreapi.com"),
  CACHE_TTL_MS: z.coerce.number().int().nonnegative().default(60_000),
  FEATURED_LIMIT: z.coerce.number().int().positive().default(5),
  CATEGORY_TOP_RATED_LIMIT: z.coerce.number().int().positive().default(3),
  UPSTREAM_TIMEOUT_MS: z.coerce.number().int().positive().default(8_000),
  EMAIL_PROVIDER: z.enum(["console", "smtp"]).default("console"),
  SALES_INBOX: z.string().email().default("sales@example.com"),
  SMTP_HOST: z.string().default("localhost"),
  SMTP_PORT: z.coerce.number().int().positive().default(1025),
  SMTP_SECURE: z
    .string()
    .optional()
    .transform((v) => v === "true"),
  SMTP_USER: z.string().optional().default(""),
  SMTP_PASS: z.string().optional().default(""),
  SMTP_FROM: z.string().default("catalogue@localhost"),
});

export type AppConfig = z.infer<typeof envSchema>;

export function loadConfig(env: NodeJS.ProcessEnv = process.env): AppConfig {
  const parsed = envSchema.safeParse(env);
  if (!parsed.success) {
    const details = parsed.error.issues
      .map((i) => `${i.path.join(".")}: ${i.message}`)
      .join("; ");
    throw new Error(`Invalid configuration: ${details}`);
  }
  return parsed.data;
}

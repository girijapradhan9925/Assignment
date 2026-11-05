import { UpstreamError } from "../../domain/errors";
import type { FakeStoreProduct } from "./types";

export interface FakeStoreClientOptions {
  baseUrl: string;
  timeoutMs: number;
  fetchImpl?: typeof fetch;
}

export class FakeStoreClient {
  private readonly baseUrl: string;
  private readonly timeoutMs: number;
  private readonly fetchImpl: typeof fetch;

  constructor(options: FakeStoreClientOptions) {
    this.baseUrl = options.baseUrl.replace(/\/$/, "");
    this.timeoutMs = options.timeoutMs;
    this.fetchImpl = options.fetchImpl ?? fetch;
  }

  async getProducts(): Promise<FakeStoreProduct[]> {
    const url = `${this.baseUrl}/products`;
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), this.timeoutMs);

    try {
      const response = await this.fetchImpl(url, {
        signal: controller.signal,
        headers: { Accept: "application/json" },
      });

      if (!response.ok) {
        throw new UpstreamError(
          `Fake Store API returned ${response.status} for ${url}`,
        );
      }

      const data: unknown = await response.json();
      if (!Array.isArray(data)) {
        throw new UpstreamError("Fake Store API returned an unexpected payload");
      }
      return data as FakeStoreProduct[];
    } catch (error) {
      if (error instanceof UpstreamError) {
        throw error;
      }
      if (error instanceof Error && error.name === "AbortError") {
        throw new UpstreamError(
          `Fake Store API timed out after ${this.timeoutMs}ms`,
        );
      }
      const message =
        error instanceof Error ? error.message : "Unknown upstream error";
      throw new UpstreamError(`Fake Store API request failed: ${message}`);
    } finally {
      clearTimeout(timer);
    }
  }
}

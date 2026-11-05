import type { Product } from "../../domain/product";
import type { ProductRepository } from "../../domain/ports";
import { FakeStoreClient } from "./client";
import { mapFakeStoreProduct } from "./mapper";

export interface FakeStoreRepositoryOptions {
  client: FakeStoreClient;
  cacheTtlMs: number;
  now?: () => number;
}

interface CacheEntry {
  products: Product[];
  expiresAt: number;
}

/**
 * ProductRepository backed by Fake Store API with an in-memory TTL cache.
 * At Fake Store scale (~20 products) fetching all and filtering in-process is fine.
 */
export class FakeStoreProductRepository implements ProductRepository {
  private readonly client: FakeStoreClient;
  private readonly cacheTtlMs: number;
  private readonly now: () => number;
  private cache: CacheEntry | null = null;
  private inflight: Promise<Product[]> | null = null;

  constructor(options: FakeStoreRepositoryOptions) {
    this.client = options.client;
    this.cacheTtlMs = options.cacheTtlMs;
    this.now = options.now ?? Date.now;
  }

  async findAll(): Promise<Product[]> {
    const cached = this.getFreshCache();
    if (cached) {
      return cached;
    }

    if (this.inflight) {
      return this.inflight;
    }

    this.inflight = this.refresh();
    try {
      return await this.inflight;
    } finally {
      this.inflight = null;
    }
  }

  async findById(id: number): Promise<Product | null> {
    const products = await this.findAll();
    return products.find((p) => p.id === id) ?? null;
  }

  /** Test helper — clear the in-memory cache. */
  clearCache(): void {
    this.cache = null;
  }

  private getFreshCache(): Product[] | null {
    if (!this.cache) {
      return null;
    }
    if (this.now() >= this.cache.expiresAt) {
      this.cache = null;
      return null;
    }
    return this.cache.products;
  }

  private async refresh(): Promise<Product[]> {
    const raw = await this.client.getProducts();
    const products = raw.map(mapFakeStoreProduct);
    this.cache = {
      products,
      expiresAt: this.now() + this.cacheTtlMs,
    };
    return products;
  }
}

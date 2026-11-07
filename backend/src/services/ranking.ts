import type { Product } from "../domain/product";

/**
 * Stable ranking: rate desc, then count desc, then id asc.
 * Used for featured products and category top-rated.
 */
export function compareByRating(a: Product, b: Product): number {
  if (b.rating.rate !== a.rating.rate) {
    return b.rating.rate - a.rating.rate;
  }
  if (b.rating.count !== a.rating.count) {
    return b.rating.count - a.rating.count;
  }
  return a.id - b.id;
}

export function sortByRating(products: Product[]): Product[] {
  return [...products].sort(compareByRating);
}

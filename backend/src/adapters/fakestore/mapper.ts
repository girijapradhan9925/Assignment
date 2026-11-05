import type { Product } from "../../domain/product";
import type { FakeStoreProduct } from "./types";
import { slugifyCategory } from "./slug";

export function mapFakeStoreProduct(raw: FakeStoreProduct): Product {
  return {
    id: raw.id,
    title: raw.title,
    price: raw.price,
    description: raw.description,
    category: raw.category,
    categorySlug: slugifyCategory(raw.category),
    imageUrl: raw.image,
    rating: {
      rate: raw.rating.rate,
      count: raw.rating.count,
    },
  };
}

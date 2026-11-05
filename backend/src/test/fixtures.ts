import type { Product } from "../domain/product";
import type { EmailProvider, ProductRepository } from "../domain/ports";
import type { EnquiryEmailPayload } from "../domain/enquiry";
import { slugifyCategory } from "../adapters/fakestore/slug";

export function makeProduct(
  overrides: Partial<Product> & Pick<Product, "id" | "title">,
): Product {
  const category = overrides.category ?? "electronics";
  return {
    id: overrides.id,
    title: overrides.title,
    price: overrides.price ?? 99.99,
    description: overrides.description ?? `${overrides.title} description`,
    category,
    categorySlug: overrides.categorySlug ?? slugifyCategory(category),
    imageUrl: overrides.imageUrl ?? `https://example.com/${overrides.id}.png`,
    rating: overrides.rating ?? { rate: 4.0, count: 100 },
  };
}

export const sampleProducts: Product[] = [
  makeProduct({
    id: 1,
    title: "Fjallraven Backpack",
    category: "men's clothing",
    rating: { rate: 3.9, count: 120 },
  }),
  makeProduct({
    id: 2,
    title: "Mens Casual Premium T-Shirt",
    category: "men's clothing",
    rating: { rate: 4.1, count: 259 },
  }),
  makeProduct({
    id: 3,
    title: "Gold Petite Micropave",
    category: "jewelery",
    rating: { rate: 4.6, count: 400 },
  }),
  makeProduct({
    id: 4,
    title: "White Gold Plated Princess",
    category: "jewelery",
    rating: { rate: 3.9, count: 70 },
  }),
  makeProduct({
    id: 5,
    title: "WD 2TB External Hard Drive",
    category: "electronics",
    description: "USB 3.0 portable storage for backups",
    rating: { rate: 4.8, count: 203 },
  }),
  makeProduct({
    id: 6,
    title: "SanDisk SSD PLUS 1TB",
    category: "electronics",
    rating: { rate: 4.8, count: 500 },
  }),
  makeProduct({
    id: 7,
    title: "Rain Jacket Women",
    category: "women's clothing",
    rating: { rate: 4.2, count: 180 },
  }),
  makeProduct({
    id: 8,
    title: "MBJ Women's Short Sleeve",
    category: "women's clothing",
    rating: { rate: 4.7, count: 130 },
  }),
];

export class InMemoryProductRepository implements ProductRepository {
  constructor(private products: Product[] = sampleProducts) {}

  async findAll(): Promise<Product[]> {
    return [...this.products];
  }

  async findById(id: number): Promise<Product | null> {
    return this.products.find((p) => p.id === id) ?? null;
  }
}

export class RecordingEmailProvider implements EmailProvider {
  readonly sent: EnquiryEmailPayload[] = [];
  failWith: Error | null = null;

  async send(payload: EnquiryEmailPayload): Promise<void> {
    if (this.failWith) {
      throw this.failWith;
    }
    this.sent.push(payload);
  }
}

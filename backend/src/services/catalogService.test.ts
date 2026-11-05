import { describe, expect, it } from "vitest";
import { CatalogService } from "./catalogService";
import { InMemoryProductRepository, sampleProducts } from "../test/fixtures";
import { NotFoundError } from "../domain/errors";

function createService() {
  return new CatalogService({
    repository: new InMemoryProductRepository(sampleProducts),
    featuredLimit: 5,
    categoryTopRatedLimit: 3,
  });
}

describe("CatalogService", () => {
  describe("getFeatured", () => {
    it("returns the top N products by rating then count", async () => {
      const service = createService();
      const featured = await service.getFeatured(3);

      expect(featured.map((p) => p.id)).toEqual([6, 5, 8]);
      // 6 and 5 both rate 4.8; 6 wins on count (500 > 203)
      expect(featured[0].rating.rate).toBe(4.8);
      expect(featured[0].rating.count).toBe(500);
    });

    it("respects the configured default limit", async () => {
      const service = createService();
      const featured = await service.getFeatured();
      expect(featured).toHaveLength(5);
    });
  });

  describe("listProducts", () => {
    it("filters by case-insensitive search across title, description and category", async () => {
      const service = createService();
      const byTitle = await service.listProducts({ search: "backpack" });
      expect(byTitle.items.map((p) => p.id)).toEqual([1]);

      const byDescription = await service.listProducts({ search: "USB 3.0" });
      expect(byDescription.items.map((p) => p.id)).toEqual([5]);

      const byCategory = await service.listProducts({ search: "jewelery" });
      expect(byCategory.total).toBe(2);
    });

    it("filters by category slug", async () => {
      const service = createService();
      const result = await service.listProducts({ category: "electronics" });
      expect(result.items.map((p) => p.id).sort()).toEqual([5, 6]);
      expect(result.total).toBe(2);
    });

    it("applies offset and limit", async () => {
      const service = createService();
      const result = await service.listProducts({ offset: 1, limit: 2 });
      expect(result.total).toBe(8);
      expect(result.items).toHaveLength(2);
      expect(result.items[0].id).toBe(2);
    });
  });

  describe("getProduct", () => {
    it("returns a product by id", async () => {
      const service = createService();
      const product = await service.getProduct(3);
      expect(product.title).toBe("Gold Petite Micropave");
    });

    it("throws NotFoundError for unknown ids", async () => {
      const service = createService();
      await expect(service.getProduct(999)).rejects.toBeInstanceOf(NotFoundError);
    });
  });

  describe("listCategories", () => {
    it("returns unique categories sorted by name", async () => {
      const service = createService();
      const categories = await service.listCategories();
      expect(categories.map((c) => c.slug)).toEqual([
        "electronics",
        "jewelery",
        "mens-clothing",
        "womens-clothing",
      ]);
    });
  });

  describe("getCategory", () => {
    it("splits top-rated from others", async () => {
      const service = createService();
      const result = await service.getCategory("mens-clothing");

      expect(result.category).toEqual({
        slug: "mens-clothing",
        name: "men's clothing",
      });
      // Only 2 products in men's clothing — both fit in top 3, others empty
      expect(result.topRated.map((p) => p.id)).toEqual([2, 1]);
      expect(result.others).toEqual([]);
    });

    it("puts overflow into others when category is larger than the top limit", async () => {
      const template = sampleProducts[0];
      const many = Array.from({ length: 5 }, (_, i) => ({
        ...template,
        id: 100 + i,
        title: `Extra ${i}`,
        category: "electronics",
        categorySlug: "electronics",
        rating: { rate: 5 - i * 0.1, count: 10 },
      }));

      const service = new CatalogService({
        repository: new InMemoryProductRepository(many),
        featuredLimit: 5,
        categoryTopRatedLimit: 3,
      });

      const result = await service.getCategory("electronics");
      expect(result.topRated).toHaveLength(3);
      expect(result.others).toHaveLength(2);
      expect(result.topRated[0].rating.rate).toBeGreaterThanOrEqual(
        result.topRated[2].rating.rate,
      );
    });

    it("throws NotFoundError for unknown slugs", async () => {
      const service = createService();
      await expect(service.getCategory("unknown")).rejects.toBeInstanceOf(
        NotFoundError,
      );
    });
  });
});

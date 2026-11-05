import { describe, expect, it } from "vitest";
import { mapFakeStoreProduct } from "./mapper";
import { slugifyCategory } from "./slug";

describe("slugifyCategory", () => {
  it("strips apostrophes and spaces", () => {
    expect(slugifyCategory("men's clothing")).toBe("mens-clothing");
    expect(slugifyCategory("women's clothing")).toBe("womens-clothing");
    expect(slugifyCategory("jewelery")).toBe("jewelery");
  });
});

describe("mapFakeStoreProduct", () => {
  it("maps Fake Store fields onto the stable Product contract", () => {
    const product = mapFakeStoreProduct({
      id: 1,
      title: "Backpack",
      price: 109.95,
      description: "A pack",
      category: "men's clothing",
      image: "https://fakestoreapi.com/img/1.png",
      rating: { rate: 3.9, count: 120 },
    });

    expect(product).toEqual({
      id: 1,
      title: "Backpack",
      price: 109.95,
      description: "A pack",
      category: "men's clothing",
      categorySlug: "mens-clothing",
      imageUrl: "https://fakestoreapi.com/img/1.png",
      rating: { rate: 3.9, count: 120 },
    });
  });
});

import { describe, expect, it } from "vitest";
import request from "supertest";
import { createApp } from "../app";
import { CatalogService } from "../services/catalogService";
import { EnquiryService } from "../services/enquiryService";
import {
  InMemoryProductRepository,
  RecordingEmailProvider,
  sampleProducts,
} from "../test/fixtures";

function buildApp(email = new RecordingEmailProvider()) {
  const repository = new InMemoryProductRepository(sampleProducts);
  const catalogService = new CatalogService({
    repository,
    featuredLimit: 5,
    categoryTopRatedLimit: 3,
  });
  const enquiryService = new EnquiryService({
    repository,
    emailProvider: email,
    salesInbox: "sales@example.com",
  });
  return {
    app: createApp({
      catalogService,
      enquiryService,
      corsOrigins: "*",
    }),
    email,
  };
}

describe("HTTP routes", () => {
  it("GET /health returns ok", async () => {
    const { app } = buildApp();
    const res = await request(app).get("/health");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: "ok" });
  });

  it("GET /api/products/featured returns top rated items", async () => {
    const { app } = buildApp();
    const res = await request(app).get("/api/products/featured?limit=2");
    expect(res.status).toBe(200);
    expect(res.body.items).toHaveLength(2);
    expect(res.body.items[0].id).toBe(6);
  });

  it("GET /api/products supports search", async () => {
    const { app } = buildApp();
    const res = await request(app).get("/api/products?search=ssd");
    expect(res.status).toBe(200);
    expect(res.body.items.map((p: { id: number }) => p.id)).toEqual([6]);
  });

  it("GET /api/products/:id returns a product", async () => {
    const { app } = buildApp();
    const res = await request(app).get("/api/products/3");
    expect(res.status).toBe(200);
    expect(res.body.title).toBe("Gold Petite Micropave");
  });

  it("GET /api/products/:id returns 404 for unknown ids", async () => {
    const { app } = buildApp();
    const res = await request(app).get("/api/products/999");
    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe("NOT_FOUND");
  });

  it("GET /api/products/:id rejects non-numeric ids", async () => {
    const { app } = buildApp();
    const res = await request(app).get("/api/products/abc");
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe("VALIDATION_ERROR");
  });

  it("GET /api/categories lists categories", async () => {
    const { app } = buildApp();
    const res = await request(app).get("/api/categories");
    expect(res.status).toBe(200);
    expect(res.body.items.length).toBeGreaterThan(0);
    expect(res.body.items[0]).toHaveProperty("slug");
    expect(res.body.items[0]).toHaveProperty("name");
  });

  it("GET /api/categories/:slug returns topRated and others", async () => {
    const { app } = buildApp();
    const res = await request(app).get("/api/categories/electronics");
    expect(res.status).toBe(200);
    expect(res.body.category.slug).toBe("electronics");
    expect(res.body.topRated.length).toBeGreaterThan(0);
    expect(Array.isArray(res.body.others)).toBe(true);
  });

  it("POST /api/enquiries accepts a valid body and returns 202", async () => {
    const { app, email } = buildApp();
    const res = await request(app)
      .post("/api/enquiries")
      .send({
        productId: 1,
        name: "Ada Lovelace",
        email: "ada@example.com",
        message: "Please call me",
      });

    expect(res.status).toBe(202);
    expect(res.body.reference).toBeTruthy();
    expect(email.sent).toHaveLength(1);
  });

  it("POST /api/enquiries rejects invalid bodies", async () => {
    const { app } = buildApp();
    const res = await request(app).post("/api/enquiries").send({
      productId: 1,
      name: "",
      email: "not-an-email",
      message: "",
    });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe("VALIDATION_ERROR");
  });

  it("POST /api/enquiries returns 404 when the product is missing", async () => {
    const { app } = buildApp();
    const res = await request(app).post("/api/enquiries").send({
      productId: 999,
      name: "Ada",
      email: "ada@example.com",
      message: "Hello",
    });
    expect(res.status).toBe(404);
  });
});

import { Router } from "express";
import rateLimit from "express-rate-limit";
import type { CatalogService } from "../services/catalogService";
import type { EnquiryService } from "../services/enquiryService";
import { asyncHandler } from "./asyncHandler";
import {
  categorySlugParamsSchema,
  enquiryBodySchema,
  featuredQuerySchema,
  productIdParamsSchema,
  productsQuerySchema,
} from "./schemas";

export interface CreateRoutesOptions {
  catalogService: CatalogService;
  enquiryService: EnquiryService;
}

export function createRoutes(options: CreateRoutesOptions): Router {
  const { catalogService, enquiryService } = options;
  const router = Router();

  const enquiryLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 30,
    standardHeaders: true,
    legacyHeaders: false,
    message: {
      error: {
        code: "RATE_LIMITED",
        message: "Too many enquiries from this address. Try again later.",
      },
    },
  });

  router.get(
    "/health",
    (_req, res) => {
      res.json({ status: "ok" });
    },
  );

  router.get(
    "/api/products/featured",
    asyncHandler(async (req, res) => {
      const query = featuredQuerySchema.parse(req.query);
      const items = await catalogService.getFeatured(query.limit);
      res.json({ items });
    }),
  );

  router.get(
    "/api/products",
    asyncHandler(async (req, res) => {
      const query = productsQuerySchema.parse(req.query);
      const result = await catalogService.listProducts(query);
      res.json(result);
    }),
  );

  router.get(
    "/api/products/:id",
    asyncHandler(async (req, res) => {
      const { id } = productIdParamsSchema.parse(req.params);
      const product = await catalogService.getProduct(id);
      res.json(product);
    }),
  );

  router.get(
    "/api/categories",
    asyncHandler(async (_req, res) => {
      const items = await catalogService.listCategories();
      res.json({ items });
    }),
  );

  router.get(
    "/api/categories/:slug",
    asyncHandler(async (req, res) => {
      const { slug } = categorySlugParamsSchema.parse(req.params);
      const result = await catalogService.getCategory(slug);
      res.json(result);
    }),
  );

  router.post(
    "/api/enquiries",
    enquiryLimiter,
    asyncHandler(async (req, res) => {
      const body = enquiryBodySchema.parse(req.body);
      const result = await enquiryService.submit(body);
      res.status(202).json(result);
    }),
  );

  return router;
}

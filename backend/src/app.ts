import express from "express";
import cors from "cors";
import helmet from "helmet";
import type { CatalogService } from "./services/catalogService";
import type { EnquiryService } from "./services/enquiryService";
import { createRoutes } from "./http/routes";
import { errorHandler } from "./http/errorHandler";

export interface CreateAppOptions {
  catalogService: CatalogService;
  enquiryService: EnquiryService;
  corsOrigins: string;
}

/**
 * Express app factory — dependencies are injected so tests can pass fakes.
 */
export function createApp(options: CreateAppOptions) {
  const app = express();

  app.use(helmet());
  app.use(
    cors({
      origin:
        options.corsOrigins === "*"
          ? true
          : options.corsOrigins.split(",").map((o) => o.trim()),
    }),
  );
  app.use(express.json({ limit: "32kb" }));

  app.use(
    createRoutes({
      catalogService: options.catalogService,
      enquiryService: options.enquiryService,
    }),
  );

  app.use(errorHandler);

  return app;
}

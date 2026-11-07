import type { ProductRepository } from "../domain/ports";
import type {
  Category,
  CategoryDetailResult,
  Product,
  ProductListResult,
} from "../domain/product";
import { NotFoundError } from "../domain/errors";
import { sortByRating } from "./ranking";

export interface CatalogServiceOptions {
  repository: ProductRepository;
  featuredLimit: number;
  categoryTopRatedLimit: number;
}

export interface ListProductsQuery {
  search?: string;
  category?: string;
  limit?: number;
  offset?: number;
}

export class CatalogService {
  private readonly repository: ProductRepository;
  private readonly featuredLimit: number;
  private readonly categoryTopRatedLimit: number;

  constructor(options: CatalogServiceOptions) {
    this.repository = options.repository;
    this.featuredLimit = options.featuredLimit;
    this.categoryTopRatedLimit = options.categoryTopRatedLimit;
  }

  async getFeatured(limit = this.featuredLimit): Promise<Product[]> {
    const products = await this.repository.findAll();
    return sortByRating(products).slice(0, limit);
  }

  async listProducts(query: ListProductsQuery = {}): Promise<ProductListResult> {
    let products = await this.repository.findAll();

    if (query.category) {
      const slug = query.category.toLowerCase();
      products = products.filter((p) => p.categorySlug === slug);
    }

    if (query.search && query.search.trim().length > 0) {
      const term = query.search.trim().toLowerCase();
      products = products.filter((p) => matchesSearch(p, term));
    }

    const total = products.length;
    const offset = Math.max(0, query.offset ?? 0);
    const limit = query.limit ?? total;
    const items = products.slice(offset, offset + limit);

    return { items, total };
  }

  async getProduct(id: number): Promise<Product> {
    const product = await this.repository.findById(id);
    if (!product) {
      throw new NotFoundError(`Product ${id} not found`);
    }
    return product;
  }

  async listCategories(): Promise<Category[]> {
    const products = await this.repository.findAll();
    const bySlug = new Map<string, Category>();
    for (const product of products) {
      if (!bySlug.has(product.categorySlug)) {
        bySlug.set(product.categorySlug, {
          slug: product.categorySlug,
          name: product.category,
        });
      }
    }
    return [...bySlug.values()].sort((a, b) => a.name.localeCompare(b.name));
  }

  async getCategory(slug: string): Promise<CategoryDetailResult> {
    const products = await this.repository.findAll();
    const inCategory = products.filter((p) => p.categorySlug === slug);

    if (inCategory.length === 0) {
      throw new NotFoundError(`Category '${slug}' not found`);
    }

    const ranked = sortByRating(inCategory);
    const topRated = ranked.slice(0, this.categoryTopRatedLimit);
    const topIds = new Set(topRated.map((p) => p.id));
    const others = ranked.filter((p) => !topIds.has(p.id));

    return {
      category: {
        slug,
        name: inCategory[0].category,
      },
      topRated,
      others,
    };
  }
}

function matchesSearch(product: Product, term: string): boolean {
  return (
    product.title.toLowerCase().includes(term) ||
    product.description.toLowerCase().includes(term) ||
    product.category.toLowerCase().includes(term)
  );
}

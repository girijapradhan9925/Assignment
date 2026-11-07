export interface ProductRating {
  rate: number;
  count: number;
}

export interface Product {
  id: number;
  title: string;
  price: number;
  description: string;
  category: string;
  categorySlug: string;
  imageUrl: string;
  rating: ProductRating;
}

export interface Category {
  slug: string;
  name: string;
}

export interface ProductListResult {
  items: Product[];
  total: number;
}

export interface CategoryDetailResult {
  category: Category;
  topRated: Product[];
  others: Product[];
}

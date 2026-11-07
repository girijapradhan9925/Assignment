export interface EnquiryRequest {
  productId: number;
  name: string;
  email: string;
  phone?: string;
  message: string;
}

export interface EnquiryResult {
  reference: string;
}

export interface EnquiryEmailPayload {
  to: string;
  subject: string;
  text: string;
  replyTo: string;
}

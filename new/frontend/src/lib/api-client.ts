import { oktaAuth } from "./okta-config";

const API_BASE = "/api";

export class ApiError extends Error {
  public readonly status: number;

  constructor(status: number, message: string) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }
}

async function getAuthHeader(): Promise<Record<string, string>> {
  if (import.meta.env.DEV) return {};
  try {
    const tokenContainer = await oktaAuth.tokenManager.get("accessToken");
    if (tokenContainer && "accessToken" in tokenContainer) {
      return { Authorization: `Bearer ${tokenContainer.accessToken}` };
    }
  } catch {
    // No token available — request will proceed unauthenticated
  }
  return {};
}

async function request<T>(url: string, options?: RequestInit): Promise<T> {
  const authHeader = await getAuthHeader();

  const response = await fetch(`${API_BASE}${url}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...authHeader,
      ...options?.headers,
    },
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new ApiError(response.status, errorText);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return response.json() as Promise<T>;
}

export const apiClient = {
  get: <T>(url: string) => request<T>(url),

  post: <T>(url: string, body?: unknown) =>
    request<T>(url, {
      method: "POST",
      body: body !== undefined ? JSON.stringify(body) : undefined,
    }),

  put: <T>(url: string, body: unknown) =>
    request<T>(url, {
      method: "PUT",
      body: JSON.stringify(body),
    }),

  delete: <T>(url: string) =>
    request<T>(url, { method: "DELETE" }),
};

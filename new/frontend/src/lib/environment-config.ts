/**
 * Environment configuration for the ARA application.
 * Provides environment name and theme colors for the environment banner.
 */

export type EnvironmentName = "Development" | "Test" | "Production";

export interface EnvironmentConfig {
  name: EnvironmentName;
  color: string;
  backgroundColor: string;
  borderColor: string;
}

const ENVIRONMENT_THEMES: Record<EnvironmentName, EnvironmentConfig> = {
  Development: {
    name: "Development",
    color: "#1e3a8a", // blue-900
    backgroundColor: "#dbeafe", // blue-100
    borderColor: "#3b82f6", // blue-500
  },
  Test: {
    name: "Test",
    color: "#78350f", // yellow-900
    backgroundColor: "#fef3c7", // yellow-100
    borderColor: "#f59e0b", // yellow-500
  },
  Production: {
    name: "Production",
    color: "#14532d", // green-900
    backgroundColor: "#dcfce7", // green-100
    borderColor: "#22c55e", // green-500
  },
};

/**
 * Gets the current environment configuration.
 * Defaults to "Development" if not configured or invalid.
 */
export function getEnvironmentConfig(): EnvironmentConfig {
  const envName = import.meta.env.VITE_ENVIRONMENT_NAME as EnvironmentName;

  // Validate and return the theme, defaulting to Development
  if (envName && envName in ENVIRONMENT_THEMES) {
    return ENVIRONMENT_THEMES[envName];
  }

  console.warn(
    `Invalid or missing VITE_ENVIRONMENT_NAME: "${envName}". Defaulting to Development.`
  );
  return ENVIRONMENT_THEMES.Development;
}

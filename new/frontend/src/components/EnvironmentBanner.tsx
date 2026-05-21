import { getEnvironmentConfig } from "@/lib/environment-config";

/**
 * EnvironmentBanner displays the current environment (Development, Test, Production)
 * at the top of the application with color-coded styling.
 *
 * This component is globally injected and does not require per-page imports.
 */
export function EnvironmentBanner() {
  const env = getEnvironmentConfig();

  return (
    <div
      className="px-4 py-2 text-center text-sm font-semibold border-b-2"
      style={{
        color: env.color,
        backgroundColor: env.backgroundColor,
        borderBottomColor: env.borderColor,
      }}
      role="banner"
      aria-live="polite"
    >
      Environment: {env.name}
    </div>
  );
}

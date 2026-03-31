import { useEffect } from "react";
import { useOktaAuth } from "@okta/okta-react";
import { LoadingState } from "@/components/shared/LoadingState";

interface RequireAuthProps {
  children: React.ReactNode;
}

export function RequireAuth({ children }: RequireAuthProps) {
  const { authState, oktaAuth } = useOktaAuth();

  useEffect(() => {
    if (import.meta.env.DEV) return;
    if (!authState) return;
    if (!authState.isAuthenticated) {
      oktaAuth.signInWithRedirect();
    }
  }, [authState, oktaAuth]);

  if (import.meta.env.DEV) return <>{children}</>;
  if (!authState || !authState.isAuthenticated) {
    return <LoadingState />;
  }

  return <>{children}</>;
}

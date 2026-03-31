import { LoginCallback } from "@okta/okta-react";
import { LoadingState } from "@/components/shared/LoadingState";
import { ErrorState } from "@/components/shared/ErrorState";

export function LoginCallbackPage() {
  return (
    <LoginCallback
      loadingElement={<LoadingState />}
      errorComponent={({ error }) => (
        <ErrorState message={error.message} />
      )}
    />
  );
}

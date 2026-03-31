import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter, useNavigate } from "react-router-dom";
import { QueryClientProvider } from "@tanstack/react-query";
import { Security } from "@okta/okta-react";
import { toRelativeUrl, OktaAuth } from "@okta/okta-auth-js";
import { oktaAuth } from "@/lib/okta-config";
import { queryClient } from "@/lib/query-client";
import { ErrorBoundary } from "@/components/ErrorBoundary";
import App from "./App";
import "./index.css";

function OktaSecurityWrapper() {
  const navigate = useNavigate();

  const restoreOriginalUri = (_oktaAuth: OktaAuth, originalUri: string) => {
    navigate(toRelativeUrl(originalUri || "/", window.location.origin));
  };

  return (
    <Security oktaAuth={oktaAuth} restoreOriginalUri={restoreOriginalUri}>
      <App />
    </Security>
  );
}

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <ErrorBoundary>
      <QueryClientProvider client={queryClient}>
        <BrowserRouter>
          <OktaSecurityWrapper />
        </BrowserRouter>
      </QueryClientProvider>
    </ErrorBoundary>
  </StrictMode>,
);

"use client";

import * as React from "react";

interface ErrorBoundaryState {
  hasError: boolean;
  error?: Error;
}

interface ErrorBoundaryProps {
  children: React.ReactNode;
  fallback?: React.ComponentType<{ error?: Error; resetError: () => void }>;
}

const DefaultErrorFallback: React.FC<{
  error?: Error;
  resetError: () => void;
}> = ({ error, resetError }) => (
  <div className="flex flex-col items-center justify-center min-h-[200px] p-6 border rounded-lg bg-muted/50">
    <h2 className="text-lg font-semibold mb-2">Something went wrong</h2>
    <p className="text-sm text-muted-foreground mb-4 text-center">
      {error?.message ||
        "An unexpected error occurred. This might be due to React 19 compatibility issues."}
    </p>
    <button
      type="button"
      onClick={resetError}
      className="px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 transition-colors"
    >
      Try again
    </button>
  </div>
);

export class React19ErrorBoundary extends React.Component<
  ErrorBoundaryProps,
  ErrorBoundaryState
> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    // Specifically catch React 19 flushSync and concurrent rendering errors
    const isReact19Error =
      error.message.includes("flushSync") ||
      error.message.includes("Cannot update a component") ||
      error.message.includes("concurrent rendering");

    return {
      hasError: true,
      error: isReact19Error ? error : error,
    };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    // Log React 19 specific errors for debugging
    if (
      error.message.includes("flushSync") ||
      error.message.includes("concurrent")
    ) {
      console.warn("React 19 Compatibility Issue:", {
        error: error.message,
        stack: error.stack,
        componentStack: errorInfo.componentStack,
      });
    }
  }

  resetError = () => {
    this.setState({ hasError: false, error: undefined });
  };

  render() {
    if (this.state.hasError) {
      const FallbackComponent = this.props.fallback || DefaultErrorFallback;
      return (
        <FallbackComponent
          error={this.state.error}
          resetError={this.resetError}
        />
      );
    }

    return this.props.children;
  }
}

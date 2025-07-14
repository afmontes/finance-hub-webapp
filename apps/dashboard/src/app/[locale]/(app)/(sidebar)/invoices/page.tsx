import { ErrorFallback } from "@/components/error-fallback";
import { InvoiceHeader } from "@/components/invoice-header";
import {
  InvoicePaymentScore,
  InvoicePaymentScoreSkeleton,
} from "@/components/invoice-payment-score";
import { InvoiceSummarySkeleton } from "@/components/invoice-summary";
import { InvoicesOpen } from "@/components/invoices-open";
import { InvoicesOverdue } from "@/components/invoices-overdue";
import { InvoicesPaid } from "@/components/invoices-paid";
import { DataTable } from "@/components/tables/invoices/data-table";
import { InvoiceSkeleton } from "@/components/tables/invoices/skeleton";
import { loadInvoiceFilterParams } from "@/hooks/use-invoice-filter-params";
import { loadSortParams } from "@/hooks/use-sort-params";
import { batchPrefetch, trpc } from "@/trpc/server";
import { getInitialInvoicesColumnVisibility } from "@/utils/columns";
import { isInvoiceFeatureEnabled } from "@/utils/feature-flags";
import { Icons } from "@midday/ui/icons";
import type { Metadata } from "next";
import { ErrorBoundary } from "next/dist/client/components/error-boundary";
import { redirect } from "next/navigation";
import type { SearchParams } from "nuqs";
import { Suspense } from "react";

export const metadata: Metadata = {
  title: "Invoices | Midday",
};

type Props = {
  searchParams: Promise<SearchParams>;
};

function FeatureDisabledPage() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] text-center space-y-6">
      <div className="flex items-center justify-center w-16 h-16 rounded-full bg-muted">
        <Icons.Invoice size={32} className="text-muted-foreground" />
      </div>

      <div className="space-y-2">
        <h2 className="text-2xl font-semibold">Invoice Feature Disabled</h2>
        <p className="text-muted-foreground max-w-md">
          The invoice functionality has been disabled in this application. This
          helps focus on core personal finance tracking features.
        </p>
      </div>

      <div className="text-sm text-muted-foreground">
        <p>
          To enable this feature, contact your administrator or check your
          configuration.
        </p>
      </div>
    </div>
  );
}

export default async function Page(props: Props) {
  // Check if invoice feature is enabled
  if (!isInvoiceFeatureEnabled()) {
    return <FeatureDisabledPage />;
  }

  const searchParams = await props.searchParams;

  const filter = loadInvoiceFilterParams(searchParams);
  const { sort } = loadSortParams(searchParams);

  const columnVisibility = getInitialInvoicesColumnVisibility();

  batchPrefetch([
    trpc.invoice.get.infiniteQueryOptions({
      ...filter,
      sort,
    }),
    trpc.invoice.invoiceSummary.queryOptions({
      status: "unpaid",
    }),
    trpc.invoice.invoiceSummary.queryOptions({
      status: "paid",
    }),
    trpc.invoice.invoiceSummary.queryOptions({
      status: "overdue",
    }),
    trpc.invoice.paymentStatus.queryOptions(),
  ]);

  return (
    <div className="flex flex-col gap-6">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 pt-6">
        <Suspense fallback={<InvoiceSummarySkeleton />}>
          <InvoicesOpen />
        </Suspense>
        <Suspense fallback={<InvoiceSummarySkeleton />}>
          <InvoicesOverdue />
        </Suspense>
        <Suspense fallback={<InvoiceSummarySkeleton />}>
          <InvoicesPaid />
        </Suspense>
        <Suspense fallback={<InvoicePaymentScoreSkeleton />}>
          <InvoicePaymentScore />
        </Suspense>
      </div>

      <InvoiceHeader />

      <ErrorBoundary errorComponent={ErrorFallback}>
        <Suspense fallback={<InvoiceSkeleton />}>
          <DataTable columnVisibility={columnVisibility} />
        </Suspense>
      </ErrorBoundary>
    </div>
  );
}

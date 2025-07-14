import { ChartSelectors } from "@/components/charts/chart-selectors";
import { Charts } from "@/components/charts/charts";
import { EmptyState } from "@/components/charts/empty-state";
import { OverviewModal } from "@/components/modals/overview-modal";
import { Widgets } from "@/components/widgets";
import { defaultPeriod } from "@/components/widgets/spending/data";
import { loadMetricsParams } from "@/hooks/use-metrics-params";
import { HydrateClient, batchPrefetch, trpc } from "@/trpc/server";
import { getQueryClient } from "@/trpc/server";
import { Cookies } from "@/utils/constants";
import { isInvoiceFeatureEnabled } from "@/utils/feature-flags";
import type { Metadata } from "next";
import { cookies } from "next/headers";
import type { SearchParams } from "nuqs";

export const metadata: Metadata = {
  title: "Overview | Midday",
};

type Props = {
  searchParams: Promise<SearchParams>;
};

export default async function Overview(props: Props) {
  const queryClient = getQueryClient();
  const searchParams = await props.searchParams;
  const { from, to, currency } = loadMetricsParams(searchParams);

  const cookieStore = await cookies();
  const hideConnectFlow =
    cookieStore.get(Cookies.HideConnectFlow)?.value === "true";

  // Prefetch core queries (always enabled)
  batchPrefetch([
    trpc.metrics.expense.queryOptions({
      from,
      to,
      currency: currency ?? undefined,
    }),
    trpc.metrics.profit.queryOptions({
      from,
      to,
      currency: currency ?? undefined,
    }),
    trpc.metrics.burnRate.queryOptions({
      from,
      to,
      currency: currency ?? undefined,
    }),
    trpc.metrics.runway.queryOptions({
      from,
      to,
      currency: currency ?? undefined,
    }),
    trpc.bankAccounts.balances.queryOptions(),
    trpc.documents.get.queryOptions({ pageSize: 10 }),
    trpc.metrics.spending.queryOptions({
      from: defaultPeriod.from,
      to: defaultPeriod.to,
      currency: currency ?? undefined,
    }),
    trpc.transactions.get.queryOptions({
      pageSize: 15,
    }),
    trpc.inbox.get.queryOptions(),
  ]);

  // Conditionally prefetch invoice queries if feature is enabled
  if (isInvoiceFeatureEnabled()) {
    batchPrefetch([
      trpc.invoice.get.queryOptions({ pageSize: 10 }),
      trpc.invoice.paymentStatus.queryOptions(),
    ]);
  }

  // Load the data for the first visible chart
  await Promise.all([
    queryClient.fetchQuery(
      trpc.bankAccounts.get.queryOptions({
        enabled: true,
      }),
    ),
    queryClient.fetchQuery(
      trpc.metrics.revenue.queryOptions({
        from,
        to,
        currency: currency ?? undefined,
      }),
    ),
  ]);

  return (
    <HydrateClient>
      <div>
        <div className="h-[530px] mb-4">
          <ChartSelectors />

          <div className="mt-8 relative">
            <EmptyState />
            <Charts />
          </div>
        </div>

        <Widgets />
      </div>

      <OverviewModal hideConnectFlow={hideConnectFlow} />
    </HydrateClient>
  );
}

"use client";

import { useTRPC } from "@/trpc/client";
import {
  isCustomerFeatureEnabled,
  isInboxFeatureEnabled,
  isInvoiceFeatureEnabled,
  isTrackerFeatureEnabled,
} from "@/utils/feature-flags";
import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
} from "@midday/ui/carousel";
import { useQuery } from "@tanstack/react-query";
import * as React from "react";
import { AccountBalance } from "./account-balance";
import { Assistant } from "./assistant";
import { Inbox } from "./inbox";
import { Invoice } from "./invoice";
import { WidgetsNavigation } from "./navigation";
import { Spending } from "./spending";
import { Tracker } from "./tracker";
import { Transactions } from "./transactions/transactions";
import { Vault } from "./vault";

export function Widgets() {
  const trpc = useTRPC();

  const { data: accounts } = useQuery(
    trpc.bankAccounts.get.queryOptions({
      enabled: true,
    }),
  );

  // If the user has not connected any accounts, disable the widgets
  const disabled = !accounts?.length;

  const items = [
    <Assistant key="assistant" />,
    <Spending disabled={disabled} key="spending" />,
    <Transactions disabled={disabled} key="transactions" />,
    <AccountBalance key="account-balance" />,
    <Vault key="vault" />,
    // Conditionally include feature-specific widgets
    ...(isInvoiceFeatureEnabled() ? [<Invoice key="invoice" />] : []),
    ...(isTrackerFeatureEnabled() ? [<Tracker key="tracker" />] : []),
    ...(isInboxFeatureEnabled()
      ? [<Inbox key="inbox" disabled={disabled} />]
      : []),
  ];

  return (
    <Carousel
      className="flex flex-col"
      opts={{
        align: "start",
        watchDrag: false,
      }}
    >
      <WidgetsNavigation />
      <div className="ml-auto hidden md:flex">
        <CarouselPrevious className="static p-0 border-none hover:bg-transparent" />
        <CarouselNext className="static p-0 border-none hover:bg-transparent" />
      </div>

      <CarouselContent className="-ml-[20px] 2xl:-ml-[40px] flex-col md:flex-row space-y-6 md:space-y-0">
        {items.map((item, idx) => {
          return (
            <CarouselItem
              className="lg:basis-1/2 xl:basis-1/3 3xl:basis-1/4 pl-[20px] 2xl:pl-[40px]"
              key={idx.toString()}
            >
              {item}
            </CarouselItem>
          );
        })}
      </CarouselContent>
    </Carousel>
  );
}

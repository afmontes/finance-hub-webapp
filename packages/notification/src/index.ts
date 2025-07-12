import { Novu } from "@novu/node";
import { nanoid } from "nanoid";

// Initialize with proper API key or a valid format that won't cause validation errors
const novuKey = process.env.NOVU_API_KEY || process.env.NOVU_SECRET_KEY || "nv_dummy_key_12345678901234567890";
const novu = new Novu(novuKey);

const API_ENDPOINT = "https://api.novu.co/v1";

export enum TriggerEvents {
  TransactionNewInApp = "transaction_new_in_app",
  TransactionsNewInApp = "transactions_new_in_app",
  TransactionNewEmail = "transaction_new_email",
  InboxNewInApp = "inbox_new_in_app",
  MatchNewInApp = "match_in_app",
  InvoicePaidInApp = "invoice_paid_in_app",
  InvoicePaidEmail = "invoice_paid_email",
  InvoiceOverdueInApp = "invoice_overdue_in_app",
  InvoiceOverdueEmail = "invoice_overdue_email",
}

export enum NotificationTypes {
  Transaction = "transaction",
  Transactions = "transactions",
  Inbox = "inbox",
  Match = "match",
  Invoice = "invoice",
}

type TriggerUser = {
  subscriberId: string;
  email: string;
  fullName: string;
  avatarUrl?: string;
  teamId: string;
};

type TriggerPayload = {
  name: TriggerEvents;
  payload: any;
  user: TriggerUser;
  replyTo?: string;
  tenant?: string; // NOTE: Currently no way to listen for messages with tenant, we use team_id + user_id for unique
};

export async function trigger(data: TriggerPayload) {
  try {
    await novu.trigger(data.name, {
      to: {
        ...data.user,
        //   Prefix subscriber id with team id
        subscriberId: `${data.user.teamId}_${data.user.subscriberId}`,
      },
      payload: data.payload,
      tenant: data.tenant,
      overrides: {
        email: {
          replyTo: data.replyTo,
          // @ts-ignore
          headers: {
            "X-Entity-Ref-ID": nanoid(),
          },
        },
      },
    });
  } catch (error) {
    console.log(error);
  }
}

export async function triggerBulk(events: TriggerPayload[]) {
  try {
    await novu.bulkTrigger(
      events.map((data) => ({
        name: data.name,
        to: {
          ...data.user,
          //   Prefix subscriber id with team id
          subscriberId: `${data.user.teamId}_${data.user.subscriberId}`,
        },
        payload: data.payload,
        tenant: data.tenant,
        overrides: {
          email: {
            replyTo: data.replyTo,
            headers: {
              "X-Entity-Ref-ID": nanoid(),
            },
          },
        },
      })),
    );
  } catch (error) {
    console.log(error);
  }
}

type GetSubscriberPreferencesParams = {
  teamId: string;
  subscriberId: string;
};

export async function getSubscriberPreferences({
  subscriberId,
  teamId,
}: GetSubscriberPreferencesParams) {
  const response = await fetch(
    `${API_ENDPOINT}/subscribers/${teamId}_${subscriberId}/preferences?includeInactiveChannels=false`,
    {
      method: "GET",
      headers: {
        Authorization: `ApiKey ${novuKey}`,
      },
    },
  );

  return response.json();
}

type UpdateSubscriberPreferenceParams = {
  subscriberId: string;
  teamId: string;
  templateId: string;
  type: string;
  enabled: boolean;
};

export async function updateSubscriberPreference({
  subscriberId,
  teamId,
  templateId,
  type,
  enabled,
}: UpdateSubscriberPreferenceParams) {
  const response = await fetch(
    `${API_ENDPOINT}/subscribers/${teamId}_${subscriberId}/preferences/${templateId}`,
    {
      method: "PATCH",
      headers: {
        Authorization: `ApiKey ${novuKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        channel: {
          type,
          enabled,
        },
      }),
    },
  );

  return response.json();
}

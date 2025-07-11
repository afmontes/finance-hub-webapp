-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create helper functions first
CREATE OR REPLACE FUNCTION generate_random_string(length integer)
RETURNS text AS $$
DECLARE
  chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z}';
  result text := '';
  i integer := 0;
BEGIN
  IF length < 0 THEN
    RAISE EXCEPTION 'Given length cannot be less than 0';
  END IF;
  FOR i IN 1..length LOOP
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Create all the types and tables for Midday Finance Hub
CREATE TYPE "public"."account_type" AS ENUM('depository', 'credit', 'other_asset', 'loan', 'other_liability');
CREATE TYPE "public"."bankProviders" AS ENUM('gocardless', 'plaid', 'teller');
CREATE TYPE "public"."bank_providers" AS ENUM('gocardless', 'plaid', 'teller', 'enablebanking', 'pluggy');
CREATE TYPE "public"."connection_status" AS ENUM('disconnected', 'connected', 'unknown');
CREATE TYPE "public"."document_processing_status" AS ENUM('pending', 'processing', 'completed', 'failed');
CREATE TYPE "public"."inbox_account_providers" AS ENUM('gmail', 'outlook');
CREATE TYPE "public"."inbox_status" AS ENUM('processing', 'pending', 'archived', 'new', 'deleted', 'done');
CREATE TYPE "public"."inbox_type" AS ENUM('invoice', 'expense');
CREATE TYPE "public"."invoice_delivery_type" AS ENUM('create', 'create_and_send', 'scheduled');
CREATE TYPE "public"."invoice_size" AS ENUM('a4', 'letter');
CREATE TYPE "public"."invoice_status" AS ENUM('draft', 'overdue', 'paid', 'unpaid', 'canceled');
CREATE TYPE "public"."plans" AS ENUM('trial', 'starter', 'pro');
CREATE TYPE "public"."reportTypes" AS ENUM('profit', 'revenue', 'burn_rate', 'expense');
CREATE TYPE "public"."teamRoles" AS ENUM('owner', 'member');
CREATE TYPE "public"."trackerStatus" AS ENUM('in_progress', 'completed');
CREATE TYPE "public"."transactionCategories" AS ENUM('travel', 'office_supplies', 'meals', 'software', 'rent', 'income', 'equipment', 'transfer', 'internet_and_telephone', 'facilities_expenses', 'activity', 'uncategorized', 'taxes', 'other', 'salary', 'fees');
CREATE TYPE "public"."transactionMethods" AS ENUM('payment', 'card_purchase', 'card_atm', 'transfer', 'other', 'unknown', 'ach', 'interest', 'deposit', 'wire', 'fee');
CREATE TYPE "public"."transactionStatus" AS ENUM('posted', 'pending', 'excluded', 'completed', 'archived');
CREATE TYPE "public"."transaction_frequency" AS ENUM('weekly', 'biweekly', 'monthly', 'semi_monthly', 'annually', 'irregular', 'unknown');

-- Create the core tables
CREATE TABLE "document_tag_embeddings" (
	"slug" text PRIMARY KEY NOT NULL,
	"embedding" vector(1024),
	"name" text NOT NULL
);

CREATE TABLE "teams" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"name" text,
	"logo_url" text,
	"inbox_id" text DEFAULT generate_random_string(10),
	"email" text,
	"inbox_email" text,
	"inbox_forwarding" boolean DEFAULT true,
	"base_currency" text,
	"document_classification" boolean DEFAULT false,
	"flags" text[],
	"canceled_at" timestamp with time zone,
	"plan" "plans" DEFAULT 'trial' NOT NULL,
	CONSTRAINT "teams_inbox_id_key" UNIQUE("inbox_id")
);

CREATE TABLE "users" (
	"id" uuid PRIMARY KEY NOT NULL,
	"full_name" text,
	"avatar_url" text,
	"email" text,
	"team_id" uuid,
	"created_at" timestamp with time zone DEFAULT now(),
	"locale" text DEFAULT 'en',
	"week_starts_on_monday" boolean DEFAULT false,
	"timezone" text,
	"time_format" numeric DEFAULT '24',
	"date_format" text
);

CREATE TABLE "transaction_categories" (
	"id" uuid DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"team_id" uuid DEFAULT gen_random_uuid() NOT NULL,
	"color" text,
	"created_at" timestamp with time zone DEFAULT now(),
	"system" boolean DEFAULT false,
	"slug" text NOT NULL,
	"vat" numeric,
	"description" text,
	"embedding" vector(384),
	CONSTRAINT "transaction_categories_pkey" PRIMARY KEY("team_id","slug"),
	CONSTRAINT "unique_team_slug" UNIQUE("team_id","slug")
);

CREATE TABLE "bank_connections" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"institution_id" text NOT NULL,
	"expires_at" timestamp with time zone,
	"team_id" uuid NOT NULL,
	"name" text NOT NULL,
	"logo_url" text,
	"access_token" text,
	"enrollment_id" text,
	"provider" "bank_providers",
	"last_accessed" timestamp with time zone,
	"reference_id" text,
	"status" "connection_status" DEFAULT 'connected',
	"error_details" text,
	"error_retries" smallint DEFAULT '0',
	CONSTRAINT "unique_bank_connections" UNIQUE("institution_id","team_id")
);

CREATE TABLE "bank_accounts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"created_by" uuid NOT NULL,
	"team_id" uuid NOT NULL,
	"name" text,
	"currency" text,
	"bank_connection_id" uuid,
	"enabled" boolean DEFAULT true NOT NULL,
	"account_id" text NOT NULL,
	"balance" numeric DEFAULT '0',
	"manual" boolean DEFAULT false,
	"type" "account_type",
	"base_currency" text,
	"base_balance" numeric,
	"error_details" text,
	"error_retries" smallint,
	"account_reference" text
);

CREATE TABLE "transactions" (
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"date" date NOT NULL,
	"name" text NOT NULL,
	"method" "transactionMethods" NOT NULL,
	"amount" numeric NOT NULL,
	"currency" text NOT NULL,
	"team_id" uuid NOT NULL,
	"assigned_id" uuid,
	"note" varchar,
	"bank_account_id" uuid,
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"internal_id" text NOT NULL,
	"status" "transactionStatus" DEFAULT 'posted',
	"category" "transactionCategories",
	"balance" numeric,
	"manual" boolean DEFAULT false,
	"description" text,
	"category_slug" text,
	"base_amount" numeric,
	"base_currency" text,
	"recurring" boolean,
	"frequency" "transaction_frequency",
	"fts_vector" "tsvector" GENERATED ALWAYS AS (to_tsvector('english'::regconfig, ((COALESCE(name, ''::text) || ' '::text) || COALESCE(description, ''::text)))) STORED,
	"notified" boolean DEFAULT false,
	"internal" boolean DEFAULT false,
	CONSTRAINT "transactions_internal_id_key" UNIQUE("internal_id")
);

-- Enable Row Level Security
ALTER TABLE "document_tag_embeddings" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "teams" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "users" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "transaction_categories" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "bank_connections" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "bank_accounts" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "transactions" ENABLE ROW LEVEL SECURITY;

-- Add Foreign Key Constraints
ALTER TABLE "users" ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "users" ADD CONSTRAINT "users_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE set null ON UPDATE no action;
ALTER TABLE "transaction_categories" ADD CONSTRAINT "transaction_categories_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "bank_connections" ADD CONSTRAINT "bank_connections_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "bank_accounts" ADD CONSTRAINT "bank_accounts_bank_connection_id_fkey" FOREIGN KEY ("bank_connection_id") REFERENCES "public"."bank_connections"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "bank_accounts" ADD CONSTRAINT "bank_accounts_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "bank_accounts" ADD CONSTRAINT "public_bank_accounts_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "transactions" ADD CONSTRAINT "public_transactions_assigned_id_fkey" FOREIGN KEY ("assigned_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;
ALTER TABLE "transactions" ADD CONSTRAINT "public_transactions_team_id_fkey" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_bank_account_id_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "public"."bank_accounts"("id") ON DELETE cascade ON UPDATE no action;
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_category_slug_team_id_fkey" FOREIGN KEY ("team_id","category_slug") REFERENCES "public"."transaction_categories"("team_id","slug") ON DELETE no action ON UPDATE no action;

-- Create Indexes for Performance
CREATE INDEX "idx_transactions_date" ON "transactions" USING btree ("date");
CREATE INDEX "idx_transactions_fts_vector" ON "transactions" USING gin ("fts_vector");
CREATE INDEX "idx_transactions_team_id" ON "transactions" USING btree ("team_id");
CREATE INDEX "transaction_categories_team_id_idx" ON "transaction_categories" USING btree ("team_id");
CREATE INDEX "bank_connections_team_id_idx" ON "bank_connections" USING btree ("team_id");
CREATE INDEX "bank_accounts_team_id_idx" ON "bank_accounts" USING btree ("team_id");
CREATE INDEX "users_team_id_idx" ON "users" USING btree ("team_id");

-- Create basic RLS policies
CREATE POLICY "Enable insert for authenticated users only" ON "teams" AS PERMISSIVE FOR INSERT TO "authenticated" WITH CHECK (true);
CREATE POLICY "Teams can be selected by a member of the team" ON "teams" AS PERMISSIVE FOR SELECT TO public;
CREATE POLICY "Teams can be updated by a member of the team" ON "teams" AS PERMISSIVE FOR UPDATE TO public;
CREATE POLICY "Teams can be deleted by a member of the team" ON "teams" AS PERMISSIVE FOR DELETE TO public;

CREATE POLICY "Users can insert their own profile." ON "users" AS PERMISSIVE FOR INSERT TO public WITH CHECK ((auth.uid() = id));
CREATE POLICY "Users can select their own profile." ON "users" AS PERMISSIVE FOR SELECT TO public;
CREATE POLICY "Users can update own profile." ON "users" AS PERMISSIVE FOR UPDATE TO public;


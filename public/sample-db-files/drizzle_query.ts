// COMPLEX FINTECH SYSTEM / DRIZZLE ORM
import {
  pgTable,
  bigserial,
  bigint,
  varchar,
  timestamp,
  boolean,
  numeric,
  integer,
  jsonb,
} from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'

export const users = pgTable('users', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  email: varchar('email', { length: 255 }),
  phone: varchar('phone', { length: 255 }),
  password_hash: varchar('password_hash', { length: 255 }),
  status: varchar('status', { length: 255 }),
  country_code: varchar('country_code', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
  updated_at: timestamp('updated_at', { withTimezone: true }),
})

export const user_profiles = pgTable('user_profiles', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }).references(() => users.id),
  first_name: varchar('first_name', { length: 255 }),
  last_name: varchar('last_name', { length: 255 }),
  date_of_birth: varchar('date_of_birth', { length: 255 }),
  occupation: varchar('occupation', { length: 255 }),
  risk_tier: varchar('risk_tier', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const kyc_profiles = pgTable('kyc_profiles', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }).references(() => users.id),
  status: varchar('status', { length: 255 }),
  provider: varchar('provider', { length: 255 }),
  external_reference: varchar('external_reference', { length: 255 }),
  verified_at: timestamp('verified_at', { withTimezone: true }),
  reviewed_at: timestamp('reviewed_at', { withTimezone: true }),
})

export const kyc_documents = pgTable('kyc_documents', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  kyc_id: bigint('kyc_id', { mode: 'number' }).references(() => kyc_profiles.id),
  document_type: varchar('document_type', { length: 255 }),
  document_number_hash: varchar('document_number_hash', { length: 255 }),
  storage_key: varchar('storage_key', { length: 255 }),
  status: varchar('status', { length: 255 }),
  expires_at: timestamp('expires_at', { withTimezone: true }),
})

export const user_addresses = pgTable('user_addresses', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }).references(() => users.id),
  address_type: varchar('address_type', { length: 255 }),
  line1: varchar('line1', { length: 255 }),
  city: varchar('city', { length: 255 }),
  state: varchar('state', { length: 255 }),
  postal_code: varchar('postal_code', { length: 255 }),
  country_code: varchar('country_code', { length: 255 }),
})

export const devices = pgTable('devices', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }).references(() => users.id),
  device_fingerprint: varchar('device_fingerprint', { length: 255 }),
  platform: varchar('platform', { length: 255 }),
  app_version: varchar('app_version', { length: 255 }),
  trusted: boolean('trusted'),
  last_seen_at: timestamp('last_seen_at', { withTimezone: true }),
})

export const sessions = pgTable('sessions', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }).references(() => users.id),
  device_id: bigint('device_id', { mode: 'number' }).references(() => devices.id),
  token_hash: varchar('token_hash', { length: 255 }),
  expires_at: timestamp('expires_at', { withTimezone: true }),
  revoked_at: varchar('revoked_at', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const roles = pgTable('roles', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  name: varchar('name', { length: 255 }),
  description: varchar('description', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const user_roles = pgTable('user_roles', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }).references(() => users.id),
  role_id: bigint('role_id', { mode: 'number' }).references(() => roles.id),
  assigned_at: varchar('assigned_at', { length: 255 }),
})

export const accounts = pgTable('accounts', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }).references(() => users.id),
  account_number: varchar('account_number', { length: 255 }),
  account_type: varchar('account_type', { length: 255 }),
  currency_id: bigint('currency_id', { mode: 'number' }),
  status: varchar('status', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const account_members = pgTable('account_members', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  account_id: bigint('account_id', { mode: 'number' }).references(() => accounts.id),
  user_id: bigint('user_id', { mode: 'number' }).references(() => users.id),
  member_role: varchar('member_role', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const wallets = pgTable('wallets', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  account_id: bigint('account_id', { mode: 'number' }).references(() => accounts.id),
  wallet_type: varchar('wallet_type', { length: 255 }),
  status: varchar('status', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const wallet_balances = pgTable('wallet_balances', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  wallet_id: bigint('wallet_id', { mode: 'number' }).references(() => wallets.id),
  available: numeric('available', { precision: 20, scale: 6 }),
  pending: numeric('pending', { precision: 20, scale: 6 }),
  ledger: numeric('ledger', { precision: 20, scale: 6 }),
  updated_at: timestamp('updated_at', { withTimezone: true }),
})

export const currencies = pgTable('currencies', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  code: varchar('code', { length: 255 }),
  name: varchar('name', { length: 255 }),
  minor_unit: varchar('minor_unit', { length: 255 }),
  is_active: varchar('is_active', { length: 255 }),
})

export const exchange_rates = pgTable('exchange_rates', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  base_currency_id: bigint('base_currency_id', { mode: 'number' }).references(() => currencies.id),
  quote_currency_id: bigint('quote_currency_id', { mode: 'number' }).references(
    () => currencies.id
  ),
  rate: numeric('rate', { precision: 20, scale: 6 }),
  provider: varchar('provider', { length: 255 }),
  observed_at: timestamp('observed_at', { withTimezone: true }),
})

export const payment_methods = pgTable('payment_methods', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }).references(() => users.id),
  method_type: varchar('method_type', { length: 255 }),
  provider: varchar('provider', { length: 255 }),
  token_reference: varchar('token_reference', { length: 255 }),
  status: varchar('status', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const cards = pgTable('cards', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }).references(() => users.id),
  account_id: bigint('account_id', { mode: 'number' }).references(() => accounts.id),
  last4: varchar('last4', { length: 255 }),
  brand: varchar('brand', { length: 255 }),
  status: varchar('status', { length: 255 }),
  issued_at: timestamp('issued_at', { withTimezone: true }),
  expires_at: timestamp('expires_at', { withTimezone: true }),
})

export const card_transactions = pgTable('card_transactions', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  card_id: bigint('card_id', { mode: 'number' }).references(() => cards.id),
  merchant_id: bigint('merchant_id', { mode: 'number' }),
  transaction_id: bigint('transaction_id', { mode: 'number' }),
  amount: numeric('amount', { precision: 20, scale: 6 }),
  currency_id: bigint('currency_id', { mode: 'number' }).references(() => currencies.id),
  status: varchar('status', { length: 255 }),
  posted_at: timestamp('posted_at', { withTimezone: true }),
})

export const merchants = pgTable('merchants', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  legal_name: varchar('legal_name', { length: 255 }),
  display_name: varchar('display_name', { length: 255 }),
  category_code: varchar('category_code', { length: 255 }),
  country_code: varchar('country_code', { length: 255 }),
  status: varchar('status', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const merchant_accounts = pgTable('merchant_accounts', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  merchant_id: bigint('merchant_id', { mode: 'number' }).references(() => merchants.id),
  account_id: bigint('account_id', { mode: 'number' }).references(() => accounts.id),
  settlement_currency_id: bigint('settlement_currency_id', { mode: 'number' }).references(
    () => currencies.id
  ),
  status: varchar('status', { length: 255 }),
})

export const beneficiaries = pgTable('beneficiaries', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }).references(() => users.id),
  name: varchar('name', { length: 255 }),
  account_number_hash: varchar('account_number_hash', { length: 255 }),
  bank_code: varchar('bank_code', { length: 255 }),
  country_code: varchar('country_code', { length: 255 }),
  status: varchar('status', { length: 255 }),
})

export const transfers = pgTable('transfers', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }).references(() => users.id),
  source_account_id: bigint('source_account_id', { mode: 'number' }).references(() => accounts.id),
  beneficiary_id: bigint('beneficiary_id', { mode: 'number' }).references(() => beneficiaries.id),
  amount: numeric('amount', { precision: 20, scale: 6 }),
  currency_id: bigint('currency_id', { mode: 'number' }).references(() => currencies.id),
  status: varchar('status', { length: 255 }),
  reference: varchar('reference', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const transfer_routes = pgTable('transfer_routes', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  transfer_id: bigint('transfer_id', { mode: 'number' }).references(() => transfers.id),
  rail: varchar('rail', { length: 255 }),
  provider: varchar('provider', { length: 255 }),
  route_status: varchar('route_status', { length: 255 }),
  provider_reference: varchar('provider_reference', { length: 255 }),
})

export const transactions = pgTable('transactions', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  account_id: bigint('account_id', { mode: 'number' }).references(() => accounts.id),
  user_id: bigint('user_id', { mode: 'number' }).references(() => users.id),
  merchant_id: bigint('merchant_id', { mode: 'number' }).references(() => merchants.id),
  type: varchar('type', { length: 255 }),
  direction: varchar('direction', { length: 255 }),
  amount: numeric('amount', { precision: 20, scale: 6 }),
  currency_id: bigint('currency_id', { mode: 'number' }).references(() => currencies.id),
  status: varchar('status', { length: 255 }),
  reference: varchar('reference', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const transaction_entries = pgTable('transaction_entries', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  transaction_id: bigint('transaction_id', { mode: 'number' }).references(() => transactions.id),
  ledger_account_id: bigint('ledger_account_id', { mode: 'number' }),
  entry_type: varchar('entry_type', { length: 255 }),
  amount: numeric('amount', { precision: 20, scale: 6 }),
  currency_id: bigint('currency_id', { mode: 'number' }).references(() => currencies.id),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const ledger_accounts = pgTable('ledger_accounts', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  account_id: bigint('account_id', { mode: 'number' }).references(() => accounts.id),
  code: varchar('code', { length: 255 }),
  name: varchar('name', { length: 255 }),
  account_class: varchar('account_class', { length: 255 }),
  currency_id: bigint('currency_id', { mode: 'number' }).references(() => currencies.id),
  status: varchar('status', { length: 255 }),
})

export const ledger_entries = pgTable('ledger_entries', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  ledger_account_id: bigint('ledger_account_id', { mode: 'number' }).references(
    () => ledger_accounts.id
  ),
  transaction_id: bigint('transaction_id', { mode: 'number' }).references(() => transactions.id),
  debit: varchar('debit', { length: 255 }),
  credit: varchar('credit', { length: 255 }),
  balance_after: varchar('balance_after', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const fees = pgTable('fees', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  transaction_id: bigint('transaction_id', { mode: 'number' }).references(() => transactions.id),
  fee_rule_id: bigint('fee_rule_id', { mode: 'number' }),
  amount: numeric('amount', { precision: 20, scale: 6 }),
  currency_id: bigint('currency_id', { mode: 'number' }).references(() => currencies.id),
  status: varchar('status', { length: 255 }),
})

export const fee_rules = pgTable('fee_rules', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  name: varchar('name', { length: 255 }),
  fee_type: varchar('fee_type', { length: 255 }),
  rate: numeric('rate', { precision: 20, scale: 6 }),
  flat_amount: numeric('flat_amount', { precision: 20, scale: 6 }),
  currency_id: bigint('currency_id', { mode: 'number' }).references(() => currencies.id),
  active_from: timestamp('active_from', { withTimezone: true }),
  active_to: timestamp('active_to', { withTimezone: true }),
})

export const refunds = pgTable('refunds', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  transaction_id: bigint('transaction_id', { mode: 'number' }).references(() => transactions.id),
  amount: numeric('amount', { precision: 20, scale: 6 }),
  currency_id: bigint('currency_id', { mode: 'number' }).references(() => currencies.id),
  reason: varchar('reason', { length: 255 }),
  status: varchar('status', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const chargebacks = pgTable('chargebacks', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  transaction_id: bigint('transaction_id', { mode: 'number' }),
  card_transaction_id: bigint('card_transaction_id', { mode: 'number' }),
  reason_code: varchar('reason_code', { length: 255 }),
  amount: numeric('amount', { precision: 20, scale: 6 }),
  status: varchar('status', { length: 255 }),
  opened_at: timestamp('opened_at', { withTimezone: true }),
  resolved_at: timestamp('resolved_at', { withTimezone: true }),
})

export const settlements = pgTable('settlements', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  merchant_id: bigint('merchant_id', { mode: 'number' }),
  settlement_date: timestamp('settlement_date', { withTimezone: true }),
  gross_amount: numeric('gross_amount', { precision: 20, scale: 6 }),
  fee_amount: numeric('fee_amount', { precision: 20, scale: 6 }),
  net_amount: numeric('net_amount', { precision: 20, scale: 6 }),
  currency_id: bigint('currency_id', { mode: 'number' }),
  status: varchar('status', { length: 255 }),
})

export const settlement_items = pgTable('settlement_items', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  settlement_id: bigint('settlement_id', { mode: 'number' }),
  transaction_id: bigint('transaction_id', { mode: 'number' }),
  gross_amount: numeric('gross_amount', { precision: 20, scale: 6 }),
  fee_amount: numeric('fee_amount', { precision: 20, scale: 6 }),
  net_amount: numeric('net_amount', { precision: 20, scale: 6 }),
})

export const invoices = pgTable('invoices', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }),
  merchant_id: bigint('merchant_id', { mode: 'number' }),
  invoice_number: varchar('invoice_number', { length: 255 }),
  subtotal: numeric('subtotal', { precision: 20, scale: 6 }),
  tax: numeric('tax', { precision: 20, scale: 6 }),
  total: numeric('total', { precision: 20, scale: 6 }),
  currency_id: bigint('currency_id', { mode: 'number' }),
  status: varchar('status', { length: 255 }),
  due_at: timestamp('due_at', { withTimezone: true }),
})

export const invoice_items = pgTable('invoice_items', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  invoice_id: bigint('invoice_id', { mode: 'number' }),
  description: varchar('description', { length: 255 }),
  quantity: integer('quantity'),
  unit_price: numeric('unit_price', { precision: 20, scale: 6 }),
  line_total: numeric('line_total', { precision: 20, scale: 6 }),
})

export const subscriptions = pgTable('subscriptions', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }),
  merchant_id: bigint('merchant_id', { mode: 'number' }),
  plan_code: varchar('plan_code', { length: 255 }),
  amount: numeric('amount', { precision: 20, scale: 6 }),
  currency_id: bigint('currency_id', { mode: 'number' }),
  status: varchar('status', { length: 255 }),
  started_at: timestamp('started_at', { withTimezone: true }),
  next_billing_at: timestamp('next_billing_at', { withTimezone: true }),
})

export const subscription_events = pgTable('subscription_events', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  subscription_id: bigint('subscription_id', { mode: 'number' }),
  event_type: varchar('event_type', { length: 255 }),
  amount: numeric('amount', { precision: 20, scale: 6 }),
  currency_id: bigint('currency_id', { mode: 'number' }),
  occurred_at: timestamp('occurred_at', { withTimezone: true }),
})

export const loans = pgTable('loans', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }),
  principal: numeric('principal', { precision: 20, scale: 6 }),
  currency_id: bigint('currency_id', { mode: 'number' }),
  interest_rate: numeric('interest_rate', { precision: 20, scale: 6 }),
  term_months: integer('term_months'),
  status: varchar('status', { length: 255 }),
  originated_at: timestamp('originated_at', { withTimezone: true }),
})

export const loan_applications = pgTable('loan_applications', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  loan_id: bigint('loan_id', { mode: 'number' }),
  user_id: bigint('user_id', { mode: 'number' }),
  requested_amount: numeric('requested_amount', { precision: 20, scale: 6 }),
  employment_status: varchar('employment_status', { length: 255 }),
  decision: varchar('decision', { length: 255 }),
  submitted_at: timestamp('submitted_at', { withTimezone: true }),
})

export const loan_repayments = pgTable('loan_repayments', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  loan_id: bigint('loan_id', { mode: 'number' }),
  schedule_id: bigint('schedule_id', { mode: 'number' }),
  amount: numeric('amount', { precision: 20, scale: 6 }),
  principal_amount: numeric('principal_amount', { precision: 20, scale: 6 }),
  interest_amount: numeric('interest_amount', { precision: 20, scale: 6 }),
  paid_at: timestamp('paid_at', { withTimezone: true }),
  status: varchar('status', { length: 255 }),
})

export const loan_schedules = pgTable('loan_schedules', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  loan_id: bigint('loan_id', { mode: 'number' }),
  installment_number: integer('installment_number'),
  due_date: timestamp('due_date', { withTimezone: true }),
  principal_due: numeric('principal_due', { precision: 20, scale: 6 }),
  interest_due: numeric('interest_due', { precision: 20, scale: 6 }),
  status: varchar('status', { length: 255 }),
})

export const credit_scores = pgTable('credit_scores', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }),
  score: numeric('score', { precision: 20, scale: 6 }),
  provider: varchar('provider', { length: 255 }),
  score_band: varchar('score_band', { length: 255 }),
  calculated_at: timestamp('calculated_at', { withTimezone: true }),
})

export const limits = pgTable('limits', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }),
  account_id: bigint('account_id', { mode: 'number' }),
  limit_type: varchar('limit_type', { length: 255 }),
  amount: numeric('amount', { precision: 20, scale: 6 }),
  currency_id: bigint('currency_id', { mode: 'number' }),
  period: varchar('period', { length: 255 }),
  active: boolean('active'),
})

export const limit_events = pgTable('limit_events', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  limit_id: bigint('limit_id', { mode: 'number' }),
  transaction_id: bigint('transaction_id', { mode: 'number' }),
  previous_used: numeric('previous_used', { precision: 20, scale: 6 }),
  new_used: numeric('new_used', { precision: 20, scale: 6 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const fraud_cases = pgTable('fraud_cases', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }),
  transaction_id: bigint('transaction_id', { mode: 'number' }),
  risk_score: varchar('risk_score', { length: 255 }),
  case_status: varchar('case_status', { length: 255 }),
  reason: varchar('reason', { length: 255 }),
  opened_at: timestamp('opened_at', { withTimezone: true }),
  closed_at: timestamp('closed_at', { withTimezone: true }),
})

export const fraud_events = pgTable('fraud_events', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  case_id: bigint('case_id', { mode: 'number' }),
  event_type: varchar('event_type', { length: 255 }),
  signal: varchar('signal', { length: 255 }),
  score: numeric('score', { precision: 20, scale: 6 }),
  metadata: jsonb('metadata'),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const risk_rules = pgTable('risk_rules', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  name: varchar('name', { length: 255 }),
  rule_expression: varchar('rule_expression', { length: 255 }),
  severity: varchar('severity', { length: 255 }),
  enabled: boolean('enabled'),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const risk_decisions = pgTable('risk_decisions', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  transaction_id: bigint('transaction_id', { mode: 'number' }),
  rule_id: bigint('rule_id', { mode: 'number' }),
  decision: varchar('decision', { length: 255 }),
  score: numeric('score', { precision: 20, scale: 6 }),
  reason: varchar('reason', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const audit_logs = pgTable('audit_logs', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }),
  actor_type: varchar('actor_type', { length: 255 }),
  action: varchar('action', { length: 255 }),
  entity_type: varchar('entity_type', { length: 255 }),
  entity_id: bigint('entity_id', { mode: 'number' }),
  metadata: jsonb('metadata'),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const webhooks = pgTable('webhooks', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  merchant_id: bigint('merchant_id', { mode: 'number' }),
  event_type: varchar('event_type', { length: 255 }),
  endpoint: varchar('endpoint', { length: 255 }),
  payload: jsonb('payload'),
  delivery_status: varchar('delivery_status', { length: 255 }),
  attempts: integer('attempts'),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const api_keys = pgTable('api_keys', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }),
  merchant_id: bigint('merchant_id', { mode: 'number' }),
  key_prefix: varchar('key_prefix', { length: 255 }),
  secret_hash: varchar('secret_hash', { length: 255 }),
  scopes: varchar('scopes', { length: 255 }),
  revoked_at: varchar('revoked_at', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const notifications = pgTable('notifications', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }),
  channel: varchar('channel', { length: 255 }),
  template_code: varchar('template_code', { length: 255 }),
  subject: varchar('subject', { length: 255 }),
  status: varchar('status', { length: 255 }),
  sent_at: timestamp('sent_at', { withTimezone: true }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const support_tickets = pgTable('support_tickets', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  user_id: bigint('user_id', { mode: 'number' }),
  category: varchar('category', { length: 255 }),
  priority: varchar('priority', { length: 255 }),
  status: varchar('status', { length: 255 }),
  subject: varchar('subject', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const ticket_messages = pgTable('ticket_messages', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  ticket_id: bigint('ticket_id', { mode: 'number' }),
  sender_user_id: bigint('sender_user_id', { mode: 'number' }),
  body: varchar('body', { length: 255 }),
  created_at: timestamp('created_at', { withTimezone: true }),
})

export const reconciliation_runs = pgTable('reconciliation_runs', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  account_id: bigint('account_id', { mode: 'number' }),
  provider: varchar('provider', { length: 255 }),
  run_date: timestamp('run_date', { withTimezone: true }),
  status: varchar('status', { length: 255 }),
  matched_count: integer('matched_count'),
  unmatched_count: integer('unmatched_count'),
})

export const reconciliation_items = pgTable('reconciliation_items', {
  id: bigserial('id', { mode: 'number' }).primaryKey(),
  run_id: bigint('run_id', { mode: 'number' }),
  transaction_id: bigint('transaction_id', { mode: 'number' }),
  external_reference: varchar('external_reference', { length: 255 }),
  external_amount: numeric('external_amount', { precision: 20, scale: 6 }),
  internal_amount: numeric('internal_amount', { precision: 20, scale: 6 }),
  status: varchar('status', { length: 255 }),
})

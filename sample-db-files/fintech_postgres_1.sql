-- COMPLEX FINTECH SYSTEM / POSTGRESQL
CREATE SCHEMA IF NOT EXISTS fintech;
SET search_path TO fintech;

CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(255),
  phone VARCHAR(255),
  password_hash VARCHAR(255),
  status VARCHAR(255),
  country_code VARCHAR(255),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE user_profiles (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  date_of_birth VARCHAR(255),
  occupation VARCHAR(255),
  risk_tier VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE kyc_profiles (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  status VARCHAR(255),
  provider VARCHAR(255),
  external_reference VARCHAR(255),
  verified_at TIMESTAMP,
  reviewed_at TIMESTAMP
);

CREATE TABLE kyc_documents (
  id BIGSERIAL PRIMARY KEY,
  kyc_id BIGINT,
  document_type VARCHAR(255),
  document_number_hash VARCHAR(255),
  storage_key VARCHAR(255),
  status VARCHAR(255),
  expires_at TIMESTAMP
);

CREATE TABLE user_addresses (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  address_type VARCHAR(255),
  line1 VARCHAR(255),
  city VARCHAR(255),
  state VARCHAR(255),
  postal_code VARCHAR(255),
  country_code VARCHAR(255)
);

CREATE TABLE devices (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  device_fingerprint VARCHAR(255),
  platform VARCHAR(255),
  app_version VARCHAR(255),
  trusted BOOLEAN,
  last_seen_at TIMESTAMP
);

CREATE TABLE sessions (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  device_id BIGINT,
  token_hash VARCHAR(255),
  expires_at TIMESTAMP,
  revoked_at VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE roles (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255),
  description VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE user_roles (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  role_id BIGINT,
  assigned_at VARCHAR(255)
);

CREATE TABLE accounts (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  account_number VARCHAR(255),
  account_type VARCHAR(255),
  currency_id BIGINT,
  status VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE account_members (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT,
  user_id BIGINT,
  member_role VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE wallets (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT,
  wallet_type VARCHAR(255),
  status VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE wallet_balances (
  id BIGSERIAL PRIMARY KEY,
  wallet_id BIGINT,
  available DECIMAL(20,6),
  pending DECIMAL(20,6),
  ledger DECIMAL(20,6),
  updated_at TIMESTAMP
);

CREATE TABLE currencies (
  id BIGSERIAL PRIMARY KEY,
  code VARCHAR(255),
  name VARCHAR(255),
  minor_unit VARCHAR(255),
  is_active VARCHAR(255)
);

CREATE TABLE exchange_rates (
  id BIGSERIAL PRIMARY KEY,
  base_currency_id BIGINT,
  quote_currency_id BIGINT,
  rate DECIMAL(20,6),
  provider VARCHAR(255),
  observed_at TIMESTAMP
);

CREATE TABLE payment_methods (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  method_type VARCHAR(255),
  provider VARCHAR(255),
  token_reference VARCHAR(255),
  status VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE cards (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  account_id BIGINT,
  last4 VARCHAR(255),
  brand VARCHAR(255),
  status VARCHAR(255),
  issued_at TIMESTAMP,
  expires_at TIMESTAMP
);

CREATE TABLE card_transactions (
  id BIGSERIAL PRIMARY KEY,
  card_id BIGINT,
  merchant_id BIGINT,
  transaction_id BIGINT,
  amount DECIMAL(20,6),
  currency_id BIGINT,
  status VARCHAR(255),
  posted_at TIMESTAMP
);

CREATE TABLE merchants (
  id BIGSERIAL PRIMARY KEY,
  legal_name VARCHAR(255),
  display_name VARCHAR(255),
  category_code VARCHAR(255),
  country_code VARCHAR(255),
  status VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE merchant_accounts (
  id BIGSERIAL PRIMARY KEY,
  merchant_id BIGINT,
  account_id BIGINT,
  settlement_currency_id BIGINT,
  status VARCHAR(255)
);

CREATE TABLE beneficiaries (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  name VARCHAR(255),
  account_number_hash VARCHAR(255),
  bank_code VARCHAR(255),
  country_code VARCHAR(255),
  status VARCHAR(255)
);

CREATE TABLE transfers (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  source_account_id BIGINT,
  beneficiary_id BIGINT,
  amount DECIMAL(20,6),
  currency_id BIGINT,
  status VARCHAR(255),
  reference VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE transfer_routes (
  id BIGSERIAL PRIMARY KEY,
  transfer_id BIGINT,
  rail VARCHAR(255),
  provider VARCHAR(255),
  route_status VARCHAR(255),
  provider_reference VARCHAR(255)
);

CREATE TABLE transactions (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT,
  user_id BIGINT,
  merchant_id BIGINT,
  type VARCHAR(255),
  direction VARCHAR(255),
  amount DECIMAL(20,6),
  currency_id BIGINT,
  status VARCHAR(255),
  reference VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE transaction_entries (
  id BIGSERIAL PRIMARY KEY,
  transaction_id BIGINT,
  ledger_account_id BIGINT,
  entry_type VARCHAR(255),
  amount DECIMAL(20,6),
  currency_id BIGINT,
  created_at TIMESTAMP
);

CREATE TABLE ledger_accounts (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT,
  code VARCHAR(255),
  name VARCHAR(255),
  account_class VARCHAR(255),
  currency_id BIGINT,
  status VARCHAR(255)
);

CREATE TABLE ledger_entries (
  id BIGSERIAL PRIMARY KEY,
  ledger_account_id BIGINT,
  transaction_id BIGINT,
  debit VARCHAR(255),
  credit VARCHAR(255),
  balance_after VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE fees (
  id BIGSERIAL PRIMARY KEY,
  transaction_id BIGINT,
  fee_rule_id BIGINT,
  amount DECIMAL(20,6),
  currency_id BIGINT,
  status VARCHAR(255)
);

CREATE TABLE fee_rules (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255),
  fee_type VARCHAR(255),
  rate DECIMAL(20,6),
  flat_amount DECIMAL(20,6),
  currency_id BIGINT,
  active_from TIMESTAMP,
  active_to TIMESTAMP
);

CREATE TABLE refunds (
  id BIGSERIAL PRIMARY KEY,
  transaction_id BIGINT,
  amount DECIMAL(20,6),
  currency_id BIGINT,
  reason VARCHAR(255),
  status VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE chargebacks (
  id BIGSERIAL PRIMARY KEY,
  transaction_id BIGINT,
  card_transaction_id BIGINT,
  reason_code VARCHAR(255),
  amount DECIMAL(20,6),
  status VARCHAR(255),
  opened_at TIMESTAMP,
  resolved_at TIMESTAMP
);

CREATE TABLE settlements (
  id BIGSERIAL PRIMARY KEY,
  merchant_id BIGINT,
  settlement_date TIMESTAMP,
  gross_amount DECIMAL(20,6),
  fee_amount DECIMAL(20,6),
  net_amount DECIMAL(20,6),
  currency_id BIGINT,
  status VARCHAR(255)
);

CREATE TABLE settlement_items (
  id BIGSERIAL PRIMARY KEY,
  settlement_id BIGINT,
  transaction_id BIGINT,
  gross_amount DECIMAL(20,6),
  fee_amount DECIMAL(20,6),
  net_amount DECIMAL(20,6)
);

CREATE TABLE invoices (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  merchant_id BIGINT,
  invoice_number VARCHAR(255),
  subtotal DECIMAL(20,6),
  tax DECIMAL(20,6),
  total DECIMAL(20,6),
  currency_id BIGINT,
  status VARCHAR(255),
  due_at TIMESTAMP
);

CREATE TABLE invoice_items (
  id BIGSERIAL PRIMARY KEY,
  invoice_id BIGINT,
  description VARCHAR(255),
  quantity INTEGER,
  unit_price DECIMAL(20,6),
  line_total DECIMAL(20,6)
);

CREATE TABLE subscriptions (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  merchant_id BIGINT,
  plan_code VARCHAR(255),
  amount DECIMAL(20,6),
  currency_id BIGINT,
  status VARCHAR(255),
  started_at TIMESTAMP,
  next_billing_at TIMESTAMP
);

CREATE TABLE subscription_events (
  id BIGSERIAL PRIMARY KEY,
  subscription_id BIGINT,
  event_type VARCHAR(255),
  amount DECIMAL(20,6),
  currency_id BIGINT,
  occurred_at TIMESTAMP
);

CREATE TABLE loans (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  principal DECIMAL(20,6),
  currency_id BIGINT,
  interest_rate DECIMAL(20,6),
  term_months INTEGER,
  status VARCHAR(255),
  originated_at TIMESTAMP
);

CREATE TABLE loan_applications (
  id BIGSERIAL PRIMARY KEY,
  loan_id BIGINT,
  user_id BIGINT,
  requested_amount DECIMAL(20,6),
  employment_status VARCHAR(255),
  decision VARCHAR(255),
  submitted_at TIMESTAMP
);

CREATE TABLE loan_repayments (
  id BIGSERIAL PRIMARY KEY,
  loan_id BIGINT,
  schedule_id BIGINT,
  amount DECIMAL(20,6),
  principal_amount DECIMAL(20,6),
  interest_amount DECIMAL(20,6),
  paid_at TIMESTAMP,
  status VARCHAR(255)
);

CREATE TABLE loan_schedules (
  id BIGSERIAL PRIMARY KEY,
  loan_id BIGINT,
  installment_number INTEGER,
  due_date TIMESTAMP,
  principal_due DECIMAL(20,6),
  interest_due DECIMAL(20,6),
  status VARCHAR(255)
);

CREATE TABLE credit_scores (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  score DECIMAL(20,6),
  provider VARCHAR(255),
  score_band VARCHAR(255),
  calculated_at TIMESTAMP
);

CREATE TABLE limits (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  account_id BIGINT,
  limit_type VARCHAR(255),
  amount DECIMAL(20,6),
  currency_id BIGINT,
  period VARCHAR(255),
  active BOOLEAN
);

CREATE TABLE limit_events (
  id BIGSERIAL PRIMARY KEY,
  limit_id BIGINT,
  transaction_id BIGINT,
  previous_used DECIMAL(20,6),
  new_used DECIMAL(20,6),
  created_at TIMESTAMP
);

CREATE TABLE fraud_cases (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  transaction_id BIGINT,
  risk_score VARCHAR(255),
  case_status VARCHAR(255),
  reason VARCHAR(255),
  opened_at TIMESTAMP,
  closed_at TIMESTAMP
);

CREATE TABLE fraud_events (
  id BIGSERIAL PRIMARY KEY,
  case_id BIGINT,
  event_type VARCHAR(255),
  signal VARCHAR(255),
  score DECIMAL(20,6),
  metadata JSONB,
  created_at TIMESTAMP
);

CREATE TABLE risk_rules (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255),
  rule_expression VARCHAR(255),
  severity VARCHAR(255),
  enabled BOOLEAN,
  created_at TIMESTAMP
);

CREATE TABLE risk_decisions (
  id BIGSERIAL PRIMARY KEY,
  transaction_id BIGINT,
  rule_id BIGINT,
  decision VARCHAR(255),
  score DECIMAL(20,6),
  reason VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  actor_type VARCHAR(255),
  action VARCHAR(255),
  entity_type VARCHAR(255),
  entity_id BIGINT,
  metadata JSONB,
  created_at TIMESTAMP
);

CREATE TABLE webhooks (
  id BIGSERIAL PRIMARY KEY,
  merchant_id BIGINT,
  event_type VARCHAR(255),
  endpoint VARCHAR(255),
  payload JSONB,
  delivery_status VARCHAR(255),
  attempts INTEGER,
  created_at TIMESTAMP
);

CREATE TABLE api_keys (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  merchant_id BIGINT,
  key_prefix VARCHAR(255),
  secret_hash VARCHAR(255),
  scopes VARCHAR(255),
  revoked_at VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE notifications (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  channel VARCHAR(255),
  template_code VARCHAR(255),
  subject VARCHAR(255),
  status VARCHAR(255),
  sent_at TIMESTAMP,
  created_at TIMESTAMP
);

CREATE TABLE support_tickets (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT,
  category VARCHAR(255),
  priority VARCHAR(255),
  status VARCHAR(255),
  subject VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE ticket_messages (
  id BIGSERIAL PRIMARY KEY,
  ticket_id BIGINT,
  sender_user_id BIGINT,
  body VARCHAR(255),
  created_at TIMESTAMP
);

CREATE TABLE reconciliation_runs (
  id BIGSERIAL PRIMARY KEY,
  account_id BIGINT,
  provider VARCHAR(255),
  run_date TIMESTAMP,
  status VARCHAR(255),
  matched_count INTEGER,
  unmatched_count INTEGER
);

CREATE TABLE reconciliation_items (
  id BIGSERIAL PRIMARY KEY,
  run_id BIGINT,
  transaction_id BIGINT,
  external_reference VARCHAR(255),
  external_amount DECIMAL(20,6),
  internal_amount DECIMAL(20,6),
  status VARCHAR(255)
);
ALTER TABLE user_profiles ADD CONSTRAINT fk_user_profiles_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE kyc_profiles ADD CONSTRAINT fk_kyc_profiles_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE kyc_documents ADD CONSTRAINT fk_kyc_documents_kyc_id FOREIGN KEY (kyc_id) REFERENCES kyc_profiles(id);
ALTER TABLE user_addresses ADD CONSTRAINT fk_user_addresses_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE devices ADD CONSTRAINT fk_devices_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE sessions ADD CONSTRAINT fk_sessions_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE sessions ADD CONSTRAINT fk_sessions_device_id FOREIGN KEY (device_id) REFERENCES devices(id);
ALTER TABLE user_roles ADD CONSTRAINT fk_user_roles_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE user_roles ADD CONSTRAINT fk_user_roles_role_id FOREIGN KEY (role_id) REFERENCES roles(id);
ALTER TABLE accounts ADD CONSTRAINT fk_accounts_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE accounts ADD CONSTRAINT fk_accounts_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE account_members ADD CONSTRAINT fk_account_members_account_id FOREIGN KEY (account_id) REFERENCES accounts(id);
ALTER TABLE account_members ADD CONSTRAINT fk_account_members_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE wallets ADD CONSTRAINT fk_wallets_account_id FOREIGN KEY (account_id) REFERENCES accounts(id);
ALTER TABLE wallet_balances ADD CONSTRAINT fk_wallet_balances_wallet_id FOREIGN KEY (wallet_id) REFERENCES wallets(id);
ALTER TABLE exchange_rates ADD CONSTRAINT fk_exchange_rates_base_currency_id FOREIGN KEY (base_currency_id) REFERENCES currencies(id);
ALTER TABLE exchange_rates ADD CONSTRAINT fk_exchange_rates_quote_currency_id FOREIGN KEY (quote_currency_id) REFERENCES currencies(id);
ALTER TABLE payment_methods ADD CONSTRAINT fk_payment_methods_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE cards ADD CONSTRAINT fk_cards_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE cards ADD CONSTRAINT fk_cards_account_id FOREIGN KEY (account_id) REFERENCES accounts(id);
ALTER TABLE card_transactions ADD CONSTRAINT fk_card_transactions_card_id FOREIGN KEY (card_id) REFERENCES cards(id);
ALTER TABLE card_transactions ADD CONSTRAINT fk_card_transactions_merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants(id);
ALTER TABLE card_transactions ADD CONSTRAINT fk_card_transactions_transaction_id FOREIGN KEY (transaction_id) REFERENCES transactions(id);
ALTER TABLE card_transactions ADD CONSTRAINT fk_card_transactions_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE merchant_accounts ADD CONSTRAINT fk_merchant_accounts_merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants(id);
ALTER TABLE merchant_accounts ADD CONSTRAINT fk_merchant_accounts_account_id FOREIGN KEY (account_id) REFERENCES accounts(id);
ALTER TABLE merchant_accounts ADD CONSTRAINT fk_merchant_accounts_settlement_currency_id FOREIGN KEY (settlement_currency_id) REFERENCES currencies(id);
ALTER TABLE beneficiaries ADD CONSTRAINT fk_beneficiaries_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE transfers ADD CONSTRAINT fk_transfers_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE transfers ADD CONSTRAINT fk_transfers_source_account_id FOREIGN KEY (source_account_id) REFERENCES accounts(id);
ALTER TABLE transfers ADD CONSTRAINT fk_transfers_beneficiary_id FOREIGN KEY (beneficiary_id) REFERENCES beneficiaries(id);
ALTER TABLE transfers ADD CONSTRAINT fk_transfers_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE transfer_routes ADD CONSTRAINT fk_transfer_routes_transfer_id FOREIGN KEY (transfer_id) REFERENCES transfers(id);
ALTER TABLE transactions ADD CONSTRAINT fk_transactions_account_id FOREIGN KEY (account_id) REFERENCES accounts(id);
ALTER TABLE transactions ADD CONSTRAINT fk_transactions_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE transactions ADD CONSTRAINT fk_transactions_merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants(id);
ALTER TABLE transactions ADD CONSTRAINT fk_transactions_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE transaction_entries ADD CONSTRAINT fk_transaction_entries_transaction_id FOREIGN KEY (transaction_id) REFERENCES transactions(id);
ALTER TABLE transaction_entries ADD CONSTRAINT fk_transaction_entries_ledger_account_id FOREIGN KEY (ledger_account_id) REFERENCES ledger_accounts(id);
ALTER TABLE transaction_entries ADD CONSTRAINT fk_transaction_entries_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE ledger_accounts ADD CONSTRAINT fk_ledger_accounts_account_id FOREIGN KEY (account_id) REFERENCES accounts(id);
ALTER TABLE ledger_accounts ADD CONSTRAINT fk_ledger_accounts_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE ledger_entries ADD CONSTRAINT fk_ledger_entries_ledger_account_id FOREIGN KEY (ledger_account_id) REFERENCES ledger_accounts(id);
ALTER TABLE ledger_entries ADD CONSTRAINT fk_ledger_entries_transaction_id FOREIGN KEY (transaction_id) REFERENCES transactions(id);
ALTER TABLE fees ADD CONSTRAINT fk_fees_transaction_id FOREIGN KEY (transaction_id) REFERENCES transactions(id);
ALTER TABLE fees ADD CONSTRAINT fk_fees_fee_rule_id FOREIGN KEY (fee_rule_id) REFERENCES fee_rules(id);
ALTER TABLE fees ADD CONSTRAINT fk_fees_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE fee_rules ADD CONSTRAINT fk_fee_rules_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE refunds ADD CONSTRAINT fk_refunds_transaction_id FOREIGN KEY (transaction_id) REFERENCES transactions(id);
ALTER TABLE refunds ADD CONSTRAINT fk_refunds_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE chargebacks ADD CONSTRAINT fk_chargebacks_transaction_id FOREIGN KEY (transaction_id) REFERENCES transactions(id);
ALTER TABLE chargebacks ADD CONSTRAINT fk_chargebacks_card_transaction_id FOREIGN KEY (card_transaction_id) REFERENCES card_transactions(id);
ALTER TABLE settlements ADD CONSTRAINT fk_settlements_merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants(id);
ALTER TABLE settlements ADD CONSTRAINT fk_settlements_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE settlement_items ADD CONSTRAINT fk_settlement_items_settlement_id FOREIGN KEY (settlement_id) REFERENCES settlements(id);
ALTER TABLE settlement_items ADD CONSTRAINT fk_settlement_items_transaction_id FOREIGN KEY (transaction_id) REFERENCES transactions(id);
ALTER TABLE invoices ADD CONSTRAINT fk_invoices_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE invoices ADD CONSTRAINT fk_invoices_merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants(id);
ALTER TABLE invoices ADD CONSTRAINT fk_invoices_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE invoice_items ADD CONSTRAINT fk_invoice_items_invoice_id FOREIGN KEY (invoice_id) REFERENCES invoices(id);
ALTER TABLE subscriptions ADD CONSTRAINT fk_subscriptions_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE subscriptions ADD CONSTRAINT fk_subscriptions_merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants(id);
ALTER TABLE subscriptions ADD CONSTRAINT fk_subscriptions_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE subscription_events ADD CONSTRAINT fk_subscription_events_subscription_id FOREIGN KEY (subscription_id) REFERENCES subscriptions(id);
ALTER TABLE subscription_events ADD CONSTRAINT fk_subscription_events_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE loans ADD CONSTRAINT fk_loans_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE loans ADD CONSTRAINT fk_loans_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE loan_applications ADD CONSTRAINT fk_loan_applications_loan_id FOREIGN KEY (loan_id) REFERENCES loans(id);
ALTER TABLE loan_applications ADD CONSTRAINT fk_loan_applications_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE loan_repayments ADD CONSTRAINT fk_loan_repayments_loan_id FOREIGN KEY (loan_id) REFERENCES loans(id);
ALTER TABLE loan_repayments ADD CONSTRAINT fk_loan_repayments_schedule_id FOREIGN KEY (schedule_id) REFERENCES loan_schedules(id);
ALTER TABLE loan_schedules ADD CONSTRAINT fk_loan_schedules_loan_id FOREIGN KEY (loan_id) REFERENCES loans(id);
ALTER TABLE credit_scores ADD CONSTRAINT fk_credit_scores_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE limits ADD CONSTRAINT fk_limits_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE limits ADD CONSTRAINT fk_limits_account_id FOREIGN KEY (account_id) REFERENCES accounts(id);
ALTER TABLE limits ADD CONSTRAINT fk_limits_currency_id FOREIGN KEY (currency_id) REFERENCES currencies(id);
ALTER TABLE limit_events ADD CONSTRAINT fk_limit_events_limit_id FOREIGN KEY (limit_id) REFERENCES limits(id);
ALTER TABLE limit_events ADD CONSTRAINT fk_limit_events_transaction_id FOREIGN KEY (transaction_id) REFERENCES transactions(id);
ALTER TABLE fraud_cases ADD CONSTRAINT fk_fraud_cases_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE fraud_cases ADD CONSTRAINT fk_fraud_cases_transaction_id FOREIGN KEY (transaction_id) REFERENCES transactions(id);
ALTER TABLE fraud_events ADD CONSTRAINT fk_fraud_events_case_id FOREIGN KEY (case_id) REFERENCES fraud_cases(id);
ALTER TABLE risk_decisions ADD CONSTRAINT fk_risk_decisions_transaction_id FOREIGN KEY (transaction_id) REFERENCES transactions(id);
ALTER TABLE risk_decisions ADD CONSTRAINT fk_risk_decisions_rule_id FOREIGN KEY (rule_id) REFERENCES risk_rules(id);
ALTER TABLE audit_logs ADD CONSTRAINT fk_audit_logs_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE webhooks ADD CONSTRAINT fk_webhooks_merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants(id);
ALTER TABLE api_keys ADD CONSTRAINT fk_api_keys_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE api_keys ADD CONSTRAINT fk_api_keys_merchant_id FOREIGN KEY (merchant_id) REFERENCES merchants(id);
ALTER TABLE notifications ADD CONSTRAINT fk_notifications_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE support_tickets ADD CONSTRAINT fk_support_tickets_user_id FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE ticket_messages ADD CONSTRAINT fk_ticket_messages_ticket_id FOREIGN KEY (ticket_id) REFERENCES support_tickets(id);
ALTER TABLE ticket_messages ADD CONSTRAINT fk_ticket_messages_sender_user_id FOREIGN KEY (sender_user_id) REFERENCES users(id);
ALTER TABLE reconciliation_runs ADD CONSTRAINT fk_reconciliation_runs_account_id FOREIGN KEY (account_id) REFERENCES accounts(id);
ALTER TABLE reconciliation_items ADD CONSTRAINT fk_reconciliation_items_run_id FOREIGN KEY (run_id) REFERENCES reconciliation_runs(id);
ALTER TABLE reconciliation_items ADD CONSTRAINT fk_reconciliation_items_transaction_id FOREIGN KEY (transaction_id) REFERENCES transactions(id);
CREATE INDEX idx_transactions_account_created ON transactions(account_id,created_at);
CREATE INDEX idx_transactions_user_status ON transactions(user_id,status);
CREATE INDEX idx_ledger_entries_transaction ON ledger_entries(transaction_id);
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation
-- synthetic join fixture: user/account/wallet/transaction/ledger/settlement/reconciliation

# FormulaFlow Requests API

## Production Deployment

**This project is deployed on Vercel**. See [DEPLOYMENT.md](../DEPLOYMENT.md) for complete Vercel deployment instructions.

**Production URLs:**
- Backend: https://formula-flow-uh98.vercel.app
- Frontend: https://formula-flow-9461.vercel.app

**IMPORTANT**: Vercel uses serverless functions. You MUST use PostgreSQL (not SQLite) for production. SQLite will not persist between function invocations.

## Run locally

From the repository root, copy `backend/.env.example` to `backend/.env` and
fill in your PayPal Sandbox REST app's client ID and secret. The backend loads
that local file automatically; environment variables already set by your
shell or hosting provider take precedence. The root `.gitignore` excludes
`.env` files, so do not force-add them to Git.

```powershell
Copy-Item backend\.env.example backend\.env
python -m pip install -r backend\requirements.txt
uvicorn backend.main:app --reload
```

For production on Linux, the API runs under Gunicorn with an ASGI worker:

```sh
gunicorn backend.main:app --workers 1 --worker-class uvicorn_worker.UvicornWorker --bind 0.0.0.0:${PORT:-8000}
```

Gunicorn is not supported on Windows; use Uvicorn for local development. The
Render API service is configured to start with Gunicorn.

For the frontend, copy `frontend/.env.example` to `frontend/.env.local` and set
`VITE_PAYPAL_CLIENT_ID` to the same Sandbox app's client ID. The client ID is
public and is used by PayPal's browser SDK; never put the REST client secret in
the frontend or in any `VITE_` variable. Restart the Vite server after editing
`.env.local`.

Generate a Fernet key for `PICKUP_TOKEN_ENCRYPTION_KEY` with:

```powershell
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

Keep that key stable and secret; changing it before all outstanding pickup
tokens are retrieved makes those encrypted tokens unreadable. The database
stores each token's hash for redemption and encrypts the token only until an
admin retrieves it once.

The backend is configured for PayPal Sandbox only. Use Sandbox credentials in
both env files; this project refuses PayPal Live API requests.

Open `/admin` and create the initial admin account with an email and a
12-character minimum password, then log in. The first admin registration closes
after an account is created. Passwords are stored as scrypt hashes; logged-in
sessions expire after 12 hours and can be revoked by signing out. Back up the
database securely because it contains the admin account and request ledger.

Admins who are signed in can change their password from **Change admin
password** on the dashboard. The current password is required; changing the
password signs out other active sessions and refreshes the current session.
If the admin has forgotten the password, run the recovery command directly in
the API environment (from the repository root) and follow its hidden prompts:

```powershell
python -m backend.reset_admin_password
```

For Render, open the API service's Shell and run the same command there. It
uses that service's configured `DATABASE_URL`, requires the existing admin
email, and revokes existing sessions. There is deliberately no unauthenticated
public password-reset endpoint.

By default, the API stores its SQLite database as `formula_requests.db` in the
current working directory. Set `DATABASE_URL` to use another SQLAlchemy
database URL. `FRONTEND_ORIGINS` is a comma-separated CORS allowlist.

## Recipient and merchant matching

`POST /api/requests` accepts `recipient_name`, `phone_number`, `location`,
`county`, `birth_month` (the first day of the birth month, as `YYYY-MM-01`),
and optional `formula_needs`. County is required for new requests and supports
approved-request regional reports. Legacy integrations may still submit
`infant_age_months` (0–23), but age-only requests cannot be tracked for monthly
continuity or an accurate age-based cutoff.
New requests start as `Pending Verification` and are not matched automatically.
An admin must first approve or reject the case. Rejections require a reason and
are terminal.
The submission response includes a private, non-guessable
`public_reference_code`. Recipients can submit it to
`POST /api/public/request-status`; the response contains only the public stage
(`submitted`, `approved`, `ready_for_pickup`, or `collected`) and
`last_updated_at`. Lookups are limited to 10 attempts per client IP per minute
per API process. Rejected requests are not available through public tracking.
Approved cases can then be explicitly matched with a selected merchant; the
backend snapshots that merchant, monthly quantity, and cost on the request:

- Ages 0–2 months: 3 containers per month.
- Ages 3 months and above: 4 containers per month.

For birth-month requests, the backend calculates age by calendar month. After a
confirmed PayPal Sandbox payout, the next admin dashboard or request-list read
creates one pending monthly review for the following month. Staff must verify
continued need, approve the case, and initiate any payout; the system never
sends automatic or recurring payouts. Reviews are created lazily when those
admin endpoints are accessed, not by a calendar scheduler. Support ends at the
start of the child's 24-month birthday month, making the month before that the
final eligible support month. Historical records without a birth month must be
updated by an admin before their age cohort and cutoff can be tracked.

Create or update a merchant with authenticated
`PUT /api/admin/vendors/{vendor_name}` and a JSON body containing `name`,
`location`, `paypal_email`, and `price_per_container_usd` (USD only); `county`
is optional for older integrations. The admin dashboard also provides a
merchant form and a per-request merchant selector. Supplier counties support
chemist regional reports; legacy requests and suppliers without a county are
reported as "Not recorded". Donor county is not collected, so donation totals
cannot be attributed to a county.
Review and assignment decisions record the operator label, timestamps,
previous/current state, merchant, and optional note in the request audit trail.

## Donations, pool, and payouts

The donor portal creates PayPal Orders v2 orders with
`POST /api/donations/orders` and captures them with
`POST /api/donations/orders/{order_id}/capture`. The capture endpoint verifies
the completed amount/currency and atomically records the PayPal order ID and
capture ID in the donation ledger while crediting the pool. Repeated captures
and record requests are idempotent and do not credit the pool twice.

Use a PayPal Sandbox app's client ID in frontend `VITE_PAYPAL_CLIENT_ID` and
backend `PAYPAL_CLIENT_ID`; keep its secret only in backend
`PAYPAL_CLIENT_SECRET`. Set `PAYPAL_ENVIRONMENT=sandbox` and
`PAYPAL_WEBHOOK_ID` to the webhook ID registered on that Sandbox REST app; this
application refuses to use PayPal Live. Use a Sandbox personal buyer account
to approve the PayPal JS SDK button.

### Sandbox buyer test checklist

1. In the PayPal Developer Dashboard, create a Sandbox REST app and use its
   client ID/secret. Create or select a Sandbox personal buyer account.
2. Set the backend environment values above and set
   `frontend/.env.local`'s `VITE_PAYPAL_CLIENT_ID` to the same Sandbox client ID.
   Never use a Live app's credentials.
3. Start FastAPI from the repository root with
   `uvicorn backend.main:app --reload`; start the React app from `frontend`
   with `npm run dev`.
4. Open `/donate`, select a preset or custom amount, and click the PayPal button.
   Sign in to the PayPal popup with the Sandbox buyer and approve the payment.
5. Confirm the page shows the demo-pool receipt and PayPal capture ID. Check
   the admin pool balance and `/studio` Donations source; each should reflect
   exactly one credit for the captured amount.
6. Confirm the `donation_records` row stores both `paypal_order_id` and
   `paypal_capture_id`. Repeating the capture/record request must not add
   another ledger row or credit.
7. Cancel a checkout and confirm no donation is recorded. Try a deliberately
   invalid Sandbox setup and confirm checkout reports the API/PayPal error.
   For an unknown capture outcome, verify the order in PayPal before taking
   further action; do not assume it failed or retry blindly.

### Register and test the PayPal webhook

1. Deploy the API over public HTTPS. In the PayPal Developer Dashboard, select
   **Apps & Credentials → Sandbox**, open the REST app that matches
   `PAYPAL_CLIENT_ID`, then add a webhook with URL
   `https://<your-api-host>/api/paypal/webhook`.
2. Subscribe to `PAYMENT.CAPTURE.COMPLETED`,
   `PAYMENT.CAPTURE.DENIED`, `PAYMENT.PAYOUTSBATCH.PROCESSING`,
   `PAYMENT.PAYOUTSBATCH.SUCCESS`, `PAYMENT.PAYOUTSBATCH.DENIED`,
   `PAYMENT.PAYOUTSBATCH.CANCELED`, and `PAYMENT.PAYOUTSBATCH.RETURNED`.
   Save the webhook and set its displayed webhook ID as backend
   `PAYPAL_WEBHOOK_ID`; restart the API after changing the environment.
3. In the same Sandbox app's **Webhooks** section, open **Webhook Simulator**,
   select the configured webhook URL and an event type, and send a test event.
   Check API logs for delivery and confirm a verified event ID is recorded in
   `paypal_webhook_events`. The simulator's sample order or payout IDs usually
   do not match local records, so the handler acknowledges and logs those
   unmatched events without changing the pool or payouts.
4. To verify a ledger/status update end to end, use the Sandbox buyer checkout
   above and select the webhook registered on the same app. For payouts, use a
   local payout whose sender batch ID was persisted before PayPal submission.
   If a verified payout event does not match a local batch, the API responds
   with `503` without recording the event as handled, so PayPal can retry after
   the payout is reconciled. A repeated matched delivery with the same event ID
   must not repeat its balance or status change. Invalid signatures are logged
   and rejected.

The webhook endpoint asks PayPal's
`POST /v1/notifications/verify-webhook-signature` API to verify each event
before processing it. `PAYMENT.CAPTURE.COMPLETED` credits only a matching local
order with the expected amount and currency. Payout events are matched by the
PayPal batch ID or the persisted sender batch ID. Verified payout failure
releases reserved funds once. A verified payout-success webhook marks the
request paid, records the `payout_confirmed` and `ready_for_pickup` transitions,
and creates a single-use token that expires after 24 hours. An admin retrieves
the token once from the dashboard for delivery. Token redemption rejects
expired or previously used tokens and transitions the request to `collected`.

The admin dashboard submits review decisions to
`POST /api/admin/requests/{request_id}/decision` with
`{"decision":"approve"}` or `{"decision":"reject","note":"..."}`. Approved
cases are matched by `POST /api/admin/requests/{request_id}/match` with
`{"merchant_id":123}`. The dashboard submits a payout to
`POST /api/admin/approve/{request_id}` only after approval and merchant
assignment;
the legacy `POST /api/admin/payout` route remains available. Admin routes
require an active account session. Before calling PayPal, the backend
atomically reserves the calculated USD cost from the platform pool. Include
`{"containers":1}` in the approve request to fund a smaller quantity; omitting
it funds the complete monthly need. A partial payout changes the actual payout
amount but preserves the request's original monthly quantity and estimated
cost; the payout report records the quantity actually purchased. Failed payouts
release the reservation; unknown PayPal outcomes remain reserved and cannot be
retried, to prevent duplicate payments. The request keeps the
existing review `status` and separately exposes `lifecycle_status`:
`submitted` → `approved` → `payout_pending` → `payout_confirmed` →
`ready_for_pickup` → `collected`. Each transition has its own timestamp in
`GET /api/admin/requests`, Studio's Requests source, and the request history.

An API payout submission response of `SUCCESS` is not sufficient to issue
pickup: the request remains `payout_pending` until either a verified PayPal
webhook or `POST /api/admin/payout/{request_id}/refresh` confirms the payout
through PayPal's status API. Refresh is also available if PayPal's initial
response already said `SUCCESS` but the webhook has not arrived. Confirmed
status and request lifecycle are reflected by the admin request list, dashboard,
reports, and Studio data sources. Public family-funded totals count only
successful PayPal payouts; simulated confirmations are excluded. The admin
dashboard, reports, Studio, and public impact metrics refresh while open. The
authenticated endpoint
`POST /api/admin/requests/{request_id}/pickup-token/retrieve` returns the token
once and clears its encrypted copy. The merchant validates and consumes the
token with `POST /api/pickup/redeem` and `{"token": "..."}`. Automated SMS is
not configured; an operator must deliver the token to the recipient.

PayPal can report an item as `UNCLAIMED`. This means PayPal has not confirmed
that the recipient claimed the payout; it is not a completed payment. Check
that the supplier email belongs to the intended PayPal account, then use
**Check PayPal status** in the dashboard to recheck the existing payout. Do not
submit another payout while its status is unclaimed or otherwise pending.
In the dashboard this is shown as **Merchant hasn't claimed PayPal payout
(pending)**; the recipient here is the merchant receiving the PayPal transfer,
not the family receiving formula. Matching is locked while a payout is pending
to avoid paying twice. After PayPal confirms a payout as failed, the request
can be matched to the same or a different merchant before retrying.

### If Sandbox Payouts is not enabled

1. In the PayPal Developer Dashboard, open **Apps & Credentials → Sandbox**
   and confirm the API client ID and secret belong to the same Sandbox REST
   app configured in the backend.
2. Check that app/account has **Payouts** access enabled. If the dashboard
   offers an enable/request-access control, complete it; if it does not, contact
   PayPal Developer Support to request Sandbox Payouts access for that account.
3. Confirm `PAYPAL_ENVIRONMENT=sandbox`, the backend is using the Sandbox
   client secret (not a Live secret), and `PAYPAL_WEBHOOK_ID` belongs to the
   same Sandbox app.
4. Confirm the associated Sandbox business account is active and funded, and
   that the recipient is a Sandbox account eligible to receive payouts. Sandbox
   funds and transfers are simulated; never use real recipient or bank data.
5. Retry only after checking the exact PayPal API error and the payout batch
   in the Developer Dashboard. An unknown submission outcome stays reserved;
   do not resubmit it blindly.

For a demo without Payouts access, set `PAYPAL_PAYOUT_SIMULATED=true` and
configure the same encryption key. The admin dashboard displays a conspicuous
SIMULATED warning. Staging a simulated payout never calls PayPal; an admin must
separately choose **Confirm simulated payout** before a pickup token is
generated. Set the flag back to `false` for real Sandbox payout requests.

The admin dashboard's PayPal totals reflect this app's completed Sandbox
donation captures and supplier payouts whose status has been confirmed through
PayPal. Pending payouts are shown separately and are not counted as sent until
confirmed. Remaining program funds are the local pool balance after payout
reservations and releases; this is not a query of the PayPal wallet balance and
may differ from the Sandbox account balance if that account has other activity
or holds. The PayPal account must separately have Payouts enabled and enough
funds. Configure PayPal credentials on the backend only. The client uses
Sandbox by default and submits a merchant payout with a unique sender batch ID.
An uncertain result must be verified in PayPal before taking further action.

## Admin data and monitoring

- `GET /api/admin/requests` returns requests awaiting review, approved,
  rejected, and paid.
- `GET /api/admin/requests/{request_id}/history` returns the complete recorded
  submission, review, assignment, payout, and pickup audit history.
- `GET /api/admin/dashboard` returns remaining program funds, captured
  Sandbox donation totals, confirmed and pending PayPal payout totals,
  request-stage and payout-status aggregates, and supported-family counts.
- `GET /api/admin/reports/supplier-payouts?supplier={name}&start_date=YYYY-MM-DD&end_date=YYYY-MM-DD`
  returns confirmed PayPal payout amounts and purchased container totals for
  one supplier. The date range is inclusive and uses the payout confirmation
  date; pending, failed, and simulated payouts are excluded.
- `GET /api/admin/anomalies` returns failed/unknown/in-flight payouts and merchant unit
  price increases of at least 20% against the previous recorded price.
- `GET /api/admin/studio/{donations,payouts,requests,merchants}` supplies separate
  Studio data sources. These endpoints require an admin session and omit
  recipient names, phone numbers, PayPal account details, and payment order IDs.
- The internal Payouts and Requests reports can be filtered to today, this
  month, all dates, or a custom date period.
- `POST /api/admin/agent/query` accepts a question such as
  `{"question": "How many pending requests are in Kibera?"}`.

The local operations assistant supports bounded, read-only aggregate queries
and does not send recipient information to an external AI provider. Merchant
matching uses shared neighborhood/city terms because requests currently
provide text locations rather than coordinates.

## Vercel Deployment

**See [DEPLOYMENT.md](../DEPLOYMENT.md) for complete deployment instructions.**

### Quick Setup Summary

1. **Database**: Use PostgreSQL (Vercel Postgres, Neon, Supabase). SQLite will NOT work on Vercel serverless.

2. **Backend Environment Variables** (Set in Vercel dashboard for `formula-flow-uh98`):
   - `DATABASE_URL` - PostgreSQL connection string (REQUIRED)
   - `FRONTEND_ORIGINS` - `https://formula-flow-9461.vercel.app`
   - `PAYPAL_ENVIRONMENT` - `sandbox`
   - `PAYPAL_CLIENT_ID` - Sandbox REST app client ID
   - `PAYPAL_CLIENT_SECRET` - Secret from same Sandbox app
   - `PAYPAL_WEBHOOK_ID` - Webhook ID from PayPal
   - `PICKUP_TOKEN_ENCRYPTION_KEY` - Generate with `python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"`
   - `PAYPAL_PAYOUT_SIMULATED` - `false` for real payouts
   - `OPENAI_API_KEY` - OpenAI key for Studio AI
   - `OPENAI_MODEL` - e.g., `gpt-4o`

3. **Frontend Environment Variables** (Set in Vercel dashboard for `formula-flow-9461`):
   - `VITE_API_BASE_URL` - `https://formula-flow-uh98.vercel.app`
   - `VITE_PAYPAL_CLIENT_ID` - Same Sandbox client ID as backend
   - `VITE_AG_STUDIO_LICENSE_KEY` - AG Studio license key

4. **PayPal Webhook**: Register `https://formula-flow-uh98.vercel.app/api/paypal/webhook` in PayPal Developer Dashboard

5. **Health Check**: Verify deployment at `https://formula-flow-uh98.vercel.app/health`

### Database Migration from SQLite

If migrating from SQLite, export your data and import to PostgreSQL:

```bash
# Export SQLite
sqlite3 formula_requests.db .dump > backup.sql

# Import to PostgreSQL (may need syntax adjustments)
psql $DATABASE_URL < backup.sql
```

Or use `pgloader` for automated migration.

### Important Notes

- Vercel serverless functions have no persistent filesystem
- Use PostgreSQL with connection pooling for production
- Keep secrets (API keys, database credentials) in Vercel environment variables only
- Never expose `PAYPAL_CLIENT_SECRET` or `OPENAI_API_KEY` in frontend variables
- The in-memory rate limiter is per-function instance; use Redis for multi-instance deployments

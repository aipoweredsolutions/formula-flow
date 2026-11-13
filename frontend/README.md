# FormulaFlow frontend

## Production Deployment

**This project is deployed on Vercel**. See [DEPLOYMENT.md](../DEPLOYMENT.md) for complete deployment instructions.

**Production URLs:**
- Frontend: https://formula-flow-9461.vercel.app
- Backend: https://formula-flow-uh98.vercel.app

## Local Development

The React/Vite app includes a public PayPal donor portal, a mobile-friendly
recipient request form, and an authenticated operations dashboard. During
local development, Vite forwards `/api` requests to `http://127.0.0.1:8000`.
Set `API_PROXY_TARGET` to use another backend or `VITE_API_BASE_URL` when the
frontend is served separately.

Run from this directory:

```powershell
npm install
npm run dev
```

The dashboard uses AG Grid Community for the request ledger and a searchable,
sortable supplier directory. Supplier names, locations, PayPal emails, and
unit prices can be edited directly in the directory; edits are saved through
the authenticated API. A form is also available for adding suppliers. The
dashboard includes location cross-filtering and pool metrics. Its operations
assistant sends questions to a bounded, local read-only backend endpoint; it
does not transmit recipient details to an external AI service. The anomaly
panel displays payout failures/unknown outcomes and recorded merchant price
surges. Request stages and payout outcomes are live database aggregates, not
sample pipeline counts. The dashboard refreshes every 30 seconds; funded
families count only PayPal-confirmed payouts, while collection is tracked as a
separate support stage. This implementation does not require an AG Grid
Enterprise license.

The full-screen AG Studio editor is available at `/studio` after signing in
under Internal operations. It loads donations, payouts, requests, merchants,
and merchant price history as separate admin-only API sources. Those sources
omit recipient names and phone numbers, PayPal account details, and payment
order IDs. Studio edits
reports in the browser only; it has no API tools for approving requests or
sending payouts. AG Studio's AI panel is wired to the OpenAI Responses API
through the authenticated `/api/llm` backend proxy. Tool calls are streamed
back to Studio for its local dashboard actions. The OpenAI key and model are
configured on the backend only; each admin account is limited to 30 AI
requests per minute per API process.

The read-only `/reports` area provides separate Overview, Donations, Payouts,
Requests, Fulfillment, and Merchants & pricing pages. It uses the same admin
session and privacy-filtered data sources as Studio. Reports use a green AG
Charts palette, with colorful stage metrics in the fulfillment view. The
Fulfillment report compares approved, PayPal-confirmed, and collected requests
by county, shows completed-stage average durations, and lists requests waiting
for pickup without recipient contact details. Requests and chemist profiles
include an explicit county field for regional reporting. Older records without
a county remain labelled "Not recorded". Donation reports include received
totals and dates, but not a county breakdown: donor locations are not collected,
and pooled donations are not linked to individual requests. Reports and Studio
sources refresh every 30 seconds; the public family-funded total excludes
simulated payouts.

The `opsAnalyst` agent supplements the five default agents. It can inspect
schema/report/page/widget state, query dashboard data, and add, position, or
configure widgets. It cannot change operational records or perform payouts.
When asked, it reviews payouts pending over 48 hours, merchant price changes,
and unusual donation patterns; it explains findings in plain language and
builds one widget per finding. All findings and widget titles are labelled
“suggestion for staff review”. FormulaFlow merchant price history is exposed
to Studio as an admin-only source without payment account details.

Studio also registers two FormulaFlow custom widgets in the widget menu and
AI catalogue: **Aid Pipeline Funnel** summarizes donation, payout,
ready-for-pickup, and collected counts and USD amounts; **Impact Scoreboard**
shows collected families, captured donation totals, and median time from
payout-pending to payout-confirmed. Both use the current Studio theme colors
and fonts. AI agents can add and configure either widget using the exposed
source mappings.

The admin page uses email/password login backed by the API. Only the first
admin account can be registered; after setup, the registration option closes.
An authenticated session is held in the browser's session storage and ends at
logout or after its 12-hour server-side expiry. No manually rotated admin token
is required.

Recipients can check `/status` with the 32-character reference code shown
after request submission. `POST /api/public/request-status` returns only the
public stage and its last-updated timestamp. Codes contain 192 bits of
randomness, and lookups are limited to 10 attempts per client IP per minute
per API process. Rejected requests are not included in the public stage flow.

## Donor checkout

Copy `.env.example` to `.env.local` and set `VITE_PAYPAL_CLIENT_ID` to your
PayPal Sandbox app's client ID. Set `VITE_AG_STUDIO_LICENSE_KEY` to your AG
Studio licence key. The AG Studio key and PayPal client ID are passed to the
browser; never put PayPal client secrets or LLM keys in `VITE_` variables.

Vite reads these values at startup. Restart `npm run dev` after changing
`.env.local`. The donor portal creates PayPal Orders through the FormulaFlow
backend, captures approved payments, and records confirmed captures in the
donation ledger and support pool. The backend must use the matching
`PAYPAL_CLIENT_ID`, its secret in `PAYPAL_CLIENT_SECRET`, and
`PAYPAL_ENVIRONMENT=sandbox`; never use a Live app's credentials. See
[the backend README](../backend/README.md) and [DEPLOYMENT.md](../DEPLOYMENT.md) 
for webhook, pool, and payout configuration.

## Vercel Deployment

For production deployment to Vercel, set these environment variables in the Vercel dashboard:

- `VITE_API_BASE_URL` - Your backend URL (e.g., `https://formula-flow-uh98.vercel.app`)
- `VITE_PAYPAL_CLIENT_ID` - PayPal Sandbox client ID (safe to expose in browser)
- `VITE_AG_STUDIO_LICENSE_KEY` - AG Studio license key
- `VITE_PAYPAL_HOSTED_BUTTON_ID` - (Optional) PayPal hosted button ID

**NEVER** put these in frontend variables:
- `PAYPAL_CLIENT_SECRET` - Backend only!
- `OPENAI_API_KEY` - Backend only!
- `DATABASE_URL` - Backend only!

See [DEPLOYMENT.md](../DEPLOYMENT.md) for complete deployment guide.

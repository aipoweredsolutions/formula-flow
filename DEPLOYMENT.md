# FormulaFlow AI - Vercel Deployment Guide

## Production URLs

- **Frontend**: https://formula-flow-9461.vercel.app
- **Backend API**: https://formula-flow-uh98.vercel.app

## Prerequisites

1. Vercel account with two projects created:
   - `formula-flow-9461` (Frontend)
   - `formula-flow-uh98` (Backend)
2. PostgreSQL database (Vercel Postgres, Neon, Supabase, or similar)
3. PayPal Sandbox REST App credentials
4. OpenAI API key (for Studio AI features)
5. AG Studio license key (for Studio features)

## Backend Deployment (Vercel)

### 1. Database Setup

**IMPORTANT**: Vercel uses serverless functions. SQLite will NOT persist between function invocations. You MUST use PostgreSQL or another managed database.

#### Option A: Vercel Postgres (Recommended)
```bash
# In your Vercel project dashboard
1. Go to Storage → Create Database → Postgres
2. Copy the connection string from the .env.local tab
```

#### Option B: External PostgreSQL (Neon, Supabase, etc.)
- Create a PostgreSQL database
- Get the connection string (format: `postgresql://user:password@host:port/dbname`)

### 2. Environment Variables

Set these in the Vercel dashboard for your backend project (`formula-flow-uh98`):

| Variable | Value | Notes |
|----------|-------|-------|
| `DATABASE_URL` | `postgresql://user:pass@host:port/db` | **REQUIRED** - Use PostgreSQL, not SQLite |
| `FRONTEND_ORIGINS` | `https://formula-flow-9461.vercel.app` | Your frontend URL |
| `PAYPAL_ENVIRONMENT` | `sandbox` | Always use sandbox for testing |
| `PAYPAL_CLIENT_ID` | `your-sandbox-client-id` | From PayPal Developer Dashboard |
| `PAYPAL_CLIENT_SECRET` | `your-sandbox-client-secret` | Keep this secret! |
| `PAYPAL_WEBHOOK_ID` | `your-webhook-id` | From PayPal webhook configuration |
| `PAYPAL_PAYOUT_SIMULATED` | `false` | Set to `true` only for demos |
| `PICKUP_TOKEN_ENCRYPTION_KEY` | Generated Fernet key | See generation below |
| `OPENAI_API_KEY` | `sk-...` | For Studio AI proxy |
| `OPENAI_MODEL` | `gpt-4o` | OpenAI model to use |

#### Generate Fernet Key for Pickup Tokens
```powershell
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

### 3. Deploy Backend

```bash
cd backend
vercel --prod
```

Or connect your GitHub repository to Vercel for automatic deployments.

### 4. Configure PayPal Webhook

1. Go to [PayPal Developer Dashboard](https://developer.paypal.com/)
2. Navigate to **Apps & Credentials → Sandbox**
3. Select your REST App
4. Add webhook URL: `https://formula-flow-uh98.vercel.app/api/paypal/webhook`
5. Subscribe to these events:
   - `PAYMENT.CAPTURE.COMPLETED`
   - `PAYMENT.CAPTURE.DENIED`
   - `PAYMENT.PAYOUTSBATCH.PROCESSING`
   - `PAYMENT.PAYOUTSBATCH.SUCCESS`
   - `PAYMENT.PAYOUTSBATCH.DENIED`
   - `PAYMENT.PAYOUTSBATCH.CANCELED`
   - `PAYMENT.PAYOUTSBATCH.RETURNED`
6. Copy the Webhook ID and set it as `PAYPAL_WEBHOOK_ID` in Vercel

## Frontend Deployment (Vercel)

### 1. Environment Variables

Set these in the Vercel dashboard for your frontend project (`formula-flow-9461`):

| Variable | Value | Notes |
|----------|-------|-------|
| `VITE_API_BASE_URL` | `https://formula-flow-uh98.vercel.app` | Your backend URL |
| `VITE_PAYPAL_CLIENT_ID` | `your-sandbox-client-id` | Same as backend (public, safe to expose) |
| `VITE_AG_STUDIO_LICENSE_KEY` | Your AG Studio key | For Studio features |
| `VITE_PAYPAL_HOSTED_BUTTON_ID` | Optional button ID | If using hosted buttons |

### 2. Deploy Frontend

```bash
cd frontend
vercel --prod
```

Or connect your GitHub repository to Vercel for automatic deployments.

## Post-Deployment Setup

### 1. Create Initial Admin Account

1. Visit `https://formula-flow-9461.vercel.app/admin`
2. Register the first admin account (email + 12+ character password)
3. This registration closes after the first account is created
4. Login with your admin credentials

### 2. Test PayPal Integration

#### Test Donations:
1. Go to `/donate`
2. Select an amount
3. Click PayPal button
4. Login with your PayPal Sandbox buyer account
5. Approve the payment
6. Verify the donation appears in the admin dashboard

#### Test Payouts:
1. Create a vendor in the admin dashboard
2. Use a PayPal Sandbox account email for the vendor
3. Submit a test request as a recipient
4. Approve the request as admin
5. Match with the vendor
6. Initiate a payout
7. Check that the payout processes and the webhook is received

### 3. Verify Database Persistence

- Check that requests persist after Vercel function cold starts
- Verify admin sessions work correctly
- Test that donations and payouts are recorded properly

### 4. Test Webhook Delivery

In PayPal Developer Dashboard:
1. Go to your webhook settings
2. Use **Webhook Simulator**
3. Send test events to `https://formula-flow-uh98.vercel.app/api/paypal/webhook`
4. Check backend logs in Vercel to confirm events are received and processed

## Database Migration from SQLite to PostgreSQL

If you have existing data in SQLite, you'll need to migrate:

### Option 1: Manual Export/Import
```bash
# Export from SQLite
sqlite3 formula_requests.db .dump > backup.sql

# Convert SQLite syntax to PostgreSQL (may need manual edits)
# Import to PostgreSQL
psql $DATABASE_URL < backup.sql
```

### Option 2: Use Migration Tool
```bash
pip install pgloader
pgloader sqlite://formula_requests.db $DATABASE_URL
```

### Option 3: Fresh Start
- If in development/testing phase, start fresh with PostgreSQL
- Create initial admin account again
- Re-enter any test data

## Troubleshooting

### Backend Issues

**Function Timeout**
- Vercel Hobby plan: 10s timeout (may be too short for some operations)
- Upgrade to Pro for 60s timeout if needed

**Database Connection Errors**
- Verify `DATABASE_URL` is set correctly
- Ensure database allows connections from Vercel IP addresses
- Check connection string format: `postgresql://` (not `sqlite://`)

**CORS Errors**
- Verify `FRONTEND_ORIGINS` matches your exact frontend URL
- Check that frontend is making requests to correct backend URL

**PayPal Errors**
- Verify all PayPal credentials are from the SAME Sandbox app
- Ensure `PAYPAL_ENVIRONMENT=sandbox` (never use `live`)
- Check webhook URL is correct and accessible

### Frontend Issues

**API Calls Failing**
- Check `VITE_API_BASE_URL` is set correctly
- Verify backend is deployed and health check passes: `https://formula-flow-uh98.vercel.app/health`

**PayPal Button Not Loading**
- Verify `VITE_PAYPAL_CLIENT_ID` matches backend's `PAYPAL_CLIENT_ID`
- Check browser console for errors

**Environment Variables Not Working**
- Remember: Vite requires `VITE_` prefix for client-side variables
- Restart development server after changing `.env.local`
- Re-deploy to Vercel after changing environment variables

## Security Checklist

- ✅ `PAYPAL_CLIENT_SECRET` is ONLY in backend environment (never in frontend)
- ✅ `OPENAI_API_KEY` is ONLY in backend environment (never in frontend)
- ✅ `PICKUP_TOKEN_ENCRYPTION_KEY` is secret and stable (don't change after tokens issued)
- ✅ `DATABASE_URL` is secure and not exposed publicly
- ✅ Using PostgreSQL (not SQLite) for production
- ✅ CORS configured with specific origins (not wildcards)
- ✅ PayPal webhook signature verification enabled
- ✅ Admin passwords are 12+ characters
- ✅ Using HTTPS for all production URLs

## Monitoring

### Check Backend Health
```bash
curl https://formula-flow-uh98.vercel.app/health
# Should return: {"status":"ok"}
```

### View Logs
- Vercel Dashboard → Your Project → Logs
- Filter by function, date, status code

### Monitor PayPal Webhooks
- PayPal Developer Dashboard → Webhooks → Recent Deliveries
- Check for failed deliveries and retry if needed

## Scaling Considerations

1. **Rate Limits**: Default in-memory rate limiting is per-function instance
   - For multiple instances, implement Redis-based rate limiting

2. **Database Connections**: Serverless functions create many connections
   - Use connection pooling (PgBouncer)
   - Configure max connections appropriately

3. **File Storage**: No persistent filesystem on Vercel
   - Use external storage (S3, Cloudinary) if needed

## Support

- Vercel Documentation: https://vercel.com/docs
- PayPal Sandbox: https://developer.paypal.com/
- Issues: Check GitHub repository issues

## Local Development

Even though deployed on Vercel, you can still develop locally:

```bash
# Backend (from repository root)
uvicorn backend.main:app --reload

# Frontend (from frontend directory)
npm run dev
```

Use `.env` files for local development, and Vercel dashboard for production environment variables.

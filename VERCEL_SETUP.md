# Vercel Setup Quick Reference

This is a quick reference for deploying FormulaFlow AI to Vercel. For complete details, see [DEPLOYMENT.md](./DEPLOYMENT.md).

## Prerequisites

1. ✅ Vercel account: https://vercel.com/signup
2. ✅ PostgreSQL database ready (Vercel Postgres, Neon, Supabase, etc.)
3. ✅ PayPal Sandbox credentials
4. ✅ Git repository connected to Vercel

## Step 1: Create Vercel Projects

### Option A: Via Vercel Dashboard
1. Go to https://vercel.com/new
2. Import your Git repository
3. Create TWO projects:
   - **Backend**: `formula-flow-uh98` (or your preferred name)
   - **Frontend**: `formula-flow-9461` (or your preferred name)

### Option B: Via Vercel CLI
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy backend
cd backend
vercel --prod

# Deploy frontend
cd ../frontend
vercel --prod
```

## Step 2: Configure Backend Environment Variables

Go to Vercel Dashboard → Backend Project → Settings → Environment Variables

Add these variables:

```bash
# Database (REQUIRED - use PostgreSQL)
DATABASE_URL=postgresql://user:password@host:5432/dbname

# CORS
FRONTEND_ORIGINS=https://your-frontend.vercel.app

# PayPal
PAYPAL_ENVIRONMENT=sandbox
PAYPAL_CLIENT_ID=your_sandbox_client_id
PAYPAL_CLIENT_SECRET=your_sandbox_secret
PAYPAL_WEBHOOK_ID=your_webhook_id
PAYPAL_PAYOUT_SIMULATED=false

# Security (generate with command below)
PICKUP_TOKEN_ENCRYPTION_KEY=your_fernet_key

# OpenAI (optional)
OPENAI_API_KEY=sk-your_key
OPENAI_MODEL=gpt-4o
```

### Generate Fernet Key
```powershell
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

## Step 3: Configure Frontend Environment Variables

Go to Vercel Dashboard → Frontend Project → Settings → Environment Variables

Add these variables:

```bash
VITE_API_BASE_URL=https://your-backend.vercel.app
VITE_PAYPAL_CLIENT_ID=your_sandbox_client_id
VITE_AG_STUDIO_LICENSE_KEY=your_ag_studio_key
```

**⚠️ NEVER add these to frontend:**
- `PAYPAL_CLIENT_SECRET` ❌
- `OPENAI_API_KEY` ❌
- `DATABASE_URL` ❌

## Step 4: Configure PayPal Webhook

1. Go to https://developer.paypal.com/dashboard/
2. Apps & Credentials → Sandbox → Your App
3. Add webhook: `https://your-backend.vercel.app/api/paypal/webhook`
4. Subscribe to events:
   - `PAYMENT.CAPTURE.COMPLETED`
   - `PAYMENT.CAPTURE.DENIED`
   - `PAYMENT.PAYOUTSBATCH.PROCESSING`
   - `PAYMENT.PAYOUTSBATCH.SUCCESS`
   - `PAYMENT.PAYOUTSBATCH.DENIED`
   - `PAYMENT.PAYOUTSBATCH.CANCELED`
   - `PAYMENT.PAYOUTSBATCH.RETURNED`
5. Copy Webhook ID → Set as `PAYPAL_WEBHOOK_ID` in Vercel backend

## Step 5: Setup Database

### If using SQLite locally (need to migrate):
```bash
# Export from SQLite
sqlite3 formula_requests.db .dump > backup.sql

# Import to PostgreSQL (may need adjustments)
psql $DATABASE_URL < backup.sql
```

### If starting fresh:
1. Create PostgreSQL database
2. Set `DATABASE_URL` in Vercel
3. Deploy backend (tables auto-create on first run)
4. Create admin account at `/admin`

## Step 6: Verify Deployment

### Check Backend Health
```bash
curl https://your-backend.vercel.app/health
# Should return: {"status":"ok"}
```

### Check Frontend
Visit `https://your-frontend.vercel.app`

### Test Admin Login
1. Go to `/admin`
2. Create first admin account
3. Login

### Test Donation Flow
1. Go to `/donate`
2. Select amount
3. Complete PayPal checkout
4. Verify donation in admin dashboard

## Common Issues

### ❌ "Database unavailable"
- Verify `DATABASE_URL` is set in Vercel
- Check database is accessible from internet
- Ensure using PostgreSQL (not SQLite)

### ❌ CORS errors
- Verify `FRONTEND_ORIGINS` matches your frontend URL exactly
- Check for http vs https mismatch

### ❌ PayPal button not showing
- Check `VITE_PAYPAL_CLIENT_ID` is set in frontend
- Verify client ID matches backend
- Open browser console for errors

### ❌ Webhooks not working
- Verify webhook URL is correct and accessible
- Check `PAYPAL_WEBHOOK_ID` matches PayPal dashboard
- Test webhook in PayPal simulator

## File Checklist

After setup, ensure these files exist:

- ✅ `vercel.json` (root)
- ✅ `backend/vercel.json`
- ✅ `frontend/vercel.json`
- ✅ `.vercelignore`
- ✅ `DEPLOYMENT.md`
- ✅ `README.md`
- ✅ Backend `.env.example` updated
- ✅ Frontend `.env.example` updated
- ❌ `render.yaml` (should be removed)

## Quick Links

- [Complete Deployment Guide](./DEPLOYMENT.md)
- [Vercel Documentation](https://vercel.com/docs)
- [PayPal Developer Dashboard](https://developer.paypal.com/)
- [Backend README](./backend/README.md)
- [Frontend README](./frontend/README.md)

## Environment Variables Summary

| Variable | Backend | Frontend | Required |
|----------|---------|----------|----------|
| `DATABASE_URL` | ✅ | ❌ | Yes |
| `FRONTEND_ORIGINS` | ✅ | ❌ | Yes |
| `PAYPAL_CLIENT_ID` | ✅ | ❌ | Yes |
| `PAYPAL_CLIENT_SECRET` | ✅ | ❌ | Yes |
| `PAYPAL_WEBHOOK_ID` | ✅ | ❌ | Yes |
| `PICKUP_TOKEN_ENCRYPTION_KEY` | ✅ | ❌ | Yes |
| `VITE_API_BASE_URL` | ❌ | ✅ | Yes |
| `VITE_PAYPAL_CLIENT_ID` | ❌ | ✅ | Yes |
| `VITE_AG_STUDIO_LICENSE_KEY` | ❌ | ✅ | Optional |
| `OPENAI_API_KEY` | ✅ | ❌ | Optional |
| `OPENAI_MODEL` | ✅ | ❌ | Optional |

## Next Steps After Deployment

1. ✅ Create admin account
2. ✅ Add test vendors
3. ✅ Test donation flow
4. ✅ Test request submission
5. ✅ Test payout processing
6. ✅ Verify webhooks work
7. ✅ Monitor Vercel logs
8. ✅ Set up alerts (optional)

---

**Need help?** Check [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed troubleshooting.

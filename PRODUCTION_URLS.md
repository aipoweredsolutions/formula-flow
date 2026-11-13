# 🌐 Production URLs Configuration

## Current Production URLs

Based on your setup, here are the URLs you mentioned:

### Live Deployments
- **Frontend**: https://formula-flow-9461.vercel.app
- **Backend**: https://formula-flow-uh98.vercel.app

---

## 🔧 Where to Use These URLs

### 1. Vercel Backend Environment Variables
Set in: **Vercel Dashboard → formula-flow-uh98 → Settings → Environment Variables**

```bash
# Required
FRONTEND_ORIGINS=https://formula-flow-9461.vercel.app
DATABASE_URL=postgresql://user:password@host:5432/database
PAYPAL_ENVIRONMENT=sandbox
PAYPAL_CLIENT_ID=your_sandbox_client_id
PAYPAL_CLIENT_SECRET=your_sandbox_client_secret
PAYPAL_WEBHOOK_ID=your_webhook_id
PICKUP_TOKEN_ENCRYPTION_KEY=your_fernet_key
PAYPAL_PAYOUT_SIMULATED=false

# Optional
OPENAI_API_KEY=sk-your_key
OPENAI_MODEL=gpt-4o
```

### 2. Vercel Frontend Environment Variables
Set in: **Vercel Dashboard → formula-flow-9461 → Settings → Environment Variables**

```bash
# Required
VITE_API_BASE_URL=https://formula-flow-uh98.vercel.app
VITE_PAYPAL_CLIENT_ID=your_sandbox_client_id

# Optional
VITE_AG_STUDIO_LICENSE_KEY=your_license_key
VITE_PAYPAL_HOSTED_BUTTON_ID=your_button_id
```

### 3. PayPal Webhook URL
Set in: **PayPal Developer Dashboard → Apps & Credentials → Sandbox → Your App → Webhooks**

```
Webhook URL: https://formula-flow-uh98.vercel.app/api/paypal/webhook
```

Subscribe to these events:
- PAYMENT.CAPTURE.COMPLETED
- PAYMENT.CAPTURE.DENIED
- PAYMENT.PAYOUTSBATCH.PROCESSING
- PAYMENT.PAYOUTSBATCH.SUCCESS
- PAYMENT.PAYOUTSBATCH.DENIED
- PAYMENT.PAYOUTSBATCH.CANCELED
- PAYMENT.PAYOUTSBATCH.RETURNED

---

## 🧪 Testing Endpoints

### Backend Health Check
```bash
curl https://formula-flow-uh98.vercel.app/health
# Should return: {"status":"ok"}
```

### Frontend Pages
- Home: https://formula-flow-9461.vercel.app/
- Donate: https://formula-flow-9461.vercel.app/donate
- Request: https://formula-flow-9461.vercel.app/request
- Status: https://formula-flow-9461.vercel.app/status
- Admin: https://formula-flow-9461.vercel.app/admin
- Studio: https://formula-flow-9461.vercel.app/studio
- Reports: https://formula-flow-9461.vercel.app/reports

---

## 📝 Local .env Files (For Development)

### backend/.env
```bash
FRONTEND_ORIGINS=http://localhost:5173
DATABASE_URL=sqlite:///./formula_requests.db
PAYPAL_ENVIRONMENT=sandbox
PAYPAL_CLIENT_ID=your_sandbox_client_id
PAYPAL_CLIENT_SECRET=your_sandbox_client_secret
PAYPAL_WEBHOOK_ID=your_webhook_id
PAYPAL_PAYOUT_SIMULATED=false
PICKUP_TOKEN_ENCRYPTION_KEY=your_fernet_key
OPENAI_API_KEY=sk-your_key
OPENAI_MODEL=gpt-4o
```

### frontend/.env.local
```bash
VITE_API_BASE_URL=http://localhost:8000
VITE_PAYPAL_CLIENT_ID=your_sandbox_client_id
VITE_AG_STUDIO_LICENSE_KEY=your_license_key
VITE_PAYPAL_HOSTED_BUTTON_ID=your_button_id
```

---

## 🔄 CORS Configuration

The backend will accept requests from:
- Production: `https://formula-flow-9461.vercel.app`
- Development: `http://localhost:5173`

Make sure `FRONTEND_ORIGINS` in backend matches exactly (no trailing slash).

---

## 🚨 Important Notes

1. **Never commit .env files** to Git (they're in .gitignore)
2. **Environment variables with `VITE_` prefix** are public (embedded in frontend build)
3. **Never put secrets** in frontend variables (no `PAYPAL_CLIENT_SECRET` or `OPENAI_API_KEY`)
4. **Use PostgreSQL for production** (SQLite won't work on Vercel)
5. **Keep `PICKUP_TOKEN_ENCRYPTION_KEY` stable** (changing it invalidates active tokens)

---

## 📞 Quick Reference

| Service | URL | Purpose |
|---------|-----|---------|
| Frontend | https://formula-flow-9461.vercel.app | User-facing application |
| Backend | https://formula-flow-uh98.vercel.app | API server |
| Health | /health | Backend health check |
| Admin | /admin | Admin dashboard |
| Studio | /studio | AG Studio analytics |
| PayPal Webhook | /api/paypal/webhook | PayPal event receiver |

---

## 🔐 Security Checklist

Before going live:
- [ ] PostgreSQL configured (not SQLite)
- [ ] All environment variables set in Vercel
- [ ] `PAYPAL_CLIENT_SECRET` only in backend
- [ ] `OPENAI_API_KEY` only in backend
- [ ] `DATABASE_URL` only in backend
- [ ] PayPal webhook URL updated
- [ ] CORS configured correctly
- [ ] Admin account created
- [ ] Test donation flow
- [ ] Test payout flow
- [ ] Webhook delivery verified

---

## 📚 Related Documentation

- **DEPLOYMENT.md** - Complete deployment guide
- **VERCEL_SETUP.md** - Quick setup reference
- **DEPLOYMENT_CHECKLIST.md** - Verification checklist
- **MIGRATION_SUMMARY.md** - What changed

---

**Last Updated**: November 13, 2026  
**Repository**: https://github.com/aipoweredsolutions/formula-flow  
**Version**: 2.0.0

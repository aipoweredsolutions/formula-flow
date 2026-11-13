# 🚀 Vercel Deployment Checklist

Use this checklist to ensure your FormulaFlow AI deployment is complete and correct.

## Pre-Deployment ✅

### Repository Setup
- [ ] Git repository is up to date
- [ ] All environment files (`.env`, `.env.local`) are in `.gitignore`
- [ ] No secrets committed to repository
- [ ] Vercel configuration files exist:
  - [ ] Root `vercel.json`
  - [ ] `backend/vercel.json`
  - [ ] `frontend/vercel.json`
  - [ ] `.vercelignore`

### Database Preparation
- [ ] PostgreSQL database created
- [ ] Database is accessible from internet
- [ ] Connection string obtained
- [ ] If migrating: SQLite data exported
- [ ] If migrating: Data migration tested

### PayPal Setup
- [ ] PayPal Sandbox REST app created
- [ ] Client ID obtained
- [ ] Client secret obtained (keep secure!)
- [ ] Sandbox test accounts created (buyer + seller)

### Keys & Secrets
- [ ] Fernet encryption key generated
- [ ] OpenAI API key obtained (if using AI features)
- [ ] AG Studio license key obtained (if using Studio)

## Backend Deployment ✅

### Vercel Project Setup
- [ ] Backend project created in Vercel
- [ ] Git repository connected
- [ ] Project name: `formula-flow-uh98` (or your choice)
- [ ] Root directory: Leave empty (uses workspace root)
- [ ] Build command: Auto-detected
- [ ] Install command: Auto-detected

### Backend Environment Variables
Set in Vercel Dashboard → Project → Settings → Environment Variables:

**Required:**
- [ ] `DATABASE_URL` - PostgreSQL connection string
- [ ] `FRONTEND_ORIGINS` - Your frontend Vercel URL
- [ ] `PAYPAL_ENVIRONMENT` - `sandbox`
- [ ] `PAYPAL_CLIENT_ID` - From PayPal Dashboard
- [ ] `PAYPAL_CLIENT_SECRET` - From PayPal Dashboard
- [ ] `PAYPAL_WEBHOOK_ID` - (Set after webhook created)
- [ ] `PICKUP_TOKEN_ENCRYPTION_KEY` - Generated Fernet key
- [ ] `PAYPAL_PAYOUT_SIMULATED` - `false`

**Optional:**
- [ ] `OPENAI_API_KEY` - For AI assistant
- [ ] `OPENAI_MODEL` - e.g., `gpt-4o`

### Backend Deployment
- [ ] Deploy backend to production
- [ ] Deployment successful (green checkmark)
- [ ] Domain assigned (e.g., `formula-flow-uh98.vercel.app`)
- [ ] Health check passes: `/health` returns `{"status":"ok"}`

## Frontend Deployment ✅

### Vercel Project Setup
- [ ] Frontend project created in Vercel
- [ ] Git repository connected
- [ ] Project name: `formula-flow-9461` (or your choice)
- [ ] Root directory: `frontend`
- [ ] Framework preset: Vite
- [ ] Build command: `npm run build`
- [ ] Output directory: `dist`

### Frontend Environment Variables
Set in Vercel Dashboard → Project → Settings → Environment Variables:

**Required:**
- [ ] `VITE_API_BASE_URL` - Your backend Vercel URL
- [ ] `VITE_PAYPAL_CLIENT_ID` - Same as backend client ID

**Optional:**
- [ ] `VITE_AG_STUDIO_LICENSE_KEY` - For Studio features
- [ ] `VITE_PAYPAL_HOSTED_BUTTON_ID` - If using hosted buttons

### Frontend Deployment
- [ ] Deploy frontend to production
- [ ] Deployment successful (green checkmark)
- [ ] Domain assigned (e.g., `formula-flow-9461.vercel.app`)
- [ ] Homepage loads without errors

## PayPal Configuration ✅

### Webhook Setup
- [ ] Go to PayPal Developer Dashboard
- [ ] Navigate to Apps & Credentials → Sandbox
- [ ] Select your REST app
- [ ] Add webhook URL: `https://your-backend.vercel.app/api/paypal/webhook`
- [ ] Subscribe to events:
  - [ ] `PAYMENT.CAPTURE.COMPLETED`
  - [ ] `PAYMENT.CAPTURE.DENIED`
  - [ ] `PAYMENT.PAYOUTSBATCH.PROCESSING`
  - [ ] `PAYMENT.PAYOUTSBATCH.SUCCESS`
  - [ ] `PAYMENT.PAYOUTSBATCH.DENIED`
  - [ ] `PAYMENT.PAYOUTSBATCH.CANCELED`
  - [ ] `PAYMENT.PAYOUTSBATCH.RETURNED`
- [ ] Copy webhook ID
- [ ] Set `PAYPAL_WEBHOOK_ID` in backend environment variables
- [ ] Redeploy backend

### Webhook Testing
- [ ] Use PayPal webhook simulator
- [ ] Send test event
- [ ] Check Vercel logs - event received
- [ ] Verify event recorded in database

## Application Setup ✅

### Admin Account
- [ ] Visit frontend at `/admin`
- [ ] Registration page loads
- [ ] Create first admin account (email + password 12+ chars)
- [ ] Login successful
- [ ] Dashboard loads

### Vendor Setup
- [ ] Add at least one test vendor
- [ ] Vendor name set
- [ ] PayPal email (use Sandbox account)
- [ ] Price per container set
- [ ] Location and county set

## Functional Testing ✅

### Donation Flow
- [ ] Visit `/donate` page
- [ ] PayPal button displays
- [ ] Select donation amount
- [ ] Click PayPal button
- [ ] PayPal popup opens
- [ ] Login with Sandbox buyer account
- [ ] Approve payment
- [ ] Success message displays
- [ ] Capture ID shown
- [ ] Donation appears in admin dashboard
- [ ] Pool balance increased
- [ ] Donation recorded in database

### Request Submission
- [ ] Visit `/request` page
- [ ] Fill out request form
- [ ] Submit successfully
- [ ] Reference code received
- [ ] Request appears in admin dashboard
- [ ] Status shows "Pending Verification"

### Request Processing (Admin)
- [ ] Login to admin dashboard
- [ ] View pending request
- [ ] Approve request
- [ ] Match with vendor
- [ ] Initiate payout
- [ ] Payout status updates
- [ ] Check PayPal status (if needed)

### Webhook Processing
- [ ] Make a donation
- [ ] Webhook received (check Vercel logs)
- [ ] Pool balance updated correctly
- [ ] Process a payout
- [ ] Payout webhook received
- [ ] Request status updated to "Payout Confirmed"
- [ ] Pickup token generated

### Status Lookup
- [ ] Visit `/status` page
- [ ] Enter reference code
- [ ] Status displays correctly
- [ ] Timestamp shown

### Pickup Flow
- [ ] Retrieve pickup token (admin)
- [ ] Token displays correctly
- [ ] Token expiry shown
- [ ] Redeem token at `/api/pickup/redeem`
- [ ] Request marked as "Collected"

## Security Verification ✅

### Environment Variables
- [ ] No secrets in Git repository
- [ ] `PAYPAL_CLIENT_SECRET` ONLY in backend
- [ ] `OPENAI_API_KEY` ONLY in backend (if used)
- [ ] `DATABASE_URL` ONLY in backend
- [ ] Public variables (`VITE_*`) correctly in frontend

### CORS
- [ ] Frontend can make API requests
- [ ] No CORS errors in browser console
- [ ] Only allowed origins configured

### Authentication
- [ ] Admin routes require login
- [ ] Sessions expire after 12 hours
- [ ] Logout works correctly
- [ ] Password change works

### PayPal
- [ ] Using Sandbox environment only
- [ ] Webhook signatures verified
- [ ] No Live credentials used

## Monitoring Setup ✅

### Vercel Logs
- [ ] Access Vercel backend logs
- [ ] Access Vercel frontend logs
- [ ] No critical errors in logs
- [ ] Can filter by function and time

### Health Monitoring
- [ ] Set up uptime monitoring (optional)
- [ ] Health endpoint: `https://backend.vercel.app/health`
- [ ] Should return `{"status":"ok"}`

### Database Monitoring
- [ ] Database connection count monitored
- [ ] Connection pooling configured (if needed)
- [ ] Database backups scheduled

## Documentation Review ✅

### Files Exist
- [ ] `README.md` at root
- [ ] `DEPLOYMENT.md` complete
- [ ] `VERCEL_SETUP.md` available
- [ ] `CHANGELOG.md` updated
- [ ] `backend/README.md` updated
- [ ] `frontend/README.md` updated
- [ ] `.env.production.example` created

### Documentation Accuracy
- [ ] URLs in docs match deployment
- [ ] Environment variables documented
- [ ] Troubleshooting section complete
- [ ] Security notes included

## Post-Deployment ✅

### Performance
- [ ] Frontend loads in < 3 seconds
- [ ] API responses < 1 second
- [ ] No cold start timeout issues
- [ ] Database queries optimized

### User Experience
- [ ] All pages load correctly
- [ ] Forms submit properly
- [ ] Navigation works
- [ ] Mobile responsive
- [ ] No console errors

### Communication
- [ ] Team notified of new URLs
- [ ] Documentation shared
- [ ] Admin credentials secured
- [ ] Backup procedures documented

## Ongoing Maintenance ✅

### Regular Tasks
- [ ] Monitor Vercel logs weekly
- [ ] Check PayPal webhook deliveries
- [ ] Review database size/performance
- [ ] Verify backup integrity
- [ ] Update dependencies monthly

### Security
- [ ] Rotate secrets periodically
- [ ] Review access logs
- [ ] Monitor for suspicious activity
- [ ] Keep dependencies updated

---

## 🆘 If Something Goes Wrong

1. **Check Vercel Logs**: Most issues show up here first
2. **Verify Environment Variables**: Missing or incorrect values are common
3. **Test Health Endpoint**: `curl https://backend.vercel.app/health`
4. **Check PayPal Dashboard**: For webhook and payout issues
5. **Consult DEPLOYMENT.md**: Detailed troubleshooting guide

## 📚 Quick Links

- [Complete Deployment Guide](./DEPLOYMENT.md)
- [Vercel Setup Guide](./VERCEL_SETUP.md)
- [Backend README](./backend/README.md)
- [Frontend README](./frontend/README.md)
- [Changelog](./CHANGELOG.md)

---

**Last Updated**: 2026-11-13  
**Version**: 2.0.0  
**Platform**: Vercel

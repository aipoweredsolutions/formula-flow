# FormulaFlow AI

FormulaFlow AI connects families in need with infant formula through a donation-funded platform. The system manages donor contributions via PayPal, coordinates with local suppliers, and facilitates formula distribution with secure pickup tokens.

## 🌐 Production Deployment

**Platform**: Vercel

**Live URLs**:
- Frontend: https://formula-flow-9461.vercel.app
- Backend API: https://formula-flow-uh98.vercel.app

**📖 [Complete Deployment Guide](./DEPLOYMENT.md)**

## ⚠️ Important Notes

- **Database**: Production MUST use PostgreSQL (not SQLite) due to Vercel serverless architecture
- **PayPal**: Configured for Sandbox only (never use Live credentials)
- **Security**: All secrets must be set in Vercel environment variables, never in code

## 🚀 Quick Start (Local Development)

### Prerequisites
- Python 3.11+
- Node.js 18+
- PayPal Sandbox account
- PostgreSQL (for production-like local setup) or SQLite (for quick testing)

### Backend Setup

```powershell
# From repository root
Copy-Item backend\.env.example backend\.env
# Edit backend\.env with your PayPal Sandbox credentials

# Install dependencies
python -m pip install -r backend\requirements.txt

# Run development server
uvicorn backend.main:app --reload
```

Backend runs at: http://localhost:8000

### Frontend Setup

```powershell
# From repository root
cd frontend
Copy-Item .env.example .env.local
# Edit .env.local with your PayPal client ID and AG Studio key

# Install dependencies
npm install

# Run development server
npm run dev
```

Frontend runs at: http://localhost:5173

## 📁 Project Structure

```
formulaflow-ai/
├── backend/              # FastAPI backend
│   ├── main.py          # API endpoints
│   ├── database.py      # SQLAlchemy models
│   ├── business_logic.py # Core business rules
│   ├── ai_agent.py      # Admin query assistant
│   ├── paypal_client.py # PayPal integration
│   ├── requirements.txt # Python dependencies
│   ├── vercel.json      # Vercel backend config
│   └── .env.example     # Environment template
├── frontend/            # React + Vite frontend
│   ├── src/
│   │   ├── components/  # React components
│   │   ├── App.jsx      # Main app component
│   │   └── main.jsx     # Entry point
│   ├── package.json     # Node dependencies
│   ├── vercel.json      # Vercel frontend config
│   └── .env.example     # Environment template
├── vercel.json          # Root Vercel config
├── DEPLOYMENT.md        # Detailed deployment guide
└── README.md            # This file
```

## 🎯 Key Features

### For Donors
- **PayPal Integration**: Secure donations via PayPal Sandbox
- **Real-time Pool Tracking**: See available funds and impact metrics
- **Donation History**: View past contributions

### For Recipients
- **Request Submission**: Submit formula requests with infant details
- **Status Tracking**: Check request status with reference code
- **Secure Pickup**: Time-limited pickup tokens for formula collection

### For Administrators
- **Request Management**: Approve/reject requests with audit trail
- **Vendor Matching**: Assign suppliers based on location and inventory
- **Payout Processing**: Automated PayPal payouts to suppliers
- **AI Assistant**: Query system data in natural language
- **Analytics Studio**: AG Grid Studio for advanced reporting
- **Audit Logs**: Complete history of all actions

### For Suppliers/Vendors
- **Vendor Portal**: Manage inventory and pricing
- **Payout Tracking**: Monitor incoming PayPals
- **Token Redemption**: Validate and process pickup tokens

## 🔒 Security Features

- Admin authentication with bcrypt password hashing
- Session-based auth with 12-hour expiry
- Encrypted pickup tokens (Fernet encryption)
- PayPal webhook signature verification
- CORS protection with allowlist
- SQL injection prevention (SQLAlchemy ORM)
- Rate limiting on public endpoints

## 🛠️ Technology Stack

### Backend
- **Framework**: FastAPI
- **Database**: SQLAlchemy (PostgreSQL for production)
- **Payments**: PayPal REST API v2
- **AI**: OpenAI API (for admin assistant)
- **Encryption**: Cryptography (Fernet)
- **Deployment**: Vercel Serverless Functions

### Frontend
- **Framework**: React 18
- **Build Tool**: Vite
- **Routing**: React Router v6
- **Styling**: Tailwind CSS
- **Grid**: AG Grid Community
- **Charts**: AG Charts
- **Studio**: AG Studio Pro
- **Deployment**: Vercel Static Hosting

## 📊 Database Schema

Key tables:
- `formula_requests` - Recipient requests with lifecycle tracking
- `admin_accounts` - Administrator credentials and sessions
- `donation_records` - Captured PayPal donations
- `payment_transactions` - Supplier payouts
- `vendors` - Supplier directory
- `request_audit_events` - Complete audit trail
- `pool_balances` - Available donation funds

## 🔄 Request Lifecycle

1. **Submitted** - Recipient submits request
2. **Approved** - Admin reviews and approves
3. **Payout Pending** - Payment initiated to supplier
4. **Payout Confirmed** - PayPal confirms payment
5. **Ready for Pickup** - Pickup token generated
6. **Collected** - Recipient redeems token

## 🧪 Testing

### Backend Tests
```powershell
# From repository root
python -m pytest backend/tests/
```

### PayPal Sandbox Testing
See [DEPLOYMENT.md](./DEPLOYMENT.md) for complete PayPal testing checklist including:
- Donation capture flow
- Payout processing
- Webhook verification

## 📝 Environment Variables

### Backend Required
- `DATABASE_URL` - PostgreSQL connection string
- `FRONTEND_ORIGINS` - CORS allowed origins
- `PAYPAL_CLIENT_ID` - PayPal app client ID
- `PAYPAL_CLIENT_SECRET` - PayPal app secret
- `PAYPAL_WEBHOOK_ID` - PayPal webhook ID
- `PICKUP_TOKEN_ENCRYPTION_KEY` - Fernet encryption key

### Frontend Required
- `VITE_API_BASE_URL` - Backend API URL
- `VITE_PAYPAL_CLIENT_ID` - PayPal client ID (public)
- `VITE_AG_STUDIO_LICENSE_KEY` - AG Studio license

See `.env.example` files for complete lists.

## 🚨 Common Issues & Solutions

### "Database unavailable" error
- **Local**: Ensure backend is running and database file is accessible
- **Production**: Verify PostgreSQL connection string and database is running

### PayPal button not loading
- Check `VITE_PAYPAL_CLIENT_ID` matches backend `PAYPAL_CLIENT_ID`
- Verify using Sandbox credentials (not Live)
- Check browser console for errors

### CORS errors
- Verify `FRONTEND_ORIGINS` includes your frontend URL
- Check protocol (http vs https) matches exactly

### Webhook not receiving events
- Confirm webhook URL is publicly accessible
- Verify `PAYPAL_WEBHOOK_ID` is correct
- Check PayPal Developer Dashboard → Webhooks → Recent Deliveries

### SQLite on Vercel not working
- **This is expected!** Vercel is serverless - no persistent filesystem
- **Solution**: Migrate to PostgreSQL (see DEPLOYMENT.md)

## 📚 Additional Documentation

- [Backend README](./backend/README.md) - API endpoints and business logic
- [Frontend README](./frontend/README.md) - Component architecture and features
- [DEPLOYMENT.md](./DEPLOYMENT.md) - Complete Vercel deployment guide

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📄 License

See [LICENSE](./LICENSE) file for details.

## 🆘 Support

For deployment issues, see [DEPLOYMENT.md](./DEPLOYMENT.md) troubleshooting section.

For PayPal integration issues, consult the [PayPal Developer Documentation](https://developer.paypal.com/docs/api/overview/).

For Vercel deployment issues, see [Vercel Documentation](https://vercel.com/docs).

---

**Note**: This application uses PayPal Sandbox for all payment processing. Never use Live PayPal credentials. For production use with real payments, extensive additional testing, compliance review, and security audits are required.

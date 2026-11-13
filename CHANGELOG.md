# Changelog

All notable changes to FormulaFlow AI will be documented in this file.

## [2.0.0] - 2026-11-13

### 🚀 Major Changes - Migration to Vercel

#### Added
- **Vercel Deployment Configuration**
  - Created `vercel.json` for backend serverless function deployment
  - Created `frontend/vercel.json` for static site deployment
  - Created `backend/vercel.json` for backend-specific Vercel settings
  - Added `.vercelignore` file for cleaner deployments

- **Documentation**
  - Created comprehensive `DEPLOYMENT.md` with complete Vercel deployment guide
  - Created root `README.md` with project overview and quick start guide
  - Added `CHANGELOG.md` to track project changes
  - Added `.env.production.example` with production environment variable template
  - Added database migration script `backend/migrate_to_postgres.py`

- **Database Migration Tools**
  - Created PostgreSQL migration script for SQLite → PostgreSQL transition
  - Added migration documentation in DEPLOYMENT.md

#### Changed
- **Platform Migration**
  - Migrated from Render to Vercel
  - Updated production URLs:
    - Frontend: `https://formula-flow-9461.vercel.app`
    - Backend: `https://formula-flow-uh98.vercel.app`

- **Environment Configuration**
  - Updated `backend/.env` with Vercel frontend URL
  - Updated `backend/.env.example` with Vercel URLs and FRONTEND_ORIGINS
  - Updated `frontend/.env.local` with Vercel backend URL
  - Updated `frontend/.env.example` with Vercel backend URL
  - Updated `render.yaml` with Vercel URLs (before removal)

- **Documentation Updates**
  - Updated `backend/README.md` with Vercel deployment instructions
  - Updated `frontend/README.md` with Vercel configuration
  - Replaced Render deployment sections with Vercel guidance
  - Added database requirement warnings (PostgreSQL required, not SQLite)

#### Removed
- **Legacy Configuration**
  - Removed `render.yaml` (Render deployment configuration)
  - Removed Render-specific deployment instructions

#### Technical Notes
- **Database**: Production deployments MUST use PostgreSQL due to Vercel's serverless architecture (no persistent filesystem)
- **Environment Variables**: All secrets now managed through Vercel dashboard
- **CORS**: Updated to allow requests from Vercel frontend URL
- **PayPal Webhook**: Updated webhook URL to Vercel backend domain

### 🔧 Infrastructure Changes

#### Vercel Serverless Architecture
- Backend runs as Vercel Python serverless functions
- No persistent filesystem (SQLite not supported in production)
- Automatic scaling and cold start optimization
- Global edge network deployment

#### Database Requirements
- **Development**: SQLite supported for local testing
- **Production**: PostgreSQL required (Vercel Postgres, Neon, Supabase, etc.)
- Connection pooling recommended for production (PgBouncer)

### 📚 Documentation Improvements

#### New Guides
1. **DEPLOYMENT.md**
   - Complete Vercel deployment walkthrough
   - Environment variable setup for both frontend and backend
   - Database migration guide from SQLite to PostgreSQL
   - PayPal webhook configuration
   - Troubleshooting section
   - Security checklist
   - Monitoring and scaling considerations

2. **README.md**
   - Project overview and features
   - Quick start for local development
   - Technology stack documentation
   - Project structure overview
   - Common issues and solutions

#### Updated Guides
- Backend README with Vercel-specific instructions
- Frontend README with Vercel deployment section
- Environment variable examples updated for Vercel

### 🔒 Security Enhancements

- Documented security best practices for Vercel deployment
- Clear separation of public vs. secret environment variables
- CORS configuration updated for production domain
- Environment variable security checklist added

### ⚠️ Breaking Changes

1. **Database**: SQLite will not work in Vercel production (must use PostgreSQL)
2. **Deployment Platform**: Render configuration no longer maintained
3. **Environment Variables**: Must be set in Vercel dashboard (not in render.yaml)
4. **URLs**: All hardcoded URLs updated to Vercel domains

### 🔄 Migration Path

For existing deployments migrating from Render to Vercel:

1. Set up PostgreSQL database (Vercel Postgres or external)
2. Migrate data from SQLite using `migrate_to_postgres.py`
3. Configure environment variables in Vercel dashboard
4. Deploy backend to Vercel (serverless functions)
5. Deploy frontend to Vercel (static hosting)
6. Update PayPal webhook URL to new Vercel backend URL
7. Test all functionality in production
8. Decommission Render deployment

### 📊 Production URLs

- **Frontend**: https://formula-flow-9461.vercel.app
- **Backend**: https://formula-flow-uh98.vercel.app
- **Health Check**: https://formula-flow-uh98.vercel.app/health

### 🎯 Verification Checklist

After migration, verify:
- ✅ Health endpoint returns 200 OK
- ✅ Database connections work (PostgreSQL)
- ✅ Admin login/registration functions
- ✅ PayPal donations process correctly
- ✅ PayPal webhooks are received
- ✅ Supplier payouts work
- ✅ Pickup tokens generate and validate
- ✅ CORS allows frontend requests
- ✅ All environment variables are set
- ✅ No SQLite references in production

---

## [1.0.0] - Previous Version

### Initial Release
- FastAPI backend with SQLAlchemy ORM
- React + Vite frontend with Tailwind CSS
- PayPal Sandbox integration for donations and payouts
- Admin dashboard with AG Grid
- AG Studio analytics integration
- Pickup token system with encryption
- Request lifecycle management
- Audit trail for all operations
- Deployed on Render with SQLite database

---

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes or platform migrations
- **MINOR** version for added functionality in a backward compatible manner
- **PATCH** version for backward compatible bug fixes

# FormulaFlow AI - Vercel Deployment Helper Script
# This script helps you deploy to Vercel step by step

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  FormulaFlow AI - Vercel Deployment" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if Vercel CLI is installed
Write-Host "Checking for Vercel CLI..." -ForegroundColor Yellow
$vercelInstalled = Get-Command vercel -ErrorAction SilentlyContinue

if (-not $vercelInstalled) {
    Write-Host "❌ Vercel CLI not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Installing Vercel CLI..." -ForegroundColor Yellow
    npm install -g vercel
    Write-Host "✅ Vercel CLI installed!" -ForegroundColor Green
} else {
    Write-Host "✅ Vercel CLI found!" -ForegroundColor Green
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Pre-Deployment Checklist" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Checklist
Write-Host "Before deploying, ensure you have:" -ForegroundColor Yellow
Write-Host "  [ ] PostgreSQL database created (not SQLite)" -ForegroundColor White
Write-Host "  [ ] Database connection string ready" -ForegroundColor White
Write-Host "  [ ] PayPal Sandbox credentials" -ForegroundColor White
Write-Host "  [ ] Fernet encryption key generated" -ForegroundColor White
Write-Host "  [ ] OpenAI API key (optional)" -ForegroundColor White
Write-Host "  [ ] AG Studio license key (optional)" -ForegroundColor White
Write-Host ""

$ready = Read-Host "Are you ready to proceed? (yes/no)"

if ($ready -ne "yes") {
    Write-Host ""
    Write-Host "No problem! Here's what you need to do:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Set up PostgreSQL:" -ForegroundColor Cyan
    Write-Host "   - Vercel Postgres (recommended): https://vercel.com/docs/storage/vercel-postgres"
    Write-Host "   - Neon: https://neon.tech"
    Write-Host "   - Supabase: https://supabase.com"
    Write-Host ""
    Write-Host "2. Generate Fernet key:" -ForegroundColor Cyan
    Write-Host '   python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"'
    Write-Host ""
    Write-Host "3. Get PayPal Sandbox credentials:" -ForegroundColor Cyan
    Write-Host "   https://developer.paypal.com/dashboard/"
    Write-Host ""
    Write-Host "4. Read the deployment guide:" -ForegroundColor Cyan
    Write-Host "   DEPLOYMENT.md or VERCEL_SETUP.md"
    Write-Host ""
    Write-Host "When ready, run this script again!" -ForegroundColor Green
    exit
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Deployment Options" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "How would you like to deploy?" -ForegroundColor Yellow
Write-Host "  1. Deploy backend only" -ForegroundColor White
Write-Host "  2. Deploy frontend only" -ForegroundColor White
Write-Host "  3. Deploy both (recommended for first time)" -ForegroundColor White
Write-Host "  4. Link existing Vercel projects" -ForegroundColor White
Write-Host "  5. View deployment checklist" -ForegroundColor White
Write-Host "  6. Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-6)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Deploying Backend..." -ForegroundColor Green
        Write-Host ""
        Write-Host "IMPORTANT: After deployment, set environment variables in Vercel dashboard!" -ForegroundColor Yellow
        Write-Host ""
        Set-Location backend
        vercel --prod
        Set-Location ..
    }
    "2" {
        Write-Host ""
        Write-Host "Deploying Frontend..." -ForegroundColor Green
        Write-Host ""
        Write-Host "IMPORTANT: After deployment, set environment variables in Vercel dashboard!" -ForegroundColor Yellow
        Write-Host ""
        Set-Location frontend
        vercel --prod
        Set-Location ..
    }
    "3" {
        Write-Host ""
        Write-Host "Deploying Both Projects..." -ForegroundColor Green
        Write-Host ""
        
        Write-Host "Step 1: Deploying Backend..." -ForegroundColor Cyan
        Set-Location backend
        vercel --prod
        $backendUrl = Read-Host "Enter the deployed backend URL (e.g., https://formula-flow-uh98.vercel.app)"
        Set-Location ..
        
        Write-Host ""
        Write-Host "Step 2: Deploying Frontend..." -ForegroundColor Cyan
        Set-Location frontend
        vercel --prod
        $frontendUrl = Read-Host "Enter the deployed frontend URL (e.g., https://formula-flow-9461.vercel.app)"
        Set-Location ..
        
        Write-Host ""
        Write-Host "=====================================" -ForegroundColor Cyan
        Write-Host "  Deployment Complete!" -ForegroundColor Green
        Write-Host "=====================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Your URLs:" -ForegroundColor Yellow
        Write-Host "  Backend:  $backendUrl" -ForegroundColor White
        Write-Host "  Frontend: $frontendUrl" -ForegroundColor White
        Write-Host ""
        Write-Host "NEXT STEPS:" -ForegroundColor Yellow
        Write-Host "1. Set environment variables in Vercel dashboard for BOTH projects"
        Write-Host "2. Update PayPal webhook URL to: $backendUrl/api/paypal/webhook"
        Write-Host "3. Test health endpoint: $backendUrl/health"
        Write-Host "4. Create admin account: $frontendUrl/admin"
        Write-Host ""
        Write-Host "See DEPLOYMENT_CHECKLIST.md for complete verification steps!" -ForegroundColor Cyan
    }
    "4" {
        Write-Host ""
        Write-Host "Linking Existing Projects..." -ForegroundColor Green
        Write-Host ""
        
        Write-Host "Backend:" -ForegroundColor Cyan
        Set-Location backend
        vercel link
        Set-Location ..
        
        Write-Host ""
        Write-Host "Frontend:" -ForegroundColor Cyan
        Set-Location frontend
        vercel link
        Set-Location ..
        
        Write-Host ""
        Write-Host "✅ Projects linked!" -ForegroundColor Green
    }
    "5" {
        Write-Host ""
        Write-Host "Opening deployment checklist..." -ForegroundColor Green
        if (Test-Path "DEPLOYMENT_CHECKLIST.md") {
            Start-Process "DEPLOYMENT_CHECKLIST.md"
        } else {
            Write-Host "❌ DEPLOYMENT_CHECKLIST.md not found!" -ForegroundColor Red
        }
    }
    "6" {
        Write-Host ""
        Write-Host "Goodbye! 👋" -ForegroundColor Cyan
        exit
    }
    default {
        Write-Host ""
        Write-Host "❌ Invalid choice!" -ForegroundColor Red
        Write-Host "Run the script again and choose 1-6" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Helpful Commands" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "View logs:" -ForegroundColor Yellow
Write-Host "  vercel logs <url>" -ForegroundColor White
Write-Host ""
Write-Host "Open project dashboard:" -ForegroundColor Yellow
Write-Host "  vercel" -ForegroundColor White
Write-Host ""
Write-Host "List deployments:" -ForegroundColor Yellow
Write-Host "  vercel ls" -ForegroundColor White
Write-Host ""
Write-Host "Environment variables:" -ForegroundColor Yellow
Write-Host "  vercel env ls" -ForegroundColor White
Write-Host "  vercel env add" -ForegroundColor White
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "  DEPLOYMENT.md - Complete guide" -ForegroundColor White
Write-Host "  VERCEL_SETUP.md - Quick reference" -ForegroundColor White
Write-Host "  DEPLOYMENT_CHECKLIST.md - Step-by-step checklist" -ForegroundColor White
Write-Host ""
Write-Host "Need help? Check the docs or visit https://vercel.com/docs" -ForegroundColor Cyan
Write-Host ""

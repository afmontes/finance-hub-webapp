# Finance Hub Webapp Development Roadmap

## Project Overview
Personal finance management webapp based on Midday's core architecture, customized for personal financial tracking with transaction management as the primary focus. This will serve as Andrés' personal finance hub while maintaining the codebase's full feature set for potential future expansion.

## Project Goals
- **Primary**: Personal finance tracking with sophisticated transaction management
- **Secondary**: Maintain full codebase integrity for future commercial use
- **Tertiary**: Create foundation for additional personal finance features

## Core Technology Stack
- **Frontend**: Next.js 15.3.3 + React 19 + TypeScript + TailwindCSS
- **Backend**: tRPC API + Supabase (PostgreSQL + Auth + Storage)
- **Bank Integration**: Plaid API (Canada/US) - keeping existing implementation
- **Hosting**: Supabase + Vercel + Fly.io (original stack maintained)
- **Package Manager**: Bun + Turborepo monorepo structure

## Feature Scope

### ✅ **Core Features (Active)**

#### **Main Menu Pages**
1. **Overview** (Preserved)
   - Financial metrics and insights
   - Account balances summary
   - Recent transactions overview
   - Monthly spending trends
   - Net worth tracking

2. **Transactions** (Preserved - Primary focus)
   - Transaction categorization and tagging
   - Bank account connections via Plaid
   - Transaction filtering and search
   - Export functionality
   - Transaction attachments
   - Bulk operations and editing

3. **Spending** (New)
   - Spending analytics by category
   - Monthly/yearly spending trends
   - Budget vs actual comparisons
   - Expense categorization insights
   - Merchant analysis
   - Spending patterns and forecasting

4. **Income & Assets** (New)
   - Income tracking and categorization
   - Asset portfolio overview
   - Investment account integration
   - Property and asset valuation
   - Income trend analysis
   - Asset allocation insights

5. **Settings** (Preserved)
   - Account preferences
   - Feature toggles
   - Bank connection management
   - Category management
   - Data export/import options

#### **Supporting Features**
- **Vault** (Accessible from settings or as utility)
  - Document storage for financial records
  - Receipt management
  - Tax document organization

### 🔄 **Deactivated Features (Toggle Off)**
- **Inbox** - Email services and invoice matching
- **Payment System** - Polar payment processing
- **Tracker** - Time tracking functionality
- **Invoices** - Invoice creation and management
- **Apps** - Third-party integrations
- **Customers** - Customer management system

### 🚀 **Future Custom Features (To Be Added)**
- Personal finance planning tools
- Investment tracking integration
- Budget management system
- Financial goal setting and tracking
- Canadian tax preparation assistance
- Immigration expense tracking (PR process)

## Repository & Deployment Strategy

### **Repository Setup: Independent Repository (Option A)**
This project will be maintained as a completely separate repository from life-LLM for the following reasons:
- Clean separation of concerns (personal life management vs. web application)
- Easier deployment pipeline (hosting services expect repo root)
- Better collaboration capabilities
- Cleaner CI/CD and version control
- No confusion between personal documents and application code

### **Deployment Architecture**
The application uses a multi-service deployment model where code is automatically deployed from GitHub:

#### **Code Flow:**
1. **GitHub Repository** → Contains all source code
2. **Vercel (Frontend)** → Automatically builds and deploys dashboard on git push
3. **Fly.io (Backend)** → Automatically builds Docker container and deploys API
4. **Supabase (Database)** → Managed PostgreSQL with manual migration runs

#### **Key Benefits:**
- **Push to deploy**: `git push` triggers automatic builds and deployments
- **Preview deployments**: Each pull request gets a preview URL
- **Rollback capability**: Easy to revert to previous versions
- **Environment separation**: Different branches can deploy to different environments

## Development Phases

### **Phase 0: Repository Setup & Initial Deployment (Week 1)**

#### **Repository Creation** ✅ COMPLETED
- [x] Fork `midday-ai/midday` on GitHub
- [x] Rename repository to `finance-hub-webapp`
- [x] Set up repository as independent project (not in life-LLM)
- [x] Configure repository settings and access

#### **Service Account Setup** ✅ COMPLETED
- [x] Set up Supabase project (database, auth, storage)
- [x] Set up Vercel account for frontend hosting
- [x] Set up Fly.io account for backend API
- [x] Set up Plaid developer account (sandbox)
- [x] Collect all API keys and credentials

#### **Deploy Original Midday First (Deploy-First Approach)** ✅ COMPLETED
- [x] **COMPLETED**: Configure environment variables in forked repository
  - Environment files use `.env-example` and `.env-template` (not `.env.example`)
  - Copy: `apps/dashboard/.env-example` → `apps/dashboard/.env.local`
  - Copy: `apps/api/.env-template` → `apps/api/.env.local`
  - Fill in Supabase, Plaid, and essential configuration variables
- [x] Set up Supabase database schema with pgvector extension
- [x] Build and deploy API to Fly.io successfully
  - Created custom Dockerfile for monorepo deployment
  - API deployed at: https://finance-hub-api.fly.dev
  - Environment variables configured in production
- [x] **COMPLETED**: Connect GitHub repo to Vercel (dashboard deployment)
  - Dashboard deployed at: https://finance-hub-webapp-dashboard.vercel.app
  - Resolved NOVU_SECRET_KEY build failures by temporarily disabling notifications page
  - Fixed turbo.json environment variable configuration
  - Automatic deployments from main branch working
- [x] Deploy original Midday code without modifications
  - Successfully deployed with minor modifications for build stability
  - All core pages accessible and functional
- [ ] **IN PROGRESS**: Verify full application works in production
  - Auth magic links need Supabase redirect URL configuration fix
- [ ] Test bank connections with Plaid sandbox
- [ ] Validate all core features function properly

**Rationale**: Deploy the original working code first to validate the entire hosting stack before making any customizations. This provides a known-good baseline and ensures the deployment pipeline works correctly.

#### **Deploy-First Approach Benefits:**
- **Immediate validation**: Confirms the tech stack works with your accounts/services
- **Baseline establishment**: Working production environment before customizations
- **Risk mitigation**: Separates deployment issues from development issues
- **Learning opportunity**: Understand the codebase while it's functioning
- **Rollback safety**: Can always revert to original working state
- **Incremental changes**: Each modification can be tested against working baseline

#### **Environment Variable Configuration Details:**
**Essential variables for initial deployment:**
- **Supabase**: URL, anon key, service key, project ID, JWT secret
- **Plaid**: Client ID, secret key, environment (sandbox)
- **Local development**: API URLs, webhook secrets, encryption keys
- **Optional**: Leave all other service variables empty initially (Resend, GoCardless, Teller, etc.)

**Critical Note**: Repository uses `.env-example` and `.env-template` naming (not `.env.example`)

### **Current Deployment Status (Updated July 12, 2025)**

#### **✅ Successfully Deployed Services**
- **API Backend**: https://finance-hub-api.fly.dev
  - Deployed on Fly.io with custom Docker configuration
  - Full Supabase integration with PostgreSQL database
  - Environment variables configured for production
  - 2 machines running for high availability
- **Frontend Dashboard**: https://finance-hub-webapp-dashboard.vercel.app ✅ **COMPLETED**
  - Successfully deployed on Vercel with automatic GitHub integration
  - Resolved multiple build issues including NOVU_SECRET_KEY configuration
  - All core pages loading and accessible
  - Build pipeline stable with proper environment variable configuration
- **Database**: Supabase PostgreSQL with pgvector extension
  - Complete schema deployed with all tables and relationships
  - Row Level Security (RLS) policies enabled
  - Full-text search capabilities configured
- **Local Development**: Fully functional development environment
  - Dashboard running on localhost:3001
  - API running on localhost:3003
  - All dependencies installed and configured

#### **🚀 Current Priority: Phase 0 Completion** ✅ **COMPLETED**
- [x] **Auth Configuration**: Fix Supabase redirect URLs for magic link authentication
  - Update Site URL to: https://finance-hub-webapp-dashboard.vercel.app
  - Add redirect URLs for auth callbacks
- [x] **Production Testing**: Complete validation of application flow
- [x] **Bank Integration**: Test Plaid connections in production environment

## **Deployment Fixes Analysis - Personal vs Commercial Priorities**

Based on our deployment experience, here are the required fixes categorized by your goals:

### **🔥 HIGH PRIORITY (Personal Finance Use - Immediate Need)**

#### **Critical Authentication & Access Issues**
- [ ] **Vercel Deployment Token**: Fix GitHub Actions deployment credentials
  - Issue: `VERCEL_TOKEN` missing from GitHub secrets
  - Impact: Blocks all deployments and updates
  - Status: **BLOCKING** - Must fix immediately

- [ ] **Team Creation Flow**: Complete initial team setup process
  - Issue: Users need teams to access any features
  - Impact: Cannot use dashboard without team
  - Status: **IN PROGRESS** - Setup page created, needs testing

- [ ] **Core Feature Validation**: Test essential finance management features
  - Transaction management and categorization
  - Account connections via Plaid (sandbox/production)
  - Basic reporting and insights
  - Status: **PENDING** - Requires team setup completion

#### **Essential Service Configuration**
- [ ] **Plaid Production Setup**: Enable real bank connections
  - Issue: Currently using sandbox credentials
  - Impact: Cannot connect real bank accounts
  - Status: **NEEDED** for actual finance tracking

- [ ] **Database Optimization**: Ensure proper performance for personal use
  - Row Level Security policies validation
  - Essential indexes for transaction queries
  - Status: **NEEDED** for responsive experience

### **🔶 MEDIUM PRIORITY (Enhanced Personal Use)**

#### **Feature Completeness**
- [ ] **Feature Toggle System**: Hide commercial features, focus on personal finance
  - Disable: Invoices, Customer management, Team collaboration
  - Keep: Transactions, Categories, Vault, Settings
  - Status: **PLANNED** for Phase 2

- [ ] **Canadian Financial Integration**: Optimize for your location
  - Canadian bank support validation
  - CAD currency as default
  - Canadian tax categories
  - Status: **NICE TO HAVE**

- [ ] **Email Notifications**: Basic transaction alerts
  - Resend API configuration for personal alerts
  - Simple notification system
  - Status: **OPTIONAL** for personal use

### **🔽 LOW PRIORITY (Family & Commercial Use)**

#### **Multi-User Support**
- [ ] **OAuth Provider Expansion**: Add Google, Apple authentication
  - Issue: Currently only GitHub OAuth configured
  - Impact: Family members may prefer other auth methods
  - Status: **FUTURE** - Not needed for personal use

- [ ] **Team Management Features**: Proper multi-user workflows
  - User roles and permissions
  - Team invitation system
  - Shared financial data controls
  - Status: **COMMERCIAL PHASE**

- [ ] **Advanced Integrations**: Full service ecosystem
  - Complete Novu notification system
  - Advanced email templates
  - Third-party app integrations
  - Status: **COMMERCIAL PHASE**

#### **Scalability & Production Readiness**
- [ ] **Performance Optimization**: Handle multiple users/teams
  - Database query optimization
  - Caching strategies
  - API rate limiting
  - Status: **COMMERCIAL PHASE**

- [ ] **Security Hardening**: Enterprise-level security
  - Advanced MFA enforcement
  - Audit logging
  - Security monitoring
  - Status: **COMMERCIAL PHASE**

- [ ] **Backup & Recovery**: Production-grade data protection
  - Automated backups
  - Disaster recovery procedures
  - Data export capabilities
  - Status: **COMMERCIAL PHASE**

### **✅ DEPLOYMENT INFRASTRUCTURE COMPLETED**

**Recent Achievements (July 12, 2025)**:
- [x] **Vercel Deployment Credentials**: Successfully configured `VERCEL_TOKEN`, `VERCEL_ORG_ID`, and `VERCEL_PROJECT_ID_DASHBOARD`
- [x] **GitHub Actions Pipeline**: Fixed all linting and build errors, restored Trigger.dev background jobs deployment
- [x] **Next.js Layout Issues**: Resolved setup page routing and structure
- [x] **Authentication Middleware**: Added `/setup` route bypass for team creation
- [x] **Production URLs**: Configured correct API endpoints and environment variables
- [x] **CORS Configuration**: Fixed API accessibility from frontend
- [x] **Security Linting**: Resolved XSS and code quality issues
- [x] **Background Jobs Re-enabled**: Restored Trigger.dev deployment step in GitHub Actions workflow

**Dashboard Status**: ✅ **SUCCESSFULLY DEPLOYED** at https://finance-hub-webapp-dashboard.vercel.app

---

### **🎯 CURRENT PRIORITY: Background Jobs Setup**

**Phase 0 is essentially complete** - now focusing on automated transaction syncing:

#### **🔄 Trigger.dev Setup** ✅ **COMPLETED**
- [x] **Create Trigger.dev Account**: Sign up and create project
- [x] **Configure Environment Variables**: Add `TRIGGER_PROJECT_ID`, `TRIGGER_SECRET_KEY`, `TRIGGER_ACCESS_TOKEN`
- [ ] **Deploy Background Jobs**: Enable automated bank syncing (TESTING)
- [ ] **Test Automated Sync**: Verify transactions sync automatically

#### **📱 Next: Personal Finance Hub Activation**
1. ✅ Create initial team via setup page
2. ✅ Connect bank accounts via Plaid
3. ✅ Test transaction syncing (manual + automated)
4. ✅ Validate core finance management features

---

## **Next Steps Priority Order**

### **Week 1: Complete Personal Finance Setup**
1. ✅ Setup Trigger.dev for automated syncing (IN PROGRESS)
2. ✅ Create team and access dashboard
3. ✅ Connect Canadian bank accounts via Plaid
4. ✅ Test transaction categorization and management
5. ✅ Validate reporting and insights

### **Week 2-3: Optimize for Personal Use**
1. ✅ Feature toggle system (hide commercial features)
2. ✅ Canadian financial optimizations
3. ✅ Performance tuning for single-user usage

### **Month 2-3: Family Access (When Ready)**
1. ✅ Multi-auth providers (Google, Apple)
2. ✅ Team management workflows
3. ✅ User permissions and sharing

### **Month 6+: Commercial Readiness (Future)**
1. ✅ Advanced integrations and notifications
2. ✅ Scalability and security hardening
3. ✅ Production-grade backup and recovery

---

### **Phase 1: Local Development Setup (Week 2)** ✅ COMPLETED

#### **Local Environment** ✅ COMPLETED
- [x] Clone your forked repository locally
- [x] Install dependencies (Bun, Node.js, PostgreSQL)
- [x] Configure local development environment variables
- [x] Set up local database with sample data
- [x] Verify all apps run locally (dashboard, API, engine)
- [x] Test local development workflow

#### **Development Workflow Setup** ✅ COMPLETED
- [x] Create development branch structure
- [x] Set up feature branch workflow
- [x] Configure CI/CD pipeline for testing
- [x] Set up environment for safe experimentation

### **Phase 2: Feature Toggle Implementation (Weeks 3-4)**

#### **Week 3: Settings Infrastructure**
- [ ] Create feature toggle system in settings
- [ ] Design settings UI for feature management
- [ ] Implement backend logic for feature flags
- [ ] Create database migrations for feature toggles
- [ ] Add feature toggle middleware for routes

#### **Week 4: Menu & Navigation Updates**
- [ ] Modify main navigation to hide toggled features
- [ ] Update routing to respect feature toggles
- [ ] Implement conditional rendering throughout app
- [ ] Add admin panel for feature management
- [ ] Test feature toggle functionality

### **Phase 3: Transaction Management Enhancement (Weeks 5-8)**

#### **Week 5-6: Transaction Core Features**
- [ ] Enhance transaction categorization system
- [ ] Improve transaction search and filtering
- [ ] Add custom transaction tags and labels
- [ ] Implement transaction bulk operations
- [ ] Add transaction notes and annotations

#### **Week 7-8: Advanced Transaction Features**
- [ ] Create transaction templates for recurring items
- [ ] Add transaction splitting functionality
- [ ] Implement transaction reconciliation tools
- [ ] Add transaction attachment management
- [ ] Create transaction export enhancements

### **Phase 4: New Page Development (Weeks 9-12)**

#### **Week 9-10: Spending Page Development**
- [ ] Create Spending page layout and navigation
- [ ] Implement spending analytics by category
- [ ] Add monthly/yearly spending trend charts
- [ ] Build budget vs actual comparison features
- [ ] Add expense categorization insights
- [ ] Implement merchant analysis functionality
- [ ] Create spending patterns and forecasting

#### **Week 11-12: Income & Assets Page Development**
- [ ] Create Income & Assets page layout
- [ ] Implement income tracking and categorization
- [ ] Add asset portfolio overview functionality
- [ ] Build investment account integration framework
- [ ] Add property and asset valuation features
- [ ] Implement income trend analysis
- [ ] Create asset allocation insights

### **Phase 5: Dashboard & Integration (Weeks 13-16)**

#### **Week 13-14: Overview Dashboard Enhancement**
- [ ] Customize overview dashboard for personal use
- [ ] Add personal finance metrics and KPIs
- [ ] Create Canadian-specific financial insights
- [ ] Integrate data from Spending and Income & Assets pages
- [ ] Add net worth tracking functionality

#### **Week 15-16: Integration Setup**
- [ ] Set up Canadian bank connections via Plaid
- [ ] Configure all personal bank accounts
- [ ] Set up automatic transaction categorization
- [ ] Create personal transaction categories
- [ ] Test end-to-end transaction flow
- [ ] Validate all new pages with real data

### **Phase 6: Security & Optimization (Weeks 17-20)**

#### **Week 17-18: Security Hardening**
- [ ] Implement security best practices
- [ ] Add rate limiting and API protection
- [ ] Set up SSL/TLS certificates
- [ ] Configure secure headers and CSP
- [ ] Add input validation and sanitization

#### **Week 19-20: Performance & Monitoring**
- [ ] Optimize database queries and indexing
- [ ] Set up monitoring and alerting
- [ ] Implement error tracking and logging
- [ ] Add performance monitoring
- [ ] Create backup and recovery procedures

## Technical Implementation Details

### **Feature Toggle Architecture**
```typescript
// Feature flags stored in database
interface FeatureFlags {
  userId: string;
  inbox: boolean;
  tracker: boolean;
  invoices: boolean;
  apps: boolean;
  customers: boolean;
  payments: boolean;
}

// Middleware for route protection
const requireFeature = (feature: keyof FeatureFlags) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!user.features[feature]) {
      return res.status(404).json({ error: 'Feature not available' });
    }
    next();
  };
};
```

### **Database Schema Updates**
- Add `feature_flags` table linked to users
- Create settings table for personal preferences
- Add custom transaction categories table
- Implement audit logging for configuration changes

### **Environment Configuration**
```bash
# Production Environment Variables
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
PLAID_CLIENT_ID=your-plaid-client-id
PLAID_SECRET=your-plaid-secret
PLAID_ENV=production
DATABASE_URL=your-supabase-db-url
```

## Cost Estimation

### **Personal Use - First Year (Revised)**

#### **Monthly Operating Costs**
- **Supabase**: $0 (Free tier sufficient for personal use)
  - 500MB database storage
  - 5GB bandwidth 
  - 50MB file storage
  - Up to 50,000 monthly active users
- **Vercel**: $0 (Hobby plan for personal projects)
  - Unlimited deployments
  - 100GB bandwidth
  - Serverless functions included
- **Fly.io**: $0-5 (Free tier likely sufficient)
  - Shared CPU with 256MB RAM
  - 3GB storage
  - 160GB outbound data transfer
- **Plaid**: $0 (Development/Sandbox environment)
  - Free for development and testing
  - Only pay when processing real transactions in production
  - For personal use: ~$10-20/month once live (based on transaction volume)
- **Domain**: $12/year (~$1/month)
- **Email (if needed)**: $0 (Resend free tier: 3,000 emails/month)

#### **Total Monthly Cost: $0-6 for first year**

#### **Cost Progression Timeline**
- **Months 1-3**: $0-1/month (development phase)
- **Months 4-6**: $1-6/month (testing with real data)
- **Months 7-12**: $6-30/month (full personal use)

#### **When You'd Need Paid Tiers**
- **Supabase Pro ($25/month)**: Only if you exceed 500MB database or need advanced features
- **Vercel Pro ($20/month)**: Only if you exceed 100GB bandwidth or need team features
- **Plaid Production**: Only when you connect real bank accounts vs. sandbox

### **Commercial Scale Costs (Future Reference)**
- **Supabase Pro**: $25/month (database, auth, storage)
- **Vercel Pro**: $20/month (frontend hosting)
- **Fly.io**: $5-10/month (API hosting)
- **Plaid**: $50-100/month (depends on transaction volume)
- **Domain & SSL**: $15/year
- **Total**: ~$100-155/month

### **One-time Setup Costs**
- Development time: ~80-120 hours
- Domain registration: $15/year
- SSL certificates: Included with hosting

## Success Metrics

### **Technical Metrics**
- Application uptime: >99.5%
- Page load times: <2 seconds
- Database query performance: <200ms average
- API response times: <500ms
- Zero security vulnerabilities

### **Functional Metrics**
- All bank accounts connected successfully
- Transaction categorization accuracy: >95%
- Daily transaction sync reliability
- Export functionality working correctly
- Feature toggles functioning properly

## Risk Mitigation

### **Technical Risks**
- **Database Migration Issues**: Comprehensive backup strategy
- **API Rate Limits**: Implement proper caching and retry logic
- **Security Vulnerabilities**: Regular security audits and updates
- **Performance Issues**: Load testing and optimization

### **Business Risks**
- **Service Provider Changes**: Maintain flexibility in service choices
- **Cost Overruns**: Monitor usage and implement alerts
- **Data Privacy**: Ensure compliance with Canadian privacy laws
- **Vendor Lock-in**: Maintain data export capabilities

## Future Roadmap (Post-Launch)

### **Phase 7: Advanced Personal Finance Features**
- Investment portfolio tracking
- Canadian tax preparation tools
- Immigration expense categorization
- Financial goal setting and tracking
- Advanced budgeting and forecasting

### **Phase 8: Intelligence & Automation**
- AI-powered transaction categorization
- Spending pattern analysis
- Automated financial insights
- Smart financial recommendations
- Integration with Canadian financial institutions

### **Phase 9: Mobile & Desktop Apps**
- React Native mobile app
- Enhanced Tauri desktop application
- Offline capability
- Real-time notifications
- Cross-platform synchronization

## Maintenance & Support

### **Regular Maintenance Tasks**
- Weekly: Monitor application health and performance
- Monthly: Review and update dependencies
- Quarterly: Security audit and penetration testing
- Annually: Full system backup and disaster recovery testing

### **Support Structure**
- Documentation: Comprehensive setup and user guides
- Monitoring: 24/7 uptime monitoring with alerts
- Backups: Daily automated backups with 30-day retention
- Updates: Monthly security patches and feature updates

## Conclusion

This roadmap provides a structured approach to developing a personal finance hub based on the Midday architecture. The phased approach ensures steady progress while maintaining code quality and security standards. The feature toggle system preserves future expansion possibilities while focusing on core personal finance management needs.

The project balances immediate personal finance needs with long-term flexibility, ensuring the webapp can evolve from a personal tool to a commercial product if needed in the future.
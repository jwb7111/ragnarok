# SaaS Starter Kit

## Metadata

| Field | Value |
|-------|-------|
| **Complexity** | Advanced |
| **Estimated Time** | 2 hours |
| **Agents Required** | implementer:frontend, implementer:backend, implementer:database, tester, reviewer, deployer, compliance |
| **Prerequisites** | Node.js 18+, npm, Stripe account (test mode) |

## Executive Summary

Build a complete SaaS starter with authentication, team management, subscription billing, and a dashboard. This serves as the foundation for any B2B SaaS application.

## User Stories

1. As a user, I want to sign up with email or Google so that I can access the product.
2. As a user, I want to create a team and invite members so that we can collaborate.
3. As an admin, I want to manage team member roles so that I can control access.
4. As a team admin, I want to subscribe to a paid plan so that I can unlock features.
5. As a user, I want to see my usage on a dashboard so that I can track activity.

## Functional Requirements

### Feature 1: Authentication

**Priority:** P0 (Must Have)

- [ ] Email/password registration and login
- [ ] Google OAuth login
- [ ] Email verification
- [ ] Password reset flow
- [ ] Session management with JWT refresh tokens
- [ ] Remember me functionality

### Feature 2: Team Management

**Priority:** P0

- [ ] Create new team
- [ ] Invite team members by email
- [ ] Accept/decline invitations
- [ ] Role management: Owner, Admin, Member
- [ ] Remove team members
- [ ] Transfer ownership

### Feature 3: Subscription Billing

**Priority:** P0

- [ ] Stripe integration for payments
- [ ] Multiple pricing tiers (Free, Pro, Enterprise)
- [ ] Monthly and annual billing options
- [ ] Upgrade/downgrade plans
- [ ] Cancel subscription
- [ ] Invoice history
- [ ] Webhook handling for payment events

### Feature 4: Dashboard

**Priority:** P1 (Should Have)

- [ ] Usage metrics display
- [ ] Team activity feed
- [ ] Quick actions
- [ ] Billing status overview

### Feature 5: Settings

**Priority:** P1

- [ ] Profile settings (name, avatar)
- [ ] Team settings (name, logo)
- [ ] Notification preferences
- [ ] Security settings (change password, 2FA prep)
- [ ] Billing settings (payment method, invoices)

## Non-Functional Requirements

### Performance
- API response time: < 200ms p99
- Dashboard load time: < 2s
- Support 100 concurrent users

### Security
- Authentication: JWT with refresh tokens
- Authorization: Role-based access control
- Payment data: Never stored, Stripe handles
- HTTPS everywhere
- CSRF protection
- Rate limiting on auth endpoints

### Reliability
- Uptime target: 99.9%
- Database backups: Daily
- Graceful degradation for non-critical features

## Tech Stack (Suggested)

| Layer | Technology | Rationale |
|-------|------------|-----------|
| Frontend | Next.js 14 | App Router, RSC, built-in API routes |
| Styling | Tailwind + shadcn/ui | Production-ready components |
| Backend | Next.js API routes | Unified deployment |
| Database | PostgreSQL | ACID compliance, relations |
| ORM | Prisma | Type-safe, migrations |
| Auth | NextAuth.js | Multiple providers, sessions |
| Payments | Stripe | Industry standard |
| Hosting | Vercel | Seamless Next.js deployment |

## Data Model

### Entity: User

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | Yes | Primary key |
| email | String | Yes | Unique |
| name | String | No | Display name |
| image | String | No | Avatar URL |
| emailVerified | DateTime | No | Verification timestamp |
| createdAt | DateTime | Yes | |

### Entity: Team

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | Yes | Primary key |
| name | String | Yes | Team name |
| slug | String | Yes | URL-safe identifier |
| stripeCustomerId | String | No | Stripe reference |
| subscriptionStatus | Enum | Yes | free, active, past_due, canceled |
| plan | Enum | Yes | free, pro, enterprise |
| createdAt | DateTime | Yes | |

### Entity: TeamMember

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | Yes | Primary key |
| teamId | UUID | Yes | Foreign key |
| userId | UUID | Yes | Foreign key |
| role | Enum | Yes | owner, admin, member |
| joinedAt | DateTime | Yes | |

### Entity: Invitation

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | Yes | Primary key |
| teamId | UUID | Yes | Foreign key |
| email | String | Yes | Invitee email |
| role | Enum | Yes | Invited role |
| token | String | Yes | Unique invite token |
| expiresAt | DateTime | Yes | Token expiration |

## API Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/register | Create account |
| POST | /api/auth/login | Get session |
| POST | /api/auth/logout | End session |
| POST | /api/auth/forgot-password | Send reset email |
| POST | /api/auth/reset-password | Set new password |

### Teams
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/teams | List user's teams |
| POST | /api/teams | Create team |
| GET | /api/teams/:slug | Get team |
| PATCH | /api/teams/:slug | Update team |
| DELETE | /api/teams/:slug | Delete team |
| GET | /api/teams/:slug/members | List members |
| POST | /api/teams/:slug/invitations | Send invite |
| DELETE | /api/teams/:slug/members/:id | Remove member |

### Billing
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/billing/checkout | Create Stripe session |
| POST | /api/billing/portal | Access billing portal |
| POST | /api/webhooks/stripe | Handle Stripe events |

## UI Wireframes

### Screen 1: Dashboard
```
┌─────────────────────────────────────────────────┐
│  [Logo] Team Name ▼        [?] [🔔] [Avatar ▼] │
├──────────┬──────────────────────────────────────┤
│          │                                      │
│ Dashboard│  Welcome back, User!                 │
│ Team     │  ┌─────────┐ ┌─────────┐ ┌─────────┐│
│ Settings │  │ Users   │ │ API Calls│ │ Storage ││
│ Billing  │  │   12    │ │  4,521  │ │  2.1 GB ││
│          │  └─────────┘ └─────────┘ └─────────┘│
│          │                                      │
│          │  Recent Activity                     │
│          │  • User joined team                  │
│          │  • Plan upgraded to Pro              │
│          │  • API key created                   │
│          │                                      │
└──────────┴──────────────────────────────────────┘
```

### Screen 2: Team Members
```
┌─────────────────────────────────────────────────┐
│  Team Members                [+ Invite Member] │
├─────────────────────────────────────────────────┤
│  👤 Alice Owner (you)    alice@example.com     │
│  👤 Bob Admin            bob@example.com  [⋮]  │
│  👤 Carol Member         carol@example.com [⋮] │
├─────────────────────────────────────────────────┤
│  Pending Invitations                            │
│  📧 dave@example.com     Admin    [Resend][×]  │
└─────────────────────────────────────────────────┘
```

## Success Criteria

### Definition of Done
- [ ] All P0 requirements implemented
- [ ] Tests passing with > 80% coverage
- [ ] No critical/high security vulnerabilities
- [ ] Lighthouse score > 80
- [ ] Stripe test payments working
- [ ] Deployed to production URL

### Acceptance Tests
1. User can sign up, verify email, and log in
2. User can create team and invite members
3. Team admin can subscribe to paid plan
4. Subscription downgrades work correctly
5. Canceled subscriptions handle grace period

## Out of Scope

- Custom domain per team
- SSO/SAML authentication
- Usage-based billing
- Admin super-user panel
- Mobile app

## Compliance Notes

Requires `config/jurisdiction.yaml` to be configured before compliance agent can:
- Generate Terms of Service
- Generate Privacy Policy
- Configure cookie consent

## Notes

This is a demanding project that tests:
- Complex authentication flows
- Multi-tenant data isolation
- Third-party payment integration
- Webhook handling
- Role-based access control

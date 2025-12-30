# Invoice Tracker PRD

## Metadata
- **Complexity:** Intermediate
- **Estimated Time:** 2-4 hours
- **Purpose:** Proof of Concept for Loki Mode capabilities
- **Agents Required:** eng-frontend, eng-backend, eng-database, ops-devops, biz-finance

---

## Executive Summary

A simple invoice tracking SaaS that allows freelancers to create, send, and track invoices. This POC demonstrates Loki Mode's ability to build a complete full-stack application with authentication, database, and payment integration.

---

## User Stories

### Authentication
- As a user, I want to sign up with email/password so that I can access the app
- As a user, I want to log in securely so that my data is protected
- As a user, I want to log out so that I can secure my session

### Invoice Management
- As a user, I want to create an invoice with client details, line items, and totals
- As a user, I want to view a list of all my invoices with status indicators
- As a user, I want to edit a draft invoice before sending
- As a user, I want to delete an invoice I no longer need
- As a user, I want to mark an invoice as paid when I receive payment

### Client Management
- As a user, I want to save client information for reuse
- As a user, I want to select from saved clients when creating invoices

### Dashboard
- As a user, I want to see summary metrics (total outstanding, paid this month, overdue)

---

## Functional Requirements

### FR-1: Authentication System
- [ ] FR-1.1: Email/password registration with validation
- [ ] FR-1.2: Email/password login with JWT tokens
- [ ] FR-1.3: Protected routes requiring authentication
- [ ] FR-1.4: Logout functionality (clear tokens)
- [ ] FR-1.5: Password must be minimum 8 characters

### FR-2: Invoice CRUD
- [ ] FR-2.1: Create invoice with: client, date, due date, line items, notes
- [ ] FR-2.2: Line items have: description, quantity, unit price, total
- [ ] FR-2.3: Invoice totals calculated automatically (subtotal, tax, total)
- [ ] FR-2.4: Invoice status: draft, sent, paid, overdue
- [ ] FR-2.5: Edit invoice (only drafts)
- [ ] FR-2.6: Delete invoice (soft delete)
- [ ] FR-2.7: View single invoice with all details
- [ ] FR-2.8: List all invoices with filtering by status

### FR-3: Client Management
- [ ] FR-3.1: Create client with: name, email, address, phone
- [ ] FR-3.2: List all clients
- [ ] FR-3.3: Select client when creating invoice (autofill details)
- [ ] FR-3.4: Edit client information
- [ ] FR-3.5: Delete client (only if no invoices)

### FR-4: Dashboard
- [ ] FR-4.1: Display total outstanding amount
- [ ] FR-4.2: Display total paid this month
- [ ] FR-4.3: Display count of overdue invoices
- [ ] FR-4.4: List 5 most recent invoices

---

## Non-Functional Requirements

### Performance
- Page load time: < 2 seconds
- API response time: < 500ms
- Database queries: < 100ms

### Security
- Passwords hashed with bcrypt (cost factor 10)
- JWT tokens expire in 24 hours
- All API endpoints require authentication (except auth routes)
- SQL injection prevention via parameterized queries
- XSS prevention via output encoding

### Accessibility
- WCAG 2.1 AA compliance
- Keyboard navigation support
- Screen reader compatible

### Code Quality
- TypeScript strict mode
- ESLint with recommended rules
- Prettier formatting
- Test coverage > 70%

---

## Tech Stack

### Frontend
- **Framework:** Next.js 14 (App Router)
- **Styling:** Tailwind CSS
- **State:** React hooks (no external state management)
- **Forms:** React Hook Form with Zod validation

### Backend
- **Runtime:** Node.js 20
- **Framework:** Next.js API Routes
- **ORM:** Prisma
- **Validation:** Zod

### Database
- **Development:** SQLite (for simplicity)
- **Production:** PostgreSQL (Railway/Supabase)

### Authentication
- **Method:** JWT stored in httpOnly cookies
- **Library:** jose (JWT handling)

### Deployment
- **Platform:** Vercel (frontend + API)
- **Database:** Railway PostgreSQL or Supabase

---

## Database Schema

```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  password  String
  name      String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  clients   Client[]
  invoices  Invoice[]
}

model Client {
  id        String   @id @default(cuid())
  name      String
  email     String
  address   String?
  phone     String?
  userId    String
  user      User     @relation(fields: [userId], references: [id])
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  invoices  Invoice[]
}

model Invoice {
  id          String        @id @default(cuid())
  number      String
  status      InvoiceStatus @default(DRAFT)
  issueDate   DateTime      @default(now())
  dueDate     DateTime
  notes       String?
  subtotal    Decimal       @db.Decimal(10, 2)
  taxRate     Decimal       @db.Decimal(5, 2) @default(0)
  taxAmount   Decimal       @db.Decimal(10, 2) @default(0)
  total       Decimal       @db.Decimal(10, 2)

  userId      String
  user        User          @relation(fields: [userId], references: [id])
  clientId    String
  client      Client        @relation(fields: [clientId], references: [id])

  lineItems   LineItem[]

  createdAt   DateTime      @default(now())
  updatedAt   DateTime      @updatedAt
  deletedAt   DateTime?

  @@unique([userId, number])
}

model LineItem {
  id          String  @id @default(cuid())
  description String
  quantity    Decimal @db.Decimal(10, 2)
  unitPrice   Decimal @db.Decimal(10, 2)
  total       Decimal @db.Decimal(10, 2)

  invoiceId   String
  invoice     Invoice @relation(fields: [invoiceId], references: [id], onDelete: Cascade)
}

enum InvoiceStatus {
  DRAFT
  SENT
  PAID
  OVERDUE
}
```

---

## API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/register | Create new user |
| POST | /api/auth/login | Login, return JWT |
| POST | /api/auth/logout | Clear auth cookie |
| GET | /api/auth/me | Get current user |

### Clients
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/clients | List all clients |
| POST | /api/clients | Create client |
| GET | /api/clients/:id | Get client |
| PUT | /api/clients/:id | Update client |
| DELETE | /api/clients/:id | Delete client |

### Invoices
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/invoices | List invoices (with filters) |
| POST | /api/invoices | Create invoice |
| GET | /api/invoices/:id | Get invoice |
| PUT | /api/invoices/:id | Update invoice |
| DELETE | /api/invoices/:id | Soft delete invoice |
| POST | /api/invoices/:id/send | Mark as sent |
| POST | /api/invoices/:id/paid | Mark as paid |

### Dashboard
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/dashboard | Get dashboard metrics |

---

## UI Pages

| Route | Page | Description |
|-------|------|-------------|
| / | Landing | Marketing page (if not logged in) |
| /login | Login | Login form |
| /register | Register | Registration form |
| /dashboard | Dashboard | Metrics + recent invoices |
| /invoices | Invoice List | All invoices with filters |
| /invoices/new | Create Invoice | Invoice creation form |
| /invoices/:id | Invoice Detail | View/edit single invoice |
| /clients | Client List | All clients |
| /clients/new | Create Client | Client creation form |

---

## Out of Scope

The following are explicitly NOT included in this POC:
- Email sending (invoice notifications)
- PDF generation
- Payment processing (Stripe integration)
- Multi-currency support
- Recurring invoices
- Team/organization features
- Invoice templates
- File attachments
- Public invoice links (share with client)

---

## Success Criteria

### Must Pass
- [ ] User can register and login
- [ ] User can create, view, edit, delete invoices
- [ ] User can manage clients
- [ ] Dashboard shows correct metrics
- [ ] All tests pass
- [ ] Build succeeds without errors
- [ ] Deploys to Vercel successfully

### Quality Gates
- [ ] TypeScript compiles with no errors
- [ ] ESLint passes with no errors
- [ ] Test coverage > 70%
- [ ] Lighthouse performance > 80
- [ ] No critical security vulnerabilities

---

## Verification Commands

```bash
# Build verification
npm run build

# Test verification
npm test

# Lint verification
npm run lint

# Type verification
npx tsc --noEmit

# Coverage verification
npm run test:coverage
```

---

## Notes for Loki Mode

1. **Start with database schema** - Run prisma generate after schema creation
2. **Build API routes before UI** - Easier to test in isolation
3. **Use seed data** - Create test user and sample data
4. **Commit frequently** - After each major feature
5. **Run verification after each task** - Don't accumulate errors

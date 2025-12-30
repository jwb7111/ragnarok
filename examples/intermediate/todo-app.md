# Todo Application

## Metadata

| Field | Value |
|-------|-------|
| **Complexity** | Intermediate |
| **Estimated Time** | 30 minutes |
| **Agents Required** | implementer:frontend, implementer:backend, implementer:database, tester, reviewer |
| **Prerequisites** | Node.js 18+, npm, Docker (optional for database) |

## Executive Summary

Build a full-stack todo application with user authentication, persistent storage, and a clean UI. This is the classic "CRUD app" that tests all layers of the stack.

## User Stories

1. As a user, I want to sign up for an account so that my todos are saved.
2. As a user, I want to create todos so that I can track tasks.
3. As a user, I want to mark todos complete so that I can see my progress.
4. As a user, I want to delete todos so that I can remove finished items.
5. As a user, I want to filter todos by status so that I can focus on what's left.

## Functional Requirements

### Feature 1: Authentication

**Priority:** P0 (Must Have)

- [ ] User registration with email/password
- [ ] User login with email/password
- [ ] User logout
- [ ] Protected routes (redirect to login if not authenticated)
- [ ] Password hashing (bcrypt)

### Feature 2: Todo CRUD

**Priority:** P0

- [ ] Create new todo with title
- [ ] Read all todos for current user
- [ ] Update todo title
- [ ] Toggle todo complete/incomplete
- [ ] Delete todo
- [ ] Todos are private to each user

### Feature 3: Filtering

**Priority:** P1 (Should Have)

- [ ] Filter: All todos
- [ ] Filter: Active (incomplete) only
- [ ] Filter: Completed only
- [ ] Count of remaining items

### Feature 4: UI Polish

**Priority:** P2 (Nice to Have)

- [ ] Enter key submits new todo
- [ ] Double-click to edit todo
- [ ] Clear completed button
- [ ] Animations on add/remove

## Non-Functional Requirements

### Performance
- API response time: < 100ms p99
- Page load time: < 1.5s

### Security
- Authentication: JWT tokens
- Authorization: User can only access own todos
- Passwords: bcrypt hashed

### Reliability
- Data persisted to database
- Handle network errors gracefully

## Tech Stack (Suggested)

| Layer | Technology | Rationale |
|-------|------------|-----------|
| Frontend | React + TypeScript | Component-based, type-safe |
| Styling | Tailwind CSS | Rapid styling |
| Backend | Express.js | Simple, well-documented |
| Database | SQLite | Zero config, good for demo |
| Auth | JWT | Stateless, simple |

## Data Model

### Entity: User

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | Yes | Primary key |
| email | String | Yes | Unique, for login |
| passwordHash | String | Yes | bcrypt hash |
| createdAt | DateTime | Yes | Account creation time |

### Entity: Todo

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | Yes | Primary key |
| userId | UUID | Yes | Foreign key to User |
| title | String | Yes | Todo text |
| completed | Boolean | Yes | Default false |
| createdAt | DateTime | Yes | Creation time |

## API Endpoints

### Auth

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/register | Create new user |
| POST | /api/auth/login | Get JWT token |
| POST | /api/auth/logout | Invalidate token (client-side) |

### Todos

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/todos | List user's todos |
| POST | /api/todos | Create new todo |
| PATCH | /api/todos/:id | Update todo |
| DELETE | /api/todos/:id | Delete todo |

## UI Wireframes

### Screen 1: Login/Register
```
┌─────────────────────────────┐
│         Todo App            │
├─────────────────────────────┤
│                             │
│  [Email input]              │
│  [Password input]           │
│                             │
│  [Login] [Register]         │
│                             │
└─────────────────────────────┘
```

### Screen 2: Todo List
```
┌─────────────────────────────┐
│  Todo App    [user] [Logout]│
├─────────────────────────────┤
│  [What needs to be done?]   │
├─────────────────────────────┤
│  ○ Buy groceries            │
│  ● Walk the dog    ✓        │
│  ○ Write code               │
├─────────────────────────────┤
│  3 items left               │
│  [All] [Active] [Completed] │
│  [Clear completed]          │
└─────────────────────────────┘
```

## Success Criteria

### Definition of Done
- [ ] All P0 requirements implemented
- [ ] Tests passing with > 70% coverage
- [ ] No critical security vulnerabilities
- [ ] API documented

### Acceptance Tests
1. User can register, logout, and login again
2. User can create, complete, and delete todos
3. Todos persist across browser refresh
4. User A cannot see User B's todos

## Out of Scope

- Social login (Google, GitHub)
- Todo priorities or due dates
- Shared/collaborative todos
- Mobile app

## Notes

This is a good intermediate project that tests:
- Full-stack integration
- Authentication flow
- Database operations
- State management

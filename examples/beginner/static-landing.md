# Static Landing Page

## Metadata

| Field | Value |
|-------|-------|
| **Complexity** | Beginner |
| **Estimated Time** | 10 minutes |
| **Agents Required** | implementer:frontend, deployer |
| **Prerequisites** | Node.js 18+, npm |

## Executive Summary

Build a simple, responsive landing page for a product or service. This is the simplest possible Loki Mode project - perfect for testing your setup.

## User Stories

1. As a visitor, I want to see what the product does so that I can decide if it's useful.
2. As a visitor, I want to sign up for updates so that I can be notified when it launches.

## Functional Requirements

### Feature 1: Hero Section

**Priority:** P0 (Must Have)

- [ ] Display product name and tagline
- [ ] Include a call-to-action button
- [ ] Show a hero image or illustration

### Feature 2: Features Section

**Priority:** P0

- [ ] Display 3-4 key features with icons
- [ ] Each feature has title and short description

### Feature 3: Email Signup

**Priority:** P1 (Should Have)

- [ ] Email input field with validation
- [ ] Submit button
- [ ] Success/error feedback (can be client-side only for this beginner example)

### Feature 4: Footer

**Priority:** P1

- [ ] Copyright notice
- [ ] Social media links (placeholder hrefs ok)

## Non-Functional Requirements

### Performance
- Page load time: < 2s
- Lighthouse performance score: > 90

### Accessibility
- WCAG Level: AA
- All images have alt text
- Keyboard navigable

## Tech Stack (Suggested)

| Layer | Technology | Rationale |
|-------|------------|-----------|
| Framework | Astro or plain HTML | Static site, no JS needed |
| Styling | Tailwind CSS | Rapid styling |
| Hosting | Vercel | Free, instant deploy |

## UI Wireframes

### Screen 1: Landing Page
```
┌─────────────────────────────────┐
│         [Logo]                  │
├─────────────────────────────────┤
│                                 │
│     Big Bold Headline           │
│     Subheadline text here       │
│                                 │
│     [Get Started Button]        │
│                                 │
├─────────────────────────────────┤
│  Feature 1   Feature 2   Feature 3
│  [icon]      [icon]      [icon] │
│  Title       Title       Title  │
│  Desc        Desc        Desc   │
├─────────────────────────────────┤
│                                 │
│  Sign up for updates            │
│  [email input] [Subscribe]      │
│                                 │
├─────────────────────────────────┤
│  © 2025  |  Twitter  LinkedIn   │
└─────────────────────────────────┘
```

## Success Criteria

### Definition of Done
- [ ] All sections render correctly
- [ ] Responsive on mobile, tablet, desktop
- [ ] Lighthouse score > 90
- [ ] Deployed to public URL

### Acceptance Tests
1. User can view page on mobile device
2. User can enter email and click subscribe

## Out of Scope

- Backend email storage (client-side validation only)
- Analytics
- CMS integration

## Notes

This is a great first project to verify Loki Mode works in your environment before attempting more complex builds.

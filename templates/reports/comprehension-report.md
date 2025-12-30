# Comprehension Report: {PHASE_NAME}

**Generated:** {TIMESTAMP}
**Phase:** {PHASE_NUMBER} - {PHASE_NAME}
**Tasks Completed:** {TASK_COUNT}

---

## 1. What Was Built (Plain English)

### Summary
{2-3_SENTENCE_SUMMARY_OF_WHAT_WAS_ACCOMPLISHED}

### Features Implemented
| Feature | Status | Files Changed |
|---------|--------|---------------|
| {FEATURE_1} | Complete | {FILES} |
| {FEATURE_2} | Complete | {FILES} |
| {FEATURE_3} | Partial | {FILES} |

### Key Components Created
1. **{COMPONENT_1}** - {PURPOSE}
2. **{COMPONENT_2}** - {PURPOSE}
3. **{COMPONENT_3}** - {PURPOSE}

---

## 2. Why These Choices (ADR Links)

| Decision | ADR | Quick Summary |
|----------|-----|---------------|
| {DECISION_1} | [ADR-001](../decisions/ADR-001-*.md) | {SUMMARY} |
| {DECISION_2} | [ADR-002](../decisions/ADR-002-*.md) | {SUMMARY} |

---

## 3. How It Works (Key Flows)

### Flow 1: {FLOW_NAME}
```
{STEP_1} → {STEP_2} → {STEP_3} → {STEP_4}
```

**Detailed Steps:**
1. {STEP_1_DETAIL}
2. {STEP_2_DETAIL}
3. {STEP_3_DETAIL}
4. {STEP_4_DETAIL}

### Flow 2: {FLOW_NAME}
```
{STEP_1} → {STEP_2} → {STEP_3}
```

---

## 4. Where to Find Things (File Guide)

### Directory Structure
```
{PROJECT_ROOT}/
├── src/
│   ├── components/     # {DESCRIPTION}
│   ├── pages/          # {DESCRIPTION}
│   ├── api/            # {DESCRIPTION}
│   ├── lib/            # {DESCRIPTION}
│   └── types/          # {DESCRIPTION}
├── prisma/             # {DESCRIPTION}
├── tests/              # {DESCRIPTION}
└── config/             # {DESCRIPTION}
```

### Key Files
| File | Purpose | When to Modify |
|------|---------|----------------|
| `{FILE_1}` | {PURPOSE} | {WHEN} |
| `{FILE_2}` | {PURPOSE} | {WHEN} |
| `{FILE_3}` | {PURPOSE} | {WHEN} |

---

## 5. Known Limitations (Tech Debt)

### Current Limitations
| ID | Description | Severity | Ticket |
|----|-------------|----------|--------|
| TD-001 | {DESCRIPTION} | Low | TODO in {FILE} |
| TD-002 | {DESCRIPTION} | Medium | TODO in {FILE} |

### Deferred Decisions
* {DECISION_1} - Deferred because {REASON}
* {DECISION_2} - Deferred because {REASON}

---

## 6. Suggested Reading Order (For New Developers)

If you're new to this codebase, read files in this order:

1. **Start here:** `{FILE_1}` - {WHY_START_HERE}
2. **Then:** `{FILE_2}` - {WHAT_YOULL_LEARN}
3. **Then:** `{FILE_3}` - {WHAT_YOULL_LEARN}
4. **Deep dive:** `{FILE_4}` - {WHAT_YOULL_LEARN}
5. **Advanced:** `{FILE_5}` - {WHAT_YOULL_LEARN}

---

## 7. External Dependencies

| Dependency | Version | Purpose | Documentation |
|------------|---------|---------|---------------|
| {DEP_1} | {VERSION} | {PURPOSE} | {URL} |
| {DEP_2} | {VERSION} | {PURPOSE} | {URL} |

---

## 8. Testing Guide

### Running Tests
```bash
# All tests
{COMMAND}

# Specific test file
{COMMAND}

# With coverage
{COMMAND}
```

### Test Structure
| Test Type | Location | Coverage |
|-----------|----------|----------|
| Unit | `tests/unit/` | {PERCENT}% |
| Integration | `tests/integration/` | {PERCENT}% |
| E2E | `tests/e2e/` | {PERCENT}% |

---

## 9. Metrics

### Code Metrics
| Metric | Value |
|--------|-------|
| Total Lines of Code | {LOC} |
| Files Created | {FILE_COUNT} |
| Test Coverage | {COVERAGE}% |
| Build Time | {TIME} |

### Quality Metrics
| Check | Status |
|-------|--------|
| TypeScript | {PASS/FAIL} |
| ESLint | {PASS/FAIL} |
| Tests | {PASS/FAIL} |
| Build | {PASS/FAIL} |

---

## 10. Next Steps

After reading this report, you should be able to:
- [ ] Understand the overall architecture
- [ ] Navigate the codebase efficiently
- [ ] Run and modify tests
- [ ] Make changes to existing features
- [ ] Add new features following established patterns

**Questions?** Check the ADRs or review the `.loki/logs/LOKI-LOG.md` for detailed decision history.

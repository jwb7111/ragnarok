# Invoice Tracker - Loki Mode POC

This is the official Proof of Concept for Loki Mode, demonstrating autonomous multi-agent development of a complete SaaS application.

## Purpose

This POC exists to address the #1 community feedback: **"Show us one successful example."**

## What This Proves

If successful, this POC demonstrates:
- Loki Mode can build a working full-stack application
- The 3-reviewer code review system catches issues
- The verification system ensures code quality
- Human intervention requirements are documented honestly

## How to Run This POC

### Prerequisites
- Node.js 20+
- Claude Code CLI installed
- `--dangerously-skip-permissions` flag available

### Running with Loki Mode

```bash
# Navigate to the POC directory
cd poc/invoice-tracker

# Run Loki Mode with the PRD
claude --dangerously-skip-permissions -p "Loki Mode with PRD at ./PRD.md"
```

### Manual Verification After Build

```bash
# Navigate to generated project
cd generated-app/

# Install dependencies
npm install

# Run all verification checks
npm run build        # Must pass
npm run lint         # Must pass
npm run test         # Must pass
npx tsc --noEmit     # Must pass

# Start development server
npm run dev
```

## Metrics We're Tracking

| Metric | Target | Actual |
|--------|--------|--------|
| Total Build Time | < 4 hours | TBD |
| Human Interventions | < 5 | TBD |
| API Token Cost | < $50 | TBD |
| Test Coverage | > 70% | TBD |
| Build Success | Yes | TBD |
| Lighthouse Score | > 80 | TBD |

## Documentation Generated

After the POC run, the following will be generated:
- `.loki/logs/LOKI-LOG.md` - Complete audit trail
- `.loki/metrics/` - Time and cost metrics
- `.loki/verify/` - All verification logs
- `.loki/reports/` - Comprehension reports

## Honest Results

This section will be updated with honest results:

### What Worked
- TBD

### What Required Intervention
- TBD

### What Failed
- TBD

### Lessons Learned
- TBD

## Contributing

If you run this POC yourself, please open an issue with your results!

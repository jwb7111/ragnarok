# Showcase Examples

This directory contains the official Proof of Concept projects that demonstrate Loki Mode capabilities.

## Invoice Tracker (Primary POC)

**Location:** [`/poc/invoice-tracker/`](../../poc/invoice-tracker/)

The Invoice Tracker is the primary POC for Loki Mode. It demonstrates:

- Full framework integration (all Loki frameworks working together)
- Real-world SaaS functionality (invoicing, payments, authentication)
- Honest documentation of what works and what requires intervention

### Quick Links

- [PRD](../../poc/invoice-tracker/PRD.md) - Full product requirements
- [README](../../poc/invoice-tracker/README.md) - How to run the POC
- [Demo Script](../../poc/invoice-tracker/scripts/demo-workflow.sh) - Interactive framework demo

### Framework Integration

The Invoice Tracker integrates all Loki frameworks:

| Framework | Config File | Purpose |
|-----------|-------------|---------|
| Environment Bootstrap | `scripts/validate-environment.sh` | Pre-flight checks |
| Jurisdiction | `config/jurisdiction.yaml` | Legal compliance |
| Checkpoints | `config/loki.yaml` | Human approval gates |
| Agent Model v3 | `config/loki.yaml` | 12-agent architecture |
| Verification | `scripts/verify-task.sh` | Objective completion |
| Failure Handlers | `config/failure-handlers.yaml` | Error recovery |

### Running the Showcase

```bash
cd poc/invoice-tracker

# Run the framework demo
./scripts/demo-workflow.sh

# Run full Loki Mode
claude --dangerously-skip-permissions -p "Loki Mode with PRD at ./PRD.md"
```

## Contributing Showcase Examples

To add a new showcase:

1. Create a complete implementation (not just a PRD)
2. Include honest metrics (time, interventions, cost)
3. Document what worked and what didn't
4. Submit a PR with the full project

We're especially interested in:
- Different tech stacks (Python, Go, Rust)
- Different deployment targets (AWS, GCP, self-hosted)
- Edge cases that stress-test the system

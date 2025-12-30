# Loki Mode: Capabilities & Limitations

> "For MVP, this is awesome. Ship it!" - Yakut-Crypto-Frog

This document provides an honest assessment of what Loki Mode can and cannot do, helping you decide when to use it and when to choose other approaches.

## What Loki Mode IS

- **An execution accelerator** for well-defined PRDs
- **A scaffolding generator** that creates working code quickly
- **A code review automation** system with 3 specialized reviewers
- **A deployment automation** tool for common platforms
- **Best for MVPs and prototypes** where speed matters more than perfection

## What Loki Mode is NOT

- A replacement for **human product strategy** - you must write the PRD
- A tool for **production-critical systems** without extensive human review
- Capable of **nuanced business decisions** - legal, pricing, marketing need humans
- A way to build apps **without understanding them** - you still need to review the code
- Magic - it will fail sometimes, and you need to be prepared

## Recommended Use Cases

| Use Case | Suitability | Notes |
|----------|-------------|-------|
| MVP/Prototype | ⭐⭐⭐⭐⭐ **Excellent** | Primary use case - speed over perfection |
| Internal Tools | ⭐⭐⭐⭐ **Good** | Lower stakes, faster iteration |
| Side Projects | ⭐⭐⭐⭐⭐ **Excellent** | Perfect for hobby projects |
| Learning/Exploration | ⭐⭐⭐⭐ **Good** | See how code is structured |
| Hackathons | ⭐⭐⭐⭐⭐ **Excellent** | Maximum speed, time-boxed scope |
| Production SaaS | ⭐⭐ **Caution** | Requires extensive human review |
| Regulated Industries | ⭐ **Not Recommended** | HIPAA, PCI, etc. need human oversight |
| Security-Critical | ⭐ **Not Recommended** | Human security review essential |

## Human Oversight Requirements by Phase

| Phase | Human Involvement | Why |
|-------|------------------|-----|
| PRD Writing | **High** | Strategy requires human judgment |
| Architecture | **Medium** | Review ADRs, approve major decisions |
| Implementation | **Low** | Let agents work, review outputs |
| Code Review | **Medium** | Spot-check reviewer findings |
| Testing | **Medium** | Verify edge cases, integration tests |
| Deployment | **Medium** | Approve production deploys |
| Business Ops | **High** | Legal, pricing, marketing need human |

## Known Limitations

### Current Limitations

1. **Context Window Limits**: Agents may lose context on very long tasks
   - *Mitigation*: Task decomposition, phase-based approach

2. **Hallucination Risk**: Despite protocols, errors can occur
   - *Mitigation*: Verification system, code review

3. **Integration Complexity**: Third-party APIs often require debugging
   - *Mitigation*: Failure handlers, retry logic

4. **Cost Unpredictability**: Token usage varies by task complexity
   - *Mitigation*: Monitoring, early stopping on runaway

5. **Legal Disclaimers**: Generated legal docs require attorney review
   - *Mitigation*: Clear warnings, human checkpoint

### What Breaks First (Honest Assessment)

Based on community feedback and testing:

| Failure Type | Frequency | Mitigation |
|--------------|-----------|------------|
| npm/dependency issues | ~30% | Failure handlers, retry logic |
| Context confusion | ~25% | Better task decomposition |
| External API integration | ~20% | Error handling, checkpoints |
| Reviewer disagreements | ~15% | Clear severity thresholds |
| Deployment config | ~10% | Environment validation |

## Expected Outcomes by Complexity

| PRD Complexity | Success Rate | Human Interventions | Est. Cost |
|----------------|--------------|---------------------|-----------|
| Beginner (landing page) | ~90% | 0-1 | < $2 |
| Intermediate (CRUD app) | ~70% | 1-3 | < $10 |
| Advanced (SaaS starter) | ~50% | 3-5 | < $30 |

*These are estimates. Actual results depend on PRD quality, environment, and network conditions.*

## When to Use Loki Mode

### ✅ DO use Loki Mode when:

- You have a **clear, detailed PRD** with specific requirements
- You're building an **MVP or prototype**
- Speed matters more than absolute code quality
- You're willing to **review and understand** the generated code
- You have fallback plans if it fails
- The project is **not** security/compliance critical

### ❌ DON'T use Loki Mode when:

- You don't have clear requirements
- You're building for regulated industries without human oversight
- You need **production-grade** code without review
- You won't review the generated code
- You need custom/unusual technology stacks
- Failure would have serious consequences

## Comparison to Alternatives

| Approach | Speed | Quality | Control | Learning |
|----------|-------|---------|---------|----------|
| Loki Mode | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Manual coding | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| No-code tools | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐ |
| Code generators | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Hire contractor | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

## Honest FAQ

### Q: Can Loki Mode build production-ready code?

**A:** It can build *functional* code, but "production-ready" requires human review for security, performance, and edge cases. Think of it as a very fast first draft.

### Q: How much will it cost?

**A:** Depends on complexity. Beginner projects: < $2. Advanced projects: $20-50. Runaway tasks can cost more if not monitored.

### Q: What if it gets stuck?

**A:** The checkpoint system will pause for human input. Failure handlers will retry common issues. If it truly fails, you'll have partial work to continue manually.

### Q: Is the generated code secure?

**A:** The security reviewer catches obvious issues, but it's NOT a replacement for a professional security audit. Do not use unreviewed code for sensitive data.

### Q: Will it replace developers?

**A:** No. It's a tool that accelerates development, like an IDE or framework. You still need to understand what's being built and review the output.

## Getting Started

If you've read this and still want to use Loki Mode:

1. **Start small** - Try the [beginner examples](/examples/beginner/)
2. **Write a good PRD** - Use the [template](/examples/PRD-TEMPLATE.md)
3. **Monitor actively** - Watch the first few runs
4. **Review everything** - Don't deploy without understanding
5. **Report issues** - Help us improve

## Feedback

Found something that doesn't match this document? Please:
- Open an issue at https://github.com/anthropics/claude-code/issues
- Include what you expected vs. what happened
- Share your PRD (redacted if needed) for context

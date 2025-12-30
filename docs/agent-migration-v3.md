# Agent Migration Report

## Overview

This report documents the migration from the 37 role-based agent model (v2)
to the 12 capability-based agent model (v3).

## Rationale

Community feedback identified that:
1. "Agents should reflect thinking patterns, not job titles" - darkflib
2. Too many specialized agents create coordination overhead
3. Similar agents (e.g., biz-sales, biz-investor) duplicate capabilities

## New Agent Model

| Agent | Modes | Replaces |
|-------|-------|----------|
| architect | component_design | prod-design |
| communicator | marketing, support, support, support, sales, marketing, marketing, sales, sales | biz-marketing, biz-support, growth-success, biz-hr, biz-sales, growth-lifecycle, growth-community, biz-investor, biz-partnerships |
| compliance | legal, regulatory, security | biz-legal, ops-compliance, ops-security |
| deployer | ci_cd, release, cloud, release, release | ops-devops, ops-sre, ops-monitor, ops-release, ops-incident |
| documenter | technical | prod-techwriter |
| implementer | database, mobile, backend, backend, database, infrastructure, backend, frontend | eng-database, eng-mobile, data-ml, eng-api, data-eng, eng-infra, eng-backend, eng-frontend |
| integrator | payment | biz-finance |
| optimizer | performance, cost | eng-perf, ops-cost |
| orchestrator | planning | prod-pm |
| researcher | competitive, competitive | growth-hacker, data-analytics |
| reviewer | security, business_logic, code_quality | review-security, review-business, review-code |
| tester | unit | eng-qa |

## Benefits

1. **Reduced Complexity**: 12 agents vs 37
2. **Better Coherence**: Single agent maintains context across related tasks
3. **Flexible Modes**: Same agent can switch modes without spawning new instance
4. **Easier Scaling**: Scale by agent type, not by role

## Risks

1. **Mode Confusion**: Agent might apply wrong mode's patterns
2. **Context Overload**: Single agent handling too many responsibilities
3. **Migration Errors**: Existing tasks may need manual review

## Validation

After migration, verify:
- [ ] All pending tasks have valid agent:mode assignments
- [ ] Agent state files are updated
- [ ] No orphaned tasks with unknown agent types
- [ ] Review parallel execution still works


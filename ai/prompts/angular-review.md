---
description: Review Angular code against the team's canonical instruction sets
---

Review the following scope against the team's Angular standards: $ARGUMENTS

If no scope was given, review the current working diff (`git diff HEAD`), and
if that is empty, the branch diff against the default branch.

Delegate the review to the `angular-reviewer` subagent. Relay its findings
ranked by severity with `file:line` references. If the diff also touches
templates with dynamic content, routing, or anything auth-related, run the
`security-auditor` subagent as well and merge both reports (deduplicate
overlapping findings, security first).

Do not apply fixes — this command reports. Offer to fix only after showing
the findings.

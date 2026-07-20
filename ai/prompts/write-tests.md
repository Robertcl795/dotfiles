---
description: Write unit tests for the given files following team standards
---

Write tests for: $ARGUMENTS

If no target was given, cover the files changed in the current diff that lack
corresponding spec changes.

Delegate to the `test-writer` subagent. Requirements it must honor: match the
repo's existing runner and spec conventions, exhaustive edge cases for utils,
property-based tests for algorithmic code when fast-check is available, and
run the suite until green before reporting. Show me the runner output tail
and any branches left uncovered.

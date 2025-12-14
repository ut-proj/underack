# Instructions for Claude Code: Create Cleanup Issues

## Overview

Before progressing with underack development, some maintenance and cleanup tasks need to be addressed. These were identified during a code review. Your job is to create a parent "Cleanup" issue and then create sub-issues for each specific item.

## Prerequisites

- You're in the underack repository directory
- `gh` CLI is authenticated
- Repository is `ut-proj/underack`

## Step 1: Create the Parent Cleanup Issue

Run this command:

```bash
gh issue create \
  --title "Pre-development cleanup and bug fixes" \
  --label "task" \
  --body "## Overview

Before progressing with underack development, some maintenance and cleanup is required. A code review identified several bugs and consistency issues that should be addressed first.

## Priority

These fixes should be completed before work continues on the executor pattern (#9) or other feature development.

## Scope

- Two bugs that will cause runtime errors
- Several consistency and code quality improvements
- Minor refactoring for clarity

See sub-tickets for details."
```

Note the issue number returned. You don't need to reference it in the sub-issues—the user will link them manually using GitHub's sub-task UI.

## Step 2: Create Sub-Issues

Create each of the following issues. Run them one at a time.

### Issue 1: Fix missing argument in kv-all-ks

```bash
gh issue create \
  --title "Fix missing name-atom argument in ur.core.data:kv-all-ks/1" \
  --label "bug" \
  --body "## Problem

The \`kv-all-ks/1\` function in \`ur.core.data\` does not pass its \`name-atom\` parameter to \`ets:select\`, causing the function to fail.

## Current Code

\`\`\`lisp
(defun kv-all-ks (name-atom)
  (lists:uniq
   (ets:select  (ets-ms (((tuple k v))
                         k)))))
\`\`\`

## Fixed Code

\`\`\`lisp
(defun kv-all-ks (name-atom)
  (lists:uniq
   (ets:select name-atom (ets-ms (((tuple k v))
                                   k)))))
\`\`\`

## File

\`src/ur/core/data.lfe\`

## Priority

P0 - This is a bug that will cause runtime errors."
```

### Issue 2: Fix gen_server:call on supervisors

```bash
gh issue create \
  --title "Fix stop/0 functions calling gen_server:call on supervisors" \
  --label "bug" \
  --body "## Problem

The \`stop/0\` functions in \`underack.supervisor\` and \`underack.busboard\` call \`gen_server:call\` on supervisor processes. Supervisors are not gen_servers, so these calls will fail.

## Current Code

In \`src/underack/supervisor.lfe\`:
\`\`\`lisp
(defun stop ()
  (gen_server:call (SERVER) 'stop))
\`\`\`

In \`src/underack/busboard.lfe\`:
\`\`\`lisp
(defun stop ()
  (gen_server:call (SERVER) 'stop))
\`\`\`

## Suggested Fix

Either:
1. Remove these functions and let application shutdown handle supervisor termination
2. Use appropriate supervisor API calls
3. If explicit stop is needed, consider \`supervisor:terminate_child/2\` or sending a shutdown signal

## Files

- \`src/underack/supervisor.lfe\`
- \`src/underack/busboard.lfe\`

## Priority

P0 - These functions will crash when called."
```

### Issue 3: Standardize shutdown reasons

```bash
gh issue create \
  --title "Standardize shutdown reasons in gen_server handle_call stop clauses" \
  --label "task" \
  --body "## Problem

Different gen_servers use different shutdown reasons, which is inconsistent:

\`underack.state\` uses \`shutdown\`:
\`\`\`lisp
(('stop _from state)
   \`#(stop shutdown ok ,state))
\`\`\`

\`underack.cables\` uses \`normal\`:
\`\`\`lisp
(('stop _from state)
   \`#(stop normal ok ,state))
\`\`\`

## Suggested Fix

Standardize on \`normal\` for clean shutdowns (this is the typical OTP convention).

## Files

- \`src/underack/state.lfe\`
- \`src/underack/cables.lfe\`
- Any other gen_servers with stop handlers

## Priority

P1 - Consistency issue, not a crash."
```

### Issue 4: Prefix unused variables with underscore

```bash
gh issue create \
  --title "Prefix unused bound variables with underscore" \
  --label "task" \
  --body "## Problem

In \`underack.cables:init/1\`, variables are bound but not used:

\`\`\`lisp
(defun init
  (((= \\\`#m(ets #m(name ,table-name opts ,table-opts)) state))
   (log-debug \"Initialising ~s ...\" \\\`(,(NAME)))
   (erlang:process_flag 'trap_exit 'true)
   \\\`#(ok ,state)))
\`\`\`

\`table-name\` and \`table-opts\` are bound but never used in the function body.

## Suggested Fix

Prefix with underscore to indicate intentionally unused:

\`\`\`lisp
(defun init
  (((= \\\`#m(ets #m(name ,_table-name opts ,_table-opts)) state))
   ...))
\`\`\`

Or simplify the pattern if those bindings aren't needed:

\`\`\`lisp
(defun init
  ((state)
   ...))
\`\`\`

## Files

- \`src/underack/cables.lfe\`
- Review other files for similar issues

## Priority

P1 - Code clarity and compiler warning avoidance."
```

### Issue 5: Replace export all with explicit exports

```bash
gh issue create \
  --title "Replace (export all) with explicit exports in utility modules" \
  --label "task" \
  --body "## Problem

The following modules use \`(export all)\`:

- \`ur.core.data\`
- \`ur.core.config\`
- \`ur.core.util\`

This exposes internal helper functions and makes the public API unclear.

## Suggested Fix

Replace with explicit export lists that define the public API:

\`\`\`lisp
(defmodule ur.core.data
  (export
   ;; Table operations
   (table-info 1)
   (kv-all 1)
   (kv-all-vs 1)
   (kv-all-ks 1)
   ;; ... etc
   ))
\`\`\`

## Files

- \`src/ur/core/data.lfe\`
- \`src/ur/core/config.lfe\`
- \`src/ur/core/util.lfe\`

## Priority

P2 - Good practice, not urgent."
```

### Issue 6: Refactor list comprehension used for side effects

```bash
gh issue create \
  --title "Refactor list comprehension used purely for side effects in init-tables" \
  --label "task" \
  --body "## Problem

In \`underack.state\`, a list comprehension is used purely for side effects:

\`\`\`lisp
(defun init-tables ()
  (list-comp ((<- (= \\\`#m(name ,name opts ,opts) table) (tables)))
    (progn
      (ur.core.data:import-or-new name opts)
      (log-debug \"ETS table info: ~p\" \\\`(,(undermidi.util:table-info name))))))
\`\`\`

List comprehensions are idiomatically for building lists, not for side effects. The return value is discarded.

## Suggested Fix

Use \`lists:foreach\` or a recursive function to clarify intent:

\`\`\`lisp
(defun init-tables ()
  (lists:foreach
    (lambda (table)
      (let ((name (mref table 'name))
            (opts (mref table 'opts)))
        (ur.core.data:import-or-new name opts)
        (log-debug \"ETS table info: ~p\" \\\`(,(undermidi.util:table-info name)))))
    (tables)))
\`\`\`

Or keep it simple with a local recursive function.

## File

\`src/underack/state.lfe\`

## Priority

P2 - Code clarity improvement."
```

### Issue 7: Rename make-row to clarify intent

```bash
gh issue create \
  --title "Rename make-row to make-connection in cables module" \
  --label "task" \
  --body "## Problem

In \`underack.cables\`, the function \`make-row\` creates a tuple representing a pub/sub connection:

\`\`\`lisp
(defun make-row (publisher subscriber)
  \"Pubsub terminology is used here...\"
  \\\`#(,publisher ,subscriber))
\`\`\`

The name \"row\" suggests database/table thinking, but the actual concept is a connection or subscription between modules.

## Suggested Fix

Rename to better reflect the domain:

- \`make-connection\` 
- \`make-subscription\`
- \`make-cable\` (matching the module name)

Update all call sites accordingly.

## File

\`src/underack/cables.lfe\`

## Priority

P2 - Naming clarity, can be done alongside other cables work."
```

## Step 3: Verify

After creating all issues, verify they were created:

```bash
gh issue list --state open --limit 20
```

You should see the parent cleanup issue plus 7 sub-issues.

## Summary

You will create 8 issues total:

1. **Parent:** Pre-development cleanup and bug fixes
2. **Bug:** Fix missing name-atom argument in kv-all-ks
3. **Bug:** Fix stop/0 functions calling gen_server:call on supervisors
4. **Task:** Standardize shutdown reasons
5. **Task:** Prefix unused variables with underscore
6. **Task:** Replace export all with explicit exports
7. **Task:** Refactor list comprehension used for side effects
8. **Task:** Rename make-row to clarify intent

The user will manually link the sub-issues to the parent using GitHub's sub-task UI features.

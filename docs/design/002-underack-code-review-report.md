# underack Code Review Report

**Date:** December 2025
**Reviewer:** Claude
**Scope:** All source files in ut-proj/underack as of current development state

---

## Executive Summary

The underack codebase demonstrates solid OTP fundamentals and good LFE style. The architecture is sound and the code is well-organized for its current stage. However, there are two bugs that need immediate attention, several consistency issues worth addressing, and some structural decisions to revisit as part of the state management consolidation work.

---

## Static Analysis

### Erlang Best Practices

#### What's Working Well

- Proper OTP behaviors (`gen_server`, `supervisor`, `application`)
- Correct use of supervision trees with appropriate restart strategies
- Good use of ETS for shared state
- Proper process registration with `{local, ...}`
- Trapping exits where appropriate

#### Issues Found

**1. Bug in `ur.core.data:kv-all-ks/1`**

The `name-atom` parameter is not passed to `ets:select`:

```lisp
;; CURRENT (broken):
(defun kv-all-ks (name-atom)
  (lists:uniq
   (ets:select  (ets-ms (((tuple k v))
                         k)))))

;; SHOULD BE:
(defun kv-all-ks (name-atom)
  (lists:uniq
   (ets:select name-atom (ets-ms (((tuple k v))
                                   k)))))
```

**2. `underack.supervisor:stop/0` calls `gen_server:call` on a supervisor**

```lisp
(defun stop ()
  (gen_server:call (SERVER) 'stop))
```

Supervisors aren't gen_servers—this call will fail. The same issue exists in `underack.busboard:stop/0`. Should use `supervisor:terminate_child/2` or let application shutdown handle it.

**3. Inconsistent shutdown reasons in `handle_call`**

`underack.state:handle_call` returns `shutdown`:

```lisp
(('stop _from state)
   `#(stop shutdown ok ,state))
```

But `underack.cables:handle_call` returns `normal`:

```lisp
(('stop _from state)
   `#(stop normal ok ,state))
```

Pick one and be consistent. `normal` is typically preferred for clean shutdowns.

**4. ETS table creation timing is fragile**

In `underack.state:init/1`, tables are created via `(init-tables)`. But `underack.cables:init/1` doesn't create its table—it expects it to already exist. This works because the supervisor starts `state` before `cables`, but if the order changes, things break silently.

---

### LFE Best Practices

#### What's Working Well

- Proper use of `defmodule` with behavior declarations
- Good use of pattern matching in function heads
- Appropriate use of `include-lib` for macros
- Maps used idiomatically (`#m(...)` syntax)
- Match-lambda in `ur.core.data:newest-table-file/1`
- List comprehensions with guards

#### Issues Found

**1. Unused bound variables not prefixed with `_`**

In `underack.cables:init/1`:

```lisp
(defun init
  (((= `#m(ets #m(name ,table-name opts ,table-opts)) state))
   ...))
```

`table-name` and `table-opts` are bound but not used. Should be `_table-name` and `_table-opts`.

**2. `export all` in utility modules**

```lisp
(defmodule ur.core.data
  (export all))
```

Convenient during development but should eventually be explicit exports. Exposes internal helpers and makes the public API unclear. Same applies to `ur.core.config`.

**3. List comprehension used for side effects**

```lisp
(list-comp ((<- (= `#m(name ,name opts ,opts) table) (tables)))
    (progn
      (ur.core.data:import-or-new name opts)
      (log-debug "ETS table info: ~p" `(,(undermidi.util:table-info name)))))
```

The `progn` works but list comprehension is being used purely for side effects. Consider `lists:foreach` or a recursive function to clarify intent.

---

### Idiomatic Assessment

**Erlang translation:** The code would translate cleanly to Erlang. OTP patterns are standard and idiomatic.

**LFE idioms:** Good use of quasiquoting, pattern matching, and LFE-specific constructs. The codebase feels natural to LFE.

---

## Semantic Analysis

### Code Organization

#### What's Working Well

- Clear separation: `underack.*` for OTP infrastructure, `ur.*` for utilities/logic
- `ur.core.*` namespace for foundational utilities
- `ur.mod.*` namespace for modules
- Logical supervision hierarchy: app → supervisor → (state, busboard, cables)

#### Structural Observations

**1. `underack.cables` has dual responsibilities**

It's both a gen_server AND a namespace for ETS operations. The gen_server doesn't do much—most operations go directly to ETS. Consider whether the gen_server is needed, or if it should be doing more (caching, coordinating updates, notifying subscribers).

**2. `underack.rack` and `underack.modules` are near-identical stubs**

They define ETS table configs and export/import functions, but no actual logic. Essentially copy-paste of each other. This is exactly what the state management consolidation (#11) should address.

**3. `ur.mod.clock` is a skeleton**

Has gen_server boilerplate but no clock logic. `default-opts` returns `#m(bpm 120)` but nothing uses it. Expected given current development stage.

---

### Complexity Assessment

#### Appropriately Complex

- `ur.core.data:newest-table-file/1` — Fold with timestamp comparison is exactly as complex as needed
- `underack.cables:handle_call` pattern matching — Clear dispatch
- Supervision tree setup — Standard OTP complexity

#### Potentially Over-Engineered (But Keep)

- ETS export/import with timestamped files — More sophisticated than strictly necessary for v0.1.0, but already built and working. Provides nice session persistence.

#### Under-Implemented (Expected)

- `ur.mod.clock` — Needs actual tick generation
- `underack.busboard` — Can add modules but no list/remove capability
- Cable subscriber notification — Cables stored but no notification mechanism

---

### Functional Correctness

#### What Works

- Application starts correctly
- Supervision tree initializes
- ETS tables created and persist across restarts (via import/export)
- Cables can be connected: `(underack-cables:connect 'clock 'random)`
- Cable state queryable: `(underack-cables:list-all)`
- Modules can be dynamically added to busboard

#### What's Incomplete (By Design)

- Modules don't act on their cable connections
- No message flow from outputs to inputs
- Clock doesn't tick
- No MIDI output

---

### Design Inference Concerns

**1. Confusing `make-row` terminology**

In `underack.cables`, a "row" is `#(publisher subscriber)`. In `underack.rack` and `underack.modules`, `make-row` returns `'tbd`. The term suggests database thinking, but you're modeling pub/sub relationships. Consider `make-connection` or `make-subscription`.

**2. Executor pattern not yet visible**

Issue #9 describes batch generation with caching, but no code structure exists yet. This is the right next thing to build after cleanup.

**3. Module lifecycle unclear**

`ur.mod:add/1` adds a module to the busboard, but:

- How does a module register its outputs with the cables table?
- How does a module discover and subscribe to other modules' outputs?
- Who owns this initialization?

These questions should be answered by the module base behavior work.

---

## Recommendations Summary

### Must Fix (Bugs)

| Priority | Issue | Location |
|----------|-------|----------|
| **P0** | Missing `name-atom` argument to `ets:select` | `ur.core.data:kv-all-ks/1` |
| **P0** | `gen_server:call` on supervisor (will crash) | `underack.supervisor:stop/0`, `underack.busboard:stop/0` |

### Should Fix (Consistency/Clarity)

| Priority | Issue | Location |
|----------|-------|----------|
| **P1** | Inconsistent shutdown reasons | `underack.state`, `underack.cables` |
| **P1** | Unused variables not prefixed with `_` | `underack.cables:init/1` |
| **P2** | `export all` should become explicit exports | `ur.core.data`, `ur.core.config` |
| **P2** | List comprehension for side effects | `underack.state:init-tables/0` |
| **P2** | Rename `make-row` to clarify intent | `underack.cables` |

### Address in State Management Work (#11)

| Issue | Notes |
|-------|-------|
| Consolidate ETS boilerplate | `rack.lfe`, `modules.lfe`, `cables.lfe` are repetitive |
| Define actual schemas | Rack and modules tables need schema definitions |
| Clarify table creation ownership | Document/enforce who creates tables and when |
| Evaluate `underack.cables` gen_server | Is it needed, or should ETS access be direct? |

---

## Conclusion

The codebase is in good shape for its development stage. The two P0 bugs should be fixed immediately before they cause confusion during further development. The consistency issues are worth addressing but aren't blocking. The larger structural questions (state management consolidation, module lifecycle, executor pattern) are already tracked in GitHub issues and represent the natural next phase of work.

The architecture is sound. The OTP patterns are correct. The code is ready to grow.

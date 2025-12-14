# underack 0.1.0 GitHub Issues Setup Guide

This guide provides step-by-step instructions for Claude Code to create the GitHub issue hierarchy for underack's first release using the `gh` CLI.

## Prerequisites

Before starting, ensure:
1. You're in the underack repository directory
2. `gh` CLI is authenticated (`gh auth status`)
3. The repository is `ut-proj/underack`

## Label Setup

First, ensure the required labels exist. Run these commands (they'll fail gracefully if labels already exist):

```bash
gh label create "epic" --color "6A0DAD" --description "High-level release milestone" 2>/dev/null || echo "epic label exists"
gh label create "feature" --color "FF8C00" --description "Feature-level work item" 2>/dev/null || echo "feature label exists"
gh label create "task" --color "0E8A16" --description "Task-level work item" 2>/dev/null || echo "task label exists"
```

## Issue Hierarchy Structure

```
Epic: underack 0.1.0 Release
├── Feature: Foundation Infrastructure
│   ├── Task: Centralized state management
│   ├── Task: Executor pattern implementation
│   └── Task: Module base behavior extraction
├── Feature: Clock Module
│   ├── Task: Basic tick generation
│   ├── Task: Clock division/multiplication outputs
│   ├── Task: Cable registry integration
│   └── Task: BPM update functions
├── Feature: Modulation Modules
│   ├── Task: Noise module
│   └── Task: LFO module
├── Feature: Transformation Modules
│   ├── Task: Quantizer module
│   ├── Task: Range module
│   └── Task: Sample & Hold module
├── Feature: Sequencing Modules
│   └── Task: Step sequencer module
├── Feature: Output Modules
│   └── Task: MIDI output module
└── Feature: Integration & Release
    ├── Task: End-to-end integration testing
    ├── Task: Example patches
    ├── Task: Documentation
    └── Task: Hex publication
```

---

## Step 1: Create the Epic

Create the epic issue with checkbox items for each feature. The checkboxes enable GitHub's "Convert to issue" feature.

```bash
gh issue create \
  --title "underack 0.1.0 Release" \
  --label "epic" \
  --body "## Overview

This epic tracks all work required for the first public release of underack, a Eurorack-inspired MIDI generation and manipulation system.

## Design Document

See: [underack Design Document](docs/design-0.1.0.md) (or link to your design doc location)

## Features

The following features comprise this release:

- [ ] Foundation Infrastructure
- [ ] Clock Module  
- [ ] Modulation Modules (Noise, LFO)
- [ ] Transformation Modules (Quantizer, Range, Sample & Hold)
- [ ] Sequencing Modules (Step Sequencer)
- [ ] Output Modules (MIDI Output)
- [ ] Integration & Release

## Exit Criteria

- All feature issues closed
- Example patches working end-to-end
- Documentation complete
- Published to Hex

## Links

- [Design Document](docs/design-0.1.0.md)
- [Project Board](https://github.com/orgs/ut-proj/projects/5)
"
```

**Note the issue number returned** (e.g., `#12`). You'll reference this as `EPIC_NUMBER` below.

---

## Step 2: Create Feature Issues

For each feature, create an issue with task checkboxes. Replace `EPIC_NUMBER` with the actual epic issue number.

### Feature 1: Foundation Infrastructure

```bash
gh issue create \
  --title "Foundation Infrastructure" \
  --label "feature" \
  --body "## Parent Epic

Part of #EPIC_NUMBER (underack 0.1.0 Release)

## Description

Complete the infrastructure work required before module development can proceed efficiently. This establishes the patterns and utilities that all modules will use.

## Tasks

- [ ] Centralized state management - Standardize ETS wrapper functions, define schemas
- [ ] Executor pattern implementation - Batch generation and caching mechanism
- [ ] Module base behavior extraction - Common patterns from clock into reusable behavior

## Exit Criteria

A new module can be created by implementing a small, well-defined interface, with boilerplate handled by the framework.

## Related Issues

- #11 (Manage state data centrally)
- #9 (Create executor pattern)
"
```

### Feature 2: Clock Module

```bash
gh issue create \
  --title "Clock Module" \
  --label "feature" \
  --body "## Parent Epic

Part of #EPIC_NUMBER (underack 0.1.0 Release)

## Description

The clock module is the heartbeat of underack and serves as the reference implementation for all other modules. It establishes patterns for output handling, cable registry integration, and subscriber management.

## Tasks

- [ ] Basic tick generation - Timer-based pulse emission at configurable BPM
- [ ] Clock division/multiplication outputs - Support ÷2, ÷4, ÷8, ×2, ×3 outputs
- [ ] Cable registry integration - Output → ETS → subscriber flow
- [ ] Local subscriber caching - Sync strategy between local cache and ETS source of truth
- [ ] BPM update functions - Runtime tempo changes

## Exit Criteria

Clock runs, emits ticks at correct tempo, division/multiplication outputs work, and other modules can subscribe to receive ticks.

## Related Issues

- #6 (Create clock module)
"
```

### Feature 3: Modulation Modules

```bash
gh issue create \
  --title "Modulation Modules" \
  --label "feature" \
  --body "## Parent Epic

Part of #EPIC_NUMBER (underack 0.1.0 Release)

## Description

Modulation sources generate changing values over time—the raw material for generative composition. These modules use the executor pattern for efficient value generation.

## Tasks

- [ ] Noise module - Uniform, normal, Perlin, and Simplex noise algorithms
- [ ] LFO module - Sine, triangle, square, saw, random/S&H waveforms with rate control

## Exit Criteria

Both modules generate values correctly, integrate with the executor pattern, and can be patched to other modules.

## Related Issues

- #10 (Create noise module)
"
```

### Feature 4: Transformation Modules

```bash
gh issue create \
  --title "Transformation Modules" \
  --label "feature" \
  --body "## Parent Epic

Part of #EPIC_NUMBER (underack 0.1.0 Release)

## Description

Transformation modules modify values passing through them—constraining to scales, mapping ranges, or sampling on triggers.

## Tasks

- [ ] Quantizer module - Constrain values to musical scales (integrate undertheory)
- [ ] Range module - Map input range to output range
- [ ] Sample & Hold module - Capture value on trigger, hold until next trigger

## Exit Criteria

All three modules transform values correctly and can be chained in patches.
"
```

### Feature 5: Sequencing Modules

```bash
gh issue create \
  --title "Sequencing Modules" \
  --label "feature" \
  --body "## Parent Epic

Part of #EPIC_NUMBER (underack 0.1.0 Release)

## Description

Sequencing modules produce structured patterns of values, typically advancing on clock triggers.

## Tasks

- [ ] Step sequencer module - Fixed-length sequence, clock-driven, per-step probability/ratcheting

## Exit Criteria

Step sequencer plays back sequences correctly, responds to clock input, supports basic per-step modifiers.
"
```

### Feature 6: Output Modules

```bash
gh issue create \
  --title "Output Modules" \
  --label "feature" \
  --body "## Parent Epic

Part of #EPIC_NUMBER (underack 0.1.0 Release)

## Description

Output modules convert internal value streams to MIDI messages and transmit them to external devices via undermidi.

## Tasks

- [ ] MIDI output module - Device/channel selection, message type config, note-on/off pairing

## Exit Criteria

MIDI output module successfully transmits notes and CCs to external MIDI devices. DAW receives and records MIDI correctly.
"
```

### Feature 7: Integration & Release

```bash
gh issue create \
  --title "Integration & Release" \
  --label "feature" \
  --body "## Parent Epic

Part of #EPIC_NUMBER (underack 0.1.0 Release)

## Description

Final integration, testing, documentation, and release preparation.

## Tasks

- [ ] End-to-end integration testing - Full patch: clock → noise → quantizer → MIDI output
- [ ] Example patches - Demonstrate typical use cases
- [ ] Documentation - User-facing docs, quick-start guide, README updates
- [ ] Hex publication - Version tag, changelog, hex publish

## Exit Criteria

- A musician can clone the repo, start the REPL, load a patch, and hear MIDI-triggered sounds
- Release 0.1.0 published to Hex
"
```

---

## Step 3: Convert Checkbox Items to Sub-Issues

After creating the feature issues, go to each one in the GitHub web UI:

1. Open the feature issue
2. In the description, hover over each checkbox item
3. Click the "Convert to issue" icon that appears (circle with dot)
4. GitHub creates a new issue linked to the checkbox
5. Add the "task" label to each newly created issue

**Note:** As of late 2024, `gh` CLI doesn't directly support creating sub-issues from task list items. This step requires the web UI or GitHub's GraphQL API.

### Alternative: Create Task Issues via CLI

If you prefer to create task issues directly via CLI (without the checkbox linking), you can run commands like:

```bash
# Example: Create a task issue and reference its parent feature
gh issue create \
  --title "Centralized state management" \
  --label "task" \
  --body "## Parent Feature

Part of #FEATURE_NUMBER (Foundation Infrastructure)

## Description

Standardize ETS wrapper functions across all tables (rack, modules, cables). Define consistent schemas.

## Acceptance Criteria

- [ ] General-purpose ETS wrapper functions in ur.core.data
- [ ] underack.cables updated to use new functions
- [ ] underack.rack schema defined
- [ ] underack.modules schema defined
- [ ] All tables use consistent patterns

## Related

- #11 (existing issue)
"
```

Repeat for each task, replacing `FEATURE_NUMBER` with the appropriate feature issue number.

---

## Step 4: Link Epic Checkboxes to Feature Issues

After creating all feature issues, edit the epic to convert its checkboxes to issue references:

```bash
gh issue edit EPIC_NUMBER --body "## Overview

This epic tracks all work required for the first public release of underack, a Eurorack-inspired MIDI generation and manipulation system.

## Design Document

See: [underack Design Document](docs/design-0.1.0.md)

## Features

The following features comprise this release:

- [ ] #F1_NUMBER Foundation Infrastructure
- [ ] #F2_NUMBER Clock Module  
- [ ] #F3_NUMBER Modulation Modules
- [ ] #F4_NUMBER Transformation Modules
- [ ] #F5_NUMBER Sequencing Modules
- [ ] #F6_NUMBER Output Modules
- [ ] #F7_NUMBER Integration & Release

## Exit Criteria

- All feature issues closed
- Example patches working end-to-end
- Documentation complete
- Published to Hex
"
```

Replace `F1_NUMBER` through `F7_NUMBER` with actual issue numbers.

---

## Quick Reference: All Commands in Sequence

```bash
# 1. Ensure labels exist
gh label create "epic" --color "6A0DAD" --description "High-level release milestone" 2>/dev/null || true
gh label create "feature" --color "FF8C00" --description "Feature-level work item" 2>/dev/null || true
gh label create "task" --color "0E8A16" --description "Task-level work item" 2>/dev/null || true

# 2. Create epic (note the returned issue number)
gh issue create --title "underack 0.1.0 Release" --label "epic" --body "..."

# 3. Create each feature issue (note returned numbers)
gh issue create --title "Foundation Infrastructure" --label "feature" --body "..."
gh issue create --title "Clock Module" --label "feature" --body "..."
gh issue create --title "Modulation Modules" --label "feature" --body "..."
gh issue create --title "Transformation Modules" --label "feature" --body "..."
gh issue create --title "Sequencing Modules" --label "feature" --body "..."
gh issue create --title "Output Modules" --label "feature" --body "..."
gh issue create --title "Integration & Release" --label "feature" --body "..."

# 4. Edit epic to link feature issues
gh issue edit EPIC_NUMBER --body "...(with issue numbers)..."

# 5. Create task issues OR use web UI to convert checkboxes
```

---

## Tips for Claude Code

1. **Run commands one at a time** and note the issue numbers returned
2. **Build a mapping** of issue numbers as you go (epic → features → tasks)
3. **Use `gh issue list`** to verify what's been created
4. **The web UI is required** for the checkbox → sub-issue conversion feature
5. **Check existing issues first** with `gh issue list --state open` to avoid duplicates

---

## Verification

After setup, verify the hierarchy:

```bash
# List all issues with labels
gh issue list --state open --label "epic"
gh issue list --state open --label "feature"
gh issue list --state open --label "task"

# View a specific issue
gh issue view ISSUE_NUMBER
```

# underack

*A Eurorack-Inspired MIDI Generation System*

Design Document for Release 0.1.0

*December 2025*

## Problem Statement

Modular synthesis offers a uniquely powerful paradigm for musical composition: patch-based signal flow, real-time modulation, and the intuitive mental model of "analog programming." Software implementations like VCVRack bring this paradigm to the desktop, but with significant drawbacks:

* **Resource consumption:** VCVRack demands substantial CPU and memory, competing with DAWs and sample libraries for system resources.

* **Audio quality issues:** Pops, clicks, and artifacts frequently appear in system audio, even during recording—a fundamental barrier to production use.

* **Sound source lock-in:** The modular interface is coupled to VCVRack's sound generation. Musicians who want modular composition techniques but prefer their existing sample libraries, hardware synths, or software instruments have no clean path forward.

The core insight is that these tools conflate two separable concerns: the control paradigm (patching, modulation, generative logic) and the audio generation layer. For many workflows, what's actually needed is the former without the latter.

## Background and Context

### The Modular Synthesis Model

In hardware Eurorack systems, modules communicate through control voltages (CV) transmitted over patch cables. A clock module emits timing pulses; an LFO generates slowly-changing voltages; a sequencer steps through values on each clock tick; a quantizer constrains continuous values to musical scales. The outputs of one module become the inputs of others, creating complex, evolving behaviors from simple building blocks.

This model maps naturally to message-passing concurrent systems. Each module is an independent process with its own state. Patch cables are communication channels between processes. The "voltage" transmitted is simply a numeric value—and for MIDI applications, that value lives in a well-defined integer range (0-127 for most parameters).

### The Erlang/OTP Fit

The BEAM virtual machine and OTP framework provide an almost suspiciously good fit for this domain:

* **Processes as modules:** Lightweight Erlang processes map directly to rack modules. Each maintains its own state, runs concurrently, and communicates through message passing.

* **Supervision for resilience:** OTP supervision trees provide automatic recovery from failures. A crashing module doesn't bring down the rack—it restarts and reconnects.

* **Hot code reloading:** Module logic can be updated without stopping the system, enabling live experimentation.

* **ETS for shared state:** Erlang Term Storage provides fast, concurrent access to patch routing tables and module registries.

LFE (Lisp Flavored Erlang) adds expressive power for defining module behaviors and DSLs for patch configuration, while retaining full access to OTP patterns.

### Prior Work: The ut-proj Ecosystem

underack builds on an existing foundation:

* **undermidi:** Provides low-level MIDI I/O through NIFs, including device enumeration, message construction, and real-time transmission. This is the bridge to the outside world.

* **undertheory:** Music theory primitives—scales, chords, intervals, transposition. Useful for quantizers and harmonizers.

* **midilib:** MIDI message parsing and construction.

underack sits above these, providing the modular composition framework that generates MIDI data for undermidi to transmit.

## Vision

### What underack Is

underack is a modular MIDI generation and manipulation system. It provides:

* **A virtual rack** where modules can be instantiated, configured, and connected.

* **A library of modules** for timing (clocks, dividers), modulation (LFOs, envelopes, noise), sequencing, and value transformation.

* **A patching system** where module outputs connect to module inputs through flexible, many-to-many relationships.

* **Output modules** that convert internal integer streams to MIDI messages and transmit them to configured devices.

Musicians set up patches programmatically or interactively, let them run, and capture the resulting MIDI in their DAW of choice. The actual sounds come from whatever instruments receive that MIDI—sample libraries, hardware synths, software plugins.

### What underack Is Not

underack does not generate audio. It has no oscillators, filters, or effects in the traditional sense. It is purely a control-rate system operating in the MIDI domain. This constraint is a feature: it keeps resource usage minimal and lets musicians use their preferred sound sources.

### Design Principles

1. **Eurorack as metaphor, not constraint.** The modular synthesis model provides excellent ergonomics, but we're not limited by physical realities. Cables can fan out freely. Modules can have dynamic numbers of inputs and outputs. Patches can be saved, loaded, and version-controlled.

2. **Composition over configuration.** Complex behaviors should emerge from combining simple modules, not from configuring monolithic ones.

3. **Soft real-time, not hard.** Musical timing matters, but we're generating MIDI, not audio. Millisecond-level jitter is acceptable; sample-accurate timing is not required.

4. **Programmer-friendly first.** The primary interface is code—LFE functions and data structures. GUIs and visual patching may come later, but the core must be fully usable from a REPL.

5. **Minimal viable, then iterate.** Release 0.1.0 should be genuinely useful for making music, not a framework awaiting modules.

## Architecture Overview

### System Layers

The system is organized in layers, from bottom to top:

* **MIDI I/O (undermidi):** Device enumeration, message transmission, timing. Already exists.

* **Infrastructure (underack core):** Supervision trees, ETS tables, module lifecycle management, cable registry.

* **Module Framework:** Base behaviors and patterns that all modules implement—input/output handling, state management, clock subscription.

* **Module Library:** Concrete implementations—clocks, noise sources, sequencers, quantizers, MIDI outputs.

* **Patches:** User-defined configurations that instantiate modules and wire them together.

### Core Abstractions

#### The Rack

The top-level container. Manages power (supervision), the bus board (dynamic module supervisor), and global state. Only one rack exists per underack instance.

#### Modules

Independent gen\_servers that process inputs and produce outputs. Each module:

* Has a unique name within the rack

* Declares its inputs (what it consumes) and outputs (what it produces)

* Maintains internal state (parameters, configuration)

* Subscribes to other modules' outputs via the cable registry

* Emits values to its outputs, which the cable system routes to subscribers

#### Cables

The routing layer. Implemented as an ETS table mapping outputs to subscribers. Unlike physical cables:

* One output can connect to many inputs (fan-out is free)

* Connections can be added and removed at runtime

* The cable registry is the source of truth; modules cache subscribers locally for performance

#### Values

The "voltage" of underack. By default, integers in the range 0-127 (MIDI's natural domain). Modules transform these values: noise sources generate them randomly, quantizers constrain them to scales, scalers map ranges, outputs convert them to MIDI messages.

### The Executor Pattern

Some modules (noise generators, complex LFOs) involve computation that shouldn't happen on every tick. The executor pattern addresses this:

* Modules define generator functions that produce batches of values

* An executor pre-computes values into a cache/queue

* Consumers pull from the cache (fast, just a dequeue)

* Background refill triggers when the cache runs low

This decouples consumption rate from generation cost, ensuring consistent timing even with expensive computations.

## Module Inventory for Release 0.1.0

The following modules constitute the minimum viable set for generative MIDI composition:

### Timing

1. **Clock:** The heartbeat. Emits pulses at a configurable BPM. Supports multiple simultaneous outputs for divisions (÷2, ÷4, ÷8) and multiplications (×2, ×3). Publishes current BPM to rack state for modules that need tempo-relative calculations.

### Modulation Sources

2. **Noise:** Random value generation. Multiple algorithms: uniform distribution, normal distribution, Perlin noise (for smooth, organic movement), Simplex noise. Uses the executor pattern for efficient batch generation.

3. **LFO:** Low-frequency oscillator. Waveforms: sine, triangle, square, saw, random/sample-and-hold. Rate configurable in Hz or tempo-synced divisions.

### Value Transformation

4. **Quantizer:** Constrains input values to musical scales. Integrates with undertheory for scale definitions. Configurable root note.

5. **Range:** Maps input range to output range. Essential for scaling modulation sources to useful MIDI ranges (e.g., noise 0-127 → velocity 60-100).

6. **Sample & Hold:** Captures input value on trigger, holds until next trigger. Classic modular utility.

### Sequencing

7. **Step Sequencer:** Fixed-length sequence of values, advances on clock input. Configurable length, supports per-step probability and ratcheting.

### Output

8. **MIDI Output:** Converts value streams to MIDI messages and transmits via undermidi. Configurable device, channel, message type (note, CC, pitch bend). Handles note-on/note-off pairing for note messages.

This set—clock, noise, LFO, quantizer, range, sample & hold, step sequencer, and MIDI output—enables a wide range of generative patches while remaining tractable for an initial release.

## Implementation Plan

### Phase 1: Foundation Completion

Complete the infrastructure work already in progress:

* **Centralized state management (\#11):** Standardize ETS wrapper functions, define schemas for rack, modules, and cables tables.

* **Executor pattern (\#9):** Implement the batch-generation and caching mechanism. This unblocks noise and potentially other modules.

* **Module base behavior:** Extract common patterns from the clock skeleton into a reusable behavior or module template.

**Exit criterion:** A new module can be created by implementing a small, well-defined interface, with boilerplate handled by the framework.

### Phase 2: Clock as Reference Implementation

The clock module (\#6) serves as the pattern-setter:

* Implement tick generation with configurable BPM

* Add division and multiplication outputs

* Establish the output → cable registry → subscriber flow

* Solve the local caching vs. ETS source-of-truth synchronization

* Document the patterns for other modules to follow

**Exit criterion:** Clock runs, emits ticks, and other modules can subscribe to receive them.

### Phase 3: Module Build-Out

With patterns established, build the remaining modules:

* Noise (using executor pattern)

* LFO

* Quantizer (integrating undertheory)

* Range

* Sample & Hold

* Step Sequencer

* MIDI Output (integrating undermidi)

Each module follows the established patterns. Complexity is in the musical logic, not the infrastructure.

**Exit criterion:** All modules implemented, individually tested.

### Phase 4: Integration and First Patch

Wire everything together:

* End-to-end test: clock → noise → quantizer → MIDI output

* Verify MIDI output reaches external devices

* Create example patches demonstrating typical use cases

* Write user-facing documentation

**Exit criterion:** A musician can clone the repo, start the REPL, load a patch, and hear MIDI-triggered sounds from their DAW.

### Phase 5: Release

Prepare for public release:

* Version tagging and changelog

* Hex package publication

* README with quick-start guide

* GitHub release with notes

**Exit criterion:** Release 0.1.0 published.

## Future Directions (Post-0.1.0)

Ideas for subsequent releases, not in scope for 0.1.0:

* **Turing Machine module:** A specific, high-priority module for generative composition. Clone of the popular VCVRack/hardware module.

* **Euclidean rhythm generator:** Algorithmic rhythm patterns.

* **Envelope generator:** ADSR and other shapes for velocity/CC modulation over time.

* **MIDI input module:** Accept external MIDI as a modulation source.

* **MIDI clock sync:** Slave to external MIDI clock from DAW.

* **Patch serialization:** Save/load patches as data files.

* **Visual patch editor:** Web-based UI for creating and monitoring patches.

* **Rust NIFs:** If profiling reveals hot paths in batch generation, factor those out to Rust for performance.

## Open Questions

Decisions to be made during implementation:

* **Timing mechanism:** erlang:send\_after/3 vs timer:send\_interval/2? The former allows drift correction; the latter is simpler. Need to evaluate jitter characteristics.

* **Clock distribution model:** Push (clock broadcasts to all subscribers) vs pull (modules request ticks)? Push seems more Eurorack-like, but pull might scale better.

* **Value representation:** Plain integers, or tagged tuples with metadata (timestamp, source module)? Start simple, add metadata if needed.

* **Cable update propagation:** When cables change, how do modules learn? Polling, notification messages, or ETS observation?

## Appendix: Glossary

| Term | Definition |
| :---- | :---- |
| **Rack** | The top-level container for the underack system |
| **Module** | An independent process that transforms or generates values |
| **Cable** | A connection from one module's output to another's input |
| **Value** | An integer (typically 0-127) transmitted between modules |
| **Executor** | A pattern for batch-generating and caching values |
| **Patch** | A configuration of modules and their cable connections |
| **CV** | Control Voltage—the analog equivalent of underack's integer values |
| **BPM** | Beats Per Minute—the tempo setting for the clock module |

*— End of Document —*
# underack vs. Eurorack

Aside from the obivous software vs. hardware and MIDI integers vs. voltages, this doc attempts to lay out the key differences how how they have affected the architectural and design decisions of underack (ur).

## Physical Analogues

* Rack system 
  * rails - NA
  * side plates - NA
  * covers - NA
  * rack ears - NA
  * bus board - a subset of the underack supervision tree (what the modules plug into)
  * power supply - very roughly, the Erlang VM
* Modules
  * circuit boards - LFE logic
  * connection to bus - LFE module-level, dedicated supervision tree for gen_server (maintaining state and connection) and child processes (I/O)
  * inputs - module child processes (one per input) linked from another module's output (Erlang PID)
  * outputs - module PIDs that have been linked to another module's output; module PIDs represent the worker processes that take integers from the given input, process the logic of the module, and produce a new integer stream from said logic
* Patching
  * 3.5 mm patch cables - OTP links between module processes

## Module Types

* VCOs - no VCOs in ur; actualy synthesis, voices, banks, etc., are provided by the devices receiving MIDI data from underack
* Noise Sources - ur does provide noise sources of integers within a given range (default, 0-127).
* Modulators - this is one of the categories that comprises the bulk of what ur aims to provide to musicians
* Filters - is is another bulk-of-capabilities category for ur
* Sequences - ur hopes to provide a handful of basic seqencers, but these are easy to create programmatically, and it is expected that coding musicians will create these to taste
* Utilities - there will eventually be a number of these provided by ur
* Effects - as with VCOs, ur will not provide any of these

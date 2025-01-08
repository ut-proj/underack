# underack

[![Build Status][gh-actions-badge]][gh-actions]
[![LFE Versions][lfe badge]][lfe]
[![Erlang Versions][erlang badge]][versions]

[![][logo]][logo-large]

*A Eurorack-inspired, modular, MIDI generation and manipulation system*

## About

In the same way that modular synth systems generate voltages which are used as inputs to other modules and, ultimately oscilators, the underack project aims to generate and modulate MIDI values to be used by MIDI devices for not only note values, velocity, etc., but also CC messages and the like. These may then be used by MIDI devices (hardware or software) to create and modify the likes of:

* rhythmic patterns
* harmonies
* melodies
* and variations on all of the above

This project aims to provide sophisticated music-generation capability with very low CPU and memory utilisation, equally suitable for short duration, small projects and long duration, complex orchestrations.

## System Architecture

As with most of the undertone projects, underack is build with LFE/Erlang OTP. Of all its sibling projects, however, underack relies most heavily on OTP, gen_servers, supervision trees, and Erlang VM process management. Modular synthesis not only rests solidly in the realm of soft real-time programming, it is an intensely state-driven endeavour.

The top-level OTP gen_server represents a eurorack assembly: slots, connectors, and power. Each module that is assed to the rack is a child gen_server with the ability to ask the top-level gen_server to update state. Each module, in turn, will create its own child process when an input is added to it. This processes output will then be available to the rest of the rack wherever inputs are accepted.

## License

Apache 2.0

[//]: ---Named-Links---

[logo]: priv/images/logo-v1-x250.png
[logo-large]: priv/images/logo-v1-x1000.png
[github]: https://github.com/ut-proj/undermidi
[gh-actions-badge]: https://github.com/ut-proj/underack/workflows/ci%2Fcd/badge.svg
[lfe-badge]: https://img.shields.io/badge/lfe-2.1+-blue.svg
[erlang-badge]: https://img.shields.io/badge/erlang-25%20to%2027-blue.svg
[versions]: https://github.com/ut-proj/underack/blob/master/.github/workflows/cicd.yml

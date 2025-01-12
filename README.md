# underack

[![Build Status][gh-actions-badge]][gh-actions]
[![LFE Versions][lfe-badge]][lfe]
[![Erlang Versions][erlang-badge]][versions]

[![][logo]][logo-large]

*A Eurorack-inspired, modular, MIDI generation and manipulation system*

## About

In the same way that modular synth systems generate voltages which are used as inputs to other modules and, ultimately oscilators, the underack project aims to generate and modulate MIDI values to be used by MIDI devices for not only note values, velocity, etc., but also CC messages and the like. These may then be used by MIDI devices (hardware or software) to create and modify the likes of:

* rhythmic patterns
* harmonies
* melodies
* and variations on all of the above

This project aims to provide sophisticated music-generation capability with very low CPU and memory utilisation, equally suitable for short duration, small projects and long duration, complex orchestrations.

## Details

* [System Architecture](./docs/arch.md)
* [underack vs. Eurorack](./docs/eurorack.md)

## Running

Clone the repo, `cd` into the dir, and run the following:

```
rebar3 as underack repl
```

## License

Apache 2.0

[//]: ---Named-Links---

[logo]: priv/images/logo-v1-x250.png
[logo-large]: priv/images/logo-v1-x1000.png
[github]: https://github.com/ut-proj/undermidi
[gh-actions-badge]: https://github.com/ut-proj/underack/workflows/ci%2Fcd/badge.svg
[gh-actions]: https://github.com/ut-proj/underack/actions
[lfe-badge]: https://img.shields.io/badge/lfe-2.1+-blue.svg
[lfe]: https://github.com/lfe/lfe
[erlang-badge]: https://img.shields.io/badge/erlang-25%20to%2027-blue.svg
[versions]: https://github.com/ut-proj/underack/blob/master/.github/workflows/cicd.yml

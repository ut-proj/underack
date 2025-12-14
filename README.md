# underack

[![Build Status][gh-actions-badge]][gh-actions]
[![LFE Versions][lfe-badge]][lfe]
[![Erlang Versions][erlang-badge]][versions]
[![Tags][github-tags-badge]][github-tags]
[![Downloads][hex-downloads]][hex-package]

*A Eurorack-inspired, modular, MIDI generation and manipulation system*

[![][logo]][logo-large]

## About

In the same way that modular synth systems generate voltages which are used as inputs to other modules and, ultimately oscilators, the underack project aims to generate and modulate MIDI values to be used by MIDI devices for not only note values, velocity, etc., but also CC messages and the like. These may then be used by MIDI devices (hardware or software) to create and modify the likes of:

* rhythmic patterns
* harmonies
* melodies
* and variations on all of the above

This project aims to provide sophisticated music-generation capability with very low CPU and memory utilisation, equally suitable for short duration, small projects and long duration, complex orchestrations.

## Details

* [v0.1.0 Design Doc](./docs/design/000-underack-design-document.md/)
* [System Architecture](./docs/arch.md)
* [underack vs. Eurorack](./docs/eurorack.md)

## Running

Clone the repo, `cd` into the dir, and run the following:

``` shell
rebar3 as underack repl
```

Note that if you don't use the `as underack` rebar3 profile subcommand, you'll get the LFE banner printed to stdout, in addition to the underack banner.

## Status

underack is currently under active initial development. Project planning is being done here:

* <https://github.com/orgs/ut-proj/projects/5>

## Notes

``` lisp
(underack-cables:add-output 'walk)
(underack-cables:connect 'clock 'random)
(underack-cables:connect 'clock '(noise divider))
(underack-cables:list-outputs)
(underack-cables:list-all)
(underack-cables:export)
```

## License

Apache 2.0

[//]: ---Named-Links---

[logo]: priv/images/logo-v1-x250.png
[logo-large]: priv/images/logo-v1-x1000.png
[gh-actions-badge]: https://github.com/ut-proj/underack/workflows/ci%2Fcd/badge.svg
[gh-actions]: https://github.com/ut-proj/underack/actions
[lfe-badge]: https://img.shields.io/badge/lfe-2.1+-blue.svg
[lfe]: https://github.com/lfe/lfe
[erlang-badge]: https://img.shields.io/badge/erlang-25+-blue.svg
[versions]: https://github.com/ut-proj/underack/blob/master/.github/workflows/cicd.yml
[github-tags]: https://github.com/ut-proj/underack/tags
[github-tags-badge]: https://img.shields.io/github/tag/ut-proj/underack.svg
[hex-package]: https://hex.pm/packages/underack
[hex-downloads]: https://img.shields.io/hexpm/dt/underack.svg

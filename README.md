# brew.v

This repository is a source-faithful V translation scaffold of Homebrew/brew at
the revision recorded in `SOURCE_COMMIT`.

Every Ruby file has a matching V file. `Library/Homebrew/example.rb` maps to
`homebrew/example.v`; the repository's other Ruby helpers map beneath `docs`
and `github`. Directory segments are lowercased where V requires
snake-case module paths (`ENV` becomes `env` and `Casks` becomes `casks`). Each
Ruby `_test.rb` filename receives a `_test_ruby.v` suffix so V does not mistake a
retained RSpec helper for a native V test. Each translated file retains its
complete Ruby source line-for-line as V comments. Ruby methods, generated
accessors, aliases, delegates, matcher methods, and RSpec examples have V entry
points.

Where a dependency or Ruby type has not yet been translated, the V entry point
calls `brew_runtime.unimplemented_fn`. These explicit boundaries are intended to
be replaced one at a time with typed V bodies without losing source context.

Build the current command entry point with:

```sh
v -o brew-v .
```

Until the retained Ruby command graph has typed V bodies, the executable uses a
native Homebrew installation as a compatibility backend and replaces itself with
that process, forwarding arguments without shell interpolation. Set
`BREW_V_BACKEND` to select the backend explicitly.

## Benchmarks

Local wall-clock measurements from 2026-08-27 on an Apple M5 Max with 128 GB
RAM, macOS 26.5 arm64, V 0.5.2 (`915f2e7`), Homebrew's portable Ruby 4.0.6,
and Homebrew 6.0.17 (updated to 6.0.20 during the update benchmark).

### Compilation

Each command had one warm-up followed by five runs with `hyperfine`. Times are
seconds.

| Operation | Median | Range | Result |
| --- | ---: | ---: | --- |
| `v -prod -o brew-v .` | 1.392 | 1.353–1.429 | 231,048-byte native executable |
| Compile Ruby `brew.rb` with `RubyVM::InstructionSequence.compile_file` | 0.028 | 0.027–0.031 | In-memory Ruby bytecode |
| Compile all 2,176 `Library/Homebrew` Ruby files to VM bytecode | 0.464 | 0.454–0.499 | In-memory Ruby bytecode |

Ruby Homebrew has no ahead-of-time build step, so these are deliberately
different operations: V produces and links a native executable, while Ruby only
parses source into process-local bytecode. The current V executable links the
command frontend and compatibility runtime; the retained `homebrew` modules are
validated separately and are not yet linked into that executable.

### Installing Neovim

These are warm-cache installs of Neovim 0.12.4 with its dependencies already
installed. Before each run, only Neovim was removed with
`brew uninstall --ignore-dependencies neovim`; the six runs alternated between
the two frontends. Neovim was left installed afterward.

| Frontend | Samples | Median |
| --- | --- | ---: |
| Native Ruby `brew install neovim` | 1.31, 1.22, 1.24 | 1.24 s |
| `brew-v install neovim` | 2.05, 1.22, 1.23 | 1.23 s |

`brew-v` currently replaces itself with the same native Homebrew backend, so
the difference is normal run-to-run noise, not an independent V installer
speedup.

### Updating Homebrew

The initial real `brew update` took 35.70 s, updated Homebrew from 6.0.17 to
6.0.20, and updated `homebrew/core` and `homebrew/cask`. After synchronization,
three alternating no-change runs through each frontend produced:

| Frontend | Samples | Median |
| --- | --- | ---: |
| Native Ruby `brew update` | 1.15, 1.09, 1.14 | 1.14 s |
| `brew-v update` | 1.34, 1.11, 1.11 | 1.11 s |

The one real network update cannot be replayed under identical remote state.
The no-change comparison again measures two frontends entering the same native
Homebrew implementation.

## Validation

Run all executable V tests with:

```sh
v test .
```

Audit source and method coverage with:

```sh
v run tools/audit_translation/main.v \
  /path/to/brew/Library/Homebrew homebrew
```

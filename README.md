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
calls `ruby.unimplemented_fn` from the
[`vlang/ruby`](https://github.com/vlang/ruby) compatibility module. These
explicit boundaries are intended to be replaced one at a time with typed V
bodies without losing source context.

Install the external V dependencies once after cloning:

```sh
v install --once
```

Build the current command entry point with:

```sh
v -o brew-v .
```

The executable runs only translated V code. It does not invoke or fall back to a
native Ruby Homebrew installation. Execution currently stops at the explicit
`brew.rb:<top-level>` stub because the retained Ruby command graph does not yet
have typed V bodies.

## Benchmarks

Local wall-clock measurements from 2026-08-27 on an Apple M5 Max with 128 GB
RAM, macOS 26.5 arm64, V 0.5.2 (`915f2e7`), Homebrew's portable Ruby 4.0.6,
and Homebrew 6.0.17 (updated to 6.0.20 during the update benchmark).

### Compilation

Each command had one warm-up followed by five runs with `hyperfine`. Times are
seconds.

| Operation | Median | Range | Result |
| --- | ---: | ---: | --- |
| `v -prod -o brew-v .` | 0.839 | 0.825–0.854 | 126,808-byte native executable |
| Compile Ruby `brew.rb` with `RubyVM::InstructionSequence.compile_file` | 0.028 | 0.027–0.031 | In-memory Ruby bytecode |
| Compile all 2,176 `Library/Homebrew` Ruby files to VM bytecode | 0.464 | 0.454–0.499 | In-memory Ruby bytecode |

Ruby Homebrew has no ahead-of-time build step, so these are deliberately
different operations: V produces and links a native executable, while Ruby only
parses source into process-local bytecode. The V executable includes the
translated root `homebrew` module, but most entry points remain explicit stubs.

### Installing Neovim

There is no valid V installation benchmark yet. `brew-v install neovim` reaches
the untranslated `brew.rb:<top-level>` boundary and exits without installing
anything. Publishing the native Ruby Homebrew time as a `brew-v` result would be
misleading.

### Updating Homebrew

There is likewise no valid V update benchmark yet. `brew-v update` stops at the
same untranslated top-level boundary. A native Ruby `brew update` measured
35.70 s while updating two taps from Homebrew 6.0.17 to 6.0.20, but that is a
Ruby Homebrew result, not a V result.

## Translation status

The repository contains source-faithful V counterparts for all 2,180 Ruby files
and retains all 320,780 Ruby source lines as comments. It currently has 23,530
translated function or generated-method boundaries: 23,527 explicit stubs and
three direct implementations. This is a complete mechanical translation
scaffold under the project's explicit stub convention, not yet a behaviorally
complete Homebrew implementation.

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

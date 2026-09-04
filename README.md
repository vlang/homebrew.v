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
uses the dynamic `ruby.Value` boundary from the
[`vlang/ruby`](https://github.com/vlang/ruby) compatibility module. These
boundaries are being replaced one at a time with typed V bodies without losing
source context.

Install the external V dependencies once after cloning:

```sh
v install --once
```

Build the current command entry point with:

```sh
v -o brew-v .
```

The executable runs only translated V code. It does not invoke or fall back to a
native Ruby Homebrew installation. Formula bottle installation and uninstall,
along with `--version`, `--repository`, and `--taps`, have executable command
bodies. Other recognized commands report that their run body is not implemented.

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
translated root `homebrew` module and the command implementations they reach.

### Installing Neovim

There is no timed V installation benchmark yet. An isolated end-to-end check on
2026-09-04 installed the current Neovim bottle and its dependencies, ran
`nvim --version`, and uninstalled Neovim using `brew-v`. Dependencies remain
installed after a plain uninstall; automatic dependency removal is not yet
wired into the root command.

### Updating Homebrew

There is likewise no valid V update benchmark yet. `brew-v update` resolves the
translated command but reports that its run body is not implemented. A native
Ruby `brew update` measured 35.70 s while updating two taps from Homebrew 6.0.17
to 6.0.20, but that is a Ruby Homebrew result, not a V result.

## Translation status

The repository contains source-faithful V counterparts for all 2,180 Ruby files
and retains all 320,780 Ruby source lines as comments. There are currently no
explicit `ruby.unimplemented_fn` stubs. Production callers use stable V APIs
whenever the target has a concrete signature. Generated `ruby_*_l*` names remain
for dynamically typed `ruby.Value` boundaries and retained source-coverage entry
points. This is not yet a behaviorally complete Homebrew implementation, and
those dynamic boundaries are being replaced as their domain models become typed.

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

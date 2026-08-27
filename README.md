# brew.v

This repository is a source-faithful V translation scaffold of Homebrew/brew at
the revision recorded in `SOURCE_COMMIT`.

Every Ruby file has a matching V file. `Library/Homebrew/example.rb` maps to
`src/homebrew/example.v`; the repository's other Ruby helpers map beneath
`src/docs` and `src/github`. Directory segments are lowercased where V requires
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
v -o brew-v src
```

Until the retained Ruby command graph has typed V bodies, the executable uses a
native Homebrew installation as a compatibility backend and replaces itself with
that process, forwarding arguments without shell interpolation. Set
`BREW_V_BACKEND` to select the backend explicitly.

Run the executable V tests and the complete translation audit with:

```sh
v test tests src/brew_runtime
```

Audit source and method coverage with:

```sh
v run tools/audit_translation/main.v \
  /path/to/brew/Library/Homebrew src/homebrew
```

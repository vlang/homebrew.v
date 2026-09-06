# brew.v

## Benchmarks: installing and removing Neovim

| Operation | `brew-v` | Ruby `brew` | |
| --- | ---: | ---: | --- |
| `install neovim` | **0.83 s** / **30.3 MB** | 1.18 s / 148.2 MB | 1.4x faster, 4.9x less RAM |
| `uninstall neovim` | **0.22 s** / **5.6 MB** | 0.73 s / 99.7 MB | 3.3x faster, 17.7x less RAM |

## About

`brew.v` is a native V implementation derived from Homebrew/brew at the
revision recorded in `SOURCE_COMMIT`.

The repository contains the typed implementation needed by the executable. It
does not retain unreferenced generated per-Ruby-method entry points, translated
Ruby test and vendor trees, or copies of the original Ruby source. Consult the
recorded upstream revision when source-level context is needed.

Some code still uses the dynamic `ruby.Value` boundary from the
[`vlang/ruby`](https://github.com/vlang/ruby) compatibility module, in 848
places across 267 files, down from 3,554. The 2,142 functions that named it and
were called from nowhere have been removed, and `homebrew/api.v` now carries
JSON as `x.json2.Any`. What is left is referenced, so each remaining boundary
needs a concrete V type rather than a mechanical substitution. None of it is on
the install or uninstall path, which already decodes into typed structs.

Install the external V dependencies once after cloning:

```sh
v install --once
```

Build the command entry point with:

```sh
v -o brew-v .
```

The executable runs only V code. It does not invoke or fall back to a native
Ruby Homebrew installation. Formula bottle installation and uninstall, along
with `--version`, `--repository`, and `--taps`, have executable command bodies.
Other recognized commands report that their run body is not implemented.

## Installing Neovim

An isolated end-to-end check on 2026-09-04 installed the current Neovim bottle
and its dependencies, ran `nvim --version`, and uninstalled Neovim using
`brew-v`. Dependencies remain installed after a plain uninstall; automatic
dependency removal is not yet wired into the root command.

## Validation

Run the executable V tests with:

```sh
v test .
```


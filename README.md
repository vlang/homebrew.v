# brew.v

## Benchmarks: installing and removing Neovim

| Operation | `brew-v` | Ruby `brew` | |
| --- | ---: | ---: | --- |
| `install neovim` | **0.76 s** / **48.4 MB** | 1.04 s / 150.6 MB | 1.4x faster, 3.1x less RAM |
| `uninstall neovim` | **0.19 s** / **10.6 MB** | 0.68 s / 98.5 MB | 3.6x faster, 9.3x less RAM |

## About

`brew.v` is a native V implementation derived from Homebrew/brew at the
revision recorded in `SOURCE_COMMIT`.

The repository contains the typed implementation needed by the executable. It
does not retain unreferenced generated per-Ruby-method entry points, translated
Ruby test and vendor trees, or copies of the original Ruby source. Consult the
recorded upstream revision when source-level context is needed.

Some code still uses the dynamic `ruby.Value` boundary from the
[`vlang/ruby`](https://github.com/vlang/ruby) compatibility module. Those
remaining boundaries are kept only when referenced and can be replaced with
typed V APIs incrementally.

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


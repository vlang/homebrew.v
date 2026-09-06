# brew.v

## Benchmarks: installing and removing Neovim

| Operation | Frontend | Median wall | Range | Median CPU | Peak RSS |
| --- | --- | ---: | ---: | ---: | ---: |
| `install neovim` | `brew-v` | 13.12 s | 12.49–13.76 | 8.35 s | 92.1 MB |
| `install neovim` | Ruby `brew` | 1.04 s | 0.79–1.07 | 0.97 s | 146.6 MB |
| `uninstall neovim` | `brew-v` | 0.19 s | 0.19–0.19 | 0.18 s | 10.6 MB |
| `uninstall neovim` | Ruby `brew` | 0.66 s | 0.49–0.69 | 0.59 s | 99.9 MB |

`brew-v uninstall` is 3.5x faster than Ruby Homebrew and holds 9.4x less memory,
with no run-to-run spread at all. `brew-v install` is 12.6x slower while holding
1.6x less memory, for two reasons that a `/usr/bin/sample` profile of a single
install attributes 84% of the run to:

- `Keg.relocate_dynamic_linkage` reaches `mach_o_files`, and `keg_file_description`
  (`homebrew/keg_relocate.v`) forks `file -b` once per regular file: 2,112 processes
  for one Neovim keg, 66% of the run. Ruby Homebrew reads the Mach-O header instead
  of shelling out. Reading the magic bytes in V, and caching the `find_executable`
  lookup that repeats per file, removes this.
- `api.fetch_formula_endpoint` (`homebrew/api/formula.v`) issues one live HTTPS GET
  to `formulae.brew.sh/api/formula/<name>.json` per formula in the dependency graph,
  18% of the run and nearly all of it blocked on the network. Ruby Homebrew answers
  the same queries from the 29 MB `~/Library/Caches/Homebrew/api` bundle it already
  has on disk. This is why a `brew-v install` of an already-installed Neovim still
  costs 5.19 s wall for only 0.39 s of CPU.

Neither cost is inherent to the V implementation: startup is already 0.00 s and
4.3 MB against Ruby's 0.03 s and 5.8 MB, and the same-work `uninstall` path shows
what the install path reaches once per-file subprocesses and uncached metadata
fetches are gone.

### Method

Measured on 2026-09-06, Apple arm64 (18-core), macOS 26.5, V 0.5.2 (`b98993c`),
against Homebrew 6.0.22-67-g29b882c on portable Ruby 4.0.6. `brew-v` is an
optimized `v -prod -o brew-v .` build; a default non-`-prod` build runs the same
install in 13.94 s, because this workload is bound by subprocess spawns and
network round trips rather than by generated code. Harness: `bench/bench.sh`
(5 recorded iterations, one warm-up, tool order rotated each iteration, raw rows
in `bench/results.tsv`).

Both frontends run the same operation from the same starting state: Neovim 0.12.5_1
absent with all ten dependencies present and the bottle and manifest already in
`~/Library/Caches/Homebrew` for `install`, and Neovim present for `uninstall`.
Ruby runs under Homebrew's own `dev-cmd/benchmark.rb` environment
(`HOMEBREW_NO_ANALYTICS`, `NO_AUTO_UPDATE`, `NO_AUTOREMOVE`, `NO_ENV_HINTS`,
`NO_INSTALLED_DEPENDENTS_CHECK`, `NO_INSTALL_CLEANUP`), so both remove exactly one
keg. Times are wall clock from `/usr/bin/time -l`; RAM is that run's maximum
resident set size.

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


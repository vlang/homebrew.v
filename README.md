# brew.v

## Benchmarks: installing and removing Neovim

| Operation | Frontend | Median wall | Range | Median CPU | Peak RSS |
| --- | --- | ---: | ---: | ---: | ---: |
| `install neovim` | `brew-v` | **0.76 s** | 0.73–0.76 | 0.66 s | **48.4 MB** |
| `install neovim` | Ruby `brew` | 1.04 s | 0.79–1.07 | 0.97 s | 150.6 MB |
| `uninstall neovim` | `brew-v` | **0.19 s** | 0.19–0.20 | 0.18 s | **10.6 MB** |
| `uninstall neovim` | Ruby `brew` | 0.68 s | 0.51–0.72 | 0.60 s | 98.5 MB |

`brew-v` installs 1.4x faster than Ruby Homebrew on 3.1x less memory, and
uninstalls 3.6x faster on 9.3x less memory.

Install was 12.70 s before the three fixes below, all of them places where the
translation reached for a subprocess or the network where the source does not.
None of them changed what gets installed: the resulting keg is byte-identical to
the one the pre-fix executable produced.

- **2,112 `file` forks per keg.** `Keg#mach_o_files` classified every regular
  file by forking `file -b`, re-scanning `PATH` for `file` each time, to find the
  12 Mach-O files in Neovim. The source reads the Mach-O header through
  ruby-macho instead, so `mach_o_relocatable_file` now parses the magic, fat
  slices and file type directly (`homebrew/keg_relocate.v`). Checked against
  `file` over 79,873 files in `/opt/homebrew/Cellar`, `/usr/bin` and
  `/opt/homebrew/bin`: zero disagreements. `Keg#text_files` had the same shape and
  now batches one `file` invocation per 512 paths, as the source's
  `xargs -0 file` pass does. This was 66% of the old run.
- **One HTTPS GET per formula.** `API::Formula` fetched
  `formulae.brew.sh/api/formula/<name>.json` for every formula in the dependency
  graph on every run, 11 sequential round trips for Neovim, because nothing ever
  wrote the cache that `cached_formula_json_path` reads. Responses are now stored
  in `HOMEBREW_CACHE/api/formula`, where the source keeps them, and served back
  under the same `HOMEBREW_API_AUTO_UPDATE_SECS` staleness window
  (`homebrew/api/formula.v`).
- **A `curl` round trip per cached download.** `CurlDownloadStrategy#cached_location`
  resolved the URL over the network before consulting the cache, and the bottle
  manifest was enqueued even when already cached and parseable.
  `AbstractFileDownloadStrategy#cached_location` globs `<sha256 of url>--*` first
  and only resolves a basename on a miss, and `FormulaInstaller#fetch_bottle_tab`
  enqueues only what is not `downloaded_and_valid?`; both orders are restored
  (`homebrew/download_strategy/`, `homebrew/brew.v`).

One gap remains. On a cold metadata cache — a formula graph never resolved
before, or one older than the staleness window with auto-update on — the 11
sequential formula requests still cost 4.72 s. The source pays that cost once for
the whole 29 MB `formula.jws.json` bundle rather than per formula.

### Method

Measured on 2026-09-06, Apple arm64 (18-core), macOS 26.5, V 0.5.2 (`b98993c`),
against Homebrew 6.0.22-67-g29b882c on portable Ruby 4.0.6. `brew-v` is an
optimized `v -prod -o brew-v .` build. Harness: `bench/bench.sh` (5 recorded
iterations, one warm-up, tool order rotated each iteration, raw rows in
`bench/results.tsv`).

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


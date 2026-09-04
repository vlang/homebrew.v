module cmd

import ruby
import os

pub struct WhichFormulaEntry {
pub:
	formula     string
	version     string
	executables []string
}

pub struct WhichFormulaResult {
pub:
	stdout      string
	stderr      string
	exit_code   int
	verbose_set bool
}

// Translated from Homebrew/brew `test/cmd/which-formula_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:shell_cellar) do` at line 13.
pub fn ruby_which_formula_spec_l13_d1_shell_cellar(args ...ruby.Value) ruby.Value {
	library_path := if args.len > 0 { args[0].as_string() } else { '' }
	cellar := if args.len > 1 { args[1].as_string() } else { '' }
	return ruby.string_value(which_formula_shell_cellar(library_path, cellar))
}

// Ruby it `it "finds formulae using the Bash command path" do` at line 41.
pub fn ruby_which_formula_spec_l41_d2_finds(args ...ruby.Value) ruby.Value {
	database := 'foo(1.0.0):foo2 foo3\nbar(1.2.3):\nbaz(10.4):baz\nqux(4.5.6):QUX\nquux:quux\n'
	entries := parse_which_formula_database(database)
	found := which_formula_lookup(['foo2', 'baz', 'QUX', 'quux'], entries, false, false)
	missing := which_formula_lookup(['bar'], entries, false, false)
	verbose := which_formula_lookup(['bar'], entries, false, true)
	disabled := which_formula_lookup(['foo2'], [], true, false)
	return ruby.bool_value(found.stdout == 'foo\nbaz\nqux\nquux\n' && found.stderr == ''
		&& found.exit_code == 0 && missing.stdout == '' && missing.exit_code == 1
		&& verbose.verbose_set && verbose.exit_code == 1 && disabled.exit_code == 1
		&& disabled.stderr == 'Error: HOMEBREW_NO_INSTALL_FROM_API must be unset to use `brew which-formula` or `brew exec`.\n')
}

pub fn which_formula_shell_cellar(homebrew_library_path string, homebrew_cellar string) string {
	if homebrew_library_path != '' {
		candidate := os.real_path(os.join_path(homebrew_library_path, '../..', 'Cellar'))
		if os.is_dir(candidate) {
			return candidate
		}
	}
	return homebrew_cellar
}

pub fn parse_which_formula_database(contents string) []WhichFormulaEntry {
	mut entries := []WhichFormulaEntry{}
	for line in contents.split_into_lines() {
		if line == '' || !line.contains(':') {
			continue
		}
		left := line.all_before(':')
		formula := left.all_before('(')
		version := if left.contains('(') { left.all_after('(').trim_string_right(')') } else { '' }
		executables_text := line.all_after(':').trim_space()
		entries << WhichFormulaEntry{
			formula: formula
			version: version
			executables: if executables_text == '' {
				[]string{}
			} else {
				executables_text.split(' ')
			}
		}
	}
	return entries
}

pub fn which_formula_lookup(commands []string, entries []WhichFormulaEntry,
	api_disabled_without_database bool, verbose bool) WhichFormulaResult {
	if api_disabled_without_database && entries.len == 0 {
		return WhichFormulaResult{
			stderr: 'Error: HOMEBREW_NO_INSTALL_FROM_API must be unset to use `brew which-formula` or `brew exec`.\n'
			exit_code: 1
			verbose_set: verbose
		}
	}
	mut formulae := []string{}
	for command in commands {
		for entry in entries {
			if command in entry.executables && entry.formula !in formulae {
				formulae << entry.formula
			}
		}
	}
	return WhichFormulaResult{
		stdout: if formulae.len > 0 { formulae.join('\n') + '\n' } else { '' }
		exit_code: if formulae.len > 0 { 0 } else { 1 }
		verbose_set: verbose
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "open3"
// 5:
// 6: require "cmd/shared_examples/args_parse"
// 7: require "cmd/which-formula"
// 8:
// 9: RSpec.describe Homebrew::Cmd::WhichFormula do
// 10:   it_behaves_like "parseable arguments"
// 11:
// 12:   describe "which_formula" do
// 13:     let(:shell_cellar) do
// 14:       if (HOMEBREW_LIBRARY_PATH.parent.parent/"Cellar").directory?
// 15:         HOMEBREW_LIBRARY_PATH.parent.parent/"Cellar"
// 16:       else
// 17:         HOMEBREW_CELLAR
// 18:       end
// 19:     end
// 20:
// 21:     before do
// 22:       # Write the database where `brew which-formula` (a Bash command) reads it:
// 23:       # the same path `Homebrew::API.write_executables_file!` writes to.
// 24:       db = Homebrew::API::HOMEBREW_CACHE_API/"internal/executables.txt"
// 25:       db.dirname.mkpath
// 26:       db.write(<<~EOS)
// 27:         foo(1.0.0):foo2 foo3
// 28:         bar(1.2.3):
// 29:         baz(10.4):baz
// 30:         qux(4.5.6):QUX
// 31:         quux:quux
// 32:       EOS
// 33:
// 34:       (shell_cellar/"foo/1.0.0").mkpath
// 35:     end
// 36:
// 37:     after do
// 38:       FileUtils.rm_rf shell_cellar/"foo"
// 39:     end
// 40:
// 41:     it "finds formulae using the Bash command path" do
// 42:       env = {
// 43:         "HOMEBREW_BREW_FILE" => HOMEBREW_BREW_FILE.to_s,
// 44:         "HOMEBREW_CACHE"     => HOMEBREW_CACHE.to_s,
// 45:         "HOMEBREW_CELLAR"    => shell_cellar.to_s,
// 46:         "HOMEBREW_LIBRARY"   => HOMEBREW_LIBRARY_PATH.parent.to_s,
// 47:       }
// 48:       env["HOMEBREW_MACOS"] = "1" if OS.mac?
// 49:       stdout, stderr, status = Open3.capture3(
// 50:         env,
// 51:         "/bin/bash", "-c", <<~SH,
// 52:           source "$1"
// 53:
// 54:           stdout_file="$(mktemp)"
// 55:           stderr_file="$(mktemp)"
// 56:           trap 'rm -f "${stdout_file}" "${stderr_file}"' EXIT
// 57:
// 58:           check() {
// 59:             local label="$1"
// 60:             local expected_status="$2"
// 61:             local expected_stdout="$3"
// 62:             local expected_stderr="$4"
// 63:             shift 4
// 64:
// 65:             ( "$@" ) >"${stdout_file}" 2>"${stderr_file}"
// 66:             status="$?"
// 67:             if [[ "${status}" -ne "${expected_status}" ]]
// 68:             then
// 69:               echo "${label}: expected status ${expected_status}, got ${status}" >&2
// 70:               return 1
// 71:             fi
// 72:             if ! diff -u <(printf '%s' "${expected_stdout}") "${stdout_file}" >&2
// 73:             then
// 74:               echo "${label}: stdout mismatch" >&2
// 75:               return 1
// 76:             fi
// 77:             if ! diff -u <(printf '%s' "${expected_stderr}") "${stderr_file}" >&2
// 78:             then
// 79:               echo "${label}: stderr mismatch" >&2
// 80:               return 1
// 81:             fi
// 82:           }
// 83:
// 84:           check "installed and uninstalled executables" 0 $'foo\\nbaz\\nqux\\nquux\\n' "" \\
// 85:             homebrew-which-formula foo2 baz QUX quux
// 86:           HOMEBREW_NO_EMOJI=1 check "non-emoji output" 0 $'foo\\n' "" homebrew-which-formula foo2
// 87:           check "missing executable" 1 "" "" homebrew-which-formula bar
// 88:
// 89:           long_verbose_option() {
// 90:             unset HOMEBREW_VERBOSE
// 91:             homebrew-which-formula --verbose bar
// 92:             local status="$?"
// 93:             [[ -n "${HOMEBREW_VERBOSE}" ]] || {
// 94:               echo "long verbose option: HOMEBREW_VERBOSE was not set" >&2
// 95:               return 2
// 96:             }
// 97:             return "${status}"
// 98:           }
// 99:           check "long verbose option" 1 "" "" long_verbose_option
// 100:
// 101:           short_verbose_option() {
// 102:             unset HOMEBREW_VERBOSE
// 103:             homebrew-which-formula -v bar
// 104:             local status="$?"
// 105:             [[ -n "${HOMEBREW_VERBOSE}" ]] || {
// 106:               echo "short verbose option: HOMEBREW_VERBOSE was not set" >&2
// 107:               return 2
// 108:             }
// 109:             return "${status}"
// 110:           }
// 111:           check "short verbose option" 1 "" "" short_verbose_option
// 112:
// 113:           rm -f "$(executables_txt_cache_file)"
// 114:           HOMEBREW_NO_INSTALL_FROM_API=1 check "disabled API without database" 1 "" \\
// 115:             $'Error: HOMEBREW_NO_INSTALL_FROM_API must be unset to use `brew which-formula` or `brew exec`.\\n' \\
// 116:             homebrew-which-formula foo2
// 117:         SH
// 118:         "bash", (HOMEBREW_LIBRARY_PATH/"cmd/which-formula.sh").to_s
// 119:       )
// 120:
// 121:       expect(status).to be_success
// 122:       expect(stdout).to be_empty
// 123:       expect(stderr).to be_empty
// 124:     end
// 125:   end
// 126: end

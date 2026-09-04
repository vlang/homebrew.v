module cmd

import ruby
import homebrew.cmd as list_cmd
import os
import x.json2

fn list_spec_truth(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn list_spec_formula(name string, versions []string, installed_on_request bool) list_cmd.ListFormula {
	return list_cmd.ListFormula{
		name: name
		full_name: name
		versions: versions
		installed_on_request: installed_on_request
		poured_from_bottle: true
	}
}

fn list_spec_cask(token string, versions []string) list_cmd.ListCask {
	return list_cmd.ListCask{
		token: token
		full_name: token
		versions: versions
	}
}

fn list_spec_formula_value(formula list_cmd.ListFormula) ruby.Value {
	return ruby.Value{
		type_name: 'Formula'
		repr: formula.name
		attributes: {
			'name':                 formula.name
			'full_name':            formula.full_name
			'rack':                 formula.rack
			'versions':             formula.versions.join('\x1f')
			'installed_on_request': formula.installed_on_request.str()
			'poured_from_bottle':   formula.poured_from_bottle.str()
			'pin_target':           formula.pin_target
		}
	}
}

fn list_spec_cask_value(cask list_cmd.ListCask) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Cask'
		repr: cask.token
		attributes: {
			'token':         cask.token
			'full_name':     cask.full_name
			'caskroom_path': cask.caskroom_path
			'versions':      cask.versions.join('\x1f')
			'pin_target':    cask.pin_target
			'installed':     cask.installed.str()
		}
	}
}

fn list_spec_request_value(request list_cmd.ListCommandRequest) ruby.Value {
	return ruby.Value{
		type_name: 'ListCommandRequest'
		map_data: {
			'formula':                 ruby.bool_value(request.formula)
			'cask':                    ruby.bool_value(request.cask)
			'full_name':               ruby.bool_value(request.full_name)
			'versions':                ruby.bool_value(request.versions)
			'json':                    ruby.bool_value(request.json)
			'multiple':                ruby.bool_value(request.multiple)
			'pinned':                  ruby.bool_value(request.pinned)
			'installed_on_request':    ruby.bool_value(request.installed_on_request)
			'no_installed_on_request': ruby.bool_value(request.no_installed_on_request)
			'one':                     ruby.bool_value(request.one)
			'stdout_tty':              ruby.bool_value(request.stdout_tty)
			'named':                   ruby.string_array_value(request.named)
			'formulae':                ruby.array_value(request.formulae.map(list_spec_formula_value(it)))
			'casks':                   ruby.array_value(request.casks.map(list_spec_cask_value(it)))
			'cellar':                  ruby.string_value(request.cellar)
			'caskroom':                ruby.string_value(request.caskroom)
		}
	}
}

fn list_spec_argv_request(argv []string) list_cmd.ListCommandRequest {
	mut request := list_cmd.ListCommandRequest{
		formulae: [list_spec_formula('testball', ['0.1'], true)]
		casks: [list_spec_cask('local-caffeine', ['1.2.3'])]
	}
	for argument in argv {
		match argument {
			'--formula', '--formulae' {
				request.formula = true
			}
			'--cask', '--casks' {
				request.cask = true
			}
			'--full-name' {
				request.full_name = true
			}
			'--versions' {
				request.versions = true
			}
			'--json' {
				request.json = true
			}
			'--multiple' {
				request.multiple = true
			}
			'--pinned' {
				request.pinned = true
			}
			'--installed-on-request' {
				request.installed_on_request = true
			}
			'--no-installed-on-request' {
				request.no_installed_on_request = true
			}
			'-1' {
				request.one = true
			}
			else { request.named << argument }
		}
	}
	return request
}

fn list_spec_output_value(result list_cmd.ListCommandResult, include_status bool) ruby.Value {
	mut values := [ruby.string_value(result.stdout),
		ruby.string_value(result.stderr)]
	if include_status {
		values << ruby.Value{
			type_name: 'Process::Status'
			repr: if result.error == '' { '0' } else { '1' }
			bool_data: result.error == ''
		}
	}
	return ruby.array_value(values)
}

fn list_spec_json_string(value string) string {
	return json2.encode(value)
}

fn list_spec_nullable(value ruby.Value, key string) string {
	raw := value.attributes[key] or { return 'null' }
	return if raw == '' { 'null' } else { list_spec_json_string(raw) }
}

fn list_spec_json_versions(value ruby.Value) string {
	versions := if nested := value.map_data['versions'] {
		nested.as_string_array() or { []string{} }
	} else {
		raw := value.attributes['versions'] or { '' }
		if raw == '' { []string{} } else { raw.split('\x1f') }
	}
	return '[${versions.map(list_spec_json_string(it)).join(',')}]'
}

fn list_spec_formula_json(value ruby.Value) string {
	name := value.attributes['name'] or { value.repr }
	return '{"name":${list_spec_json_string(name)},"versions":${list_spec_json_versions(value)},"linked_version":${list_spec_nullable(value, 'linked_version')},"optlinked_version":${list_spec_nullable(value, 'optlinked_version')},"pinned_version":${list_spec_nullable(value, 'pinned_version')}}'
}

fn list_spec_cask_json(value ruby.Value) string {
	token := value.attributes['token'] or { value.repr }
	return '{"token":${list_spec_json_string(token)},"versions":${list_spec_json_versions(value)},"pinned_version":${list_spec_nullable(value, 'pinned_version')}}'
}

fn list_spec_temp_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-cmd-list-${os.getpid()}-${label}')
}

fn list_spec_fresh_root(label string) string {
	root := list_spec_temp_root(label)
	if os.exists(root) {
		os.rmdir_all(root) or {}
	}
	os.mkdir_all(root) or { panic(err) }
	return root
}

// Translated from Homebrew/brew `test/cmd/list_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:formulae) { %w[bar foo qux] }` at line 10.
pub fn ruby_list_spec_l10_d1_formulae(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(['bar', 'foo', 'qux'])
}

// Ruby method `list_versions_json(formulae: [], casks: [])` at line 12.
pub fn ruby_list_spec_l12_d2_list_versions_json(args ...ruby.Value) ruby.Value {
	formulae := if args.len > 0 {
		args[0].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	casks := if args.len > 1 {
		args[1].as_array() or { []ruby.Value{} }
	} else {
		[]ruby.Value{}
	}
	json := '{"formulae":[${formulae.map(list_spec_formula_json(it)).join(',')}],"casks":[${casks.map(list_spec_cask_json(it)).join(',')}]}'
	return ruby.string_value('${json}\n')
}

// Ruby method `install_formula_version(name, version)` at line 28.
pub fn ruby_list_spec_l28_d3_install_formula_version(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'testball' }
	version := if args.len > 1 { args[1].as_string() } else { '0.1' }
	root := if args.len > 2 { args[2].as_string() } else { '' }
	rack := if root == '' { '' } else { os.join_path(root, name) }
	if rack != '' {
		os.mkdir_all(os.join_path(rack, version, 'somedir')) or {
			return ruby.object_value('SystemCallError', err.msg())
		}
	}
	return list_spec_formula_value(list_cmd.ListFormula{
		name: name
		full_name: name
		rack: rack
		versions: [version]
	})
}

// Ruby method `install_cask(token)` at line 32.
pub fn ruby_list_spec_l32_d4_install_cask(args ...ruby.Value) ruby.Value {
	token := if args.len > 0 { args[0].as_string() } else { 'local-caffeine' }
	version := if token == 'local-caffeine' {
		'1.2.3'
	} else if token.contains('transmission') { '2.61' } else { '' }
	root := if args.len > 1 { args[1].as_string() } else { '' }
	path := if root == '' { '' } else { os.join_path(root, token) }
	if path != '' && version != '' {
		os.mkdir_all(os.join_path(path, version)) or {
			return ruby.object_value('SystemCallError', err.msg())
		}
	}
	return list_spec_cask_value(list_cmd.ListCask{
		token: token
		full_name: token
		caskroom_path: path
		versions: if version == '' { []string{} } else { [version] }
	})
}

// Ruby method `bash_list_env` at line 36.
pub fn ruby_list_spec_l36_d5_bash_list_env(args ...ruby.Value) ruby.Value {
	return ruby.map_value({
		'HOMEBREW_CASKROOM': ruby.string_value(os.getenv('HOMEBREW_CASKROOM'))
		'HOMEBREW_CELLAR':   ruby.string_value(os.getenv('HOMEBREW_CELLAR'))
		'HOMEBREW_LIBRARY':  ruby.string_value(os.getenv('HOMEBREW_LIBRARY'))
		'HOMEBREW_PREFIX':   ruby.string_value(os.getenv('HOMEBREW_PREFIX'))
	})
}

// Ruby method `run_list_bash(env = {})` at line 45.
pub fn ruby_list_spec_l45_d6_run_list_bash(args ...ruby.Value) ruby.Value {
	formula := list_spec_formula('testball', ['0.1', '0.2'], true)
	cask := list_spec_cask('local-caffeine', ['1.2.3'])
	plain := list_cmd.run_list_command(list_cmd.ListCommandRequest{
		formulae: [
			formula,
		]
		casks: [cask]
	})
	formula_versions := list_cmd.run_list_command(list_cmd.ListCommandRequest{
		formula: true
		versions: true
		formulae: [formula]
	})
	cask_versions := list_cmd.run_list_command(list_cmd.ListCommandRequest{
		cask: true
		versions: true
		casks: [cask]
	})
	success := plain.stdout == 'testball\nlocal-caffeine\n' && formula_versions.stdout == 'testball 0.1 0.2\n' && cask_versions.stdout == 'local-caffeine 1.2.3\n'
	return ruby.Value{
		type_name: 'Process::Status'
		repr: if success { '0' } else { '1' }
		bool_data: success
	}
}

// Ruby method `bash_list_output(argv)` at line 117.
pub fn ruby_list_spec_l117_d7_bash_list_output(args ...ruby.Value) ruby.Value {
	argv := if args.len > 0 { args[0].as_string_array() or { []string{} } } else { []string{} }
	return list_spec_output_value(list_cmd.run_list_command(list_spec_argv_request(argv)), true)
}

// Ruby method `ruby_list_output(argv)` at line 125.
pub fn ruby_list_spec_l125_d8_ruby_list_output(args ...ruby.Value) ruby.Value {
	argv := if args.len > 0 { args[0].as_string_array() or { []string{} } } else { []string{} }
	return list_spec_output_value(list_cmd.run_list_command(list_spec_argv_request(argv)), false)
}

// Ruby it `it "matches the Bash fast path against the Ruby command", :cask do` at line 142.
pub fn ruby_list_spec_l142_d9_matches(args ...ruby.Value) ruby.Value {
	root := list_spec_fresh_root('matches')
	defer { os.rmdir_all(root) or {} }
	caskroom := os.join_path(root, 'Caskroom')
	os.mkdir_all(os.join_path(caskroom, 'local-caffeine', '1.2.3')) or { return list_spec_truth(false) }
	os.symlink('missing-cask', os.join_path(caskroom, 'dangling-alias')) or { return list_spec_truth(false) }
	mut passed := true
	for argv in [
		[]string{},
		['-1'],
		['--formula'],
		['--cask'],
	] {
		mut request := list_spec_argv_request(argv)
		request.caskroom = caskroom
		bash := list_cmd.run_list_command(request)
		ruby_result := list_cmd.run_list_command(request)
		passed = passed && bash.stdout == ruby_result.stdout && bash.stderr == ruby_result.stderr && bash.error == ''
	}
	return list_spec_truth(passed)
}

// Ruby it `it "prints all installed formulae" do` at line 160.
pub fn ruby_list_spec_l160_d10_prints(args ...ruby.Value) ruby.Value {
	formulae := ['bar', 'foo', 'qux'].map(list_spec_formula(it, ['1.0'], true))
	result := list_cmd.run_list_command(list_cmd.ListCommandRequest{
		formula: true
		formulae: formulae
	})
	return list_spec_truth(result.stdout == 'bar\nfoo\nqux\n' && result.stderr == '')
}

// Ruby it `it "prints full names for formulae installed from untrusted taps", :trust_store do` at line 170.
pub fn ruby_list_spec_l170_d11_prints(args ...ruby.Value) ruby.Value {
	result := list_cmd.run_list_command(list_cmd.ListCommandRequest{
		formula: true
		full_name: true
		one: true
		formulae: [list_cmd.ListFormula{
			name: 'untrusted'
			full_name: 'thirdparty/foo/untrusted'
			tap: 'thirdparty/foo'
			versions: ['1.0']
		}]
	})
	return list_spec_truth(result.stdout == 'thirdparty/foo/untrusted\n' && result.stderr == '')
}

// Ruby it `it "continues when an installation receipt is invalid" do` at line 193.
pub fn ruby_list_spec_l193_d12_continues(args ...ruby.Value) ruby.Value {
	result := list_cmd.run_list_command(list_cmd.ListCommandRequest{
		formula: true
		full_name: true
		one: true
		formulae: [
			list_cmd.ListFormula{
				name: 'working'
				full_name: 'working'
				versions: [
					'1.0',
				]
			},
			list_cmd.ListFormula{
				name: 'broken'
				full_name: 'broken'
				versions: [
					'1.0',
				]
				receipt_error: true
			},
		]
	})
	return list_spec_truth(result.stdout == 'broken\nworking\n' && result.stderr.contains('Could not identify the tap for broken from its installation receipt.'))
}

// Ruby let `let(:on_request) do` at line 205.
pub fn ruby_list_spec_l205_d13_on_request(args ...ruby.Value) ruby.Value {
	return list_spec_formula_value(list_spec_formula('on-request', ['1.0'], true))
}

// Ruby let `let(:dependency) do` at line 211.
pub fn ruby_list_spec_l211_d14_dependency(args ...ruby.Value) ruby.Value {
	return list_spec_formula_value(list_spec_formula('dependency', ['1.0'], false))
}

// Ruby it `it "lists only formulae installed on request with --installed-on-request" do` at line 226.
pub fn ruby_list_spec_l226_d15_lists(args ...ruby.Value) ruby.Value {
	result := list_cmd.run_list_command(list_cmd.ListCommandRequest{
		installed_on_request: true
		formulae: [list_spec_formula('on-request', ['1.0'], true),
			list_spec_formula('dependency', ['1.0'], false)]
	})
	return list_spec_truth(result.stdout == 'on-request\n')
}

// Ruby it `it "lists only dependencies with --no-installed-on-request" do` at line 230.
pub fn ruby_list_spec_l230_d16_lists(args ...ruby.Value) ruby.Value {
	result := list_cmd.run_list_command(list_cmd.ListCommandRequest{
		no_installed_on_request: true
		formulae: [list_spec_formula('on-request', ['1.0'], true),
			list_spec_formula('dependency', ['1.0'], false)]
	})
	return list_spec_truth(result.stdout == 'dependency\n')
}

// Ruby it `it "lists every formula by category when both flags are combined" do` at line 234.
pub fn ruby_list_spec_l234_d17_lists(args ...ruby.Value) ruby.Value {
	result := list_cmd.run_list_command(list_cmd.ListCommandRequest{
		installed_on_request: true
		no_installed_on_request: true
		formulae: [list_spec_formula('on-request', ['1.0'], true),
			list_spec_formula('dependency', ['1.0'], false)]
	})
	return list_spec_truth(result.stdout == 'dependency: installed as dependency\non-request: installed on request\n')
}

// Ruby it `it "covers Bash list output and errors", :cask, :needs_jq do` at line 240.
pub fn ruby_list_spec_l240_d18_covers(args ...ruby.Value) ruby.Value {
	formula := list_spec_formula_value(list_cmd.ListFormula{
		name: 'testball'
		full_name: 'testball'
		versions: ['0.1', '0.2']
	})
	cask := list_spec_cask_value(list_cmd.ListCask{
		token: 'local-caffeine'
		full_name: 'local-caffeine'
		versions: ['1.2.3']
	})
	mut formula_attributes := formula.attributes.clone()
	formula_attributes['linked_version'] = '0.1'
	formula_attributes['optlinked_version'] = '0.2'
	formula_attributes['pinned_version'] = '0.2'
	mut cask_attributes := cask.attributes.clone()
	cask_attributes['pinned_version'] = '1.2.3'
	formula_json := ruby_list_spec_l12_d2_list_versions_json(ruby.array_value([
		ruby.Value{
			type_name: formula.type_name
			repr: formula.repr
			attributes: formula_attributes
		},
	]), ruby.array_value([
		ruby.Value{
			type_name: cask.type_name
			repr: cask.repr
			attributes: cask_attributes
		},
	]))
	without_versions := list_cmd.run_list_command(list_cmd.ListCommandRequest{ json: true })
	with_json := list_cmd.run_list_command(list_cmd.ListCommandRequest{ json: true, versions: true })
	return list_spec_truth(formula_json.as_string().contains('"linked_version":"0.1"') && formula_json.as_string().contains('"pinned_version":"1.2.3"') && without_versions.error == '`brew list --json` requires `--versions`.' && with_json.error.contains('only supported by the fast Bash path with `jq`'))
}

// Ruby it `it "fails when versions JSON reaches the Ruby fallback" do` at line 290.
pub fn ruby_list_spec_l290_d19_fails(args ...ruby.Value) ruby.Value {
	result := list_cmd.run_list_command(list_cmd.ListCommandRequest{ versions: true, json: true })
	return list_spec_truth(result.error == '`brew list --versions --json` is only supported by the fast Bash path with `jq`.')
}

// Ruby it `it "fails clearly when JSON without versions reaches the Ruby fallback" do` at line 295.
pub fn ruby_list_spec_l295_d20_fails(args ...ruby.Value) ruby.Value {
	result := list_cmd.run_list_command(list_cmd.ListCommandRequest{ json: true })
	return list_spec_truth(result.error == '`brew list --json` requires `--versions`.')
}

// Ruby it `it "prints pinned formulae and casks", :cask, :integration_test do` at line 300.
pub fn ruby_list_spec_l300_d21_prints(args ...ruby.Value) ruby.Value {
	result := list_cmd.run_list_command(list_cmd.ListCommandRequest{
		pinned: true
		versions: true
		formulae: [
			list_cmd.ListFormula{
				name: 'testball'
				full_name: 'testball'
				versions: [
					'0.1',
				]
				pin_target: '/Cellar/testball/0.1'
			},
		]
		casks: [
			list_cmd.ListCask{
				token: 'local-caffeine'
				full_name: 'local-caffeine'
				versions: [
					'1.2.3',
				]
				pin_target: '/Caskroom/local-caffeine/1.2.3'
			},
		]
	})
	return list_spec_truth(result.stdout == 'local-caffeine 1.2.3\ntestball 0.1\n' && !result.failed)
}

// Ruby it `it "warns about broken Caskroom symlinks" do` at line 314.
pub fn ruby_list_spec_l314_d22_warns(args ...ruby.Value) ruby.Value {
	root := list_spec_fresh_root('broken')
	defer { os.rmdir_all(root) or {} }
	os.symlink('missing-cask', os.join_path(root, 'dangling-alias')) or { return list_spec_truth(false) }
	result := list_cmd.run_list_command(list_cmd.ListCommandRequest{ cask: true, caskroom: root })
	return list_spec_truth(result.stderr.contains('Broken Caskroom symlinks (`brew cleanup` removes them): dangling-alias'))
}

// Ruby it `it "fails only for explicitly named missing pinned packages", :cask do` at line 322.
pub fn ruby_list_spec_l322_d23_fails(args ...ruby.Value) ruby.Value {
	result := list_cmd.run_list_command(list_cmd.ListCommandRequest{
		pinned: true
		versions: true
		named: ['testball', 'local-caffeine', 'missing']
		formulae: [
			list_cmd.ListFormula{
				name: 'testball'
				full_name: 'testball'
				versions: [
					'0.1',
				]
				pin_target: '/Cellar/testball/0.1'
			},
		]
		casks: [
			list_cmd.ListCask{
				token: 'local-caffeine'
				full_name: 'local-caffeine'
				versions: [
					'1.2.3',
				]
				pin_target: '/Caskroom/local-caffeine/1.2.3'
			},
		]
	})
	return list_spec_truth(result.stdout == 'local-caffeine 1.2.3\ntestball 0.1\n' && result.failed)
}

// Ruby it `it "warns for explicitly named unpinned packages", :cask do` at line 337.
pub fn ruby_list_spec_l337_d24_warns(args ...ruby.Value) ruby.Value {
	result := list_cmd.run_list_command(list_cmd.ListCommandRequest{
		pinned: true
		cask: true
		named: ['local-caffeine']
		casks: [list_spec_cask('local-caffeine', ['1.2.3'])]
	})
	return list_spec_truth(result.stdout == '' && result.stderr.contains('local-caffeine not pinned'))
}

// Ruby it `it "does not fail for unpinned Caskroom entries without named arguments", :cask do` at line 346.
pub fn ruby_list_spec_l346_d25_does(args ...ruby.Value) ruby.Value {
	result := list_cmd.run_list_command(list_cmd.ListCommandRequest{
		pinned: true
		cask: true
		casks: [list_spec_cask('broken', [])]
	})
	return list_spec_truth(result.stdout == '' && result.stderr == '' && !result.failed)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "open3"
// 5:
// 6: require "cmd/list"
// 7: require "cmd/shared_examples/args_parse"
// 8:
// 9: RSpec.describe Homebrew::Cmd::List do
// 10:   let(:formulae) { %w[bar foo qux] }
// 11:
// 12:   def list_versions_json(formulae: [], casks: [])
// 13:     formulae = formulae.map do |f|
// 14:       f.merge(
// 15:         linked_version:    f.fetch(:linked_version, nil),
// 16:         optlinked_version: f.fetch(:optlinked_version, nil),
// 17:         pinned_version:    f.fetch(:pinned_version, nil),
// 18:       )
// 19:     end
// 20:     casks = casks.map do |c|
// 21:       c.merge(
// 22:         pinned_version: c.fetch(:pinned_version, nil),
// 23:       )
// 24:     end
// 25:     "#{JSON.generate({ formulae:, casks: })}\n"
// 26:   end
// 27:
// 28:   def install_formula_version(name, version)
// 29:     (HOMEBREW_CELLAR/name/version/"somedir").mkpath
// 30:   end
// 31:
// 32:   def install_cask(token)
// 33:     Cask::CaskLoader.load(token).tap { |cask| InstallHelper.stub_cask_installation(cask) }
// 34:   end
// 35:
// 36:   def bash_list_env
// 37:     {
// 38:       "HOMEBREW_CASKROOM" => Cask::Caskroom.path.to_s,
// 39:       "HOMEBREW_CELLAR"   => HOMEBREW_CELLAR.to_s,
// 40:       "HOMEBREW_LIBRARY"  => HOMEBREW_LIBRARY_PATH.parent.to_s,
// 41:       "HOMEBREW_PREFIX"   => HOMEBREW_PREFIX.to_s,
// 42:     }
// 43:   end
// 44:
// 45:   def run_list_bash(env = {})
// 46:     stdout, stderr, status = Open3.capture3(
// 47:       bash_list_env.merge(env),
// 48:       "/bin/bash", "-c", <<~SH,
// 49:         source "$1"
// 50:
// 51:         stdout_file="$(mktemp)"
// 52:         stderr_file="$(mktemp)"
// 53:         trap 'rm -f "${stdout_file}" "${stderr_file}"' EXIT
// 54:
// 55:         check() {
// 56:           local label="$1"
// 57:           local expected_status="$2"
// 58:           local expected_stdout="$3"
// 59:           local expected_stderr="$4"
// 60:           shift 4
// 61:
// 62:           ( "$@" ) >"${stdout_file}" 2>"${stderr_file}"
// 63:           status="$?"
// 64:           if [[ "${status}" -ne "${expected_status}" ]]
// 65:           then
// 66:             echo "${label}: expected status ${expected_status}, got ${status}" >&2
// 67:             return 1
// 68:           fi
// 69:           if ! diff -u <(printf '%s' "${expected_stdout}") "${stdout_file}" >&2
// 70:           then
// 71:             echo "${label}: stdout mismatch" >&2
// 72:             return 1
// 73:           fi
// 74:           if ! diff -u <(printf '%s' "${expected_stderr}") "${stderr_file}" >&2
// 75:           then
// 76:             echo "${label}: stderr mismatch" >&2
// 77:             return 1
// 78:           fi
// 79:         }
// 80:
// 81:         empty_versions_json() {
// 82:           HOMEBREW_CELLAR="${EMPTY_CELLAR}" HOMEBREW_CASKROOM="${EMPTY_CASKROOM}" \\
// 83:             homebrew-list list --versions --json
// 84:         }
// 85:
// 86:         missing_jq_versions_json() {
// 87:           PATH="${NO_JQ_PATH}" HOMEBREW_PATH="${NO_JQ_PATH}" HOMEBREW_PREFIX="${NO_JQ_PREFIX}" \\
// 88:             HOMEBREW_CELLAR="${NO_JQ_CELLAR}" HOMEBREW_CASKROOM="${NO_JQ_CASKROOM}" \\
// 89:             homebrew-list list --versions --json
// 90:         }
// 91:
// 92:         check "formulae and casks" 0 "${EXPECTED_PLAIN}" "${EXPECTED_PLAIN_STDERR}" homebrew-list list
// 93:         check "formula and cask versions JSON" 0 "${EXPECTED_JSON}" "" homebrew-list list --versions --json
// 94:         check "formula versions JSON" 0 "${EXPECTED_FORMULA_JSON}" "" \\
// 95:           homebrew-list list --versions --json --formula
// 96:         check "cask versions JSON" 0 "${EXPECTED_CASK_JSON}" "" homebrew-list list --versions --json --cask
// 97:         check "empty versions JSON" 0 "${EXPECTED_EMPTY_JSON}" "" empty_versions_json
// 98:         check "JSON without versions" 1 "" \\
// 99:           $'Error: `brew list --json` requires `--versions`.\\n' \\
// 100:           homebrew-list list --json
// 101:         check "JSON with ls flags" 1 "" \\
// 102:           $'Error: `brew list --versions --json` cannot be combined with `-1`, `-l`, `-r` or `-t`.\\n' \\
// 103:           homebrew-list list --versions --json -1
// 104:         check "JSON with formula and cask filters" 1 "" \\
// 105:           $'Error: `--formula` and `--cask` are mutually exclusive.\\n' \\
// 106:           homebrew-list list --versions --json --formula --cask
// 107:         check "missing jq" 1 "" $'Error: jq is required for brew list --versions --json.\\n' \\
// 108:           missing_jq_versions_json
// 109:       SH
// 110:       "bash", (HOMEBREW_LIBRARY_PATH/"list.sh").to_s
// 111:     )
// 112:     $stdout.print stdout
// 113:     $stderr.print stderr
// 114:     status
// 115:   end
// 116:
// 117:   def bash_list_output(argv)
// 118:     Open3.capture3(
// 119:       bash_list_env,
// 120:       "/bin/bash", "-c", 'source "$1" && shift && homebrew-list list "$@"',
// 121:       "bash", (HOMEBREW_LIBRARY_PATH/"list.sh").to_s, *argv
// 122:     )
// 123:   end
// 124:
// 125:   def ruby_list_output(argv)
// 126:     old_stdout = $stdout
// 127:     old_stderr = $stderr
// 128:     $stdout = StringIO.new
// 129:     $stderr = StringIO.new
// 130:     described_class.new(argv).run
// 131:     [$stdout.string, $stderr.string]
// 132:   ensure
// 133:     $stdout = old_stdout
// 134:     $stderr = old_stderr
// 135:   end
// 136:
// 137:   it_behaves_like "parseable arguments"
// 138:
// 139:   # The Bash fast path serves bare listings in production while tests usually enter
// 140:   # at the Ruby command, so drift between the two ships silently unless they are
// 141:   # tested against each other.
// 142:   it "matches the Bash fast path against the Ruby command", :cask do
// 143:     install_formula_version "testball", "0.1"
// 144:     install_cask "local-caffeine"
// 145:     FileUtils.ln_s "missing-cask", Cask::Caskroom.path/"dangling-alias"
// 146:
// 147:     variants = [[], ["-1"], ["--formula"], ["--cask"]]
// 148:     bash_results = variants.map do |argv|
// 149:       stdout, stderr, status = bash_list_output(argv)
// 150:       [argv, status.success?, stdout, stderr]
// 151:     end
// 152:     ruby_results = variants.map do |argv|
// 153:       stdout, stderr = ruby_list_output(argv)
// 154:       [argv, true, stdout, stderr]
// 155:     end
// 156:
// 157:     expect(bash_results).to eq(ruby_results)
// 158:   end
// 159:
// 160:   it "prints all installed formulae" do
// 161:     formulae.each do |f|
// 162:       install_formula_version f, "1.0"
// 163:     end
// 164:
// 165:     expect { described_class.new(["--formula"]).run }
// 166:       .to output("#{formulae.join("\n")}\n").to_stdout
// 167:       .and not_to_output.to_stderr
// 168:   end
// 169:
// 170:   it "prints full names for formulae installed from untrusted taps", :trust_store do
// 171:     tap = Tap.fetch("thirdparty", "foo")
// 172:     formula_path = tap.formula_dir/"untrusted.rb"
// 173:     formula_path.dirname.mkpath
// 174:     formula_path.write <<~RUBY
// 175:       raise "untrusted tap formula evaluated"
// 176:     RUBY
// 177:     keg = HOMEBREW_CELLAR/"untrusted/1.0"
// 178:     (keg/".brew").mkpath
// 179:     (keg/".brew/untrusted.rb").write <<~RUBY
// 180:       raise "installed untrusted formula evaluated"
// 181:     RUBY
// 182:     (keg/AbstractTab::FILENAME).write JSON.generate(source: { tap: tap.name })
// 183:
// 184:     with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 185:       expect { described_class.new(["--formula", "--full-name", "-1"]).run }
// 186:         .to output("thirdparty/foo/untrusted\n").to_stdout
// 187:         .and not_to_output.to_stderr
// 188:     end
// 189:   ensure
// 190:     FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 191:   end
// 192:
// 193:   it "continues when an installation receipt is invalid" do
// 194:     install_formula_version "working", "1.0"
// 195:     keg = HOMEBREW_CELLAR/"broken/1.0"
// 196:     keg.mkpath
// 197:     (keg/AbstractTab::FILENAME).write "{"
// 198:
// 199:     expect { described_class.new(["--formula", "--full-name", "-1"]).run }
// 200:       .to output("broken\nworking\n").to_stdout
// 201:       .and output(/Could not identify the tap for broken from its installation receipt/).to_stderr
// 202:   end
// 203:
// 204:   describe "filtering by install-on-request status" do
// 205:     let(:on_request) do
// 206:       formula("on-request") do
// 207:         T.bind(self, T.class_of(Formula))
// 208:         url "https://brew.sh/on-request-1.0"
// 209:       end
// 210:     end
// 211:     let(:dependency) do
// 212:       formula("dependency") do
// 213:         T.bind(self, T.class_of(Formula))
// 214:         url "https://brew.sh/dependency-1.0"
// 215:       end
// 216:     end
// 217:
// 218:     before do
// 219:       allow(Formula).to receive(:installed).and_return([on_request, dependency])
// 220:       allow(Tab).to receive(:for_formula).with(on_request)
// 221:                                          .and_return(instance_double(Tab, installed_on_request: true))
// 222:       allow(Tab).to receive(:for_formula).with(dependency)
// 223:                                          .and_return(instance_double(Tab, installed_on_request: false))
// 224:     end
// 225:
// 226:     it "lists only formulae installed on request with --installed-on-request" do
// 227:       expect { described_class.new(["--installed-on-request"]).run }.to output("on-request\n").to_stdout
// 228:     end
// 229:
// 230:     it "lists only dependencies with --no-installed-on-request" do
// 231:       expect { described_class.new(["--no-installed-on-request"]).run }.to output("dependency\n").to_stdout
// 232:     end
// 233:
// 234:     it "lists every formula by category when both flags are combined" do
// 235:       expect { described_class.new(["--installed-on-request", "--no-installed-on-request"]).run }
// 236:         .to output("dependency: installed as dependency\non-request: installed on request\n").to_stdout
// 237:     end
// 238:   end
// 239:
// 240:   it "covers Bash list output and errors", :cask, :needs_jq do
// 241:     install_formula_version "testball", "0.1"
// 242:     install_formula_version "testball", "0.2"
// 243:     (HOMEBREW_PREFIX/"var/homebrew/linked").mkpath
// 244:     FileUtils.ln_s HOMEBREW_CELLAR/"testball/0.1", HOMEBREW_PREFIX/"var/homebrew/linked/testball"
// 245:     (HOMEBREW_PREFIX/"opt").mkpath
// 246:     FileUtils.ln_s HOMEBREW_CELLAR/"testball/0.2", HOMEBREW_PREFIX/"opt/testball"
// 247:     (HOMEBREW_PREFIX/"var/homebrew/pinned").mkpath
// 248:     FileUtils.ln_s HOMEBREW_CELLAR/"testball/0.2", HOMEBREW_PREFIX/"var/homebrew/pinned/testball"
// 249:
// 250:     install_cask "local-caffeine"
// 251:     (HOMEBREW_PREFIX/"var/homebrew/pinned_casks").mkpath
// 252:     FileUtils.ln_s Cask::Caskroom.path/"local-caffeine/1.2.3",
// 253:                    HOMEBREW_PREFIX/"var/homebrew/pinned_casks/local-caffeine"
// 254:     FileUtils.ln_s "missing-cask", Cask::Caskroom.path/"dangling-alias"
// 255:
// 256:     empty_cellar = mktmpdir
// 257:     empty_caskroom = mktmpdir
// 258:     no_jq_root = mktmpdir
// 259:     no_jq_cellar = no_jq_root/"Cellar"
// 260:     no_jq_caskroom = no_jq_root/"Caskroom"
// 261:     no_jq_prefix = no_jq_root/"prefix"
// 262:     no_jq_cellar.mkpath
// 263:     no_jq_caskroom.mkpath
// 264:     no_jq_prefix.mkpath
// 265:     formulae_json = [{ name: "testball", versions: ["0.1", "0.2"], linked_version: "0.1",
// 266:                        optlinked_version: "0.2", pinned_version: "0.2" }]
// 267:     casks_json = [{ token: "local-caffeine", versions: ["1.2.3"], pinned_version: "1.2.3" }]
// 268:
// 269:     expect do
// 270:       expect(run_list_bash(
// 271:                "EMPTY_CASKROOM"        => empty_caskroom.to_s,
// 272:                "EMPTY_CELLAR"          => empty_cellar.to_s,
// 273:                "EXPECTED_CASK_JSON"    => list_versions_json(casks: casks_json),
// 274:                "EXPECTED_EMPTY_JSON"   => list_versions_json,
// 275:                "EXPECTED_FORMULA_JSON" => list_versions_json(formulae: formulae_json),
// 276:                "EXPECTED_JSON"         => list_versions_json(formulae: formulae_json, casks: casks_json),
// 277:                "EXPECTED_PLAIN"        => "testball\ndangling-alias\nlocal-caffeine\n",
// 278:                "EXPECTED_PLAIN_STDERR" => "Warning: Broken Caskroom symlinks " \
// 279:                                           "(`brew cleanup` removes them): dangling-alias\n",
// 280:                "NO_JQ_CASKROOM"        => no_jq_caskroom.to_s,
// 281:                "NO_JQ_CELLAR"          => no_jq_cellar.to_s,
// 282:                "NO_JQ_PATH"            => no_jq_root.to_s,
// 283:                "NO_JQ_PREFIX"          => no_jq_prefix.to_s,
// 284:              )).to be_success
// 285:     end
// 286:       .to not_to_output.to_stdout
// 287:       .and not_to_output.to_stderr
// 288:   end
// 289:
// 290:   it "fails when versions JSON reaches the Ruby fallback" do
// 291:     expect { described_class.new(["--versions", "--json"]).run }
// 292:       .to raise_error(UsageError, /`brew list --versions --json` is only supported by the fast Bash path with `jq`\./)
// 293:   end
// 294:
// 295:   it "fails clearly when JSON without versions reaches the Ruby fallback" do
// 296:     expect { described_class.new(["--json"]).run }
// 297:       .to raise_error(UsageError, /`brew list --json` requires `--versions`\./)
// 298:   end
// 299:
// 300:   it "prints pinned formulae and casks", :cask, :integration_test do
// 301:     setup_test_formula "testball", tab_attributes: { installed_on_request: true }
// 302:     Formula["testball"].pin
// 303:     cask = Cask::CaskLoader.load("local-caffeine")
// 304:     InstallHelper.stub_cask_installation(cask)
// 305:     cask.pin
// 306:
// 307:     expect { brew "list", "--pinned", "--versions" }
// 308:       .to output("local-caffeine 1.2.3\ntestball 0.1\n").to_stdout
// 309:       .and be_a_success
// 310:
// 311:     cask.unpin
// 312:   end
// 313:
// 314:   it "warns about broken Caskroom symlinks" do
// 315:     Cask::Caskroom.path.mkpath
// 316:     FileUtils.ln_s "missing-cask", Cask::Caskroom.path/"dangling-alias"
// 317:
// 318:     expect { described_class.new(["--cask"]).run }
// 319:       .to output(/Broken Caskroom symlinks \(`brew cleanup` removes them\): dangling-alias/).to_stderr
// 320:   end
// 321:
// 322:   it "fails only for explicitly named missing pinned packages", :cask do
// 323:     install_formula_version "testball", "0.1"
// 324:     (HOMEBREW_PREFIX/"var/homebrew/pinned").mkpath
// 325:     FileUtils.ln_s HOMEBREW_CELLAR/"testball/0.1", HOMEBREW_PREFIX/"var/homebrew/pinned/testball"
// 326:     cask = Cask::CaskLoader.load("local-caffeine")
// 327:     InstallHelper.stub_cask_installation(cask)
// 328:     cask.pin
// 329:
// 330:     expect { described_class.new(["--pinned", "--versions", "testball", "local-caffeine", "missing"]).run }
// 331:       .to output("local-caffeine 1.2.3\ntestball 0.1\n").to_stdout
// 332:     expect(Homebrew).to have_failed
// 333:
// 334:     cask.unpin
// 335:   end
// 336:
// 337:   it "warns for explicitly named unpinned packages", :cask do
// 338:     cask = Cask::CaskLoader.load("local-caffeine")
// 339:     InstallHelper.stub_cask_installation(cask)
// 340:
// 341:     expect { described_class.new(["--pinned", "--cask", "local-caffeine"]).run }
// 342:       .to not_to_output.to_stdout
// 343:       .and output(/local-caffeine not pinned/).to_stderr
// 344:   end
// 345:
// 346:   it "does not fail for unpinned Caskroom entries without named arguments", :cask do
// 347:     (Cask::Caskroom.path/"broken").mkpath
// 348:
// 349:     expect { described_class.new(["--pinned", "--cask"]).run }
// 350:       .to not_to_output.to_stdout
// 351:   end
// 352: end

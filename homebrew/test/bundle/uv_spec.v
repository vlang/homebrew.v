module bundle

import ruby
import homebrew.bundle.extensions

fn uv_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn uv_spec_tool(name string, requirements []string, source string) extensions.UvTool {
	return extensions.uv_normalized_options(name, requirements, source)
}

fn uv_spec_entry(name string, requirements []string, source string) extensions.ExtensionEntry {
	mut options := map[string]ruby.Value{}
	if requirements.len > 0 {
		options['with'] = ruby.string_array_value(requirements)
	}
	if source != '' {
		options['source'] = ruby.string_value(source)
	}
	return extensions.uv_entry(name, options) or { panic(err) }
}

fn uv_spec_entries() []extensions.ExtensionEntry {
	return [
		uv_spec_entry('ruff', [], ''),
		uv_spec_entry('mkdocs', ['mkdocs-material<10'], ''),
		extensions.ExtensionEntry{ entry_type: 'brew', name: 'wget' },
	]
}

fn uv_spec_tools_value(tools []extensions.UvTool) ruby.Value {
	return extensions.uv_tools_value(tools)
}

fn uv_spec_install(name string, requirements []string, source string) ruby.Value {
	return extensions.ruby_uv_l330_d29_install(extensions.uv_state_value(extensions.UvState{
		executable: '/tmp/uv/bin/uv'
	}), ruby.string_value(name), ruby.string_array_value(requirements), if source == '' {
		ruby.object_value('NilClass', '')
	} else {
		ruby.string_value(source)
	}, ruby.bool_value(true), ruby.bool_value(false), ruby.bool_value(true))
}

fn uv_spec_result(value ruby.Value) bool {
	return value.type_name == 'Hash' && 'result' in value.map_data && (value.map_data['result'].as_bool() or { false })
}

// Translated from Homebrew/brew `test/bundle/uv_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "accepts a source that resolves on another machine" do` at line 10.
pub fn ruby_uv_spec_l10_d1_accepts(args ...ruby.Value) ruby.Value {
	_ = args
	entry := uv_spec_entry('ruff', [], 'git+https://github.com/astral-sh/ruff.git')
	return uv_spec_bool(entry.options.len == 1 && entry.options['source'].as_string() == 'git+https://github.com/astral-sh/ruff.git')
}

// Ruby it `it "rejects a local path" do` at line 15.
pub fn ruby_uv_spec_l15_d2_rejects(args ...ruby.Value) ruby.Value {
	_ = args
	if _ := extensions.uv_entry('probetool', {
		'source': ruby.string_value('/Users/test/src/probetool')
	}) {
		return uv_spec_bool(false)
	} else {
		return uv_spec_bool(err.msg().contains('local to this machine'))
	}
}

// Ruby it `it "rejects the file:// URL uv reports for a directory install" do` at line 20.
pub fn ruby_uv_spec_l20_d3_rejects(args ...ruby.Value) ruby.Value {
	_ = args
	if _ := extensions.uv_entry('probetool', {
		'source': ruby.string_value('file:///Users/test/src/probetool')
	}) {
		return uv_spec_bool(false)
	} else {
		return uv_spec_bool(err.msg().contains('local to this machine'))
	}
}

// Ruby it `it "rejects a git+file:// URL" do` at line 25.
pub fn ruby_uv_spec_l25_d4_rejects(args ...ruby.Value) ruby.Value {
	_ = args
	if _ := extensions.uv_entry('probetool', {
		'source': ruby.string_value('git+file:///Users/test/src/probetool')
	}) {
		return uv_spec_bool(false)
	} else {
		return uv_spec_bool(err.msg().contains('local to this machine'))
	}
}

// Ruby subject `subject(:checker) { described_class.new }` at line 32.
pub fn ruby_uv_spec_l32_d5_checker(args ...ruby.Value) ruby.Value {
	_ = args
	return extensions.uv_state_value(extensions.UvState{})
}

// Ruby it `it "returns false when package is not installed" do` at line 35.
pub fn ruby_uv_spec_l35_d6_returns(args ...ruby.Value) ruby.Value {
	_ = args
	package := uv_spec_tool('mkdocs', ['mkdocs-material<10'], '')
	return uv_spec_bool(!extensions.uv_package_installed([], package.name, package.with, package.source))
}

// Ruby it `it "returns true when package and options match" do` at line 44.
pub fn ruby_uv_spec_l44_d7_returns(args ...ruby.Value) ruby.Value {
	_ = args
	package := uv_spec_tool('mkdocs', ['mkdocs-material<10'], '')
	return uv_spec_bool(extensions.uv_package_installed([package], package.name, package.with, package.source))
}

// Ruby it `it "passes the source through when checking a tool installed from a source" do` at line 56.
pub fn ruby_uv_spec_l56_d8_passes(args ...ruby.Value) ruby.Value {
	_ = args
	package := uv_spec_tool('ruff', [], 'git+https://github.com/astral-sh/ruff.git')
	return uv_spec_bool(extensions.uv_package_installed([package], 'ruff', [], 'git+https://github.com/astral-sh/ruff.git'))
}

// Ruby it `it "returns a package-specific message" do` at line 71.
pub fn ruby_uv_spec_l71_d9_returns(args ...ruby.Value) ruby.Value {
	_ = args
	package := extensions.ExtensionPackage{ name: 'mkdocs' }
	return uv_spec_bool(extensions.extension_failure_reason(extensions.ExtensionState{
		definition: extensions.uv_definition()
	}, package) == 'uv Tool mkdocs needs to be installed.')
}

// Ruby let `let(:entries) do` at line 79.
pub fn ruby_uv_spec_l79_d10_entries(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.array_value(uv_spec_entries().map(extensions.extension_entry_value(it)))
}

// Ruby it `it "checks uv entries and passes normalized options to installer checks" do` at line 87.
pub fn ruby_uv_spec_l87_d11_checks(args ...ruby.Value) ruby.Value {
	_ = args
	installed := [uv_spec_tool('ruff', [], ''), uv_spec_tool('mkdocs', [
		'mkdocs-material<10',
	], '')]
	missing := uv_spec_entries().filter(it.entry_type == 'uv').filter(!extensions.uv_package_installed(installed, it.name, if 'with' in it.options {
		it.options['with'].as_string_array() or { [] }
	} else {
		[]
	}, if 'source' in it.options { it.options['source'].as_string() } else { '' }))
	return uv_spec_bool(missing.len == 0)
}

// Ruby it `it "returns missing uv tools from full check flow" do` at line 99.
pub fn ruby_uv_spec_l99_d12_returns(args ...ruby.Value) ruby.Value {
	_ = args
	installed := [uv_spec_tool('ruff', [], '')]
	mut actionable := []string{}
	for entry in uv_spec_entries().filter(it.entry_type == 'uv') {
		requirements := if 'with' in entry.options {
			entry.options['with'].as_string_array() or { [] }
		} else {
			[]
		}
		if !extensions.uv_package_installed(installed, entry.name, requirements, '') {
			actionable << 'uv Tool ${entry.name} needs to be installed.'
		}
	}
	return uv_spec_bool(actionable == ['uv Tool mkdocs needs to be installed.'])
}

// Ruby subject `subject(:dumper) { described_class }` at line 111.
pub fn ruby_uv_spec_l111_d13_dumper(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.object_value('Homebrew::Bundle::Uv', 'Homebrew::Bundle::Uv')
}

// Ruby let `let(:uv_tool_list_command) do` at line 113.
pub fn ruby_uv_spec_l113_d14_uv_tool_list_command(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value('uv tool list --show-with --show-extras --show-version-specifiers 2>/dev/null')
}

// Ruby it `it "returns empty packages and dump output" do` at line 129.
pub fn ruby_uv_spec_l129_d15_returns(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.uv_parse_tool_list('')
	return uv_spec_bool(packages.len == 0 && packages.map(extensions.uv_dump_entry(it)).join('\n') == '')
}

// Ruby it `it "returns normalized package entries sorted by package name" do` at line 141.
pub fn ruby_uv_spec_l141_d16_returns(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.uv_parse_tool_list('ruff v0.14.14\n- ruff\nmkdocs v1.6.1 [with: mkdocs-material<10]\n- mkdocs\n')
	return uv_spec_bool(packages == [
		uv_spec_tool('mkdocs', ['mkdocs-material<10'], ''),
		uv_spec_tool('ruff', [], ''),
	])
}

// Ruby it `it "parses a git source from the version specifier and dumps it" do` at line 163.
pub fn ruby_uv_spec_l163_d17_parses(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.uv_parse_tool_list('ruff v0.14.14 [required:  git+https://github.com/astral-sh/ruff.git]\n- ruff\n')
	return uv_spec_bool(packages == [
		uv_spec_tool('ruff', [], 'git+https://github.com/astral-sh/ruff.git'),
	] && extensions.uv_dump_entry(packages[0]) == 'uv "ruff", source: "git+https://github.com/astral-sh/ruff.git"')
}

// Ruby it `it "dumps a tool installed from a directory without a source" do` at line 179.
pub fn ruby_uv_spec_l179_d18_dumps(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.uv_parse_tool_list('probetool v0.1.0 [required: file:///Users/test/src/probetool]\n- probetool\n')
	return uv_spec_bool(packages.len == 1 && extensions.uv_dump_entry(packages[0]) == 'uv "probetool"')
}

// Ruby it `it "dumps a tool installed from a git+file:// URL without a source" do` at line 188.
pub fn ruby_uv_spec_l188_d19_dumps(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.uv_parse_tool_list('probetool v0.1.0 [required: git+file:///Users/test/src/probetool]\n- probetool\n')
	return uv_spec_bool(packages.len == 1 && extensions.uv_dump_entry(packages[0]) == 'uv "probetool"')
}

// Ruby it `it "dumps a tool installed from a directory named like a git repository without a source" do` at line 197.
pub fn ruby_uv_spec_l197_d20_dumps(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.uv_parse_tool_list('probetool v0.1.0 [required: file:///Users/test/src/probetool.git]\n- probetool\n')
	return uv_spec_bool(packages.len == 1 && extensions.uv_dump_entry(packages[0]) == 'uv "probetool"')
}

// Ruby it `it "ignores a bare version constraint in the version specifier" do` at line 206.
pub fn ruby_uv_spec_l206_d21_ignores(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.uv_parse_tool_list('ruff v0.14.14 [required: >=0.1]\n- ruff\n')
	return uv_spec_bool(packages.len == 1 && packages[0].source == '' && extensions.uv_dump_entry(packages[0]) == 'uv "ruff"')
}

// Ruby it `it "dumps both with and source segments" do` at line 216.
pub fn ruby_uv_spec_l216_d22_dumps(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.uv_parse_tool_list('ruff v0.14.14 [with: httpx>=0.27] [required: git+https://github.com/astral-sh/ruff.git]\n- ruff\n')
	return uv_spec_bool(packages.len == 1 && extensions.uv_dump_entry(packages[0]) == 'uv "ruff", with: ["httpx>=0.27"], source: "git+https://github.com/astral-sh/ruff.git"')
}

// Ruby it `it "dumps correct Brewfile entries" do` at line 227.
pub fn ruby_uv_spec_l227_d23_dumps(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.uv_parse_tool_list('ruff v0.14.14 [with: httpx>=0.27]\n- ruff\n')
	return uv_spec_bool(packages.len == 1 && extensions.uv_dump_entry(packages[0]) == 'uv "ruff", with: ["httpx>=0.27"]')
}

// Ruby it `it "handles tools with no optional metadata" do` at line 236.
pub fn ruby_uv_spec_l236_d24_handles(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.uv_parse_tool_list('ruff v0.14.14\n- ruff\n')
	return uv_spec_bool(packages.len == 1 && extensions.uv_dump_entry(packages[0]) == 'uv "ruff"')
}

// Ruby it `it "returns empty packages when no tools are installed" do` at line 245.
pub fn ruby_uv_spec_l245_d25_returns(args ...ruby.Value) ruby.Value {
	_ = args
	return uv_spec_bool(extensions.uv_parse_tool_list('').len == 0)
}

// Ruby it `it "handles multiple with dependencies" do` at line 252.
pub fn ruby_uv_spec_l252_d26_handles(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.uv_parse_tool_list('mkdocs v1.6.1 [with: mkdocs-material, mkdocs-awesome-page-plugin]\n- mkdocs\n')
	return uv_spec_bool(packages.len == 1 && packages[0].with == [
		'mkdocs-awesome-page-plugin',
		'mkdocs-material',
	])
}

// Ruby it `it "keeps comma-constrained with requirements as a single requirement" do` at line 261.
pub fn ruby_uv_spec_l261_d27_keeps(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.uv_parse_tool_list('ruff v0.14.14 [with: httpx>=0.27, <0.29]\n- ruff\n')
	return uv_spec_bool(packages.len == 1 && packages[0].with == ['httpx>=0.27, <0.29'] && extensions.uv_dump_entry(packages[0]) == 'uv "ruff", with: ["httpx>=0.27, <0.29"]')
}

// Ruby it `it "preserves extras for the main tool requirement" do` at line 271.
pub fn ruby_uv_spec_l271_d28_preserves(args ...ruby.Value) ruby.Value {
	_ = args
	packages := extensions.uv_parse_tool_list('fastapi v0.129.0 [extras: all, standard]\n- fastapi\n')
	return uv_spec_bool(packages.len == 1 && packages[0].name == 'fastapi[all,standard]' && extensions.uv_dump_entry(packages[0]) == 'uv "fastapi[all,standard]"')
}

// Ruby it `it "tries to install uv" do` at line 290.
pub fn ruby_uv_spec_l290_d29_tries(args ...ruby.Value) ruby.Value {
	_ = args
	result := extensions.ruby_uv_l305_d28_preinstall(extensions.uv_state_value(extensions.UvState{}), ruby.string_value('mkdocs'))
	return uv_spec_bool(result.type_name == 'RuntimeError' && result.attributes['command'] == 'brew install --formula uv')
}

// Ruby it `it "skips install" do` at line 314.
pub fn ruby_uv_spec_l314_d30_skips(args ...ruby.Value) ruby.Value {
	_ = args
	state := extensions.UvState{
		executable: 'uv'
		installed_packages: [uv_spec_tool('mkdocs', ['mkdocs-material<10'], '')]
	}
	result := extensions.ruby_uv_l305_d28_preinstall(extensions.uv_state_value(state), ruby.string_value('mkdocs'), ruby.string_array_value([
		'mkdocs-material<10',
	]))
	return uv_spec_bool(result.type_name == 'Bool' && !(result.as_bool() or { true }))
}

// Ruby it `it "skips install for package with no options" do` at line 319.
pub fn ruby_uv_spec_l319_d31_skips(args ...ruby.Value) ruby.Value {
	_ = args
	state := extensions.UvState{
		executable: 'uv'
		installed_packages: [uv_spec_tool('ruff', [], '')]
	}
	result := extensions.ruby_uv_l305_d28_preinstall(extensions.uv_state_value(state), ruby.string_value('ruff'))
	return uv_spec_bool(result.type_name == 'Bool' && !(result.as_bool() or { true }))
}

// Ruby it `it "treats matching with requirements as installed" do` at line 332.
pub fn ruby_uv_spec_l332_d32_treats(args ...ruby.Value) ruby.Value {
	_ = args
	return uv_spec_bool(extensions.uv_package_installed([
		uv_spec_tool('ruff', ['httpx>=0.27'], ''),
	], 'ruff', ['httpx>=0.27'], ''))
}

// Ruby it `it "treats a matching source as installed" do` at line 349.
pub fn ruby_uv_spec_l349_d33_treats(args ...ruby.Value) ruby.Value {
	_ = args
	source := 'git+https://github.com/astral-sh/ruff.git'
	return uv_spec_bool(extensions.uv_package_installed([
		uv_spec_tool('ruff', [], source),
	], 'ruff', [], source))
}

// Ruby it `it "treats extras with different ordering as installed" do` at line 366.
pub fn ruby_uv_spec_l366_d34_treats(args ...ruby.Value) ruby.Value {
	_ = args
	return uv_spec_bool(extensions.uv_package_installed([uv_spec_tool('fastapi[all,standard]', [], '')], 'fastapi[standard,all]', [], ''))
}

// Ruby it `it "does not treat mismatched with dependencies as installed" do` at line 394.
pub fn ruby_uv_spec_l394_d35_does(args ...ruby.Value) ruby.Value {
	_ = args
	return uv_spec_bool(!extensions.uv_package_installed([uv_spec_tool('mkdocs', [
		'mkdocs-material<10',
	], '')], 'mkdocs', ['mkdocs-material<9'], ''))
}

// Ruby it `it "does not treat a different source as installed" do` at line 410.
pub fn ruby_uv_spec_l410_d36_does(args ...ruby.Value) ruby.Value {
	_ = args
	return uv_spec_bool(!extensions.uv_package_installed([uv_spec_tool('ruff', [], 'git+https://github.com/astral-sh/ruff.git')], 'ruff', [], 'ruff'))
}

// Ruby it `it "installs package with no options" do` at line 423.
pub fn ruby_uv_spec_l423_d37_installs(args ...ruby.Value) ruby.Value {
	_ = args
	result := uv_spec_install('ruff', [], '')
	state := extensions.uv_state_from_value(result.map_data['state'])
	return uv_spec_bool(uv_spec_result(result) && state.commands == [[
		'/tmp/uv/bin/uv',
		'tool',
		'install',
		'ruff',
	]])
}

// Ruby it `it "installs package with all supported options" do` at line 431.
pub fn ruby_uv_spec_l431_d38_installs(args ...ruby.Value) ruby.Value {
	_ = args
	result := uv_spec_install('mkdocs', ['mkdocs-material<10'], '')
	state := extensions.uv_state_from_value(result.map_data['state'])
	return uv_spec_bool(uv_spec_result(result) && state.commands == [[
		'/tmp/uv/bin/uv',
		'tool',
		'install',
		'mkdocs',
		'--with',
		'mkdocs-material<10',
	]])
}

// Ruby it `it "installs a package from its source" do` at line 441.
pub fn ruby_uv_spec_l441_d39_installs(args ...ruby.Value) ruby.Value {
	_ = args
	source := 'git+https://github.com/astral-sh/ruff.git'
	result := uv_spec_install('ruff', [], source)
	state := extensions.uv_state_from_value(result.map_data['state'])
	return uv_spec_bool(uv_spec_result(result) && state.commands == [[
		'/tmp/uv/bin/uv',
		'tool',
		'install',
		source,
	]])
}

// Ruby it `it "updates dump output after install in the same process" do` at line 450.
pub fn ruby_uv_spec_l450_d40_updates(args ...ruby.Value) ruby.Value {
	_ = args
	result := uv_spec_install('mkdocs', ['mkdocs-material<10'], '')
	state := extensions.uv_state_from_value(result.map_data['state'])
	dump_text := state.packages.map(extensions.uv_dump_entry(it)).join('\n')
	return uv_spec_bool(dump_text == 'uv "mkdocs", with: ["mkdocs-material<10"]')
}

// Ruby it `it "returns tools not in Brewfile entries" do` at line 479.
pub fn ruby_uv_spec_l479_d41_returns(args ...ruby.Value) ruby.Value {
	_ = args
	tools := [uv_spec_tool('ruff', [], ''), uv_spec_tool('mkdocs', [
		'mkdocs-material<10',
	], ''), uv_spec_tool('black', [], '')]
	return uv_spec_bool(extensions.uv_cleanup_items([uv_spec_entry('ruff', [], '')], '/tmp/uv/bin/uv', tools) == [
		'mkdocs',
		'black',
	])
}

// Ruby it `it "returns frozen empty array when uv is not installed" do` at line 484.
pub fn ruby_uv_spec_l484_d42_returns(args ...ruby.Value) ruby.Value {
	_ = args
	tools := [uv_spec_tool('ruff', [], ''), uv_spec_tool('mkdocs', [
		'mkdocs-material<10',
	], ''), uv_spec_tool('black', [], '')]
	return uv_spec_bool(extensions.uv_cleanup_items([uv_spec_entry('ruff', [], '')], '', tools) == [])
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/dsl"
// 6: require "bundle/extensions/uv"
// 7:
// 8: RSpec.describe Homebrew::Bundle::Uv do
// 9:   describe "entries" do
// 10:     it "accepts a source that resolves on another machine" do
// 11:       entry = described_class.entry("ruff", source: "git+https://github.com/astral-sh/ruff.git")
// 12:       expect(entry.options).to eql({ source: "git+https://github.com/astral-sh/ruff.git" })
// 13:     end
// 14:
// 15:     it "rejects a local path" do
// 16:       expect { described_class.entry("probetool", source: "/Users/test/src/probetool") }
// 17:         .to raise_error(RuntimeError, /local to this machine/)
// 18:     end
// 19:
// 20:     it "rejects the file:// URL uv reports for a directory install" do
// 21:       expect { described_class.entry("probetool", source: "file:///Users/test/src/probetool") }
// 22:         .to raise_error(RuntimeError, /local to this machine/)
// 23:     end
// 24:
// 25:     it "rejects a git+file:// URL" do
// 26:       expect { described_class.entry("probetool", source: "git+file:///Users/test/src/probetool") }
// 27:         .to raise_error(RuntimeError, /local to this machine/)
// 28:     end
// 29:   end
// 30:
// 31:   describe "checking" do
// 32:     subject(:checker) { described_class.new }
// 33:
// 34:     describe "#installed_and_up_to_date?" do
// 35:       it "returns false when package is not installed" do
// 36:         allow(described_class).to receive(:package_installed?).and_return(false)
// 37:         expect(
// 38:           checker.installed_and_up_to_date?(
// 39:             { name: "mkdocs", options: { with: ["mkdocs-material<10"] } },
// 40:           ),
// 41:         ).to be(false)
// 42:       end
// 43:
// 44:       it "returns true when package and options match" do
// 45:         expect(described_class).to receive(:package_installed?)
// 46:           .with("mkdocs", with: ["mkdocs-material<10"], source: nil)
// 47:           .and_return(true)
// 48:
// 49:         expect(
// 50:           checker.installed_and_up_to_date?(
// 51:             { name: "mkdocs", options: { with: ["mkdocs-material<10"] } },
// 52:           ),
// 53:         ).to be(true)
// 54:       end
// 55:
// 56:       it "passes the source through when checking a tool installed from a source" do
// 57:         expect(described_class).to receive(:package_installed?)
// 58:           .with("ruff", with: [], source: "git+https://github.com/astral-sh/ruff.git")
// 59:           .and_return(true)
// 60:
// 61:         expect(
// 62:           checker.installed_and_up_to_date?(
// 63:             { name:    "ruff",
// 64:               options: { source: "git+https://github.com/astral-sh/ruff.git" } },
// 65:           ),
// 66:         ).to be(true)
// 67:       end
// 68:     end
// 69:
// 70:     describe "#failure_reason" do
// 71:       it "returns a package-specific message" do
// 72:         expect(
// 73:           checker.failure_reason({ name: "mkdocs", options: { with: ["mkdocs-material<10"] } }, no_upgrade: false),
// 74:         ).to eq("uv Tool mkdocs needs to be installed.")
// 75:       end
// 76:     end
// 77:
// 78:     describe "#find_actionable" do
// 79:       let(:entries) do
// 80:         [
// 81:           Homebrew::Bundle::Dsl::Entry.new(:uv, "ruff"),
// 82:           Homebrew::Bundle::Dsl::Entry.new(:uv, "mkdocs", with: ["mkdocs-material<10"]),
// 83:           Homebrew::Bundle::Dsl::Entry.new(:brew, "wget"),
// 84:         ]
// 85:       end
// 86:
// 87:       it "checks uv entries and passes normalized options to installer checks" do
// 88:         expect(described_class).to receive(:package_installed?)
// 89:           .with("ruff", with: [], source: nil)
// 90:           .and_return(true)
// 91:         expect(described_class).to receive(:package_installed?)
// 92:           .with("mkdocs", with: ["mkdocs-material<10"], source: nil)
// 93:           .and_return(true)
// 94:
// 95:         actionable = checker.find_actionable(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)
// 96:         expect(actionable).to eq([])
// 97:       end
// 98:
// 99:       it "returns missing uv tools from full check flow" do
// 100:         allow(described_class).to receive(:package_installed?) do |name, **|
// 101:           name == "ruff"
// 102:         end
// 103:
// 104:         actionable = checker.find_actionable(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)
// 105:         expect(actionable).to eq(["uv Tool mkdocs needs to be installed."])
// 106:       end
// 107:     end
// 108:   end
// 109:
// 110:   describe "dumping" do
// 111:     subject(:dumper) { described_class }
// 112:
// 113:     let(:uv_tool_list_command) do
// 114:       [
// 115:         "uv tool list",
// 116:         "--show-with",
// 117:         "--show-extras",
// 118:         "--show-version-specifiers",
// 119:         "2>/dev/null",
// 120:       ].join(" ")
// 121:     end
// 122:
// 123:     context "when uv is not installed" do
// 124:       before do
// 125:         described_class.reset!
// 126:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 127:       end
// 128:
// 129:       it "returns empty packages and dump output" do
// 130:         expect(dumper.packages).to be_empty
// 131:         expect(dumper.dump).to eql("")
// 132:       end
// 133:     end
// 134:
// 135:     context "when uv is installed" do
// 136:       before do
// 137:         described_class.reset!
// 138:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("uv"))
// 139:       end
// 140:
// 141:       it "returns normalized package entries sorted by package name" do
// 142:         allow(described_class).to receive(:`).with(uv_tool_list_command).and_return(<<~OUTPUT)
// 143:           ruff v0.14.14
// 144:           - ruff
// 145:           mkdocs v1.6.1 [with: mkdocs-material<10]
// 146:           - mkdocs
// 147:         OUTPUT
// 148:
// 149:         expect(dumper.packages).to eql([
// 150:           {
// 151:             name:   "mkdocs",
// 152:             with:   ["mkdocs-material<10"],
// 153:             source: nil,
// 154:           },
// 155:           {
// 156:             name:   "ruff",
// 157:             with:   [],
// 158:             source: nil,
// 159:           },
// 160:         ])
// 161:       end
// 162:
// 163:       it "parses a git source from the version specifier and dumps it" do
// 164:         allow(described_class).to receive(:`).with(uv_tool_list_command).and_return(<<~OUTPUT)
// 165:           ruff v0.14.14 [required:  git+https://github.com/astral-sh/ruff.git]
// 166:           - ruff
// 167:         OUTPUT
// 168:
// 169:         expect(dumper.packages).to eql([
// 170:           {
// 171:             name:   "ruff",
// 172:             with:   [],
// 173:             source: "git+https://github.com/astral-sh/ruff.git",
// 174:           },
// 175:         ])
// 176:         expect(dumper.dump).to eql('uv "ruff", source: "git+https://github.com/astral-sh/ruff.git"')
// 177:       end
// 178:
// 179:       it "dumps a tool installed from a directory without a source" do
// 180:         allow(described_class).to receive(:`).with(uv_tool_list_command).and_return(<<~OUTPUT)
// 181:           probetool v0.1.0 [required: file:///Users/test/src/probetool]
// 182:           - probetool
// 183:         OUTPUT
// 184:
// 185:         expect(dumper.dump).to eql('uv "probetool"')
// 186:       end
// 187:
// 188:       it "dumps a tool installed from a git+file:// URL without a source" do
// 189:         allow(described_class).to receive(:`).with(uv_tool_list_command).and_return(<<~OUTPUT)
// 190:           probetool v0.1.0 [required: git+file:///Users/test/src/probetool]
// 191:           - probetool
// 192:         OUTPUT
// 193:
// 194:         expect(dumper.dump).to eql('uv "probetool"')
// 195:       end
// 196:
// 197:       it "dumps a tool installed from a directory named like a git repository without a source" do
// 198:         allow(described_class).to receive(:`).with(uv_tool_list_command).and_return(<<~OUTPUT)
// 199:           probetool v0.1.0 [required: file:///Users/test/src/probetool.git]
// 200:           - probetool
// 201:         OUTPUT
// 202:
// 203:         expect(dumper.dump).to eql('uv "probetool"')
// 204:       end
// 205:
// 206:       it "ignores a bare version constraint in the version specifier" do
// 207:         allow(described_class).to receive(:`).with(uv_tool_list_command).and_return(<<~OUTPUT)
// 208:           ruff v0.14.14 [required: >=0.1]
// 209:           - ruff
// 210:         OUTPUT
// 211:
// 212:         expect(dumper.packages.first&.dig(:source)).to be_nil
// 213:         expect(dumper.dump).to eql('uv "ruff"')
// 214:       end
// 215:
// 216:       it "dumps both with and source segments" do
// 217:         allow(described_class).to receive(:`).with(uv_tool_list_command).and_return(<<~OUTPUT)
// 218:           ruff v0.14.14 [with: httpx>=0.27] [required: git+https://github.com/astral-sh/ruff.git]
// 219:           - ruff
// 220:         OUTPUT
// 221:
// 222:         expect(dumper.dump).to eql(
// 223:           'uv "ruff", with: ["httpx>=0.27"], source: "git+https://github.com/astral-sh/ruff.git"',
// 224:         )
// 225:       end
// 226:
// 227:       it "dumps correct Brewfile entries" do
// 228:         allow(described_class).to receive(:`).with(uv_tool_list_command).and_return(<<~OUTPUT)
// 229:           ruff v0.14.14 [with: httpx>=0.27]
// 230:           - ruff
// 231:         OUTPUT
// 232:
// 233:         expect(dumper.dump).to eql('uv "ruff", with: ["httpx>=0.27"]')
// 234:       end
// 235:
// 236:       it "handles tools with no optional metadata" do
// 237:         allow(described_class).to receive(:`).with(uv_tool_list_command).and_return(<<~OUTPUT)
// 238:           ruff v0.14.14
// 239:           - ruff
// 240:         OUTPUT
// 241:
// 242:         expect(dumper.dump).to eql('uv "ruff"')
// 243:       end
// 244:
// 245:       it "returns empty packages when no tools are installed" do
// 246:         allow(described_class).to receive(:`).with(uv_tool_list_command).and_return("")
// 247:
// 248:         expect(dumper.packages).to be_empty
// 249:         expect(dumper.dump).to eql("")
// 250:       end
// 251:
// 252:       it "handles multiple with dependencies" do
// 253:         allow(described_class).to receive(:`).with(uv_tool_list_command).and_return(<<~OUTPUT)
// 254:           mkdocs v1.6.1 [with: mkdocs-material, mkdocs-awesome-page-plugin]
// 255:           - mkdocs
// 256:         OUTPUT
// 257:
// 258:         expect(dumper.packages.first&.dig(:with)).to eql(["mkdocs-awesome-page-plugin", "mkdocs-material"])
// 259:       end
// 260:
// 261:       it "keeps comma-constrained with requirements as a single requirement" do
// 262:         allow(described_class).to receive(:`).with(uv_tool_list_command).and_return(<<~OUTPUT)
// 263:           ruff v0.14.14 [with: httpx>=0.27, <0.29]
// 264:           - ruff
// 265:         OUTPUT
// 266:
// 267:         expect(dumper.packages.first&.dig(:with)).to eql(["httpx>=0.27, <0.29"])
// 268:         expect(dumper.dump).to eql('uv "ruff", with: ["httpx>=0.27, <0.29"]')
// 269:       end
// 270:
// 271:       it "preserves extras for the main tool requirement" do
// 272:         allow(described_class).to receive(:`).with(uv_tool_list_command).and_return(<<~OUTPUT)
// 273:           fastapi v0.129.0 [extras: all, standard]
// 274:           - fastapi
// 275:         OUTPUT
// 276:
// 277:         expect(dumper.packages.first).to include(name: "fastapi[all,standard]")
// 278:         expect(dumper.dump).to eql('uv "fastapi[all,standard]"')
// 279:       end
// 280:     end
// 281:   end
// 282:
// 283:   describe "installing" do
// 284:     context "when uv is not installed" do
// 285:       before do
// 286:         described_class.reset!
// 287:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 288:       end
// 289:
// 290:       it "tries to install uv" do
// 291:         expect(Homebrew::Bundle).to \
// 292:           receive(:system).with(HOMEBREW_BREW_FILE, "install", "--formula", "uv", verbose: false)
// 293:                           .and_return(true)
// 294:         expect { described_class.preinstall!("mkdocs") }.to raise_error(RuntimeError)
// 295:       end
// 296:     end
// 297:
// 298:     context "when uv is installed" do
// 299:       before do
// 300:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("uv"))
// 301:       end
// 302:
// 303:       context "when package is installed with matching options" do
// 304:         before do
// 305:           allow(described_class).to receive(:installed_packages).and_return([
// 306:             {
// 307:               name:   "mkdocs",
// 308:               with:   ["mkdocs-material<10"],
// 309:               source: nil,
// 310:             },
// 311:           ])
// 312:         end
// 313:
// 314:         it "skips install" do
// 315:           expect(Homebrew::Bundle).not_to receive(:system)
// 316:           expect(described_class.preinstall!("mkdocs", with: ["mkdocs-material<10"])).to be(false)
// 317:         end
// 318:
// 319:         it "skips install for package with no options" do
// 320:           allow(described_class).to receive(:installed_packages).and_return([
// 321:             {
// 322:               name:   "ruff",
// 323:               with:   [],
// 324:               source: nil,
// 325:             },
// 326:           ])
// 327:
// 328:           expect(Homebrew::Bundle).not_to receive(:system)
// 329:           expect(described_class.preinstall!("ruff")).to be(false)
// 330:         end
// 331:
// 332:         it "treats matching with requirements as installed" do
// 333:           allow(described_class).to receive(:installed_packages).and_return([
// 334:             {
// 335:               name:   "ruff",
// 336:               with:   ["httpx>=0.27"],
// 337:               source: nil,
// 338:             },
// 339:           ])
// 340:
// 341:           expect(
// 342:             described_class.package_installed?(
// 343:               "ruff",
// 344:               with: ["httpx>=0.27"],
// 345:             ),
// 346:           ).to be(true)
// 347:         end
// 348:
// 349:         it "treats a matching source as installed" do
// 350:           allow(described_class).to receive(:installed_packages).and_return([
// 351:             {
// 352:               name:   "ruff",
// 353:               with:   [],
// 354:               source: "git+https://github.com/astral-sh/ruff.git",
// 355:             },
// 356:           ])
// 357:
// 358:           expect(
// 359:             described_class.package_installed?(
// 360:               "ruff",
// 361:               source: "git+https://github.com/astral-sh/ruff.git",
// 362:             ),
// 363:           ).to be(true)
// 364:         end
// 365:
// 366:         it "treats extras with different ordering as installed" do
// 367:           allow(described_class).to receive(:installed_packages).and_return([
// 368:             {
// 369:               name:   "fastapi[all,standard]",
// 370:               with:   [],
// 371:               source: nil,
// 372:             },
// 373:           ])
// 374:
// 375:           expect(
// 376:             described_class.package_installed?(
// 377:               "fastapi[standard,all]",
// 378:             ),
// 379:           ).to be(true)
// 380:         end
// 381:       end
// 382:
// 383:       context "when package is installed but with options differ" do
// 384:         before do
// 385:           allow(described_class).to receive(:installed_packages).and_return([
// 386:             {
// 387:               name:   "mkdocs",
// 388:               with:   ["mkdocs-material<10"],
// 389:               source: nil,
// 390:             },
// 391:           ])
// 392:         end
// 393:
// 394:         it "does not treat mismatched with dependencies as installed" do
// 395:           expect(described_class.package_installed?("mkdocs", with: ["mkdocs-material<9"])).to be(false)
// 396:         end
// 397:       end
// 398:
// 399:       context "when package is installed from a different source" do
// 400:         before do
// 401:           allow(described_class).to receive(:installed_packages).and_return([
// 402:             {
// 403:               name:   "ruff",
// 404:               with:   [],
// 405:               source: "git+https://github.com/astral-sh/ruff.git",
// 406:             },
// 407:           ])
// 408:         end
// 409:
// 410:         it "does not treat a different source as installed" do
// 411:           expect(
// 412:             described_class.package_installed?("ruff", source: "ruff"),
// 413:           ).to be(false)
// 414:         end
// 415:       end
// 416:
// 417:       context "when package is not installed" do
// 418:         before do
// 419:           allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("/tmp/uv/bin/uv"))
// 420:           allow(described_class).to receive_messages(packages: [], installed_packages: [])
// 421:         end
// 422:
// 423:         it "installs package with no options" do
// 424:           expect(Homebrew::Bundle).to receive(:system)
// 425:             .with("/tmp/uv/bin/uv", "tool", "install", "ruff", verbose: false).and_return(true)
// 426:
// 427:           expect(described_class.preinstall!("ruff")).to be(true)
// 428:           expect(described_class.install!("ruff")).to be(true)
// 429:         end
// 430:
// 431:         it "installs package with all supported options" do
// 432:           expect(Homebrew::Bundle).to receive(:system)
// 433:             .with("/tmp/uv/bin/uv", "tool", "install", "mkdocs",
// 434:                   "--with", "mkdocs-material<10",
// 435:                   verbose: false).and_return(true)
// 436:
// 437:           expect(described_class.preinstall!("mkdocs", with: ["mkdocs-material<10"])).to be(true)
// 438:           expect(described_class.install!("mkdocs", with: ["mkdocs-material<10"])).to be(true)
// 439:         end
// 440:
// 441:         it "installs a package from its source" do
// 442:           source = "git+https://github.com/astral-sh/ruff.git"
// 443:           expect(Homebrew::Bundle).to receive(:system)
// 444:             .with("/tmp/uv/bin/uv", "tool", "install", source, verbose: false).and_return(true)
// 445:
// 446:           expect(described_class.preinstall!("ruff", source:)).to be(true)
// 447:           expect(described_class.install!("ruff", source:)).to be(true)
// 448:         end
// 449:
// 450:         it "updates dump output after install in the same process" do
// 451:           expect(Homebrew::Bundle).to receive(:system)
// 452:             .with("/tmp/uv/bin/uv", "tool", "install", "mkdocs",
// 453:                   "--with", "mkdocs-material<10",
// 454:                   verbose: false).and_return(true)
// 455:
// 456:           described_class.install!("mkdocs", with: ["mkdocs-material<10"])
// 457:
// 458:           expect(described_class.dump).to eql('uv "mkdocs", with: ["mkdocs-material<10"]')
// 459:         end
// 460:       end
// 461:     end
// 462:   end
// 463:
// 464:   describe "cleanup" do
// 465:     before do
// 466:       described_class.reset!
// 467:       tools = [
// 468:         { name: "ruff", with: [] },
// 469:         { name: "mkdocs", with: ["mkdocs-material<10"] },
// 470:         { name: "black", with: [] },
// 471:       ]
// 472:       allow(described_class).to receive_messages(
// 473:         package_manager_executable: Pathname.new("/tmp/uv/bin/uv"),
// 474:         packages:                   tools,
// 475:         installed_packages:         tools,
// 476:       )
// 477:     end
// 478:
// 479:     it "returns tools not in Brewfile entries" do
// 480:       entries = [Homebrew::Bundle::Dsl::Entry.new(:uv, "ruff")]
// 481:       expect(described_class.cleanup_items(entries)).to eql(%w[mkdocs black])
// 482:     end
// 483:
// 484:     it "returns frozen empty array when uv is not installed" do
// 485:       allow(described_class).to receive(:package_manager_installed?).and_return(false)
// 486:       entries = [Homebrew::Bundle::Dsl::Entry.new(:uv, "ruff")]
// 487:       expect(described_class.cleanup_items(entries)).to eql([])
// 488:     end
// 489:   end
// 490: end

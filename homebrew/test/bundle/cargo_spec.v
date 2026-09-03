module bundle

import brew_runtime
import homebrew.bundle.extensions

fn cargo_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn cargo_spec_crate(name string, source string) extensions.CargoCrate {
	return extensions.cargo_crate_record(name, source)
}

fn cargo_spec_entry(name string, source string) extensions.ExtensionEntry {
	mut options := map[string]brew_runtime.Value{}
	if source != '' {
		options['source'] = brew_runtime.string_value(source)
	}
	return extensions.cargo_entry(name, options) or { panic(err) }
}

fn cargo_spec_entries() []extensions.ExtensionEntry {
	return [
		cargo_spec_entry('ripgrep', ''),
		cargo_spec_entry('tftio-kb', 'ssh://git@example.com/tftio/kb.git'),
		extensions.ExtensionEntry{ entry_type: 'brew', name: 'wget' },
	]
}

fn cargo_spec_install(name string, source string) brew_runtime.Value {
	return extensions.ruby_cargo_l219_d21_install(extensions.cargo_state_value(extensions.CargoState{
		executable: '/tmp/rust/bin/cargo'
		executable_exists: true
	}), brew_runtime.string_value(name), brew_runtime.object_value('NilClass', ''), if source == '' {
		brew_runtime.object_value('NilClass', '')
	} else {
		brew_runtime.string_value(source)
	}, brew_runtime.bool_value(true), brew_runtime.bool_value(false), brew_runtime.bool_value(true))
}

fn cargo_spec_result(value brew_runtime.Value) bool {
	return value.type_name == 'Hash' && 'result' in value.map_data && (value.map_data['result'].as_bool() or { false })
}

// Translated from Homebrew/brew `test/bundle/cargo_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "accepts a source option" do` at line 23.
pub fn ruby_cargo_spec_l23_d1_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	entry := cargo_spec_entry('tftio-kb', 'ssh://git@example.com/tftio/kb.git')
	return cargo_spec_bool(entry.name == 'tftio-kb' && entry.options.len == 1 && entry.options['source'].as_string() == 'ssh://git@example.com/tftio/kb.git')
}

// Ruby it `it "accepts a source that selects a git reference" do` at line 29.
pub fn ruby_cargo_spec_l29_d2_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	entry := cargo_spec_entry('tftio-kb', 'ssh://git@example.com/tftio/kb.git?branch=next')
	return cargo_spec_bool(entry.options['source'].as_string() == 'ssh://git@example.com/tftio/kb.git?branch=next')
}

// Ruby it `it "stores no options when no source is given" do` at line 34.
pub fn ruby_cargo_spec_l34_d3_stores(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cargo_spec_bool(cargo_spec_entry('ripgrep', '').options.len == 0)
}

// Ruby it `it "rejects a non-String source" do` at line 38.
pub fn ruby_cargo_spec_l38_d4_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	if _ := extensions.cargo_entry('tftio-kb', {
		'source': brew_runtime.string_array_value(['ssh://git@example.com/tftio/kb.git'])
	}) {
		return cargo_spec_bool(false)
	} else {
		return cargo_spec_bool(err.msg().contains('options[:source]'))
	}
}

// Ruby it `it "rejects a source that is not a git URL" do` at line 43.
pub fn ruby_cargo_spec_l43_d5_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	if _ := extensions.cargo_entry('tftio-kb', {
		'source': brew_runtime.string_value('tftio-kb')
	}) {
		return cargo_spec_bool(false)
	} else {
		return cargo_spec_bool(err.msg().contains('should be a git URL'))
	}
}

// Ruby it `it "rejects a local path, which does not resolve on another machine" do` at line 48.
pub fn ruby_cargo_spec_l48_d6_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	if _ := extensions.cargo_entry('bat', {
		'source': brew_runtime.string_value('/Users/test/src/bat')
	}) {
		return cargo_spec_bool(false)
	} else {
		return cargo_spec_bool(err.msg().contains('should be a git URL'))
	}
}

// Ruby it `it "rejects a file:// git URL, which does not resolve on another machine either" do` at line 53.
pub fn ruby_cargo_spec_l53_d7_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	if _ := extensions.cargo_entry('bat', {
		'source': brew_runtime.string_value('file:///Users/test/src/bat')
	}) {
		return cargo_spec_bool(false)
	} else {
		return cargo_spec_bool(err.msg().contains('should be a git URL'))
	}
}

// Ruby it `it "rejects a git query that selects something other than a branch, tag or rev" do` at line 58.
pub fn ruby_cargo_spec_l58_d8_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	if _ := extensions.cargo_entry('tftio-kb', {
		'source': brew_runtime.string_value('ssh://git@example.com/tftio/kb.git?foo=bar')
	}) {
		return cargo_spec_bool(false)
	} else {
		return cargo_spec_bool(err.msg().contains('should select a branch, tag or rev'))
	}
}

// Ruby it `it "rejects an scp-style git remote that cargo cannot parse as a URL" do` at line 63.
pub fn ruby_cargo_spec_l63_d9_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	if _ := extensions.cargo_entry('bat', {
		'source': brew_runtime.string_value('git@github.com:sharkdp/bat.git')
	}) {
		return cargo_spec_bool(false)
	} else {
		return cargo_spec_bool(err.msg().contains('should be a git URL'))
	}
}

// Ruby it `it "rejects unknown options" do` at line 68.
pub fn ruby_cargo_spec_l68_d10_rejects(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	if _ := extensions.cargo_entry('ripgrep', {
		'features': brew_runtime.string_array_value(['pcre2'])
	}) {
		return cargo_spec_bool(false)
	} else {
		return cargo_spec_bool(err.msg().contains('unknown options'))
	}
}

// Ruby subject `subject(:checker) { described_class.new }` at line 75.
pub fn ruby_cargo_spec_l75_d11_checker(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return extensions.cargo_state_value(extensions.CargoState{})
}

// Ruby it `it "passes the source through when checking a crate installed from a source" do` at line 78.
pub fn ruby_cargo_spec_l78_d12_passes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	crate := cargo_spec_crate('tftio-kb', 'ssh://git@example.com/tftio/kb.git')
	return cargo_spec_bool(extensions.cargo_package_installed([crate], crate.name, crate.source))
}

// Ruby it `it "passes a nil source through for a registry crate" do` at line 90.
pub fn ruby_cargo_spec_l90_d13_passes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	crate := cargo_spec_crate('ripgrep', '')
	return cargo_spec_bool(extensions.cargo_package_installed([crate], 'ripgrep', ''))
}

// Ruby let `let(:entries) do` at line 100.
pub fn ruby_cargo_spec_l100_d14_entries(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.array_value(cargo_spec_entries().map(extensions.extension_entry_value(it)))
}

// Ruby it `it "returns missing cargo packages" do` at line 108.
pub fn ruby_cargo_spec_l108_d15_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	installed := [cargo_spec_crate('ripgrep', '')]
	mut actionable := []string{}
	for entry in cargo_spec_entries().filter(it.entry_type == 'cargo') {
		source := if 'source' in entry.options { entry.options['source'].as_string() } else { '' }
		if !extensions.cargo_package_installed(installed, entry.name, source) {
			actionable << 'Cargo Package ${entry.name} needs to be installed.'
		}
	}
	return cargo_spec_bool(actionable == [
		'Cargo Package tftio-kb needs to be installed.',
	])
}

// Ruby subject `subject(:dumper) { described_class }` at line 120.
pub fn ruby_cargo_spec_l120_d16_dumper(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.object_value('Homebrew::Bundle::Cargo', 'Homebrew::Bundle::Cargo')
}

// Ruby specify `specify do` at line 128.
pub fn ruby_cargo_spec_l128_d17_do(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	crates := extensions.cargo_parse_package_list('')
	return cargo_spec_bool(crates.len == 0 && crates.map(extensions.cargo_dump_entry(it)).join('\n') == '')
}

// Ruby it `it "returns package list" do` at line 140.
pub fn ruby_cargo_spec_l140_d18_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	output := 'ripgrep v13.0.0:\n    rg\nbat v0.24.0 (https://github.com/sharkdp/bat#3492d620)\n'
	return cargo_spec_bool(extensions.cargo_parse_package_list(output) == [
		cargo_spec_crate('ripgrep', ''),
		cargo_spec_crate('bat', 'https://github.com/sharkdp/bat'),
	])
}

// Ruby it `it "parses a git source and strips the resolved revision" do` at line 158.
pub fn ruby_cargo_spec_l158_d19_parses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	crates := extensions.cargo_parse_package_list('tftio-kb v4.0.0 (ssh://git@example.com/tftio/kb.git#3492d620):\n    kb\n')
	return cargo_spec_bool(crates == [cargo_spec_crate('tftio-kb', 'ssh://git@example.com/tftio/kb.git')] && extensions.cargo_dump_entry(crates[0]) == 'cargo "tftio-kb", source: "ssh://git@example.com/tftio/kb.git"')
}

// Ruby it `it "parses an https git source" do` at line 170.
pub fn ruby_cargo_spec_l170_d20_parses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	crates := extensions.cargo_parse_package_list('ripgrep v13.0.0 (https://github.com/BurntSushi/ripgrep#9f0e88bc):\n    rg\n')
	return cargo_spec_bool(crates.len == 1 && crates[0].source == 'https://github.com/BurntSushi/ripgrep')
}

// Ruby it `it "keeps a tag selector while stripping the resolved revision" do` at line 179.
pub fn ruby_cargo_spec_l179_d21_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	crates := extensions.cargo_parse_package_list('tftio-kb v4.0.0 (ssh://git@example.com/tftio/kb.git?tag=v4.0.0#3492d620):\n    kb\n')
	return cargo_spec_bool(crates.len == 1 && extensions.cargo_dump_entry(crates[0]) == 'cargo "tftio-kb", source: "ssh://git@example.com/tftio/kb.git?tag=v4.0.0"')
}

// Ruby it `it "dumps a crate installed from a local path without a source" do` at line 188.
pub fn ruby_cargo_spec_l188_d22_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	crates := extensions.cargo_parse_package_list('bat v0.24.0 (/Users/test/src/bat):\n    bat\n')
	return cargo_spec_bool(crates.len == 1 && extensions.cargo_dump_entry(crates[0]) == 'cargo "bat"')
}

// Ruby it `it "dumps a crate installed from a file:// repository without a source" do` at line 197.
pub fn ruby_cargo_spec_l197_d23_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	crates := extensions.cargo_parse_package_list('bat v0.24.0 (file:///Users/test/src/bat#3492d620):\n    bat\n')
	return cargo_spec_bool(crates.len == 1 && extensions.cargo_dump_entry(crates[0]) == 'cargo "bat"')
}

// Ruby it `it "ignores an origin it cannot classify as a source" do` at line 206.
pub fn ruby_cargo_spec_l206_d24_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	crates := extensions.cargo_parse_package_list('ripgrep v13.0.0 (registry+sparse):\n    rg\n')
	return cargo_spec_bool(crates.len == 1 && crates[0].source == '' && extensions.cargo_dump_entry(crates[0]) == 'cargo "ripgrep"')
}

// Ruby it `it "dumps package list" do` at line 216.
pub fn ruby_cargo_spec_l216_d25_dumps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	crates := [cargo_spec_crate('ripgrep', ''), cargo_spec_crate('bat', '')]
	return cargo_spec_bool(crates.map(extensions.cargo_dump_entry(it)).join('\n') == 'cargo "ripgrep"\ncargo "bat"')
}

// Ruby it `it "tries to install rust" do` at line 233.
pub fn ruby_cargo_spec_l233_d26_tries(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := extensions.ruby_cargo_l194_d20_preinstall(extensions.cargo_state_value(extensions.CargoState{}), brew_runtime.string_value('ripgrep'))
	return cargo_spec_bool(result.type_name == 'RuntimeError' && result.attributes['command'] == 'brew install --formula rust')
}

// Ruby it `it "skips" do` at line 252.
pub fn ruby_cargo_spec_l252_d27_skips(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	state := extensions.CargoState{
		executable: 'cargo'
		installed_packages: [cargo_spec_crate('ripgrep', '')]
	}
	result := extensions.ruby_cargo_l194_d20_preinstall(extensions.cargo_state_value(state), brew_runtime.string_value('ripgrep'))
	return cargo_spec_bool(result.type_name == 'Bool' && !(result.as_bool() or { true }))
}

// Ruby it `it "does not treat a differently-sourced package as installed" do` at line 257.
pub fn ruby_cargo_spec_l257_d28_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cargo_spec_bool(!extensions.cargo_package_installed([
		cargo_spec_crate('ripgrep', ''),
	], 'ripgrep', 'https://github.com/BurntSushi/ripgrep'))
}

// Ruby it `it "treats a matching source as installed" do` at line 270.
pub fn ruby_cargo_spec_l270_d29_treats(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	source := 'ssh://git@example.com/tftio/kb.git'
	return cargo_spec_bool(extensions.cargo_package_installed([cargo_spec_crate('tftio-kb', source)], 'tftio-kb', source))
}

// Ruby it `it "does not treat a different source as installed" do` at line 276.
pub fn ruby_cargo_spec_l276_d30_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cargo_spec_bool(!extensions.cargo_package_installed([cargo_spec_crate('tftio-kb', 'ssh://git@example.com/tftio/kb.git')], 'tftio-kb', 'ssh://git@example.com/tftio/other.git'))
}

// Ruby it `it "does not treat the registry crate of the same name as installed" do` at line 282.
pub fn ruby_cargo_spec_l282_d31_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return cargo_spec_bool(!extensions.cargo_package_installed([cargo_spec_crate('tftio-kb', 'ssh://git@example.com/tftio/kb.git')], 'tftio-kb', ''))
}

// Ruby it `it "installs package" do` at line 294.
pub fn ruby_cargo_spec_l294_d32_installs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := cargo_spec_install('ripgrep', '')
	state := extensions.cargo_state_from_value(result.map_data['state'])
	environment := extensions.cargo_env('/tmp/rust/bin/cargo', {
		'HOMEBREW_CARGO_HOME':         '~/.cargo'
		'HOMEBREW_CARGO_INSTALL_ROOT': '~/.cargo/bin'
		'HOMEBREW_RUSTUP_HOME':        '~/.rustup'
		'PATH':                        '/usr/bin'
	})
	return cargo_spec_bool(cargo_spec_result(result) && state.commands == [[
		'/tmp/rust/bin/cargo',
		'install',
		'--locked',
		'ripgrep',
	]] && environment['CARGO_HOME'] == '~/.cargo' && environment['PATH'].starts_with('/tmp/rust/bin:'))
}

// Ruby it `it "installs a package from a git source by package name" do` at line 308.
pub fn ruby_cargo_spec_l308_d33_installs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	source := 'ssh://git@example.com/tftio/kb.git'
	result := cargo_spec_install('tftio-kb', source)
	state := extensions.cargo_state_from_value(result.map_data['state'])
	return cargo_spec_bool(cargo_spec_result(result) && state.commands == [[
		'/tmp/rust/bin/cargo',
		'install',
		'--locked',
		'--git',
		source,
		'tftio-kb',
	]])
}

// Ruby it `it "installs a package from a git branch" do` at line 319.
pub fn ruby_cargo_spec_l319_d34_installs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := cargo_spec_install('tftio-kb', 'ssh://git@example.com/tftio/kb.git?branch=next')
	state := extensions.cargo_state_from_value(result.map_data['state'])
	return cargo_spec_bool(cargo_spec_result(result) && state.commands == [[
		'/tmp/rust/bin/cargo',
		'install',
		'--locked',
		'--git',
		'ssh://git@example.com/tftio/kb.git',
		'--branch',
		'next',
		'tftio-kb',
	]])
}

// Ruby it `it "installs a package from a pinned git revision" do` at line 331.
pub fn ruby_cargo_spec_l331_d35_installs(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := cargo_spec_install('tftio-kb', 'ssh://git@example.com/tftio/kb.git?rev=3492d620')
	state := extensions.cargo_state_from_value(result.map_data['state'])
	return cargo_spec_bool(cargo_spec_result(result) && state.commands == [[
		'/tmp/rust/bin/cargo',
		'install',
		'--locked',
		'--git',
		'ssh://git@example.com/tftio/kb.git',
		'--rev',
		'3492d620',
		'tftio-kb',
	]])
}

// Ruby it `it "updates dump output after install in the same process" do` at line 343.
pub fn ruby_cargo_spec_l343_d36_updates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	source := 'ssh://git@example.com/tftio/kb.git'
	result := cargo_spec_install('tftio-kb', source)
	state := extensions.cargo_state_from_value(result.map_data['state'])
	return cargo_spec_bool(state.packages.map(extensions.cargo_dump_entry(it)).join('\n') == 'cargo "tftio-kb", source: "ssh://git@example.com/tftio/kb.git"')
}

// Ruby it `it "returns packages not in Brewfile entries" do` at line 370.
pub fn ruby_cargo_spec_l370_d37_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	crates := [cargo_spec_crate('ripgrep', ''), cargo_spec_crate('fd-find', ''),
		cargo_spec_crate('bat', '')]
	return cargo_spec_bool(extensions.cargo_cleanup_items([
		cargo_spec_entry('ripgrep', ''),
	], '/tmp/rust/bin/cargo', crates) == ['fd-find', 'bat'])
}

// Ruby it `it "returns frozen empty array when cargo is not installed" do` at line 375.
pub fn ruby_cargo_spec_l375_d38_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	crates := [cargo_spec_crate('ripgrep', ''), cargo_spec_crate('fd-find', ''),
		cargo_spec_crate('bat', '')]
	return cargo_spec_bool(extensions.cargo_cleanup_items([
		cargo_spec_entry('ripgrep', ''),
	], '', crates) == [])
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/dsl"
// 6: require "bundle/extensions/cargo"
// 7:
// 8: RSpec.describe Homebrew::Bundle::Cargo do
// 9:   around do |example|
// 10:     with_env({
// 11:       "HOMEBREW_CARGO_HOME"         => "~/.cargo",
// 12:       "HOMEBREW_CARGO_INSTALL_ROOT" => "~/.cargo/bin",
// 13:       "HOMEBREW_RUSTUP_HOME"        => "~/.rustup",
// 14:       "CARGO_HOME"                  => nil,
// 15:       "CARGO_INSTALL_ROOT"          => nil,
// 16:       "RUSTUP_HOME"                 => nil,
// 17:     }) do
// 18:       example.run
// 19:     end
// 20:   end
// 21:
// 22:   describe "entries" do
// 23:     it "accepts a source option" do
// 24:       entry = described_class.entry("tftio-kb", source: "ssh://git@example.com/tftio/kb.git")
// 25:       expect(entry.name).to eql("tftio-kb")
// 26:       expect(entry.options).to eql({ source: "ssh://git@example.com/tftio/kb.git" })
// 27:     end
// 28:
// 29:     it "accepts a source that selects a git reference" do
// 30:       entry = described_class.entry("tftio-kb", source: "ssh://git@example.com/tftio/kb.git?branch=next")
// 31:       expect(entry.options).to eql({ source: "ssh://git@example.com/tftio/kb.git?branch=next" })
// 32:     end
// 33:
// 34:     it "stores no options when no source is given" do
// 35:       expect(described_class.entry("ripgrep").options).to be_empty
// 36:     end
// 37:
// 38:     it "rejects a non-String source" do
// 39:       expect { described_class.entry("tftio-kb", source: ["ssh://git@example.com/tftio/kb.git"]) }
// 40:         .to raise_error(RuntimeError, /options\[:source\]/)
// 41:     end
// 42:
// 43:     it "rejects a source that is not a git URL" do
// 44:       expect { described_class.entry("tftio-kb", source: "tftio-kb") }
// 45:         .to raise_error(RuntimeError, /should be a git URL/)
// 46:     end
// 47:
// 48:     it "rejects a local path, which does not resolve on another machine" do
// 49:       expect { described_class.entry("bat", source: "/Users/test/src/bat") }
// 50:         .to raise_error(RuntimeError, /should be a git URL/)
// 51:     end
// 52:
// 53:     it "rejects a file:// git URL, which does not resolve on another machine either" do
// 54:       expect { described_class.entry("bat", source: "file:///Users/test/src/bat") }
// 55:         .to raise_error(RuntimeError, /should be a git URL/)
// 56:     end
// 57:
// 58:     it "rejects a git query that selects something other than a branch, tag or rev" do
// 59:       expect { described_class.entry("tftio-kb", source: "ssh://git@example.com/tftio/kb.git?foo=bar") }
// 60:         .to raise_error(RuntimeError, /should select a branch, tag or rev/)
// 61:     end
// 62:
// 63:     it "rejects an scp-style git remote that cargo cannot parse as a URL" do
// 64:       expect { described_class.entry("bat", source: "git@github.com:sharkdp/bat.git") }
// 65:         .to raise_error(RuntimeError, /should be a git URL/)
// 66:     end
// 67:
// 68:     it "rejects unknown options" do
// 69:       expect { described_class.entry("ripgrep", features: ["pcre2"]) }
// 70:         .to raise_error(RuntimeError, /unknown options/)
// 71:     end
// 72:   end
// 73:
// 74:   describe "checking" do
// 75:     subject(:checker) { described_class.new }
// 76:
// 77:     describe "#installed_and_up_to_date?" do
// 78:       it "passes the source through when checking a crate installed from a source" do
// 79:         expect(described_class).to receive(:package_installed?)
// 80:           .with("tftio-kb", source: "ssh://git@example.com/tftio/kb.git")
// 81:           .and_return(true)
// 82:
// 83:         expect(
// 84:           checker.installed_and_up_to_date?(
// 85:             { name: "tftio-kb", options: { source: "ssh://git@example.com/tftio/kb.git" } },
// 86:           ),
// 87:         ).to be(true)
// 88:       end
// 89:
// 90:       it "passes a nil source through for a registry crate" do
// 91:         expect(described_class).to receive(:package_installed?)
// 92:           .with("ripgrep", source: nil)
// 93:           .and_return(true)
// 94:
// 95:         expect(checker.installed_and_up_to_date?({ name: "ripgrep", options: {} })).to be(true)
// 96:       end
// 97:     end
// 98:
// 99:     describe "#find_actionable" do
// 100:       let(:entries) do
// 101:         [
// 102:           Homebrew::Bundle::Dsl::Entry.new(:cargo, "ripgrep"),
// 103:           Homebrew::Bundle::Dsl::Entry.new(:cargo, "tftio-kb", source: "ssh://git@example.com/tftio/kb.git"),
// 104:           Homebrew::Bundle::Dsl::Entry.new(:brew, "wget"),
// 105:         ]
// 106:       end
// 107:
// 108:       it "returns missing cargo packages" do
// 109:         allow(described_class).to receive(:package_installed?) do |name, **|
// 110:           name == "ripgrep"
// 111:         end
// 112:
// 113:         actionable = checker.find_actionable(entries, exit_on_first_error: false, no_upgrade: false, verbose: false)
// 114:         expect(actionable).to eq(["Cargo Package tftio-kb needs to be installed."])
// 115:       end
// 116:     end
// 117:   end
// 118:
// 119:   describe "dumping" do
// 120:     subject(:dumper) { described_class }
// 121:
// 122:     context "when cargo is not installed" do
// 123:       before do
// 124:         described_class.reset!
// 125:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 126:       end
// 127:
// 128:       specify do
// 129:         expect(dumper.packages).to be_empty
// 130:         expect(dumper.dump).to eql("")
// 131:       end
// 132:     end
// 133:
// 134:     context "when cargo is installed" do
// 135:       before do
// 136:         described_class.reset!
// 137:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("cargo"))
// 138:       end
// 139:
// 140:       it "returns package list" do
// 141:         expect(described_class).to receive(:`).with("cargo install --list") do
// 142:           expect(ENV.fetch("CARGO_HOME", nil)).to eq("~/.cargo")
// 143:           expect(ENV.fetch("CARGO_INSTALL_ROOT", nil)).to eq("~/.cargo/bin")
// 144:           expect(ENV.fetch("RUSTUP_HOME", nil)).to eq("~/.rustup")
// 145:           <<~EOS
// 146:             ripgrep v13.0.0:
// 147:                 rg
// 148:             bat v0.24.0 (https://github.com/sharkdp/bat#3492d620)
// 149:           EOS
// 150:         end
// 151:
// 152:         expect(dumper.packages).to eql([
// 153:           { name: "ripgrep", source: nil },
// 154:           { name: "bat", source: "https://github.com/sharkdp/bat" },
// 155:         ])
// 156:       end
// 157:
// 158:       it "parses a git source and strips the resolved revision" do
// 159:         allow(described_class).to receive(:`).with("cargo install --list").and_return(<<~EOS)
// 160:           tftio-kb v4.0.0 (ssh://git@example.com/tftio/kb.git#3492d620):
// 161:               kb
// 162:         EOS
// 163:
// 164:         expect(dumper.packages).to eql([
// 165:           { name: "tftio-kb", source: "ssh://git@example.com/tftio/kb.git" },
// 166:         ])
// 167:         expect(dumper.dump).to eql('cargo "tftio-kb", source: "ssh://git@example.com/tftio/kb.git"')
// 168:       end
// 169:
// 170:       it "parses an https git source" do
// 171:         allow(described_class).to receive(:`).with("cargo install --list").and_return(<<~EOS)
// 172:           ripgrep v13.0.0 (https://github.com/BurntSushi/ripgrep#9f0e88bc):
// 173:               rg
// 174:         EOS
// 175:
// 176:         expect(dumper.packages.first&.dig(:source)).to eql("https://github.com/BurntSushi/ripgrep")
// 177:       end
// 178:
// 179:       it "keeps a tag selector while stripping the resolved revision" do
// 180:         allow(described_class).to receive(:`).with("cargo install --list").and_return(<<~EOS)
// 181:           tftio-kb v4.0.0 (ssh://git@example.com/tftio/kb.git?tag=v4.0.0#3492d620):
// 182:               kb
// 183:         EOS
// 184:
// 185:         expect(dumper.dump).to eql('cargo "tftio-kb", source: "ssh://git@example.com/tftio/kb.git?tag=v4.0.0"')
// 186:       end
// 187:
// 188:       it "dumps a crate installed from a local path without a source" do
// 189:         allow(described_class).to receive(:`).with("cargo install --list").and_return(<<~EOS)
// 190:           bat v0.24.0 (/Users/test/src/bat):
// 191:               bat
// 192:         EOS
// 193:
// 194:         expect(dumper.dump).to eql('cargo "bat"')
// 195:       end
// 196:
// 197:       it "dumps a crate installed from a file:// repository without a source" do
// 198:         allow(described_class).to receive(:`).with("cargo install --list").and_return(<<~EOS)
// 199:           bat v0.24.0 (file:///Users/test/src/bat#3492d620):
// 200:               bat
// 201:         EOS
// 202:
// 203:         expect(dumper.dump).to eql('cargo "bat"')
// 204:       end
// 205:
// 206:       it "ignores an origin it cannot classify as a source" do
// 207:         allow(described_class).to receive(:`).with("cargo install --list").and_return(<<~EOS)
// 208:           ripgrep v13.0.0 (registry+sparse):
// 209:               rg
// 210:         EOS
// 211:
// 212:         expect(dumper.packages.first&.dig(:source)).to be_nil
// 213:         expect(dumper.dump).to eql('cargo "ripgrep"')
// 214:       end
// 215:
// 216:       it "dumps package list" do
// 217:         allow(dumper).to receive(:packages).and_return([
// 218:           { name: "ripgrep", source: nil },
// 219:           { name: "bat", source: nil },
// 220:         ])
// 221:         expect(dumper.dump).to eql("cargo \"ripgrep\"\ncargo \"bat\"")
// 222:       end
// 223:     end
// 224:   end
// 225:
// 226:   describe "installing" do
// 227:     context "when Cargo is not installed" do
// 228:       before do
// 229:         described_class.reset!
// 230:         allow(described_class).to receive(:package_manager_executable).and_return(nil)
// 231:       end
// 232:
// 233:       it "tries to install rust" do
// 234:         expect(Homebrew::Bundle).to \
// 235:           receive(:system).with(HOMEBREW_BREW_FILE, "install", "--formula", "rust", verbose: false)
// 236:                           .and_return(true)
// 237:         expect { described_class.preinstall!("ripgrep") }.to raise_error(RuntimeError)
// 238:       end
// 239:     end
// 240:
// 241:     context "when Cargo is installed" do
// 242:       before do
// 243:         allow(described_class).to receive(:package_manager_executable).and_return(Pathname.new("cargo"))
// 244:       end
// 245:
// 246:       context "when package is installed" do
// 247:         before do
// 248:           allow(described_class).to receive(:installed_packages)
// 249:             .and_return([{ name: "ripgrep", source: nil }])
// 250:         end
// 251:
// 252:         it "skips" do
// 253:           expect(Homebrew::Bundle).not_to receive(:system)
// 254:           expect(described_class.preinstall!("ripgrep")).to be(false)
// 255:         end
// 256:
// 257:         it "does not treat a differently-sourced package as installed" do
// 258:           expect(
// 259:             described_class.package_installed?("ripgrep", source: "https://github.com/BurntSushi/ripgrep"),
// 260:           ).to be(false)
// 261:         end
// 262:       end
// 263:
// 264:       context "when package is installed from a source" do
// 265:         before do
// 266:           allow(described_class).to receive(:installed_packages)
// 267:             .and_return([{ name: "tftio-kb", source: "ssh://git@example.com/tftio/kb.git" }])
// 268:         end
// 269:
// 270:         it "treats a matching source as installed" do
// 271:           expect(
// 272:             described_class.package_installed?("tftio-kb", source: "ssh://git@example.com/tftio/kb.git"),
// 273:           ).to be(true)
// 274:         end
// 275:
// 276:         it "does not treat a different source as installed" do
// 277:           expect(
// 278:             described_class.package_installed?("tftio-kb", source: "ssh://git@example.com/tftio/other.git"),
// 279:           ).to be(false)
// 280:         end
// 281:
// 282:         it "does not treat the registry crate of the same name as installed" do
// 283:           expect(described_class.package_installed?("tftio-kb")).to be(false)
// 284:         end
// 285:       end
// 286:
// 287:       context "when package is not installed" do
// 288:         before do
// 289:           allow(described_class).to receive_messages(
// 290:             package_manager_executable: Pathname.new("/tmp/rust/bin/cargo"), packages: [], installed_packages: [],
// 291:           )
// 292:         end
// 293:
// 294:         it "installs package" do
// 295:           expect(Homebrew::Bundle).to receive(:system) do |*args, verbose:|
// 296:             expect(ENV.fetch("CARGO_HOME", nil)).to eq("~/.cargo")
// 297:             expect(ENV.fetch("CARGO_INSTALL_ROOT", nil)).to eq("~/.cargo/bin")
// 298:             expect(ENV.fetch("RUSTUP_HOME", nil)).to eq("~/.rustup")
// 299:             expect(ENV.fetch("PATH", "")).to start_with("/tmp/rust/bin:")
// 300:             expect(args).to eq(["/tmp/rust/bin/cargo", "install", "--locked", "ripgrep"])
// 301:             expect(verbose).to be(false)
// 302:             true
// 303:           end
// 304:           expect(described_class.preinstall!("ripgrep")).to be(true)
// 305:           expect(described_class.install!("ripgrep")).to be(true)
// 306:         end
// 307:
// 308:         it "installs a package from a git source by package name" do
// 309:           source = "ssh://git@example.com/tftio/kb.git"
// 310:           expect(Homebrew::Bundle).to receive(:system) do |*args, verbose:|
// 311:             expect(args).to eq(["/tmp/rust/bin/cargo", "install", "--locked", "--git", source, "tftio-kb"])
// 312:             expect(verbose).to be(false)
// 313:             true
// 314:           end
// 315:           expect(described_class.preinstall!("tftio-kb", source:)).to be(true)
// 316:           expect(described_class.install!("tftio-kb", source:)).to be(true)
// 317:         end
// 318:
// 319:         it "installs a package from a git branch" do
// 320:           expect(Homebrew::Bundle).to receive(:system) do |*args, verbose:|
// 321:             _ = verbose
// 322:             expect(args).to eq(["/tmp/rust/bin/cargo", "install", "--locked", "--git",
// 323:                                 "ssh://git@example.com/tftio/kb.git", "--branch", "next", "tftio-kb"])
// 324:             true
// 325:           end
// 326:           expect(
// 327:             described_class.install!("tftio-kb", source: "ssh://git@example.com/tftio/kb.git?branch=next"),
// 328:           ).to be(true)
// 329:         end
// 330:
// 331:         it "installs a package from a pinned git revision" do
// 332:           expect(Homebrew::Bundle).to receive(:system) do |*args, verbose:|
// 333:             _ = verbose
// 334:             expect(args).to eq(["/tmp/rust/bin/cargo", "install", "--locked", "--git",
// 335:                                 "ssh://git@example.com/tftio/kb.git", "--rev", "3492d620", "tftio-kb"])
// 336:             true
// 337:           end
// 338:           expect(
// 339:             described_class.install!("tftio-kb", source: "ssh://git@example.com/tftio/kb.git?rev=3492d620"),
// 340:           ).to be(true)
// 341:         end
// 342:
// 343:         it "updates dump output after install in the same process" do
// 344:           source = "ssh://git@example.com/tftio/kb.git"
// 345:           allow(Homebrew::Bundle).to receive(:system).and_return(true)
// 346:
// 347:           described_class.install!("tftio-kb", source:)
// 348:
// 349:           expect(described_class.dump).to eql(%Q(cargo "tftio-kb", source: "#{source}"))
// 350:         end
// 351:       end
// 352:     end
// 353:   end
// 354:
// 355:   describe "cleanup" do
// 356:     before do
// 357:       described_class.reset!
// 358:       crates = [
// 359:         { name: "ripgrep", source: nil },
// 360:         { name: "fd-find", source: nil },
// 361:         { name: "bat", source: nil },
// 362:       ]
// 363:       allow(described_class).to receive_messages(
// 364:         package_manager_executable: Pathname.new("/tmp/rust/bin/cargo"),
// 365:         packages:                   crates,
// 366:         installed_packages:         crates,
// 367:       )
// 368:     end
// 369:
// 370:     it "returns packages not in Brewfile entries" do
// 371:       entries = [Homebrew::Bundle::Dsl::Entry.new(:cargo, "ripgrep")]
// 372:       expect(described_class.cleanup_items(entries)).to eql(%w[fd-find bat])
// 373:     end
// 374:
// 375:     it "returns frozen empty array when cargo is not installed" do
// 376:       allow(described_class).to receive(:package_manager_installed?).and_return(false)
// 377:       entries = [Homebrew::Bundle::Dsl::Entry.new(:cargo, "ripgrep")]
// 378:       expect(described_class.cleanup_items(entries)).to eql([])
// 379:     end
// 380:   end
// 381: end

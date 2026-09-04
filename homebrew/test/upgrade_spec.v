module test

import ruby
import homebrew

fn upgrade_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn upgrade_spec_formula(name string, version string, attributes map[string]string,
	fields map[string]ruby.Value) ruby.Value {
	mut values := attributes.clone()
	values['name'] = name
	values['full_name'] = values['full_name'] or { name }
	values['full_specified_name'] = values['full_specified_name'] or { values['full_name'] }
	values['pkg_version'] = version
	return ruby.Value{
		type_name: 'Formula'
		repr: name
		attributes: values
		map_data: fields.clone()
	}
}

fn upgrade_spec_installer(formula ruby.Value, attributes map[string]string,
	dependencies []ruby.Value) ruby.Value {
	return ruby.Value{
		type_name: 'FormulaInstaller'
		repr: formula.repr
		attributes: attributes.clone()
		map_data: {
			'formula':      formula
			'dependencies': ruby.array_value(dependencies)
		}
	}
}

// Translated from Homebrew/brew `test/upgrade_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "aligns a large mixed list of package names and versions" do` at line 13.
pub fn ruby_upgrade_spec_l13_d1_aligns(args ...ruby.Value) ruby.Value {
	upgrades := [
		'sqlite 3.53.1 -> 3.53.2 (2.4MB)',
		'docker 29.5.2 -> 29.6.0 (9.3MB)',
		'gh 2.93.0 -> 2.95.0 (13.4MB)',
		'python@3.14 3.14.5 -> 3.14.6 (19.2MB)',
		'pnpm 11.5.1 -> 11.8.0 (4MB)',
		'usage 3.4.0 -> 3.5.2 (2.9MB)',
		'certifi 2026.5.20 -> 2026.6.17 (5.7KB)',
		'libvmaf 3.1.0 -> 3.2.0 (1.2MB)',
		'kubernetes-cli 1.36.1 -> 1.36.2 (18.2MB)',
		'jq 1.8.1 -> 1.8.2 (441KB)',
		'mise 2026.6.0 -> 2026.6.11 (34.8MB)',
		'sdl2 2.32.70 (636.8KB)',
		'opencode-desktop 1.14.48 -> 1.17.9',
		'slack 4.48.102 -> 4.50.140',
		'spotify 1.2.84.476 -> 1.2.92.148',
		'visual-studio-code 1.111.0 -> 1.125.1',
	]
	expected := [
		'sqlite              3.53.1     -> 3.53.2 (2.4MB)',
		'docker              29.5.2     -> 29.6.0 (9.3MB)',
		'gh                  2.93.0     -> 2.95.0 (13.4MB)',
		'python@3.14         3.14.5     -> 3.14.6 (19.2MB)',
		'pnpm                11.5.1     -> 11.8.0 (4MB)',
		'usage               3.4.0      -> 3.5.2 (2.9MB)',
		'certifi             2026.5.20  -> 2026.6.17 (5.7KB)',
		'libvmaf             3.1.0      -> 3.2.0 (1.2MB)',
		'kubernetes-cli      1.36.1     -> 1.36.2 (18.2MB)',
		'jq                  1.8.1      -> 1.8.2 (441KB)',
		'mise                2026.6.0   -> 2026.6.11 (34.8MB)',
		'sdl2                2.32.70 (636.8KB)',
		'opencode-desktop    1.14.48    -> 1.17.9',
		'slack               4.48.102   -> 4.50.140',
		'spotify             1.2.84.476 -> 1.2.92.148',
		'visual-studio-code  1.111.0    -> 1.125.1',
	]
	actual := homebrew.ruby_upgrade_l26_d1_format_upgrade_summary(ruby.string_array_value(upgrades)).as_string_array() or {
		[]
	}
	return upgrade_spec_bool(actual == expected)
}

// Ruby it `it "shows the version transition for an unlinked dependency installed at an older version" do` at line 55.
pub fn ruby_upgrade_spec_l55_d2_shows(args ...ruby.Value) ruby.Value {
	dependency := upgrade_spec_formula('python@3.14', '3.14.6', {
		'installed_versions': '2.7.14_2\x1f3.6.1\x1f3.6.4_4\x1f3.7.1'
	}, {})
	installer := upgrade_spec_installer(upgrade_spec_formula('testball', '0.2', {}, {}), {}, [
		dependency,
	])
	result := homebrew.ruby_upgrade_l466_d8_upgrade_formula(installer, ruby.structured_value('UpgradeOptions', '', {
		'dry_run': 'true'
	}))
	return upgrade_spec_bool(result.attributes['stdout'] or { '' }.contains('Would upgrade dependencies') && result.attributes['stdout'] or { '' }.contains('python@3.14 3.7.1 -> 3.14.6'))
}

// Ruby it `it "reports a failed upgrade instead of aborting the rest of the batch" do` at line 73.
pub fn ruby_upgrade_spec_l73_d3_reports(args ...ruby.Value) ruby.Value {
	formula := upgrade_spec_formula('testball', '0.2', {}, {})
	installer := upgrade_spec_installer(formula, {
		'install_error': 'gzip decompression failed'
	}, [])
	result := homebrew.ruby_upgrade_l466_d8_upgrade_formula(installer)
	return upgrade_spec_bool(!result.bool_data && (result.attributes['stderr'] or { '' }).contains('Error: testball: gzip decompression failed'))
}

// Ruby it `it "explains when installed dependencies satisfy the bottle metadata" do` at line 84.
pub fn ruby_upgrade_spec_l84_d4_explains(args ...ruby.Value) ruby.Value {
	dependent := upgrade_spec_formula('dependent', '2.0', {}, {})
	installer := upgrade_spec_installer(dependent, {
		'all_runtime_dependencies_installed': 'true'
	}, [])
	formula := ruby.Value{
		...dependent
		map_data: {
			'installer': installer
		}
	}
	result := homebrew.ruby_upgrade_l65_d2_formula_installers(ruby.array_value([
		formula,
	]), ruby.structured_value('UpgradeOptions', '', {
		'dependents': 'true'
	}))
	return upgrade_spec_bool((result.attributes['stdout'] or { '' }) == '==> Not upgrading dependent: installed runtime dependencies satisfy bottle metadata\n')
}

// Ruby it `it "returns installed dependents unless they are primary formulae" do` at line 116.
pub fn ruby_upgrade_spec_l116_d5_returns(args ...ruby.Value) ruby.Value {
	installed := upgrade_spec_formula('installed-dependent', '2.0', {}, {})
	primary := upgrade_spec_formula('primary', '2.0', {}, {})
	dependants := ruby.map_value({
		'upgradeable': ruby.array_value([installed, primary])
		'pinned':      ruby.array_value([])
		'skipped':     ruby.array_value([])
	})
	config := ruby.Value{
		type_name: 'UpgradeOptions'
		map_data: {
			'installed_formulae': ruby.array_value([installed, primary])
		}
	}
	result := homebrew.ruby_upgrade_l283_d7_upgrade_dependents(dependants, ruby.array_value([
		primary,
	]), config)
	values := (result.map_data['values'] or { ruby.array_value([]) }).as_array() or { [] }
	return upgrade_spec_bool(values.len == 1 && values[0].repr == 'installed-dependent')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "upgrade"
// 5: require "formula_installer"
// 6: require "dependency"
// 7: require "keg"
// 8: require "pkg_version"
// 9: require "test/support/fixtures/testball"
// 10:
// 11: RSpec.describe Homebrew::Upgrade do
// 12:   describe "::format_upgrade_summary" do
// 13:     it "aligns a large mixed list of package names and versions" do
// 14:       upgrades = [
// 15:         "sqlite 3.53.1 -> 3.53.2 (2.4MB)",
// 16:         "docker 29.5.2 -> 29.6.0 (9.3MB)",
// 17:         "gh 2.93.0 -> 2.95.0 (13.4MB)",
// 18:         "python@3.14 3.14.5 -> 3.14.6 (19.2MB)",
// 19:         "pnpm 11.5.1 -> 11.8.0 (4MB)",
// 20:         "usage 3.4.0 -> 3.5.2 (2.9MB)",
// 21:         "certifi 2026.5.20 -> 2026.6.17 (5.7KB)",
// 22:         "libvmaf 3.1.0 -> 3.2.0 (1.2MB)",
// 23:         "kubernetes-cli 1.36.1 -> 1.36.2 (18.2MB)",
// 24:         "jq 1.8.1 -> 1.8.2 (441KB)",
// 25:         "mise 2026.6.0 -> 2026.6.11 (34.8MB)",
// 26:         "sdl2 2.32.70 (636.8KB)",
// 27:         "opencode-desktop 1.14.48 -> 1.17.9",
// 28:         "slack 4.48.102 -> 4.50.140",
// 29:         "spotify 1.2.84.476 -> 1.2.92.148",
// 30:         "visual-studio-code 1.111.0 -> 1.125.1",
// 31:       ]
// 32:
// 33:       expect(described_class.format_upgrade_summary(upgrades)).to eq([
// 34:         "sqlite              3.53.1     -> 3.53.2 (2.4MB)",
// 35:         "docker              29.5.2     -> 29.6.0 (9.3MB)",
// 36:         "gh                  2.93.0     -> 2.95.0 (13.4MB)",
// 37:         "python@3.14         3.14.5     -> 3.14.6 (19.2MB)",
// 38:         "pnpm                11.5.1     -> 11.8.0 (4MB)",
// 39:         "usage               3.4.0      -> 3.5.2 (2.9MB)",
// 40:         "certifi             2026.5.20  -> 2026.6.17 (5.7KB)",
// 41:         "libvmaf             3.1.0      -> 3.2.0 (1.2MB)",
// 42:         "kubernetes-cli      1.36.1     -> 1.36.2 (18.2MB)",
// 43:         "jq                  1.8.1      -> 1.8.2 (441KB)",
// 44:         "mise                2026.6.0   -> 2026.6.11 (34.8MB)",
// 45:         "sdl2                2.32.70 (636.8KB)",
// 46:         "opencode-desktop    1.14.48    -> 1.17.9",
// 47:         "slack               4.48.102   -> 4.50.140",
// 48:         "spotify             1.2.84.476 -> 1.2.92.148",
// 49:         "visual-studio-code  1.111.0    -> 1.125.1",
// 50:       ])
// 51:     end
// 52:   end
// 53:
// 54:   describe "::upgrade_formula" do
// 55:     it "shows the version transition for an unlinked dependency installed at an older version" do
// 56:       python = formula("python@3.14") do
// 57:         T.bind(self, T.class_of(Formula))
// 58:         url "https://brew.sh/python-3.14.6.tgz"
// 59:       end
// 60:       kegs = ["2.7.14_2", "3.6.1", "3.6.4_4", "3.7.1"].map do |v|
// 61:         instance_double(Keg, version: PkgVersion.parse(v))
// 62:       end
// 63:       allow(python).to receive_messages(any_version_installed?: true, optlinked?: false, installed_kegs: kegs)
// 64:       dependency = instance_double(Dependency, to_formula: python)
// 65:       formula_installer = instance_double(
// 66:         FormulaInstaller, formula: Testball.new, compute_dependencies: [dependency]
// 67:       )
// 68:
// 69:       expect { described_class.upgrade_formula(formula_installer, dry_run: true) }
// 70:         .to output(/Would upgrade.*python@3.14 3.7.1 -> 3.14.6/m).to_stdout
// 71:     end
// 72:
// 73:     it "reports a failed upgrade instead of aborting the rest of the batch" do
// 74:       formula_installer = instance_double(FormulaInstaller, formula: Testball.new)
// 75:       allow(Homebrew::Install).to receive(:install_formula).and_raise("gzip decompression failed")
// 76:
// 77:       expect do
// 78:         expect(described_class.upgrade_formula(formula_installer)).to be(false)
// 79:       end.to output(/Error: testball: gzip decompression failed/).to_stderr
// 80:     end
// 81:   end
// 82:
// 83:   describe "::formula_installers" do
// 84:     it "explains when installed dependencies satisfy the bottle metadata" do
// 85:       dependent = formula("dependent") do
// 86:         T.bind(self, T.class_of(Formula))
// 87:         url "https://brew.sh/dependent-2.0"
// 88:       end
// 89:       formula_installer = instance_double(
// 90:         FormulaInstaller,
// 91:         bottle_tab_runtime_dependencies: { "dependency" => { "version" => "2.0", "revision" => "0" } },
// 92:         determine_bottle_tab_attributes: nil,
// 93:         fetch_bottle_tab:                nil,
// 94:         formula:                         dependent,
// 95:       )
// 96:       dependency = instance_double(Dependency)
// 97:       download_queue = instance_double(Homebrew::DownloadQueue, fetch: nil, shutdown: nil)
// 98:
// 99:       allow(Migrator).to receive(:migrate_if_needed)
// 100:       allow(described_class).to receive(:create_formula_installer).and_return(formula_installer)
// 101:       allow(Homebrew::DownloadQueue).to receive(:new).and_return(download_queue)
// 102:       allow(Dependency).to receive(:new).with("dependency").and_return(dependency)
// 103:       allow(dependency).to receive(:installed?)
// 104:         .with(minimum_version: Version.new("2.0"), minimum_revision: 0)
// 105:         .and_return(true)
// 106:
// 107:       expect do
// 108:         described_class.formula_installers([dependent], flags: [], dependents: true)
// 109:       end.to output(
// 110:         "==> Not upgrading dependent: installed runtime dependencies satisfy bottle metadata\n",
// 111:       ).to_stdout
// 112:     end
// 113:   end
// 114:
// 115:   describe "::upgrade_dependents" do
// 116:     it "returns installed dependents unless they are primary formulae" do
// 117:       installed_dependent = formula("installed-dependent") do
// 118:         T.bind(self, T.class_of(Formula))
// 119:         url "https://brew.sh/installed-dependent-2.0"
// 120:       end
// 121:       primary_formula = formula("primary") do
// 122:         T.bind(self, T.class_of(Formula))
// 123:         url "https://brew.sh/primary-2.0"
// 124:       end
// 125:       FormulaInstaller.installed.merge([installed_dependent, primary_formula])
// 126:       dependants = Homebrew::Upgrade::Dependents.new(
// 127:         upgradeable: [installed_dependent, primary_formula], pinned: [], skipped: [],
// 128:       )
// 129:
// 130:       expect(described_class.upgrade_dependents(dependants, [primary_formula], flags: []))
// 131:         .to contain_exactly(installed_dependent)
// 132:     end
// 133:   end
// 134: end

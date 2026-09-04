module cask

import ruby
import homebrew
import homebrew.cask.dsl as depends_on_dsl

// Translated from Homebrew/brew `test/cask/depends_on_spec.rb`.
// The original source is retained below until every stub has a typed V body.
const depends_on_spec_default_macos = '26'

fn depends_on_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn depends_on_spec_symbol(value string) ruby.Value {
	return ruby.Value{
		type_name: 'Symbol'
		repr: value
	}
}

fn depends_on_spec_pairs(token string) map[string]ruby.Value {
	return match token {
		'with-depends-on-cask' {
			{
				'cask': ruby.string_value('local-transmission-zip')
			}
		}
		'with-depends-on-cask-cyclic' {
			{
				'cask': ruby.string_array_value([
					'local-caffeine',
					'with-depends-on-cask-cyclic-helper',
				])
			}
		}
		'with-depends-on-cask-cyclic-helper' {
			{
				'cask': ruby.string_value('with-depends-on-cask-cyclic')
			}
		}
		'with-depends-on-macos-array' {
			{
				'macos': ruby.array_value([
					depends_on_spec_symbol('catalina'),
					depends_on_spec_symbol(depends_on_spec_default_macos),
				])
			}
		}
		'with-depends-on-macos-comparison' {
			{
				'macos': depends_on_spec_symbol('catalina')
			}
		}
		'with-depends-on-macos-symbol' {
			{
				'macos': depends_on_spec_symbol(depends_on_spec_default_macos)
			}
		}
		'with-depends-on-macos-failure' {
			{
				'maximum_macos': depends_on_spec_symbol('monterey')
			}
		}
		'with-depends-on-arch' {
			{
				'arch': ruby.array_value([
					depends_on_spec_symbol('intel'),
					depends_on_spec_symbol('arm64'),
				])
			}
		}
		else { map[string]ruby.Value{} }
	}
}

fn depends_on_spec_typed(token string) !depends_on_dsl.CaskDependsOn {
	mut depends_on := depends_on_dsl.CaskDependsOn{}
	depends_on.load(depends_on_spec_pairs(token), false, false)!
	return depends_on
}

fn depends_on_spec_cask(token string) ruby.Value {
	depends_on := depends_on_spec_typed(token) or {
		return ruby.object_value('CaskError', err.msg())
	}
	return ruby.Value{
		type_name: 'Cask::Cask'
		repr: token
		map_data: {
			'token':            ruby.string_value(token)
			'depends_on':       depends_on_dsl.cask_depends_on_value(depends_on)
			'current_macos':    ruby.string_value(depends_on_spec_default_macos)
			'running_on_macos': ruby.bool_value(true)
			'current_arch':     ruby.string_value('arm')
			'current_bits':     ruby.int_value(64)
		}
		attributes: {
			'token': token
		}
	}
}

fn depends_on_spec_fixture(token string) ruby.Value {
	return depends_on_spec_cask(token)
}

fn depends_on_spec_token(cask ruby.Value) !string {
	if cask.type_name != 'Cask::Cask' {
		return error('expected Cask::Cask, got ${cask.type_name}')
	}
	return (cask.map_data['token'] or { return error('cask has no token') }).as_string()
}

fn depends_on_spec_dependencies(cask ruby.Value) ![]string {
	raw := cask.map_data['depends_on'] or { return error('cask has no depends_on stanza') }
	return depends_on_dsl.cask_depends_on_from_value(raw)!.casks.clone()
}

fn depends_on_spec_dependency_reaches(target string, token string, mut seen []string) bool {
	if token == target {
		return true
	}
	if token in seen {
		return false
	}
	seen << token
	cask := depends_on_spec_fixture(token)
	dependencies := depends_on_spec_dependencies(cask) or { return false }
	for dependency in dependencies {
		if depends_on_spec_dependency_reaches(target, dependency, mut seen) {
			return true
		}
	}
	return false
}

fn depends_on_spec_requirement_error(cask ruby.Value) ! {
	token := depends_on_spec_token(cask)!
	depends_on := depends_on_spec_typed(token)!
	current_macos := homebrew.new_macos_version((cask.map_data['current_macos'] or {
		ruby.string_value(depends_on_spec_default_macos)
	}).as_string())!
	running_on_macos := (cask.map_data['running_on_macos'] or {
		ruby.bool_value(true)
	}).as_bool()!
	if requirement := depends_on.macos {
		if !requirement.satisfied_on(current_macos, running_on_macos) {
			return error(requirement.message('cask', running_on_macos))
		}
	}
	if requirement := depends_on.maximum_macos {
		if !requirement.satisfied_on(current_macos, running_on_macos) {
			return error(requirement.message('cask', running_on_macos))
		}
	}
	if depends_on.arch.len > 0 {
		current_arch := (cask.map_data['current_arch'] or {
			ruby.string_value('arm')
		}).as_string()
		current_bits := int((cask.map_data['current_bits'] or {
			ruby.int_value(64)
		}).as_int()!)
		if !depends_on.arch.any(it.kind == current_arch && it.bits == current_bits) {
			return error('This cask depends on an unsupported hardware architecture.')
		}
	}
}

fn depends_on_spec_collect_installs(token string, mut visited []string, mut installed []string) ! {
	if token in visited {
		return
	}
	visited << token
	cask := depends_on_spec_fixture(token)
	depends_on_spec_requirement_error(cask)!
	for dependency in depends_on_spec_dependencies(cask)! {
		depends_on_spec_collect_installs(dependency, mut visited, mut installed)!
	}
	installed << token
}

fn depends_on_spec_install(cask ruby.Value) ruby.Value {
	token := depends_on_spec_token(cask) or {
		return ruby.Value{
			type_name: 'Cask::InstallResult'
			repr: err.msg()
			map_data: {
				'installed':     ruby.string_array_value([])
				'error_type':    ruby.string_value('CaskError')
				'error_message': ruby.string_value(err.msg())
			}
		}
	}
	direct_dependencies := depends_on_spec_dependencies(cask) or {
		return ruby.Value{
			type_name: 'Cask::InstallResult'
			repr: err.msg()
			map_data: {
				'installed':     ruby.string_array_value([])
				'error_type':    ruby.string_value('CaskError')
				'error_message': ruby.string_value(err.msg())
			}
		}
	}
	mut cyclic_dependencies := []string{}
	for dependency in direct_dependencies {
		mut seen := []string{}
		if depends_on_spec_dependency_reaches(token, dependency, mut seen) {
			cyclic_dependencies << dependency
		}
	}
	if cyclic_dependencies.len > 0 {
		message := "Cask '${token}' includes cyclic dependencies on other Casks: ${cyclic_dependencies.join(', ')}"
		return ruby.Value{
			type_name: 'Cask::InstallResult'
			repr: message
			map_data: {
				'installed':     ruby.string_array_value([])
				'error_type':    ruby.string_value('Cask::CaskCyclicDependencyError')
				'error_message': ruby.string_value(message)
			}
		}
	}
	depends_on_spec_requirement_error(cask) or {
		return ruby.Value{
			type_name: 'Cask::InstallResult'
			repr: err.msg()
			map_data: {
				'installed':     ruby.string_array_value([])
				'error_type':    ruby.string_value('Cask::CaskError')
				'error_message': ruby.string_value(err.msg())
			}
		}
	}
	mut visited := []string{}
	mut installed := []string{}
	for dependency in direct_dependencies {
		depends_on_spec_collect_installs(dependency, mut visited, mut installed) or {
			return ruby.Value{
				type_name: 'Cask::InstallResult'
				repr: err.msg()
				map_data: {
					'installed':     ruby.string_array_value(installed)
					'error_type':    ruby.string_value('Cask::CaskError')
					'error_message': ruby.string_value(err.msg())
				}
			}
		}
	}
	if token !in installed {
		installed << token
	}
	return ruby.Value{
		type_name: 'Cask::InstallResult'
		repr: installed.str()
		map_data: {
			'installed':     ruby.string_array_value(installed)
			'error_type':    ruby.string_value('')
			'error_message': ruby.string_value('')
		}
	}
}

fn depends_on_spec_result_passed(result ruby.Value) bool {
	return result.type_name == 'Cask::InstallResult' && (result.map_data['error_type'] or { ruby.string_value('missing') }).as_string() == ''
}

// Ruby subject `subject(:install) do` at line 9.
pub fn ruby_depends_on_spec_l9_d1_install(args ...ruby.Value) ruby.Value {
	cask := if args.len > 0 { args[0] } else { depends_on_spec_fixture('with-depends-on-cask') }
	return depends_on_spec_install(cask)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-cask")) }` at line 13.
pub fn ruby_depends_on_spec_l13_d2_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return depends_on_spec_fixture('with-depends-on-cask')
}

// Ruby let `let(:dependency) { Cask::CaskLoader.load(cask.depends_on.cask.first) }` at line 16.
pub fn ruby_depends_on_spec_l16_d3_dependency(args ...ruby.Value) ruby.Value {
	cask := if args.len > 0 { args[0] } else { depends_on_spec_fixture('with-depends-on-cask') }
	dependencies := depends_on_spec_dependencies(cask) or {
		return ruby.object_value('CaskError', err.msg())
	}
	if dependencies.len == 0 {
		return ruby.object_value('CaskError', 'cask has no cask dependency')
	}
	return depends_on_spec_fixture(dependencies[0])
}

// Ruby it `it "installs the dependency of a Cask and the Cask itself" do` at line 18.
pub fn ruby_depends_on_spec_l18_d4_installs(args ...ruby.Value) ruby.Value {
	cask := if args.len > 0 { args[0] } else { ruby_depends_on_spec_l13_d2_cask() }
	dependency := ruby_depends_on_spec_l16_d3_dependency(cask)
	result := ruby_depends_on_spec_l9_d1_install(cask)
	installed := (result.map_data['installed'] or {
		return depends_on_spec_bool(false)
	}).as_string_array() or { return depends_on_spec_bool(false) }
	return depends_on_spec_bool(depends_on_spec_result_passed(result) && depends_on_spec_token(cask) or { '' } in installed && depends_on_spec_token(dependency) or { '' } in installed)
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-cask-cyclic")) }` at line 25.
pub fn ruby_depends_on_spec_l25_d5_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return depends_on_spec_fixture('with-depends-on-cask-cyclic')
}

// Ruby it `it {` at line 27.
pub fn ruby_depends_on_spec_l27_d6_anonymous(args ...ruby.Value) ruby.Value {
	cask := if args.len > 0 { args[0] } else { ruby_depends_on_spec_l25_d5_cask() }
	result := ruby_depends_on_spec_l9_d1_install(cask)
	error_type := (result.map_data['error_type'] or { return depends_on_spec_bool(false) }).as_string()
	error_message := (result.map_data['error_message'] or { return depends_on_spec_bool(false) }).as_string()
	return depends_on_spec_bool(error_type == 'Cask::CaskCyclicDependencyError' && error_message == "Cask 'with-depends-on-cask-cyclic' includes cyclic dependencies on other Casks: with-depends-on-cask-cyclic-helper")
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-array")) }` at line 39.
pub fn ruby_depends_on_spec_l39_d7_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return depends_on_spec_fixture('with-depends-on-macos-array')
}

// Ruby it `it "does not raise an error" do` at line 41.
pub fn ruby_depends_on_spec_l41_d8_does(args ...ruby.Value) ruby.Value {
	cask := if args.len > 0 { args[0] } else { ruby_depends_on_spec_l39_d7_cask() }
	return depends_on_spec_bool(depends_on_spec_result_passed(ruby_depends_on_spec_l9_d1_install(cask)))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-comparison")) }` at line 47.
pub fn ruby_depends_on_spec_l47_d9_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return depends_on_spec_fixture('with-depends-on-macos-comparison')
}

// Ruby it `it "does not raise an error" do` at line 49.
pub fn ruby_depends_on_spec_l49_d10_does(args ...ruby.Value) ruby.Value {
	cask := if args.len > 0 { args[0] } else { ruby_depends_on_spec_l47_d9_cask() }
	return depends_on_spec_bool(depends_on_spec_result_passed(ruby_depends_on_spec_l9_d1_install(cask)))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-symbol")) }` at line 55.
pub fn ruby_depends_on_spec_l55_d11_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return depends_on_spec_fixture('with-depends-on-macos-symbol')
}

// Ruby it `it "does not raise an error" do` at line 57.
pub fn ruby_depends_on_spec_l57_d12_does(args ...ruby.Value) ruby.Value {
	cask := if args.len > 0 { args[0] } else { ruby_depends_on_spec_l55_d11_cask() }
	return depends_on_spec_bool(depends_on_spec_result_passed(ruby_depends_on_spec_l9_d1_install(cask)))
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-failure")) }` at line 63.
pub fn ruby_depends_on_spec_l63_d13_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return depends_on_spec_fixture('with-depends-on-macos-failure')
}

// Ruby it `it "raises an error" do` at line 65.
pub fn ruby_depends_on_spec_l65_d14_raises(args ...ruby.Value) ruby.Value {
	cask := if args.len > 0 { args[0] } else { ruby_depends_on_spec_l63_d13_cask() }
	result := ruby_depends_on_spec_l9_d1_install(cask)
	error_type := (result.map_data['error_type'] or { return depends_on_spec_bool(false) }).as_string()
	error_message := (result.map_data['error_message'] or { return depends_on_spec_bool(false) }).as_string()
	return depends_on_spec_bool(error_type == 'Cask::CaskError' && error_message == 'This cask does not run on macOS versions newer than Monterey.')
}

// Ruby let `let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-arch")) }` at line 74.
pub fn ruby_depends_on_spec_l74_d15_cask(args ...ruby.Value) ruby.Value {
	_ = args
	return depends_on_spec_fixture('with-depends-on-arch')
}

// Ruby it `it "does not raise an error" do` at line 76.
pub fn ruby_depends_on_spec_l76_d16_does(args ...ruby.Value) ruby.Value {
	cask := if args.len > 0 { args[0] } else { ruby_depends_on_spec_l74_d15_cask() }
	return depends_on_spec_bool(depends_on_spec_result_passed(ruby_depends_on_spec_l9_d1_install(cask)))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: # TODO: this test should be named after the corresponding class, once
// 5: #       that class is abstracted from installer.rb
// 6: # rubocop:disable RSpec/DescribeClass
// 7: RSpec.describe "Satisfy Dependencies and Requirements", :cask do
// 8:   # rubocop:enable RSpec/DescribeClass
// 9:   subject(:install) do
// 10:     Cask::Installer.new(cask).install
// 11:   end
// 12:
// 13:   let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-cask")) }
// 14:
// 15:   describe "depends_on cask" do
// 16:     let(:dependency) { Cask::CaskLoader.load(cask.depends_on.cask.first) }
// 17:
// 18:     it "installs the dependency of a Cask and the Cask itself" do
// 19:       expect { install }.not_to raise_error
// 20:       expect(cask).to be_installed
// 21:       expect(dependency).to be_installed
// 22:     end
// 23:
// 24:     context "when depends_on cask is cyclic" do
// 25:       let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-cask-cyclic")) }
// 26:
// 27:       it {
// 28:         expect { install }.to raise_error(
// 29:           Cask::CaskCyclicDependencyError,
// 30:           "Cask 'with-depends-on-cask-cyclic' includes cyclic dependencies " \
// 31:           "on other Casks: with-depends-on-cask-cyclic-helper",
// 32:         )
// 33:       }
// 34:     end
// 35:   end
// 36:
// 37:   describe "depends_on macos" do
// 38:     context "with an array" do
// 39:       let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-array")) }
// 40:
// 41:       it "does not raise an error" do
// 42:         expect { install }.not_to raise_error
// 43:       end
// 44:     end
// 45:
// 46:     context "with a comparison" do
// 47:       let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-comparison")) }
// 48:
// 49:       it "does not raise an error" do
// 50:         expect { install }.not_to raise_error
// 51:       end
// 52:     end
// 53:
// 54:     context "with a symbol" do
// 55:       let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-symbol")) }
// 56:
// 57:       it "does not raise an error" do
// 58:         expect { install }.not_to raise_error
// 59:       end
// 60:     end
// 61:
// 62:     context "when not satisfied" do
// 63:       let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-macos-failure")) }
// 64:
// 65:       it "raises an error" do
// 66:         allow(OS::Mac).to receive(:version).and_return(MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED))
// 67:         expect { install }.to raise_error(Cask::CaskError)
// 68:       end
// 69:     end
// 70:   end
// 71:
// 72:   describe "depends_on arch" do
// 73:     context "when satisfied" do
// 74:       let(:cask) { Cask::CaskLoader.load(cask_path("with-depends-on-arch")) }
// 75:
// 76:       it "does not raise an error" do
// 77:         expect { install }.not_to raise_error
// 78:       end
// 79:     end
// 80:   end
// 81: end

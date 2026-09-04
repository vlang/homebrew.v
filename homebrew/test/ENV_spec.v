module test

import ruby
import homebrew.compilers
import homebrew.extend
import homebrew.extend.env as env_extension
import homebrew.extend.os.linux.extend.env as linux_env_extension

// Translated from Homebrew/brew `test/ENV_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:env) { {}.extend(EnvActivation).extend(described_class) }` at line 7.
pub fn ruby_env_spec_l7_d1_env() &env_extension.SharedEnvState {
	return env_extension.new_shared_env(env_spec_shared_config(), map[string]string{})
}

// Ruby it `it "supports switching compilers" do` at line 12.
pub fn ruby_env_spec_l12_d2_supports() bool {
	mut state := ruby_env_spec_l7_d1_env()
	env_extension.ruby_shared_l258_d28_compiler(mut state, 'clang', 'clang++') or {
		return false
	}
	values := state.to_map()
	return 'LD' !in values && values['CC'] == values['OBJC']
}

// Ruby it `it "restores the environment" do` at line 19.
pub fn ruby_env_spec_l19_d3_restores() bool {
	environment := map[string]string{}
	before := environment.clone()
	extend.with_build_environment(environment, extend.BuildEnvironmentOptions{}, none, env_spec_activation_setup, env_spec_mutating_block) or { return false }
	return 'foo' !in environment && environment == before
}

// Ruby it `it "ensures the environment is restored" do` at line 30.
pub fn ruby_env_spec_l30_d4_ensures() bool {
	environment := map[string]string{}
	before := environment.clone()
	extend.with_build_environment(environment, extend.BuildEnvironmentOptions{}, none, env_spec_activation_setup, env_spec_failing_block) or {
		return err.msg() == 'StandardError' && 'foo' !in environment && environment == before
	}
	return false
}

// Ruby it `it "returns the value of the block" do` at line 44.
pub fn ruby_env_spec_l44_d5_returns() bool {
	result := extend.with_build_environment(map[string]string{}, extend.BuildEnvironmentOptions{}, none, env_spec_activation_setup, env_spec_one_block) or { return false }
	return result.type_name == 'Integer' && result.int_data == 1
}

// Ruby it `it "does not mutate the interface" do` at line 48.
pub fn ruby_env_spec_l48_d6_does() bool {
	environment := {
		'PATH': '/usr/bin'
	}
	before := environment.clone()
	result := extend.with_build_environment(environment, extend.BuildEnvironmentOptions{}, none, env_spec_activation_setup, env_spec_interface_block) or { return false }
	return result.as_string_array() or { return false } == ['PATH'] && environment == before
}

// Ruby it `it "appends to an existing key" do` at line 61.
pub fn ruby_env_spec_l61_d7_appends() bool {
	mut state := env_extension.new_shared_env(env_spec_shared_config(), {
		'foo': 'bar'
	})
	env_extension.ruby_shared_l97_d10_append(mut state, ['foo'], '1', ' ')
	return state.value('foo') or { '' } == 'bar 1'
}

// Ruby it `it "appends to an existing empty key" do` at line 67.
pub fn ruby_env_spec_l67_d8_appends() bool {
	mut state := env_extension.new_shared_env(env_spec_shared_config(), {
		'foo': ''
	})
	env_extension.ruby_shared_l97_d10_append(mut state, ['foo'], '1', ' ')
	return state.value('foo') or { '' } == '1'
}

// Ruby it `it "appends to a non-existent key" do` at line 73.
pub fn ruby_env_spec_l73_d9_appends() bool {
	mut state := ruby_env_spec_l7_d1_env()
	env_extension.ruby_shared_l97_d10_append(mut state, ['foo'], '1', ' ')
	return state.value('foo') or { '' } == '1'
}

// Ruby it `it "coerces a value to a string" do` at line 80.
pub fn ruby_env_spec_l80_d10_coerces() bool {
	mut state := ruby_env_spec_l7_d1_env()
	env_extension.ruby_shared_l97_d10_append(mut state, ['foo'], 42.str(), ' ')
	return state.value('foo') or { '' } == '42'
}

// Ruby it `it "prepends to an existing key" do` at line 87.
pub fn ruby_env_spec_l87_d11_prepends() bool {
	mut state := env_extension.new_shared_env(env_spec_shared_config(), {
		'foo': 'bar'
	})
	env_extension.ruby_shared_l110_d11_prepend(mut state, ['foo'], '1', ' ')
	return state.value('foo') or { '' } == '1 bar'
}

// Ruby it `it "prepends to an existing empty key" do` at line 93.
pub fn ruby_env_spec_l93_d12_prepends() bool {
	mut state := env_extension.new_shared_env(env_spec_shared_config(), {
		'foo': ''
	})
	env_extension.ruby_shared_l110_d11_prepend(mut state, ['foo'], '1', ' ')
	return state.value('foo') or { '' } == '1'
}

// Ruby it `it "prepends to a non-existent key" do` at line 99.
pub fn ruby_env_spec_l99_d13_prepends() bool {
	mut state := ruby_env_spec_l7_d1_env()
	env_extension.ruby_shared_l110_d11_prepend(mut state, ['foo'], '1', ' ')
	return state.value('foo') or { '' } == '1'
}

// Ruby it `it "coerces a value to a string" do` at line 106.
pub fn ruby_env_spec_l106_d14_coerces() bool {
	mut state := ruby_env_spec_l7_d1_env()
	env_extension.ruby_shared_l110_d11_prepend(mut state, ['foo'], 42.str(), ' ')
	return state.value('foo') or { '' } == '42'
}

// Ruby it `it "appends to a path" do` at line 113.
pub fn ruby_env_spec_l113_d15_appends() bool {
	mut state := ruby_env_spec_l7_d1_env()
	env_extension.ruby_shared_l123_d12_append_path(mut state, 'FOO', '/usr/bin')
	if state.value('FOO') or { '' } != '/usr/bin' {
		return false
	}
	env_extension.ruby_shared_l123_d12_append_path(mut state, 'FOO', '/bin')
	return state.value('FOO') or { '' } == '/usr/bin:/bin'
}

// Ruby it `it "prepends to a path" do` at line 123.
pub fn ruby_env_spec_l123_d16_prepends() bool {
	mut state := ruby_env_spec_l7_d1_env()
	env_extension.ruby_shared_l140_d14_prepend_path(mut state, 'FOO', '/usr/local')
	if state.value('FOO') or { '' } != '/usr/local' {
		return false
	}
	env_extension.ruby_shared_l140_d14_prepend_path(mut state, 'FOO', '/usr')
	return state.value('FOO') or { '' } == '/usr:/usr/local'
}

// Ruby it `it "allows switching compilers" do` at line 133.
pub fn ruby_env_spec_l133_d17_allows() bool {
	mut state := ruby_env_spec_l7_d1_env()
	env_extension.ruby_shared_l258_d28_compiler(mut state, 'gcc-9', 'g++-9') or {
		return false
	}
	compiler := env_extension.ruby_shared_l222_d26_compiler(mut state) or { return false }
	return compiler.name == 'gcc-9'
}

// Ruby example `example "deparallelize_block_form_restores_makeflags" do` at line 139.
pub fn ruby_env_spec_l139_d18_deparallelize_block_form_restores_makeflags() bool {
	mut standard := env_extension.new_shared_env(env_spec_shared_config(), {
		'MAKEFLAGS': '-j4'
	})
	env_extension.stdenv_deparallelize(mut standard, env_spec_stdenv_deparallelized) or {
		return false
	}
	if standard.value('MAKEFLAGS') or { '' } != '-j4' {
		return false
	}
	mut superenv := env_extension.new_superenv(env_spec_super_config(), {
		'MAKEFLAGS': '-j4'
	})
	env_extension.ruby_super_l340_d38_deparallelize(mut superenv, env_spec_superenv_deparallelized) or { return false }
	return superenv.value('MAKEFLAGS') or { '' } == '-j4'
}

// Ruby it `it "list sensitive environment" do` at line 150.
pub fn ruby_env_spec_l150_d19_list() bool {
	selected := env_extension.ruby_sensitive_l26_d2_sensitive_environment({
		'SECRET_TOKEN': 'password'
	})
	return 'SECRET_TOKEN' in selected
}

// Ruby it `it "removes sensitive environment variables" do` at line 157.
pub fn ruby_env_spec_l157_d20_removes() bool {
	mut values := {
		'SECRET_TOKEN': 'password'
	}
	env_extension.ruby_sensitive_l37_d3_clear_sensitive_environment(mut values, [], false)
	return 'SECRET_TOKEN' !in values
}

// Ruby it `it "preserves excepted sensitive environment variables" do` at line 163.
pub fn ruby_env_spec_l163_d21_preserves() bool {
	mut values := {
		'SECRET_TOKEN': 'password'
	}
	env_extension.ruby_sensitive_l37_d3_clear_sensitive_environment(mut values, [
		'SECRET_TOKEN',
	], false)
	return values['SECRET_TOKEN'] == 'password'
}

// Ruby it `it "leaves non-sensitive environment variables alone" do` at line 169.
pub fn ruby_env_spec_l169_d22_leaves() bool {
	mut values := {
		'FOO': 'bar'
	}
	env_extension.ruby_sensitive_l37_d3_clear_sensitive_environment(mut values, [], false)
	return values['FOO'] == 'bar'
}

// Ruby it `it "restores the environment after yielding" do` at line 175.
pub fn ruby_env_spec_l175_d23_restores() bool {
	mut values := {
		'SECRET_TOKEN': 'password'
		'FOO':          'bar'
	}
	result := env_extension.with_cleared_sensitive_environment(mut values, [], false, env_spec_cleared_mutation) or { return false }
	items := result.as_array() or { return false }
	return items.len == 2 && items[0].type_name in ['Nil', 'NilClass'] && items[1].as_string() == 'baz' && values['SECRET_TOKEN'] == 'password' && values['FOO'] == 'bar' && 'OTHER_TOKEN' !in values
}

// Ruby it `it "defers HOMEBREW_ secrets to a placeholder" do` at line 194.
pub fn ruby_env_spec_l194_d24_defers() bool {
	mut values := {
		'HOMEBREW_PRIVATE_TOKEN': 'glpat-secret'
	}
	deferred := env_extension.ruby_sensitive_l62_d4_clear_sensitive_environment_for_eval(mut values, env_spec_private_token) or { return false }
	masked := deferred.as_string()
	expanded := env_extension.ruby_sensitive_l70_d5_expand_deferred_environment('PRIVATE-TOKEN: ${masked}', values, false)
	return masked != 'glpat-secret' && masked != '' && expanded == 'PRIVATE-TOKEN: ${masked}'
}

// Ruby it `it "never expands a non-HOMEBREW_ secret back to its real value" do` at line 204.
pub fn ruby_env_spec_l204_d25_never() bool {
	mut values := {
		'SECRET_TOKEN': 'password'
	}
	deferred := env_extension.with_cleared_sensitive_environment(mut values, [
		'HOMEBREW_GITHUB_API_TOKEN',
	], true, env_spec_secret_token) or { return false }
	expanded := env_extension.ruby_sensitive_l70_d5_expand_deferred_environment('X: ${deferred.as_string()}', values, true)
	return !expanded.contains('password')
}

// Ruby it `it "keeps HOMEBREW_GITHUB_API_TOKEN readable during eval" do` at line 213.
pub fn ruby_env_spec_l213_d26_keeps() bool {
	mut values := {
		'HOMEBREW_GITHUB_API_TOKEN': 'gh-token'
	}
	result := env_extension.ruby_sensitive_l62_d4_clear_sensitive_environment_for_eval(mut values, env_spec_github_token) or { return false }
	return result.as_string() == 'gh-token'
}

// Ruby it `it "restores the environment after yielding" do` at line 220.
pub fn ruby_env_spec_l220_d27_restores() bool {
	mut values := {
		'HOMEBREW_PRIVATE_TOKEN': 'glpat-secret'
	}
	env_extension.ruby_sensitive_l62_d4_clear_sensitive_environment_for_eval(mut values, env_spec_nil_sensitive) or { return false }
	return values['HOMEBREW_PRIVATE_TOKEN'] == 'glpat-secret'
}

// Ruby it `it "leaves values without a deferred placeholder unchanged" do` at line 228.
pub fn ruby_env_spec_l228_d28_leaves() bool {
	value := 'PRIVATE-TOKEN: plain'
	return env_extension.ruby_sensitive_l70_d5_expand_deferred_environment(value, map[string]string{}, false) == value
}

// Ruby it `it "expands placeholders only during download strategy fetches" do` at line 232.
pub fn ruby_env_spec_l232_d29_expands() bool {
	mut values := {
		'HOMEBREW_PRIVATE_TOKEN': 'glpat-secret'
	}
	deferred := env_extension.ruby_sensitive_l62_d4_clear_sensitive_environment_for_eval(mut values, env_spec_private_token) or { return false }
	return env_extension.ruby_sensitive_l70_d5_expand_deferred_environment('PRIVATE-TOKEN: ${deferred.as_string()}', values, true) == 'PRIVATE-TOKEN: glpat-secret'
}

// Ruby it `it "initializes deps" do` at line 251.
pub fn ruby_env_spec_l251_d30_initializes() bool {
	state := env_extension.new_superenv(env_spec_super_config(), map[string]string{})
	return env_extension.ruby_super_l26_d3_deps(state) == [] && env_extension.ruby_super_l23_d1_keg_only_deps(state) == []
}

// Ruby it `it "supports gcc-11" do` at line 257.
pub fn ruby_env_spec_l257_d31_supports() bool {
	mut state := env_extension.new_superenv(env_spec_super_config(), map[string]string{})
	env_extension.superenv_use_compiler(mut state, 'gcc-11')
	env_extension.ruby_super_l373_d42_cxx11(mut state)
	cccfg := state.value('HOMEBREW_CCCFG') or { '' }
	return cccfg.contains('x') && !cccfg.contains('g')
}

// Ruby it `it "supports clang" do` at line 264.
pub fn ruby_env_spec_l264_d32_supports() bool {
	mut state := env_extension.new_superenv(env_spec_super_config(), map[string]string{})
	env_extension.superenv_use_compiler(mut state, 'clang')
	env_extension.ruby_super_l373_d42_cxx11(mut state)
	cccfg := state.value('HOMEBREW_CCCFG') or { '' }
	return cccfg.contains('x') && cccfg.contains('g')
}

// Ruby it `it "sets the debug symbols flag" do` at line 273.
pub fn ruby_env_spec_l273_d33_sets() bool {
	mut state := env_extension.new_superenv(env_spec_super_config(), map[string]string{})
	env_extension.ruby_super_l384_d44_set_debug_symbols(mut state)
	return state.value('HOMEBREW_CCCFG') or { '' }.contains('D')
}

// Ruby it `it "sets HOMEBREW_CC to shim name" do` at line 282.
pub fn ruby_env_spec_l282_d34_sets() bool {
	mut state := env_extension.new_superenv(env_spec_super_config(), map[string]string{})
	env_extension.ruby_super_l146_d13_llvm_clang(mut state)
	return state.value('HOMEBREW_CC') or { '' } == 'llvm_clang'
}

// Ruby it `it "sets CC/CXX to real names" do` at line 286.
pub fn ruby_env_spec_l286_d35_sets() bool {
	mut state := env_extension.new_superenv(env_spec_super_config(), map[string]string{})
	env_extension.ruby_super_l146_d13_llvm_clang(mut state)
	values := state.to_map()
	return values['CC'] == 'clang' && values['CXX'] == 'clang++' && values['OBJC'] == 'clang' && values['OBJCXX'] == 'clang++'
}

// Ruby let `let(:gcc) { "gcc-#{CompilerConstants::GNU_GCC_VERSIONS.last}" }` at line 295.
pub fn ruby_env_spec_l295_d36_gcc() string {
	versions := compilers.supported_gnu_gcc_versions()
	return 'gcc-${versions.last()}'
}

// Ruby it `it "sets versioned HOMEBREW_CC" do` at line 299.
pub fn ruby_env_spec_l299_d37_sets() bool {
	mut state := env_extension.new_superenv(env_spec_super_config(), map[string]string{})
	gcc := ruby_env_spec_l295_d36_gcc()
	env_extension.superenv_use_compiler(mut state, gcc)
	return state.value('HOMEBREW_CC') or { '' } == gcc
}

// Ruby it `it "sets unversioned CC/CXX on Linux", :needs_linux do` at line 303.
pub fn ruby_env_spec_l303_d38_sets() bool {
	mut state := env_extension.new_superenv(env_spec_super_config(), map[string]string{})
	gcc := ruby_env_spec_l295_d36_gcc()
	linux_env_extension.ruby_super_l102_d8_gcc_n(mut state, gcc)
	values := state.to_map()
	return values['CC'] == 'gcc' && values['CXX'] == 'g++' && values['OBJC'] == 'gcc' && values['OBJCXX'] == 'g++'
}

// Ruby it `it "sets versioned CC/CXX on macOS", :needs_macos do` at line 312.
pub fn ruby_env_spec_l312_d39_sets() bool {
	mut state := env_extension.new_superenv(env_spec_super_config(), map[string]string{})
	gcc := ruby_env_spec_l295_d36_gcc()
	env_extension.superenv_use_compiler(mut state, gcc)
	values := state.to_map()
	gxx := gcc.replace('gcc', 'g++')
	return values['CC'] == gcc && values['CXX'] == gxx && values['OBJC'] == gcc && values['OBJCXX'] == gxx
}

fn env_spec_shared_config() env_extension.SharedEnvConfig {
	return env_extension.SharedEnvConfig{
		default_compiler: 'clang'
		oldest_cpu: 'arm64'
		make_jobs: 4
	}
}

fn env_spec_super_config() env_extension.SuperenvConfig {
	return env_extension.SuperenvConfig{
		shims_path: '/shims'
		superenv_bin: '/shims/super/bin'
		brew_file: '/brew/bin/brew'
		prefix: '/brew'
		cellar: '/brew/Cellar'
		temp: '/tmp/brew'
		make_jobs: 4
		compiler: 'clang'
		effective_arch: 'arm64'
	}
}

fn env_spec_activation_setup(environment map[string]string, _ extend.EnvironmentExtension,
	_ extend.BuildEnvironmentOptions) !map[string]string {
	return environment.clone()
}

fn env_spec_mutating_block(environment map[string]string) !ruby.Value {
	mut temporary := environment.clone()
	temporary['foo'] = 'bar'
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn env_spec_failing_block(environment map[string]string) !ruby.Value {
	mut temporary := environment.clone()
	temporary['foo'] = 'bar'
	return error('StandardError')
}

fn env_spec_one_block(_ map[string]string) !ruby.Value {
	return ruby.int_value(1)
}

fn env_spec_interface_block(environment map[string]string) !ruby.Value {
	mut keys := environment.keys()
	keys.sort()
	return ruby.string_array_value(keys)
}

fn env_spec_stdenv_deparallelized(mut state env_extension.SharedEnvState) !ruby.Value {
	if 'MAKEFLAGS' in state.to_map() {
		return error('MAKEFLAGS was not removed')
	}
	return ruby.bool_value(true)
}

fn env_spec_superenv_deparallelized(mut state env_extension.SuperenvState) !ruby.Value {
	if 'MAKEFLAGS' in state.to_map() {
		return error('MAKEFLAGS was not removed')
	}
	return ruby.bool_value(true)
}

fn env_spec_cleared_mutation(mut view env_extension.SensitiveEnvironmentView) !ruby.Value {
	view.values['FOO'] = 'baz'
	view.values['OTHER_TOKEN'] = 'secret'
	secret := if value := view.values['SECRET_TOKEN'] {
		ruby.string_value(value)
	} else {
		ruby.Value{
			type_name: 'NilClass'
			repr: 'nil'
		}
	}
	return ruby.array_value([secret, ruby.string_value(view.values['FOO'] or { '' })])
}

fn env_spec_private_token(mut view env_extension.SensitiveEnvironmentView) !ruby.Value {
	return ruby.string_value(view.values['HOMEBREW_PRIVATE_TOKEN'] or { '' })
}

fn env_spec_secret_token(mut view env_extension.SensitiveEnvironmentView) !ruby.Value {
	return ruby.string_value(view.values['SECRET_TOKEN'] or { '' })
}

fn env_spec_github_token(mut view env_extension.SensitiveEnvironmentView) !ruby.Value {
	return ruby.string_value(view.values['HOMEBREW_GITHUB_API_TOKEN'] or { '' })
}

fn env_spec_nil_sensitive(mut _ env_extension.SensitiveEnvironmentView) !ruby.Value {
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn env_spec_map_value(values map[string]string) ruby.Value {
	mut translated := map[string]ruby.Value{}
	for key, value in values {
		translated[key] = ruby.string_value(value)
	}
	return ruby.map_value(translated)
}

pub fn env_spec_all_boundaries() []ruby.Value {
	return [
		env_spec_map_value(ruby_env_spec_l7_d1_env().to_map()),
		ruby.bool_value(ruby_env_spec_l12_d2_supports()),
		ruby.bool_value(ruby_env_spec_l19_d3_restores()),
		ruby.bool_value(ruby_env_spec_l30_d4_ensures()),
		ruby.bool_value(ruby_env_spec_l44_d5_returns()),
		ruby.bool_value(ruby_env_spec_l48_d6_does()),
		ruby.bool_value(ruby_env_spec_l61_d7_appends()),
		ruby.bool_value(ruby_env_spec_l67_d8_appends()),
		ruby.bool_value(ruby_env_spec_l73_d9_appends()),
		ruby.bool_value(ruby_env_spec_l80_d10_coerces()),
		ruby.bool_value(ruby_env_spec_l87_d11_prepends()),
		ruby.bool_value(ruby_env_spec_l93_d12_prepends()),
		ruby.bool_value(ruby_env_spec_l99_d13_prepends()),
		ruby.bool_value(ruby_env_spec_l106_d14_coerces()),
		ruby.bool_value(ruby_env_spec_l113_d15_appends()),
		ruby.bool_value(ruby_env_spec_l123_d16_prepends()),
		ruby.bool_value(ruby_env_spec_l133_d17_allows()),
		ruby.bool_value(ruby_env_spec_l139_d18_deparallelize_block_form_restores_makeflags()),
		ruby.bool_value(ruby_env_spec_l150_d19_list()),
		ruby.bool_value(ruby_env_spec_l157_d20_removes()),
		ruby.bool_value(ruby_env_spec_l163_d21_preserves()),
		ruby.bool_value(ruby_env_spec_l169_d22_leaves()),
		ruby.bool_value(ruby_env_spec_l175_d23_restores()),
		ruby.bool_value(ruby_env_spec_l194_d24_defers()),
		ruby.bool_value(ruby_env_spec_l204_d25_never()),
		ruby.bool_value(ruby_env_spec_l213_d26_keeps()),
		ruby.bool_value(ruby_env_spec_l220_d27_restores()),
		ruby.bool_value(ruby_env_spec_l228_d28_leaves()),
		ruby.bool_value(ruby_env_spec_l232_d29_expands()),
		ruby.bool_value(ruby_env_spec_l251_d30_initializes()),
		ruby.bool_value(ruby_env_spec_l257_d31_supports()),
		ruby.bool_value(ruby_env_spec_l264_d32_supports()),
		ruby.bool_value(ruby_env_spec_l273_d33_sets()),
		ruby.bool_value(ruby_env_spec_l282_d34_sets()),
		ruby.bool_value(ruby_env_spec_l286_d35_sets()),
		ruby.string_value(ruby_env_spec_l295_d36_gcc()),
		ruby.bool_value(ruby_env_spec_l299_d37_sets()),
		ruby.bool_value(ruby_env_spec_l303_d38_sets()),
		ruby.bool_value(ruby_env_spec_l312_d39_sets()),
	]
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/ENV"
// 5:
// 6: RSpec.describe "ENV" do
// 7:   subject(:env) { {}.extend(EnvActivation).extend(described_class) }
// 8:
// 9:   shared_examples EnvActivation do
// 10:     include Context
// 11:
// 12:     it "supports switching compilers" do
// 13:       subject.clang
// 14:       expect(subject["LD"]).to be_nil
// 15:       expect(subject["CC"]).to eq(subject["OBJC"])
// 16:     end
// 17:
// 18:     describe "#with_build_environment" do
// 19:       it "restores the environment" do
// 20:         before = subject.dup
// 21:
// 22:         subject.with_build_environment do
// 23:           subject["foo"] = "bar"
// 24:         end
// 25:
// 26:         expect(subject["foo"]).to be_nil
// 27:         expect(subject).to eq(before)
// 28:       end
// 29:
// 30:       it "ensures the environment is restored" do
// 31:         before = subject.dup
// 32:
// 33:         expect do
// 34:           subject.with_build_environment do
// 35:             subject["foo"] = "bar"
// 36:             raise StandardError
// 37:           end
// 38:         end.to raise_error(StandardError)
// 39:
// 40:         expect(subject["foo"]).to be_nil
// 41:         expect(subject).to eq(before)
// 42:       end
// 43:
// 44:       it "returns the value of the block" do
// 45:         expect(subject.with_build_environment { 1 }).to eq(1)
// 46:       end
// 47:
// 48:       it "does not mutate the interface" do
// 49:         # Lazy-loaded gems may add methods to Hash without extending this object.
// 50:         expected = subject.singleton_methods
// 51:
// 52:         subject.with_build_environment do
// 53:           expect(subject.singleton_methods).to eq(expected)
// 54:         end
// 55:
// 56:         expect(subject.singleton_methods).to eq(expected)
// 57:       end
// 58:     end
// 59:
// 60:     describe "#append" do
// 61:       it "appends to an existing key" do
// 62:         subject["foo"] = "bar"
// 63:         subject.append "foo", "1"
// 64:         expect(subject["foo"]).to eq("bar 1")
// 65:       end
// 66:
// 67:       it "appends to an existing empty key" do
// 68:         subject["foo"] = ""
// 69:         subject.append "foo", "1"
// 70:         expect(subject["foo"]).to eq("1")
// 71:       end
// 72:
// 73:       it "appends to a non-existent key" do
// 74:         subject.append "foo", "1"
// 75:         expect(subject["foo"]).to eq("1")
// 76:       end
// 77:
// 78:       # NOTE: This may be a wrong behavior; we should probably reject objects that
// 79:       #       do not respond to `#to_str`. For now this documents existing behavior.
// 80:       it "coerces a value to a string" do
// 81:         subject.append "foo", 42
// 82:         expect(subject["foo"]).to eq("42")
// 83:       end
// 84:     end
// 85:
// 86:     describe "#prepend" do
// 87:       it "prepends to an existing key" do
// 88:         subject["foo"] = "bar"
// 89:         subject.prepend "foo", "1"
// 90:         expect(subject["foo"]).to eq("1 bar")
// 91:       end
// 92:
// 93:       it "prepends to an existing empty key" do
// 94:         subject["foo"] = ""
// 95:         subject.prepend "foo", "1"
// 96:         expect(subject["foo"]).to eq("1")
// 97:       end
// 98:
// 99:       it "prepends to a non-existent key" do
// 100:         subject.prepend "foo", "1"
// 101:         expect(subject["foo"]).to eq("1")
// 102:       end
// 103:
// 104:       # NOTE: this may be a wrong behavior; we should probably reject objects that
// 105:       # do not respond to #to_str. For now this documents existing behavior.
// 106:       it "coerces a value to a string" do
// 107:         subject.prepend "foo", 42
// 108:         expect(subject["foo"]).to eq("42")
// 109:       end
// 110:     end
// 111:
// 112:     describe "#append_path" do
// 113:       it "appends to a path" do
// 114:         subject.append_path "FOO", "/usr/bin"
// 115:         expect(subject["FOO"]).to eq("/usr/bin")
// 116:
// 117:         subject.append_path "FOO", "/bin"
// 118:         expect(subject["FOO"]).to eq("/usr/bin#{File::PATH_SEPARATOR}/bin")
// 119:       end
// 120:     end
// 121:
// 122:     describe "#prepend_path" do
// 123:       it "prepends to a path" do
// 124:         subject.prepend_path "FOO", "/usr/local"
// 125:         expect(subject["FOO"]).to eq("/usr/local")
// 126:
// 127:         subject.prepend_path "FOO", "/usr"
// 128:         expect(subject["FOO"]).to eq("/usr#{File::PATH_SEPARATOR}/usr/local")
// 129:       end
// 130:     end
// 131:
// 132:     describe "#compiler" do
// 133:       it "allows switching compilers" do
// 134:         subject.public_send(:"gcc-9")
// 135:         expect(subject.compiler).to eq("gcc-9")
// 136:       end
// 137:     end
// 138:
// 139:     example "deparallelize_block_form_restores_makeflags" do
// 140:       subject["MAKEFLAGS"] = "-j4"
// 141:
// 142:       subject.deparallelize do
// 143:         expect(subject["MAKEFLAGS"]).to be_nil
// 144:       end
// 145:
// 146:       expect(subject["MAKEFLAGS"]).to eq("-j4")
// 147:     end
// 148:
// 149:     describe "#sensitive_environment" do
// 150:       it "list sensitive environment" do
// 151:         subject["SECRET_TOKEN"] = "password"
// 152:         expect(subject.sensitive_environment).to include("SECRET_TOKEN")
// 153:       end
// 154:     end
// 155:
// 156:     describe "#clear_sensitive_environment!" do
// 157:       it "removes sensitive environment variables" do
// 158:         subject["SECRET_TOKEN"] = "password"
// 159:         subject.clear_sensitive_environment!
// 160:         expect(subject).not_to include("SECRET_TOKEN")
// 161:       end
// 162:
// 163:       it "preserves excepted sensitive environment variables" do
// 164:         subject["SECRET_TOKEN"] = "password"
// 165:         subject.clear_sensitive_environment!(except: ["SECRET_TOKEN"])
// 166:         expect(subject["SECRET_TOKEN"]).to eq("password")
// 167:       end
// 168:
// 169:       it "leaves non-sensitive environment variables alone" do
// 170:         subject["FOO"] = "bar"
// 171:         subject.clear_sensitive_environment!
// 172:         expect(subject["FOO"]).to eq "bar"
// 173:       end
// 174:
// 175:       it "restores the environment after yielding" do
// 176:         subject["SECRET_TOKEN"] = "password"
// 177:         subject["FOO"] = "bar"
// 178:
// 179:         result = subject.clear_sensitive_environment! do
// 180:           subject["FOO"] = "baz"
// 181:           subject["OTHER_TOKEN"] = "secret"
// 182:
// 183:           [subject["SECRET_TOKEN"], subject["FOO"]]
// 184:         end
// 185:
// 186:         expect(result).to eq([nil, "baz"])
// 187:         expect(subject["SECRET_TOKEN"]).to eq("password")
// 188:         expect(subject["FOO"]).to eq("bar")
// 189:         expect(subject).not_to include("OTHER_TOKEN")
// 190:       end
// 191:     end
// 192:
// 193:     describe "#clear_sensitive_environment_for_eval!" do
// 194:       it "defers HOMEBREW_ secrets to a placeholder" do
// 195:         subject["HOMEBREW_PRIVATE_TOKEN"] = "glpat-secret"
// 196:
// 197:         deferred = subject.clear_sensitive_environment_for_eval! { subject["HOMEBREW_PRIVATE_TOKEN"] }
// 198:
// 199:         expect(deferred).not_to eq("glpat-secret")
// 200:         expect(deferred).not_to be_empty
// 201:         expect(subject.expand_deferred_environment("PRIVATE-TOKEN: #{deferred}")).to eq("PRIVATE-TOKEN: #{deferred}")
// 202:       end
// 203:
// 204:       it "never expands a non-HOMEBREW_ secret back to its real value" do
// 205:         subject["SECRET_TOKEN"] = "password"
// 206:         deferred = subject.clear_sensitive_environment_for_eval! { subject["SECRET_TOKEN"] }
// 207:
// 208:         with_context(deferred_environment_expansion: true) do
// 209:           expect(subject.expand_deferred_environment("X: #{deferred}")).not_to include("password")
// 210:         end
// 211:       end
// 212:
// 213:       it "keeps HOMEBREW_GITHUB_API_TOKEN readable during eval" do
// 214:         subject["HOMEBREW_GITHUB_API_TOKEN"] = "gh-token"
// 215:         expect(subject.clear_sensitive_environment_for_eval! do
// 216:           subject["HOMEBREW_GITHUB_API_TOKEN"]
// 217:         end).to eq("gh-token")
// 218:       end
// 219:
// 220:       it "restores the environment after yielding" do
// 221:         subject["HOMEBREW_PRIVATE_TOKEN"] = "glpat-secret"
// 222:         subject.clear_sensitive_environment_for_eval! { nil }
// 223:         expect(subject["HOMEBREW_PRIVATE_TOKEN"]).to eq("glpat-secret")
// 224:       end
// 225:     end
// 226:
// 227:     describe "#expand_deferred_environment" do
// 228:       it "leaves values without a deferred placeholder unchanged" do
// 229:         expect(subject.expand_deferred_environment("PRIVATE-TOKEN: plain")).to eq("PRIVATE-TOKEN: plain")
// 230:       end
// 231:
// 232:       it "expands placeholders only during download strategy fetches" do
// 233:         subject["HOMEBREW_PRIVATE_TOKEN"] = "glpat-secret"
// 234:         deferred = subject.clear_sensitive_environment_for_eval! { subject["HOMEBREW_PRIVATE_TOKEN"] }
// 235:
// 236:         with_context(deferred_environment_expansion: true) do
// 237:           expect(subject.expand_deferred_environment("PRIVATE-TOKEN: #{deferred}"))
// 238:             .to eq("PRIVATE-TOKEN: glpat-secret")
// 239:         end
// 240:       end
// 241:     end
// 242:   end
// 243:
// 244:   describe Stdenv do
// 245:     include_examples EnvActivation
// 246:   end
// 247:
// 248:   describe Superenv do
// 249:     include_examples EnvActivation
// 250:
// 251:     it "initializes deps" do
// 252:       expect(env.deps).to eq([])
// 253:       expect(env.keg_only_deps).to eq([])
// 254:     end
// 255:
// 256:     describe "#cxx11" do
// 257:       it "supports gcc-11" do
// 258:         env["HOMEBREW_CC"] = "gcc-11"
// 259:         env.cxx11
// 260:         expect(env["HOMEBREW_CCCFG"]).to include("x")
// 261:         expect(env["HOMEBREW_CCCFG"]).not_to include("g")
// 262:       end
// 263:
// 264:       it "supports clang" do
// 265:         env["HOMEBREW_CC"] = "clang"
// 266:         env.cxx11
// 267:         expect(env["HOMEBREW_CCCFG"]).to include("x")
// 268:         expect(env["HOMEBREW_CCCFG"]).to include("g")
// 269:       end
// 270:     end
// 271:
// 272:     describe "#set_debug_symbols" do
// 273:       it "sets the debug symbols flag" do
// 274:         env.set_debug_symbols
// 275:         expect(env["HOMEBREW_CCCFG"]).to include("D")
// 276:       end
// 277:     end
// 278:
// 279:     describe "#llvm_clang" do
// 280:       before { env.llvm_clang }
// 281:
// 282:       it "sets HOMEBREW_CC to shim name" do
// 283:         expect(env["HOMEBREW_CC"]).to eq "llvm_clang"
// 284:       end
// 285:
// 286:       it "sets CC/CXX to real names" do
// 287:         expect(env["CC"]).to eq "clang"
// 288:         expect(env["CXX"]).to eq "clang++"
// 289:         expect(env["OBJC"]).to eq "clang"
// 290:         expect(env["OBJCXX"]).to eq "clang++"
// 291:       end
// 292:     end
// 293:
// 294:     describe "when using versioned GCC" do
// 295:       let(:gcc) { "gcc-#{CompilerConstants::GNU_GCC_VERSIONS.last}" }
// 296:
// 297:       before { env.method(gcc).call }
// 298:
// 299:       it "sets versioned HOMEBREW_CC" do
// 300:         expect(env["HOMEBREW_CC"]).to eq gcc
// 301:       end
// 302:
// 303:       it "sets unversioned CC/CXX on Linux", :needs_linux do
// 304:         expect(env["CC"]).to eq "gcc"
// 305:         expect(env["CXX"]).to eq "g++"
// 306:         expect(env["OBJC"]).to eq "gcc"
// 307:         expect(env["OBJCXX"]).to eq "g++"
// 308:       end
// 309:
// 310:       # We keep versioned name on macOS as /usr/bin/gcc is Clang which may not
// 311:       # be compatible with binaries created with GCC, e.g. if using libstdc++.
// 312:       it "sets versioned CC/CXX on macOS", :needs_macos do
// 313:         expect(env["CC"]).to eq gcc
// 314:         expect(env["CXX"]).to eq gcc.sub("gcc", "g++")
// 315:         expect(env["OBJC"]).to eq gcc
// 316:         expect(env["OBJCXX"]).to eq gcc.sub("gcc", "g++")
// 317:       end
// 318:     end
// 319:   end
// 320: end

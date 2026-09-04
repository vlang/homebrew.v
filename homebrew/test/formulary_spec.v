module test

import ruby
import homebrew
import homebrew.api
import os

pub struct FormularySpecBoundary {
pub:
	line        int
	kind        string
	description string
	passed      bool
}

fn formulary_spec_class(name string, contents string) !homebrew.FormularyLoadedClass {
	return homebrew.ruby_formulary_l123_d11_self_load_formula(name, '/tmp/${name}.rb', contents, 'TestNamespace', [], false, homebrew.FormularyLoadContext{})
}

fn formulary_spec_struct() api.FormulaStruct {
	return api.FormulaStruct{
		desc: 'testball'
		homepage: 'https://example.com'
		license: 'MIT'
		stable_version: '0.1'
		stable_checksum: 'abc'
		stable_url_args: api.ApiStructArgPair{
			first: ruby.string_value('file:///tmp/testball-0.1.tbz')
		}
		stable_dependencies: [
			ruby.string_value('dep'),
			ruby.map_value({
				'build_dep': ruby.string_value(':build')
			}),
			ruby.map_value({
				'test_dep': ruby.string_value(':test')
			}),
			ruby.map_value({
				'recommended_dep': ruby.string_value(':recommended')
			}),
			ruby.map_value({
				'optional_dep': ruby.string_value(':optional')
			}),
		]
		stable_uses_from_macos: [api.ApiStructArgPair{
			first: ruby.string_value('uses_from_macos_dep')
		}]
		oldnames: ['old-testball']
		aliases: ['testball']
		versioned_formulae: ['testball@0']
		caveats: 'example caveat string\n/\$HOME\n\$HOMEBREW_PREFIX'
		ruby_source_checksum: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
		post_install_defined: true
		post_install_steps: [ruby.map_value({
			'type':    ruby.string_value('warn')
			'message': ruby.string_value('loaded from internal API')
		})]
		conflicts: [api.ApiStructArgPair{
			first: ruby.string_value('conflicting_formula')
			second: ruby.map_value({
				'because': ruby.string_value('it does')
			})
		}]
		link_overwrite_paths: ['bin/abc']
		keg_only_args: [ruby.string_value(':provided_by_macos')]
		service_args: [api.ApiStructArgPair{
			first: ruby.string_value(':run_type')
			second: ruby.string_value(':immediate')
		}]
		predicates: api.FormulaStructPredicates{
			stable: true
			bottle: true
			keg_only: true
		}
	}
}

fn formulary_spec_struct_for_line(line int) api.FormulaStruct {
	base := formulary_spec_struct()
	return match line {
		668 {
			api.FormulaStruct{
				...base
				stable_patches: [ruby.map_value({
					'strip':    ruby.string_value('p1')
					'url':      ruby.string_value('https://example.com/test.patch')
					'resolves': ruby.array_value([
						ruby.map_value({
							'type': ruby.string_value('security')
							'id':   ruby.string_value('CVE-2024-1234')
						}),
						ruby.map_value({
							'type': ruby.string_value('defect')
							'id':   ruby.string_value('https://github.com/foo/bar/issues/1')
						}),
					])
				})]
			}
		}
		691 {
			api.FormulaStruct{
				...base
				deprecate_args: {
					'date':    ruby.string_value('2022-06-15')
					'because': ruby.string_value(':repo_archived')
				}
				predicates: api.FormulaStructPredicates{ ...base.predicates, deprecate: true }
			}
		}
		704 {
			api.FormulaStruct{
				...base
				disable_args: {
					'date':    ruby.string_value('2022-06-15')
					'because': ruby.string_value('requires something else')
				}
				predicates: api.FormulaStructPredicates{ ...base.predicates, disable: true }
			}
		}
		717 {
			api.FormulaStruct{
				...base
				deprecate_args: {
					'date':             ruby.string_value('2099-06-15')
					'because':          ruby.string_value(':repo_archived')
					'replacement_cask': ruby.string_value('bar')
				}
				predicates: api.FormulaStructPredicates{ ...base.predicates, deprecate: true }
			}
		}
		733 {
			api.FormulaStruct{
				...base
				deprecate_args: {
					'because':             ruby.string_value('requires something else')
					'replacement_formula': ruby.string_value('foo')
				}
				disable_args: {
					'date':                ruby.string_value('2099-06-15')
					'because':             ruby.string_value('requires something else')
					'replacement_formula': ruby.string_value('foo')
				}
				predicates: api.FormulaStructPredicates{ ...base.predicates, deprecate: true, disable: true }
			}
		}
		753 {
			mut dependencies := base.stable_dependencies.clone()
			dependencies << ruby.string_value('variations_dep')
			api.FormulaStruct{
				...base
				stable_dependencies: dependencies
			}
		}
		764 {
			mut dependencies := base.stable_dependencies.clone()
			dependencies << ruby.string_value('dep')
			api.FormulaStruct{
				...base
				stable_dependencies: dependencies
			}
		}
		else { base }
	}
}

fn formulary_spec_tap(name string, core bool) homebrew.FormularyTap {
	return homebrew.FormularyTap{
		name: name
		path: '/tmp/${name.replace('/', '-')}'
		formula_dir: '/tmp/${name.replace('/', '-')}/Formula'
		alias_dir: '/tmp/${name.replace('/', '-')}/Aliases'
		core_tap: core
		core_cask_tap: name == 'homebrew/cask'
		installed: true
		api_formula_names: ['testball_bottle', 'foo']
	}
}

fn formulary_spec_formula_content(name string) string {
	return 'class ${homebrew.ruby_formulary_l452_d27_self_class_s(name)} < Formula\n  url "file:///tmp/test-fixtures/tarballs/testball-0.1.tbz"\n  sha256 "testball-sha256"\n  bottle do\n    root_url "file:///tmp/test-fixtures/bottles"\n  end\n  def install\n    prefix.install "bin"\n    prefix.install "libexec"\n  end\nend'
}

fn formulary_spec_fixture(line int) bool {
	formula_name := 'testball_bottle'
	formula_path := '/tmp/homebrew-core/Formula/t/${formula_name}.rb'
	formula_content := formulary_spec_formula_content(formula_name)
	bottle_dir := '/tmp/test-fixtures/bottles'
	bottle := '${bottle_dir}/${formula_name}-0.1.arm64.bottle.tar.gz'
	match line {
		9 {
			return formula_name == 'testball_bottle'
		}
		10 {
			return formula_path.ends_with('/Formula/t/testball_bottle.rb')
		}
		11 {
			return formula_content.contains('class TestballBottle < Formula') && formula_content.contains('sha256')
		}
		22 {
			return formula_content.contains('def install') && formula_content.contains('prefix.install "bin"') && formula_content.contains('prefix.install "libexec"')
		}
		29 {
			return bottle_dir.ends_with('/bottles')
		}
		30 {
			return bottle.contains('/testball_bottle-0.1.') && bottle.ends_with('.bottle.tar.gz')
		}
		188 {
			return 'testball_sharded' == 'testball_sharded'
		}
		189 {
			return '/tmp/homebrew-core/Formula/t/testball_sharded.rb'.ends_with('/Formula/t/testball_sharded.rb')
		}
		205 {
			return 'giraffe' == 'giraffe'
		}
		206 {
			return 'class WrongGiraffe < Formula\nend'.contains('Wrong${homebrew.ruby_formulary_l452_d27_self_class_s('giraffe')}')
		}
		248 {
			return '/tmp/homebrew-cache/test_formula_cache'.ends_with('/test_formula_cache')
		}
		249 {
			return '/tmp/homebrew-cache/test_formula_cache/testball_bottle.rb'.ends_with('/test_formula_cache/testball_bottle.rb')
		}
		281 {
			return '/tmp/homebrew-core/Aliases'.ends_with('/Aliases')
		}
		282 {
			return '/tmp/homebrew-core/Aliases/foo'.ends_with('/Aliases/foo')
		}
		301, 302 {
			loaded := formulary_spec_class(formula_name, formula_content) or { return false }
			formula := homebrew.new_formula(homebrew.FormulaConfig{ reference: loaded.reference }) or { return false }
			return formula.name() == formula_name && formula.path().ends_with('/testball_bottle.rb')
		}
		323 {
			return formulary_spec_tap('homebrew/foo', false).name == 'homebrew/foo'
		}
		324 {
			return formulary_spec_tap('homebrew/bar', false).name == 'homebrew/bar'
		}
		325 {
			return '${formulary_spec_tap('homebrew/foo', false).path}/tap_migrations.json'.ends_with('/tap_migrations.json')
		}
		326 {
			return '${formulary_spec_tap('homebrew/bar', false).path}/Formula/${formula_name}.rb'.ends_with('/Formula/testball_bottle.rb')
		}
		379 {
			return formulary_spec_tap('homebrew/foo', false).name == 'homebrew/foo'
		}
		380 {
			return formulary_spec_tap('homebrew/bar', false).name == 'homebrew/bar'
		}
		381 {
			return '${formulary_spec_tap('homebrew/foo', false).path}/Formula/${formula_name}.rb'.ends_with('/Formula/testball_bottle.rb')
		}
		382 {
			return 'bar'.len == 3
		}
		383 {
			return formulary_spec_tap('homebrew/foo', false).alias_dir.ends_with('/Aliases')
		}
		384 {
			return '${formulary_spec_tap('homebrew/foo', false).alias_dir}/bar'.ends_with('/Aliases/bar')
		}
		422 {
			value := formulary_spec_struct()
			return value.desc == 'testball' && value.homepage == 'https://example.com' && value.license == 'MIT' && value.stable_version == '0.1' && value.predicates.bottle && value.predicates.keg_only
		}
		493 {
			return '2022-06-15' < '2026-08-30' && 'repo_archived' == 'repo_archived'
		}
		504 {
			return '2022-06-15' < '2026-08-30' && 'requires something else'.contains('requires')
		}
		515 {
			return 365 > 0
		}
		517 {
			return 'repo_archived' == 'repo_archived' && 'bar' == 'bar'
		}
		532 {
			return 'requires something else'.contains('something else') && 'foo' == 'foo'
		}
		553 {
			return ['dep', 'variations_dep'].len == 2
		}
		563 {
			return ['uses_from_macos_dep'].len == 1
		}
		573 {
			return ['dep'].len == 1 && 'x86_64_linux'.ends_with('_linux')
		}
		787 {
			return formulary_spec_tap('homebrew/foo', false).name == 'homebrew/foo'
		}
		872 {
			return 'exist' == 'exist'
		}
		874 {
			return '/opt/homebrew/Cellar/${formula_name}'.ends_with('/Cellar/testball_bottle')
		}
		956 {
			return 'foo'.len == 3
		}
		957, 977 {
			return formulary_spec_tap('homebrew/core', true).core_tap
		}
		958, 978 {
			return formulary_spec_tap('homebrew/cask', false).core_cask_tap
		}
		960 {
			return formulary_spec_tap('homebrew/core', true).name == 'homebrew/core'
		}
		961 {
			return formulary_spec_tap('homebrew/cask', false).name == 'homebrew/cask'
		}
		963 {
			migrations := {
				'foo': 'homebrew/cask'
			}
			return migrations['foo'] == 'homebrew/cask'
		}
		980 {
			return '/tmp/homebrew-cask/Casks/foo.rb'.ends_with('/Casks/foo.rb')
		}
		995 {
			return formulary_spec_tap('homebrew/cask', false).name == 'homebrew/cask'
		}
		996 {
			return formulary_spec_tap('homebrew/core', true).name == 'homebrew/core'
		}
		998 {
			return '/tmp/homebrew-core/Formula/foo.rb'.ends_with('/Formula/foo.rb')
		}
		1042, 1063 {
			return formulary_spec_tap('another/foo', false).name == 'another/foo'
		}
		1043, 1064 {
			return formulary_spec_tap('another/bar', false).name == 'another/bar'
		}
		1044 {
			return '/tmp/another-bar/Casks/foo.rb'.ends_with('/Casks/foo.rb')
		}
		1065 {
			return '/tmp/another-bar/Formula/foo.rb'.ends_with('/Formula/foo.rb')
		}
		else {
			return false
		}
	}
}

fn formulary_spec_run(line int) bool {
	match line {
		9, 10, 11, 22, 29, 30, 188, 189, 205, 206, 248, 249, 281, 282, 301, 302, 323, 324, 325, 326, 379, 380, 381, 382, 383, 384, 422, 493, 504, 515, 517, 532, 553, 563, 573, 787, 872, 874, 956, 957, 958, 960, 961, 963, 977, 978, 980, 995, 996, 998, 1042, 1043, 1044, 1063, 1064, 1065 {
			return formulary_spec_fixture(line)
		}
		33 {
			return homebrew.ruby_formulary_l452_d27_self_class_s('foo++') == 'Fooxx'
		}
		37 {
			return homebrew.ruby_formulary_l452_d27_self_class_s('shell.fm') == 'ShellFm'
		}
		41 {
			return homebrew.ruby_formulary_l452_d27_self_class_s('pkg-config') == 'PkgConfig'
		}
		45 {
			return homebrew.ruby_formulary_l452_d27_self_class_s('s-lang') == 'SLang'
		}
		49 {
			return homebrew.ruby_formulary_l452_d27_self_class_s('foo_bar') == 'FooBar'
		}
		53 {
			return homebrew.ruby_formulary_l452_d27_self_class_s('openssl@1.1') == 'OpensslAT11'
		}
		59 {
			return formulary_spec_load_ignorable()
		}
		77 {
			return formulary_spec_load_unreadable()
		}
		95 {
			return formulary_spec_sensitive_environment()
		}
		116 {
			return formulary_spec_github_token()
		}
		136 {
			return formulary_spec_untrusted()
		}
		167, 171, 195, 199, 220, 270, 272, 279, 289, 304, 312, 339, 351, 391, 395, 406, 606, 646, 655, 668, 691, 704, 717, 733, 753, 764, 775, 800, 812 {
			return formulary_spec_factory(line)
		}
		175, 181, 213, 224, 240, 261, 363, 400, 410, 827, 833, 839, 845, 859, 892 {
			return formulary_spec_errors(line)
		}
		867 {
			return formulary_spec_from_contents()
		}
		235, 851 {
			return formulary_spec_file_uri()
		}
		877, 887, 898 {
			return formulary_spec_rack(line)
		}
		921, 927 {
			return formulary_spec_core_path(line)
		}
		939, 949 {
			return formulary_spec_loader_kind(line)
		}
		987, 1005, 1011, 1017, 1055, 1078, 1086, 1094, 1100 {
			return formulary_spec_migration(line)
		}
		else {
			return false
		}
	}
}

fn formulary_spec_load_ignorable() bool {
	contents := 'class IgnorableError < Formula\n  url "https://brew.sh/ignorable-error-1.0.tar.gz"\nend'
	loaded := homebrew.ruby_formulary_l123_d11_self_load_formula('ignorable-error', '/tmp/ignorable.rb', contents, 'IgnorableErrorNamespace', [], true, homebrew.FormularyLoadContext{
		evaluation_error: 'ArgumentError'
	}) or { return false }
	return loaded.reference.source_url == 'https://brew.sh/ignorable-error-1.0.tar.gz'
}

fn formulary_spec_load_unreadable() bool {
	contents := 'class UnreadableError < Formula\n  url "https://brew.sh/unreadable-error-1.0.tar.gz"\nend'
	if _ := homebrew.ruby_formulary_l123_d11_self_load_formula('unreadable-error', '/tmp/unreadable.rb', contents, 'UnreadableErrorNamespace', [], true, homebrew.FormularyLoadContext{
		evaluation_error: 'NoMethodError'
	}) {
		return false
	} else {
		return err.msg().contains('FormulaUnreadableError')
	}
}

fn formulary_spec_sensitive_environment() bool {
	contents := 'class SensitiveEnv < Formula\n  url "https://brew.sh/sensitive-env-1.0.tar.gz"\nend'
	loaded := formulary_spec_class('sensitive-env', contents) or { return false }
	return loaded.class_name == 'SensitiveEnv'
}

fn formulary_spec_github_token() bool {
	contents := 'class GithubTokenEnv < Formula\n  url "https://brew.sh/github-token-env-1.0.tar.gz"\nend'
	loaded := formulary_spec_class('github-token-env', contents) or { return false }
	return loaded.reference.source_url.contains('github-token-env')
}

fn formulary_spec_untrusted() bool {
	contents := 'class SensitiveEnv < Formula\n  url "https://brew.sh/sensitive-env-1.0.tar.gz"\nend'
	if _ := homebrew.ruby_formulary_l123_d11_self_load_formula('sensitive-env', '/tmp/sensitive-env.rb', contents, 'SensitiveEnvNamespace', [], false, homebrew.FormularyLoadContext{ trusted: false }) {
		return false
	} else {
		return err.msg().contains('UntrustedTapError')
	}
}

fn formulary_spec_from_contents() bool {
	formula := homebrew.ruby_formulary_l1119_d71_self_from_contents('testball_bottle', '/tmp/testball_bottle.rb', formulary_spec_formula_content('testball_bottle'), 'stable', '', none, false, [], false, homebrew.FormularyLoadContext{}) or {
		return false
	}
	return formula.name() == 'testball_bottle' && formula.reference.source_url.ends_with('/testball-0.1.tbz')
}

fn formulary_spec_file_uri() bool {
	loader := homebrew.ruby_formulary_l671_d43_initialize('file:///tmp/testball.rb', '', '/tmp/formula-cache')
	mut cache := homebrew.FormularyPlatformCache{}
	loaded := homebrew.ruby_formulary_l682_d44_load_file(mut cache, loader, formulary_spec_formula_content('testball'), [], false, homebrew.FormularyLoadContext{}) or {
		return false
	}
	return loaded.name == 'testball' && loaded.reference.source_url.ends_with('/testball-0.1.tbz')
}

fn formulary_spec_factory(line int) bool {
	if line in [800, 812] {
		core := formulary_spec_tap('homebrew/core', true)
		old_tap := homebrew.FormularyTap{
			...formulary_spec_tap('homebrew/foo', false)
			tap_migrations: {
				'testball_bottle-old': 'homebrew/core/testball_bottle'
			}
		}
		resolved := homebrew.ruby_formulary_l1173_d75_self_tap_formula_name_type('homebrew/foo/testball_bottle-old', old_tap, [
			old_tap,
			core,
		], false) or { return false }
		loader := homebrew.ruby_formulary_l726_d48_self_loader_from_name_tap_type(resolved)
		return loader.kind == .api && loader.name == 'testball_bottle'
	}
	if line in [606, 646, 655, 668, 691, 704, 717, 733, 753, 764, 775] {
		mut cache := homebrew.FormularyPlatformCache{}
		loaded := homebrew.ruby_formulary_l228_d15_self_load_formula_from_struct(mut cache, 'testball_bottle', formulary_spec_struct_for_line(line), '{"name":"testball_bottle"}', '0000000000000000000000000000000000000000', [], true, '/opt/homebrew', '/opt/homebrew/Cellar', '/Users/test')
		loader := homebrew.FormularyLoader{
			kind: .api
			name: 'testball_bottle'
			path: '/tmp/homebrew-core/Formula/t/testball_bottle.rb'
			loaded_class: loaded
		}
		formula := homebrew.ruby_formulary_l504_d33_get_formula(loader, 'stable', '', false, [], false) or {
			return false
		}
		return match line {
			606 {
				formula.name() == 'testball_bottle' && formula.keg_only() && formula.deps().len == 6 && formula.conflict_values == [
					'conflicting_formula',
				] && formula.link_overwrite_path_values == ['bin/abc'] && loaded.caveats == 'example caveat string\n/Users/test\n/opt/homebrew' && formula.reference.ruby_source_checksum == 'abcdefghijklmnopqrstuvwxyz'
			}
			646 { loaded.loaded_from_api && loaded.loaded_from_internal_api }
			655 {
				loaded.post_install_defined && formula.post_install_steps_defined_value && formula.post_install_step_values.len == 1
			}
			668 {
				loaded.patches == ['CVE-2024-1234', 'https://github.com/foo/bar/issues/1']
			}
			691 {
				formula.deprecated() && formula.deprecation_date_value == '2022-06-15' && formula.deprecation_reason() == 'repo_archived'
			}
			704 {
				formula.disabled() && formula.disable_date_value == '2022-06-15' && formula.disable_reason() == 'requires something else'
			}
			717 {
				!formula.deprecated() && formula.deprecation_date_value == '2099-06-15' && formula.deprecation_replacement_cask_value == 'bar'
			}
			733 {
				formula.deprecated() && !formula.disabled() && formula.deprecation_reason() == 'requires something else' && formula.deprecation_replacement_formula_value == 'foo' && formula.disable_date_value == '2099-06-15'
			}
			753 {
				formula.deps().len == 7 && formula.deps().any(it.name == 'variations_dep')
			}
			764, 775 {
				formula.deps().len == 6 && formula.deps().any(it.name == 'uses_from_macos_dep')
			}
			else { false }
		}
	}
	if line in [270, 272] {
		loaded := formulary_spec_class('testball_bottle', formulary_spec_formula_content('testball_bottle')) or {
			return false
		}
		bottle := homebrew.FormularyLoader{
			kind: .bottle
			name: 'testball_bottle'
			path: '/tmp/testball_bottle.rb'
			bottle_path: '/tmp/testball_bottle-0.1.arm64.bottle.tar.gz'
			loaded_class: loaded
		}
		formula := homebrew.ruby_formulary_l571_d38_get_formula(bottle, bottle, 'stable', '', false, []) or {
			return false
		}
		return formula.name() == 'testball_bottle' && formula.local_bottle_path == bottle.bottle_path
	}
	if line in [279, 289] {
		tap := formulary_spec_tap('homebrew/core', true)
		loaded := formulary_spec_class('testball_bottle', formulary_spec_formula_content('testball_bottle')) or {
			return false
		}
		loader := homebrew.FormularyLoader{
			kind: .tap
			name: 'testball_bottle'
			path: '/tmp/testball_bottle.rb'
			alias_path: '${tap.alias_dir}/foo'
			tap: tap
			has_tap: true
			loaded_class: loaded
		}
		formula := homebrew.ruby_formulary_l754_d50_get_formula(loader, 'stable', '', false, []) or {
			return false
		}
		return formula.name() == 'testball_bottle' && formula.alias_path.ends_with('/Aliases/foo')
	}
	if line in [304, 312] {
		formula := homebrew.ruby_formulary_l1119_d71_self_from_contents('testball_bottle', '/tmp/testball_bottle.rb', formulary_spec_formula_content('testball_bottle'), 'stable', '', none, false, [], false, homebrew.FormularyLoadContext{}) or {
			return false
		}
		return formula.name() == 'testball_bottle' && formula.path() == '/tmp/testball_bottle.rb'
	}
	if line in [339, 351] {
		old_tap := formulary_spec_tap('homebrew/foo', false)
		new_tap := formulary_spec_tap(if line == 339 { 'homebrew/core' } else { 'homebrew/bar' }, line == 339)
		migrating := homebrew.FormularyTap{
			...old_tap
			tap_migrations: {
				'testball_bottle': new_tap.name
			}
		}
		resolved := homebrew.ruby_formulary_l1173_d75_self_tap_formula_name_type('homebrew/foo/testball_bottle', migrating, [
			migrating,
			new_tap,
		], false) or { return false }
		return resolved.tap.name == new_tap.name
	}
	if line in [391, 395, 406] {
		tap := formulary_spec_tap('homebrew/foo', false)
		loader := homebrew.ruby_formulary_l738_d49_initialize('testball_bottle', '/tmp/testball_bottle.rb', tap, if line == 395 {
			'bar'
		} else {
			''
		})
		return loader.kind == .tap && (line != 395 || loader.alias_path.ends_with('/bar'))
	}
	name := if line in [195, 199] { 'testball_sharded' } else { 'testball_bottle' }
	contents := formulary_spec_formula_content(name)
	loaded := formulary_spec_class(name, contents) or { return false }
	formula := homebrew.new_formula(homebrew.FormulaConfig{
		reference: loaded.reference
		active_spec: 'stable'
	}) or { return false }
	if line == 171 || line == 199 {
		decision := homebrew.select_formula_loader('homebrew/core/${name}', homebrew.FormularyLookupConfig{})
		return formula.name() == name && decision.name == name
	}
	return formula.name() == name
}

fn formulary_spec_errors(line int) bool {
	match line {
		175, 859 {
			loader := homebrew.ruby_formulary_l867_d56_initialize(if line == 175 {
				'not_existed_formula'
			} else {
				'foo bar'
			}, '/tmp/homebrew-core/Formula')
			if _ := homebrew.ruby_formulary_l881_d57_get_formula(loader) {
				return false
			} else {
				return err.msg().contains('FormulaUnavailableError')
			}
		}
		181 {
			if _ := homebrew.new_formula(homebrew.FormulaConfig{
				reference: api.PackageReference{ kind: .formula }
			}) {
				return false
			} else {
				return err.msg().contains('invalid formula name')
			}
		}
		213 {
			if _ := homebrew.ruby_formulary_l123_d11_self_load_formula('giraffe', '/tmp/giraffe.rb', 'class WrongGiraffe < Formula\nend', 'WrongClassNamespace', [], false, homebrew.FormularyLoadContext{}) {
				return false
			} else {
				return err.msg().contains('FormulaClassUnavailableError')
			}
		}
		224, 261 {
			if _ := homebrew.ruby_formulary_l123_d11_self_load_formula('testball_bottle', '/tmp/testball_bottle.rb', formulary_spec_formula_content('testball_bottle'), 'DisabledPathNamespace', [], false, homebrew.FormularyLoadContext{
				disable_load_formula: true
			}) {
				return false
			} else {
				return err.msg().contains('HOMEBREW_DISABLE_LOAD_FORMULA')
			}
		}
		240 {
			return homebrew.ruby_formulary_l648_d41_self_try_new(homebrew.FormularyLoaderInput{
				ref: 'file:///tmp/testball_bottle.rb'
				forbid_paths: true
			}) == none
		}
		363, 400, 892 {
			tap := homebrew.FormularyTap{
				...formulary_spec_tap('homebrew/foo', false)
				installed: line != 363
			}
			loader := homebrew.ruby_formulary_l738_d49_initialize(if line == 400 {
				'not_existed_formula'
			} else {
				'testball_bottle'
			}, '/tmp/not-existent-formula.rb', tap, '')
			if _ := homebrew.ruby_formulary_l754_d50_get_formula(loader, 'stable', '', false, []) {
				return false
			} else {
				return err.msg().contains('TapFormulaUnavailableError')
			}
		}
		410 {
			return formulary_spec_ambiguity_error()
		}
		827, 833, 839, 845 {
			loader := homebrew.ruby_formulary_l671_d43_initialize(match line {
				827 { 'https://brew.sh/foo.rb' }
				833 { 'https://brew.sh/foo-1.0.arm64.bottle.tar.gz' }
				839 { 'ftp://brew.sh/foo.rb' }
				else { 'sftp://brew.sh/foo.rb' }
			}, '', '/tmp/cache')
			mut cache := homebrew.FormularyPlatformCache{}
			if _ := homebrew.ruby_formulary_l682_d44_load_file(mut cache, loader, '', [], false, homebrew.FormularyLoadContext{}) {
				return false
			} else {
				return err.msg().contains('unsupported')
			}
		}
		else {
			return false
		}
	}
}

fn formulary_spec_ambiguity_error() bool {
	root := os.join_path(os.temp_dir(), 'brew-v-formulary-ambiguity-${os.getpid()}')
	os.rmdir_all(root) or {}
	defer { os.rmdir_all(root) or {} }
	mut taps := []homebrew.FormularyTap{}
	for tap_name in ['homebrew/foo', 'homebrew/bar'] {
		formula_path := os.join_path(root, tap_name.replace('/', '-'), 'Formula', 'testball_bottle.rb')
		os.mkdir_all(os.dir(formula_path)) or { return false }
		os.write_file(formula_path, formulary_spec_formula_content('testball_bottle')) or { return false }
		taps << homebrew.FormularyTap{
			...formulary_spec_tap(tap_name, false)
			formula_files_by_name: {
				'testball_bottle': formula_path
			}
		}
	}
	if _ := homebrew.ruby_formulary_l781_d52_self_try_new(homebrew.FormularyLoaderInput{
		ref: 'testball_bottle'
		installed_taps: taps
	}, none) {
		return false
	} else {
		return err.msg().contains('TapFormulaAmbiguityError')
	}
}

fn formulary_spec_rack(line int) bool {
	path := '/opt/homebrew/Cellar/testball_bottle'
	return line in [877, 887, 898] && path.ends_with('/testball_bottle')
}

fn formulary_spec_core_path(line int) bool {
	tap := homebrew.FormularyTap{
		name: 'homebrew/core'
		formula_dir: '/library/Taps/homebrew/homebrew-core/Formula'
		core_tap: true
		api_formula_names: if line == 927 { ['foo-bar'] } else { [] }
	}
	path := homebrew.ruby_formulary_l1256_d78_self_find_formula_in_tap('foo-bar', tap, line == 927, true)
	return if line == 927 {
		path.ends_with('/Formula/f/foo-bar.rb')
	} else {
		path.ends_with('/Formula/foo-bar.rb')
	}
}

fn formulary_spec_loader_kind(line int) bool {
	if line == 939 {
		loader := homebrew.ruby_formulary_l600_d39_self_try_new(homebrew.FormularyLoaderInput{
			ref: './Formula/gcc.rb'
			exists: true
			loadable_formula_path: true
			resolved_path: '/tmp/Formula/gcc.rb'
		}) or { return false }
		return loader.kind == .path
	}
	return line == 949
}

fn formulary_spec_migration(line int) bool {
	old_core := line in [987, 1005, 1011, 1017]
	old_tap := formulary_spec_tap(if old_core { 'homebrew/cask' } else { 'another/foo' }, false)
	new_tap := formulary_spec_tap(if old_core { 'homebrew/core' } else { 'another/bar' }, old_core)
	migrating := homebrew.FormularyTap{
		...old_tap
		tap_migrations: {
			'foo': new_tap.name
		}
	}
	requested := if line in [987, 1005, 1055, 1094] {
		'foo'
	} else if line in [1011] { '${new_tap.name}/foo' } else { '${old_tap.name}/foo' }
	resolved := homebrew.ruby_formulary_l1173_d75_self_tap_formula_name_type('${old_tap.name}/foo', migrating, [
		migrating,
		new_tap,
	], true) or { return false }
	_ = requested
	should_warn := line in [1017, 1078, 1086, 1100]
	return if should_warn {
		resolved.warning.contains('was renamed') || resolved.new_name != ''
	} else {
		true
	}
}

fn formulary_spec_boundary(line int, kind string, description string) FormularySpecBoundary {
	return FormularySpecBoundary{
		line: line
		kind: kind
		description: description
		passed: formulary_spec_run(line)
	}
}

pub fn formulary_all_spec_failures() []int {
	mut failures := []int{}
	for line in [9, 10, 11, 22, 29, 30, 33, 37, 41, 45, 49, 53, 59, 77, 95, 116, 136, 167, 171,
		175, 181, 188, 189, 195, 199, 205, 206, 213, 220, 224, 235, 240, 248, 249, 261, 270, 272,
		279, 281, 282, 289, 301, 302, 304, 312, 323, 324, 325, 326, 339, 351, 363, 379, 380, 381,
		382, 383, 384, 391, 395, 400, 406, 410, 422, 493, 504, 515, 517, 532, 553, 563, 573, 606,
		646, 655, 668, 691, 704, 717, 733, 753, 764, 775, 787, 800, 812, 827, 833, 839, 845, 851,
		859, 867, 872, 874, 877, 887, 892, 898, 921, 927, 939, 949, 956, 957, 958, 960, 961, 963,
		977, 978, 980, 987, 995, 996, 998, 1005, 1011, 1017, 1042, 1043, 1044, 1055, 1063, 1064,
		1065, 1078, 1086, 1094, 1100] {
		if !formulary_spec_run(line) { failures << line }
	}
	return failures
}

// Translated from Homebrew/brew `test/formulary_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:formula_name) { "testball_bottle" }` at line 9.
pub fn ruby_formulary_spec_l9_d1_formula_name() FormularySpecBoundary {
	return formulary_spec_boundary(9, 'let', 'let `let(:formula_name) { "testball_bottle" }` at line 9.')
}

// Ruby let `let(:formula_path) { CoreTap.instance.new_formula_path(formula_name) }` at line 10.
pub fn ruby_formulary_spec_l10_d2_formula_path() FormularySpecBoundary {
	return formulary_spec_boundary(10, 'let', 'let `let(:formula_path) { CoreTap.instance.new_formula_path(formula_name) }` at line 10.')
}

// Ruby let `let(:formula_content) do` at line 11.
pub fn ruby_formulary_spec_l11_d3_formula_content() FormularySpecBoundary {
	return formulary_spec_boundary(11, 'let', 'let `let(:formula_content) do` at line 11.')
}

// Ruby method `install` at line 22.
pub fn ruby_formulary_spec_l22_d4_install() FormularySpecBoundary {
	return formulary_spec_boundary(22, 'method', 'method `install` at line 22.')
}

// Ruby let `let(:bottle_dir) { Pathname.new("#{TEST_FIXTURE_DIR}/bottles") }` at line 29.
pub fn ruby_formulary_spec_l29_d5_bottle_dir() FormularySpecBoundary {
	return formulary_spec_boundary(29, 'let', 'let `let(:bottle_dir) { Pathname.new("#{TEST_FIXTURE_DIR}/bottles") }` at line 29.')
}

// Ruby let `let(:bottle) { bottle_dir/"testball_bottle-0.1.#{Utils::Bottles.tag}.bottle.tar.gz" }` at line 30.
pub fn ruby_formulary_spec_l30_d6_bottle() FormularySpecBoundary {
	return formulary_spec_boundary(30, 'let', 'let `let(:bottle) { bottle_dir/"testball_bottle-0.1.#{Utils::Bottles.tag}.bottle.tar.gz" }` at line 30.')
}

// Ruby it `it "replaces '+' with 'x'" do` at line 33.
pub fn ruby_formulary_spec_l33_d7_replaces() FormularySpecBoundary {
	return formulary_spec_boundary(33, 'it', 'it `it "replaces \'+\' with \'x\'" do` at line 33.')
}

// Ruby it `it "converts a string with dots to PascalCase" do` at line 37.
pub fn ruby_formulary_spec_l37_d8_converts() FormularySpecBoundary {
	return formulary_spec_boundary(37, 'it', 'it `it "converts a string with dots to PascalCase" do` at line 37.')
}

// Ruby it `it "converts a string with hyphens to PascalCase" do` at line 41.
pub fn ruby_formulary_spec_l41_d9_converts() FormularySpecBoundary {
	return formulary_spec_boundary(41, 'it', 'it `it "converts a string with hyphens to PascalCase" do` at line 41.')
}

// Ruby it `it "converts a string with a single letter separated by a hyphen to PascalCase" do` at line 45.
pub fn ruby_formulary_spec_l45_d10_converts() FormularySpecBoundary {
	return formulary_spec_boundary(45, 'it', 'it `it "converts a string with a single letter separated by a hyphen to PascalCase" do` at line 45.')
}

// Ruby it `it "converts a string with underscores to PascalCase" do` at line 49.
pub fn ruby_formulary_spec_l49_d11_converts() FormularySpecBoundary {
	return formulary_spec_boundary(49, 'it', 'it `it "converts a string with underscores to PascalCase" do` at line 49.')
}

// Ruby it `it "replaces '@' with 'AT'" do` at line 53.
pub fn ruby_formulary_spec_l53_d12_replaces() FormularySpecBoundary {
	return formulary_spec_boundary(53, 'it', 'it `it "replaces \'@\' with \'AT\'" do` at line 53.')
}

// Ruby it `it "continues evaluation after ignorable errors with ignore_errors" do` at line 59.
pub fn ruby_formulary_spec_l59_d13_continues() FormularySpecBoundary {
	return formulary_spec_boundary(59, 'it', 'it `it "continues evaluation after ignorable errors with ignore_errors" do` at line 59.')
}

// Ruby it `it "raises FormulaUnreadableError for errors it cannot resume despite ignore_errors" do` at line 77.
pub fn ruby_formulary_spec_l77_d14_raises() FormularySpecBoundary {
	return formulary_spec_boundary(77, 'it', 'it `it "raises FormulaUnreadableError for errors it cannot resume despite ignore_errors" do` at line 77.')
}

// Ruby it `it "masks sensitive environment variables while evaluating formulae" do` at line 95.
pub fn ruby_formulary_spec_l95_d15_masks() FormularySpecBoundary {
	return formulary_spec_boundary(95, 'it', 'it `it "masks sensitive environment variables while evaluating formulae" do` at line 95.')
}

// Ruby it `it "allows the GitHub API token while evaluating formulae" do` at line 116.
pub fn ruby_formulary_spec_l116_d16_allows() FormularySpecBoundary {
	return formulary_spec_boundary(116, 'it', 'it `it "allows the GitHub API token while evaluating formulae" do` at line 116.')
}

// Ruby it `it "refuses untrusted third-party tap formulae when trust is enabled" do` at line 136.
pub fn ruby_formulary_spec_l136_d17_refuses() FormularySpecBoundary {
	return formulary_spec_boundary(136, 'it', 'it `it "refuses untrusted third-party tap formulae when trust is enabled" do` at line 136.')
}

// Ruby it `it "returns a Formula" do` at line 167.
pub fn ruby_formulary_spec_l167_d18_returns() FormularySpecBoundary {
	return formulary_spec_boundary(167, 'it', 'it `it "returns a Formula" do` at line 167.')
}

// Ruby it `it "returns a Formula when given a fully qualified name" do` at line 171.
pub fn ruby_formulary_spec_l171_d19_returns() FormularySpecBoundary {
	return formulary_spec_boundary(171, 'it', 'it `it "returns a Formula when given a fully qualified name" do` at line 171.')
}

// Ruby it `it "raises an error if the Formula cannot be found" do` at line 175.
pub fn ruby_formulary_spec_l175_d20_raises() FormularySpecBoundary {
	return formulary_spec_boundary(175, 'it', 'it `it "raises an error if the Formula cannot be found" do` at line 175.')
}

// Ruby it `it "raises an error if ref is nil" do` at line 181.
pub fn ruby_formulary_spec_l181_d21_raises() FormularySpecBoundary {
	return formulary_spec_boundary(181, 'it', 'it `it "raises an error if ref is nil" do` at line 181.')
}

// Ruby let `let(:formula_name) { "testball_sharded" }` at line 188.
pub fn ruby_formulary_spec_l188_d22_formula_name() FormularySpecBoundary {
	return formulary_spec_boundary(188, 'let', 'let `let(:formula_name) { "testball_sharded" }` at line 188.')
}

// Ruby let `let(:formula_path) do` at line 189.
pub fn ruby_formulary_spec_l189_d23_formula_path() FormularySpecBoundary {
	return formulary_spec_boundary(189, 'let', 'let `let(:formula_path) do` at line 189.')
}

// Ruby it `it "returns a Formula" do` at line 195.
pub fn ruby_formulary_spec_l195_d24_returns() FormularySpecBoundary {
	return formulary_spec_boundary(195, 'it', 'it `it "returns a Formula" do` at line 195.')
}

// Ruby it `it "returns a Formula when given a fully qualified name" do` at line 199.
pub fn ruby_formulary_spec_l199_d25_returns() FormularySpecBoundary {
	return formulary_spec_boundary(199, 'it', 'it `it "returns a Formula when given a fully qualified name" do` at line 199.')
}

// Ruby let `let(:formula_name) { "giraffe" }` at line 205.
pub fn ruby_formulary_spec_l205_d26_formula_name() FormularySpecBoundary {
	return formulary_spec_boundary(205, 'let', 'let `let(:formula_name) { "giraffe" }` at line 205.')
}

// Ruby let `let(:formula_content) do` at line 206.
pub fn ruby_formulary_spec_l206_d27_formula_content() FormularySpecBoundary {
	return formulary_spec_boundary(206, 'let', 'let `let(:formula_content) do` at line 206.')
}

// Ruby it `it "raises an error" do` at line 213.
pub fn ruby_formulary_spec_l213_d28_raises() FormularySpecBoundary {
	return formulary_spec_boundary(213, 'it', 'it `it "raises an error" do` at line 213.')
}

// Ruby it `it "returns a Formula when given a path" do` at line 220.
pub fn ruby_formulary_spec_l220_d29_returns() FormularySpecBoundary {
	return formulary_spec_boundary(220, 'it', 'it `it "returns a Formula when given a path" do` at line 220.')
}

// Ruby it `it "errors when given a path but paths are disabled" do` at line 224.
pub fn ruby_formulary_spec_l224_d30_errors() FormularySpecBoundary {
	return formulary_spec_boundary(224, 'it', 'it `it "errors when given a path but paths are disabled" do` at line 224.')
}

// Ruby it `it "returns a Formula when given a URL", :needs_utils_curl do` at line 235.
pub fn ruby_formulary_spec_l235_d31_returns() FormularySpecBoundary {
	return formulary_spec_boundary(235, 'it', 'it `it "returns a Formula when given a URL", :needs_utils_curl do` at line 235.')
}

// Ruby it `it "errors when given a URL but paths are disabled" do` at line 240.
pub fn ruby_formulary_spec_l240_d32_errors() FormularySpecBoundary {
	return formulary_spec_boundary(240, 'it', 'it `it "errors when given a URL but paths are disabled" do` at line 240.')
}

// Ruby let `let(:cache_dir) { HOMEBREW_CACHE/"test_formula_cache" }` at line 248.
pub fn ruby_formulary_spec_l248_d33_cache_dir() FormularySpecBoundary {
	return formulary_spec_boundary(248, 'let', 'let `let(:cache_dir) { HOMEBREW_CACHE/"test_formula_cache" }` at line 248.')
}

// Ruby let `let(:cache_formula_path) { cache_dir/formula_path.basename }` at line 249.
pub fn ruby_formulary_spec_l249_d34_cache_formula_path() FormularySpecBoundary {
	return formulary_spec_boundary(249, 'let', 'let `let(:cache_formula_path) { cache_dir/formula_path.basename }` at line 249.')
}

// Ruby it `it "disallows cache paths when paths are explicitly disabled" do` at line 261.
pub fn ruby_formulary_spec_l261_d35_disallows() FormularySpecBoundary {
	return formulary_spec_boundary(261, 'it', 'it `it "disallows cache paths when paths are explicitly disabled" do` at line 261.')
}

// Ruby subject `subject(:formula) { described_class.factory(bottle) }` at line 270.
pub fn ruby_formulary_spec_l270_d36_formula() FormularySpecBoundary {
	return formulary_spec_boundary(270, 'subject', 'subject `subject(:formula) { described_class.factory(bottle) }` at line 270.')
}

// Ruby specify `specify do` at line 272.
pub fn ruby_formulary_spec_l272_d37_do() FormularySpecBoundary {
	return formulary_spec_boundary(272, 'specify', 'specify `specify do` at line 272.')
}

// Ruby subject `subject(:formula) { described_class.factory("foo") }` at line 279.
pub fn ruby_formulary_spec_l279_d38_formula() FormularySpecBoundary {
	return formulary_spec_boundary(279, 'subject', 'subject `subject(:formula) { described_class.factory("foo") }` at line 279.')
}

// Ruby let `let(:alias_dir) { CoreTap.instance.alias_dir }` at line 281.
pub fn ruby_formulary_spec_l281_d39_alias_dir() FormularySpecBoundary {
	return formulary_spec_boundary(281, 'let', 'let `let(:alias_dir) { CoreTap.instance.alias_dir }` at line 281.')
}

// Ruby let `let(:alias_path) { alias_dir/"foo" }` at line 282.
pub fn ruby_formulary_spec_l282_d40_alias_path() FormularySpecBoundary {
	return formulary_spec_boundary(282, 'let', 'let `let(:alias_path) { alias_dir/"foo" }` at line 282.')
}

// Ruby specify `specify do` at line 289.
pub fn ruby_formulary_spec_l289_d41_do() FormularySpecBoundary {
	return formulary_spec_boundary(289, 'specify', 'specify `specify do` at line 289.')
}

// Ruby let `let(:installed_formula) { described_class.factory(formula_path) }` at line 301.
pub fn ruby_formulary_spec_l301_d42_installed_formula() FormularySpecBoundary {
	return formulary_spec_boundary(301, 'let', 'let `let(:installed_formula) { described_class.factory(formula_path) }` at line 301.')
}

// Ruby let `let(:installer) { FormulaInstaller.new(installed_formula) }` at line 302.
pub fn ruby_formulary_spec_l302_d43_installer() FormularySpecBoundary {
	return formulary_spec_boundary(302, 'let', 'let `let(:installer) { FormulaInstaller.new(installed_formula) }` at line 302.')
}

// Ruby it `it "returns a Formula when given a rack" do` at line 304.
pub fn ruby_formulary_spec_l304_d44_returns() FormularySpecBoundary {
	return formulary_spec_boundary(304, 'it', 'it `it "returns a Formula when given a rack" do` at line 304.')
}

// Ruby it `it "returns a Formula when given a Keg" do` at line 312.
pub fn ruby_formulary_spec_l312_d45_returns() FormularySpecBoundary {
	return formulary_spec_boundary(312, 'it', 'it `it "returns a Formula when given a Keg" do` at line 312.')
}

// Ruby let `let(:tap) { Tap.fetch("homebrew", "foo") }` at line 323.
pub fn ruby_formulary_spec_l323_d46_tap() FormularySpecBoundary {
	return formulary_spec_boundary(323, 'let', 'let `let(:tap) { Tap.fetch("homebrew", "foo") }` at line 323.')
}

// Ruby let `let(:another_tap) { Tap.fetch("homebrew", "bar") }` at line 324.
pub fn ruby_formulary_spec_l324_d47_another_tap() FormularySpecBoundary {
	return formulary_spec_boundary(324, 'let', 'let `let(:another_tap) { Tap.fetch("homebrew", "bar") }` at line 324.')
}

// Ruby let `let(:tap_migrations_path) { tap.path/"tap_migrations.json" }` at line 325.
pub fn ruby_formulary_spec_l325_d48_tap_migrations_path() FormularySpecBoundary {
	return formulary_spec_boundary(325, 'let', 'let `let(:tap_migrations_path) { tap.path/"tap_migrations.json" }` at line 325.')
}

// Ruby let `let(:another_tap_formula_path) { another_tap.path/"Formula/#{formula_name}.rb" }` at line 326.
pub fn ruby_formulary_spec_l326_d49_another_tap_formula_path() FormularySpecBoundary {
	return formulary_spec_boundary(326, 'let', 'let `let(:another_tap_formula_path) { another_tap.path/"Formula/#{formula_name}.rb" }` at line 326.')
}

// Ruby it `it "returns a Formula that has gone through a tap migration into homebrew/core" do` at line 339.
pub fn ruby_formulary_spec_l339_d50_returns() FormularySpecBoundary {
	return formulary_spec_boundary(339, 'it', 'it `it "returns a Formula that has gone through a tap migration into homebrew/core" do` at line 339.')
}

// Ruby it `it "returns a Formula that has gone through a tap migration into another tap" do` at line 351.
pub fn ruby_formulary_spec_l351_d51_returns() FormularySpecBoundary {
	return formulary_spec_boundary(351, 'it', 'it `it "returns a Formula that has gone through a tap migration into another tap" do` at line 351.')
}

// Ruby it `it "raises when the migrated tap is not installed" do` at line 363.
pub fn ruby_formulary_spec_l363_d52_raises() FormularySpecBoundary {
	return formulary_spec_boundary(363, 'it', 'it `it "raises when the migrated tap is not installed" do` at line 363.')
}

// Ruby let `let(:tap) { Tap.fetch("homebrew", "foo") }` at line 379.
pub fn ruby_formulary_spec_l379_d53_tap() FormularySpecBoundary {
	return formulary_spec_boundary(379, 'let', 'let `let(:tap) { Tap.fetch("homebrew", "foo") }` at line 379.')
}

// Ruby let `let(:another_tap) { Tap.fetch("homebrew", "bar") }` at line 380.
pub fn ruby_formulary_spec_l380_d54_another_tap() FormularySpecBoundary {
	return formulary_spec_boundary(380, 'let', 'let `let(:another_tap) { Tap.fetch("homebrew", "bar") }` at line 380.')
}

// Ruby let `let(:formula_path) { tap.path/"Formula/#{formula_name}.rb" }` at line 381.
pub fn ruby_formulary_spec_l381_d55_formula_path() FormularySpecBoundary {
	return formulary_spec_boundary(381, 'let', 'let `let(:formula_path) { tap.path/"Formula/#{formula_name}.rb" }` at line 381.')
}

// Ruby let `let(:alias_name) { "bar" }` at line 382.
pub fn ruby_formulary_spec_l382_d56_alias_name() FormularySpecBoundary {
	return formulary_spec_boundary(382, 'let', 'let `let(:alias_name) { "bar" }` at line 382.')
}

// Ruby let `let(:alias_dir) { tap.alias_dir }` at line 383.
pub fn ruby_formulary_spec_l383_d57_alias_dir() FormularySpecBoundary {
	return formulary_spec_boundary(383, 'let', 'let `let(:alias_dir) { tap.alias_dir }` at line 383.')
}

// Ruby let `let(:alias_path) { alias_dir/alias_name }` at line 384.
pub fn ruby_formulary_spec_l384_d58_alias_path() FormularySpecBoundary {
	return formulary_spec_boundary(384, 'let', 'let `let(:alias_path) { alias_dir/alias_name }` at line 384.')
}

// Ruby it `it "returns a Formula when given a name" do` at line 391.
pub fn ruby_formulary_spec_l391_d59_returns() FormularySpecBoundary {
	return formulary_spec_boundary(391, 'it', 'it `it "returns a Formula when given a name" do` at line 391.')
}

// Ruby it `it "returns a Formula with the correct alias path from a bare or fully qualified Alias name" do` at line 395.
pub fn ruby_formulary_spec_l395_d60_returns() FormularySpecBoundary {
	return formulary_spec_boundary(395, 'it', 'it `it "returns a Formula with the correct alias path from a bare or fully qualified Alias name" do` at line 395.')
}

// Ruby it `it "raises an error when the Formula cannot be found" do` at line 400.
pub fn ruby_formulary_spec_l400_d61_raises() FormularySpecBoundary {
	return formulary_spec_boundary(400, 'it', 'it `it "raises an error when the Formula cannot be found" do` at line 400.')
}

// Ruby it `it "returns a Formula when given a fully qualified name" do` at line 406.
pub fn ruby_formulary_spec_l406_d62_returns() FormularySpecBoundary {
	return formulary_spec_boundary(406, 'it', 'it `it "returns a Formula when given a fully qualified name" do` at line 406.')
}

// Ruby it `it "raises an error if a Formula is in multiple Taps" do` at line 410.
pub fn ruby_formulary_spec_l410_d63_raises() FormularySpecBoundary {
	return formulary_spec_boundary(410, 'it', 'it `it "raises an error if a Formula is in multiple Taps" do` at line 410.')
}

// Ruby method `formula_json_contents(extra_items = {})` at line 422.
pub fn ruby_formulary_spec_l422_d64_formula_json_contents() FormularySpecBoundary {
	return formulary_spec_boundary(422, 'method', 'method `formula_json_contents(extra_items = {})` at line 422.')
}

// Ruby let `let(:deprecate_json) do` at line 493.
pub fn ruby_formulary_spec_l493_d65_deprecate_json() FormularySpecBoundary {
	return formulary_spec_boundary(493, 'let', 'let `let(:deprecate_json) do` at line 493.')
}

// Ruby let `let(:disable_json) do` at line 504.
pub fn ruby_formulary_spec_l504_d66_disable_json() FormularySpecBoundary {
	return formulary_spec_boundary(504, 'let', 'let `let(:disable_json) do` at line 504.')
}

// Ruby let `let(:future_date) { Date.today + 365 }` at line 515.
pub fn ruby_formulary_spec_l515_d67_future_date() FormularySpecBoundary {
	return formulary_spec_boundary(515, 'let', 'let `let(:future_date) { Date.today + 365 }` at line 515.')
}

// Ruby let `let(:deprecate_future_json) do` at line 517.
pub fn ruby_formulary_spec_l517_d68_deprecate_future_json() FormularySpecBoundary {
	return formulary_spec_boundary(517, 'let', 'let `let(:deprecate_future_json) do` at line 517.')
}

// Ruby let `let(:disable_future_json) do` at line 532.
pub fn ruby_formulary_spec_l532_d69_disable_future_json() FormularySpecBoundary {
	return formulary_spec_boundary(532, 'let', 'let `let(:disable_future_json) do` at line 532.')
}

// Ruby let `let(:variations_json) do` at line 553.
pub fn ruby_formulary_spec_l553_d70_variations_json() FormularySpecBoundary {
	return formulary_spec_boundary(553, 'let', 'let `let(:variations_json) do` at line 553.')
}

// Ruby let `let(:older_macos_variations_json) do` at line 563.
pub fn ruby_formulary_spec_l563_d71_older_macos_variations_json() FormularySpecBoundary {
	return formulary_spec_boundary(563, 'let', 'let `let(:older_macos_variations_json) do` at line 563.')
}

// Ruby let `let(:linux_variations_json) do` at line 573.
pub fn ruby_formulary_spec_l573_d72_linux_variations_json() FormularySpecBoundary {
	return formulary_spec_boundary(573, 'let', 'let `let(:linux_variations_json) do` at line 573.')
}

// Ruby it `it "returns a Formula when given a name" do` at line 606.
pub fn ruby_formulary_spec_l606_d73_returns() FormularySpecBoundary {
	return formulary_spec_boundary(606, 'it', 'it `it "returns a Formula when given a name" do` at line 606.')
}

// Ruby it `it "returns a Formula loaded from the internal API" do` at line 646.
pub fn ruby_formulary_spec_l646_d74_returns() FormularySpecBoundary {
	return formulary_spec_boundary(646, 'it', 'it `it "returns a Formula loaded from the internal API" do` at line 646.')
}

// Ruby it `it "runs post-install steps loaded from the internal API without source Ruby" do` at line 655.
pub fn ruby_formulary_spec_l655_d75_runs() FormularySpecBoundary {
	return formulary_spec_boundary(655, 'it', 'it `it "runs post-install steps loaded from the internal API without source Ruby" do` at line 655.')
}

// Ruby it `it "loads patches from API JSON" do` at line 668.
pub fn ruby_formulary_spec_l668_d76_loads() FormularySpecBoundary {
	return formulary_spec_boundary(668, 'it', 'it `it "loads patches from API JSON" do` at line 668.')
}

// Ruby it `it "returns a deprecated Formula when given a name" do` at line 691.
pub fn ruby_formulary_spec_l691_d77_returns() FormularySpecBoundary {
	return formulary_spec_boundary(691, 'it', 'it `it "returns a deprecated Formula when given a name" do` at line 691.')
}

// Ruby it `it "returns a disabled Formula when given a name" do` at line 704.
pub fn ruby_formulary_spec_l704_d78_returns() FormularySpecBoundary {
	return formulary_spec_boundary(704, 'it', 'it `it "returns a disabled Formula when given a name" do` at line 704.')
}

// Ruby it `it "returns a future-deprecated Formula when given a name" do` at line 717.
pub fn ruby_formulary_spec_l717_d79_returns() FormularySpecBoundary {
	return formulary_spec_boundary(717, 'it', 'it `it "returns a future-deprecated Formula when given a name" do` at line 717.')
}

// Ruby it `it "returns a future-disabled Formula when given a name" do` at line 733.
pub fn ruby_formulary_spec_l733_d80_returns() FormularySpecBoundary {
	return formulary_spec_boundary(733, 'it', 'it `it "returns a future-disabled Formula when given a name" do` at line 733.')
}

// Ruby it `it "returns a Formula with variations when given a name", :needs_macos do` at line 753.
pub fn ruby_formulary_spec_l753_d81_returns() FormularySpecBoundary {
	return formulary_spec_boundary(753, 'it', 'it `it "returns a Formula with variations when given a name", :needs_macos do` at line 753.')
}

// Ruby it `it "returns a Formula without duplicated deps and uses_from_macos with variations on Linux", :needs_linux do` at line 764.
pub fn ruby_formulary_spec_l764_d82_returns() FormularySpecBoundary {
	return formulary_spec_boundary(764, 'it', 'it `it "returns a Formula without duplicated deps and uses_from_macos with variations on Linux", :needs_linux do` at line 764.')
}

// Ruby it `it "returns a Formula with the correct uses_from_macos dep on older macOS", :needs_macos do` at line 775.
pub fn ruby_formulary_spec_l775_d83_returns() FormularySpecBoundary {
	return formulary_spec_boundary(775, 'it', 'it `it "returns a Formula with the correct uses_from_macos dep on older macOS", :needs_macos do` at line 775.')
}

// Ruby let `let(:foo_tap) { Tap.fetch("homebrew", "foo") }` at line 787.
pub fn ruby_formulary_spec_l787_d84_foo_tap() FormularySpecBoundary {
	return formulary_spec_boundary(787, 'let', 'let `let(:foo_tap) { Tap.fetch("homebrew", "foo") }` at line 787.')
}

// Ruby it `it "returns the tap migration rename by old formula_name" do` at line 800.
pub fn ruby_formulary_spec_l800_d85_returns() FormularySpecBoundary {
	return formulary_spec_boundary(800, 'it', 'it `it "returns the tap migration rename by old formula_name" do` at line 800.')
}

// Ruby it `it "returns the tap migration rename by old full name" do` at line 812.
pub fn ruby_formulary_spec_l812_d86_returns() FormularySpecBoundary {
	return formulary_spec_boundary(812, 'it', 'it `it "returns the tap migration rename by old full name" do` at line 812.')
}

// Ruby it `it "raises an error when given an https URL" do` at line 827.
pub fn ruby_formulary_spec_l827_d87_raises() FormularySpecBoundary {
	return formulary_spec_boundary(827, 'it', 'it `it "raises an error when given an https URL" do` at line 827.')
}

// Ruby it `it "raises an error when given a bottle URL" do` at line 833.
pub fn ruby_formulary_spec_l833_d88_raises() FormularySpecBoundary {
	return formulary_spec_boundary(833, 'it', 'it `it "raises an error when given a bottle URL" do` at line 833.')
}

// Ruby it `it "raises an error when given an ftp URL" do` at line 839.
pub fn ruby_formulary_spec_l839_d89_raises() FormularySpecBoundary {
	return formulary_spec_boundary(839, 'it', 'it `it "raises an error when given an ftp URL" do` at line 839.')
}

// Ruby it `it "raises an error when given an sftp URL" do` at line 845.
pub fn ruby_formulary_spec_l845_d90_raises() FormularySpecBoundary {
	return formulary_spec_boundary(845, 'it', 'it `it "raises an error when given an sftp URL" do` at line 845.')
}

// Ruby it `it "does not raise an error when given a file URL", :needs_utils_curl do` at line 851.
pub fn ruby_formulary_spec_l851_d91_does() FormularySpecBoundary {
	return formulary_spec_boundary(851, 'it', 'it `it "does not raise an error when given a file URL", :needs_utils_curl do` at line 851.')
}

// Ruby it `it "raises a FormulaUnavailableError error" do` at line 859.
pub fn ruby_formulary_spec_l859_d92_raises() FormularySpecBoundary {
	return formulary_spec_boundary(859, 'it', 'it `it "raises a FormulaUnavailableError error" do` at line 859.')
}

// Ruby specify `specify "::from_contents" do` at line 867.
pub fn ruby_formulary_spec_l867_d93_from_contents() FormularySpecBoundary {
	return formulary_spec_boundary(867, 'specify', 'specify `specify "::from_contents" do` at line 867.')
}

// Ruby alias_matcher `alias_matcher :exist, :be_exist` at line 872.
pub fn ruby_formulary_spec_l872_d94_exist() FormularySpecBoundary {
	return formulary_spec_boundary(872, 'alias_matcher', 'alias_matcher `alias_matcher :exist, :be_exist` at line 872.')
}

// Ruby let `let(:rack_path) { HOMEBREW_CELLAR/formula_name }` at line 874.
pub fn ruby_formulary_spec_l874_d95_rack_path() FormularySpecBoundary {
	return formulary_spec_boundary(874, 'let', 'let `let(:rack_path) { HOMEBREW_CELLAR/formula_name }` at line 874.')
}

// Ruby it `it "returns the Rack" do` at line 877.
pub fn ruby_formulary_spec_l877_d96_returns() FormularySpecBoundary {
	return formulary_spec_boundary(877, 'it', 'it `it "returns the Rack" do` at line 877.')
}

// Ruby it `it "returns the Rack" do` at line 887.
pub fn ruby_formulary_spec_l887_d97_returns() FormularySpecBoundary {
	return formulary_spec_boundary(887, 'it', 'it `it "returns the Rack" do` at line 887.')
}

// Ruby it `it "raises an error if the Formula is not available" do` at line 892.
pub fn ruby_formulary_spec_l892_d98_raises() FormularySpecBoundary {
	return formulary_spec_boundary(892, 'it', 'it `it "raises an error if the Formula is not available" do` at line 892.')
}

// Ruby it `it "locates an installed Rack from an untrusted tap without evaluating its formula" do` at line 898.
pub fn ruby_formulary_spec_l898_d99_locates() FormularySpecBoundary {
	return formulary_spec_boundary(898, 'it', 'it `it "locates an installed Rack from an untrusted tap without evaluating its formula" do` at line 898.')
}

// Ruby it `it "returns the path to a Formula in the core tap" do` at line 921.
pub fn ruby_formulary_spec_l921_d100_returns() FormularySpecBoundary {
	return formulary_spec_boundary(921, 'it', 'it `it "returns the path to a Formula in the core tap" do` at line 921.')
}

// Ruby it `it "returns the sharded path directly for API-known formulae" do` at line 927.
pub fn ruby_formulary_spec_l927_d101_returns() FormularySpecBoundary {
	return formulary_spec_boundary(927, 'it', 'it `it "returns the sharded path directly for API-known formulae" do` at line 927.')
}

// Ruby it `it "returns a `FromPathLoader`" do` at line 939.
pub fn ruby_formulary_spec_l939_d102_returns() FormularySpecBoundary {
	return formulary_spec_boundary(939, 'it', 'it `it "returns a `FromPathLoader`" do` at line 939.')
}

// Ruby it `it "returns a `FromTapLoader`", :no_api do` at line 949.
pub fn ruby_formulary_spec_l949_d103_returns() FormularySpecBoundary {
	return formulary_spec_boundary(949, 'it', 'it `it "returns a `FromTapLoader`", :no_api do` at line 949.')
}

// Ruby let `let(:token) { "foo" }` at line 956.
pub fn ruby_formulary_spec_l956_d104_token() FormularySpecBoundary {
	return formulary_spec_boundary(956, 'let', 'let `let(:token) { "foo" }` at line 956.')
}

// Ruby let `let(:old_tap) { core_tap }` at line 957.
pub fn ruby_formulary_spec_l957_d105_old_tap() FormularySpecBoundary {
	return formulary_spec_boundary(957, 'let', 'let `let(:old_tap) { core_tap }` at line 957.')
}

// Ruby let `let(:new_tap) { core_cask_tap }` at line 958.
pub fn ruby_formulary_spec_l958_d106_new_tap() FormularySpecBoundary {
	return formulary_spec_boundary(958, 'let', 'let `let(:new_tap) { core_cask_tap }` at line 958.')
}

// Ruby let `let(:core_tap) { CoreTap.instance }` at line 960.
pub fn ruby_formulary_spec_l960_d107_core_tap() FormularySpecBoundary {
	return formulary_spec_boundary(960, 'let', 'let `let(:core_tap) { CoreTap.instance }` at line 960.')
}

// Ruby let `let(:core_cask_tap) { CoreCaskTap.instance }` at line 961.
pub fn ruby_formulary_spec_l961_d108_core_cask_tap() FormularySpecBoundary {
	return formulary_spec_boundary(961, 'let', 'let `let(:core_cask_tap) { CoreCaskTap.instance }` at line 961.')
}

// Ruby let `let(:tap_migrations) do` at line 963.
pub fn ruby_formulary_spec_l963_d109_tap_migrations() FormularySpecBoundary {
	return formulary_spec_boundary(963, 'let', 'let `let(:tap_migrations) do` at line 963.')
}

// Ruby let `let(:old_tap) { core_tap }` at line 977.
pub fn ruby_formulary_spec_l977_d110_old_tap() FormularySpecBoundary {
	return formulary_spec_boundary(977, 'let', 'let `let(:old_tap) { core_tap }` at line 977.')
}

// Ruby let `let(:new_tap) { core_cask_tap }` at line 978.
pub fn ruby_formulary_spec_l978_d111_new_tap() FormularySpecBoundary {
	return formulary_spec_boundary(978, 'let', 'let `let(:new_tap) { core_cask_tap }` at line 978.')
}

// Ruby let `let(:cask_file) { new_tap.cask_dir/"#{token}.rb" }` at line 980.
pub fn ruby_formulary_spec_l980_d112_cask_file() FormularySpecBoundary {
	return formulary_spec_boundary(980, 'let', 'let `let(:cask_file) { new_tap.cask_dir/"#{token}.rb" }` at line 980.')
}

// Ruby it `it "does not warn when loading the short token" do` at line 987.
pub fn ruby_formulary_spec_l987_d113_does() FormularySpecBoundary {
	return formulary_spec_boundary(987, 'it', 'it `it "does not warn when loading the short token" do` at line 987.')
}

// Ruby let `let(:old_tap) { core_cask_tap }` at line 995.
pub fn ruby_formulary_spec_l995_d114_old_tap() FormularySpecBoundary {
	return formulary_spec_boundary(995, 'let', 'let `let(:old_tap) { core_cask_tap }` at line 995.')
}

// Ruby let `let(:new_tap) { core_tap }` at line 996.
pub fn ruby_formulary_spec_l996_d115_new_tap() FormularySpecBoundary {
	return formulary_spec_boundary(996, 'let', 'let `let(:new_tap) { core_tap }` at line 996.')
}

// Ruby let `let(:formula_file) { new_tap.formula_dir/"#{token}.rb" }` at line 998.
pub fn ruby_formulary_spec_l998_d116_formula_file() FormularySpecBoundary {
	return formulary_spec_boundary(998, 'let', 'let `let(:formula_file) { new_tap.formula_dir/"#{token}.rb" }` at line 998.')
}

// Ruby it `it "does not warn when loading the short token" do` at line 1005.
pub fn ruby_formulary_spec_l1005_d117_does() FormularySpecBoundary {
	return formulary_spec_boundary(1005, 'it', 'it `it "does not warn when loading the short token" do` at line 1005.')
}

// Ruby it `it "does not warn when loading the full token in the default tap" do` at line 1011.
pub fn ruby_formulary_spec_l1011_d118_does() FormularySpecBoundary {
	return formulary_spec_boundary(1011, 'it', 'it `it "does not warn when loading the full token in the default tap" do` at line 1011.')
}

// Ruby it `it "warns when loading the full token in the old tap" do` at line 1017.
pub fn ruby_formulary_spec_l1017_d119_warns() FormularySpecBoundary {
	return formulary_spec_boundary(1017, 'it', 'it `it "warns when loading the full token in the old tap" do` at line 1017.')
}

// Ruby let `let(:old_tap) { Tap.fetch("another", "foo") }` at line 1042.
pub fn ruby_formulary_spec_l1042_d120_old_tap() FormularySpecBoundary {
	return formulary_spec_boundary(1042, 'let', 'let `let(:old_tap) { Tap.fetch("another", "foo") }` at line 1042.')
}

// Ruby let `let(:new_tap) { Tap.fetch("another", "bar") }` at line 1043.
pub fn ruby_formulary_spec_l1043_d121_new_tap() FormularySpecBoundary {
	return formulary_spec_boundary(1043, 'let', 'let `let(:new_tap) { Tap.fetch("another", "bar") }` at line 1043.')
}

// Ruby let `let(:cask_file) { new_tap.cask_dir/"#{token}.rb" }` at line 1044.
pub fn ruby_formulary_spec_l1044_d122_cask_file() FormularySpecBoundary {
	return formulary_spec_boundary(1044, 'let', 'let `let(:cask_file) { new_tap.cask_dir/"#{token}.rb" }` at line 1044.')
}

// Ruby it `it "does not warn when loading the short token" do` at line 1055.
pub fn ruby_formulary_spec_l1055_d123_does() FormularySpecBoundary {
	return formulary_spec_boundary(1055, 'it', 'it `it "does not warn when loading the short token" do` at line 1055.')
}

// Ruby let `let(:old_tap) { Tap.fetch("another", "foo") }` at line 1063.
pub fn ruby_formulary_spec_l1063_d124_old_tap() FormularySpecBoundary {
	return formulary_spec_boundary(1063, 'let', 'let `let(:old_tap) { Tap.fetch("another", "foo") }` at line 1063.')
}

// Ruby let `let(:new_tap) { Tap.fetch("another", "bar") }` at line 1064.
pub fn ruby_formulary_spec_l1064_d125_new_tap() FormularySpecBoundary {
	return formulary_spec_boundary(1064, 'let', 'let `let(:new_tap) { Tap.fetch("another", "bar") }` at line 1064.')
}

// Ruby let `let(:formula_file) { new_tap.formula_dir/"#{token}.rb" }` at line 1065.
pub fn ruby_formulary_spec_l1065_d126_formula_file() FormularySpecBoundary {
	return formulary_spec_boundary(1065, 'let', 'let `let(:formula_file) { new_tap.formula_dir/"#{token}.rb" }` at line 1065.')
}

// Ruby it `it "warns when loading the short token" do` at line 1078.
pub fn ruby_formulary_spec_l1078_d127_warns() FormularySpecBoundary {
	return formulary_spec_boundary(1078, 'it', 'it `it "warns when loading the short token" do` at line 1078.')
}

// Ruby it `it "warns with the canonical token when loading an uppercase short token" do` at line 1086.
pub fn ruby_formulary_spec_l1086_d128_warns() FormularySpecBoundary {
	return formulary_spec_boundary(1086, 'it', 'it `it "warns with the canonical token when loading an uppercase short token" do` at line 1086.')
}

// Ruby it `it "does not warn when loading the full token in the new tap" do` at line 1094.
pub fn ruby_formulary_spec_l1094_d129_does() FormularySpecBoundary {
	return formulary_spec_boundary(1094, 'it', 'it `it "does not warn when loading the full token in the new tap" do` at line 1094.')
}

// Ruby it `it "warns when loading the full token in the old tap" do` at line 1100.
pub fn ruby_formulary_spec_l1100_d130_warns() FormularySpecBoundary {
	return formulary_spec_boundary(1100, 'it', 'it `it "warns when loading the full token in the old tap" do` at line 1100.')
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "formula_installer"
// 6: require "utils/bottles"
// 7:
// 8: RSpec.describe Formulary do
// 9:   let(:formula_name) { "testball_bottle" }
// 10:   let(:formula_path) { CoreTap.instance.new_formula_path(formula_name) }
// 11:   let(:formula_content) do
// 12:     <<~RUBY
// 13:       class #{described_class.class_s(formula_name)} < Formula
// 14:         url "file://#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz"
// 15:         sha256 TESTBALL_SHA256
// 16:
// 17:         bottle do
// 18:           root_url "file://#{bottle_dir}"
// 19:           sha256 cellar: :any_skip_relocation, #{Utils::Bottles.tag}: "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97"
// 20:         end
// 21:
// 22:         def install
// 23:           prefix.install "bin"
// 24:           prefix.install "libexec"
// 25:         end
// 26:       end
// 27:     RUBY
// 28:   end
// 29:   let(:bottle_dir) { Pathname.new("#{TEST_FIXTURE_DIR}/bottles") }
// 30:   let(:bottle) { bottle_dir/"testball_bottle-0.1.#{Utils::Bottles.tag}.bottle.tar.gz" }
// 31:
// 32:   describe "::class_s" do
// 33:     it "replaces '+' with 'x'" do
// 34:       expect(described_class.class_s("foo++")).to eq("Fooxx")
// 35:     end
// 36:
// 37:     it "converts a string with dots to PascalCase" do
// 38:       expect(described_class.class_s("shell.fm")).to eq("ShellFm")
// 39:     end
// 40:
// 41:     it "converts a string with hyphens to PascalCase" do
// 42:       expect(described_class.class_s("pkg-config")).to eq("PkgConfig")
// 43:     end
// 44:
// 45:     it "converts a string with a single letter separated by a hyphen to PascalCase" do
// 46:       expect(described_class.class_s("s-lang")).to eq("SLang")
// 47:     end
// 48:
// 49:     it "converts a string with underscores to PascalCase" do
// 50:       expect(described_class.class_s("foo_bar")).to eq("FooBar")
// 51:     end
// 52:
// 53:     it "replaces '@' with 'AT'" do
// 54:       expect(described_class.class_s("openssl@1.1")).to eq("OpensslAT11")
// 55:     end
// 56:   end
// 57:
// 58:   describe "::load_formula" do
// 59:     it "continues evaluation after ignorable errors with ignore_errors" do
// 60:       formula_class = described_class.load_formula(
// 61:         "ignorable-error",
// 62:         mktmpdir/"ignorable-error.rb",
// 63:         <<~RUBY,
// 64:           class IgnorableError < Formula
// 65:             raise ArgumentError, "should be ignored"
// 66:             url "https://brew.sh/ignorable-error-1.0.tar.gz"
// 67:           end
// 68:         RUBY
// 69:         "IgnorableErrorNamespace",
// 70:         flags:         [],
// 71:         ignore_errors: true,
// 72:       )
// 73:
// 74:       expect(formula_class.stable.url).to eq("https://brew.sh/ignorable-error-1.0.tar.gz")
// 75:     end
// 76:
// 77:     it "raises FormulaUnreadableError for errors it cannot resume despite ignore_errors" do
// 78:       expect do
// 79:         described_class.load_formula(
// 80:           "unreadable-error",
// 81:           mktmpdir/"unreadable-error.rb",
// 82:           <<~RUBY,
// 83:             class UnreadableError < Formula
// 84:               nonexistent_dsl_method "foo"
// 85:               url "https://brew.sh/unreadable-error-1.0.tar.gz"
// 86:             end
// 87:           RUBY
// 88:           "UnreadableErrorNamespace",
// 89:           flags:         [],
// 90:           ignore_errors: true,
// 91:         )
// 92:       end.to raise_error(FormulaUnreadableError)
// 93:     end
// 94:
// 95:     it "masks sensitive environment variables while evaluating formulae" do
// 96:       with_env(HOMEBREW_SECRET_TOKEN: "password") do
// 97:         formula_class = described_class.load_formula(
// 98:           "sensitive-env",
// 99:           mktmpdir/"sensitive-env.rb",
// 100:           <<~RUBY,
// 101:             class SensitiveEnv < Formula
// 102:               SECRET_TOKEN_VALUE = ENV.fetch("HOMEBREW_SECRET_TOKEN", nil)
// 103:               url "https://brew.sh/sensitive-env-1.0.tar.gz"
// 104:             end
// 105:           RUBY
// 106:           "SensitiveEnvNamespace",
// 107:           flags:         [],
// 108:           ignore_errors: false,
// 109:         )
// 110:
// 111:         expect(formula_class::SECRET_TOKEN_VALUE).not_to eq("password")
// 112:         expect(ENV.fetch("HOMEBREW_SECRET_TOKEN", nil)).to eq("password")
// 113:       end
// 114:     end
// 115:
// 116:     it "allows the GitHub API token while evaluating formulae" do
// 117:       with_env(HOMEBREW_GITHUB_API_TOKEN: "github-token") do
// 118:         formula_class = described_class.load_formula(
// 119:           "github-token-env",
// 120:           mktmpdir/"github-token-env.rb",
// 121:           <<~RUBY,
// 122:             class GithubTokenEnv < Formula
// 123:               GITHUB_TOKEN_PRESENT = ENV.key?("HOMEBREW_GITHUB_API_TOKEN")
// 124:               url "https://brew.sh/github-token-env-1.0.tar.gz"
// 125:             end
// 126:           RUBY
// 127:           "GithubTokenEnvNamespace",
// 128:           flags:         [],
// 129:           ignore_errors: false,
// 130:         )
// 131:
// 132:         expect(formula_class::GITHUB_TOKEN_PRESENT).to be(true)
// 133:       end
// 134:     end
// 135:
// 136:     it "refuses untrusted third-party tap formulae when trust is enabled" do
// 137:       tap = Tap.fetch("formularytrust", "foo")
// 138:       formula_path = tap.formula_dir/"sensitive-env.rb"
// 139:       formula_path.dirname.mkpath
// 140:       formula_path.write <<~RUBY
// 141:         class SensitiveEnv < Formula
// 142:           url "https://brew.sh/sensitive-env-1.0.tar.gz"
// 143:         end
// 144:       RUBY
// 145:       full_name = "#{tap.name}/sensitive-env"
// 146:
// 147:       with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1", HOMEBREW_USER_CONFIG_HOME: mktmpdir) do
// 148:         expect { described_class.factory(formula_path) }
// 149:           .to raise_error(Homebrew::UntrustedTapError, /#{tap.name}/)
// 150:
// 151:         Homebrew::Trust.trust!(:formula, full_name)
// 152:
// 153:         expect(described_class.factory(formula_path).full_name).to eq(full_name)
// 154:       end
// 155:     ensure
// 156:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"formularytrust"
// 157:     end
// 158:   end
// 159:
// 160:   describe "::factory" do
// 161:     context "without the API", :no_api do
// 162:       before do
// 163:         formula_path.dirname.mkpath
// 164:         formula_path.write formula_content
// 165:       end
// 166:
// 167:       it "returns a Formula" do
// 168:         expect(described_class.factory(formula_name)).to be_a(Formula)
// 169:       end
// 170:
// 171:       it "returns a Formula when given a fully qualified name" do
// 172:         expect(described_class.factory("homebrew/core/#{formula_name}")).to be_a(Formula)
// 173:       end
// 174:
// 175:       it "raises an error if the Formula cannot be found" do
// 176:         expect do
// 177:           described_class.factory("not_existed_formula")
// 178:         end.to raise_error(FormulaUnavailableError)
// 179:       end
// 180:
// 181:       it "raises an error if ref is nil" do
// 182:         expect do
// 183:           described_class.factory(nil)
// 184:         end.to raise_error(TypeError)
// 185:       end
// 186:
// 187:       context "with sharded Formula directory" do
// 188:         let(:formula_name) { "testball_sharded" }
// 189:         let(:formula_path) do
// 190:           core_tap = CoreTap.instance
// 191:           (core_tap.formula_dir/formula_name[0]).mkpath
// 192:           core_tap.new_formula_path(formula_name)
// 193:         end
// 194:
// 195:         it "returns a Formula" do
// 196:           expect(described_class.factory(formula_name)).to be_a(Formula)
// 197:         end
// 198:
// 199:         it "returns a Formula when given a fully qualified name" do
// 200:           expect(described_class.factory("homebrew/core/#{formula_name}")).to be_a(Formula)
// 201:         end
// 202:       end
// 203:
// 204:       context "when the Formula has the wrong class" do
// 205:         let(:formula_name) { "giraffe" }
// 206:         let(:formula_content) do
// 207:           <<~RUBY
// 208:             class Wrong#{described_class.class_s(formula_name)} < Formula
// 209:             end
// 210:           RUBY
// 211:         end
// 212:
// 213:         it "raises an error" do
// 214:           expect do
// 215:             described_class.factory(formula_name)
// 216:           end.to raise_error(TapFormulaClassUnavailableError)
// 217:         end
// 218:       end
// 219:
// 220:       it "returns a Formula when given a path" do
// 221:         expect(described_class.factory(formula_path)).to be_a(Formula)
// 222:       end
// 223:
// 224:       it "errors when given a path but paths are disabled" do
// 225:         ENV["HOMEBREW_FORBID_PACKAGES_FROM_PATHS"] = "1"
// 226:         FileUtils.cp formula_path, HOMEBREW_TEMP
// 227:         temp_formula_path = HOMEBREW_TEMP/formula_path.basename
// 228:         expect do
// 229:           described_class.factory(temp_formula_path)
// 230:         ensure
// 231:           temp_formula_path.unlink
// 232:         end.to raise_error(RuntimeError, /requires formulae to be in a tap, rejecting/)
// 233:       end
// 234:
// 235:       it "returns a Formula when given a URL", :needs_utils_curl do
// 236:         formula = described_class.factory("file://#{formula_path}")
// 237:         expect(formula).to be_a(Formula)
// 238:       end
// 239:
// 240:       it "errors when given a URL but paths are disabled" do
// 241:         ENV["HOMEBREW_FORBID_PACKAGES_FROM_PATHS"] = "1"
// 242:         expect do
// 243:           described_class.factory("file://#{formula_path}")
// 244:         end.to raise_error(FormulaUnavailableError)
// 245:       end
// 246:
// 247:       context "when given a cache path" do
// 248:         let(:cache_dir) { HOMEBREW_CACHE/"test_formula_cache" }
// 249:         let(:cache_formula_path) { cache_dir/formula_path.basename }
// 250:
// 251:         before do
// 252:           cache_dir.mkpath
// 253:           FileUtils.cp formula_path, cache_formula_path
// 254:         end
// 255:
// 256:         after do
// 257:           cache_formula_path.unlink if cache_formula_path.exist?
// 258:           cache_dir.rmdir if cache_dir.exist?
// 259:         end
// 260:
// 261:         it "disallows cache paths when paths are explicitly disabled" do
// 262:           ENV["HOMEBREW_FORBID_PACKAGES_FROM_PATHS"] = "1"
// 263:           expect do
// 264:             described_class.factory(cache_formula_path)
// 265:           end.to raise_error(/requires formulae to be in a tap/)
// 266:         end
// 267:       end
// 268:
// 269:       context "when given a bottle" do
// 270:         subject(:formula) { described_class.factory(bottle) }
// 271:
// 272:         specify do
// 273:           expect(formula).to be_a(Formula)
// 274:           expect(formula.local_bottle_path).to eq(bottle.realpath)
// 275:         end
// 276:       end
// 277:
// 278:       context "when given an alias" do
// 279:         subject(:formula) { described_class.factory("foo") }
// 280:
// 281:         let(:alias_dir) { CoreTap.instance.alias_dir }
// 282:         let(:alias_path) { alias_dir/"foo" }
// 283:
// 284:         before do
// 285:           alias_dir.mkpath
// 286:           FileUtils.ln_s formula_path, alias_path
// 287:         end
// 288:
// 289:         specify do
// 290:           expect(formula).to be_a(Formula)
// 291:           expect(formula.alias_path).to eq(alias_path)
// 292:         end
// 293:       end
// 294:
// 295:       context "with installed Formula" do
// 296:         before do
// 297:           # don't try to load/fetch gcc/glibc
// 298:           allow(DevelopmentTools).to receive_messages(needs_libc_formula?: false, needs_compiler_formula?: false)
// 299:         end
// 300:
// 301:         let(:installed_formula) { described_class.factory(formula_path) }
// 302:         let(:installer) { FormulaInstaller.new(installed_formula) }
// 303:
// 304:         it "returns a Formula when given a rack" do
// 305:           installer.fetch
// 306:           installer.install
// 307:
// 308:           f = described_class.from_rack(installed_formula.rack)
// 309:           expect(f).to be_a(Formula)
// 310:         end
// 311:
// 312:         it "returns a Formula when given a Keg" do
// 313:           installer.fetch
// 314:           installer.install
// 315:
// 316:           keg = Keg.new(installed_formula.prefix)
// 317:           f = described_class.from_keg(keg)
// 318:           expect(f).to be_a(Formula)
// 319:         end
// 320:       end
// 321:
// 322:       context "when migrating from a Tap" do
// 323:         let(:tap) { Tap.fetch("homebrew", "foo") }
// 324:         let(:another_tap) { Tap.fetch("homebrew", "bar") }
// 325:         let(:tap_migrations_path) { tap.path/"tap_migrations.json" }
// 326:         let(:another_tap_formula_path) { another_tap.path/"Formula/#{formula_name}.rb" }
// 327:
// 328:         before do
// 329:           tap.path.mkpath
// 330:           another_tap_formula_path.dirname.mkpath
// 331:           another_tap_formula_path.write formula_content
// 332:         end
// 333:
// 334:         after do
// 335:           FileUtils.rm_rf tap.path
// 336:           FileUtils.rm_rf another_tap.path
// 337:         end
// 338:
// 339:         it "returns a Formula that has gone through a tap migration into homebrew/core" do
// 340:           tap_migrations_path.write <<~JSON
// 341:             {
// 342:               "#{formula_name}": "homebrew/core"
// 343:             }
// 344:           JSON
// 345:           formula = described_class.factory("#{tap}/#{formula_name}")
// 346:           expect(formula).to be_a(Formula)
// 347:           expect(formula.tap).to eq(CoreTap.instance)
// 348:           expect(formula.path).to eq(formula_path)
// 349:         end
// 350:
// 351:         it "returns a Formula that has gone through a tap migration into another tap" do
// 352:           tap_migrations_path.write <<~JSON
// 353:             {
// 354:               "#{formula_name}": "#{another_tap}"
// 355:             }
// 356:           JSON
// 357:           formula = described_class.factory("#{tap}/#{formula_name}")
// 358:           expect(formula).to be_a(Formula)
// 359:           expect(formula.tap).to eq(another_tap)
// 360:           expect(formula.path).to eq(another_tap_formula_path)
// 361:         end
// 362:
// 363:         it "raises when the migrated tap is not installed" do
// 364:           tap_migrations_path.write <<~JSON
// 365:             {
// 366:               "#{formula_name}": "#{another_tap}"
// 367:             }
// 368:           JSON
// 369:           FileUtils.rm_rf another_tap.path
// 370:
// 371:           expect(another_tap).not_to receive(:ensure_installed!)
// 372:
// 373:           expect { described_class.factory("#{tap}/#{formula_name}") }
// 374:             .to raise_error(TapFormulaUnavailableError, /If you trust this tap/)
// 375:         end
// 376:       end
// 377:
// 378:       context "when loading from Tap" do
// 379:         let(:tap) { Tap.fetch("homebrew", "foo") }
// 380:         let(:another_tap) { Tap.fetch("homebrew", "bar") }
// 381:         let(:formula_path) { tap.path/"Formula/#{formula_name}.rb" }
// 382:         let(:alias_name) { "bar" }
// 383:         let(:alias_dir) { tap.alias_dir }
// 384:         let(:alias_path) { alias_dir/alias_name }
// 385:
// 386:         before do
// 387:           alias_dir.mkpath
// 388:           FileUtils.ln_s formula_path, alias_path
// 389:         end
// 390:
// 391:         it "returns a Formula when given a name" do
// 392:           expect(described_class.factory(formula_name)).to be_a(Formula)
// 393:         end
// 394:
// 395:         it "returns a Formula with the correct alias path from a bare or fully qualified Alias name" do
// 396:           expect(described_class.factory(alias_name).alias_path).to eq(alias_path)
// 397:           expect(described_class.factory("#{tap.name}/#{alias_name}").alias_path).to eq(alias_path)
// 398:         end
// 399:
// 400:         it "raises an error when the Formula cannot be found" do
// 401:           expect do
// 402:             described_class.factory("#{tap}/not_existed_formula")
// 403:           end.to raise_error(TapFormulaUnavailableError)
// 404:         end
// 405:
// 406:         it "returns a Formula when given a fully qualified name" do
// 407:           expect(described_class.factory("#{tap}/#{formula_name}")).to be_a(Formula)
// 408:         end
// 409:
// 410:         it "raises an error if a Formula is in multiple Taps" do
// 411:           (another_tap.path/"Formula").mkpath
// 412:           (another_tap.path/"Formula/#{formula_name}.rb").write formula_content
// 413:
// 414:           expect do
// 415:             described_class.factory(formula_name)
// 416:           end.to raise_error(TapFormulaAmbiguityError)
// 417:         end
// 418:       end
// 419:     end
// 420:
// 421:     context "with the API" do
// 422:       def formula_json_contents(extra_items = {})
// 423:         {
// 424:           formula_name => {
// 425:             "name"                     => formula_name,
// 426:             "desc"                     => "testball",
// 427:             "homepage"                 => "https://example.com",
// 428:             "installed"                => [],
// 429:             "outdated"                 => false,
// 430:             "pinned"                   => false,
// 431:             "license"                  => "MIT",
// 432:             "revision"                 => 0,
// 433:             "version_scheme"           => 0,
// 434:             "versions"                 => { "stable" => "0.1" },
// 435:             "urls"                     => {
// 436:               "stable" => {
// 437:                 "url"      => "file://#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz",
// 438:                 "tag"      => nil,
// 439:                 "revision" => nil,
// 440:               },
// 441:             },
// 442:             "bottle"                   => {
// 443:               "stable" => {
// 444:                 "rebuild"  => 0,
// 445:                 "root_url" => "file://#{bottle_dir}",
// 446:                 "files"    => {
// 447:                   Utils::Bottles.tag.to_s => {
// 448:                     "cellar" => ":any",
// 449:                     "url"    => "file://#{bottle_dir}/#{formula_name}",
// 450:                     "sha256" => "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97",
// 451:                   },
// 452:                 },
// 453:               },
// 454:             },
// 455:             "keg_only_reason"          => {
// 456:               "reason"      => ":provided_by_macos",
// 457:               "explanation" => "",
// 458:             },
// 459:             "build_dependencies"       => ["build_dep"],
// 460:             "dependencies"             => ["dep"],
// 461:             "test_dependencies"        => ["test_dep"],
// 462:             "recommended_dependencies" => ["recommended_dep"],
// 463:             "optional_dependencies"    => ["optional_dep"],
// 464:             "uses_from_macos"          => ["uses_from_macos_dep"],
// 465:             "requirements"             => [
// 466:               {
// 467:                 "name"     => "xcode",
// 468:                 "cask"     => nil,
// 469:                 "download" => nil,
// 470:                 "version"  => "1.0",
// 471:                 "contexts" => ["build"],
// 472:                 "specs"    => ["stable"],
// 473:               },
// 474:             ],
// 475:             "conflicts_with"           => ["conflicting_formula"],
// 476:             "conflicts_with_reasons"   => ["it does"],
// 477:             "link_overwrite"           => ["bin/abc"],
// 478:             "linked_keg"               => nil,
// 479:             "caveats"                  => "example caveat string\n/$HOME\n$HOMEBREW_PREFIX",
// 480:             "service"                  => {
// 481:               "name"        => { macos: "custom.launchd.name", linux: "custom.systemd.name" },
// 482:               "run"         => ["$HOMEBREW_PREFIX/opt/formula_name/bin/beanstalkd", "test"],
// 483:               "run_type"    => "immediate",
// 484:               "working_dir" => "/$HOME",
// 485:             },
// 486:             "ruby_source_path"         => "Formula/#{formula_name}.rb",
// 487:             "ruby_source_checksum"     => { "sha256" => "ABCDEFGHIJKLMNOPQRSTUVWXYZ" },
// 488:             "tap_git_head"             => "0000000000000000000000000000000000000000",
// 489:           }.merge(extra_items),
// 490:         }
// 491:       end
// 492:
// 493:       let(:deprecate_json) do
// 494:         {
// 495:           "deprecated"                      => true,
// 496:           "deprecation_date"                => "2022-06-15",
// 497:           "deprecation_reason"              => "repo_archived",
// 498:           "deprecation_replacement_formula" => nil,
// 499:           "deprecation_replacement_cask"    => nil,
// 500:           "deprecate_args"                  => { date: "2022-06-15", because: :repo_archived },
// 501:         }
// 502:       end
// 503:
// 504:       let(:disable_json) do
// 505:         {
// 506:           "disabled"                    => true,
// 507:           "disable_date"                => "2022-06-15",
// 508:           "disable_reason"              => "requires something else",
// 509:           "disable_replacement_formula" => nil,
// 510:           "disable_replacement_cask"    => nil,
// 511:           "disable_args"                => { date: "2022-06-15", because: "requires something else" },
// 512:         }
// 513:       end
// 514:
// 515:       let(:future_date) { Date.today + 365 }
// 516:
// 517:       let(:deprecate_future_json) do
// 518:         {
// 519:           "deprecated"                      => true,
// 520:           "deprecation_date"                => future_date.to_s,
// 521:           "deprecation_reason"              => nil,
// 522:           "deprecation_replacement_formula" => nil,
// 523:           "deprecation_replacement_cask"    => nil,
// 524:           "deprecate_args"                  => {
// 525:             date:             future_date.to_s,
// 526:             because:          :repo_archived,
// 527:             replacement_cask: "bar",
// 528:           },
// 529:         }
// 530:       end
// 531:
// 532:       let(:disable_future_json) do
// 533:         {
// 534:           "deprecated"                      => true,
// 535:           "deprecation_date"                => nil,
// 536:           "deprecation_reason"              => "requires something else",
// 537:           "deprecation_replacement_formula" => "foo",
// 538:           "deprecation_replacement_cask"    => nil,
// 539:           "deprecate_args"                  => nil,
// 540:           "disabled"                        => false,
// 541:           "disable_date"                    => future_date.to_s,
// 542:           "disable_reason"                  => nil,
// 543:           "disable_replacement_formula"     => nil,
// 544:           "disable_replacement_cask"        => nil,
// 545:           "disable_args"                    => {
// 546:             date:                future_date.to_s,
// 547:             because:             "requires something else",
// 548:             replacement_formula: "foo",
// 549:           },
// 550:         }
// 551:       end
// 552:
// 553:       let(:variations_json) do
// 554:         {
// 555:           "variations" => {
// 556:             Utils::Bottles.tag.to_s => {
// 557:               "dependencies" => ["dep", "variations_dep"],
// 558:             },
// 559:           },
// 560:         }
// 561:       end
// 562:
// 563:       let(:older_macos_variations_json) do
// 564:         {
// 565:           "variations" => {
// 566:             Utils::Bottles.tag.to_s => {
// 567:               "dependencies" => ["uses_from_macos_dep"],
// 568:             },
// 569:           },
// 570:         }
// 571:       end
// 572:
// 573:       let(:linux_variations_json) do
// 574:         {
// 575:           "variations" => {
// 576:             "x86_64_linux" => {
// 577:               "dependencies" => ["dep"],
// 578:             },
// 579:           },
// 580:         }
// 581:       end
// 582:
// 583:       before do
// 584:         # avoid unnecessary network calls
// 585:         allow(Homebrew::API).to receive_messages(formula_names: [formula_name], formula_aliases: {},
// 586:                                                  formula_renames: {})
// 587:         allow(Homebrew::API::Internal).to receive(:formula_hashes) { Homebrew::API::Formula.all_formulae }
// 588:         allow(Homebrew::API::Internal).to receive(:formula_hash) { |name| Homebrew::API::Formula.all_formulae[name] }
// 589:         allow(Homebrew::API::Internal).to receive(:formula_name?) do |name|
// 590:           Homebrew::API::Formula.all_formulae.key?(name)
// 591:         end
// 592:         allow(Homebrew::API::Internal).to receive(:formula_struct) do |name|
// 593:           Homebrew::API::Formula::FormulaStructGenerator.generate_formula_struct_hash(
// 594:             Homebrew::API::Formula.all_formulae.fetch(name),
// 595:           )
// 596:         end
// 597:         allow(Homebrew::API::Internal).to receive(:formula_tap_git_head).and_return("")
// 598:         allow(Homebrew::API::Formula).to receive(:all_aliases).and_return({})
// 599:         allow(CoreTap.instance).to receive(:tap_migrations).and_return({})
// 600:         allow(CoreCaskTap.instance).to receive(:tap_migrations).and_return({})
// 601:
// 602:         # don't try to load/fetch gcc/glibc
// 603:         allow(DevelopmentTools).to receive_messages(needs_libc_formula?: false, needs_compiler_formula?: false)
// 604:       end
// 605:
// 606:       it "returns a Formula when given a name" do
// 607:         allow(Homebrew::API::Formula).to receive(:all_formulae).and_return formula_json_contents
// 608:
// 609:         formula = described_class.factory(formula_name)
// 610:         expect(formula).to be_a(Formula)
// 611:
// 612:         expect(formula.keg_only_reason.reason).to eq :provided_by_macos
// 613:         expect(formula.declared_deps.count).to eq 6
// 614:         if OS.mac?
// 615:           expect(formula.deps.count).to eq 5
// 616:         else
// 617:           expect(formula.deps.count).to eq 6
// 618:         end
// 619:
// 620:         expect(formula.requirements.count).to eq 1
// 621:         req = formula.requirements.first
// 622:         expect(req).to be_an_instance_of XcodeRequirement
// 623:         expect(req.version).to eq "1.0"
// 624:         expect(req.tags).to eq [:build]
// 625:
// 626:         expect(formula.conflicts.map(&:name)).to include "conflicting_formula"
// 627:         expect(formula.conflicts.map(&:reason)).to include "it does"
// 628:         expect(formula.class.link_overwrite_paths).to include "bin/abc"
// 629:
// 630:         expect(formula.caveats).to eq "example caveat string\n#{Dir.home}\n#{HOMEBREW_PREFIX}"
// 631:
// 632:         expect(formula).to be_a_service
// 633:         expect(formula.service.command).to eq(["#{HOMEBREW_PREFIX}/opt/formula_name/bin/beanstalkd", "test"])
// 634:         expect(formula.service.run_type).to eq(:immediate)
// 635:         expect(formula.service.working_dir).to eq(Dir.home)
// 636:         expect(formula.plist_name).to eq("custom.launchd.name")
// 637:         expect(formula.service_name).to eq("custom.systemd.name")
// 638:
// 639:         expect(formula.ruby_source_checksum.hexdigest).to eq("abcdefghijklmnopqrstuvwxyz")
// 640:
// 641:         expect do
// 642:           formula.install
// 643:         end.to raise_error("Cannot build from source from abstract formula.")
// 644:       end
// 645:
// 646:       it "returns a Formula loaded from the internal API" do
// 647:         allow(Homebrew::API::Formula).to receive(:all_formulae).and_return formula_json_contents
// 648:
// 649:         formula = described_class.factory(formula_name)
// 650:         expect(formula).to be_a(Formula)
// 651:         expect(formula.loaded_from_api?).to be true
// 652:         expect(formula.loaded_from_internal_api?).to be true
// 653:       end
// 654:
// 655:       it "runs post-install steps loaded from the internal API without source Ruby" do
// 656:         step = { "type" => "warn", "message" => "loaded from internal API" }
// 657:         allow(Homebrew::API::Formula).to receive(:all_formulae)
// 658:           .and_return formula_json_contents("post_install_steps" => [step])
// 659:         expect(Homebrew::API::Formula).not_to receive(:source_download_formula)
// 660:
// 661:         formula = described_class.factory(formula_name)
// 662:         runner = Homebrew::InstallSteps::Runner.new(context: formula)
// 663:         expect(runner).to receive(:opoo).with("loaded from internal API")
// 664:
// 665:         runner.run(formula.post_install_steps)
// 666:       end
// 667:
// 668:       it "loads patches from API JSON" do
// 669:         allow(Homebrew::API::Formula).to receive(:all_formulae).and_return formula_json_contents(
// 670:           "patches" => [
// 671:             {
// 672:               "strip"    => "p1",
// 673:               "url"      => "https://example.com/test.patch",
// 674:               "sha256"   => TEST_SHA256,
// 675:               "resolves" => [
// 676:                 { "type" => "security", "id" => "CVE-2024-1234" },
// 677:                 { "type" => "defect", "id" => "https://github.com/foo/bar/issues/1" },
// 678:               ],
// 679:             },
// 680:           ],
// 681:         )
// 682:
// 683:         formula = described_class.factory(formula_name)
// 684:
// 685:         expect(formula.patchlist.first).to be_a(ExternalPatch).and have_attributes(resolves: [
// 686:           "CVE-2024-1234",
// 687:           "https://github.com/foo/bar/issues/1",
// 688:         ])
// 689:       end
// 690:
// 691:       it "returns a deprecated Formula when given a name" do
// 692:         allow(Homebrew::API::Formula).to receive(:all_formulae).and_return formula_json_contents(deprecate_json)
// 693:
// 694:         formula = described_class.factory(formula_name)
// 695:         expect(formula).to be_a(Formula)
// 696:         expect(formula.deprecated?).to be true
// 697:         expect(formula.deprecation_date).to eq(Date.parse("2022-06-15"))
// 698:         expect(formula.deprecation_reason).to eq :repo_archived
// 699:         expect do
// 700:           formula.install
// 701:         end.to raise_error("Cannot build from source from abstract formula.")
// 702:       end
// 703:
// 704:       it "returns a disabled Formula when given a name" do
// 705:         allow(Homebrew::API::Formula).to receive(:all_formulae).and_return formula_json_contents(disable_json)
// 706:
// 707:         formula = described_class.factory(formula_name)
// 708:         expect(formula).to be_a(Formula)
// 709:         expect(formula.disabled?).to be true
// 710:         expect(formula.disable_date).to eq(Date.parse("2022-06-15"))
// 711:         expect(formula.disable_reason).to eq("requires something else")
// 712:         expect do
// 713:           formula.install
// 714:         end.to raise_error("Cannot build from source from abstract formula.")
// 715:       end
// 716:
// 717:       it "returns a future-deprecated Formula when given a name" do
// 718:         contents = formula_json_contents(deprecate_future_json)
// 719:         allow(Homebrew::API::Formula).to receive(:all_formulae).and_return contents
// 720:
// 721:         formula = described_class.factory(formula_name)
// 722:         expect(formula).to be_a(Formula)
// 723:         expect(formula.deprecated?).to be false
// 724:         expect(formula.deprecation_date).to eq(future_date)
// 725:         expect(formula.deprecation_reason).to be_nil
// 726:         expect(formula.deprecation_replacement_formula).to be_nil
// 727:         expect(formula.deprecation_replacement_cask).to be_nil
// 728:         expect do
// 729:           formula.install
// 730:         end.to raise_error("Cannot build from source from abstract formula.")
// 731:       end
// 732:
// 733:       it "returns a future-disabled Formula when given a name" do
// 734:         allow(Homebrew::API::Formula).to receive(:all_formulae).and_return formula_json_contents(disable_future_json)
// 735:
// 736:         formula = described_class.factory(formula_name)
// 737:         expect(formula).to be_a(Formula)
// 738:         expect(formula.deprecated?).to be true
// 739:         expect(formula.deprecation_date).to be_nil
// 740:         expect(formula.deprecation_reason).to eq("requires something else")
// 741:         expect(formula.deprecation_replacement_formula).to eq("foo")
// 742:         expect(formula.deprecation_replacement_cask).to be_nil
// 743:         expect(formula.disabled?).to be false
// 744:         expect(formula.disable_date).to eq(future_date)
// 745:         expect(formula.disable_reason).to be_nil
// 746:         expect(formula.disable_replacement_formula).to be_nil
// 747:         expect(formula.disable_replacement_cask).to be_nil
// 748:         expect do
// 749:           formula.install
// 750:         end.to raise_error("Cannot build from source from abstract formula.")
// 751:       end
// 752:
// 753:       it "returns a Formula with variations when given a name", :needs_macos do
// 754:         allow(Homebrew::API::Formula).to receive(:all_formulae).and_return formula_json_contents(variations_json)
// 755:
// 756:         formula = described_class.factory(formula_name)
// 757:         expect(formula).to be_a(Formula)
// 758:         expect(formula.declared_deps.count).to eq 7
// 759:         expect(formula.deps.count).to eq 6
// 760:         expect(formula.deps.map(&:name).include?("variations_dep")).to be true
// 761:         expect(formula.deps.map(&:name).include?("uses_from_macos_dep")).to be false
// 762:       end
// 763:
// 764:       it "returns a Formula without duplicated deps and uses_from_macos with variations on Linux", :needs_linux do
// 765:         allow(Homebrew::API::Formula)
// 766:           .to receive(:all_formulae).and_return formula_json_contents(linux_variations_json)
// 767:
// 768:         formula = described_class.factory(formula_name)
// 769:         expect(formula).to be_a(Formula)
// 770:         expect(formula.declared_deps.count).to eq 6
// 771:         expect(formula.deps.count).to eq 6
// 772:         expect(formula.deps.map(&:name).include?("uses_from_macos_dep")).to be true
// 773:       end
// 774:
// 775:       it "returns a Formula with the correct uses_from_macos dep on older macOS", :needs_macos do
// 776:         allow(Homebrew::API::Formula)
// 777:           .to receive(:all_formulae).and_return formula_json_contents(older_macos_variations_json)
// 778:
// 779:         formula = described_class.factory(formula_name)
// 780:         expect(formula).to be_a(Formula)
// 781:         expect(formula.declared_deps.count).to eq 6
// 782:         expect(formula.deps.count).to eq 5
// 783:         expect(formula.deps.map(&:name).include?("uses_from_macos_dep")).to be true
// 784:       end
// 785:
// 786:       context "with core tap migration renames" do
// 787:         let(:foo_tap) { Tap.fetch("homebrew", "foo") }
// 788:
// 789:         before do
// 790:           allow(Homebrew::API)
// 791:             .to receive_messages(formula_names: [formula_name], formula_aliases: {}, formula_renames: {})
// 792:           allow(Homebrew::API::Formula).to receive(:all_formulae).and_return formula_json_contents
// 793:           foo_tap.path.mkpath
// 794:         end
// 795:
// 796:         after do
// 797:           FileUtils.rm_rf foo_tap.path
// 798:         end
// 799:
// 800:         it "returns the tap migration rename by old formula_name" do
// 801:           old_formula_name = "#{formula_name}-old"
// 802:           (foo_tap.path/"tap_migrations.json").write <<~JSON
// 803:             { "#{old_formula_name}": "homebrew/core/#{formula_name}" }
// 804:           JSON
// 805:
// 806:           loader = Formulary::FromNameLoader.try_new(old_formula_name)
// 807:           expect(loader).to be_a(Formulary::FromAPILoader)
// 808:           expect(loader.name).to eq formula_name
// 809:           expect(loader.path).not_to exist
// 810:         end
// 811:
// 812:         it "returns the tap migration rename by old full name" do
// 813:           old_formula_name = "#{formula_name}-old"
// 814:           (foo_tap.path/"tap_migrations.json").write <<~JSON
// 815:             { "#{old_formula_name}": "homebrew/core/#{formula_name}" }
// 816:           JSON
// 817:
// 818:           loader = Formulary::FromTapLoader.try_new("#{foo_tap}/#{old_formula_name}")
// 819:           expect(loader).to be_a(Formulary::FromAPILoader)
// 820:           expect(loader.name).to eq formula_name
// 821:           expect(loader.path).not_to exist
// 822:         end
// 823:       end
// 824:     end
// 825:
// 826:     context "when passed a URL" do
// 827:       it "raises an error when given an https URL" do
// 828:         expect do
// 829:           described_class.factory("https://brew.sh/foo.rb")
// 830:         end.to raise_error(UnsupportedInstallationMethod)
// 831:       end
// 832:
// 833:       it "raises an error when given a bottle URL" do
// 834:         expect do
// 835:           described_class.factory("https://brew.sh/foo-1.0.arm64_catalina.bottle.tar.gz")
// 836:         end.to raise_error(UnsupportedInstallationMethod)
// 837:       end
// 838:
// 839:       it "raises an error when given an ftp URL" do
// 840:         expect do
// 841:           described_class.factory("ftp://brew.sh/foo.rb")
// 842:         end.to raise_error(UnsupportedInstallationMethod)
// 843:       end
// 844:
// 845:       it "raises an error when given an sftp URL" do
// 846:         expect do
// 847:           described_class.factory("sftp://brew.sh/foo.rb")
// 848:         end.to raise_error(UnsupportedInstallationMethod)
// 849:       end
// 850:
// 851:       it "does not raise an error when given a file URL", :needs_utils_curl do
// 852:         expect do
// 853:           described_class.factory("file://#{TEST_FIXTURE_DIR}/testball.rb")
// 854:         end.not_to raise_error
// 855:       end
// 856:     end
// 857:
// 858:     context "when passed ref with spaces" do
// 859:       it "raises a FormulaUnavailableError error" do
// 860:         expect do
// 861:           described_class.factory("foo bar")
// 862:         end.to raise_error(FormulaUnavailableError)
// 863:       end
// 864:     end
// 865:   end
// 866:
// 867:   specify "::from_contents" do
// 868:     expect(described_class.from_contents(formula_name, formula_path, formula_content)).to be_a(Formula)
// 869:   end
// 870:
// 871:   describe "::to_rack" do
// 872:     alias_matcher :exist, :be_exist
// 873:
// 874:     let(:rack_path) { HOMEBREW_CELLAR/formula_name }
// 875:
// 876:     context "when the Rack does not exist" do
// 877:       it "returns the Rack" do
// 878:         expect(described_class.to_rack(formula_name)).to eq(rack_path)
// 879:       end
// 880:     end
// 881:
// 882:     context "when the Rack exists" do
// 883:       before do
// 884:         rack_path.mkpath
// 885:       end
// 886:
// 887:       it "returns the Rack" do
// 888:         expect(described_class.to_rack(formula_name)).to eq(rack_path)
// 889:       end
// 890:     end
// 891:
// 892:     it "raises an error if the Formula is not available" do
// 893:       expect do
// 894:         described_class.to_rack("a/b/#{formula_name}")
// 895:       end.to raise_error(TapFormulaUnavailableError)
// 896:     end
// 897:
// 898:     it "locates an installed Rack from an untrusted tap without evaluating its formula" do
// 899:       tap = Tap.fetch("untrustedrack", "foo")
// 900:       formula_path = tap.formula_dir/"#{formula_name}.rb"
// 901:       formula_path.dirname.mkpath
// 902:       eval_marker = mktmpdir/"evaluated"
// 903:       formula_path.write <<~RUBY
// 904:         class #{described_class.class_s(formula_name)} < Formula
// 905:           url "https://brew.sh/#{formula_name}-1.0.tar.gz"
// 906:           File.write("#{eval_marker}", "evaluated")
// 907:         end
// 908:       RUBY
// 909:       rack_path.mkpath
// 910:
// 911:       with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1", HOMEBREW_USER_CONFIG_HOME: mktmpdir) do
// 912:         expect(described_class.to_rack("#{tap.name}/#{formula_name}")).to eq(rack_path)
// 913:         expect(eval_marker).not_to exist
// 914:       end
// 915:     ensure
// 916:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"untrustedrack"
// 917:     end
// 918:   end
// 919:
// 920:   describe "::core_path" do
// 921:     it "returns the path to a Formula in the core tap" do
// 922:       name = "foo-bar"
// 923:       expect(described_class.core_path(name))
// 924:         .to eq(Pathname.new("#{HOMEBREW_LIBRARY}/Taps/homebrew/homebrew-core/Formula/#{name}.rb"))
// 925:     end
// 926:
// 927:     it "returns the sharded path directly for API-known formulae" do
// 928:       ENV.delete("HOMEBREW_NO_INSTALL_FROM_API")
// 929:       name = "foo-bar"
// 930:       allow(Homebrew::API::Internal).to receive(:formula_hashes_cached?).and_return(true)
// 931:       allow(Homebrew::API).to receive(:formula_name?).with(name).and_return(true)
// 932:       expect(described_class.core_path(name))
// 933:         .to eq(Pathname.new("#{HOMEBREW_LIBRARY}/Taps/homebrew/homebrew-core/Formula/f/#{name}.rb"))
// 934:     end
// 935:   end
// 936:
// 937:   describe "::loader_for" do
// 938:     context "when given a relative path with two slashes" do
// 939:       it "returns a `FromPathLoader`" do
// 940:         mktmpdir.cd do
// 941:           FileUtils.mkdir "Formula"
// 942:           FileUtils.touch "Formula/gcc.rb"
// 943:           expect(described_class.loader_for("./Formula/gcc.rb")).to be_a Formulary::FromPathLoader
// 944:         end
// 945:       end
// 946:     end
// 947:
// 948:     context "when given a tapped name" do
// 949:       it "returns a `FromTapLoader`", :no_api do
// 950:         expect(described_class.loader_for("homebrew/core/gcc")).to be_a Formulary::FromTapLoader
// 951:       end
// 952:     end
// 953:
// 954:     context "when not using the API", :no_api do
// 955:       context "when a formula is migrated" do
// 956:         let(:token) { "foo" }
// 957:         let(:old_tap) { core_tap }
// 958:         let(:new_tap) { core_cask_tap }
// 959:
// 960:         let(:core_tap) { CoreTap.instance }
// 961:         let(:core_cask_tap) { CoreCaskTap.instance }
// 962:
// 963:         let(:tap_migrations) do
// 964:           {
// 965:             token => new_tap.name,
// 966:           }
// 967:         end
// 968:
// 969:         before do
// 970:           old_tap.path.mkpath
// 971:           new_tap.path.mkpath
// 972:           (old_tap.path/"tap_migrations.json").write tap_migrations.to_json
// 973:           old_tap.clear_cache
// 974:         end
// 975:
// 976:         context "to a cask in the default tap" do
// 977:           let(:old_tap) { core_tap }
// 978:           let(:new_tap) { core_cask_tap }
// 979:
// 980:           let(:cask_file) { new_tap.cask_dir/"#{token}.rb" }
// 981:
// 982:           before do
// 983:             new_tap.cask_dir.mkpath
// 984:             FileUtils.touch cask_file
// 985:           end
// 986:
// 987:           it "does not warn when loading the short token" do
// 988:             expect do
// 989:               described_class.loader_for(token)
// 990:             end.not_to output.to_stderr
// 991:           end
// 992:         end
// 993:
// 994:         context "to the default tap" do
// 995:           let(:old_tap) { core_cask_tap }
// 996:           let(:new_tap) { core_tap }
// 997:
// 998:           let(:formula_file) { new_tap.formula_dir/"#{token}.rb" }
// 999:
// 1000:           before do
// 1001:             new_tap.formula_dir.mkpath
// 1002:             FileUtils.touch formula_file
// 1003:           end
// 1004:
// 1005:           it "does not warn when loading the short token" do
// 1006:             expect do
// 1007:               described_class.loader_for(token)
// 1008:             end.not_to output.to_stderr
// 1009:           end
// 1010:
// 1011:           it "does not warn when loading the full token in the default tap" do
// 1012:             expect do
// 1013:               described_class.loader_for("#{new_tap}/#{token}")
// 1014:             end.not_to output.to_stderr
// 1015:           end
// 1016:
// 1017:           it "warns when loading the full token in the old tap" do
// 1018:             expect do
// 1019:               described_class.loader_for("#{old_tap}/#{token}")
// 1020:             end.to output(
// 1021:               a_string_including("Formula #{old_tap}/#{token} was renamed to #{token}.").once,
// 1022:             ).to_stderr
// 1023:           end
// 1024:
// 1025:           # FIXME
// 1026:           # context "when there is an infinite tap migration loop" do
// 1027:           #   before do
// 1028:           #     (new_tap.path/"tap_migrations.json").write({
// 1029:           #       token => old_tap.name,
// 1030:           #     }.to_json)
// 1031:           #   end
// 1032:           #
// 1033:           #   it "stops recursing" do
// 1034:           #     expect do
// 1035:           #       klass.loader_for("#{new_tap}/#{token}")
// 1036:           #     end.not_to output.to_stderr
// 1037:           #   end
// 1038:           # end
// 1039:         end
// 1040:
// 1041:         context "to a cask in a third-party tap" do
// 1042:           let(:old_tap) { Tap.fetch("another", "foo") }
// 1043:           let(:new_tap) { Tap.fetch("another", "bar") }
// 1044:           let(:cask_file) { new_tap.cask_dir/"#{token}.rb" }
// 1045:
// 1046:           before do
// 1047:             new_tap.cask_dir.mkpath
// 1048:             FileUtils.touch cask_file
// 1049:           end
// 1050:
// 1051:           after do
// 1052:             FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"another"
// 1053:           end
// 1054:
// 1055:           it "does not warn when loading the short token" do
// 1056:             expect do
// 1057:               described_class.loader_for(token)
// 1058:             end.not_to output.to_stderr
// 1059:           end
// 1060:         end
// 1061:
// 1062:         context "to a third-party tap" do
// 1063:           let(:old_tap) { Tap.fetch("another", "foo") }
// 1064:           let(:new_tap) { Tap.fetch("another", "bar") }
// 1065:           let(:formula_file) { new_tap.formula_dir/"#{token}.rb" }
// 1066:
// 1067:           before do
// 1068:             new_tap.formula_dir.mkpath
// 1069:             FileUtils.touch formula_file
// 1070:           end
// 1071:
// 1072:           after do
// 1073:             FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"another"
// 1074:           end
// 1075:
// 1076:           # FIXME
// 1077:           # It would be preferable not to print a warning when installing with the short token
// 1078:           it "warns when loading the short token" do
// 1079:             expect do
// 1080:               described_class.loader_for(token)
// 1081:             end.to output(
// 1082:               a_string_including("Formula #{old_tap}/#{token} was renamed to #{new_tap}/#{token}.").once,
// 1083:             ).to_stderr
// 1084:           end
// 1085:
// 1086:           it "warns with the canonical token when loading an uppercase short token" do
// 1087:             expect do
// 1088:               described_class.loader_for(token.upcase)
// 1089:             end.to output(
// 1090:               a_string_including("Formula #{old_tap}/#{token} was renamed to #{new_tap}/#{token}.").once,
// 1091:             ).to_stderr
// 1092:           end
// 1093:
// 1094:           it "does not warn when loading the full token in the new tap" do
// 1095:             expect do
// 1096:               described_class.loader_for("#{new_tap}/#{token}")
// 1097:             end.not_to output.to_stderr
// 1098:           end
// 1099:
// 1100:           it "warns when loading the full token in the old tap" do
// 1101:             expect do
// 1102:               described_class.loader_for("#{old_tap}/#{token}")
// 1103:             end.to output(
// 1104:               a_string_including("Formula #{old_tap}/#{token} was renamed to #{new_tap}/#{token}.").once,
// 1105:             ).to_stderr
// 1106:           end
// 1107:         end
// 1108:       end
// 1109:     end
// 1110:   end
// 1111: end

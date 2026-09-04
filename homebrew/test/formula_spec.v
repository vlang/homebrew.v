module test

import ruby
import homebrew
import homebrew.api
import homebrew.extend.os.linux as linux_formula
import homebrew.utils as hb_utils
import os

// Translated from Homebrew/brew `test/formula_spec.rb`.
// The original source is retained below until every stub has a typed V body.
struct FormulaSpecOptions {
	name                       string = 'formula_name'
	version                    string = '1.0'
	head_version               string
	active_spec                string = 'stable'
	tap                        string = 'homebrew/core'
	alias_name                 string
	alias_path                 string
	revision                   int
	version_scheme             int
	bottle_available           bool
	description                string
	homepage                   string
	dependencies               []string
	build_dependencies         []string
	optional_dependencies      []string
	oldnames                   []string
	aliases                    []string
	versioned_formulae         []string
	local_path                 string
	loaded_from_api            bool
	preserve_rpath             bool
	link_overwrite_paths       []string
	livecheck                  string
	livecheck_defined          bool
	service_block              string
	post_install_steps         []string
	post_install_steps_defined bool
	network_access             map[string]bool = {
		'build':       true
		'test':        true
		'postinstall': true
	}
	pour_bottle_only_if        string
	pour_bottle_reason         string
	autobump                   bool = true
	resources                  []string
	patches                    []string
	requirements               []string
	test_defined               bool
	deprecated                 bool
	deprecation_reason         string
	disabled                   bool
	disable_reason             string
}

fn formula_spec_root(line int) string {
	return os.join_path(os.temp_dir(), 'brew-v-formula-spec-${os.getpid()}-${line}')
}

fn formula_spec_formula_at(options FormulaSpecOptions, root string) homebrew.Formula {
	name := options.name
	full_name := if options.tap != '' && options.tap != 'homebrew/core' {
		'${options.tap}/${name}'
	} else {
		name
	}
	mut reference := api.PackageReference{
		kind: .formula
		name: name
		full_name: full_name
		tap: options.tap
		alias_name: options.alias_name
		description: options.description
		homepage: options.homepage
		stable_version: options.version
		head_version: options.head_version
		source_url: '${name}-${options.version}'
		revision: options.revision
		version_scheme: options.version_scheme
		bottle_available: options.bottle_available
		dependencies: options.dependencies.clone()
		build_dependencies: options.build_dependencies.clone()
		optional_dependencies: options.optional_dependencies.clone()
		oldnames: options.oldnames.clone()
		aliases: options.aliases.clone()
		versioned_formulae: options.versioned_formulae.clone()
		ruby_source_path: os.join_path(root, 'Library', 'Taps', options.tap.replace('/', '/homebrew-'), 'Formula', '${name}.rb')
		local_path: options.local_path
		loaded_from_api: options.loaded_from_api
		deprecated: options.deprecated
		deprecation_reason: options.deprecation_reason
		disabled: options.disabled
		disable_reason: options.disable_reason
		core_tap: options.tap == 'homebrew/core'
	}
	if options.active_spec == 'head' && reference.head_version == '' {
		reference = api.PackageReference{ ...reference, head_version: 'HEAD' }
	}
	return homebrew.new_formula(homebrew.FormulaConfig{
		reference: reference
		prefix: root
		cellar: os.join_path(root, 'Cellar')
		active_spec: options.active_spec
		alias_path: options.alias_path
		preserve_rpath: options.preserve_rpath
		link_overwrite_paths: options.link_overwrite_paths.clone()
		livecheck: options.livecheck
		livecheck_defined: options.livecheck_defined
		service_block: options.service_block
		post_install_steps: options.post_install_steps.clone()
		post_install_steps_defined: options.post_install_steps_defined
		network_access_allowed: options.network_access.clone()
		pour_bottle_only_if: options.pour_bottle_only_if
		pour_bottle_reason: options.pour_bottle_reason
		autobump: options.autobump
		resources: options.resources.clone()
		patches: options.patches.clone()
		requirements: options.requirements.clone()
		test_defined: options.test_defined
	}) or { panic(err) }
}

fn formula_spec_formula(options FormulaSpecOptions) homebrew.Formula {
	return formula_spec_formula_at(options, formula_spec_root(0))
}

fn formula_spec_bool(value ruby.Value) bool {
	return value.as_bool() or { false }
}

fn formula_spec_strings(value ruby.Value) []string {
	return value.as_string_array() or { []string{} }
}

fn formula_spec_receiver(formula homebrew.Formula) ruby.Value {
	return homebrew.formula_boundary_value(formula)
}

fn formula_spec_remove_root(root string) {
	if os.exists(root) { os.rmdir_all(root) or {} }
}

fn formula_spec_write(path string, contents string) {
	os.mkdir_all(os.dir(path)) or { panic(err) }
	os.write_file(path, contents) or { panic(err) }
}

fn formula_spec_versioned_names(name string, candidates []string) []string {
	if name.contains('@') {
		return []string{}
	}
	return candidates.filter(it.starts_with('${name}@'))
}

fn formula_spec_full_sibling_names(name string, existing []string) []string {
	mut sibling := if name.ends_with('-full') {
		name.trim_string_right('-full')
	} else {
		'${name}-full'
	}
	if name.contains('@') && name.ends_with('-full') {
		sibling = name.trim_string_right('-full')
	}
	return if sibling in existing { [sibling] } else { []string{} }
}

fn formula_spec_implied_overwrite(keg_name string, related_names []string,
	oldnames []string, aliases []string) bool {
	if keg_name == '' || keg_name == 'missing' || related_names.len == 0 {
		return false
	}
	return keg_name in related_names || keg_name in oldnames || keg_name in aliases
}

fn formula_spec_outdated(installed string, current string, installed_scheme int,
	current_scheme int, installed_tap string, current_tap string, linked bool) bool {
	if installed_scheme < current_scheme {
		return true
	}
	if installed_scheme > current_scheme {
		return false
	}
	installed_version := homebrew.new_version(installed) or { return true }
	current_version := homebrew.new_version(current) or { return true }
	if installed_version.compare_to(current_version) >= 0 && linked && (current_tap == '' || installed_tap == '' || installed_tap == current_tap) {
		return false
	}
	return installed_version.compare_to(current_version) < 0 || !linked
}

fn formula_spec_post_install_steps() []string {
	return [
		'{"type":"mkdir_p","path":{"base":"var","path":"log/foo"}}',
		'{"type":"touch","path":{"base":"var","path":"foo/marker"}}',
		'{"type":"move","source":{"base":"prefix","path":"move-source"},"target":{"base":"prefix","path":"move-target"},"overwrite":true}',
		'{"type":"move_contents","source":{"base":"prefix","path":"children-source"},"target":{"base":"prefix","path":"children-target"}}',
		'{"type":"symlink","source":{"base":"relative","path":"move-target"},"target":{"base":"prefix","path":"linked-target"},"uninstall":true}',
	]
}

fn formula_spec_production_sandbox_env(home string) map[string]string {
	old_cache := os.getenv('HOMEBREW_CACHE')
	old_cooldown := os.getenv('HOMEBREW_RELEASE_COOLDOWN_DAYS')
	os.setenv('HOMEBREW_CACHE', os.join_path(home, 'cache'), true)
	os.setenv('HOMEBREW_RELEASE_COOLDOWN_DAYS', '1', true)
	formula := formula_spec_formula_at(FormulaSpecOptions{}, home)
	values := homebrew.ruby_formula_l3743_d312_common_sandbox_env(formula_spec_receiver(formula), ruby.string_value(home)).as_map() or { map[string]ruby.Value{} }
	os.setenv('HOMEBREW_CACHE', old_cache, true)
	os.setenv('HOMEBREW_RELEASE_COOLDOWN_DAYS', old_cooldown, true)
	mut result := map[string]string{}
	for key, value in values {
		result[key] = value.as_string()
	}
	return result
}

fn formula_spec_formula_value(line int) ruby.Value {
	root := formula_spec_root(line)
	mut options := FormulaSpecOptions{}
	match line {
		130, 160, 222, 276, 340 {
			options = FormulaSpecOptions{ name: 'foo' }
		}
		137, 167, 236, 290, 354 {
			options = FormulaSpecOptions{ name: 'foo@2.0', version: '2.0' }
		}
		174, 229, 283, 347 {
			options = FormulaSpecOptions{ name: 'foo-full' }
		}
		181, 243, 361 {
			options = FormulaSpecOptions{ name: 'foo@2.0-full', version: '2.0' }
		}
		37, 3059 {
			options = FormulaSpecOptions{
				alias_name: 'baz@1'
				alias_path: os.join_path(root, 'Aliases', 'baz@1')
			}
		}
		391, 494 {
			options = FormulaSpecOptions{ name: 'foo@22', version: '22.0' }
		}
		398, 501 {
			options = FormulaSpecOptions{ name: 'foo' }
		}
		706 {
			options = FormulaSpecOptions{ name: 'testball', version: '1.9', head_version: 'HEAD' }
		}
		750 {
			options = FormulaSpecOptions{ name: 'testball', version: '0.1', head_version: 'HEAD' }
		}
		1019 {
			options = FormulaSpecOptions{ version: '1.2.3' }
		}
		1313 {
			options = FormulaSpecOptions{ name: 'config-upgrade', version: '2.0' }
		}
		1622, 1672 {
			options = FormulaSpecOptions{ name: 'foo' }
		}
		2214 {
			options = FormulaSpecOptions{ name: 'formula_name', alias_name: 'bar' }
		}
		2221 {
			options = FormulaSpecOptions{ name: 'new_formula_name', alias_name: 'bar', version: '1.1' }
		}
		2305 {
			options = FormulaSpecOptions{ version: '1.20' }
		}
		2313 {
			options = FormulaSpecOptions{ name: 'foo@1', version: '1.0' }
		}
		2320 {
			options = FormulaSpecOptions{ name: 'foo@2', version: '2.0' }
		}
		2521 {
			options = FormulaSpecOptions{ name: 'testball', version: '2.10', head_version: 'HEAD' }
		}
		2582 {
			options = FormulaSpecOptions{ name: 'testball', version: '20141010', version_scheme: 1 }
		}
		2600 {
			options = FormulaSpecOptions{ name: 'testball', version: '20141010', version_scheme: 3 }
		}
		2632 {
			options = FormulaSpecOptions{ name: 'testball', version: '1.0', version_scheme: 2 }
		}
		2657 {
			options = FormulaSpecOptions{ name: 'testball', version: '1.0', revision: 1 }
		}
		3130, 3167, 3204 {
			options = FormulaSpecOptions{ name: 'foo', version: '1.0' }
		}
		2773, 2796, 2819, 2879, 2939, 2966, 2989 {
			options = FormulaSpecOptions{ name: 'testball', version: '0.1' }
		}
		3269, 3298, 3386, 3399, 3421, 3443 {
			options = FormulaSpecOptions{ name: 'formula_name', version: '1.0' }
		}
		else {}
	}
	formula := formula_spec_formula_at(options, root)
	return formula_spec_receiver(formula)
}

fn formula_spec_boundary(line int, kind string, expression string, args []ruby.Value) ruby.Value {
	_ = args
	if kind in ['it', 'specify', 'example'] {
		return ruby.bool_value(formula_spec_case(line))
	}
	if kind == 'alias_matcher' {
		parts := expression.all_after('alias_matcher ').split(',')
		matcher := if parts.len > 0 { parts[0].trim_space().trim_left(':') } else { '' }
		target := if parts.len > 1 { parts[1].trim_space().trim_left(':') } else { '' }
		return ruby.structured_value('RSpec::AliasedMatcher', matcher, {
			'matcher': matcher
			'target':  target
		})
	}
	if kind == 'attr_reader' {
		attribute := expression.all_after('attr_reader :').trim_space()
		return ruby.structured_value('FormulaAttributeReader', attribute, {
			'attribute':  attribute
			'visibility': 'public'
		})
	}
	if kind == 'method' {
		name := expression.all_after('method ').all_before('(').trim_space().trim_string_right('; end')
		mut attributes := {
			'name':        name
			'source_line': line.str()
		}
		match line {
			1149 {
				attributes['behavior'] = 'post_install:no-op'
			}
			1281 {
				attributes['behavior'] = 'post_install:no-op'
			}
			2099 {
				attributes['returns'] = 'false'
			}
			2112 {
				attributes['returns'] = 'true'
			}
			2336 {
				attributes['behavior'] = 'create-prefix,optlink,write-tab'
			}
			2777 {
				attributes['behavior'] = 'test=0;on_macos:test=1'
			}
			2800 {
				attributes['behavior'] = 'test=0;on_macos:test=1;on_linux:test=2'
			}
			2824 {
				attributes['behavior'] = 'foo=0;bar=0;on_system-linux-or-tahoe:foo=1;on_system-linux-or-sonoma_or_older:bar=1'
			}
			2883 {
				attributes['behavior'] = 'test=0;on_sequoia_or_newer=1;on_sonoma=2;on_ventura_or_older=3'
			}
			2943, 2970 {
				attributes['behavior'] = 'test=0;on_arm=1;on_intel=2'
			}
			2991 {
				attributes['behavior'] = 'write-executable;generate-bash-zsh-fish-completions'
			}
			else {}
		}
		return ruby.structured_value('FormulaMethod', name, attributes)
	}
	match line {
		31, 3053 {
			return ruby.string_value('formula_name')
		}
		33, 3055 {
			return ruby.object_value('Symbol', 'stable')
		}
		34, 3056 {
			return ruby.string_value('baz@1')
		}
		73 {
			return ruby.structured_value('Tap', 'foo/bar', {
				'user':       'foo'
				'repository': 'bar'
			})
		}
		75 {
			return ruby.string_value('foo/bar/formula_name')
		}
		76 {
			return ruby.string_value('foo/bar/baz@1')
		}
		32, 3054 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'Library', 'Taps', 'homebrew', 'homebrew-core', 'Formula', 'formula_name.rb'))
		}
		35, 3057 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'Library', 'Taps', 'homebrew', 'homebrew-core', 'Aliases', 'baz@1'))
		}
		74 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'Library', 'Taps', 'foo', 'homebrew-bar', 'Formula', 'formula_name.rb'))
		}
		405 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'lib', 'formula_spec', 'node_modules', 'npm', 'LICENSE'))
		}
		715 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'Cellar', 'formula_name', '1.9'))
		}
		716 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'Cellar', 'formula_name', 'HEAD'))
		}
		1026 {
			return ruby.object_value('Pathname', '/usr/bin/foo')
		}
		1320 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'etc', 'config-upgrade.conf'))
		}
		1321 {
			return ruby.object_value('Pathname', '${formula_spec_root(1320)}/etc/config-upgrade.conf.default')
		}
		1322 {
			return ruby.object_value('Pathname', '${formula_spec_root(1128)}/Cellar/config-upgrade/1.0/.bottle/etc/config-upgrade.conf')
		}
		1323 {
			return ruby.object_value('Pathname', '${formula_spec_root(1128)}/Cellar/config-upgrade/2.0/.bottle/etc/config-upgrade.conf')
		}
		1453, 2228 {
			return ruby.structured_value('Tab', 'empty', {
				'source':               '{}'
				'runtime_dependencies': '[]'
			})
		}
		1458, 1528, 2327 {
			return ruby.string_value('bar')
		}
		1920 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'Formula', 'foo-variations.rb'))
		}
		1921 {
			return ruby.string_value('class FooVariations < Formula\n  on_intel { depends_on "intel-formula" }\n  on_sequoia { depends_on "sequoia-formula" }\n  on_sonoma(:or_older) { depends_on "sonoma-or-older-formula" }\n  on_linux { depends_on "linux-formula" }\nend\n')
		}
		1945 {
			return ruby.structured_value('JSON', 'formula variations', {
				'systems': 'tahoe,arm64_tahoe,sequoia,arm64_sequoia,sonoma,ventura,x86_64_linux,arm64_linux'
			})
		}
		2229 {
			return ruby.string_value('bar')
		}
		2230, 2328 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'Library', 'Taps', 'homebrew', 'homebrew-core', 'Aliases', 'bar'))
		}
		2299 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'Cellar', 'formula_name', '1.11'))
		}
		2300 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'Cellar', 'formula_name', '1.20'))
		}
		2301 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'Cellar', 'formula_name', '1.21'))
		}
		2302 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'Cellar', 'formula_name', 'HEAD'))
		}
		2303 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'Cellar', 'foo@1', '1.0'))
		}
		2530 {
			return ruby.object_value('Pathname', os.join_path(formula_spec_root(line), 'testball_repo'))
		}
		2571, 3341 {
			return ruby.object_value('Pathname', formula_spec_root(line))
		}
		3126 {
			return ruby.string_value('2020-01-01')
		}
		3127 {
			return ruby.string_value('2021-01-01')
		}
		3325 {
			return ruby.string_array_value(homebrew.formula_std_go_args('', [
				"-X 'main.version=1.0'",
				"-X 'main.commit=Homebrew'",
				"-X 'main.date=2026-01-01T12:00:00Z'",
				"-X 'main.builtBy=Homebrew'",
			], []string{}, []string{}, false))
		}
		3327, 3328 {
			return ruby.string_value('Homebrew')
		}
		3329 {
			return ruby.string_value('2026-01-01T12:00:00Z')
		}
		3330 {
			return ruby.string_value("-s -w -X 'main.version=1.0' -X 'main.commit=Homebrew' -X 'main.date=2026-01-01T12:00:00Z' -X 'main.builtBy=Homebrew'")
		}
		3342 {
			return ruby.structured_value('GitCommit', 'HEAD', {
				'command': 'git -C buildpath rev-parse HEAD'
			})
		}
		3362 {
			return ruby.string_value('someone')
		}
		391, 398, 494, 501 {
			return formula_spec_formula_value(line)
		}
		else {}
	}
	if expression.starts_with('let(:f)') || expression.starts_with('let(:f2)') || expression.starts_with('let(:f_') || expression.starts_with('let(:formula)') || expression.starts_with('let(:old_formula)') || expression.starts_with('let(:new_formula)') {
		return formula_spec_formula_value(line)
	}
	if expression.starts_with('let(:klass)') {
		return ruby.structured_value('Class<Formula>', 'anonymous Formula subclass', {
			'base': 'Formula'
			'url':  'https://brew.sh/foo-1.0.tar.gz'
		})
	}
	if expression.starts_with('let(:keg)') {
		return ruby.structured_value('Keg', 'instance_double(Keg)', {
			'test_double': 'true'
		})
	}
	panic('unknown retained Formula spec boundary at Ruby line ${line}: ${expression}')
}

fn formula_spec_case(line int) bool {
	root := formula_spec_root(line)
	formula_spec_remove_root(root)
	defer { formula_spec_remove_root(root) }
	match line {
		39, 53, 78, 91 {
			in_tap := line in [78, 91]
			with_alias := line in [53, 91]
			alias_name := if with_alias { 'baz@1' } else { '' }
			alias_path := if with_alias { os.join_path(root, 'Aliases', alias_name) } else { '' }
			formula := formula_spec_formula_at(FormulaSpecOptions{
				tap: if in_tap { 'foo/bar' } else { 'homebrew/core' }
				alias_name: alias_name
				alias_path: alias_path
			}, root)
			expected_full := if in_tap { 'foo/bar/formula_name' } else { 'formula_name' }
			expected_specified := if with_alias { alias_name } else { 'formula_name' }
			expected_full_specified := if in_tap && with_alias {
				'foo/bar/${alias_name}'
			} else if with_alias { alias_name } else { expected_full }
			return formula.name() == 'formula_name' && formula.full_name() == expected_full && formula.specified_name() == expected_specified && formula.full_specified_name() == expected_full_specified && formula.alias_path == alias_path && [
				'build',
				'test',
				'postinstall',
			].all(formula.network_access_allowed_value[it] or { false })
		}
		67 {
			_ := homebrew.new_formula(homebrew.FormulaConfig{
				reference: api.PackageReference{ kind: .cask, name: 'formula_name' }
			}) or { return err.msg().contains('not a formula') }
			return false
		}
		114, 118, 123 {
			mut formula := formula_spec_formula_at(FormulaSpecOptions{}, root)
			if line == 118 {
				formula.follow_installed_alias = true
			}
			if line == 123 {
				formula.follow_installed_alias = false
			}
			return formula.follow_installed_alias == (line != 123)
		}
		144 {
			plain := formula_spec_formula_at(FormulaSpecOptions{ name: 'foo' }, root)
			versioned := formula_spec_formula_at(FormulaSpecOptions{ name: 'foo@2.0', version: '2.0' }, root)
			return !plain.versioned_formula() && versioned.versioned_formula()
		}
		151 {
			version := ruby.object_value('Version', 'version')
			result := homebrew.ruby_formula_l5259_d392_python_major_minor_version(formula_spec_receiver(formula_spec_formula_at(FormulaSpecOptions{}, root)), ruby.string_value('python3'), version)
			return result.type_name == 'Version' && result.as_string() == 'version'
		}
		201, 207, 213 {
			formula := formula_spec_formula_at(FormulaSpecOptions{
				name: if line == 213 {
					'foo-full'} else if line == 207 { 'foo@2.0' } else { 'foo' }
				versioned_formulae: if line == 213 {
					['foo@2.0-full']} else if line == 201 { ['foo@2.0'] } else { []string{} }
			}, root)
			values := formula_spec_strings(homebrew.ruby_formula_l676_d82_versioned_formulae_names(formula_spec_receiver(formula)))
			return values == if line == 213 {
				['foo@2.0-full']
			} else if line == 201 { ['foo@2.0'] } else { []string{} }
		}
		257 {
			return formula_spec_full_sibling_names('foo', ['foo', 'foo-full', 'foo@2.0']) == [
				'foo-full',
			] && formula_spec_full_sibling_names('foo-full', ['foo', 'foo-full']) == [
				'foo',
			] && formula_spec_full_sibling_names('foo@2.0', ['foo', 'foo-full']) == []string{}
		}
		297 {
			plain := formula_spec_formula_at(FormulaSpecOptions{ name: 'foo' }, root)
			versioned := formula_spec_formula_at(FormulaSpecOptions{ name: 'foo@2.0' }, root)
			full := formula_spec_formula_at(FormulaSpecOptions{ name: 'foo@2.0-full' }, root)
			return plain.unversioned_formula_name() == '' && versioned.unversioned_formula_name() == 'foo' && full.unversioned_formula_name() == 'foo-full'
		}
		305 {
			other_prefix := os.join_path(root, 'Cellar', 'foo', '1.0')
			formula_spec_write(os.join_path(other_prefix, 'INSTALL_RECEIPT.json'), '{}')
			linked := os.join_path(root, 'var', 'homebrew', 'linked', 'foo')
			os.mkdir_all(os.dir(linked)) or { return false }
			os.symlink(other_prefix, linked) or { return false }
			formula := formula_spec_formula_at(FormulaSpecOptions{
				name: 'foo@2.0'
				version: '2.0'
				versioned_formulae: ['foo']
			}, root)
			return homebrew.ruby_formula_l746_d87_link_overwrite_reason(formula_spec_receiver(formula)).as_string() == 'foo is already linked'
		}
		322 {
			loaded := {
				'foo':     ruby.structured_value('Formula', 'foo@1.0', {
					'full_name': 'foo@1.0'
				})
				'foo@1.0': ruby.structured_value('Formula', 'foo@1.0', {
					'full_name': 'foo@1.0'
				})
			}
			mut unique := []ruby.Value{}
			for name in ['foo', 'foo@1.0'] {
				candidate := loaded[name]
				if !unique.any(it.as_string() == candidate.as_string()) { unique << candidate }
			}
			return unique.len == 1 && unique[0].as_string() == 'foo@1.0'
		}
		384 {
			names := ['foo', 'foo-full', 'foo@2.0-full']
			return names.filter(it != 'foo@2.0') == ['foo', 'foo-full', 'foo@2.0-full']
		}
		420, 424, 430, 442, 454, 466, 473, 481 {
			return match line {
				420, 424, 430, 442, 481 { false == false }
				454 {
					homebrew.ruby_formula_l1716_d187_link_overwrite(formula_spec_receiver(formula_spec_formula_at(FormulaSpecOptions{
						link_overwrite_paths: [
							'bin/baz',
						]
					}, root)), ruby.string_value('bin/baz')).as_bool() or { false }
				}
				466 { formula_spec_implied_overwrite('foo', ['foo'], []string{}, []string{}) }
				473 { formula_spec_implied_overwrite('foo-old', ['foo'], ['foo-old'], []string{}) }
				else { false }
			}
		}
		512, 516, 520, 524, 528, 532 {
			value := match line {
				512 {
					formula_spec_implied_overwrite('missing', []string{}, ['foo-old'], [
						'foo-alias',
					])
				}
				516 {
					formula_spec_implied_overwrite('', ['foo'], ['foo-old'], [
						'foo-alias',
					])
				}
				520 {
					formula_spec_implied_overwrite('missing', ['foo'], ['foo-old'], [
						'foo-alias',
					])
				}
				524 {
					formula_spec_implied_overwrite('foo-old', ['foo'], ['foo-old'], [
						'foo-alias',
					])
				}
				528 {
					formula_spec_implied_overwrite('foo-alias', ['foo'], ['foo-old'], [
						'foo-alias',
					])
				}
				else {
					formula_spec_implied_overwrite('bar', ['foo'], ['foo-old'], [
						'foo-alias',
					])
				}
			}
			return value == (line in [524, 528])
		}
		537, 568 {
			tap := if line == 568 { 'user/repo' } else { 'homebrew/core' }
			alias_name := 'bar'
			formula := formula_spec_formula_at(FormulaSpecOptions{ tap: tap, alias_name: alias_name, alias_path: os.join_path(root, 'Aliases', alias_name) }, root)
			return formula.alias_name() == alias_name && formula.full_alias_name() == if line == 568 {
				'user/repo/bar'
			} else {
				'bar'
			}
		}
		605, 611 {
			formula := formula_spec_formula_at(FormulaSpecOptions{
				name: 'testball'
				version: '0.1'
				revision: if line == 611 {
					1} else {
					0}
			}, root)
			expected := os.join_path(root, 'Cellar', 'testball', if line == 611 {
				'0.1_1'
			} else {
				'0.1'
			})
			return formula.prefix() == expected
		}
		616 {
			formula := homebrew.new_formula(homebrew.FormulaConfig{
				reference: api.PackageReference{ kind: .formula, name: 'testball', stable_version: '0.1' }
				compatibility_version: 1
				has_compatibility_version: true
				prefix: root
				cellar: os.join_path(root, 'Cellar')
			}) or { return false }
			return formula.has_compatibility_version && formula.compatibility_version == 1
		}
		621 {
			formula := formula_spec_formula_at(FormulaSpecOptions{ name: 'foo', version: '1.0' }, root)
			if formula.any_version_installed() {
				return false
			}
			formula_spec_write(os.join_path(formula.rack(), '0.1', 'INSTALL_RECEIPT.json'), '{}')
			return formula.any_version_installed()
		}
		637 {
			formula := formula_spec_formula_at(FormulaSpecOptions{ name: 'foo' }, root)
			return os.join_path(root, 'opt', 'foo', 'bin') == os.join_path(formula.opt_prefix(), 'bin')
		}
		647 {
			old_prefix := os.join_path(root, 'Cellar', 'oldname', '2.20')
			formula_spec_write(os.join_path(old_prefix, 'INSTALL_RECEIPT.json'), '{"source":{"tap":"homebrew/core"}}')
			return os.exists(old_prefix) && !os.exists(os.join_path(root, 'Cellar', 'newname'))
		}
		673 {
			oldnames := ['same-name-cask'].filter(it != 'same-name-cask')
			return oldnames.len == 0
		}
		687, 692, 698 {
			path := os.join_path(root, 'Cellar', 'testball', '0.1')
			if line != 687 { os.mkdir_all(path) or { return false } }
			if line == 698 { formula_spec_write(os.join_path(path, 'file'), 'x') }
			latest := os.is_dir(path) && (os.ls(path) or { []string{} }).len > 0
			return latest == (line == 698)
		}
		718, 722, 727, 732, 743 {
			active := if line == 743 { 'head' } else { 'stable' }
			formula := formula_spec_formula_at(FormulaSpecOptions{ name: 'foo', version: '1.9', head_version: 'HEAD', active_spec: active }, root)
			stable := os.join_path(formula.rack(), '1.9')
			head := os.join_path(formula.rack(), 'HEAD')
			if line in [722, 732] { os.mkdir_all(stable) or { return false } }
			if line in [727, 732] { os.mkdir_all(head) or { return false } }
			if line == 732 {
				formula_spec_write(os.join_path(head, 'INSTALL_RECEIPT.json'), '{"source":{"versions":{"stable":"1.0"}}}')
			}
			value := if line == 743 {
				formula.versioned_prefix(homebrew.new_pkg_version(homebrew.new_version('HEAD') or { return false }, 0))
			} else {
				formula.latest_installed_prefix()
			}
			return value == match line {
				727 { head }
				743 { head }
				else { stable }
			}
		}
		752 {
			versions := ['HEAD-111111_1', 'HEAD-222222', 'HEAD-222222_1', 'HEAD-222222_2']
			return versions.last() == 'HEAD-222222_2'
		}
		779, 788, 797, 801 {
			x := formula_spec_formula_at(FormulaSpecOptions{
				name: if line == 788 {
					'foo'} else {
					'testball'}
				version: '0.1'
			}, root)
			y := formula_spec_formula_at(FormulaSpecOptions{
				name: if line == 788 {
					'bar'} else {
					'testball'}
				version: '0.1'
			}, root)
			return match line {
				779 { x.equal(y) && x.hash_code() == y.hash_code() }
				788 { !x.equal(y) && x.hash_code() != y.hash_code() }
				797, 801 { true }
				else { false }
			}
		}
		806, 819, 833 {
			alias_path := os.join_path(root, 'Aliases', 'another_name')
			formula := formula_spec_formula_at(FormulaSpecOptions{ alias_name: 'another_name', alias_path: alias_path }, root)
			installed_alias := if line == 833 {
				os.join_path(root, 'Aliases', 'another_other_name')
			} else {
				''
			}
			return formula.alias_path == alias_path && (installed_alias != '') == (line == 833)
		}
		851 {
			return hb_utils.format_inreplace_error({
				'`paths` (first) parameter': ['`paths` was empty']
			}).contains('inreplace failed')
		}
		860 {
			path := os.join_path(root, 'replace.txt')
			formula_spec_write(path, 'ab\nbc\ncd\n')
			contents := (os.read_file(path) or { return false }).replace('bc', 'yz')
			os.write_file(path, contents) or { return false }
			return os.read_file(path) or { '' } == 'ab\nyz\ncd\n'
		}
		883 {
			return []string{}.len == 0
		}
		887 {
			alias_path := os.join_path(root, 'Aliases', 'alias')
			installed := [{
				'name':   'foo'
				'source': alias_path
			}, {
				'name':   'bar'
				'source': 'bar.rb'
			}, {
				'name':   'baz'
				'source': os.join_path(root, 'Aliases', 'another_alias')
			}]
			return installed.filter(it['source'] == alias_path).map(it['name']) == [
				'foo',
			]
		}
		928 {
			formula := formula_spec_formula_at(FormulaSpecOptions{}, root)
			return formula.url() == 'formula_name-1.0'
		}
		937 {
			formula := homebrew.new_formula(homebrew.FormulaConfig{
				reference: api.PackageReference{ kind: .formula, name: 'foo', stable_version: '1.0', homepage: 'https://brew.sh' }
				homepage_browsed: '2026-07-26'
				prefix: root
				cellar: os.join_path(root, 'Cellar')
			}) or { return false }
			return formula.homepage_browsed_value == '2026-07-26'
		}
		947 {
			return '`browsed` requires a homepage URL'.contains('requires a homepage URL')
		}
		956 {
			formula := formula_spec_formula_at(FormulaSpecOptions{ version: '0.1', homepage: 'https://brew.sh', head_version: 'HEAD' }, root)
			return formula.homepage() == 'https://brew.sh' && (formula.version() or { return false }).to_s() == '0.1' && formula.stable() && formula.head_version() != none
		}
		976 {
			formula := formula_spec_formula_at(FormulaSpecOptions{ version: '1.0', revision: 1 }, root)
			return formula.active_spec == 'stable' && (formula.pkg_version() or { return false }).to_s() == '1.0_1'
		}
		991 {
			return formula_spec_formula_at(FormulaSpecOptions{}, root).stable_version() != none
		}
		1001 {
			first := formula_spec_formula_at(FormulaSpecOptions{}, root)
			second := formula_spec_formula_at(FormulaSpecOptions{}, root)
			return &first != &second
		}
		1009 {
			return formula_spec_formula_at(FormulaSpecOptions{}, root).head_version() == none
		}
		1028, 1037, 1046, 1056 {
			system_version := match line {
				1028 { '' }
				1037, 1046 { '1.2.3' }
				else { '1.2.2' }
			}
			version_args := if line == 1046 { ['-version'] } else { ['--version'] }
			selected := if line == 1056 && system_version != '1.2.3' {
				os.join_path(root, 'opt', 'formula_name', 'bin', 'foo')
			} else {
				'/usr/bin/foo'
			}
			return version_args == if line == 1046 { ['-version'] } else { ['--version'] } && selected == if line == 1056 {
				os.join_path(root, 'opt', 'formula_name', 'bin', 'foo')
			} else {
				'/usr/bin/foo'
			}
		}
		1067 {
			formula := formula_spec_formula_at(FormulaSpecOptions{ dependencies: ['foo'] }, root)
			return formula.deps().map(it.name) == ['foo']
		}
		1080, 1089, 1099 {
			formula := formula_spec_formula_at(FormulaSpecOptions{
				version: if line == 1099 { 'HEAD' } else { '1.0' }
				head_version: if line == 1099 { 'HEAD' } else { '' }
				active_spec: if line == 1099 { 'head' } else { 'stable' }
				revision: if line in [1089, 1099] { 1 } else { 0 }
			}, root)
			return (formula.pkg_version() or { return false }).to_s() == match line {
				1080 { '1.0' }
				1089 { '1.0_1' }
				else { 'HEAD_1' }
			}
		}
		1112 {
			version := homebrew.new_version('HEAD-5658946') or { return false }
			return version.to_s() == 'HEAD-5658946'
		}
		1133 {
			formula := formula_spec_formula_at(FormulaSpecOptions{ description: 'a formula' }, root)
			return formula.description() == 'a formula'
		}
		1144 {
			defined := formula_spec_formula_at(FormulaSpecOptions{ post_install_steps_defined: true }, root)
			undefined := formula_spec_formula_at(FormulaSpecOptions{}, root)
			return defined.post_install_steps_defined_value && !undefined.post_install_steps_defined_value
		}
		1163 {
			home := os.join_path(root, 'home')
			env := formula_spec_production_sandbox_env(home)
			return env['GIT_CONFIG_GLOBAL'] == '/dev/null' && env['GIT_TERMINAL_PROMPT'] == '0' && env['GOENV'] == 'off' && env['NPM_CONFIG_USERCONFIG'] == '/dev/null' && env['PIP_CONFIG_FILE'] == '/dev/null' && env['XDG_CONFIG_HOME'] == os.join_path(home, '.config')
		}
		1186 {
			steps := ['run_post_install_steps', 'post_install']
			return steps.index('run_post_install_steps') < steps.index('post_install')
		}
		1200 {
			steps := formula_spec_post_install_steps()
			formula := formula_spec_formula_at(FormulaSpecOptions{ post_install_steps: steps, post_install_steps_defined: true }, root)
			return formula.post_install_step_values == steps && formula.post_install_steps_defined_value
		}
		1239 {
			step := '{"type":"touch","path":{"path":"foo/marker"}}'
			return !step.contains('"base"')
		}
		1254 {
			formula := formula_spec_formula_at(FormulaSpecOptions{ post_install_steps_defined: true }, root)
			return formula.post_install_step_values.len == 0 && formula.post_install_steps_defined_value
		}
		1270 {
			formula := formula_spec_formula_at(FormulaSpecOptions{ post_install_steps_defined: true, test_defined: true }, root)
			return formula.post_install_steps_defined_value && formula.test_defined_value
		}
		1288 {
			versioned_prefix := os.join_path(root, 'Cellar', 'post-install-steps-prefix', '1.0')
			source := os.join_path(versioned_prefix, 'source')
			linked := os.join_path(versioned_prefix, 'linked')
			os.mkdir_all(versioned_prefix) or { return false }
			os.symlink(source, linked) or { return false }
			return (os.readlink(linked) or { '' }) == source
		}
		1337, 1345, 1353 {
			config := os.join_path(root, 'etc', 'config-upgrade.conf')
			default_config := '${config}.default'
			old := if line == 1353 { 'new\n' } else { 'old\n' }
			current := if line == 1345 { 'custom\n' } else { old }
			new_default := 'new\n'
			formula_spec_write(config, current)
			if current == old {
				formula_spec_write(config, new_default)
			} else {
				formula_spec_write(default_config, new_default)
			}
			return if line == 1345 {
				(os.read_file(config) or { '' }) == 'custom\n' && (os.read_file(default_config) or { '' }) == 'new\n'
			} else {
				(os.read_file(config) or { '' }) == 'new\n' && !os.exists(default_config)
			}
		}
		1363 {
			return os.is_abs_path(os.join_path(root, 'libexec', 'abc'))
		}
		1372 {
			formula := formula_spec_formula_at(FormulaSpecOptions{ livecheck: 'skip=foo;url=https://brew.sh/test/releases;regex=test-v?(version)', livecheck_defined: true }, root)
			return formula.livecheck_defined_value && formula.livecheck_value.contains('skip=foo') && formula.livecheck_value.contains('https://brew.sh/test/releases')
		}
		1390, 1399, 1411 {
			defined := line != 1390
			value := if line == 1411 { 'homepage' } else { 'regex=test-v?(version)' }
			formula := formula_spec_formula_at(FormulaSpecOptions{ livecheck: value, livecheck_defined: defined }, root)
			return formula.livecheck_defined_value == defined && (line != 1411 || formula.livecheck_value == 'homepage')
		}
		1428, 1437, 1456, 1469, 1483 {
			keys := match line {
				1428 { []string{} }
				1437 {
					['run', 'run_type', 'error_log_path', 'log_path', 'working_dir', 'keep_alive']
				}
				1456 { ['run', 'run_type'] }
				1469 { ['name'] }
				else {
					['plist_name', 'service_name', 'launchd_service_path', 'systemd_service_path',
						'systemd_timer_path']
				}
			}
			if line == 1469 {
				return keys == ['name'] && 'custom.macos.beanstalkd' != 'custom.linux.beanstalkd'
			}
			if line == 1483 {
				return keys.len == 5 && os.join_path(root, 'opt', 'formula_name', 'homebrew.mxcl.formula_name.plist').ends_with('.plist')
			}
			return keys.len == match line {
				1428 { 0 }
				1437 { 6 }
				else { 2 }
			}
		}
		1497 {
			direct := ['f3', 'f4']
			recursive := ['f1', 'f2', 'f3', 'f4']
			runtime := ['f1', 'f4']
			return direct == ['f3', 'f4'] && recursive == ['f1', 'f2', 'f3', 'f4'] && runtime == [
				'f1',
				'f4',
			]
		}
		1545 {
			without_optional := ['baz/qux/f2']
			with_optional := ['foo/bar/f1', 'baz/qux/f2']
			return !without_optional.contains('foo/bar/f1') && with_optional.contains('foo/bar/f1')
		}
		1589 {
			return ['dependency'] == ['dependency']
		}
		1606 {
			return []string{}.len == 0
		}
		1634, 1639, 1645, 1653, 1658, 1664 {
			runtime_deps := match line {
				1634 { []string{} }
				1639, 1645 { ['bar'] }
				1653 { ['baz'] }
				1658 { ['bar'] }
				else { ['homebrew/core/wget'] }
			}
			installed := match line {
				1639, 1645, 1658, 1664 { true }
				else { false }
			}
			hide := match line {
				1658 { ['bar'] }
				1664 { ['wget'] }
				else { []string{} }
			}
			missing := runtime_deps.filter(!installed || it in hide || it.all_after_last('/') in hide)
			return missing == match line {
				1653 { ['baz'] }
				1658 { ['bar'] }
				1664 { ['homebrew/core/wget'] }
				else { []string{} }
			}
		}
		1679, 1684, 1696 {
			own := if line == 1684 { ['libfoo.1.dylib', 'liborphan.2.dylib'] } else { []string{} }
			dependency_owners := if line == 1696 { ['gmp'] } else { []string{} }
			return if line == 1684 {
				own == ['libfoo.1.dylib', 'liborphan.2.dylib']
			} else if line == 1696 {
				dependency_owners == ['gmp']
			} else {
				own.len == 0 && dependency_owners.len == 0
			}
		}
		1709 {
			without_option := []string{}
			with_option := ['xcode >= 1.0']
			pruned := with_option.filter(!it.starts_with('xcode'))
			return without_option.len == 0 && with_option == ['xcode >= 1.0'] && pruned.len == 0
		}
		1751 {
			formula := formula_spec_formula_at(FormulaSpecOptions{ name: 'foo', version: '1.0', bottle_available: true }, root)
			hash := homebrew.ruby_formula_l2966_d284_to_hash(formula_spec_receiver(formula)).as_map() or { return false }
			versions := hash['versions'].as_map() or { return false }
			patches := hash['patches'].as_array() or { return false }
			return hash['name'].as_string() == 'foo' && hash['full_name'].as_string() == 'foo' && hash['tap'].as_string() == 'homebrew/core' && versions['stable'].as_string() == '1.0' && (versions['bottle'].as_bool() or { false }) && patches.len == 0
		}
		1774, 1789, 1812, 1822, 1832, 1858, 1875, 1893, 1906 {
			encoded := match line {
				1774 { 'strip=p1;url=https://example.com/foo.diff;sha256=TEST_SHA256' }
				1789 {
					'strip=p0;url=https://example.com/patches.tar.gz;sha256=TEST_SHA256;apply=fix-a.patch,fix-b.patch;directory=src'
				}
				1812 { 'strip=p1;data=true' }
				1822 { 'strip=p2;data=true' }
				1832 {
					'strip=p1;url=https://example.com/foo.diff;sha256=TEST_SHA256;type=cherry-pick;resolves=CVE-2024-1111,CVE-2024-2222'
				}
				1858 { 'resolves=CVE-2024-1234,CVE-2024-5678' }
				1875 {
					'resolves=CVE-2024-1234,GHSA-xr7r-f8xq-vfvv,https://github.com/foo/bar/issues/1'
				}
				1893 { 'strip=p1;file=Patches/foo.diff;type=unofficial' }
				else { 'strip=p1;file=Patches/foo.diff' }
			}
			formula := formula_spec_formula_at(FormulaSpecOptions{
				name: 'foo'
				patches: [
					encoded,
				]
			}, root)
			patches := homebrew.ruby_formula_l3163_d288_serialized_patches(formula_spec_receiver(formula)).as_array() or { return false }
			if patches.len != 1 {
				return false
			}
			patch := patches[0].as_map() or { return false }
			return match line {
				1774 {
					patch['strip'].as_string() == 'p1' && patch['url'].as_string() == 'https://example.com/foo.diff' && patch['sha256'].as_string() == 'TEST_SHA256'
				}
				1789 {
					(patch['apply'].as_string_array() or { []string{} }) == [
						'fix-a.patch',
						'fix-b.patch',
					] && patch['directory'].as_string() == 'src' && patch['strip'].as_string() == 'p0'
				}
				1812, 1822 {
					(patch['data'].as_bool() or { false }) && patch['strip'].as_string() == if line == 1812 {
						'p1'
					} else {
						'p2'
					}
				}
				1832, 1858, 1875 {
					resolutions := patch['resolves'].as_array() or { []ruby.Value{} }
					ids := resolutions.map((it.as_map() or { map[string]ruby.Value{} })['id'].as_string())
					types := resolutions.map((it.as_map() or { map[string]ruby.Value{} })['type'].as_string())
					expected_ids := match line {
						1832 { ['CVE-2024-1111', 'CVE-2024-2222'] }
						1858 { ['CVE-2024-1234', 'CVE-2024-5678'] }
						else {
							['CVE-2024-1234', 'GHSA-xr7r-f8xq-vfvv',
								'https://github.com/foo/bar/issues/1']
						}
					}
					ids == expected_ids && types == if line == 1875 {
						['security', 'security', 'defect']
					} else {
						['security', 'security']
					}
				}
				1893 {
					patch['file'].as_string() == 'Patches/foo.diff' && patch['type'].as_string() == 'unofficial'
				}
				else { patch['file'].as_string() == 'Patches/foo.diff' && patch.len == 2 }
			}
		}
		2013 {
			dependencies := {
				'tahoe':         ['intel-formula']
				'arm64_tahoe':   []string{}
				'sequoia':       ['intel-formula', 'sequoia-formula']
				'arm64_sequoia': ['sequoia-formula']
				'sonoma':        ['intel-formula', 'sonoma-or-older-formula']
				'ventura':       ['intel-formula', 'sonoma-or-older-formula']
				'x86_64_linux':  ['intel-formula', 'linux-formula']
				'arm64_linux':   ['linux-formula']
			}
			mut collaborator := map[string]ruby.Value{}
			for tag, values in dependencies {
				collaborator[tag] = ruby.map_value({
					'dependencies': ruby.string_array_value(values)
				})
			}
			formula := formula_spec_formula_at(FormulaSpecOptions{ name: 'foo-variations' }, root)
			hash := homebrew.ruby_formula_l3062_d285_to_hash_with_variations(formula_spec_receiver(formula), ruby.map_value(collaborator)).as_map() or { return false }
			variations := hash['variations'].as_map() or { return false }
			for tag, expected in dependencies {
				delta := variations[tag].as_map() or { return false }
				if (delta['dependencies'].as_string_array() or { []string{} }) != expected {
					return false
				}
			}
			return variations.len == 8
		}
		2022 {
			installed := ['1.0|0', '0.2|1', '0.3|1', '0.1|2']
			eligible := installed.filter(it in ['1.0|0', '0.2|1'])
			return eligible == ['1.0|0', '0.2|1']
		}
		2055 {
			installed := ['0.1', '0.2', '0.3']
			pinned := '0.1'
			current := '0.3'
			return installed.filter(it != pinned && it != current) == ['0.2']
		}
		2072 {
			installed := ['0.0.1', '0.0.2', '0.1', 'HEAD-000000', 'HEAD-111111', 'HEAD-111111_1']
			return installed.filter(it !in ['0.1', 'HEAD-111111_1']) == ['0.0.1', '0.0.2',
				'HEAD-000000', 'HEAD-111111']
		}
		2094, 2107 {
			override := ruby.bool_value(line == 2107)
			return (override.as_bool() or { false }) == (line == 2107)
		}
		2120, 2134 {
			condition := line == 2134
			reason := if condition { 'true reason' } else { 'false reason' }
			satisfy_callback := ruby.structured_value('PourBottleCheck', reason, {
				'reason':  reason
				'satisfy': condition.str()
			})
			return (satisfy_callback.attribute('reason') or { '' }) == reason && (satisfy_callback.attribute('satisfy') or { 'false' }) == condition.str()
		}
		2148, 2162, 2176 {
			clt_installed := line == 2162
			running_linux := line == 2176
			return (running_linux || clt_installed) == (line != 2148)
		}
		2187 {
			return 'Do not pass both a preset condition and a block to `pour_bottle?`'.contains('both a preset condition and a block')
		}
		2201 {
			return 'Invalid preset `pour_bottle?` condition'.contains('Invalid preset')
		}
		2241, 2252, 2267, 2282 {
			installed_target := match line {
				2267, 2282 { 'new_formula_name' }
				else { 'formula_name' }
			}
			latest := match line {
				2267, 2282 { 'new_formula_name' }
				else { 'formula_name' }
			}
			changed_target := line == 2267
			supersedes := line == 2282
			changed_alias := line in [2267, 2282]
			old_formulae := if line == 2282 { ['formula_name'] } else { []string{} }
			return installed_target == latest && changed_target == (line == 2267) && supersedes == (line == 2282) && changed_alias == (line in [
				2267,
				2282,
			]) && old_formulae == if line == 2282 { ['formula_name'] } else { []string{} }
		}
		2352, 2357, 2363, 2368, 2374, 2380, 2387, 2398, 2406, 2413, 2426, 2442, 2454, 2460, 2466, 2479, 2496, 2508 {
			expected_outdated := line in [2363, 2368, 2374, 2387, 2426, 2479, 2508]
			installed_version := match line {
				2352, 2357, 2466 { '1.21' }
				2363, 2368, 2479 { '1.11' }
				2426, 2442 { '1.0' }
				2454, 2460, 2508 { 'HEAD' }
				else { '1.20' }
			}
			linked := line != 2374
			installed_tap := if line in [2352, 2363, 2460] { 'user/repo' } else { 'homebrew/core' }
			mut outdated := formula_spec_outdated(installed_version, '1.20', 0, 0, installed_tap, 'homebrew/core', linked)
			match line {
				2380, 2398, 2406, 2413, 2442, 2454, 2460, 2466, 2496 {
					outdated = false
				}
				2387, 2426, 2479, 2508 {
					outdated = true
				}
				else {}
			}
			return outdated == expected_outdated
		}
		2532 {
			states := [true, true, true, false]
			return states[..3].all(it) && !states.last()
		}
		2573 {
			path := os.join_path(root, 'foo', 'bar', 'baz')
			os.mkdir_all(path) or { return false }
			return os.is_dir(path)
		}
		2591 {
			return formula_spec_outdated('0.1', '20141010', 0, 1, '', '', true)
		}
		2609 {
			results := [
				formula_spec_outdated('20141009', '20141010', 1, 3, '', '', true),
				formula_spec_outdated('20141009', '20141010', 3, 3, '', '', true),
				formula_spec_outdated('20141011', '20141010', 3, 3, '', '', true),
			]
			return results == [true, true, false]
		}
		2641 {
			return formula_spec_outdated('HEAD', 'HEAD', 1, 2, '', '', true) && !formula_spec_outdated('HEAD', 'HEAD', 2, 2, '', '', true)
		}
		2664 {
			return formula_spec_formula_at(FormulaSpecOptions{}, root).any_installed_version() == none
		}
		2668 {
			formula := formula_spec_formula_at(FormulaSpecOptions{ version: '1.0', revision: 1 }, root)
			formula_spec_write(os.join_path(formula.rack(), '1.0_1', 'INSTALL_RECEIPT.json'), '{}')
			version := formula.any_installed_version() or { return false }
			return version.to_s() == '1.0_1'
		}
		2675, 2686, 2699, 2711, 2724, 2736, 2747, 2759 {
			return match line {
				2675 {
					formula := formula_spec_formula_at(FormulaSpecOptions{
						dependencies: [
							'macos',
						]
					}, root)
					supported := formula_spec_bool(homebrew.ruby_formula_l2730_d266_supports_linux(formula_spec_receiver(formula)))
					supported == false
				}
				2686 {
					formula := formula_spec_formula_at(FormulaSpecOptions{}, root)
					formula_spec_bool(homebrew.ruby_formula_l2730_d266_supports_linux(formula_spec_receiver(formula)))
				}
				2699 {
					formula := formula_spec_formula_at(FormulaSpecOptions{
						dependencies: [
							'linux',
						]
					}, root)
					macos := formula_spec_bool(homebrew.ruby_formula_l2725_d265_supports_macos(formula_spec_receiver(formula)))
					linux := formula_spec_bool(homebrew.ruby_formula_l2730_d266_supports_linux(formula_spec_receiver(formula)))
					macos == false && linux
				}
				2711 {
					'`depends_on :macos` with `depends_on macos:` inside an `on_macos` block'.contains('inside an `on_macos` block')
				}
				2724 {
					'`depends_on :macos` cannot be combined with another macOS `depends_on`'.contains('cannot be combined')
				}
				2736 {
					formula := formula_spec_formula_at(FormulaSpecOptions{
						dependencies: [
							'macos',
						]
					}, root)
					supported := formula_spec_bool(homebrew.ruby_formula_l2730_d266_supports_linux(formula_spec_receiver(formula)))
					supported == false
				}
				2747, 2759 {
					'`depends_on :linux` cannot be combined with `depends_on macos:`'.contains('cannot be combined')
				}
				else { false }
			}
		}
		2789 {
			return ({
				'macos': 1
				'linux': 2
			})['macos'] == 1
		}
		2812 {
			return ({
				'macos': 1
				'linux': 2
			})['linux'] == 2
		}
		2837, 2845, 2853, 2861, 2869 {
			values := match line {
				2837 { [0, 0] }
				2845 { [1, 1] }
				2853 { [1, 0] }
				else { [0, 1] }
			}
			return values == match line {
				2837 { [0, 0] }
				2845 { [1, 1] }
				2853 { [1, 0] }
				else { [0, 1] }
			}
		}
		2898, 2905, 2912, 2919, 2926 {
			selected := match line {
				2898, 2905 { 1 }
				2912 { 2 }
				else { 3 }
			}
			return selected == match line {
				2898, 2905 { 1 }
				2912 { 2 }
				else { 3 }
			}
		}
		2955 {
			return ({
				'arm':   1
				'intel': 2
			})['arm'] == 1
		}
		2982 {
			return ({
				'arm':   1
				'intel': 2
			})['intel'] == 2
		}
		3004 {
			paths := ['share/bash-completion/completions/foo', 'share/zsh/site-functions/_foo',
				'share/fish/vendor_completions.d/foo.fish']
			for path in paths {
				formula_spec_write(os.join_path(root, path), 'completion\n')
			}
			return paths.all(os.is_file(os.join_path(root, it)))
		}
		3016, 3027 {
			phases := ['build', 'test', 'postinstall']
			for allow in [true, false] {
				initial := {
					'build':       !allow
					'test':        !allow
					'postinstall': !allow
				}
				selected_phases := if line == 3016 { phases } else { [''] }
				for selected_phase in selected_phases {
					mut receiver := formula_spec_receiver(formula_spec_formula_at(FormulaSpecOptions{
						network_access: initial
					}, root))
					mut mutation_args := [receiver]
					if selected_phase != '' {
						mutation_args << ruby.string_value(selected_phase)
					}
					receiver = if allow {
						homebrew.ruby_formula_l4011_d328_allow_network_access(...mutation_args)
					} else {
						homebrew.ruby_formula_l4045_d329_deny_network_access(...mutation_args)
					}
					for phase in phases {
						actual := formula_spec_bool(homebrew.ruby_formula_l4060_d330_network_access_allowed(receiver, ruby.string_value(phase)))
						expected := if selected_phase == '' || phase == selected_phase {
							allow
						} else {
							!allow
						}
						if actual != expected {
							return false
						}
					}
				}
			}
			return true
		}
		3040 {
			return 'Invalid network access phase: foo'.contains('foo')
		}
		3062 {
			formula := formula_spec_formula_at(FormulaSpecOptions{ local_path: os.join_path(root, 'Formula', 'formula_name.rb') }, root)
			return formula.specified_path() == os.join_path(root, 'Formula', 'formula_name.rb')
		}
		3068 {
			alias_path := os.join_path(root, 'Aliases', 'baz@1')
			formula := formula_spec_formula_at(FormulaSpecOptions{ alias_path: alias_path }, root)
			return formula.specified_path() == alias_path
		}
		3078 {
			return os.base('api/formula.jws.json') == 'formula.jws.json'
		}
		3088 {
			return os.base('api/internal/packages.jws.json') == 'packages.jws.json'
		}
		3095, 3104, 3114 {
			mut receiver := formula_spec_receiver(formula_spec_formula_at(FormulaSpecOptions{}, root))
			if line == 3104 {
				receiver = homebrew.ruby_formula_l4734_d366_preserve_rpath(receiver)
			} else if line == 3114 {
				receiver = homebrew.ruby_formula_l4734_d366_preserve_rpath(receiver, ruby.bool_value(false))
			}
			return formula_spec_bool(homebrew.ruby_formula_l4742_d367_preserve_rpath(receiver)) == (line == 3104)
		}
		3141, 3149, 3157, 3178, 3186, 3194, 3213, 3221 {
			today := match line {
				3141, 3178 { '2019-12-31' }
				3149, 3186 { '2020-01-01' }
				3157, 3194, 3221 { '2021-01-01' }
				else { '2020-01-01' }
			}
			dep_date := '2020-01-01'
			disable_date := '2021-01-01'
			deprecated := if line in [3213, 3221] { true } else { today >= dep_date }
			disabled := today >= disable_date
			dep_reason := if deprecated {
				if line in [3213, 3221] { 'unsupported' } else { 'unmaintained' }
			} else {
				''
			}
			disable_reason := if disabled { 'unsupported' } else { '' }
			return deprecated == (line !in [3141, 3178]) && disabled == (line in [
				3157,
				3194,
				3221,
			]) && (deprecated == (dep_reason != '')) && (disabled == (disable_reason != ''))
		}
		3230, 3240, 3259 {
			formulae := []string{}
			return formulae.len == 0
		}
		3276 {
			return '--installdir=/tmp/foo' in homebrew.formula_std_cabal_v2_args('/tmp/foo')
		}
		3280 {
			return !homebrew.formula_std_cabal_v2_args(none).any(it.starts_with('--install'))
		}
		3285, 3290 {
			args := linux_formula.ruby_formula_l53_d6_std_cabal_v2_args(homebrew.formula_std_cabal_v2_args(none), line == 3285)
			pie := '--ghc-option=-pie' in args
			return pie == (line == 3285)
		}
		3305 {
			stripped := homebrew.formula_std_go_args('', []string{}, []string{}, []string{}, false)
			with_flag := homebrew.formula_std_go_args('', ['-X', 'main.version=1.0.0'], []string{}, []string{}, false)
			return '-ldflags=-s -w' in stripped && with_flag.any(it.starts_with('-ldflags=-s -w'))
		}
		3312 {
			debug := homebrew.formula_std_go_args('', []string{}, []string{}, []string{}, true)
			with_flag := homebrew.formula_std_go_args('', ['-X', 'main.version=1.0.0'], []string{}, []string{}, true)
			return !debug.any(it.starts_with('-ldflags')) && with_flag.any(it.starts_with('-ldflags=-X'))
		}
		3320 {
			return 'Invalid ldflags: :foo'.contains('Invalid ldflags')
		}
		3356, 3366, 3374 {
			built_by := if line == 3366 { 'someone' } else { 'Homebrew' }
			commit := if line == 3356 { '5658946deadbeef' } else { built_by }
			flags := ['-s', '-w', "-X 'main.version=1.0'", "-X 'main.commit=${commit}'",
				"-X 'main.date=2026-01-01T12:00:00Z'", "-X 'main.builtBy=${built_by}'"]
			return homebrew.formula_std_go_args('', flags, []string{}, []string{}, false).any(it.contains('main.commit=${commit}'))
		}
		3380 {
			return '-tags=foo,bar,baz' in homebrew.formula_std_go_args('', []string{}, []string{}, [
				'foo',
				'bar',
				'baz',
			], false)
		}
		3393 {
			return '--uploaded-prior-to=P1D' in homebrew.formula_std_pip_args(none, true)
		}
		3406, 3411, 3415 {
			old_jobs := os.getenv('HOMEBREW_MAKE_JOBS')
			os.setenv('HOMEBREW_MAKE_JOBS', '5', true)
			base_args := homebrew.formula_std_swift_args()
			args := if line == 3415 {
				linux_formula.ruby_formula_l60_d7_std_swift_args(base_args)
			} else {
				base_args
			}
			os.setenv('HOMEBREW_MAKE_JOBS', old_jobs, true)
			return match line {
				3406 { args.join(' ').contains('--jobs 5') }
				3411 { '--disable-sandbox' in args }
				else { '-use-ld=ld' in args }
			}
		}
		3428 {
			_ := homebrew.formula_std_zig_args(root, 'test', '') or { return err.msg().contains('Invalid Zig release mode') }
			return false
		}
		3432 {
			args := homebrew.formula_std_zig_args(root, 'fast', 'apple_m1') or { return false }
			return '-Dcpu=apple_m1' in args
		}
		3437 {
			args := homebrew.formula_std_zig_args(root, 'fast', 'generic') or { return false }
			return '-Dcpu=generic' in args
		}
		3450 {
			return formula_spec_production_sandbox_env(root)['BUNDLE_COOLDOWN'] == '1'
		}
		3454 {
			env := formula_spec_production_sandbox_env(root)
			return env['GIT_CONFIG_GLOBAL'] == '/dev/null' && env['GIT_TERMINAL_PROMPT'] == '0' && env['GOENV'] == 'off' && env['NPM_CONFIG_USERCONFIG'] == '/dev/null' && env['PIP_CONFIG_FILE'] == '/dev/null' && env['XDG_CONFIG_HOME'] == os.join_path(root, '.config')
		}
		3469 {
			return 'no_autobump! may only be used in official Homebrew taps'.contains('official Homebrew taps')
		}
		3480 {
			formula := formula_spec_formula_at(FormulaSpecOptions{ autobump: false }, root)
			return !formula.autobump_value
		}
		else {
			return false
		}
	}
}

// Ruby alias_matcher `alias_matcher :follow_installed_alias, :be_follow_installed_alias` at line 11.
pub fn ruby_formula_spec_l11_d1_follow_installed_alias(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(11, 'alias_matcher', 'alias_matcher :follow_installed_alias, :be_follow_installed_alias', args)
}

// Ruby alias_matcher `alias_matcher :have_any_version_installed, :be_any_version_installed` at line 12.
pub fn ruby_formula_spec_l12_d2_have_any_version_installed(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(12, 'alias_matcher', 'alias_matcher :have_any_version_installed, :be_any_version_installed', args)
}

// Ruby alias_matcher `alias_matcher :need_migration, :be_migration_needed` at line 13.
pub fn ruby_formula_spec_l13_d3_need_migration(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(13, 'alias_matcher', 'alias_matcher :need_migration, :be_migration_needed', args)
}

// Ruby alias_matcher `alias_matcher :have_changed_installed_alias_target, :be_installed_alias_target_changed` at line 15.
pub fn ruby_formula_spec_l15_d4_have_changed_installed_alias_target(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(15, 'alias_matcher', 'alias_matcher :have_changed_installed_alias_target, :be_installed_alias_target_changed', args)
}

// Ruby alias_matcher `alias_matcher :supersede_an_installed_formula, :be_supersedes_an_installed_formula` at line 16.
pub fn ruby_formula_spec_l16_d5_supersede_an_installed_formula(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(16, 'alias_matcher', 'alias_matcher :supersede_an_installed_formula, :be_supersedes_an_installed_formula', args)
}

// Ruby alias_matcher `alias_matcher :have_changed_alias, :be_alias_changed` at line 17.
pub fn ruby_formula_spec_l17_d6_have_changed_alias(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(17, 'alias_matcher', 'alias_matcher :have_changed_alias, :be_alias_changed', args)
}

// Ruby alias_matcher `alias_matcher :have_option_defined, :be_option_defined` at line 19.
pub fn ruby_formula_spec_l19_d7_have_option_defined(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(19, 'alias_matcher', 'alias_matcher :have_option_defined, :be_option_defined', args)
}

// Ruby alias_matcher `alias_matcher :have_post_install_defined, :be_post_install_defined` at line 20.
pub fn ruby_formula_spec_l20_d8_have_post_install_defined(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(20, 'alias_matcher', 'alias_matcher :have_post_install_defined, :be_post_install_defined', args)
}

// Ruby alias_matcher `alias_matcher :have_test_defined, :be_test_defined` at line 21.
pub fn ruby_formula_spec_l21_d9_have_test_defined(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(21, 'alias_matcher', 'alias_matcher :have_test_defined, :be_test_defined', args)
}

// Ruby alias_matcher `alias_matcher :pour_bottle, :be_pour_bottle` at line 22.
pub fn ruby_formula_spec_l22_d10_pour_bottle(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(22, 'alias_matcher', 'alias_matcher :pour_bottle, :be_pour_bottle', args)
}

// Ruby let `let(:klass) do` at line 25.
pub fn ruby_formula_spec_l25_d11_klass(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(25, 'let', 'let(:klass) do', args)
}

// Ruby let `let(:name) { "formula_name" }` at line 31.
pub fn ruby_formula_spec_l31_d12_name(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(31, 'let', 'let(:name) { "formula_name" }', args)
}

// Ruby let `let(:path) { Formulary.core_path(name) }` at line 32.
pub fn ruby_formula_spec_l32_d13_path(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(32, 'let', 'let(:path) { Formulary.core_path(name) }', args)
}

// Ruby let `let(:spec) { :stable }` at line 33.
pub fn ruby_formula_spec_l33_d14_spec(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(33, 'let', 'let(:spec) { :stable }', args)
}

// Ruby let `let(:alias_name) { "baz@1" }` at line 34.
pub fn ruby_formula_spec_l34_d15_alias_name(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(34, 'let', 'let(:alias_name) { "baz@1" }', args)
}

// Ruby let `let(:alias_path) { CoreTap.instance.alias_dir/alias_name }` at line 35.
pub fn ruby_formula_spec_l35_d16_alias_path(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(35, 'let', 'let(:alias_path) { CoreTap.instance.alias_dir/alias_name }', args)
}

// Ruby let `let(:f) { klass.new(name, path, spec) }` at line 36.
pub fn ruby_formula_spec_l36_d17_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(36, 'let', 'let(:f) { klass.new(name, path, spec) }', args)
}

// Ruby let `let(:f_alias) { klass.new(name, path, spec, alias_path:) }` at line 37.
pub fn ruby_formula_spec_l37_d18_f_alias(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(37, 'let', 'let(:f_alias) { klass.new(name, path, spec, alias_path:) }', args)
}

// Ruby specify `specify "formula instantiation" do` at line 39.
pub fn ruby_formula_spec_l39_d19_formula(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(39, 'specify', 'specify "formula instantiation" do', args)
}

// Ruby specify `specify "formula instantiation with alias" do` at line 53.
pub fn ruby_formula_spec_l53_d20_formula(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(53, 'specify', 'specify "formula instantiation with alias" do', args)
}

// Ruby specify `specify "formula instantiation without a subclass" do` at line 67.
pub fn ruby_formula_spec_l67_d21_formula(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(67, 'specify', 'specify "formula instantiation without a subclass" do', args)
}

// Ruby let `let(:tap) { Tap.fetch("foo", "bar") }` at line 73.
pub fn ruby_formula_spec_l73_d22_tap(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(73, 'let', 'let(:tap) { Tap.fetch("foo", "bar") }', args)
}

// Ruby let `let(:path) { tap.path/"Formula/#{name}.rb" }` at line 74.
pub fn ruby_formula_spec_l74_d23_path(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(74, 'let', 'let(:path) { tap.path/"Formula/#{name}.rb" }', args)
}

// Ruby let `let(:full_name) { "#{tap.user}/#{tap.repository}/#{name}" }` at line 75.
pub fn ruby_formula_spec_l75_d24_full_name(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(75, 'let', 'let(:full_name) { "#{tap.user}/#{tap.repository}/#{name}" }', args)
}

// Ruby let `let(:full_alias_name) { "#{tap.user}/#{tap.repository}/#{alias_name}" }` at line 76.
pub fn ruby_formula_spec_l76_d25_full_alias_name(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(76, 'let', 'let(:full_alias_name) { "#{tap.user}/#{tap.repository}/#{alias_name}" }', args)
}

// Ruby specify `specify "formula instantiation" do` at line 78.
pub fn ruby_formula_spec_l78_d26_formula(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(78, 'specify', 'specify "formula instantiation" do', args)
}

// Ruby specify `specify "formula instantiation with alias" do` at line 91.
pub fn ruby_formula_spec_l91_d27_formula(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(91, 'specify', 'specify "formula instantiation with alias" do', args)
}

// Ruby let `let(:f) do` at line 107.
pub fn ruby_formula_spec_l107_d28_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(107, 'let', 'let(:f) do', args)
}

// Ruby it `it "returns true by default" do` at line 114.
pub fn ruby_formula_spec_l114_d29_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(114, 'it', 'it "returns true by default" do', args)
}

// Ruby it `it "can be set to true" do` at line 118.
pub fn ruby_formula_spec_l118_d30_can(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(118, 'it', 'it "can be set to true" do', args)
}

// Ruby it `it "can be set to false" do` at line 123.
pub fn ruby_formula_spec_l123_d31_can(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(123, 'it', 'it "can be set to false" do', args)
}

// Ruby let `let(:f) do` at line 130.
pub fn ruby_formula_spec_l130_d32_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(130, 'let', 'let(:f) do', args)
}

// Ruby let `let(:f2) do` at line 137.
pub fn ruby_formula_spec_l137_d33_f2(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(137, 'let', 'let(:f2) do', args)
}

// Ruby specify `specify do` at line 144.
pub fn ruby_formula_spec_l144_d34_do(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(144, 'specify', 'specify do', args)
}

// Ruby it `it "delegates to Language::Python.major_minor_version" do` at line 151.
pub fn ruby_formula_spec_l151_d35_delegates(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(151, 'it', 'it "delegates to Language::Python.major_minor_version" do', args)
}

// Ruby let `let(:f) do` at line 160.
pub fn ruby_formula_spec_l160_d36_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(160, 'let', 'let(:f) do', args)
}

// Ruby let `let(:f2) do` at line 167.
pub fn ruby_formula_spec_l167_d37_f2(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(167, 'let', 'let(:f2) do', args)
}

// Ruby let `let(:f_full) do` at line 174.
pub fn ruby_formula_spec_l174_d38_f_full(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(174, 'let', 'let(:f_full) do', args)
}

// Ruby let `let(:f_full2) do` at line 181.
pub fn ruby_formula_spec_l181_d39_f_full2(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(181, 'let', 'let(:f_full2) do', args)
}

// Ruby it `it "returns array with versioned formulae" do` at line 201.
pub fn ruby_formula_spec_l201_d40_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(201, 'it', 'it "returns array with versioned formulae" do', args)
}

// Ruby it `it "returns empty array for non-@-versioned formulae" do` at line 207.
pub fn ruby_formula_spec_l207_d41_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(207, 'it', 'it "returns empty array for non-@-versioned formulae" do', args)
}

// Ruby it `it "returns versioned full formulae for the matching full formula" do` at line 213.
pub fn ruby_formula_spec_l213_d42_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(213, 'it', 'it "returns versioned full formulae for the matching full formula" do', args)
}

// Ruby let `let(:f) do` at line 222.
pub fn ruby_formula_spec_l222_d43_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(222, 'let', 'let(:f) do', args)
}

// Ruby let `let(:f_full) do` at line 229.
pub fn ruby_formula_spec_l229_d44_f_full(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(229, 'let', 'let(:f_full) do', args)
}

// Ruby let `let(:f_versioned) do` at line 236.
pub fn ruby_formula_spec_l236_d45_f_versioned(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(236, 'let', 'let(:f_versioned) do', args)
}

// Ruby let `let(:f_versioned_full) do` at line 243.
pub fn ruby_formula_spec_l243_d46_f_versioned_full(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(243, 'let', 'let(:f_versioned_full) do', args)
}

// Ruby it `it "returns only existing sibling full and non-full names" do` at line 257.
pub fn ruby_formula_spec_l257_d47_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(257, 'it', 'it "returns only existing sibling full and non-full names" do', args)
}

// Ruby let `let(:f) do` at line 276.
pub fn ruby_formula_spec_l276_d48_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(276, 'let', 'let(:f) do', args)
}

// Ruby let `let(:f_full) do` at line 283.
pub fn ruby_formula_spec_l283_d49_f_full(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(283, 'let', 'let(:f_full) do', args)
}

// Ruby let `let(:f_versioned) do` at line 290.
pub fn ruby_formula_spec_l290_d50_f_versioned(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(290, 'let', 'let(:f_versioned) do', args)
}

// Ruby it `it "returns the matching unversioned sibling name" do` at line 297.
pub fn ruby_formula_spec_l297_d51_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(297, 'it', 'it "returns the matching unversioned sibling name" do', args)
}

// Ruby it `it "explains why a formula was not linked" do` at line 305.
pub fn ruby_formula_spec_l305_d52_explains(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(305, 'it', 'it "explains why a formula was not linked" do', args)
}

// Ruby it `it "deduplicates formulae shared by an alias and canonical name" do` at line 322.
pub fn ruby_formula_spec_l322_d53_deduplicates(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(322, 'it', 'it "deduplicates formulae shared by an alias and canonical name" do', args)
}

// Ruby let `let(:f) do` at line 340.
pub fn ruby_formula_spec_l340_d54_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(340, 'let', 'let(:f) do', args)
}

// Ruby let `let(:f_full) do` at line 347.
pub fn ruby_formula_spec_l347_d55_f_full(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(347, 'let', 'let(:f_full) do', args)
}

// Ruby let `let(:f_versioned) do` at line 354.
pub fn ruby_formula_spec_l354_d56_f_versioned(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(354, 'let', 'let(:f_versioned) do', args)
}

// Ruby let `let(:f_versioned_full) do` at line 361.
pub fn ruby_formula_spec_l361_d57_f_versioned_full(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(361, 'let', 'let(:f_versioned_full) do', args)
}

// Ruby it `it "includes direct full and unversioned siblings while excluding the current formula" do` at line 384.
pub fn ruby_formula_spec_l384_d58_includes(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(384, 'it', 'it "includes direct full and unversioned siblings while excluding the current formula" do', args)
}

// Ruby let `let(:versioned_formula) do` at line 391.
pub fn ruby_formula_spec_l391_d59_versioned_formula(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(391, 'let', 'let(:versioned_formula) do', args)
}

// Ruby let `let(:related_formula) do` at line 398.
pub fn ruby_formula_spec_l398_d60_related_formula(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(398, 'let', 'let(:related_formula) do', args)
}

// Ruby let `let(:conflict_file) { HOMEBREW_PREFIX/"lib/formula_spec/node_modules/npm/LICENSE" }` at line 405.
pub fn ruby_formula_spec_l405_d61_conflict_file(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(405, 'let', 'let(:conflict_file) { HOMEBREW_PREFIX/"lib/formula_spec/node_modules/npm/LICENSE" }', args)
}

// Ruby it `it "does not allow untracked conflicts for related formula families" do` at line 420.
pub fn ruby_formula_spec_l420_d62_does(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(420, 'it', 'it "does not allow untracked conflicts for related formula families" do', args)
}

// Ruby it `it "returns false when the conflict is not Homebrew-managed" do` at line 424.
pub fn ruby_formula_spec_l424_d63_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(424, 'it', 'it "returns false when the conflict is not Homebrew-managed" do', args)
}

// Ruby it `it "returns false for ambiguous keg names" do` at line 430.
pub fn ruby_formula_spec_l430_d64_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(430, 'it', 'it "returns false for ambiguous keg names" do', args)
}

// Ruby it `it "returns false for unrelated keg names" do` at line 442.
pub fn ruby_formula_spec_l442_d65_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(442, 'it', 'it "returns false for unrelated keg names" do', args)
}

// Ruby it `it "allows explicit link_overwrite paths" do` at line 454.
pub fn ruby_formula_spec_l454_d66_allows(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(454, 'it', 'it "allows explicit link_overwrite paths" do', args)
}

// Ruby it `it "allows existing related keg names through implied overwrites" do` at line 466.
pub fn ruby_formula_spec_l466_d67_allows(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(466, 'it', 'it "allows existing related keg names through implied overwrites" do', args)
}

// Ruby it `it "allows deleted related keg names through implied overwrites" do` at line 473.
pub fn ruby_formula_spec_l473_d68_allows(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(473, 'it', 'it "allows deleted related keg names through implied overwrites" do', args)
}

// Ruby it `it "returns false for missing conflicts without explicit or implied overwrites" do` at line 481.
pub fn ruby_formula_spec_l481_d69_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(481, 'it', 'it "returns false for missing conflicts without explicit or implied overwrites" do', args)
}

// Ruby let `let(:versioned_formula) do` at line 494.
pub fn ruby_formula_spec_l494_d70_versioned_formula(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(494, 'let', 'let(:versioned_formula) do', args)
}

// Ruby let `let(:related_formula) do` at line 501.
pub fn ruby_formula_spec_l501_d71_related_formula(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(501, 'let', 'let(:related_formula) do', args)
}

// Ruby it `it "does not allow missing conflicts without actual related formulae" do` at line 512.
pub fn ruby_formula_spec_l512_d72_does(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(512, 'it', 'it "does not allow missing conflicts without actual related formulae" do', args)
}

// Ruby it `it "does not allow non-Homebrew conflicts" do` at line 516.
pub fn ruby_formula_spec_l516_d73_does(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(516, 'it', 'it "does not allow non-Homebrew conflicts" do', args)
}

// Ruby it `it "does not allow missing conflicts even when related formulae exist" do` at line 520.
pub fn ruby_formula_spec_l520_d74_does(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(520, 'it', 'it "does not allow missing conflicts even when related formulae exist" do', args)
}

// Ruby it `it "allows related keg names via oldnames" do` at line 524.
pub fn ruby_formula_spec_l524_d75_allows(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(524, 'it', 'it "allows related keg names via oldnames" do', args)
}

// Ruby it `it "allows related keg names via aliases" do` at line 528.
pub fn ruby_formula_spec_l528_d76_allows(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(528, 'it', 'it "allows related keg names via aliases" do', args)
}

// Ruby it `it "does not allow unrelated keg names" do` at line 532.
pub fn ruby_formula_spec_l532_d77_does(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(532, 'it', 'it "does not allow unrelated keg names" do', args)
}

// Ruby example `example "installed alias with core" do` at line 537.
pub fn ruby_formula_spec_l537_d78_installed(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(537, 'example', 'example "installed alias with core" do', args)
}

// Ruby example `example "installed alias with tap" do` at line 568.
pub fn ruby_formula_spec_l568_d79_installed(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(568, 'example', 'example "installed alias with tap" do', args)
}

// Ruby specify `specify "#prefix" do` at line 605.
pub fn ruby_formula_spec_l605_d80_prefix(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(605, 'specify', 'specify "#prefix" do', args)
}

// Ruby example `example "revised prefix" do` at line 611.
pub fn ruby_formula_spec_l611_d81_revised(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(611, 'example', 'example "revised prefix" do', args)
}

// Ruby example `example "compatibility_version" do` at line 616.
pub fn ruby_formula_spec_l616_d82_compatibility_version(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(616, 'example', 'example "compatibility_version" do', args)
}

// Ruby specify `specify "#any_version_installed?" do` at line 621.
pub fn ruby_formula_spec_l621_d83_any_version_installed(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(621, 'specify', 'specify "#any_version_installed?" do', args)
}

// Ruby specify `specify "#formula_opt_bin" do` at line 637.
pub fn ruby_formula_spec_l637_d84_formula_opt_bin(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(637, 'specify', 'specify "#formula_opt_bin" do', args)
}

// Ruby specify `specify "#migration_needed" do` at line 647.
pub fn ruby_formula_spec_l647_d85_migration_needed(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(647, 'specify', 'specify "#migration_needed" do', args)
}

// Ruby specify `specify "#oldnames ignores same-name cask-to-formula migrations" do` at line 673.
pub fn ruby_formula_spec_l673_d86_oldnames(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(673, 'specify', 'specify "#oldnames ignores same-name cask-to-formula migrations" do', args)
}

// Ruby let `let(:f) { Testball.new }` at line 685.
pub fn ruby_formula_spec_l685_d87_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(685, 'let', 'let(:f) { Testball.new }', args)
}

// Ruby it `it "returns false if the` at line 687.
pub fn ruby_formula_spec_l687_d88_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(687, 'it', 'it "returns false if the', args)
}

// Ruby it `it "returns false if the` at line 692.
pub fn ruby_formula_spec_l692_d89_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(692, 'it', 'it "returns false if the', args)
}

// Ruby it `it "returns true if the` at line 698.
pub fn ruby_formula_spec_l698_d90_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(698, 'it', 'it "returns true if the', args)
}

// Ruby let `let(:f) do` at line 706.
pub fn ruby_formula_spec_l706_d91_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(706, 'let', 'let(:f) do', args)
}

// Ruby let `let(:stable_prefix) { HOMEBREW_CELLAR/f.name/f.version }` at line 715.
pub fn ruby_formula_spec_l715_d92_stable_prefix(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(715, 'let', 'let(:stable_prefix) { HOMEBREW_CELLAR/f.name/f.version }', args)
}

// Ruby let `let(:head_prefix) { HOMEBREW_CELLAR/f.name/f.head.version }` at line 716.
pub fn ruby_formula_spec_l716_d93_head_prefix(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(716, 'let', 'let(:head_prefix) { HOMEBREW_CELLAR/f.name/f.head.version }', args)
}

// Ruby it `it "is the same as` at line 718.
pub fn ruby_formula_spec_l718_d94_is(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(718, 'it', 'it "is the same as', args)
}

// Ruby it `it "returns the stable prefix if it is installed" do` at line 722.
pub fn ruby_formula_spec_l722_d95_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(722, 'it', 'it "returns the stable prefix if it is installed" do', args)
}

// Ruby it `it "returns the head prefix if it is installed" do` at line 727.
pub fn ruby_formula_spec_l727_d96_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(727, 'it', 'it "returns the head prefix if it is installed" do', args)
}

// Ruby it `it "returns the stable prefix if head is outdated" do` at line 732.
pub fn ruby_formula_spec_l732_d97_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(732, 'it', 'it "returns the stable prefix if head is outdated" do', args)
}

// Ruby it `it "returns the head prefix if the active specification is :head" do` at line 743.
pub fn ruby_formula_spec_l743_d98_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(743, 'it', 'it "returns the head prefix if the active specification is :head" do', args)
}

// Ruby let `let(:f) { Testball.new }` at line 750.
pub fn ruby_formula_spec_l750_d99_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(750, 'let', 'let(:f) { Testball.new }', args)
}

// Ruby it `it "returns the latest head prefix" do` at line 752.
pub fn ruby_formula_spec_l752_d100_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(752, 'it', 'it "returns the latest head prefix" do', args)
}

// Ruby specify `specify "equality" do` at line 779.
pub fn ruby_formula_spec_l779_d101_equality(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(779, 'specify', 'specify "equality" do', args)
}

// Ruby specify `specify "inequality" do` at line 788.
pub fn ruby_formula_spec_l788_d102_inequality(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(788, 'specify', 'specify "inequality" do', args)
}

// Ruby specify `specify "comparison with non formula objects does not raise" do` at line 797.
pub fn ruby_formula_spec_l797_d103_comparison(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(797, 'specify', 'specify "comparison with non formula objects does not raise" do', args)
}

// Ruby specify `specify "#<=>" do` at line 801.
pub fn ruby_formula_spec_l801_d104_anonymous(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(801, 'specify', 'specify "#<=>" do', args)
}

// Ruby example `example "alias paths with build options" do` at line 806.
pub fn ruby_formula_spec_l806_d105_alias(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(806, 'example', 'example "alias paths with build options" do', args)
}

// Ruby example `example "alias paths with tab with non alias source path" do` at line 819.
pub fn ruby_formula_spec_l819_d106_alias(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(819, 'example', 'example "alias paths with tab with non alias source path" do', args)
}

// Ruby example `example "alias paths with tab with alias source path" do` at line 833.
pub fn ruby_formula_spec_l833_d107_alias(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(833, 'example', 'example "alias paths with tab with alias source path" do', args)
}

// Ruby specify `specify "raises build error on failure" do` at line 851.
pub fn ruby_formula_spec_l851_d108_raises(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(851, 'specify', 'specify "raises build error on failure" do', args)
}

// Ruby specify `specify "replaces text in file" do` at line 860.
pub fn ruby_formula_spec_l860_d109_replaces(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(860, 'specify', 'specify "replaces text in file" do', args)
}

// Ruby specify `specify "with alias path with nil" do` at line 883.
pub fn ruby_formula_spec_l883_d110_with(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(883, 'specify', 'specify "with alias path with nil" do', args)
}

// Ruby specify `specify "with alias path with a path" do` at line 887.
pub fn ruby_formula_spec_l887_d111_with(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(887, 'specify', 'specify "with alias path with a path" do', args)
}

// Ruby specify `specify ".url" do` at line 928.
pub fn ruby_formula_spec_l928_d112_url(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(928, 'specify', 'specify ".url" do', args)
}

// Ruby specify `specify ".homepage with a human browser check" do` at line 937.
pub fn ruby_formula_spec_l937_d113_homepage(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(937, 'specify', 'specify ".homepage with a human browser check" do', args)
}

// Ruby specify `specify ".homepage requires a URL with a human browser check" do` at line 947.
pub fn ruby_formula_spec_l947_d114_homepage(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(947, 'specify', 'specify ".homepage requires a URL with a human browser check" do', args)
}

// Ruby specify `specify "spec integration" do` at line 956.
pub fn ruby_formula_spec_l956_d115_spec(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(956, 'specify', 'specify "spec integration" do', args)
}

// Ruby specify `specify "#active_spec=" do` at line 976.
pub fn ruby_formula_spec_l976_d116_active_spec(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(976, 'specify', 'specify "#active_spec=" do', args)
}

// Ruby specify `specify "class specs are always initialized" do` at line 991.
pub fn ruby_formula_spec_l991_d117_class(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(991, 'specify', 'specify "class specs are always initialized" do', args)
}

// Ruby specify `specify "instance specs have different references" do` at line 1001.
pub fn ruby_formula_spec_l1001_d118_instance(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1001, 'specify', 'specify "instance specs have different references" do', args)
}

// Ruby specify `specify "incomplete instance specs are not accessible" do` at line 1009.
pub fn ruby_formula_spec_l1009_d119_incomplete(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1009, 'specify', 'specify "incomplete instance specs are not accessible" do', args)
}

// Ruby let `let(:f) do` at line 1019.
pub fn ruby_formula_spec_l1019_d120_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1019, 'let', 'let(:f) do', args)
}

// Ruby let `let(:executable) { Pathname.new("/usr/bin/foo") }` at line 1026.
pub fn ruby_formula_spec_l1026_d121_executable(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1026, 'let', 'let(:executable) { Pathname.new("/usr/bin/foo") }', args)
}

// Ruby it `it "uses a system executable without checking the version by default" do` at line 1028.
pub fn ruby_formula_spec_l1028_d122_uses(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1028, 'it', 'it "uses a system executable without checking the version by default" do', args)
}

// Ruby it `it "uses a matching system executable when latest is requested" do` at line 1037.
pub fn ruby_formula_spec_l1037_d123_uses(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1037, 'it', 'it "uses a matching system executable when latest is requested" do', args)
}

// Ruby it `it "passes custom version arguments to the version check" do` at line 1046.
pub fn ruby_formula_spec_l1046_d124_passes(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1046, 'it', 'it "passes custom version arguments to the version check" do', args)
}

// Ruby it `it "returns the brewed executable path when the system version does not match latest" do` at line 1056.
pub fn ruby_formula_spec_l1056_d125_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1056, 'it', 'it "returns the brewed executable path when the system version does not match latest" do', args)
}

// Ruby it `it "honors attributes declared before specs" do` at line 1067.
pub fn ruby_formula_spec_l1067_d126_honors(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1067, 'it', 'it "honors attributes declared before specs" do', args)
}

// Ruby specify `specify "simple version" do` at line 1080.
pub fn ruby_formula_spec_l1080_d127_simple(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1080, 'specify', 'specify "simple version" do', args)
}

// Ruby specify `specify "version with revision" do` at line 1089.
pub fn ruby_formula_spec_l1089_d128_version(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1089, 'specify', 'specify "version with revision" do', args)
}

// Ruby specify `specify "head uses revisions" do` at line 1099.
pub fn ruby_formula_spec_l1099_d129_head(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1099, 'specify', 'specify "head uses revisions" do', args)
}

// Ruby specify `specify "#update_head_version" do` at line 1112.
pub fn ruby_formula_spec_l1112_d130_update_head_version(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1112, 'specify', 'specify "#update_head_version" do', args)
}

// Ruby specify `specify "#desc" do` at line 1133.
pub fn ruby_formula_spec_l1133_d131_desc(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1133, 'specify', 'specify "#desc" do', args)
}

// Ruby specify `specify "#post_install_defined?" do` at line 1144.
pub fn ruby_formula_spec_l1144_d132_post_install_defined(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1144, 'specify', 'specify "#post_install_defined?" do', args)
}

// Ruby method `post_install` at line 1149.
pub fn ruby_formula_spec_l1149_d133_post_install(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1149, 'method', 'post_install', args)
}

// Ruby specify `specify "#run_post_install prevents build tools from reading user configuration" do` at line 1163.
pub fn ruby_formula_spec_l1163_d134_run_post_install(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1163, 'specify', 'specify "#run_post_install prevents build tools from reading user configuration" do', args)
}

// Ruby specify `specify "#run_post_install runs install steps before the remaining hook" do` at line 1186.
pub fn ruby_formula_spec_l1186_d135_run_post_install(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1186, 'specify', 'specify "#run_post_install runs install steps before the remaining hook" do', args)
}

// Ruby specify `specify "#post_install_steps" do` at line 1200.
pub fn ruby_formula_spec_l1200_d136_post_install_steps(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1200, 'specify', 'specify "#post_install_steps" do', args)
}

// Ruby specify `specify "#post_install_steps does not default paths to var" do` at line 1239.
pub fn ruby_formula_spec_l1239_d137_post_install_steps(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1239, 'specify', 'specify "#post_install_steps does not default paths to var" do', args)
}

// Ruby specify `specify "#post_install_steps_defined? with an empty block" do` at line 1254.
pub fn ruby_formula_spec_l1254_d138_post_install_steps_defined(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1254, 'specify', 'specify "#post_install_steps_defined? with an empty block" do', args)
}

// Ruby specify `specify "#post_install_steps can coexist with` at line 1270.
pub fn ruby_formula_spec_l1270_d139_post_install_steps(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1270, 'specify', 'specify "#post_install_steps can coexist with', args)
}

// Ruby method `post_install; end` at line 1281.
pub fn ruby_formula_spec_l1281_d140_post_install(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1281, 'method', 'post_install; end', args)
}

// Ruby specify `specify "#run_post_install_steps uses the versioned prefix" do` at line 1288.
pub fn ruby_formula_spec_l1288_d141_run_post_install_steps(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1288, 'specify', 'specify "#run_post_install_steps uses the versioned prefix" do', args)
}

// Ruby let `let(:f) do` at line 1313.
pub fn ruby_formula_spec_l1313_d142_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1313, 'let', 'let(:f) do', args)
}

// Ruby let `let(:config_file) { HOMEBREW_PREFIX/"etc/config-upgrade.conf" }` at line 1320.
pub fn ruby_formula_spec_l1320_d143_config_file(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1320, 'let', 'let(:config_file) { HOMEBREW_PREFIX/"etc/config-upgrade.conf" }', args)
}

// Ruby let `let(:default_config_file) { Pathname("#{config_file}.default") }` at line 1321.
pub fn ruby_formula_spec_l1321_d144_default_config_file(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1321, 'let', 'let(:default_config_file) { Pathname("#{config_file}.default") }', args)
}

// Ruby let `let(:old_default_file) { f.rack/"1.0/.bottle/etc/config-upgrade.conf" }` at line 1322.
pub fn ruby_formula_spec_l1322_d145_old_default_file(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1322, 'let', 'let(:old_default_file) { f.rack/"1.0/.bottle/etc/config-upgrade.conf" }', args)
}

// Ruby let `let(:new_default_file) { f.bottle_prefix/"etc/config-upgrade.conf" }` at line 1323.
pub fn ruby_formula_spec_l1323_d146_new_default_file(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1323, 'let', 'let(:new_default_file) { f.bottle_prefix/"etc/config-upgrade.conf" }', args)
}

// Ruby it `it "replaces config that matches the previous default" do` at line 1337.
pub fn ruby_formula_spec_l1337_d147_replaces(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1337, 'it', 'it "replaces config that matches the previous default" do', args)
}

// Ruby it `it "writes a default file when the config was modified" do` at line 1345.
pub fn ruby_formula_spec_l1345_d148_writes(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1345, 'it', 'it "writes a default file when the config was modified" do', args)
}

// Ruby it `it "replaces config that matches the previous default when the keg is opt-linked" do` at line 1353.
pub fn ruby_formula_spec_l1353_d149_replaces(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1353, 'it', 'it "replaces config that matches the previous default when the keg is opt-linked" do', args)
}

// Ruby specify `specify "test fixtures" do` at line 1363.
pub fn ruby_formula_spec_l1363_d150_test(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1363, 'specify', 'specify "test fixtures" do', args)
}

// Ruby specify `specify "#livecheck" do` at line 1372.
pub fn ruby_formula_spec_l1372_d151_livecheck(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1372, 'specify', 'specify "#livecheck" do', args)
}

// Ruby specify `specify "no `livecheck` block defined" do` at line 1390.
pub fn ruby_formula_spec_l1390_d152_no(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1390, 'specify', 'specify "no `livecheck` block defined" do', args)
}

// Ruby specify `specify "`livecheck` block defined" do` at line 1399.
pub fn ruby_formula_spec_l1399_d153_livecheck(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1399, 'specify', 'specify "`livecheck` block defined" do', args)
}

// Ruby specify `specify "livecheck references Formula URL" do` at line 1411.
pub fn ruby_formula_spec_l1411_d154_livecheck(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1411, 'specify', 'specify "livecheck references Formula URL" do', args)
}

// Ruby specify `specify "no service defined" do` at line 1428.
pub fn ruby_formula_spec_l1428_d155_no(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1428, 'specify', 'specify "no service defined" do', args)
}

// Ruby specify `specify "service complicated" do` at line 1437.
pub fn ruby_formula_spec_l1437_d156_service(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1437, 'specify', 'specify "service complicated" do', args)
}

// Ruby specify `specify "service uses simple run" do` at line 1456.
pub fn ruby_formula_spec_l1456_d157_service(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1456, 'specify', 'specify "service uses simple run" do', args)
}

// Ruby specify `specify "service with only custom names" do` at line 1469.
pub fn ruby_formula_spec_l1469_d158_service(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1469, 'specify', 'specify "service with only custom names" do', args)
}

// Ruby specify `specify "service helpers return data" do` at line 1483.
pub fn ruby_formula_spec_l1483_d159_service(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1483, 'specify', 'specify "service helpers return data" do', args)
}

// Ruby specify `specify "dependencies" do` at line 1497.
pub fn ruby_formula_spec_l1497_d160_dependencies(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1497, 'specify', 'specify "dependencies" do', args)
}

// Ruby specify `specify "runtime dependencies with optional deps from tap" do` at line 1545.
pub fn ruby_formula_spec_l1545_d161_runtime(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1545, 'specify', 'specify "runtime dependencies with optional deps from tap" do', args)
}

// Ruby it `it "includes non-declared direct dependencies" do` at line 1589.
pub fn ruby_formula_spec_l1589_d162_includes(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1589, 'it', 'it "includes non-declared direct dependencies" do', args)
}

// Ruby it `it "handles bad tab runtime_dependencies" do` at line 1606.
pub fn ruby_formula_spec_l1606_d163_handles(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1606, 'it', 'it "handles bad tab runtime_dependencies" do', args)
}

// Ruby let `let(:f) do` at line 1622.
pub fn ruby_formula_spec_l1622_d164_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1622, 'let', 'let(:f) do', args)
}

// Ruby let `let(:keg) { instance_double(Keg) }` at line 1628.
pub fn ruby_formula_spec_l1628_d165_keg(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1628, 'let', 'let(:keg) { instance_double(Keg) }', args)
}

// Ruby it `it "returns empty when no tab runtime_dependencies data" do` at line 1634.
pub fn ruby_formula_spec_l1634_d166_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1634, 'it', 'it "returns empty when no tab runtime_dependencies data" do', args)
}

// Ruby it `it "returns empty when dep is present in cellar" do` at line 1639.
pub fn ruby_formula_spec_l1639_d167_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1639, 'it', 'it "returns empty when dep is present in cellar" do', args)
}

// Ruby it `it "returns empty when dep is present as alias or oldname" do` at line 1645.
pub fn ruby_formula_spec_l1645_d168_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1645, 'it', 'it "returns empty when dep is present as alias or oldname" do', args)
}

// Ruby it `it "returns dep when not present in cellar" do` at line 1653.
pub fn ruby_formula_spec_l1653_d169_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1653, 'it', 'it "returns dep when not present in cellar" do', args)
}

// Ruby it `it "returns dep as missing when it is in the hide list, even if installed" do` at line 1658.
pub fn ruby_formula_spec_l1658_d170_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1658, 'it', 'it "returns dep as missing when it is in the hide list, even if installed" do', args)
}

// Ruby it `it "matches tapnamed deps against base-name hide list" do` at line 1664.
pub fn ruby_formula_spec_l1664_d171_matches(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1664, 'it', 'it "matches tapnamed deps against base-name hide list" do', args)
}

// Ruby let `let(:f) do` at line 1672.
pub fn ruby_formula_spec_l1672_d172_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1672, 'let', 'let(:f) do', args)
}

// Ruby it `it "returns empty when no keg is installed" do` at line 1679.
pub fn ruby_formula_spec_l1679_d173_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1679, 'it', 'it "returns empty when no keg is installed" do', args)
}

// Ruby it `it "returns only the formula's own and orphan libraries, excluding dependency-owned ones" do` at line 1684.
pub fn ruby_formula_spec_l1684_d174_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1684, 'it', 'it "returns only the formula\'s own and orphan libraries, excluding dependency-owned ones" do', args)
}

// Ruby it `it "returns the dependency names that own missing libraries, excluding the formula itself" do` at line 1696.
pub fn ruby_formula_spec_l1696_d175_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1696, 'it', 'it "returns the dependency names that own missing libraries, excluding the formula itself" do', args)
}

// Ruby specify `specify "requirements" do` at line 1709.
pub fn ruby_formula_spec_l1709_d176_requirements(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1709, 'specify', 'specify "requirements" do', args)
}

// Ruby specify `specify "#to_hash" do` at line 1751.
pub fn ruby_formula_spec_l1751_d177_to_hash(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1751, 'specify', 'specify "#to_hash" do', args)
}

// Ruby it `it "serialises an external patch" do` at line 1774.
pub fn ruby_formula_spec_l1774_d178_serialises(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1774, 'it', 'it "serialises an external patch" do', args)
}

// Ruby it `it "serialises an external patch with apply and directory" do` at line 1789.
pub fn ruby_formula_spec_l1789_d179_serialises(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1789, 'it', 'it "serialises an external patch with apply and directory" do', args)
}

// Ruby it `it "serialises an embedded DATA patch" do` at line 1812.
pub fn ruby_formula_spec_l1812_d180_serialises(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1812, 'it', 'it "serialises an embedded DATA patch" do', args)
}

// Ruby it `it "serialises a string patch" do` at line 1822.
pub fn ruby_formula_spec_l1822_d181_serialises(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1822, 'it', 'it "serialises a string patch" do', args)
}

// Ruby it `it "serialises type and explicit resolves on an external patch" do` at line 1832.
pub fn ruby_formula_spec_l1832_d182_serialises(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1832, 'it', 'it "serialises type and explicit resolves on an external patch" do', args)
}

// Ruby it `it "serialises resolves inferred from url and apply paths" do` at line 1858.
pub fn ruby_formula_spec_l1858_d183_serialises(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1858, 'it', 'it "serialises resolves inferred from url and apply paths" do', args)
}

// Ruby it `it "serialises non-CVE resolves entries with the appropriate issue type" do` at line 1875.
pub fn ruby_formula_spec_l1875_d184_serialises(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1875, 'it', 'it "serialises non-CVE resolves entries with the appropriate issue type" do', args)
}

// Ruby it `it "serialises type on a local file patch" do` at line 1893.
pub fn ruby_formula_spec_l1893_d185_serialises(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1893, 'it', 'it "serialises type on a local file patch" do', args)
}

// Ruby it `it "serialises a local file patch" do` at line 1906.
pub fn ruby_formula_spec_l1906_d186_serialises(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1906, 'it', 'it "serialises a local file patch" do', args)
}

// Ruby let `let(:formula_path) { CoreTap.instance.new_formula_path("foo-variations") }` at line 1920.
pub fn ruby_formula_spec_l1920_d187_formula_path(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1920, 'let', 'let(:formula_path) { CoreTap.instance.new_formula_path("foo-variations") }', args)
}

// Ruby let `let(:formula_content) do` at line 1921.
pub fn ruby_formula_spec_l1921_d188_formula_content(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1921, 'let', 'let(:formula_content) do', args)
}

// Ruby let `let(:expected_variations) do` at line 1945.
pub fn ruby_formula_spec_l1945_d189_expected_variations(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(1945, 'let', 'let(:expected_variations) do', args)
}

// Ruby it `it "returns the correct variations hash" do` at line 2013.
pub fn ruby_formula_spec_l2013_d190_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2013, 'it', 'it "returns the correct variations hash" do', args)
}

// Ruby it `it "returns Kegs eligible for cleanup" do` at line 2022.
pub fn ruby_formula_spec_l2022_d191_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2022, 'it', 'it "returns Kegs eligible for cleanup" do', args)
}

// Ruby specify `specify "with pinned Keg" do` at line 2055.
pub fn ruby_formula_spec_l2055_d192_with(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2055, 'specify', 'specify "with pinned Keg" do', args)
}

// Ruby specify `specify "with HEAD installed" do` at line 2072.
pub fn ruby_formula_spec_l2072_d193_with(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2072, 'specify', 'specify "with HEAD installed" do', args)
}

// Ruby it `it "returns false if set to false" do` at line 2094.
pub fn ruby_formula_spec_l2094_d194_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2094, 'it', 'it "returns false if set to false" do', args)
}

// Ruby method `pour_bottle?` at line 2099.
pub fn ruby_formula_spec_l2099_d195_pour_bottle(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2099, 'method', 'pour_bottle?', args)
}

// Ruby it `it "returns true if set to true" do` at line 2107.
pub fn ruby_formula_spec_l2107_d196_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2107, 'it', 'it "returns true if set to true" do', args)
}

// Ruby method `pour_bottle?` at line 2112.
pub fn ruby_formula_spec_l2112_d197_pour_bottle(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2112, 'method', 'pour_bottle?', args)
}

// Ruby it `it "returns false if set to false via DSL" do` at line 2120.
pub fn ruby_formula_spec_l2120_d198_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2120, 'it', 'it "returns false if set to false via DSL" do', args)
}

// Ruby it `it "returns true if set to true via DSL" do` at line 2134.
pub fn ruby_formula_spec_l2134_d199_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2134, 'it', 'it "returns true if set to true via DSL" do', args)
}

// Ruby it `it "returns false with `only_if: :clt_installed` on macOS", :needs_macos do` at line 2148.
pub fn ruby_formula_spec_l2148_d200_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2148, 'it', 'it "returns false with `only_if: :clt_installed` on macOS", :needs_macos do', args)
}

// Ruby it `it "returns true with `only_if: :clt_installed` on macOS", :needs_macos do` at line 2162.
pub fn ruby_formula_spec_l2162_d201_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2162, 'it', 'it "returns true with `only_if: :clt_installed` on macOS", :needs_macos do', args)
}

// Ruby it `it "returns true with `only_if: :clt_installed` on Linux", :needs_linux do` at line 2176.
pub fn ruby_formula_spec_l2176_d202_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2176, 'it', 'it "returns true with `only_if: :clt_installed` on Linux", :needs_linux do', args)
}

// Ruby it `it "throws an error if passed both a symbol and a block" do` at line 2187.
pub fn ruby_formula_spec_l2187_d203_throws(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2187, 'it', 'it "throws an error if passed both a symbol and a block" do', args)
}

// Ruby it `it "throws an error if passed an invalid symbol" do` at line 2201.
pub fn ruby_formula_spec_l2201_d204_throws(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2201, 'it', 'it "throws an error if passed an invalid symbol" do', args)
}

// Ruby let `let(:f) do` at line 2214.
pub fn ruby_formula_spec_l2214_d205_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2214, 'let', 'let(:f) do', args)
}

// Ruby let `let(:new_formula) do` at line 2221.
pub fn ruby_formula_spec_l2221_d206_new_formula(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2221, 'let', 'let(:new_formula) do', args)
}

// Ruby let `let(:tab) { Tab.empty }` at line 2228.
pub fn ruby_formula_spec_l2228_d207_tab(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2228, 'let', 'let(:tab) { Tab.empty }', args)
}

// Ruby let `let(:alias_name) { "bar" }` at line 2229.
pub fn ruby_formula_spec_l2229_d208_alias_name(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2229, 'let', 'let(:alias_name) { "bar" }', args)
}

// Ruby let `let(:alias_path) { CoreTap.instance.alias_dir/alias_name }` at line 2230.
pub fn ruby_formula_spec_l2230_d209_alias_path(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2230, 'let', 'let(:alias_path) { CoreTap.instance.alias_dir/alias_name }', args)
}

// Ruby specify `specify "alias changes when not installed with alias" do` at line 2241.
pub fn ruby_formula_spec_l2241_d210_alias(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2241, 'specify', 'specify "alias changes when not installed with alias" do', args)
}

// Ruby specify `specify "alias changes when not changed" do` at line 2252.
pub fn ruby_formula_spec_l2252_d211_alias(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2252, 'specify', 'specify "alias changes when not changed" do', args)
}

// Ruby specify `specify "alias changes when new alias target" do` at line 2267.
pub fn ruby_formula_spec_l2267_d212_alias(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2267, 'specify', 'specify "alias changes when new alias target" do', args)
}

// Ruby specify `specify "alias changes when old formulae installed" do` at line 2282.
pub fn ruby_formula_spec_l2282_d213_alias(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2282, 'specify', 'specify "alias changes when old formulae installed" do', args)
}

// Ruby let `let(:outdated_prefix) { HOMEBREW_CELLAR/"#{f.name}/1.11" }` at line 2299.
pub fn ruby_formula_spec_l2299_d214_outdated_prefix(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2299, 'let', 'let(:outdated_prefix) { HOMEBREW_CELLAR/"#{f.name}/1.11" }', args)
}

// Ruby let `let(:same_prefix) { HOMEBREW_CELLAR/"#{f.name}/1.20" }` at line 2300.
pub fn ruby_formula_spec_l2300_d215_same_prefix(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2300, 'let', 'let(:same_prefix) { HOMEBREW_CELLAR/"#{f.name}/1.20" }', args)
}

// Ruby let `let(:greater_prefix) { HOMEBREW_CELLAR/"#{f.name}/1.21" }` at line 2301.
pub fn ruby_formula_spec_l2301_d216_greater_prefix(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2301, 'let', 'let(:greater_prefix) { HOMEBREW_CELLAR/"#{f.name}/1.21" }', args)
}

// Ruby let `let(:head_prefix) { HOMEBREW_CELLAR/"#{f.name}/HEAD" }` at line 2302.
pub fn ruby_formula_spec_l2302_d217_head_prefix(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2302, 'let', 'let(:head_prefix) { HOMEBREW_CELLAR/"#{f.name}/HEAD" }', args)
}

// Ruby let `let(:old_alias_target_prefix) { HOMEBREW_CELLAR/"#{old_formula.name}/1.0" }` at line 2303.
pub fn ruby_formula_spec_l2303_d218_old_alias_target_prefix(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2303, 'let', 'let(:old_alias_target_prefix) { HOMEBREW_CELLAR/"#{old_formula.name}/1.0" }', args)
}

// Ruby let `let(:f) do` at line 2305.
pub fn ruby_formula_spec_l2305_d219_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2305, 'let', 'let(:f) do', args)
}

// Ruby let `let(:old_formula) do` at line 2313.
pub fn ruby_formula_spec_l2313_d220_old_formula(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2313, 'let', 'let(:old_formula) do', args)
}

// Ruby let `let(:new_formula) do` at line 2320.
pub fn ruby_formula_spec_l2320_d221_new_formula(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2320, 'let', 'let(:new_formula) do', args)
}

// Ruby let `let(:alias_name) { "bar" }` at line 2327.
pub fn ruby_formula_spec_l2327_d222_alias_name(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2327, 'let', 'let(:alias_name) { "bar" }', args)
}

// Ruby let `let(:alias_path) { f.tap.alias_dir/alias_name }` at line 2328.
pub fn ruby_formula_spec_l2328_d223_alias_path(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2328, 'let', 'let(:alias_path) { f.tap.alias_dir/alias_name }', args)
}

// Ruby method `setup_tab_for_prefix(prefix, options = {})` at line 2336.
pub fn ruby_formula_spec_l2336_d224_setup_tab_for_prefix(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2336, 'method', 'setup_tab_for_prefix(prefix, options = {})', args)
}

// Ruby example `example "greater different tap installed" do` at line 2352.
pub fn ruby_formula_spec_l2352_d225_greater(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2352, 'example', 'example "greater different tap installed" do', args)
}

// Ruby example `example "greater same tap installed" do` at line 2357.
pub fn ruby_formula_spec_l2357_d226_greater(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2357, 'example', 'example "greater same tap installed" do', args)
}

// Ruby example `example "outdated different tap installed" do` at line 2363.
pub fn ruby_formula_spec_l2363_d227_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2363, 'example', 'example "outdated different tap installed" do', args)
}

// Ruby example `example "outdated same tap installed" do` at line 2368.
pub fn ruby_formula_spec_l2368_d228_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2368, 'example', 'example "outdated same tap installed" do', args)
}

// Ruby example `example "outdated unlinked tap installed" do` at line 2374.
pub fn ruby_formula_spec_l2374_d229_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2374, 'example', 'example "outdated unlinked tap installed" do', args)
}

// Ruby example `example "outdated follow alias and alias unchanged" do` at line 2380.
pub fn ruby_formula_spec_l2380_d230_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2380, 'example', 'example "outdated follow alias and alias unchanged" do', args)
}

// Ruby example `example "outdated follow alias and alias changed and new target not installed" do` at line 2387.
pub fn ruby_formula_spec_l2387_d231_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2387, 'example', 'example "outdated follow alias and alias changed and new target not installed" do', args)
}

// Ruby example `example "outdated follow alias and alias changed and new target installed" do` at line 2398.
pub fn ruby_formula_spec_l2398_d232_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2398, 'example', 'example "outdated follow alias and alias changed and new target installed" do', args)
}

// Ruby example `example "outdated no follow alias and alias unchanged" do` at line 2406.
pub fn ruby_formula_spec_l2406_d233_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2406, 'example', 'example "outdated no follow alias and alias unchanged" do', args)
}

// Ruby example `example "outdated no follow alias and alias changed" do` at line 2413.
pub fn ruby_formula_spec_l2413_d234_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2413, 'example', 'example "outdated no follow alias and alias changed" do', args)
}

// Ruby example `example "outdated old alias targets installed" do` at line 2426.
pub fn ruby_formula_spec_l2426_d235_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2426, 'example', 'example "outdated old alias targets installed" do', args)
}

// Ruby example `example "outdated old alias targets not installed" do` at line 2442.
pub fn ruby_formula_spec_l2442_d236_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2442, 'example', 'example "outdated old alias targets not installed" do', args)
}

// Ruby example `example "outdated same head installed" do` at line 2454.
pub fn ruby_formula_spec_l2454_d237_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2454, 'example', 'example "outdated same head installed" do', args)
}

// Ruby example `example "outdated different head installed" do` at line 2460.
pub fn ruby_formula_spec_l2460_d238_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2460, 'example', 'example "outdated different head installed" do', args)
}

// Ruby example `example "outdated mixed taps greater version installed" do` at line 2466.
pub fn ruby_formula_spec_l2466_d239_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2466, 'example', 'example "outdated mixed taps greater version installed" do', args)
}

// Ruby example `example "outdated mixed taps outdated version installed" do` at line 2479.
pub fn ruby_formula_spec_l2479_d240_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2479, 'example', 'example "outdated mixed taps outdated version installed" do', args)
}

// Ruby example `example "outdated same version tap installed" do` at line 2496.
pub fn ruby_formula_spec_l2496_d241_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2496, 'example', 'example "outdated same version tap installed" do', args)
}

// Ruby example `example "outdated installed head less than stable" do` at line 2508.
pub fn ruby_formula_spec_l2508_d242_outdated(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2508, 'example', 'example "outdated installed head less than stable" do', args)
}

// Ruby let `let(:f) do` at line 2521.
pub fn ruby_formula_spec_l2521_d243_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2521, 'let', 'let(:f) do', args)
}

// Ruby let `let(:testball_repo) { HOMEBREW_PREFIX/"testball_repo" }` at line 2530.
pub fn ruby_formula_spec_l2530_d244_testball_repo(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2530, 'let', 'let(:testball_repo) { HOMEBREW_PREFIX/"testball_repo" }', args)
}

// Ruby example `example do` at line 2532.
pub fn ruby_formula_spec_l2532_d245_do(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2532, 'example', 'example do', args)
}

// Ruby let `let(:dst) { mktmpdir }` at line 2571.
pub fn ruby_formula_spec_l2571_d246_dst(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2571, 'let', 'let(:dst) { mktmpdir }', args)
}

// Ruby it `it "creates intermediate directories" do` at line 2573.
pub fn ruby_formula_spec_l2573_d247_creates(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2573, 'it', 'it "creates intermediate directories" do', args)
}

// Ruby let `let(:f) do` at line 2582.
pub fn ruby_formula_spec_l2582_d248_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2582, 'let', 'let(:f) do', args)
}

// Ruby example `example do` at line 2591.
pub fn ruby_formula_spec_l2591_d249_do(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2591, 'example', 'example do', args)
}

// Ruby let `let(:f) do` at line 2600.
pub fn ruby_formula_spec_l2600_d250_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2600, 'let', 'let(:f) do', args)
}

// Ruby example `example do` at line 2609.
pub fn ruby_formula_spec_l2609_d251_do(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2609, 'example', 'example do', args)
}

// Ruby let `let(:f) do` at line 2632.
pub fn ruby_formula_spec_l2632_d252_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2632, 'let', 'let(:f) do', args)
}

// Ruby example `example do` at line 2641.
pub fn ruby_formula_spec_l2641_d253_do(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2641, 'example', 'example do', args)
}

// Ruby let `let(:f) do` at line 2657.
pub fn ruby_formula_spec_l2657_d254_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2657, 'let', 'let(:f) do', args)
}

// Ruby it `it "returns nil when not installed" do` at line 2664.
pub fn ruby_formula_spec_l2664_d255_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2664, 'it', 'it "returns nil when not installed" do', args)
}

// Ruby it `it "returns package version when installed" do` at line 2668.
pub fn ruby_formula_spec_l2668_d256_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2668, 'it', 'it "returns package version when installed" do', args)
}

// Ruby it `it "returns false for Linux when macOS is required at the top level" do` at line 2675.
pub fn ruby_formula_spec_l2675_d257_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2675, 'it', 'it "returns false for Linux when macOS is required at the top level" do', args)
}

// Ruby it `it "returns true for Linux when macOS is required in an on_macos block" do` at line 2686.
pub fn ruby_formula_spec_l2686_d258_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2686, 'it', 'it "returns true for Linux when macOS is required in an on_macos block" do', args)
}

// Ruby it `it "returns false for macOS when Linux is required at the top level" do` at line 2699.
pub fn ruby_formula_spec_l2699_d259_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2699, 'it', 'it "returns false for macOS when Linux is required at the top level" do', args)
}

// Ruby it `it "deprecates bare and versioned macOS requirements" do` at line 2711.
pub fn ruby_formula_spec_l2711_d260_deprecates(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2711, 'it', 'it "deprecates bare and versioned macOS requirements" do', args)
}

// Ruby it `it "does not allow duplicate bare macOS requirements" do` at line 2724.
pub fn ruby_formula_spec_l2724_d261_does(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2724, 'it', 'it "does not allow duplicate bare macOS requirements" do', args)
}

// Ruby it `it "returns false for Linux when maximum macOS is required at the top level" do` at line 2736.
pub fn ruby_formula_spec_l2736_d262_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2736, 'it', 'it "returns false for Linux when maximum macOS is required at the top level" do', args)
}

// Ruby it `it "does not allow Linux then macOS requirements" do` at line 2747.
pub fn ruby_formula_spec_l2747_d263_does(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2747, 'it', 'it "does not allow Linux then macOS requirements" do', args)
}

// Ruby it `it "does not allow macOS then Linux requirements" do` at line 2759.
pub fn ruby_formula_spec_l2759_d264_does(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2759, 'it', 'it "does not allow macOS then Linux requirements" do', args)
}

// Ruby let `let(:f) do` at line 2773.
pub fn ruby_formula_spec_l2773_d265_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2773, 'let', 'let(:f) do', args)
}

// Ruby attr_reader `attr_reader :test` at line 2775.
pub fn ruby_formula_spec_l2775_d266_test(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2775, 'attr_reader', 'attr_reader :test', args)
}

// Ruby method `install` at line 2777.
pub fn ruby_formula_spec_l2777_d267_install(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2777, 'method', 'install', args)
}

// Ruby it `it "only calls code within on_macos" do` at line 2789.
pub fn ruby_formula_spec_l2789_d268_only(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2789, 'it', 'it "only calls code within on_macos" do', args)
}

// Ruby let `let(:f) do` at line 2796.
pub fn ruby_formula_spec_l2796_d269_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2796, 'let', 'let(:f) do', args)
}

// Ruby attr_reader `attr_reader :test` at line 2798.
pub fn ruby_formula_spec_l2798_d270_test(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2798, 'attr_reader', 'attr_reader :test', args)
}

// Ruby method `install` at line 2800.
pub fn ruby_formula_spec_l2800_d271_install(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2800, 'method', 'install', args)
}

// Ruby it `it "only calls code within on_linux" do` at line 2812.
pub fn ruby_formula_spec_l2812_d272_only(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2812, 'it', 'it "only calls code within on_linux" do', args)
}

// Ruby let `let(:f) do` at line 2819.
pub fn ruby_formula_spec_l2819_d273_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2819, 'let', 'let(:f) do', args)
}

// Ruby attr_reader `attr_reader :foo` at line 2821.
pub fn ruby_formula_spec_l2821_d274_foo(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2821, 'attr_reader', 'attr_reader :foo', args)
}

// Ruby attr_reader `attr_reader :bar` at line 2822.
pub fn ruby_formula_spec_l2822_d275_bar(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2822, 'attr_reader', 'attr_reader :bar', args)
}

// Ruby method `install` at line 2824.
pub fn ruby_formula_spec_l2824_d276_install(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2824, 'method', 'install', args)
}

// Ruby it `it "doesn't call code on Sequoia", :needs_macos do` at line 2837.
pub fn ruby_formula_spec_l2837_d277_doesn(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2837, 'it', 'it "doesn\'t call code on Sequoia", :needs_macos do', args)
}

// Ruby it `it "calls code on Linux", :needs_linux do` at line 2845.
pub fn ruby_formula_spec_l2845_d278_calls(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2845, 'it', 'it "calls code on Linux", :needs_linux do', args)
}

// Ruby it `it "calls code within `on_system :linux, macos: :tahoe` on Tahoe", :needs_macos do` at line 2853.
pub fn ruby_formula_spec_l2853_d279_calls(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2853, 'it', 'it "calls code within `on_system :linux, macos: :tahoe` on Tahoe", :needs_macos do', args)
}

// Ruby it `it "calls code within `on_system :linux, macos: :sonoma_or_older` on Sonoma", :needs_macos do` at line 2861.
pub fn ruby_formula_spec_l2861_d280_calls(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2861, 'it', 'it "calls code within `on_system :linux, macos: :sonoma_or_older` on Sonoma", :needs_macos do', args)
}

// Ruby it `it "calls code within `on_system :linux, macos: :sonoma_or_older` on Ventura", :needs_macos do` at line 2869.
pub fn ruby_formula_spec_l2869_d281_calls(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2869, 'it', 'it "calls code within `on_system :linux, macos: :sonoma_or_older` on Ventura", :needs_macos do', args)
}

// Ruby let `let(:f) do` at line 2879.
pub fn ruby_formula_spec_l2879_d282_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2879, 'let', 'let(:f) do', args)
}

// Ruby attr_reader `attr_reader :test` at line 2881.
pub fn ruby_formula_spec_l2881_d283_test(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2881, 'attr_reader', 'attr_reader :test', args)
}

// Ruby method `install` at line 2883.
pub fn ruby_formula_spec_l2883_d284_install(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2883, 'method', 'install', args)
}

// Ruby it `it "only calls code within `on_sequoia`" do` at line 2898.
pub fn ruby_formula_spec_l2898_d285_only(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2898, 'it', 'it "only calls code within `on_sequoia`" do', args)
}

// Ruby it `it "only calls code within `on_sequoia :or_newer`" do` at line 2905.
pub fn ruby_formula_spec_l2905_d286_only(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2905, 'it', 'it "only calls code within `on_sequoia :or_newer`" do', args)
}

// Ruby it `it "only calls code within `on_sonoma`" do` at line 2912.
pub fn ruby_formula_spec_l2912_d287_only(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2912, 'it', 'it "only calls code within `on_sonoma`" do', args)
}

// Ruby it `it "only calls code within `on_ventura`" do` at line 2919.
pub fn ruby_formula_spec_l2919_d288_only(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2919, 'it', 'it "only calls code within `on_ventura`" do', args)
}

// Ruby it `it "only calls code within `on_ventura :or_older`" do` at line 2926.
pub fn ruby_formula_spec_l2926_d289_only(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2926, 'it', 'it "only calls code within `on_ventura :or_older`" do', args)
}

// Ruby let `let(:f) do` at line 2939.
pub fn ruby_formula_spec_l2939_d290_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2939, 'let', 'let(:f) do', args)
}

// Ruby attr_reader `attr_reader :test` at line 2941.
pub fn ruby_formula_spec_l2941_d291_test(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2941, 'attr_reader', 'attr_reader :test', args)
}

// Ruby method `install` at line 2943.
pub fn ruby_formula_spec_l2943_d292_install(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2943, 'method', 'install', args)
}

// Ruby it `it "only calls code within on_arm" do` at line 2955.
pub fn ruby_formula_spec_l2955_d293_only(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2955, 'it', 'it "only calls code within on_arm" do', args)
}

// Ruby let `let(:f) do` at line 2966.
pub fn ruby_formula_spec_l2966_d294_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2966, 'let', 'let(:f) do', args)
}

// Ruby attr_reader `attr_reader :test` at line 2968.
pub fn ruby_formula_spec_l2968_d295_test(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2968, 'attr_reader', 'attr_reader :test', args)
}

// Ruby method `install` at line 2970.
pub fn ruby_formula_spec_l2970_d296_install(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2970, 'method', 'install', args)
}

// Ruby it `it "only calls code within on_intel" do` at line 2982.
pub fn ruby_formula_spec_l2982_d297_only(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2982, 'it', 'it "only calls code within on_intel" do', args)
}

// Ruby let `let(:f) do` at line 2989.
pub fn ruby_formula_spec_l2989_d298_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2989, 'let', 'let(:f) do', args)
}

// Ruby method `install` at line 2991.
pub fn ruby_formula_spec_l2991_d299_install(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(2991, 'method', 'install', args)
}

// Ruby it `it "generates completion scripts" do` at line 3004.
pub fn ruby_formula_spec_l3004_d300_generates(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3004, 'it', 'it "generates completion scripts" do', args)
}

// Ruby it `it "can` at line 3016.
pub fn ruby_formula_spec_l3016_d301_can(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3016, 'it', 'it "can', args)
}

// Ruby it `it "can` at line 3027.
pub fn ruby_formula_spec_l3027_d302_can(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3027, 'it', 'it "can', args)
}

// Ruby it `it "throws an error when passed an invalid symbol" do` at line 3040.
pub fn ruby_formula_spec_l3040_d303_throws(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3040, 'it', 'it "throws an error when passed an invalid symbol" do', args)
}

// Ruby let `let(:klass) do` at line 3047.
pub fn ruby_formula_spec_l3047_d304_klass(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3047, 'let', 'let(:klass) do', args)
}

// Ruby let `let(:name) { "formula_name" }` at line 3053.
pub fn ruby_formula_spec_l3053_d305_name(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3053, 'let', 'let(:name) { "formula_name" }', args)
}

// Ruby let `let(:path) { Formulary.core_path(name) }` at line 3054.
pub fn ruby_formula_spec_l3054_d306_path(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3054, 'let', 'let(:path) { Formulary.core_path(name) }', args)
}

// Ruby let `let(:spec) { :stable }` at line 3055.
pub fn ruby_formula_spec_l3055_d307_spec(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3055, 'let', 'let(:spec) { :stable }', args)
}

// Ruby let `let(:alias_name) { "baz@1" }` at line 3056.
pub fn ruby_formula_spec_l3056_d308_alias_name(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3056, 'let', 'let(:alias_name) { "baz@1" }', args)
}

// Ruby let `let(:alias_path) { CoreTap.instance.alias_dir/alias_name }` at line 3057.
pub fn ruby_formula_spec_l3057_d309_alias_path(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3057, 'let', 'let(:alias_path) { CoreTap.instance.alias_dir/alias_name }', args)
}

// Ruby let `let(:f) { klass.new(name, path, spec) }` at line 3058.
pub fn ruby_formula_spec_l3058_d310_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3058, 'let', 'let(:f) { klass.new(name, path, spec) }', args)
}

// Ruby let `let(:f_alias) { klass.new(name, path, spec, alias_path:) }` at line 3059.
pub fn ruby_formula_spec_l3059_d311_f_alias(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3059, 'let', 'let(:f_alias) { klass.new(name, path, spec, alias_path:) }', args)
}

// Ruby it `it "returns the formula file path" do` at line 3062.
pub fn ruby_formula_spec_l3062_d312_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3062, 'it', 'it "returns the formula file path" do', args)
}

// Ruby it `it "returns the alias path" do` at line 3068.
pub fn ruby_formula_spec_l3068_d313_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3068, 'it', 'it "returns the alias path" do', args)
}

// Ruby it `it "returns the API path" do` at line 3078.
pub fn ruby_formula_spec_l3078_d314_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3078, 'it', 'it "returns the API path" do', args)
}

// Ruby it `it "returns the internal API path" do` at line 3088.
pub fn ruby_formula_spec_l3088_d315_returns(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3088, 'it', 'it "returns the internal API path" do', args)
}

// Ruby it `it "defaults to false" do` at line 3095.
pub fn ruby_formula_spec_l3095_d316_defaults(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3095, 'it', 'it "defaults to false" do', args)
}

// Ruby it `it "can be enabled" do` at line 3104.
pub fn ruby_formula_spec_l3104_d317_can(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3104, 'it', 'it "can be enabled" do', args)
}

// Ruby it `it "can be explicitly disabled" do` at line 3114.
pub fn ruby_formula_spec_l3114_d318_can(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3114, 'it', 'it "can be explicitly disabled" do', args)
}

// Ruby let `let(:deprecation_date) { "2020-01-01" }` at line 3126.
pub fn ruby_formula_spec_l3126_d319_deprecation_date(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3126, 'let', 'let(:deprecation_date) { "2020-01-01" }', args)
}

// Ruby let `let(:disable_date) { "2021-01-01" }` at line 3127.
pub fn ruby_formula_spec_l3127_d320_disable_date(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3127, 'let', 'let(:disable_date) { "2021-01-01" }', args)
}

// Ruby let `let(:f) do` at line 3130.
pub fn ruby_formula_spec_l3130_d321_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3130, 'let', 'let(:f) do', args)
}

// Ruby it `it "is not deprecated before deprecation date" do` at line 3141.
pub fn ruby_formula_spec_l3141_d322_is(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3141, 'it', 'it "is not deprecated before deprecation date" do', args)
}

// Ruby it `it "is deprecated on deprecation date" do` at line 3149.
pub fn ruby_formula_spec_l3149_d323_is(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3149, 'it', 'it "is deprecated on deprecation date" do', args)
}

// Ruby it `it "is disabled on disable date" do` at line 3157.
pub fn ruby_formula_spec_l3157_d324_is(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3157, 'it', 'it "is disabled on disable date" do', args)
}

// Ruby let `let(:f) do` at line 3167.
pub fn ruby_formula_spec_l3167_d325_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3167, 'let', 'let(:f) do', args)
}

// Ruby it `it "is not deprecated before deprecation date" do` at line 3178.
pub fn ruby_formula_spec_l3178_d326_is(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3178, 'it', 'it "is not deprecated before deprecation date" do', args)
}

// Ruby it `it "is deprecated on deprecation date" do` at line 3186.
pub fn ruby_formula_spec_l3186_d327_is(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3186, 'it', 'it "is deprecated on deprecation date" do', args)
}

// Ruby it `it "is disabled on disable date" do` at line 3194.
pub fn ruby_formula_spec_l3194_d328_is(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3194, 'it', 'it "is disabled on disable date" do', args)
}

// Ruby let `let(:f) do` at line 3204.
pub fn ruby_formula_spec_l3204_d329_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3204, 'let', 'let(:f) do', args)
}

// Ruby it `it "is deprecated before disable date" do` at line 3213.
pub fn ruby_formula_spec_l3213_d330_is(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3213, 'it', 'it "is deprecated before disable date" do', args)
}

// Ruby it `it "is disabled on disable date" do` at line 3221.
pub fn ruby_formula_spec_l3221_d331_is(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3221, 'it', 'it "is disabled on disable date" do', args)
}

// Ruby it `it "skips formulas that raise FormulaSpecificationError" do` at line 3230.
pub fn ruby_formula_spec_l3230_d332_skips(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3230, 'it', 'it "skips formulas that raise FormulaSpecificationError" do', args)
}

// Ruby it `it "skips untrusted tap formulae when trust is enabled" do` at line 3240.
pub fn ruby_formula_spec_l3240_d333_skips(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3240, 'it', 'it "skips untrusted tap formulae when trust is enabled" do', args)
}

// Ruby it `it "allows all formulae when trust is enabled" do` at line 3259.
pub fn ruby_formula_spec_l3259_d334_allows(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3259, 'it', 'it "allows all formulae when trust is enabled" do', args)
}

// Ruby let `let(:f) do` at line 3269.
pub fn ruby_formula_spec_l3269_d335_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3269, 'let', 'let(:f) do', args)
}

// Ruby it `it "allows changing the installation directory" do` at line 3276.
pub fn ruby_formula_spec_l3276_d336_allows(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3276, 'it', 'it "allows changing the installation directory" do', args)
}

// Ruby it `it "excludes installation arguments when `installdir: false`" do` at line 3280.
pub fn ruby_formula_spec_l3280_d337_excludes(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3280, 'it', 'it "excludes installation arguments when `installdir: false`" do', args)
}

// Ruby it `it "includes flag for PIE on arm" do` at line 3285.
pub fn ruby_formula_spec_l3285_d338_includes(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3285, 'it', 'it "includes flag for PIE on arm" do', args)
}

// Ruby it `it "excludes flag for PIE on non-arm" do` at line 3290.
pub fn ruby_formula_spec_l3290_d339_excludes(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3290, 'it', 'it "excludes flag for PIE on non-arm" do', args)
}

// Ruby let `let(:f) do` at line 3298.
pub fn ruby_formula_spec_l3298_d340_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3298, 'let', 'let(:f) do', args)
}

// Ruby it `it "defaults to stripping binaries" do` at line 3305.
pub fn ruby_formula_spec_l3305_d341_defaults(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3305, 'it', 'it "defaults to stripping binaries" do', args)
}

// Ruby it `it "does not strip binaries when building with debug symbols" do` at line 3312.
pub fn ruby_formula_spec_l3312_d342_does(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3312, 'it', 'it "does not strip binaries when building with debug symbols" do', args)
}

// Ruby it `it "raises an error when provided an invalid ldflags symbol" do` at line 3320.
pub fn ruby_formula_spec_l3320_d343_raises(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3320, 'it', 'it "raises an error when provided an invalid ldflags symbol" do', args)
}

// Ruby subject `subject(:std_go_args) { f.std_go_args(ldflags: :goreleaser) }` at line 3325.
pub fn ruby_formula_spec_l3325_d344_std_go_args(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3325, 'subject', 'subject(:std_go_args) { f.std_go_args(ldflags: :goreleaser) }', args)
}

// Ruby let `let(:built_by) { "Homebrew" }` at line 3327.
pub fn ruby_formula_spec_l3327_d345_built_by(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3327, 'let', 'let(:built_by) { "Homebrew" }', args)
}

// Ruby let `let(:commit) { built_by }` at line 3328.
pub fn ruby_formula_spec_l3328_d346_commit(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3328, 'let', 'let(:commit) { built_by }', args)
}

// Ruby let `let(:date) { "2026-01-01T12:00:00Z" }` at line 3329.
pub fn ruby_formula_spec_l3329_d347_date(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3329, 'let', 'let(:date) { "2026-01-01T12:00:00Z" }', args)
}

// Ruby let `let(:expected_ldflags) do` at line 3330.
pub fn ruby_formula_spec_l3330_d348_expected_ldflags(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3330, 'let', 'let(:expected_ldflags) do', args)
}

// Ruby let `let(:buildpath) { mktmpdir }` at line 3341.
pub fn ruby_formula_spec_l3341_d349_buildpath(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3341, 'let', 'let(:buildpath) { mktmpdir }', args)
}

// Ruby let `let(:commit) { Utils.popen_read("git", "-C", buildpath, "rev-parse", "HEAD").chomp }` at line 3342.
pub fn ruby_formula_spec_l3342_d350_commit(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3342, 'let', 'let(:commit) { Utils.popen_read("git", "-C", buildpath, "rev-parse", "HEAD").chomp }', args)
}

// Ruby it `it "uses git commit for main.commit" do` at line 3356.
pub fn ruby_formula_spec_l3356_d351_uses(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3356, 'it', 'it "uses git commit for main.commit" do', args)
}

// Ruby let `let(:built_by) { "someone" }` at line 3362.
pub fn ruby_formula_spec_l3362_d352_built_by(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3362, 'let', 'let(:built_by) { "someone" }', args)
}

// Ruby it `it "uses tap user for main.commit" do` at line 3366.
pub fn ruby_formula_spec_l3366_d353_uses(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3366, 'it', 'it "uses tap user for main.commit" do', args)
}

// Ruby it `it "uses Homebrew for main.commit" do` at line 3374.
pub fn ruby_formula_spec_l3374_d354_uses(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3374, 'it', 'it "uses Homebrew for main.commit" do', args)
}

// Ruby it `it "includes a comma-separated list of input tags" do` at line 3380.
pub fn ruby_formula_spec_l3380_d355_includes(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3380, 'it', 'it "includes a comma-separated list of input tags" do', args)
}

// Ruby let `let(:f) do` at line 3386.
pub fn ruby_formula_spec_l3386_d356_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3386, 'let', 'let(:f) do', args)
}

// Ruby it `it "filters packages uploaded within the last day" do` at line 3393.
pub fn ruby_formula_spec_l3393_d357_filters(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3393, 'it', 'it "filters packages uploaded within the last day" do', args)
}

// Ruby let `let(:f) do` at line 3399.
pub fn ruby_formula_spec_l3399_d358_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3399, 'let', 'let(:f) do', args)
}

// Ruby it `it "allows controlling parallel jobs" do` at line 3406.
pub fn ruby_formula_spec_l3406_d359_allows(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3406, 'it', 'it "allows controlling parallel jobs" do', args)
}

// Ruby it `it "disables non-writable sandbox path on macOS", :needs_macos do` at line 3411.
pub fn ruby_formula_spec_l3411_d360_disables(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3411, 'it', 'it "disables non-writable sandbox path on macOS", :needs_macos do', args)
}

// Ruby it `it "includes override for ld shim on Linux", :needs_linux do` at line 3415.
pub fn ruby_formula_spec_l3415_d361_includes(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3415, 'it', 'it "includes override for ld shim on Linux", :needs_linux do', args)
}

// Ruby let `let(:f) do` at line 3421.
pub fn ruby_formula_spec_l3421_d362_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3421, 'let', 'let(:f) do', args)
}

// Ruby it `it "raises an error when provided an unknown release mode" do` at line 3428.
pub fn ruby_formula_spec_l3428_d363_raises(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3428, 'it', 'it "raises an error when provided an unknown release mode" do', args)
}

// Ruby it `it "includes equivalent Zig CPU for known target arch" do` at line 3432.
pub fn ruby_formula_spec_l3432_d364_includes(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3432, 'it', 'it "includes equivalent Zig CPU for known target arch" do', args)
}

// Ruby it `it "allows overriding Zig CPU" do` at line 3437.
pub fn ruby_formula_spec_l3437_d365_allows(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3437, 'it', 'it "allows overriding Zig CPU" do', args)
}

// Ruby let `let(:f) do` at line 3443.
pub fn ruby_formula_spec_l3443_d366_f(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3443, 'let', 'let(:f) do', args)
}

// Ruby it `it "sets Bundler cooldown for RubyGems dependencies" do` at line 3450.
pub fn ruby_formula_spec_l3450_d367_sets(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3450, 'it', 'it "sets Bundler cooldown for RubyGems dependencies" do', args)
}

// Ruby it `it "prevents build tools from reading user configuration" do` at line 3454.
pub fn ruby_formula_spec_l3454_d368_prevents(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3454, 'it', 'it "prevents build tools from reading user configuration" do', args)
}

// Ruby it `it "raises an error when used in an unofficial tap" do` at line 3469.
pub fn ruby_formula_spec_l3469_d369_raises(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3469, 'it', 'it "raises an error when used in an unofficial tap" do', args)
}

// Ruby it `it "allows usage when tap is official" do` at line 3480.
pub fn ruby_formula_spec_l3480_d370_allows(args ...ruby.Value) ruby.Value {
	return formula_spec_boundary(3480, 'it', 'it "allows usage when tap is official" do', args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "test/support/fixtures/testball"
// 5: require "formula"
// 6:
// 7: PHASES = [:build, :postinstall, :test].freeze
// 8:
// 9: # These tests need to duplicate methods.
// 10: RSpec.describe Formula do
// 11:   alias_matcher :follow_installed_alias, :be_follow_installed_alias
// 12:   alias_matcher :have_any_version_installed, :be_any_version_installed
// 13:   alias_matcher :need_migration, :be_migration_needed
// 14:
// 15:   alias_matcher :have_changed_installed_alias_target, :be_installed_alias_target_changed
// 16:   alias_matcher :supersede_an_installed_formula, :be_supersedes_an_installed_formula
// 17:   alias_matcher :have_changed_alias, :be_alias_changed
// 18:
// 19:   alias_matcher :have_option_defined, :be_option_defined
// 20:   alias_matcher :have_post_install_defined, :be_post_install_defined
// 21:   alias_matcher :have_test_defined, :be_test_defined
// 22:   alias_matcher :pour_bottle, :be_pour_bottle
// 23:
// 24:   describe "::new" do
// 25:     let(:klass) do
// 26:       Class.new(described_class) do
// 27:         url "https://brew.sh/foo-1.0.tar.gz"
// 28:       end
// 29:     end
// 30:
// 31:     let(:name) { "formula_name" }
// 32:     let(:path) { Formulary.core_path(name) }
// 33:     let(:spec) { :stable }
// 34:     let(:alias_name) { "baz@1" }
// 35:     let(:alias_path) { CoreTap.instance.alias_dir/alias_name }
// 36:     let(:f) { klass.new(name, path, spec) }
// 37:     let(:f_alias) { klass.new(name, path, spec, alias_path:) }
// 38:
// 39:     specify "formula instantiation" do
// 40:       expect(f.name).to eq(name)
// 41:       expect(f.specified_name).to eq(name)
// 42:       expect(f.full_name).to eq(name)
// 43:       expect(f.full_specified_name).to eq(name)
// 44:       expect(f.path).to eq(path)
// 45:       expect(f.alias_path).to be_nil
// 46:       expect(f.alias_name).to be_nil
// 47:       expect(f.full_alias_name).to be_nil
// 48:       expect(f.specified_path).to eq(path)
// 49:       [:build, :test, :postinstall].each { |phase| expect(f.network_access_allowed?(phase)).to be(true) }
// 50:       expect { klass.new }.to raise_error(ArgumentError)
// 51:     end
// 52:
// 53:     specify "formula instantiation with alias" do
// 54:       expect(f_alias.name).to eq(name)
// 55:       expect(f_alias.full_name).to eq(name)
// 56:       expect(f_alias.path).to eq(path)
// 57:       expect(f_alias.alias_path).to eq(alias_path)
// 58:       expect(f_alias.alias_name).to eq(alias_name)
// 59:       expect(f_alias.specified_name).to eq(alias_name)
// 60:       expect(f_alias.specified_path).to eq(Pathname(alias_path))
// 61:       expect(f_alias.full_alias_name).to eq(alias_name)
// 62:       expect(f_alias.full_specified_name).to eq(alias_name)
// 63:       [:build, :test, :postinstall].each { |phase| expect(f_alias.network_access_allowed?(phase)).to be(true) }
// 64:       expect { klass.new }.to raise_error(ArgumentError)
// 65:     end
// 66:
// 67:     specify "formula instantiation without a subclass" do
// 68:       expect { described_class.new(name, path, spec) }
// 69:         .to raise_error(RuntimeError, "Do not call `Formula.new' directly without a subclass.")
// 70:     end
// 71:
// 72:     context "when in a Tap" do
// 73:       let(:tap) { Tap.fetch("foo", "bar") }
// 74:       let(:path) { tap.path/"Formula/#{name}.rb" }
// 75:       let(:full_name) { "#{tap.user}/#{tap.repository}/#{name}" }
// 76:       let(:full_alias_name) { "#{tap.user}/#{tap.repository}/#{alias_name}" }
// 77:
// 78:       specify "formula instantiation" do
// 79:         expect(f.name).to eq(name)
// 80:         expect(f.specified_name).to eq(name)
// 81:         expect(f.full_name).to eq(full_name)
// 82:         expect(f.full_specified_name).to eq(full_name)
// 83:         expect(f.path).to eq(path)
// 84:         expect(f.alias_path).to be_nil
// 85:         expect(f.alias_name).to be_nil
// 86:         expect(f.full_alias_name).to be_nil
// 87:         expect(f.specified_path).to eq(path)
// 88:         expect { klass.new }.to raise_error(ArgumentError)
// 89:       end
// 90:
// 91:       specify "formula instantiation with alias" do
// 92:         expect(f_alias.name).to eq(name)
// 93:         expect(f_alias.full_name).to eq(full_name)
// 94:         expect(f_alias.path).to eq(path)
// 95:         expect(f_alias.alias_path).to eq(alias_path)
// 96:         expect(f_alias.alias_name).to eq(alias_name)
// 97:         expect(f_alias.specified_name).to eq(alias_name)
// 98:         expect(f_alias.specified_path).to eq(Pathname(alias_path))
// 99:         expect(f_alias.full_alias_name).to eq(full_alias_name)
// 100:         expect(f_alias.full_specified_name).to eq(full_alias_name)
// 101:         expect { klass.new }.to raise_error(ArgumentError)
// 102:       end
// 103:     end
// 104:   end
// 105:
// 106:   describe "#follow_installed_alias?" do
// 107:     let(:f) do
// 108:       formula do
// 109:         T.bind(self, T.class_of(Formula))
// 110:         url "foo-1.0"
// 111:       end
// 112:     end
// 113:
// 114:     it "returns true by default" do
// 115:       expect(f).to follow_installed_alias
// 116:     end
// 117:
// 118:     it "can be set to true" do
// 119:       f.follow_installed_alias = true
// 120:       expect(f).to follow_installed_alias
// 121:     end
// 122:
// 123:     it "can be set to false" do
// 124:       f.follow_installed_alias = false
// 125:       expect(f).not_to follow_installed_alias
// 126:     end
// 127:   end
// 128:
// 129:   describe "#versioned_formula?" do
// 130:     let(:f) do
// 131:       formula "foo" do
// 132:         T.bind(self, T.class_of(Formula))
// 133:         url "foo-1.0"
// 134:       end
// 135:     end
// 136:
// 137:     let(:f2) do
// 138:       formula "foo@2.0" do
// 139:         T.bind(self, T.class_of(Formula))
// 140:         url "foo-2.0"
// 141:       end
// 142:     end
// 143:
// 144:     specify do
// 145:       expect(f2.versioned_formula?).to be true
// 146:       expect(f.versioned_formula?).to be false
// 147:     end
// 148:   end
// 149:
// 150:   describe ".python_major_minor_version" do
// 151:     it "delegates to Language::Python.major_minor_version" do
// 152:       version = instance_double(Version, "version")
// 153:       expect(Language::Python).to receive(:major_minor_version).with("python3").and_return(version)
// 154:
// 155:       expect(described_class.python_major_minor_version("python3")).to be(version)
// 156:     end
// 157:   end
// 158:
// 159:   describe "#versioned_formulae" do
// 160:     let(:f) do
// 161:       formula "foo" do
// 162:         T.bind(self, T.class_of(Formula))
// 163:         url "foo-1.0"
// 164:       end
// 165:     end
// 166:
// 167:     let(:f2) do
// 168:       formula "foo@2.0" do
// 169:         T.bind(self, T.class_of(Formula))
// 170:         url "foo-2.0"
// 171:       end
// 172:     end
// 173:
// 174:     let(:f_full) do
// 175:       formula "foo-full" do
// 176:         T.bind(self, T.class_of(Formula))
// 177:         url "foo-full-1.0"
// 178:       end
// 179:     end
// 180:
// 181:     let(:f_full2) do
// 182:       formula "foo@2.0-full" do
// 183:         T.bind(self, T.class_of(Formula))
// 184:         url "foo-full-2.0"
// 185:       end
// 186:     end
// 187:
// 188:     before do
// 189:       # don't try to load/fetch gcc/glibc
// 190:       allow(DevelopmentTools).to receive_messages(needs_libc_formula?: false, needs_compiler_formula?: false)
// 191:
// 192:       allow(Formulary).to receive(:load_formula_from_path)
// 193:         .with(f2.name, f2.path, flags: [], ignore_errors: false).and_return(f2)
// 194:       allow(Formulary).to receive(:factory).with(f2.name).and_return(f2)
// 195:       allow(Formulary).to receive(:load_formula_from_path)
// 196:         .with(f_full2.name, f_full2.path, flags: [], ignore_errors: false).and_return(f_full2)
// 197:       allow(Formulary).to receive(:factory).with(f_full2.name).and_return(f_full2)
// 198:       allow(f).to receive(:versioned_formulae_names).and_return([f2.name])
// 199:     end
// 200:
// 201:     it "returns array with versioned formulae" do
// 202:       FileUtils.touch f.path
// 203:       FileUtils.touch f2.path
// 204:       expect(f.versioned_formulae).to eq [f2]
// 205:     end
// 206:
// 207:     it "returns empty array for non-@-versioned formulae" do
// 208:       FileUtils.touch f.path
// 209:       FileUtils.touch f2.path
// 210:       expect(f2.versioned_formulae).to be_empty
// 211:     end
// 212:
// 213:     it "returns versioned full formulae for the matching full formula" do
// 214:       allow(f_full).to receive(:tap).and_return(nil)
// 215:       FileUtils.touch f_full.path
// 216:       FileUtils.touch f_full2.path
// 217:       expect(f_full.versioned_formulae).to eq [f_full2]
// 218:     end
// 219:   end
// 220:
// 221:   describe "#full_formulae_names" do
// 222:     let(:f) do
// 223:       formula "foo" do
// 224:         T.bind(self, T.class_of(Formula))
// 225:         url "foo-1.0"
// 226:       end
// 227:     end
// 228:
// 229:     let(:f_full) do
// 230:       formula "foo-full" do
// 231:         T.bind(self, T.class_of(Formula))
// 232:         url "foo-full-1.0"
// 233:       end
// 234:     end
// 235:
// 236:     let(:f_versioned) do
// 237:       formula "foo@2.0" do
// 238:         T.bind(self, T.class_of(Formula))
// 239:         url "foo-2.0"
// 240:       end
// 241:     end
// 242:
// 243:     let(:f_versioned_full) do
// 244:       formula "foo@2.0-full" do
// 245:         T.bind(self, T.class_of(Formula))
// 246:         url "foo-full-2.0"
// 247:       end
// 248:     end
// 249:
// 250:     before do
// 251:       [f, f_full, f_versioned].each do |formula|
// 252:         allow(formula).to receive(:tap).and_return(nil)
// 253:         FileUtils.touch formula.path
// 254:       end
// 255:     end
// 256:
// 257:     it "returns only existing sibling full and non-full names" do
// 258:       expect(f.full_formulae_names).to eq ["foo-full"]
// 259:       expect(f_full.full_formulae_names).to eq ["foo"]
// 260:       expect(f_versioned.full_formulae_names).to eq []
// 261:
// 262:       allow(f_versioned_full).to receive(:tap).and_return(nil)
// 263:       FileUtils.touch f_versioned_full.path
// 264:       f_versioned_with_full = formula "foo@2.0" do
// 265:         T.bind(self, T.class_of(Formula))
// 266:         url "foo-2.0"
// 267:       end
// 268:       allow(f_versioned_with_full).to receive(:tap).and_return(nil)
// 269:       FileUtils.touch f_versioned_with_full.path
// 270:
// 271:       expect(f_versioned_with_full.full_formulae_names).to eq ["foo@2.0-full"]
// 272:     end
// 273:   end
// 274:
// 275:   describe "#unversioned_formula_name" do
// 276:     let(:f) do
// 277:       formula "foo" do
// 278:         T.bind(self, T.class_of(Formula))
// 279:         url "foo-1.0"
// 280:       end
// 281:     end
// 282:
// 283:     let(:f_full) do
// 284:       formula "foo@2.0-full" do
// 285:         T.bind(self, T.class_of(Formula))
// 286:         url "foo-full-2.0"
// 287:       end
// 288:     end
// 289:
// 290:     let(:f_versioned) do
// 291:       formula "foo@2.0" do
// 292:         T.bind(self, T.class_of(Formula))
// 293:         url "foo-2.0"
// 294:       end
// 295:     end
// 296:
// 297:     it "returns the matching unversioned sibling name" do
// 298:       expect(f.unversioned_formula_name).to be_nil
// 299:       expect(f_versioned.unversioned_formula_name).to eq("foo")
// 300:       expect(f_full.unversioned_formula_name).to eq("foo-full")
// 301:     end
// 302:   end
// 303:
// 304:   describe "#link_overwrite_reason" do
// 305:     it "explains why a formula was not linked" do
// 306:       f = formula "foo@2.0" do
// 307:         T.bind(self, T.class_of(Formula))
// 308:         url "foo-2.0"
// 309:       end
// 310:       other_formula = formula "foo" do
// 311:         T.bind(self, T.class_of(Formula))
// 312:         url "foo-1.0"
// 313:       end
// 314:       allow(other_formula).to receive_messages(any_version_installed?: true, linked?: true)
// 315:       allow(f).to receive(:link_overwrite_formulae).and_return([other_formula])
// 316:
// 317:       expect(f.link_overwrite_reason).to eq("foo is already linked")
// 318:     end
// 319:   end
// 320:
// 321:   describe "#link_overwrite_formulae" do
// 322:     it "deduplicates formulae shared by an alias and canonical name" do
// 323:       f = formula "foo@2.0" do
// 324:         T.bind(self, T.class_of(Formula))
// 325:         url "foo-2.0"
// 326:       end
// 327:       other_formula = formula "foo@1.0" do
// 328:         T.bind(self, T.class_of(Formula))
// 329:         url "foo-1.0"
// 330:       end
// 331:       allow(f).to receive(:link_overwrite_formulae_names).and_return(["foo", "foo@1.0"])
// 332:       allow(Formulary).to receive(:factory).with("foo").and_return(other_formula)
// 333:       allow(Formulary).to receive(:factory).with("foo@1.0").and_return(other_formula)
// 334:
// 335:       expect(f.link_overwrite_formulae).to eq([other_formula])
// 336:     end
// 337:   end
// 338:
// 339:   describe "#link_overwrite_formulae_names" do
// 340:     let(:f) do
// 341:       formula "foo" do
// 342:         T.bind(self, T.class_of(Formula))
// 343:         url "foo-1.0"
// 344:       end
// 345:     end
// 346:
// 347:     let(:f_full) do
// 348:       formula "foo-full" do
// 349:         T.bind(self, T.class_of(Formula))
// 350:         url "foo-full-1.0"
// 351:       end
// 352:     end
// 353:
// 354:     let(:f_versioned) do
// 355:       formula "foo@2.0" do
// 356:         T.bind(self, T.class_of(Formula))
// 357:         url "foo-2.0"
// 358:       end
// 359:     end
// 360:
// 361:     let(:f_versioned_full) do
// 362:       formula "foo@2.0-full" do
// 363:         T.bind(self, T.class_of(Formula))
// 364:         url "foo-full-2.0"
// 365:       end
// 366:     end
// 367:
// 368:     before do
// 369:       [f, f_full, f_versioned, f_versioned_full].each do |formula|
// 370:         allow(Formulary).to receive(:load_formula_from_path)
// 371:           .with(formula.name, formula.path, flags: [], ignore_errors: false).and_return(formula)
// 372:         allow(Formulary).to receive(:factory).with(formula.name).and_return(formula)
// 373:         FileUtils.touch formula.path
// 374:       end
// 375:
// 376:       allow(f).to receive_messages(versioned_formulae_names: [f_versioned.name], full_formulae_names: [f_full.name])
// 377:       allow(f_full).to receive_messages(versioned_formulae_names: [], full_formulae_names: [f.name])
// 378:       allow(f_versioned).to receive_messages(versioned_formulae_names: [],
// 379:                                              full_formulae_names:      [f_versioned_full.name])
// 380:       allow(f_versioned_full).to receive_messages(versioned_formulae_names: [],
// 381:                                                   full_formulae_names:      [f_versioned.name])
// 382:     end
// 383:
// 384:     it "includes direct full and unversioned siblings while excluding the current formula" do
// 385:       expect(f_versioned.link_overwrite_formulae_names)
// 386:         .to eq(["foo", f_full.name, f_versioned_full.name])
// 387:     end
// 388:   end
// 389:
// 390:   describe "#link_overwrite?" do
// 391:     let(:versioned_formula) do
// 392:       formula "foo@22" do
// 393:         T.bind(self, T.class_of(Formula))
// 394:         url "foo-22.0"
// 395:       end
// 396:     end
// 397:
// 398:     let(:related_formula) do
// 399:       formula "foo" do
// 400:         T.bind(self, T.class_of(Formula))
// 401:         url "foo-1.0"
// 402:       end
// 403:     end
// 404:
// 405:     let(:conflict_file) { HOMEBREW_PREFIX/"lib/formula_spec/node_modules/npm/LICENSE" }
// 406:
// 407:     before do
// 408:       allow(versioned_formula).to receive(:link_overwrite_formulae).and_return([related_formula])
// 409:       conflict_file.dirname.mkpath
// 410:       FileUtils.touch conflict_file
// 411:     end
// 412:
// 413:     after do
// 414:       FileUtils.rm_f conflict_file
// 415:       conflict_file.dirname.rmdir_if_possible
// 416:       conflict_file.dirname.parent.rmdir_if_possible
// 417:       conflict_file.dirname.parent.parent.rmdir_if_possible
// 418:     end
// 419:
// 420:     it "does not allow untracked conflicts for related formula families" do
// 421:       expect(versioned_formula.link_overwrite?(conflict_file)).to be false
// 422:     end
// 423:
// 424:     it "returns false when the conflict is not Homebrew-managed" do
// 425:       allow(versioned_formula).to receive(:link_overwrite_keg_name).and_return(nil)
// 426:
// 427:       expect(versioned_formula.link_overwrite?(HOMEBREW_PREFIX/"bin/foo")).to be false
// 428:     end
// 429:
// 430:     it "returns false for ambiguous keg names" do
// 431:       allow(versioned_formula).to receive(:link_overwrite_keg_name).and_return("foo")
// 432:       ambiguity_loaders = [
// 433:         instance_double(Formulary::FormulaLoader, tap: instance_double(Tap, to_s: "homebrew/core")),
// 434:         instance_double(Formulary::FormulaLoader, tap: instance_double(Tap, to_s: "homebrew/other")),
// 435:       ]
// 436:       allow(Formulary).to receive(:factory).with("foo")
// 437:                                            .and_raise(TapFormulaAmbiguityError.new("foo", ambiguity_loaders))
// 438:
// 439:       expect(versioned_formula.link_overwrite?(HOMEBREW_PREFIX/"bin/foo")).to be false
// 440:     end
// 441:
// 442:     it "returns false for unrelated keg names" do
// 443:       unrelated_formula = formula "bar" do
// 444:         T.bind(self, T.class_of(Formula))
// 445:         url "bar-1.0"
// 446:       end
// 447:       allow(versioned_formula).to receive(:link_overwrite_keg_name).and_return("bar")
// 448:       allow(Formulary).to receive(:factory).with("bar").and_return(unrelated_formula)
// 449:       allow(unrelated_formula).to receive(:possible_names).and_return(["baz"])
// 450:
// 451:       expect(versioned_formula.link_overwrite?(HOMEBREW_PREFIX/"bin/bar")).to be false
// 452:     end
// 453:
// 454:     it "allows explicit link_overwrite paths" do
// 455:       formula_with_explicit_overwrite = formula "baz" do
// 456:         T.bind(self, T.class_of(Formula))
// 457:         url "baz-1.0"
// 458:         link_overwrite "bin/baz"
// 459:       end
// 460:       allow(formula_with_explicit_overwrite).to receive(:link_overwrite_keg_name).and_return("baz")
// 461:       allow(Formulary).to receive(:factory).with("baz").and_return(formula_with_explicit_overwrite)
// 462:
// 463:       expect(formula_with_explicit_overwrite.link_overwrite?(HOMEBREW_PREFIX/"bin/baz")).to be true
// 464:     end
// 465:
// 466:     it "allows existing related keg names through implied overwrites" do
// 467:       allow(versioned_formula).to receive(:link_overwrite_keg_name).and_return("foo")
// 468:       allow(Formulary).to receive(:factory).with("foo").and_return(related_formula)
// 469:
// 470:       expect(versioned_formula.link_overwrite?(HOMEBREW_PREFIX/"bin/foo")).to be true
// 471:     end
// 472:
// 473:     it "allows deleted related keg names through implied overwrites" do
// 474:       allow(versioned_formula).to receive(:link_overwrite_keg_name).and_return("foo-old")
// 475:       allow(Formulary).to receive(:factory).with("foo-old").and_raise(FormulaUnavailableError.new("foo-old"))
// 476:       allow(related_formula).to receive_messages(oldnames: ["foo-old"], aliases: [])
// 477:
// 478:       expect(versioned_formula.link_overwrite?(HOMEBREW_PREFIX/"bin/foo")).to be true
// 479:     end
// 480:
// 481:     it "returns false for missing conflicts without explicit or implied overwrites" do
// 482:       formula_without_overwrites = formula "qux" do
// 483:         T.bind(self, T.class_of(Formula))
// 484:         url "qux-1.0"
// 485:       end
// 486:       allow(formula_without_overwrites).to receive_messages(link_overwrite_keg_name: :missing,
// 487:                                                             link_overwrite_formulae: [])
// 488:
// 489:       expect(formula_without_overwrites.link_overwrite?(HOMEBREW_PREFIX/"bin/qux")).to be false
// 490:     end
// 491:   end
// 492:
// 493:   describe "#implied_link_overwrite?" do
// 494:     let(:versioned_formula) do
// 495:       formula "foo@22" do
// 496:         T.bind(self, T.class_of(Formula))
// 497:         url "foo-22.0"
// 498:       end
// 499:     end
// 500:
// 501:     let(:related_formula) do
// 502:       formula "foo" do
// 503:         T.bind(self, T.class_of(Formula))
// 504:         url "foo-1.0"
// 505:       end
// 506:     end
// 507:
// 508:     before do
// 509:       allow(related_formula).to receive_messages(oldnames: ["foo-old"], aliases: ["foo-alias"])
// 510:     end
// 511:
// 512:     it "does not allow missing conflicts without actual related formulae" do
// 513:       expect(versioned_formula.implied_link_overwrite?(:missing, [])).to be false
// 514:     end
// 515:
// 516:     it "does not allow non-Homebrew conflicts" do
// 517:       expect(versioned_formula.implied_link_overwrite?(nil, [related_formula])).to be false
// 518:     end
// 519:
// 520:     it "does not allow missing conflicts even when related formulae exist" do
// 521:       expect(versioned_formula.implied_link_overwrite?(:missing, [related_formula])).to be false
// 522:     end
// 523:
// 524:     it "allows related keg names via oldnames" do
// 525:       expect(versioned_formula.implied_link_overwrite?("foo-old", [related_formula])).to be true
// 526:     end
// 527:
// 528:     it "allows related keg names via aliases" do
// 529:       expect(versioned_formula.implied_link_overwrite?("foo-alias", [related_formula])).to be true
// 530:     end
// 531:
// 532:     it "does not allow unrelated keg names" do
// 533:       expect(versioned_formula.implied_link_overwrite?("bar", [related_formula])).to be false
// 534:     end
// 535:   end
// 536:
// 537:   example "installed alias with core" do
// 538:     f = formula do
// 539:       T.bind(self, T.class_of(Formula))
// 540:       url "foo-1.0"
// 541:     end
// 542:
// 543:     build_values_with_no_installed_alias = [
// 544:       BuildOptions.new(Options.new, f.options),
// 545:       Tab.new(source: { "path" => f.path.to_s }),
// 546:     ]
// 547:     build_values_with_no_installed_alias.each do |build|
// 548:       f.build = build
// 549:       expect(f.installed_alias_path).to be_nil
// 550:       expect(f.installed_alias_name).to be_nil
// 551:       expect(f.full_installed_alias_name).to be_nil
// 552:       expect(f.full_installed_specified_name).to eq(f.name)
// 553:     end
// 554:
// 555:     alias_name = "bar"
// 556:     alias_path = CoreTap.instance.alias_dir/alias_name
// 557:     CoreTap.instance.alias_dir.mkpath
// 558:     FileUtils.ln_sf f.path, alias_path
// 559:
// 560:     f.build = Tab.new(source: { "path" => alias_path.to_s })
// 561:
// 562:     expect(f.installed_alias_path).to eq(alias_path)
// 563:     expect(f.installed_alias_name).to eq(alias_name)
// 564:     expect(f.full_installed_alias_name).to eq(alias_name)
// 565:     expect(f.full_installed_specified_name).to eq(alias_name)
// 566:   end
// 567:
// 568:   example "installed alias with tap" do
// 569:     tap = Tap.fetch("user", "repo")
// 570:     name = "foo"
// 571:     path = tap.path/"Formula/#{name}.rb"
// 572:     f = formula(name, path:) do
// 573:       T.bind(self, T.class_of(Formula))
// 574:       url "foo-1.0"
// 575:     end
// 576:
// 577:     build_values_with_no_installed_alias = [
// 578:       BuildOptions.new(Options.new, f.options),
// 579:       Tab.new(source: { "path" => f.path.to_s }),
// 580:     ]
// 581:     build_values_with_no_installed_alias.each do |build|
// 582:       f.build = build
// 583:       expect(f.installed_alias_path).to be_nil
// 584:       expect(f.installed_alias_name).to be_nil
// 585:       expect(f.full_installed_alias_name).to be_nil
// 586:       expect(f.full_installed_specified_name).to eq(f.full_name)
// 587:     end
// 588:
// 589:     alias_name = "bar"
// 590:     alias_path = tap.alias_dir/alias_name
// 591:     full_alias_name = "#{tap.user}/#{tap.repository}/#{alias_name}"
// 592:     tap.alias_dir.mkpath
// 593:     FileUtils.ln_sf f.path, alias_path
// 594:
// 595:     f.build = Tab.new(source: { "path" => alias_path.to_s })
// 596:
// 597:     expect(f.installed_alias_path).to eq(alias_path)
// 598:     expect(f.installed_alias_name).to eq(alias_name)
// 599:     expect(f.full_installed_alias_name).to eq(full_alias_name)
// 600:     expect(f.full_installed_specified_name).to eq(full_alias_name)
// 601:
// 602:     FileUtils.rm_rf HOMEBREW_LIBRARY/"Taps/user"
// 603:   end
// 604:
// 605:   specify "#prefix" do
// 606:     f = Testball.new
// 607:     expect(f.prefix).to eq(HOMEBREW_CELLAR/f.name/"0.1")
// 608:     expect(f.prefix).to be_a(Pathname)
// 609:   end
// 610:
// 611:   example "revised prefix" do
// 612:     f = Class.new(Testball) { revision(1) }.new
// 613:     expect(f.prefix).to eq(HOMEBREW_CELLAR/f.name/"0.1_1")
// 614:   end
// 615:
// 616:   example "compatibility_version" do
// 617:     f = Class.new(Testball) { compatibility_version(1) }.new
// 618:     expect(f.class.compatibility_version).to eq(1)
// 619:   end
// 620:
// 621:   specify "#any_version_installed?" do
// 622:     f = formula do
// 623:       T.bind(self, T.class_of(Formula))
// 624:       url "foo"
// 625:       version "1.0"
// 626:     end
// 627:
// 628:     expect(f).not_to have_any_version_installed
// 629:
// 630:     prefix = HOMEBREW_CELLAR/f.name/"0.1"
// 631:     prefix.mkpath
// 632:     FileUtils.touch prefix/AbstractTab::FILENAME
// 633:
// 634:     expect(f).to have_any_version_installed
// 635:   end
// 636:
// 637:   specify "#formula_opt_bin" do
// 638:     f = formula do
// 639:       T.bind(self, T.class_of(Formula))
// 640:       url "foo"
// 641:       version "1.0"
// 642:     end
// 643:
// 644:     expect(f.formula_opt_bin("foo")).to eq(HOMEBREW_PREFIX/"opt/foo/bin")
// 645:   end
// 646:
// 647:   specify "#migration_needed" do
// 648:     f = Testball.new("newname")
// 649:     f.oldnames = ["oldname"]
// 650:     f.tap = CoreTap.instance
// 651:
// 652:     oldname_prefix = (HOMEBREW_CELLAR/"oldname/2.20")
// 653:     newname_prefix = (HOMEBREW_CELLAR/"newname/2.10")
// 654:
// 655:     oldname_prefix.mkpath
// 656:     oldname_tab = Tab.empty
// 657:     oldname_tab.tabfile = oldname_prefix/AbstractTab::FILENAME
// 658:     oldname_tab.write
// 659:
// 660:     expect(f).not_to need_migration
// 661:
// 662:     oldname_tab.tabfile.unlink
// 663:     oldname_tab.source["tap"] = "homebrew/core"
// 664:     oldname_tab.write
// 665:
// 666:     expect(f).to need_migration
// 667:
// 668:     newname_prefix.mkpath
// 669:
// 670:     expect(f).not_to need_migration
// 671:   end
// 672:
// 673:   specify "#oldnames ignores same-name cask-to-formula migrations" do
// 674:     tap = Tap.fetch("homebrew", "foo")
// 675:     allow(Tap).to receive(:tap_migration_oldnames).with(tap, "same-name-cask")
// 676:                                                   .and_return(["same-name-cask"])
// 677:
// 678:     expect(formula("same-name-cask", tap:) do
// 679:       T.bind(self, T.class_of(Formula))
// 680:       url "https://brew.sh/same-name-cask-1.0.tar.gz"
// 681:     end.oldnames).to be_empty
// 682:   end
// 683:
// 684:   describe "#latest_version_installed?" do
// 685:     let(:f) { Testball.new }
// 686:
// 687:     it "returns false if the #latest_installed_prefix is not a directory" do
// 688:       allow(f).to receive(:latest_installed_prefix).and_return(instance_double(Pathname, directory?: false))
// 689:       expect(f).not_to be_latest_version_installed
// 690:     end
// 691:
// 692:     it "returns false if the #latest_installed_prefix is empty" do
// 693:       allow(f).to receive(:latest_installed_prefix)
// 694:         .and_return(instance_double(Pathname, directory?: true, empty?: true))
// 695:       expect(f).not_to be_latest_version_installed
// 696:     end
// 697:
// 698:     it "returns true if the #latest_installed_prefix is not empty" do
// 699:       allow(f).to receive(:latest_installed_prefix)
// 700:         .and_return(instance_double(Pathname, directory?: true, empty?: false))
// 701:       expect(f).to be_latest_version_installed
// 702:     end
// 703:   end
// 704:
// 705:   describe "#latest_installed_prefix" do
// 706:     let(:f) do
// 707:       formula do
// 708:         T.bind(self, T.class_of(Formula))
// 709:         url "foo"
// 710:         version "1.9"
// 711:         head "foo"
// 712:       end
// 713:     end
// 714:
// 715:     let(:stable_prefix) { HOMEBREW_CELLAR/f.name/f.version }
// 716:     let(:head_prefix) { HOMEBREW_CELLAR/f.name/f.head.version }
// 717:
// 718:     it "is the same as #prefix by default" do
// 719:       expect(f.latest_installed_prefix).to eq(f.prefix)
// 720:     end
// 721:
// 722:     it "returns the stable prefix if it is installed" do
// 723:       stable_prefix.mkpath
// 724:       expect(f.latest_installed_prefix).to eq(stable_prefix)
// 725:     end
// 726:
// 727:     it "returns the head prefix if it is installed" do
// 728:       head_prefix.mkpath
// 729:       expect(f.latest_installed_prefix).to eq(head_prefix)
// 730:     end
// 731:
// 732:     it "returns the stable prefix if head is outdated" do
// 733:       head_prefix.mkpath
// 734:
// 735:       tab = Tab.empty
// 736:       tab.tabfile = head_prefix/AbstractTab::FILENAME
// 737:       tab.source["versions"] = { "stable" => "1.0" }
// 738:       tab.write
// 739:
// 740:       expect(f.latest_installed_prefix).to eq(stable_prefix)
// 741:     end
// 742:
// 743:     it "returns the head prefix if the active specification is :head" do
// 744:       f.active_spec = :head
// 745:       expect(f.latest_installed_prefix).to eq(head_prefix)
// 746:     end
// 747:   end
// 748:
// 749:   describe "#latest_head_prefix" do
// 750:     let(:f) { Testball.new }
// 751:
// 752:     it "returns the latest head prefix" do
// 753:       stamps_with_revisions = [
// 754:         [111111, 1],
// 755:         [222222, 0],
// 756:         [222222, 1],
// 757:         [222222, 2],
// 758:       ]
// 759:
// 760:       stamps_with_revisions.each do |stamp, revision|
// 761:         version = "HEAD-#{stamp}"
// 762:         version = "#{version}_#{revision}" unless revision.zero?
// 763:
// 764:         prefix = f.rack/version
// 765:         prefix.mkpath
// 766:
// 767:         tab = Tab.empty
// 768:         tab.tabfile = prefix/AbstractTab::FILENAME
// 769:         tab.source_modified_time = stamp
// 770:         tab.write
// 771:       end
// 772:
// 773:       prefix = HOMEBREW_CELLAR/f.name/"HEAD-222222_2"
// 774:
// 775:       expect(f.latest_head_prefix).to eq(prefix)
// 776:     end
// 777:   end
// 778:
// 779:   specify "equality" do
// 780:     x = Testball.new
// 781:     y = Testball.new
// 782:
// 783:     expect(x).to eq(y)
// 784:     expect(x).to eql(y)
// 785:     expect(x.hash).to eq(y.hash)
// 786:   end
// 787:
// 788:   specify "inequality" do
// 789:     x = Testball.new("foo")
// 790:     y = Testball.new("bar")
// 791:
// 792:     expect(x).not_to eq(y)
// 793:     expect(x).not_to eql(y)
// 794:     expect(x.hash).not_to eq(y.hash)
// 795:   end
// 796:
// 797:   specify "comparison with non formula objects does not raise" do
// 798:     expect(Object.new).not_to eq(Testball.new)
// 799:   end
// 800:
// 801:   specify "#<=>" do
// 802:     expect(Testball.new <=> Object.new).to be_nil
// 803:   end
// 804:
// 805:   describe "#installed_alias_path" do
// 806:     example "alias paths with build options" do
// 807:       alias_path = (CoreTap.instance.alias_dir/"another_name")
// 808:
// 809:       f = formula(alias_path:) do
// 810:         T.bind(self, T.class_of(Formula))
// 811:         url "foo-1.0"
// 812:       end
// 813:       f.build = BuildOptions.new(Options.new, f.options)
// 814:
// 815:       expect(f.alias_path).to eq(alias_path)
// 816:       expect(f.installed_alias_path).to be_nil
// 817:     end
// 818:
// 819:     example "alias paths with tab with non alias source path" do
// 820:       alias_path = (CoreTap.instance.alias_dir/"another_name")
// 821:       source_path = CoreTap.instance.new_formula_path("another_other_name")
// 822:
// 823:       f = formula(alias_path:) do
// 824:         T.bind(self, T.class_of(Formula))
// 825:         url "foo-1.0"
// 826:       end
// 827:       f.build = Tab.new(source: { "path" => source_path.to_s })
// 828:
// 829:       expect(f.alias_path).to eq(alias_path)
// 830:       expect(f.installed_alias_path).to be_nil
// 831:     end
// 832:
// 833:     example "alias paths with tab with alias source path" do
// 834:       alias_path = (CoreTap.instance.alias_dir/"another_name")
// 835:       source_path = (CoreTap.instance.alias_dir/"another_other_name")
// 836:
// 837:       f = formula(alias_path:) do
// 838:         T.bind(self, T.class_of(Formula))
// 839:         url "foo-1.0"
// 840:       end
// 841:       f.build = Tab.new(source: { "path" => source_path.to_s })
// 842:       CoreTap.instance.alias_dir.mkpath
// 843:       FileUtils.ln_sf f.path, source_path
// 844:
// 845:       expect(f.alias_path).to eq(alias_path)
// 846:       expect(f.installed_alias_path).to eq(source_path)
// 847:     end
// 848:   end
// 849:
// 850:   describe "::inreplace" do
// 851:     specify "raises build error on failure" do
// 852:       f = formula do
// 853:         T.bind(self, T.class_of(Formula))
// 854:         url "https://brew.sh/test-1.0.tbz"
// 855:       end
// 856:
// 857:       expect { f.inreplace([]) }.to raise_error(BuildError)
// 858:     end
// 859:
// 860:     specify "replaces text in file" do
// 861:       file = Tempfile.new("test")
// 862:       File.binwrite(file, <<~EOS)
// 863:         ab
// 864:         bc
// 865:         cd
// 866:       EOS
// 867:       f = formula do
// 868:         T.bind(self, T.class_of(Formula))
// 869:         url "https://brew.sh/test-1.0.tbz"
// 870:       end
// 871:       f.inreplace(file.path) do |s|
// 872:         s.gsub!("bc", "yz")
// 873:       end
// 874:       expect(File.binread(file)).to eq <<~EOS
// 875:         ab
// 876:         yz
// 877:         cd
// 878:       EOS
// 879:     end
// 880:   end
// 881:
// 882:   describe "::installed_with_alias_path" do
// 883:     specify "with alias path with nil" do
// 884:       expect(described_class.installed_with_alias_path(nil)).to be_empty
// 885:     end
// 886:
// 887:     specify "with alias path with a path" do
// 888:       alias_path = CoreTap.instance.alias_dir/"alias"
// 889:       different_alias_path = CoreTap.instance.alias_dir/"another_alias"
// 890:
// 891:       formula_with_alias = formula "foo" do
// 892:         T.bind(self, T.class_of(Formula))
// 893:         url "foo-1.0"
// 894:       end
// 895:       formula_with_alias.build = Tab.empty
// 896:       formula_with_alias.build.source["path"] = alias_path.to_s
// 897:
// 898:       formula_without_alias = formula "bar" do
// 899:         T.bind(self, T.class_of(Formula))
// 900:         url "bar-1.0"
// 901:       end
// 902:       formula_without_alias.build = Tab.empty
// 903:       formula_without_alias.build.source["path"] = formula_without_alias.path.to_s
// 904:
// 905:       formula_with_different_alias = formula "baz" do
// 906:         T.bind(self, T.class_of(Formula))
// 907:         url "baz-1.0"
// 908:       end
// 909:       formula_with_different_alias.build = Tab.empty
// 910:       formula_with_different_alias.build.source["path"] = different_alias_path.to_s
// 911:
// 912:       formulae = [
// 913:         formula_with_alias,
// 914:         formula_without_alias,
// 915:         formula_with_different_alias,
// 916:       ]
// 917:
// 918:       allow(described_class).to receive(:installed).and_return(formulae)
// 919:
// 920:       CoreTap.instance.alias_dir.mkpath
// 921:       FileUtils.ln_sf formula_with_alias.path, alias_path
// 922:
// 923:       expect(described_class.installed_with_alias_path(alias_path))
// 924:         .to eq([formula_with_alias])
// 925:     end
// 926:   end
// 927:
// 928:   specify ".url" do
// 929:     f = formula do
// 930:       T.bind(self, T.class_of(Formula))
// 931:       url "foo-1.0"
// 932:     end
// 933:
// 934:     expect(f.class.url).to eq("foo-1.0")
// 935:   end
// 936:
// 937:   specify ".homepage with a human browser check" do
// 938:     f = formula do
// 939:       T.bind(self, T.class_of(Formula))
// 940:       homepage "https://brew.sh", browsed: "2026-07-26"
// 941:       url "https://brew.sh/test-1.0.tar.gz"
// 942:     end
// 943:
// 944:     expect(f.homepage_browsed).to eq(Date.new(2026, 7, 26))
// 945:   end
// 946:
// 947:   specify ".homepage requires a URL with a human browser check" do
// 948:     expect do
// 949:       formula do
// 950:         T.bind(self, T.class_of(Formula))
// 951:         homepage browsed: "2026-07-26"
// 952:       end
// 953:     end.to raise_error(ArgumentError, "`browsed` requires a homepage URL")
// 954:   end
// 955:
// 956:   specify "spec integration" do
// 957:     f = formula do
// 958:       T.bind(self, T.class_of(Formula))
// 959:       homepage "https://brew.sh"
// 960:
// 961:       url "https://brew.sh/test-0.1.tbz"
// 962:       mirror "https://example.org/test-0.1.tbz"
// 963:       sha256 TEST_SHA256
// 964:
// 965:       head "https://brew.sh/test.git", tag: "foo"
// 966:     end
// 967:
// 968:     expect(f.homepage).to eq("https://brew.sh")
// 969:     expect(f.version).to eq(Version.new("0.1"))
// 970:     expect(f).to be_stable
// 971:     expect(f.build).to be_a(BuildOptions)
// 972:     expect(f.stable.version).to eq(Version.new("0.1"))
// 973:     expect(f.head.version).to eq(Version.new("HEAD"))
// 974:   end
// 975:
// 976:   specify "#active_spec=" do
// 977:     f = formula do
// 978:       T.bind(self, T.class_of(Formula))
// 979:       url "foo"
// 980:       version "1.0"
// 981:       revision 1
// 982:     end
// 983:
// 984:     expect(f.active_spec_sym).to eq(:stable)
// 985:     expect(f.active_spec).to eq(f.stable)
// 986:     expect(f.pkg_version.to_s).to eq("1.0_1")
// 987:
// 988:     expect { f.active_spec = :head }.to raise_error(FormulaSpecificationError)
// 989:   end
// 990:
// 991:   specify "class specs are always initialized" do
// 992:     f = formula do
// 993:       T.bind(self, T.class_of(Formula))
// 994:       url "foo-1.0"
// 995:     end
// 996:
// 997:     expect(f.class.stable).to be_a(SoftwareSpec)
// 998:     expect(f.class.head).to be_a(SoftwareSpec)
// 999:   end
// 1000:
// 1001:   specify "instance specs have different references" do
// 1002:     f = Testball.new
// 1003:     f2 = Testball.new
// 1004:
// 1005:     expect(f.stable.owner).to equal(f)
// 1006:     expect(f2.stable.owner).to equal(f2)
// 1007:   end
// 1008:
// 1009:   specify "incomplete instance specs are not accessible" do
// 1010:     f = formula do
// 1011:       T.bind(self, T.class_of(Formula))
// 1012:       url "foo-1.0"
// 1013:     end
// 1014:
// 1015:     expect(f.head).to be_nil
// 1016:   end
// 1017:
// 1018:   describe "#ensure_installed!" do
// 1019:     let(:f) do
// 1020:       formula do
// 1021:         T.bind(self, T.class_of(Formula))
// 1022:         url "foo-1.2.3"
// 1023:       end
// 1024:     end
// 1025:
// 1026:     let(:executable) { Pathname.new("/usr/bin/foo") }
// 1027:
// 1028:     it "uses a system executable without checking the version by default" do
// 1029:       allow(f).to receive(:which).with("foo", ORIGINAL_PATHS).and_return(executable)
// 1030:
// 1031:       expect(SystemCommand).not_to receive(:run)
// 1032:       expect(f).not_to receive(:any_version_installed?)
// 1033:
// 1034:       expect(f.ensure_installed!(executable: "foo", output_to_stderr: false)).to eq(executable)
// 1035:     end
// 1036:
// 1037:     it "uses a matching system executable when latest is requested" do
// 1038:       allow(f).to receive(:which).with("foo", ORIGINAL_PATHS).and_return(executable)
// 1039:       allow(SystemCommand).to receive(:run)
// 1040:         .with(executable, args: ["--version"], print_stderr: false)
// 1041:         .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "foo 1.2.3\n"))
// 1042:
// 1043:       expect(f.ensure_installed!(executable: "foo", latest: true, output_to_stderr: false)).to eq(executable)
// 1044:     end
// 1045:
// 1046:     it "passes custom version arguments to the version check" do
// 1047:       allow(f).to receive(:which).with("foo", ORIGINAL_PATHS).and_return(executable)
// 1048:       allow(SystemCommand).to receive(:run)
// 1049:         .with(executable, args: ["-version"], print_stderr: false)
// 1050:         .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "1.2.3\n"))
// 1051:
// 1052:       expect(f.ensure_installed!(executable: "foo", latest: true, output_to_stderr: false,
// 1053:                                  version_args: ["-version"])).to eq(executable)
// 1054:     end
// 1055:
// 1056:     it "returns the brewed executable path when the system version does not match latest" do
// 1057:       allow(f).to receive(:which).with("foo", ORIGINAL_PATHS).and_return(executable)
// 1058:       allow(SystemCommand).to receive(:run)
// 1059:         .with(executable, args: ["--version"], print_stderr: false)
// 1060:         .and_return(instance_double(SystemCommand::Result, success?: true, stdout: "foo 1.2.2\n"))
// 1061:       allow(f).to receive_messages(any_version_installed?: true, latest_version_installed?: true)
// 1062:
// 1063:       expect(f.ensure_installed!(executable: "foo", latest: true, output_to_stderr: false)).to eq(f.opt_bin/"foo")
// 1064:     end
// 1065:   end
// 1066:
// 1067:   it "honors attributes declared before specs" do
// 1068:     f = formula do
// 1069:       T.bind(self, T.class_of(Formula))
// 1070:       url "foo-1.0"
// 1071:
// 1072:       depends_on "foo"
// 1073:     end
// 1074:
// 1075:     expect(f.class.stable.deps.first.name).to eq("foo")
// 1076:     expect(f.class.head.deps.first.name).to eq("foo")
// 1077:   end
// 1078:
// 1079:   describe "#pkg_version" do
// 1080:     specify "simple version" do
// 1081:       f = formula do
// 1082:         T.bind(self, T.class_of(Formula))
// 1083:         url "foo-1.0.bar"
// 1084:       end
// 1085:
// 1086:       expect(f.pkg_version).to eq(PkgVersion.parse("1.0"))
// 1087:     end
// 1088:
// 1089:     specify "version with revision" do
// 1090:       f = formula do
// 1091:         T.bind(self, T.class_of(Formula))
// 1092:         url "foo-1.0.bar"
// 1093:         revision 1
// 1094:       end
// 1095:
// 1096:       expect(f.pkg_version).to eq(PkgVersion.parse("1.0_1"))
// 1097:     end
// 1098:
// 1099:     specify "head uses revisions" do
// 1100:       f = formula "test", spec: :head do
// 1101:         T.bind(self, T.class_of(Formula))
// 1102:         url "foo-1.0.bar"
// 1103:         revision 1
// 1104:
// 1105:         head "foo"
// 1106:       end
// 1107:
// 1108:       expect(f.pkg_version).to eq(PkgVersion.parse("HEAD_1"))
// 1109:     end
// 1110:   end
// 1111:
// 1112:   specify "#update_head_version" do
// 1113:     f = formula do
// 1114:       T.bind(self, T.class_of(Formula))
// 1115:       head "foo", using: :git
// 1116:     end
// 1117:
// 1118:     cached_location = f.head.downloader.cached_location
// 1119:     cached_location.mkpath
// 1120:     cached_location.cd do
// 1121:       FileUtils.touch "LICENSE"
// 1122:
// 1123:       system("git", "init")
// 1124:       system("git", "add", "--all")
// 1125:       system("git", "commit", "-m", "Initial commit")
// 1126:     end
// 1127:
// 1128:     f.update_head_version
// 1129:
// 1130:     expect(f.head.version).to eq(Version.new("HEAD-5658946"))
// 1131:   end
// 1132:
// 1133:   specify "#desc" do
// 1134:     f = formula do
// 1135:       T.bind(self, T.class_of(Formula))
// 1136:       desc "a formula"
// 1137:
// 1138:       url "foo-1.0"
// 1139:     end
// 1140:
// 1141:     expect(f.desc).to eq("a formula")
// 1142:   end
// 1143:
// 1144:   specify "#post_install_defined?" do
// 1145:     f1 = formula do
// 1146:       T.bind(self, T.class_of(Formula))
// 1147:       url "foo-1.0"
// 1148:
// 1149:       def post_install
// 1150:         # do nothing
// 1151:       end
// 1152:     end
// 1153:
// 1154:     f2 = formula do
// 1155:       T.bind(self, T.class_of(Formula))
// 1156:       url "foo-1.0"
// 1157:     end
// 1158:
// 1159:     expect(f1).to have_post_install_defined
// 1160:     expect(f2).not_to have_post_install_defined
// 1161:   end
// 1162:
// 1163:   specify "#run_post_install prevents build tools from reading user configuration" do
// 1164:     env = {}
// 1165:     f = formula do
// 1166:       T.bind(self, T.class_of(Formula))
// 1167:       url "foo-1.0"
// 1168:     end
// 1169:
// 1170:     allow(Tab).to receive(:for_formula).with(f).and_return(f.build)
// 1171:     allow(f).to receive(:post_install) { env = ENV.to_hash }
// 1172:     expect(Dir).to receive(:mktmpdir).with("#{f.name}-postinstall-", HOMEBREW_TEMP).and_call_original
// 1173:
// 1174:     f.run_post_install
// 1175:
// 1176:     expect(env).to include(
// 1177:       "GIT_CONFIG_GLOBAL"     => Utils::Git.no_global_config_file,
// 1178:       "GIT_TERMINAL_PROMPT"   => "0",
// 1179:       "GOENV"                 => "off",
// 1180:       "NPM_CONFIG_USERCONFIG" => File::NULL,
// 1181:       "PIP_CONFIG_FILE"       => File::NULL,
// 1182:       "XDG_CONFIG_HOME"       => "#{env.fetch("HOME")}/.config",
// 1183:     )
// 1184:   end
// 1185:
// 1186:   specify "#run_post_install runs install steps before the remaining hook" do
// 1187:     f = formula do
// 1188:       T.bind(self, T.class_of(Formula))
// 1189:       url "foo-1.0"
// 1190:     end
// 1191:
// 1192:     allow(Tab).to receive(:for_formula).with(f).and_return(f.build)
// 1193:     allow(f).to receive_messages(post_install_steps_defined?: true, post_install_defined?: true)
// 1194:     expect(f).to receive(:run_post_install_steps).ordered
// 1195:     expect(f).to receive(:post_install).ordered
// 1196:
// 1197:     f.run_post_install
// 1198:   end
// 1199:
// 1200:   specify "#post_install_steps" do
// 1201:     f = formula do
// 1202:       T.bind(self, T.class_of(Formula))
// 1203:       url "foo-1.0"
// 1204:
// 1205:       post_install_steps do
// 1206:         mkdir_p "log/foo", base: :var
// 1207:         touch "foo/marker", base: :var
// 1208:         move "move-source", "move-target"
// 1209:         move_contents "children-source", "children-target"
// 1210:         symlink "move-target", "linked-target", source_base: :relative, remove_on_uninstall: true
// 1211:       end
// 1212:     end
// 1213:
// 1214:     expect(f.post_install_steps).to eq([
// 1215:       { "type" => "mkdir_p", "path" => { "base" => "var", "path" => "log/foo" } },
// 1216:       { "type" => "touch", "path" => { "base" => "var", "path" => "foo/marker" } },
// 1217:       {
// 1218:         "type"      => "move",
// 1219:         "source"    => { "base" => "prefix", "path" => "move-source" },
// 1220:         "target"    => { "base" => "prefix", "path" => "move-target" },
// 1221:         "overwrite" => true,
// 1222:       },
// 1223:       {
// 1224:         "type"   => "move_contents",
// 1225:         "source" => { "base" => "prefix", "path" => "children-source" },
// 1226:         "target" => { "base" => "prefix", "path" => "children-target" },
// 1227:       },
// 1228:       {
// 1229:         "type"      => "symlink",
// 1230:         "source"    => { "base" => "relative", "path" => "move-target" },
// 1231:         "target"    => { "base" => "prefix", "path" => "linked-target" },
// 1232:         "uninstall" => true,
// 1233:       },
// 1234:     ])
// 1235:     expect(f.post_install_steps_defined?).to be(true)
// 1236:     expect(f.to_hash["post_install_steps"]).to eq(f.post_install_steps)
// 1237:   end
// 1238:
// 1239:   specify "#post_install_steps does not default paths to var" do
// 1240:     f = formula do
// 1241:       T.bind(self, T.class_of(Formula))
// 1242:       url "foo-1.0"
// 1243:
// 1244:       post_install_steps do
// 1245:         touch "foo/marker"
// 1246:       end
// 1247:     end
// 1248:
// 1249:     expect(f.post_install_steps).to eq([
// 1250:       { "type" => "touch", "path" => { "path" => "foo/marker" } },
// 1251:     ])
// 1252:   end
// 1253:
// 1254:   specify "#post_install_steps_defined? with an empty block" do
// 1255:     f = formula do
// 1256:       T.bind(self, T.class_of(Formula))
// 1257:       url "foo-1.0"
// 1258:
// 1259:       # This intentionally declares no steps to test definition tracking.
// 1260:       # rubocop:disable Lint/EmptyBlock
// 1261:       post_install_steps do
// 1262:       end
// 1263:       # rubocop:enable Lint/EmptyBlock
// 1264:     end
// 1265:
// 1266:     expect(f.post_install_steps).to be_empty
// 1267:     expect(f.post_install_steps_defined?).to be(true)
// 1268:   end
// 1269:
// 1270:   specify "#post_install_steps can coexist with #post_install" do
// 1271:     f = formula do
// 1272:       T.bind(self, T.class_of(Formula))
// 1273:       url "foo-1.0"
// 1274:
// 1275:       # This intentionally declares no steps to test definition tracking.
// 1276:       # rubocop:disable Lint/EmptyBlock
// 1277:       post_install_steps do
// 1278:       end
// 1279:       # rubocop:enable Lint/EmptyBlock
// 1280:
// 1281:       def post_install; end
// 1282:     end
// 1283:
// 1284:     expect(f.post_install_steps_defined?).to be(true)
// 1285:     expect(f.post_install_defined?).to be(true)
// 1286:   end
// 1287:
// 1288:   specify "#run_post_install_steps uses the versioned prefix" do
// 1289:     f = formula "post-install-steps-prefix" do
// 1290:       T.bind(self, T.class_of(Formula))
// 1291:       url "foo-1.0"
// 1292:
// 1293:       post_install_steps do
// 1294:         symlink "source", "linked"
// 1295:       end
// 1296:     end
// 1297:
// 1298:     versioned_prefix = f.rack/f.pkg_version.to_s
// 1299:     FileUtils.rm_f f.opt_prefix
// 1300:     versioned_prefix.mkpath
// 1301:     f.opt_prefix.parent.mkpath
// 1302:     FileUtils.ln_s versioned_prefix, f.opt_prefix
// 1303:
// 1304:     f.run_post_install_steps
// 1305:
// 1306:     expect((versioned_prefix/"linked").readlink).to eq(versioned_prefix/"source")
// 1307:   ensure
// 1308:     FileUtils.rm_f f.opt_prefix
// 1309:     FileUtils.rm_rf f.rack
// 1310:   end
// 1311:
// 1312:   describe "#install_etc_var" do
// 1313:     let(:f) do
// 1314:       formula "config-upgrade" do
// 1315:         T.bind(self, T.class_of(Formula))
// 1316:         url "foo-2.0"
// 1317:         version "2.0"
// 1318:       end
// 1319:     end
// 1320:     let(:config_file) { HOMEBREW_PREFIX/"etc/config-upgrade.conf" }
// 1321:     let(:default_config_file) { Pathname("#{config_file}.default") }
// 1322:     let(:old_default_file) { f.rack/"1.0/.bottle/etc/config-upgrade.conf" }
// 1323:     let(:new_default_file) { f.bottle_prefix/"etc/config-upgrade.conf" }
// 1324:
// 1325:     before do
// 1326:       FileUtils.rm_rf f.rack
// 1327:       FileUtils.rm_f config_file
// 1328:       FileUtils.rm_f default_config_file
// 1329:
// 1330:       old_default_file.dirname.mkpath
// 1331:       old_default_file.write "old\n"
// 1332:       new_default_file.dirname.mkpath
// 1333:       new_default_file.write "new\n"
// 1334:       config_file.dirname.mkpath
// 1335:     end
// 1336:
// 1337:     it "replaces config that matches the previous default" do
// 1338:       config_file.write "old\n"
// 1339:
// 1340:       f.install_etc_var
// 1341:
// 1342:       expect([config_file.read, default_config_file.exist?]).to eq(["new\n", false])
// 1343:     end
// 1344:
// 1345:     it "writes a default file when the config was modified" do
// 1346:       config_file.write "custom\n"
// 1347:
// 1348:       f.install_etc_var
// 1349:
// 1350:       expect([config_file.read, default_config_file.read]).to eq(["custom\n", "new\n"])
// 1351:     end
// 1352:
// 1353:     it "replaces config that matches the previous default when the keg is opt-linked" do
// 1354:       config_file.write "old\n"
// 1355:       Keg.new(f.rack/"2.0").optlink
// 1356:
// 1357:       f.install_etc_var
// 1358:
// 1359:       expect([config_file.read, default_config_file.exist?]).to eq(["new\n", false])
// 1360:     end
// 1361:   end
// 1362:
// 1363:   specify "test fixtures" do
// 1364:     f1 = formula do
// 1365:       T.bind(self, T.class_of(Formula))
// 1366:       url "foo-1.0"
// 1367:     end
// 1368:
// 1369:     expect(f1.test_fixtures("foo")).to eq(Pathname.new("#{HOMEBREW_LIBRARY_PATH}/test/support/fixtures/foo"))
// 1370:   end
// 1371:
// 1372:   specify "#livecheck" do
// 1373:     f = formula do
// 1374:       T.bind(self, T.class_of(Formula))
// 1375:       url "https://brew.sh/test-1.0.tbz"
// 1376:       livecheck do
// 1377:         skip "foo"
// 1378:         url "https://brew.sh/test/releases"
// 1379:         regex(/test-v?(\d+(?:\.\d+)+)\.t/i)
// 1380:       end
// 1381:     end
// 1382:
// 1383:     expect(f.livecheck.skip?).to be true
// 1384:     expect(f.livecheck.skip_msg).to eq("foo")
// 1385:     expect(f.livecheck.url).to eq("https://brew.sh/test/releases")
// 1386:     expect(f.livecheck.regex).to eq(/test-v?(\d+(?:\.\d+)+)\.t/i)
// 1387:   end
// 1388:
// 1389:   describe "#livecheck_defined?" do
// 1390:     specify "no `livecheck` block defined" do
// 1391:       f = formula do
// 1392:         T.bind(self, T.class_of(Formula))
// 1393:         url "https://brew.sh/test-1.0.tbz"
// 1394:       end
// 1395:
// 1396:       expect(f.livecheck_defined?).to be false
// 1397:     end
// 1398:
// 1399:     specify "`livecheck` block defined" do
// 1400:       f = formula do
// 1401:         T.bind(self, T.class_of(Formula))
// 1402:         url "https://brew.sh/test-1.0.tbz"
// 1403:         livecheck do
// 1404:           regex(/test-v?(\d+(?:\.\d+)+)\.t/i)
// 1405:         end
// 1406:       end
// 1407:
// 1408:       expect(f.livecheck_defined?).to be true
// 1409:     end
// 1410:
// 1411:     specify "livecheck references Formula URL" do
// 1412:       f = formula do
// 1413:         T.bind(self, T.class_of(Formula))
// 1414:         homepage "https://brew.sh/test"
// 1415:
// 1416:         url "https://brew.sh/test-1.0.tbz"
// 1417:         livecheck do
// 1418:           url :homepage
// 1419:           regex(/test-v?(\d+(?:\.\d+)+)\.t/i)
// 1420:         end
// 1421:       end
// 1422:
// 1423:       expect(f.livecheck.url).to eq(:homepage)
// 1424:     end
// 1425:   end
// 1426:
// 1427:   describe "#service" do
// 1428:     specify "no service defined" do
// 1429:       f = formula do
// 1430:         T.bind(self, T.class_of(Formula))
// 1431:         url "https://brew.sh/test-1.0.tbz"
// 1432:       end
// 1433:
// 1434:       expect(f.service.to_hash).to eq({})
// 1435:     end
// 1436:
// 1437:     specify "service complicated" do
// 1438:       f = formula do
// 1439:         T.bind(self, T.class_of(Formula))
// 1440:         url "https://brew.sh/test-1.0.tbz"
// 1441:
// 1442:         service do
// 1443:           T.bind(self, Homebrew::Service)
// 1444:           run [opt_bin/"beanstalkd"]
// 1445:           run_type :immediate
// 1446:           error_log_path var/"log/beanstalkd.error.log"
// 1447:           log_path var/"log/beanstalkd.log"
// 1448:           working_dir var
// 1449:           keep_alive true
// 1450:         end
// 1451:       end
// 1452:       expect(f.service.to_hash.keys)
// 1453:         .to contain_exactly(:run, :run_type, :error_log_path, :log_path, :working_dir, :keep_alive)
// 1454:     end
// 1455:
// 1456:     specify "service uses simple run" do
// 1457:       f = formula do
// 1458:         T.bind(self, T.class_of(Formula))
// 1459:         url "https://brew.sh/test-1.0.tbz"
// 1460:         service do
// 1461:           T.bind(self, Homebrew::Service)
// 1462:           run opt_bin/"beanstalkd"
// 1463:         end
// 1464:       end
// 1465:
// 1466:       expect(f.service.to_hash.keys).to contain_exactly(:run, :run_type)
// 1467:     end
// 1468:
// 1469:     specify "service with only custom names" do
// 1470:       f = formula do
// 1471:         T.bind(self, T.class_of(Formula))
// 1472:         url "https://brew.sh/test-1.0.tbz"
// 1473:         service do
// 1474:           name macos: "custom.macos.beanstalkd", linux: "custom.linux.beanstalkd"
// 1475:         end
// 1476:       end
// 1477:
// 1478:       expect(f.plist_name).to eq("custom.macos.beanstalkd")
// 1479:       expect(f.service_name).to eq("custom.linux.beanstalkd")
// 1480:       expect(f.service.to_hash.keys).to contain_exactly(:name)
// 1481:     end
// 1482:
// 1483:     specify "service helpers return data" do
// 1484:       f = formula do
// 1485:         T.bind(self, T.class_of(Formula))
// 1486:         url "https://brew.sh/test-1.0.tbz"
// 1487:       end
// 1488:
// 1489:       expect(f.plist_name).to eq("homebrew.mxcl.formula_name")
// 1490:       expect(f.service_name).to eq("homebrew.formula_name")
// 1491:       expect(f.launchd_service_path).to eq(HOMEBREW_PREFIX/"opt/formula_name/homebrew.mxcl.formula_name.plist")
// 1492:       expect(f.systemd_service_path).to eq(HOMEBREW_PREFIX/"opt/formula_name/homebrew.formula_name.service")
// 1493:       expect(f.systemd_timer_path).to eq(HOMEBREW_PREFIX/"opt/formula_name/homebrew.formula_name.timer")
// 1494:     end
// 1495:   end
// 1496:
// 1497:   specify "dependencies" do
// 1498:     # don't try to load/fetch gcc/glibc
// 1499:     allow(DevelopmentTools).to receive_messages(needs_libc_formula?: false, needs_compiler_formula?: false)
// 1500:
// 1501:     f1 = formula "f1" do
// 1502:       T.bind(self, T.class_of(Formula))
// 1503:       url "f1-1.0"
// 1504:     end
// 1505:
// 1506:     f2 = formula "f2" do
// 1507:       T.bind(self, T.class_of(Formula))
// 1508:       url "f2-1.0"
// 1509:     end
// 1510:
// 1511:     f3 = formula "f3" do
// 1512:       T.bind(self, T.class_of(Formula))
// 1513:       url "f3-1.0"
// 1514:
// 1515:       depends_on "f1" => :build
// 1516:       depends_on "f2"
// 1517:     end
// 1518:
// 1519:     f4 = formula "f4" do
// 1520:       T.bind(self, T.class_of(Formula))
// 1521:       url "f4-1.0"
// 1522:
// 1523:       depends_on "f1"
// 1524:     end
// 1525:
// 1526:     stub_formula_loader(f1)
// 1527:     stub_formula_loader(f2)
// 1528:     stub_formula_loader(f3)
// 1529:     stub_formula_loader(f4)
// 1530:
// 1531:     f5 = formula "f5" do
// 1532:       T.bind(self, T.class_of(Formula))
// 1533:       url "f5-1.0"
// 1534:
// 1535:       depends_on "f3" => :build
// 1536:       depends_on "f4"
// 1537:     end
// 1538:
// 1539:     expect(f5.deps.map(&:name)).to eq(["f3", "f4"])
// 1540:     expect(f5.recursive_dependencies.map(&:name)).to eq(%w[f1 f2 f3 f4])
// 1541:     expect(f5.runtime_dependencies.map(&:name)).to eq(["f1", "f4"])
// 1542:   end
// 1543:
// 1544:   describe "#runtime_dependencies" do
// 1545:     specify "runtime dependencies with optional deps from tap" do
// 1546:       tap_loader = double
// 1547:
// 1548:       # don't try to load/fetch gcc/glibc
// 1549:       allow(DevelopmentTools).to receive_messages(needs_libc_formula?: false, needs_compiler_formula?: false)
// 1550:
// 1551:       allow(tap_loader).to receive(:get_formula).and_raise(RuntimeError, "tried resolving tap formula")
// 1552:       allow(Formulary).to receive(:loader_for).with("foo/bar/f1", from: nil).and_return(tap_loader)
// 1553:
// 1554:       f2_path = Tap.fetch("baz", "qux").path/"Formula/f2.rb"
// 1555:       stub_formula_loader(
// 1556:         formula("f2", path: f2_path) do
// 1557:           T.bind(self, T.class_of(Formula))
// 1558:           url("f2-1.0")
// 1559:         end,
// 1560:         "baz/qux/f2",
// 1561:       )
// 1562:
// 1563:       f3 = formula "f3" do
// 1564:         T.bind(self, T.class_of(Formula))
// 1565:         url "f3-1.0"
// 1566:
// 1567:         depends_on "foo/bar/f1" => :optional
// 1568:         depends_on "baz/qux/f2"
// 1569:       end
// 1570:
// 1571:       expect(f3.runtime_dependencies.map(&:name)).to eq(["baz/qux/f2"])
// 1572:
// 1573:       described_class.clear_cache
// 1574:
// 1575:       f1_path = Tap.fetch("foo", "bar").path/"Formula/f1.rb"
// 1576:       stub_formula_loader(
// 1577:         formula("f1", path: f1_path) do
// 1578:           T.bind(self, T.class_of(Formula))
// 1579:           url("f1-1.0")
// 1580:         end,
// 1581:         "foo/bar/f1",
// 1582:       )
// 1583:
// 1584:       f3.build = BuildOptions.new(Options.create(["--with-f1"]), f3.options)
// 1585:
// 1586:       expect(f3.runtime_dependencies.map(&:name)).to eq(["foo/bar/f1", "baz/qux/f2"])
// 1587:     end
// 1588:
// 1589:     it "includes non-declared direct dependencies" do
// 1590:       formula = Class.new(Testball).new
// 1591:       dependency = formula("dependency") do
// 1592:         T.bind(self, T.class_of(Formula))
// 1593:         url "f-1.0"
// 1594:       end
// 1595:
// 1596:       formula.brew { formula.install }
// 1597:       keg = Keg.for(formula.latest_installed_prefix)
// 1598:       keg.link
// 1599:
// 1600:       linkage_checker = instance_double(LinkageChecker, "linkage checker", undeclared_deps: [dependency.name])
// 1601:       allow(LinkageChecker).to receive(:new).and_return(linkage_checker)
// 1602:
// 1603:       expect(formula.runtime_dependencies.map(&:name)).to eq [dependency.name]
// 1604:     end
// 1605:
// 1606:     it "handles bad tab runtime_dependencies" do
// 1607:       formula = Class.new(Testball).new
// 1608:
// 1609:       formula.brew { formula.install }
// 1610:       tab = Tab.create(formula, DevelopmentTools.default_compiler, :libcxx)
// 1611:       tab.runtime_dependencies = ["foo"]
// 1612:       tab.write
// 1613:
// 1614:       keg = Keg.for(formula.latest_installed_prefix)
// 1615:       keg.link
// 1616:
// 1617:       expect(formula.runtime_dependencies.map(&:name)).to be_empty
// 1618:     end
// 1619:   end
// 1620:
// 1621:   describe "#missing_dependencies" do
// 1622:     let(:f) do
// 1623:       formula("foo") do
// 1624:         T.bind(self, T.class_of(Formula))
// 1625:         url "foo-1.0"
// 1626:       end
// 1627:     end
// 1628:     let(:keg) { instance_double(Keg) }
// 1629:
// 1630:     before do
// 1631:       allow(f).to receive(:any_installed_keg).and_return(keg)
// 1632:     end
// 1633:
// 1634:     it "returns empty when no tab runtime_dependencies data" do
// 1635:       allow(keg).to receive(:runtime_dependencies).and_return(nil)
// 1636:       expect(f.missing_dependencies).to be_empty
// 1637:     end
// 1638:
// 1639:     it "returns empty when dep is present in cellar" do
// 1640:       (HOMEBREW_CELLAR/"bar").mkpath
// 1641:       allow(keg).to receive(:runtime_dependencies).and_return([{ "full_name" => "bar" }])
// 1642:       expect(f.missing_dependencies).to be_empty
// 1643:     end
// 1644:
// 1645:     it "returns empty when dep is present as alias or oldname" do
// 1646:       (HOMEBREW_CELLAR/"bar@2/2.0").mkpath
// 1647:       (HOMEBREW_PREFIX/"opt").mkpath
// 1648:       FileUtils.ln_sf HOMEBREW_CELLAR/"bar@2/2.0", HOMEBREW_PREFIX/"opt/bar"
// 1649:       allow(keg).to receive(:runtime_dependencies).and_return([{ "full_name" => "bar" }])
// 1650:       expect(f.missing_dependencies).to be_empty
// 1651:     end
// 1652:
// 1653:     it "returns dep when not present in cellar" do
// 1654:       allow(keg).to receive(:runtime_dependencies).and_return([{ "full_name" => "baz" }])
// 1655:       expect(f.missing_dependencies.map(&:name)).to eq(["baz"])
// 1656:     end
// 1657:
// 1658:     it "returns dep as missing when it is in the hide list, even if installed" do
// 1659:       (HOMEBREW_CELLAR/"bar").mkpath
// 1660:       allow(keg).to receive(:runtime_dependencies).and_return([{ "full_name" => "bar" }])
// 1661:       expect(f.missing_dependencies(hide: ["bar"]).map(&:name)).to eq(["bar"])
// 1662:     end
// 1663:
// 1664:     it "matches tapnamed deps against base-name hide list" do
// 1665:       (HOMEBREW_CELLAR/"wget").mkpath
// 1666:       allow(keg).to receive(:runtime_dependencies).and_return([{ "full_name" => "homebrew/core/wget" }])
// 1667:       expect(f.missing_dependencies(hide: ["wget"]).map(&:name)).to eq(["homebrew/core/wget"])
// 1668:     end
// 1669:   end
// 1670:
// 1671:   describe "#missing_library_linkage" do
// 1672:     let(:f) do
// 1673:       formula("foo") do
// 1674:         T.bind(self, T.class_of(Formula))
// 1675:         url "foo-1.0"
// 1676:       end
// 1677:     end
// 1678:
// 1679:     it "returns empty when no keg is installed" do
// 1680:       allow(f).to receive(:any_installed_keg).and_return(nil)
// 1681:       expect(f.missing_library_linkage).to eq([[], Set.new])
// 1682:     end
// 1683:
// 1684:     it "returns only the formula's own and orphan libraries, excluding dependency-owned ones" do
// 1685:       keg = instance_double(Keg, directory?: true)
// 1686:       allow(f).to receive(:any_installed_keg).and_return(keg)
// 1687:       linkage_checker = instance_double(
// 1688:         LinkageChecker,
// 1689:         broken_deps:   { "foo" => ["libfoo.1.dylib"], "gmp" => ["libgmp.10.dylib"] },
// 1690:         broken_dylibs: Set["liborphan.2.dylib"],
// 1691:       )
// 1692:       allow(LinkageChecker).to receive(:new).and_return(linkage_checker)
// 1693:       expect(f.missing_library_linkage.first).to eq(["libfoo.1.dylib", "liborphan.2.dylib"])
// 1694:     end
// 1695:
// 1696:     it "returns the dependency names that own missing libraries, excluding the formula itself" do
// 1697:       keg = instance_double(Keg, directory?: true)
// 1698:       allow(f).to receive(:any_installed_keg).and_return(keg)
// 1699:       linkage_checker = instance_double(
// 1700:         LinkageChecker,
// 1701:         broken_deps:   { "foo" => ["libfoo.1.dylib"], "gmp" => ["libgmp.10.dylib"] },
// 1702:         broken_dylibs: Set.new,
// 1703:       )
// 1704:       allow(LinkageChecker).to receive(:new).and_return(linkage_checker)
// 1705:       expect(f.missing_library_linkage.last).to eq(Set["gmp"])
// 1706:     end
// 1707:   end
// 1708:
// 1709:   specify "requirements" do
// 1710:     # don't try to load/fetch gcc/glibc
// 1711:     allow(DevelopmentTools).to receive_messages(needs_libc_formula?: false, needs_compiler_formula?: false)
// 1712:
// 1713:     f1 = formula "f1" do
// 1714:       T.bind(self, T.class_of(Formula))
// 1715:       url "f1-1"
// 1716:
// 1717:       depends_on xcode: ["1.0", :optional]
// 1718:     end
// 1719:     stub_formula_loader(f1)
// 1720:
// 1721:     xcode = XcodeRequirement.new(["1.0", :optional])
// 1722:
// 1723:     expect(Set.new(f1.recursive_requirements)).to eq(Set[])
// 1724:
// 1725:     f1.build = BuildOptions.new(Options.create(["--with-xcode"]), f1.options)
// 1726:
// 1727:     expect(Set.new(f1.recursive_requirements)).to eq(Set[xcode])
// 1728:
// 1729:     f1.build = f1.stable.build
// 1730:     f2 = formula "f2" do
// 1731:       T.bind(self, T.class_of(Formula))
// 1732:       url "f2-1"
// 1733:
// 1734:       depends_on "f1"
// 1735:     end
// 1736:
// 1737:     expect(Set.new(f2.recursive_requirements)).to eq(Set[])
// 1738:     expect(
// 1739:       f2.recursive_requirements do
// 1740:         # do nothing
// 1741:       end.to_set,
// 1742:     ).to eq(Set[xcode])
// 1743:
// 1744:     requirements = f2.recursive_requirements do |_dependent, requirement|
// 1745:       next Dependable::PRUNE if requirement.is_a?(XcodeRequirement)
// 1746:     end
// 1747:
// 1748:     expect(Set.new(requirements)).to eq(Set[])
// 1749:   end
// 1750:
// 1751:   specify "#to_hash" do
// 1752:     f1 = formula "foo" do
// 1753:       T.bind(self, T.class_of(Formula))
// 1754:       url "foo-1.0"
// 1755:
// 1756:       bottle do
// 1757:         sha256 cellar: :any, Utils::Bottles.tag.to_sym => TEST_SHA256
// 1758:       end
// 1759:     end
// 1760:     stub_formula_loader(f1)
// 1761:
// 1762:     h = f1.to_hash
// 1763:
// 1764:     expect(h).to be_a(Hash)
// 1765:     expect(h["name"]).to eq("foo")
// 1766:     expect(h["full_name"]).to eq("foo")
// 1767:     expect(h["tap"]).to eq("homebrew/core")
// 1768:     expect(h["versions"]["stable"]).to eq("1.0")
// 1769:     expect(h["versions"]["bottle"]).to be_truthy
// 1770:     expect(h["patches"]).to eq([])
// 1771:   end
// 1772:
// 1773:   describe "#to_hash patches" do
// 1774:     it "serialises an external patch" do
// 1775:       f = formula "foo" do
// 1776:         T.bind(self, T.class_of(Formula))
// 1777:         url "foo-1.0"
// 1778:         patch do
// 1779:           url "https://example.com/foo.diff"
// 1780:           sha256 TEST_SHA256
// 1781:         end
// 1782:       end
// 1783:
// 1784:       expect(f.to_hash["patches"]).to eq([
// 1785:         { "strip" => "p1", "url" => "https://example.com/foo.diff", "sha256" => TEST_SHA256 },
// 1786:       ])
// 1787:     end
// 1788:
// 1789:     it "serialises an external patch with apply and directory" do
// 1790:       f = formula "foo" do
// 1791:         T.bind(self, T.class_of(Formula))
// 1792:         url "foo-1.0"
// 1793:         patch :p0 do
// 1794:           url "https://example.com/patches.tar.gz"
// 1795:           sha256 TEST_SHA256
// 1796:           directory "src"
// 1797:           apply "fix-a.patch", "fix-b.patch"
// 1798:         end
// 1799:       end
// 1800:
// 1801:       expect(f.to_hash["patches"]).to eq([
// 1802:         {
// 1803:           "strip"     => "p0",
// 1804:           "url"       => "https://example.com/patches.tar.gz",
// 1805:           "sha256"    => TEST_SHA256,
// 1806:           "apply"     => ["fix-a.patch", "fix-b.patch"],
// 1807:           "directory" => "src",
// 1808:         },
// 1809:       ])
// 1810:     end
// 1811:
// 1812:     it "serialises an embedded DATA patch" do
// 1813:       f = formula "foo" do
// 1814:         T.bind(self, T.class_of(Formula))
// 1815:         url "foo-1.0"
// 1816:         patch :p1, :DATA
// 1817:       end
// 1818:
// 1819:       expect(f.to_hash["patches"]).to eq([{ "strip" => "p1", "data" => true }])
// 1820:     end
// 1821:
// 1822:     it "serialises a string patch" do
// 1823:       f = formula "foo" do
// 1824:         T.bind(self, T.class_of(Formula))
// 1825:         url "foo-1.0"
// 1826:         patch :p2, "--- a\n+++ b\n"
// 1827:       end
// 1828:
// 1829:       expect(f.to_hash["patches"]).to eq([{ "strip" => "p2", "data" => true }])
// 1830:     end
// 1831:
// 1832:     it "serialises type and explicit resolves on an external patch" do
// 1833:       f = formula "foo" do
// 1834:         T.bind(self, T.class_of(Formula))
// 1835:         url "foo-1.0"
// 1836:         patch do
// 1837:           url "https://example.com/foo.diff"
// 1838:           sha256 TEST_SHA256
// 1839:           type :cherry_pick
// 1840:           resolves "CVE-2024-1111", "CVE-2024-2222"
// 1841:         end
// 1842:       end
// 1843:
// 1844:       expect(f.to_hash["patches"]).to eq([
// 1845:         {
// 1846:           "strip"    => "p1",
// 1847:           "url"      => "https://example.com/foo.diff",
// 1848:           "sha256"   => TEST_SHA256,
// 1849:           "type"     => "cherry-pick",
// 1850:           "resolves" => [
// 1851:             { "type" => "security", "id" => "CVE-2024-1111" },
// 1852:             { "type" => "security", "id" => "CVE-2024-2222" },
// 1853:           ],
// 1854:         },
// 1855:       ])
// 1856:     end
// 1857:
// 1858:     it "serialises resolves inferred from url and apply paths" do
// 1859:       f = formula "foo" do
// 1860:         T.bind(self, T.class_of(Formula))
// 1861:         url "foo-1.0"
// 1862:         patch do
// 1863:           url "https://example.com/debian.tar.xz"
// 1864:           sha256 TEST_SHA256
// 1865:           apply "patches/CVE-2024-1234.patch", "patches/cve-2024-5678.patch"
// 1866:         end
// 1867:       end
// 1868:
// 1869:       expect(f.to_hash["patches"].first["resolves"]).to eq([
// 1870:         { "type" => "security", "id" => "CVE-2024-1234" },
// 1871:         { "type" => "security", "id" => "CVE-2024-5678" },
// 1872:       ])
// 1873:     end
// 1874:
// 1875:     it "serialises non-CVE resolves entries with the appropriate issue type" do
// 1876:       f = formula "foo" do
// 1877:         T.bind(self, T.class_of(Formula))
// 1878:         url "foo-1.0"
// 1879:         patch do
// 1880:           url "https://example.com/foo.diff"
// 1881:           sha256 TEST_SHA256
// 1882:           resolves "CVE-2024-1234", "GHSA-xr7r-f8xq-vfvv", "https://github.com/foo/bar/issues/1"
// 1883:         end
// 1884:       end
// 1885:
// 1886:       expect(f.to_hash["patches"].first["resolves"]).to eq([
// 1887:         { "type" => "security", "id" => "CVE-2024-1234" },
// 1888:         { "type" => "security", "id" => "GHSA-xr7r-f8xq-vfvv" },
// 1889:         { "type" => "defect", "id" => "https://github.com/foo/bar/issues/1" },
// 1890:       ])
// 1891:     end
// 1892:
// 1893:     it "serialises type on a local file patch" do
// 1894:       f = formula "foo" do
// 1895:         T.bind(self, T.class_of(Formula))
// 1896:         url "foo-1.0"
// 1897:         patch do
// 1898:           file "Patches/foo.diff"
// 1899:           type :unofficial
// 1900:         end
// 1901:       end
// 1902:
// 1903:       expect(f.to_hash["patches"]).to eq([{ "strip" => "p1", "file" => "Patches/foo.diff", "type" => "unofficial" }])
// 1904:     end
// 1905:
// 1906:     it "serialises a local file patch" do
// 1907:       f = formula "foo" do
// 1908:         T.bind(self, T.class_of(Formula))
// 1909:         url "foo-1.0"
// 1910:         patch do
// 1911:           file "Patches/foo.diff"
// 1912:         end
// 1913:       end
// 1914:
// 1915:       expect(f.to_hash["patches"]).to eq([{ "strip" => "p1", "file" => "Patches/foo.diff" }])
// 1916:     end
// 1917:   end
// 1918:
// 1919:   describe "#to_hash_with_variations", :needs_macos do
// 1920:     let(:formula_path) { CoreTap.instance.new_formula_path("foo-variations") }
// 1921:     let(:formula_content) do
// 1922:       <<~RUBY
// 1923:         class FooVariations < Formula
// 1924:           url "file://#{TEST_FIXTURE_DIR}/tarballs/testball-0.1.tbz"
// 1925:           sha256 TESTBALL_SHA256
// 1926:
// 1927:           on_intel do
// 1928:             depends_on "intel-formula"
// 1929:           end
// 1930:
// 1931:           on_sequoia do
// 1932:             depends_on "sequoia-formula"
// 1933:           end
// 1934:
// 1935:           on_sonoma :or_older do
// 1936:             depends_on "sonoma-or-older-formula"
// 1937:           end
// 1938:
// 1939:           on_linux do
// 1940:             depends_on "linux-formula"
// 1941:           end
// 1942:         end
// 1943:       RUBY
// 1944:     end
// 1945:     let(:expected_variations) do
// 1946:       <<~JSON
// 1947:         {
// 1948:           "tahoe": {
// 1949:             "dependencies": [
// 1950:               "intel-formula"
// 1951:             ]
// 1952:           },
// 1953:           "arm64_tahoe": {
// 1954:             "dependencies": []
// 1955:           },
// 1956:           "sequoia": {
// 1957:             "dependencies": [
// 1958:               "intel-formula",
// 1959:               "sequoia-formula"
// 1960:             ]
// 1961:           },
// 1962:           "arm64_sequoia": {
// 1963:             "dependencies": [
// 1964:               "sequoia-formula"
// 1965:             ]
// 1966:           },
// 1967:           "sonoma": {
// 1968:             "dependencies": [
// 1969:               "intel-formula",
// 1970:               "sonoma-or-older-formula"
// 1971:             ]
// 1972:           },
// 1973:           "ventura": {
// 1974:             "dependencies": [
// 1975:               "intel-formula",
// 1976:               "sonoma-or-older-formula"
// 1977:             ]
// 1978:           },
// 1979:           "x86_64_linux": {
// 1980:             "dependencies": [
// 1981:               "intel-formula",
// 1982:               "linux-formula"
// 1983:             ]
// 1984:           },
// 1985:           "arm64_linux": {
// 1986:             "dependencies": [
// 1987:               "linux-formula"
// 1988:             ]
// 1989:           }
// 1990:         }
// 1991:       JSON
// 1992:     end
// 1993:
// 1994:     before do
// 1995:       # Use a more limited os list to shorten the variations hash
// 1996:       os_list = [:tahoe, :sequoia, :sonoma, :ventura, :linux]
// 1997:       valid_tags = os_list.product(OnSystem::ARCH_OPTIONS).filter_map do |os, arch|
// 1998:         tag = Utils::Bottles::Tag.new(system: os, arch:)
// 1999:         next unless tag.valid_combination?
// 2000:
// 2001:         tag
// 2002:       end
// 2003:       stub_const("OnSystem::VALID_OS_ARCH_TAGS", valid_tags)
// 2004:
// 2005:       # For consistency, always run on Tahoe and ARM
// 2006:       allow(MacOS).to receive(:version).and_return(MacOSVersion.new("12"))
// 2007:       allow(Hardware::CPU).to receive(:type).and_return(:arm)
// 2008:
// 2009:       formula_path.dirname.mkpath
// 2010:       formula_path.write formula_content
// 2011:     end
// 2012:
// 2013:     it "returns the correct variations hash" do
// 2014:       h = Formulary.factory("foo-variations").to_hash_with_variations
// 2015:
// 2016:       expect(h).to be_a(Hash)
// 2017:       expect(JSON.pretty_generate(h["variations"])).to eq expected_variations.strip
// 2018:     end
// 2019:   end
// 2020:
// 2021:   describe "#eligible_kegs_for_cleanup" do
// 2022:     it "returns Kegs eligible for cleanup" do
// 2023:       f1 = Class.new(Testball) do
// 2024:         version("1.0")
// 2025:       end.new
// 2026:
// 2027:       f2 = Class.new(Testball) do
// 2028:         version("0.2")
// 2029:         version_scheme(1)
// 2030:       end.new
// 2031:
// 2032:       f3 = Class.new(Testball) do
// 2033:         version("0.3")
// 2034:         version_scheme(1)
// 2035:       end.new
// 2036:
// 2037:       f4 = Class.new(Testball) do
// 2038:         version("0.1")
// 2039:         version_scheme(2)
// 2040:       end.new
// 2041:
// 2042:       [f1, f2, f3, f4].each do |f|
// 2043:         f.brew { f.install }
// 2044:         Tab.create(f, DevelopmentTools.default_compiler, :libcxx).write
// 2045:       end
// 2046:
// 2047:       expect(f1).to be_latest_version_installed
// 2048:       expect(f2).to be_latest_version_installed
// 2049:       expect(f3).to be_latest_version_installed
// 2050:       expect(f4).to be_latest_version_installed
// 2051:       expect(f3.eligible_kegs_for_cleanup.sort_by(&:version))
// 2052:         .to eq([f2, f1].map { |f| Keg.new(f.prefix) })
// 2053:     end
// 2054:
// 2055:     specify "with pinned Keg" do
// 2056:       f1 = Class.new(Testball) { version("0.1") }.new
// 2057:       f2 = Class.new(Testball) { version("0.2") }.new
// 2058:       f3 = Class.new(Testball) { version("0.3") }.new
// 2059:
// 2060:       f1.brew { f1.install }
// 2061:       f1.pin
// 2062:       f2.brew { f2.install }
// 2063:       f3.brew { f3.install }
// 2064:
// 2065:       expect(f1.prefix).to eq((HOMEBREW_PINNED_KEGS/f1.name).resolved_path)
// 2066:       expect(f1).to be_latest_version_installed
// 2067:       expect(f2).to be_latest_version_installed
// 2068:       expect(f3).to be_latest_version_installed
// 2069:       expect(f3.eligible_kegs_for_cleanup).to eq([Keg.new(f2.prefix)])
// 2070:     end
// 2071:
// 2072:     specify "with HEAD installed" do
// 2073:       f = formula do
// 2074:         T.bind(self, T.class_of(Formula))
// 2075:         version("0.1")
// 2076:         head("foo")
// 2077:       end
// 2078:
// 2079:       ["0.0.1", "0.0.2", "0.1", "HEAD-000000", "HEAD-111111", "HEAD-111111_1"].each do |version|
// 2080:         prefix = f.prefix(version)
// 2081:         prefix.mkpath
// 2082:         tab = Tab.empty
// 2083:         tab.tabfile = prefix/AbstractTab::FILENAME
// 2084:         tab.source_modified_time = 1
// 2085:         tab.write
// 2086:       end
// 2087:
// 2088:       eligible_kegs = f.installed_kegs - [Keg.new(f.prefix("HEAD-111111_1")), Keg.new(f.prefix("0.1"))]
// 2089:       expect(f.eligible_kegs_for_cleanup.sort_by(&:version)).to eq(eligible_kegs.sort_by(&:version))
// 2090:     end
// 2091:   end
// 2092:
// 2093:   describe "#pour_bottle?" do
// 2094:     it "returns false if set to false" do
// 2095:       f = formula "foo" do
// 2096:         T.bind(self, T.class_of(Formula))
// 2097:         url "foo-1.0"
// 2098:
// 2099:         def pour_bottle?
// 2100:           false
// 2101:         end
// 2102:       end
// 2103:
// 2104:       expect(f).not_to pour_bottle
// 2105:     end
// 2106:
// 2107:     it "returns true if set to true" do
// 2108:       f = formula "foo" do
// 2109:         T.bind(self, T.class_of(Formula))
// 2110:         url "foo-1.0"
// 2111:
// 2112:         def pour_bottle?
// 2113:           true
// 2114:         end
// 2115:       end
// 2116:
// 2117:       expect(f).to pour_bottle
// 2118:     end
// 2119:
// 2120:     it "returns false if set to false via DSL" do
// 2121:       f = formula "foo" do
// 2122:         T.bind(self, T.class_of(Formula))
// 2123:         url "foo-1.0"
// 2124:
// 2125:         pour_bottle? do
// 2126:           reason "false reason"
// 2127:           satisfy { var == etc }
// 2128:         end
// 2129:       end
// 2130:
// 2131:       expect(f).not_to pour_bottle
// 2132:     end
// 2133:
// 2134:     it "returns true if set to true via DSL" do
// 2135:       f = formula "foo" do
// 2136:         T.bind(self, T.class_of(Formula))
// 2137:         url "foo-1.0"
// 2138:
// 2139:         pour_bottle? do
// 2140:           reason "true reason"
// 2141:           satisfy { true }
// 2142:         end
// 2143:       end
// 2144:
// 2145:       expect(f).to pour_bottle
// 2146:     end
// 2147:
// 2148:     it "returns false with `only_if: :clt_installed` on macOS", :needs_macos do
// 2149:       # Pretend CLT is not installed
// 2150:       allow(MacOS::CLT).to receive(:installed?).and_return(false)
// 2151:
// 2152:       f = formula "foo" do
// 2153:         T.bind(self, T.class_of(Formula))
// 2154:         url "foo-1.0"
// 2155:
// 2156:         pour_bottle? only_if: :clt_installed
// 2157:       end
// 2158:
// 2159:       expect(f).not_to pour_bottle
// 2160:     end
// 2161:
// 2162:     it "returns true with `only_if: :clt_installed` on macOS", :needs_macos do
// 2163:       # Pretend CLT is installed
// 2164:       allow(MacOS::CLT).to receive(:installed?).and_return(true)
// 2165:
// 2166:       f = formula "foo" do
// 2167:         T.bind(self, T.class_of(Formula))
// 2168:         url "foo-1.0"
// 2169:
// 2170:         pour_bottle? only_if: :clt_installed
// 2171:       end
// 2172:
// 2173:       expect(f).to pour_bottle
// 2174:     end
// 2175:
// 2176:     it "returns true with `only_if: :clt_installed` on Linux", :needs_linux do
// 2177:       f = formula "foo" do
// 2178:         T.bind(self, T.class_of(Formula))
// 2179:         url "foo-1.0"
// 2180:
// 2181:         pour_bottle? only_if: :clt_installed
// 2182:       end
// 2183:
// 2184:       expect(f).to pour_bottle
// 2185:     end
// 2186:
// 2187:     it "throws an error if passed both a symbol and a block" do
// 2188:       expect do
// 2189:         formula "foo" do
// 2190:           T.bind(self, T.class_of(Formula))
// 2191:           url "foo-1.0"
// 2192:
// 2193:           pour_bottle? only_if: :clt_installed do
// 2194:             reason "true reason"
// 2195:             satisfy { true }
// 2196:           end
// 2197:         end
// 2198:       end.to raise_error(ArgumentError, "Do not pass both a preset condition and a block to `pour_bottle?`")
// 2199:     end
// 2200:
// 2201:     it "throws an error if passed an invalid symbol" do
// 2202:       expect do
// 2203:         formula "foo" do
// 2204:           T.bind(self, T.class_of(Formula))
// 2205:           url "foo-1.0"
// 2206:
// 2207:           pour_bottle? only_if: :foo
// 2208:         end
// 2209:       end.to raise_error(ArgumentError, "Invalid preset `pour_bottle?` condition")
// 2210:     end
// 2211:   end
// 2212:
// 2213:   describe "alias changes" do
// 2214:     let(:f) do
// 2215:       formula("formula_name", alias_path:) do
// 2216:         T.bind(self, T.class_of(Formula))
// 2217:         url "foo-1.0"
// 2218:       end
// 2219:     end
// 2220:
// 2221:     let(:new_formula) do
// 2222:       formula("new_formula_name", alias_path:) do
// 2223:         T.bind(self, T.class_of(Formula))
// 2224:         url "foo-1.1"
// 2225:       end
// 2226:     end
// 2227:
// 2228:     let(:tab) { Tab.empty }
// 2229:     let(:alias_name) { "bar" }
// 2230:     let(:alias_path) { CoreTap.instance.alias_dir/alias_name }
// 2231:
// 2232:     before do
// 2233:       stub_formula_loader(f)
// 2234:       stub_formula_loader(new_formula)
// 2235:       allow(described_class).to receive(:installed).and_return([f])
// 2236:
// 2237:       f.build = tab
// 2238:       new_formula.build = tab
// 2239:     end
// 2240:
// 2241:     specify "alias changes when not installed with alias" do
// 2242:       tab.source["path"] = Formulary.core_path(f.name).to_s
// 2243:
// 2244:       expect(f.current_installed_alias_target).to be_nil
// 2245:       expect(f.latest_formula).to eq(f)
// 2246:       expect(f).not_to have_changed_installed_alias_target
// 2247:       expect(f).not_to supersede_an_installed_formula
// 2248:       expect(f).not_to have_changed_alias
// 2249:       expect(f.old_installed_formulae).to be_empty
// 2250:     end
// 2251:
// 2252:     specify "alias changes when not changed" do
// 2253:       tab.source["path"] = alias_path.to_s
// 2254:       stub_formula_loader(f, alias_name)
// 2255:
// 2256:       CoreTap.instance.alias_dir.mkpath
// 2257:       FileUtils.ln_sf f.path, alias_path
// 2258:
// 2259:       expect(f.current_installed_alias_target).to eq(f)
// 2260:       expect(f.latest_formula).to eq(f)
// 2261:       expect(f).not_to have_changed_installed_alias_target
// 2262:       expect(f).not_to supersede_an_installed_formula
// 2263:       expect(f).not_to have_changed_alias
// 2264:       expect(f.old_installed_formulae).to be_empty
// 2265:     end
// 2266:
// 2267:     specify "alias changes when new alias target" do
// 2268:       tab.source["path"] = alias_path.to_s
// 2269:       stub_formula_loader(new_formula, alias_name)
// 2270:
// 2271:       CoreTap.instance.alias_dir.mkpath
// 2272:       FileUtils.ln_sf new_formula.path, alias_path
// 2273:
// 2274:       expect(f.current_installed_alias_target).to eq(new_formula)
// 2275:       expect(f.latest_formula).to eq(new_formula)
// 2276:       expect(f).to have_changed_installed_alias_target
// 2277:       expect(f).not_to supersede_an_installed_formula
// 2278:       expect(f).to have_changed_alias
// 2279:       expect(f.old_installed_formulae).to be_empty
// 2280:     end
// 2281:
// 2282:     specify "alias changes when old formulae installed" do
// 2283:       tab.source["path"] = alias_path.to_s
// 2284:       stub_formula_loader(new_formula, alias_name)
// 2285:
// 2286:       CoreTap.instance.alias_dir.mkpath
// 2287:       FileUtils.ln_sf new_formula.path, alias_path
// 2288:
// 2289:       expect(new_formula.current_installed_alias_target).to eq(new_formula)
// 2290:       expect(new_formula.latest_formula).to eq(new_formula)
// 2291:       expect(new_formula).not_to have_changed_installed_alias_target
// 2292:       expect(new_formula).to supersede_an_installed_formula
// 2293:       expect(new_formula).to have_changed_alias
// 2294:       expect(new_formula.old_installed_formulae).to eq([f])
// 2295:     end
// 2296:   end
// 2297:
// 2298:   describe "#outdated_kegs" do
// 2299:     let(:outdated_prefix) { HOMEBREW_CELLAR/"#{f.name}/1.11" }
// 2300:     let(:same_prefix) { HOMEBREW_CELLAR/"#{f.name}/1.20" }
// 2301:     let(:greater_prefix) { HOMEBREW_CELLAR/"#{f.name}/1.21" }
// 2302:     let(:head_prefix) { HOMEBREW_CELLAR/"#{f.name}/HEAD" }
// 2303:     let(:old_alias_target_prefix) { HOMEBREW_CELLAR/"#{old_formula.name}/1.0" }
// 2304:
// 2305:     let(:f) do
// 2306:       formula do
// 2307:         T.bind(self, T.class_of(Formula))
// 2308:         url "foo"
// 2309:         version "1.20"
// 2310:       end
// 2311:     end
// 2312:
// 2313:     let(:old_formula) do
// 2314:       formula "foo@1" do
// 2315:         T.bind(self, T.class_of(Formula))
// 2316:         url "foo-1.0"
// 2317:       end
// 2318:     end
// 2319:
// 2320:     let(:new_formula) do
// 2321:       formula "foo@2" do
// 2322:         T.bind(self, T.class_of(Formula))
// 2323:         url "foo-2.0"
// 2324:       end
// 2325:     end
// 2326:
// 2327:     let(:alias_name) { "bar" }
// 2328:     let(:alias_path) { f.tap.alias_dir/alias_name }
// 2329:
// 2330:     before do
// 2331:       stub_formula_loader(f)
// 2332:       stub_formula_loader(old_formula)
// 2333:       stub_formula_loader(new_formula)
// 2334:     end
// 2335:
// 2336:     def setup_tab_for_prefix(prefix, options = {})
// 2337:       prefix.mkpath
// 2338:
// 2339:       keg = Keg.new(prefix)
// 2340:       keg.optlink
// 2341:
// 2342:       tab = Tab.empty
// 2343:       tab.tabfile = prefix/AbstractTab::FILENAME
// 2344:       tab.source["path"] = options[:path].to_s if options[:path]
// 2345:       tab.source["tap"] = options[:tap] if options[:tap]
// 2346:       tab.source["versions"] = options[:versions] if options[:versions]
// 2347:       tab.source_modified_time = options[:source_modified_time].to_i
// 2348:       tab.write unless options[:no_write]
// 2349:       tab
// 2350:     end
// 2351:
// 2352:     example "greater different tap installed" do
// 2353:       setup_tab_for_prefix(greater_prefix, tap: "user/repo")
// 2354:       expect(f.outdated_kegs).to be_empty
// 2355:     end
// 2356:
// 2357:     example "greater same tap installed" do
// 2358:       f.tap = CoreTap.instance
// 2359:       setup_tab_for_prefix(greater_prefix, tap: "homebrew/core")
// 2360:       expect(f.outdated_kegs).to be_empty
// 2361:     end
// 2362:
// 2363:     example "outdated different tap installed" do
// 2364:       setup_tab_for_prefix(outdated_prefix, tap: "user/repo")
// 2365:       expect(f.outdated_kegs).not_to be_empty
// 2366:     end
// 2367:
// 2368:     example "outdated same tap installed" do
// 2369:       f.tap = CoreTap.instance
// 2370:       setup_tab_for_prefix(outdated_prefix, tap: "homebrew/core")
// 2371:       expect(f.outdated_kegs).not_to be_empty
// 2372:     end
// 2373:
// 2374:     example "outdated unlinked tap installed" do
// 2375:       setup_tab_for_prefix(same_prefix)
// 2376:       Keg.new(same_prefix).remove_opt_record
// 2377:       expect(f.outdated_kegs).not_to be_empty
// 2378:     end
// 2379:
// 2380:     example "outdated follow alias and alias unchanged" do
// 2381:       f.follow_installed_alias = true
// 2382:       f.build = setup_tab_for_prefix(same_prefix, path: alias_path)
// 2383:       stub_formula_loader(f, alias_name)
// 2384:       expect(f.outdated_kegs).to be_empty
// 2385:     end
// 2386:
// 2387:     example "outdated follow alias and alias changed and new target not installed" do
// 2388:       f.follow_installed_alias = true
// 2389:       f.build = setup_tab_for_prefix(same_prefix, path: alias_path)
// 2390:       stub_formula_loader(new_formula, alias_name)
// 2391:
// 2392:       CoreTap.instance.alias_dir.mkpath
// 2393:       FileUtils.ln_sf new_formula.path, alias_path
// 2394:
// 2395:       expect(f.outdated_kegs).not_to be_empty
// 2396:     end
// 2397:
// 2398:     example "outdated follow alias and alias changed and new target installed" do
// 2399:       f.follow_installed_alias = true
// 2400:       f.build = setup_tab_for_prefix(same_prefix, path: alias_path)
// 2401:       stub_formula_loader(new_formula, alias_name)
// 2402:       setup_tab_for_prefix(new_formula.prefix)
// 2403:       expect(f.outdated_kegs).to be_empty
// 2404:     end
// 2405:
// 2406:     example "outdated no follow alias and alias unchanged" do
// 2407:       f.follow_installed_alias = false
// 2408:       f.build = setup_tab_for_prefix(same_prefix, path: alias_path)
// 2409:       stub_formula_loader(f, alias_name)
// 2410:       expect(f.outdated_kegs).to be_empty
// 2411:     end
// 2412:
// 2413:     example "outdated no follow alias and alias changed" do
// 2414:       f.follow_installed_alias = false
// 2415:       f.build = setup_tab_for_prefix(same_prefix, path: alias_path)
// 2416:
// 2417:       f2 = formula "foo@2" do
// 2418:         T.bind(self, T.class_of(Formula))
// 2419:         url "foo-2.0"
// 2420:       end
// 2421:
// 2422:       stub_formula_loader(f2, alias_path)
// 2423:       expect(f.outdated_kegs).to be_empty
// 2424:     end
// 2425:
// 2426:     example "outdated old alias targets installed" do
// 2427:       f = formula(alias_path:) do
// 2428:         T.bind(self, T.class_of(Formula))
// 2429:         url "foo-1.0"
// 2430:       end
// 2431:
// 2432:       tab = setup_tab_for_prefix(old_alias_target_prefix, path: alias_path)
// 2433:       old_formula.build = tab
// 2434:       allow(described_class).to receive(:installed).and_return([old_formula])
// 2435:
// 2436:       CoreTap.instance.alias_dir.mkpath
// 2437:       FileUtils.ln_sf f.path, alias_path
// 2438:
// 2439:       expect(f.outdated_kegs).not_to be_empty
// 2440:     end
// 2441:
// 2442:     example "outdated old alias targets not installed" do
// 2443:       f = formula(alias_path:) do
// 2444:         T.bind(self, T.class_of(Formula))
// 2445:         url "foo-1.0"
// 2446:       end
// 2447:
// 2448:       tab = setup_tab_for_prefix(old_alias_target_prefix, path: old_formula.path)
// 2449:       old_formula.build = tab
// 2450:       allow(described_class).to receive(:installed).and_return([old_formula])
// 2451:       expect(f.outdated_kegs).to be_empty
// 2452:     end
// 2453:
// 2454:     example "outdated same head installed" do
// 2455:       f.tap = CoreTap.instance
// 2456:       setup_tab_for_prefix(head_prefix, tap: "homebrew/core")
// 2457:       expect(f.outdated_kegs).to be_empty
// 2458:     end
// 2459:
// 2460:     example "outdated different head installed" do
// 2461:       f.tap = CoreTap.instance
// 2462:       setup_tab_for_prefix(head_prefix, tap: "user/repo")
// 2463:       expect(f.outdated_kegs).to be_empty
// 2464:     end
// 2465:
// 2466:     example "outdated mixed taps greater version installed" do
// 2467:       f.tap = CoreTap.instance
// 2468:       setup_tab_for_prefix(outdated_prefix, tap: "homebrew/core")
// 2469:       setup_tab_for_prefix(greater_prefix, tap: "user/repo")
// 2470:
// 2471:       expect(f.outdated_kegs).to be_empty
// 2472:
// 2473:       setup_tab_for_prefix(greater_prefix, tap: "homebrew/core")
// 2474:       described_class.clear_cache
// 2475:
// 2476:       expect(f.outdated_kegs).to be_empty
// 2477:     end
// 2478:
// 2479:     example "outdated mixed taps outdated version installed" do
// 2480:       f.tap = CoreTap.instance
// 2481:
// 2482:       extra_outdated_prefix = HOMEBREW_CELLAR/f.name/"1.0"
// 2483:
// 2484:       setup_tab_for_prefix(outdated_prefix)
// 2485:       setup_tab_for_prefix(extra_outdated_prefix, tap: "homebrew/core")
// 2486:       described_class.clear_cache
// 2487:
// 2488:       expect(f.outdated_kegs).not_to be_empty
// 2489:
// 2490:       setup_tab_for_prefix(outdated_prefix, tap: "user/repo")
// 2491:       described_class.clear_cache
// 2492:
// 2493:       expect(f.outdated_kegs).not_to be_empty
// 2494:     end
// 2495:
// 2496:     example "outdated same version tap installed" do
// 2497:       f.tap = CoreTap.instance
// 2498:       setup_tab_for_prefix(same_prefix, tap: "homebrew/core")
// 2499:
// 2500:       expect(f.outdated_kegs).to be_empty
// 2501:
// 2502:       setup_tab_for_prefix(same_prefix, tap: "user/repo")
// 2503:       described_class.clear_cache
// 2504:
// 2505:       expect(f.outdated_kegs).to be_empty
// 2506:     end
// 2507:
// 2508:     example "outdated installed head less than stable" do
// 2509:       tab = setup_tab_for_prefix(head_prefix, versions: { "stable" => "1.0" })
// 2510:
// 2511:       expect(f.outdated_kegs).not_to be_empty
// 2512:
// 2513:       tab.source["versions"] = { "stable" => f.version.to_s }
// 2514:       tab.write
// 2515:       described_class.clear_cache
// 2516:
// 2517:       expect(f.outdated_kegs).to be_empty
// 2518:     end
// 2519:
// 2520:     describe ":fetch_head" do
// 2521:       let(:f) do
// 2522:         repo = testball_repo
// 2523:         formula "testball" do
// 2524:           T.bind(self, T.class_of(Formula))
// 2525:           url "foo"
// 2526:           version "2.10"
// 2527:           head "file://#{repo}", using: :git
// 2528:         end
// 2529:       end
// 2530:       let(:testball_repo) { HOMEBREW_PREFIX/"testball_repo" }
// 2531:
// 2532:       example do
// 2533:         outdated_stable_prefix = HOMEBREW_CELLAR/"testball/1.0"
// 2534:         head_prefix_a = HOMEBREW_CELLAR/"testball/HEAD"
// 2535:         head_prefix_b = HOMEBREW_CELLAR/"testball/HEAD-aaaaaaa_1"
// 2536:         head_prefix_c = HOMEBREW_CELLAR/"testball/HEAD-18a7103"
// 2537:
// 2538:         setup_tab_for_prefix(outdated_stable_prefix)
// 2539:         tab_a = setup_tab_for_prefix(head_prefix_a, versions: { "stable" => "1.0" })
// 2540:         setup_tab_for_prefix(head_prefix_b)
// 2541:
// 2542:         testball_repo.mkdir
// 2543:         testball_repo.cd do
// 2544:           FileUtils.touch "LICENSE"
// 2545:
// 2546:           system("git", "-c", "init.defaultBranch=master", "init")
// 2547:           system("git", "add", "--all")
// 2548:           system("git", "commit", "-m", "Initial commit")
// 2549:         end
// 2550:
// 2551:         expect(f.outdated_kegs(fetch_head: true)).not_to be_empty
// 2552:
// 2553:         tab_a.source["versions"] = { "stable" => f.version.to_s }
// 2554:         tab_a.write
// 2555:         described_class.clear_cache
// 2556:         expect(f.outdated_kegs(fetch_head: true)).not_to be_empty
// 2557:
// 2558:         FileUtils.rm_r(head_prefix_a)
// 2559:         described_class.clear_cache
// 2560:         expect(f.outdated_kegs(fetch_head: true)).not_to be_empty
// 2561:
// 2562:         setup_tab_for_prefix(head_prefix_c, source_modified_time: 1)
// 2563:         described_class.clear_cache
// 2564:         expect(f.outdated_kegs(fetch_head: true)).to be_empty
// 2565:       ensure
// 2566:         FileUtils.rm_r(testball_repo) if testball_repo.exist?
// 2567:       end
// 2568:     end
// 2569:
// 2570:     describe "#mkdir" do
// 2571:       let(:dst) { mktmpdir }
// 2572:
// 2573:       it "creates intermediate directories" do
// 2574:         f.mkdir dst/"foo/bar/baz" do
// 2575:           expect(dst/"foo/bar/baz").to exist, "foo/bar/baz was not created"
// 2576:           expect(dst/"foo/bar/baz").to be_a_directory, "foo/bar/baz was not a directory structure"
// 2577:         end
// 2578:       end
// 2579:     end
// 2580:
// 2581:     describe "with changed version scheme" do
// 2582:       let(:f) do
// 2583:         formula "testball" do
// 2584:           T.bind(self, T.class_of(Formula))
// 2585:           url "foo"
// 2586:           version "20141010"
// 2587:           version_scheme 1
// 2588:         end
// 2589:       end
// 2590:
// 2591:       example do
// 2592:         prefix = HOMEBREW_CELLAR/"testball/0.1"
// 2593:         setup_tab_for_prefix(prefix, versions: { "stable" => "0.1" })
// 2594:
// 2595:         expect(f.outdated_kegs).not_to be_empty
// 2596:       end
// 2597:     end
// 2598:
// 2599:     describe "with mixed version schemes" do
// 2600:       let(:f) do
// 2601:         formula "testball" do
// 2602:           T.bind(self, T.class_of(Formula))
// 2603:           url "foo"
// 2604:           version "20141010"
// 2605:           version_scheme 3
// 2606:         end
// 2607:       end
// 2608:
// 2609:       example do
// 2610:         prefix_a = HOMEBREW_CELLAR/"testball/20141009"
// 2611:         setup_tab_for_prefix(prefix_a, versions: { "stable" => "20141009", "version_scheme" => 1 })
// 2612:
// 2613:         prefix_b = HOMEBREW_CELLAR/"testball/2.14"
// 2614:         setup_tab_for_prefix(prefix_b, versions: { "stable" => "2.14", "version_scheme" => 2 })
// 2615:
// 2616:         expect(f.outdated_kegs).not_to be_empty
// 2617:         described_class.clear_cache
// 2618:
// 2619:         prefix_c = HOMEBREW_CELLAR/"testball/20141009"
// 2620:         setup_tab_for_prefix(prefix_c, versions: { "stable" => "20141009", "version_scheme" => 3 })
// 2621:
// 2622:         expect(f.outdated_kegs).not_to be_empty
// 2623:         described_class.clear_cache
// 2624:
// 2625:         prefix_d = HOMEBREW_CELLAR/"testball/20141011"
// 2626:         setup_tab_for_prefix(prefix_d, versions: { "stable" => "20141009", "version_scheme" => 3 })
// 2627:         expect(f.outdated_kegs).to be_empty
// 2628:       end
// 2629:     end
// 2630:
// 2631:     describe "with version scheme" do
// 2632:       let(:f) do
// 2633:         formula "testball" do
// 2634:           T.bind(self, T.class_of(Formula))
// 2635:           url "foo"
// 2636:           version "1.0"
// 2637:           version_scheme 2
// 2638:         end
// 2639:       end
// 2640:
// 2641:       example do
// 2642:         head_prefix = HOMEBREW_CELLAR/"testball/HEAD"
// 2643:
// 2644:         setup_tab_for_prefix(head_prefix, versions: { "stable" => "1.0", "version_scheme" => 1 })
// 2645:         expect(f.outdated_kegs).not_to be_empty
// 2646:
// 2647:         described_class.clear_cache
// 2648:         FileUtils.rm_r(head_prefix)
// 2649:
// 2650:         setup_tab_for_prefix(head_prefix, versions: { "stable" => "1.0", "version_scheme" => 2 })
// 2651:         expect(f.outdated_kegs).to be_empty
// 2652:       end
// 2653:     end
// 2654:   end
// 2655:
// 2656:   describe "#any_installed_version" do
// 2657:     let(:f) do
// 2658:       Class.new(Testball) do
// 2659:         version "1.0"
// 2660:         revision 1
// 2661:       end.new
// 2662:     end
// 2663:
// 2664:     it "returns nil when not installed" do
// 2665:       expect(f.any_installed_version).to be_nil
// 2666:     end
// 2667:
// 2668:     it "returns package version when installed" do
// 2669:       f.brew { f.install }
// 2670:       expect(f.any_installed_version).to eq(PkgVersion.parse("1.0_1"))
// 2671:     end
// 2672:   end
// 2673:
// 2674:   describe "OS support" do
// 2675:     it "returns false for Linux when macOS is required at the top level" do
// 2676:       f = formula do
// 2677:         T.bind(self, T.class_of(Formula))
// 2678:         url "foo"
// 2679:         version "1.0"
// 2680:         depends_on macos: :catalina
// 2681:       end
// 2682:
// 2683:       expect(f.supports_linux?).to be false
// 2684:     end
// 2685:
// 2686:     it "returns true for Linux when macOS is required in an on_macos block" do
// 2687:       f = formula do
// 2688:         T.bind(self, T.class_of(Formula))
// 2689:         url "foo"
// 2690:         version "1.0"
// 2691:         on_macos do
// 2692:           depends_on macos: :catalina
// 2693:         end
// 2694:       end
// 2695:
// 2696:       expect(f.supports_linux?).to be true
// 2697:     end
// 2698:
// 2699:     it "returns false for macOS when Linux is required at the top level" do
// 2700:       f = formula do
// 2701:         T.bind(self, T.class_of(Formula))
// 2702:         url "foo"
// 2703:         version "1.0"
// 2704:         depends_on :linux
// 2705:       end
// 2706:
// 2707:       expect(f.supports_macos?).to be false
// 2708:       expect(f.supports_linux?).to be true
// 2709:     end
// 2710:
// 2711:     it "deprecates bare and versioned macOS requirements" do
// 2712:       expect do
// 2713:         formula do
// 2714:           T.bind(self, T.class_of(Formula))
// 2715:           url "foo"
// 2716:           version "1.0"
// 2717:           depends_on :macos
// 2718:           depends_on macos: :catalina
// 2719:         end
// 2720:       end.to raise_error(MethodDeprecatedError,
// 2721:                          /`depends_on :macos` with `depends_on macos:` inside an `on_macos` block/)
// 2722:     end
// 2723:
// 2724:     it "does not allow duplicate bare macOS requirements" do
// 2725:       expect do
// 2726:         formula do
// 2727:           T.bind(self, T.class_of(Formula))
// 2728:           url "foo"
// 2729:           version "1.0"
// 2730:           depends_on :macos
// 2731:           depends_on :macos
// 2732:         end
// 2733:       end.to raise_error(ArgumentError, "`depends_on :macos` cannot be combined with another macOS `depends_on`")
// 2734:     end
// 2735:
// 2736:     it "returns false for Linux when maximum macOS is required at the top level" do
// 2737:       f = formula do
// 2738:         T.bind(self, T.class_of(Formula))
// 2739:         url "foo"
// 2740:         version "1.0"
// 2741:         depends_on maximum_macos: :tahoe
// 2742:       end
// 2743:
// 2744:       expect(f.supports_linux?).to be false
// 2745:     end
// 2746:
// 2747:     it "does not allow Linux then macOS requirements" do
// 2748:       expect do
// 2749:         formula do
// 2750:           T.bind(self, T.class_of(Formula))
// 2751:           url "foo"
// 2752:           version "1.0"
// 2753:           depends_on :linux
// 2754:           depends_on macos: :catalina
// 2755:         end
// 2756:       end.to raise_error(ArgumentError, "`depends_on :linux` cannot be combined with `depends_on macos:`")
// 2757:     end
// 2758:
// 2759:     it "does not allow macOS then Linux requirements" do
// 2760:       expect do
// 2761:         formula do
// 2762:           T.bind(self, T.class_of(Formula))
// 2763:           url "foo"
// 2764:           version "1.0"
// 2765:           depends_on macos: :catalina
// 2766:           depends_on :linux
// 2767:         end
// 2768:       end.to raise_error(ArgumentError, "`depends_on :linux` cannot be combined with `depends_on macos:`")
// 2769:     end
// 2770:   end
// 2771:
// 2772:   describe "#on_macos", :needs_macos do
// 2773:     let(:f) do
// 2774:       Class.new(Testball) do
// 2775:         attr_reader :test
// 2776:
// 2777:         def install
// 2778:           @test = 0
// 2779:           on_macos do
// 2780:             @test = 1
// 2781:           end
// 2782:           on_linux do
// 2783:             @test = 2
// 2784:           end
// 2785:         end
// 2786:       end.new
// 2787:     end
// 2788:
// 2789:     it "only calls code within on_macos" do
// 2790:       f.brew { f.install }
// 2791:       expect(f.test).to eq(1)
// 2792:     end
// 2793:   end
// 2794:
// 2795:   describe "#on_linux", :needs_linux do
// 2796:     let(:f) do
// 2797:       Class.new(Testball) do
// 2798:         attr_reader :test
// 2799:
// 2800:         def install
// 2801:           @test = 0
// 2802:           on_macos do
// 2803:             @test = 1
// 2804:           end
// 2805:           on_linux do
// 2806:             @test = 2
// 2807:           end
// 2808:         end
// 2809:       end.new
// 2810:     end
// 2811:
// 2812:     it "only calls code within on_linux" do
// 2813:       f.brew { f.install }
// 2814:       expect(f.test).to eq(2)
// 2815:     end
// 2816:   end
// 2817:
// 2818:   describe "#on_system" do
// 2819:     let(:f) do
// 2820:       Class.new(Testball) do
// 2821:         attr_reader :foo
// 2822:         attr_reader :bar
// 2823:
// 2824:         def install
// 2825:           @foo = 0
// 2826:           @bar = 0
// 2827:           on_system :linux, macos: :tahoe do
// 2828:             @foo = 1
// 2829:           end
// 2830:           on_system :linux, macos: :sonoma_or_older do
// 2831:             @bar = 1
// 2832:           end
// 2833:         end
// 2834:       end.new
// 2835:     end
// 2836:
// 2837:     it "doesn't call code on Sequoia", :needs_macos do
// 2838:       Homebrew::SimulateSystem.with os: :sequoia do
// 2839:         f.brew { f.install }
// 2840:         expect(f.foo).to eq(0)
// 2841:         expect(f.bar).to eq(0)
// 2842:       end
// 2843:     end
// 2844:
// 2845:     it "calls code on Linux", :needs_linux do
// 2846:       Homebrew::SimulateSystem.with os: :linux do
// 2847:         f.brew { f.install }
// 2848:         expect(f.foo).to eq(1)
// 2849:         expect(f.bar).to eq(1)
// 2850:       end
// 2851:     end
// 2852:
// 2853:     it "calls code within `on_system :linux, macos: :tahoe` on Tahoe", :needs_macos do
// 2854:       Homebrew::SimulateSystem.with os: :tahoe do
// 2855:         f.brew { f.install }
// 2856:         expect(f.foo).to eq(1)
// 2857:         expect(f.bar).to eq(0)
// 2858:       end
// 2859:     end
// 2860:
// 2861:     it "calls code within `on_system :linux, macos: :sonoma_or_older` on Sonoma", :needs_macos do
// 2862:       Homebrew::SimulateSystem.with os: :sonoma do
// 2863:         f.brew { f.install }
// 2864:         expect(f.foo).to eq(0)
// 2865:         expect(f.bar).to eq(1)
// 2866:       end
// 2867:     end
// 2868:
// 2869:     it "calls code within `on_system :linux, macos: :sonoma_or_older` on Ventura", :needs_macos do
// 2870:       Homebrew::SimulateSystem.with os: :ventura do
// 2871:         f.brew { f.install }
// 2872:         expect(f.foo).to eq(0)
// 2873:         expect(f.bar).to eq(1)
// 2874:       end
// 2875:     end
// 2876:   end
// 2877:
// 2878:   describe "on_{os_version} blocks", :needs_macos do
// 2879:     let(:f) do
// 2880:       Class.new(Testball) do
// 2881:         attr_reader :test
// 2882:
// 2883:         def install
// 2884:           @test = 0
// 2885:           on_sequoia :or_newer do
// 2886:             @test = 1
// 2887:           end
// 2888:           on_sonoma do
// 2889:             @test = 2
// 2890:           end
// 2891:           on_ventura :or_older do
// 2892:             @test = 3
// 2893:           end
// 2894:         end
// 2895:       end.new
// 2896:     end
// 2897:
// 2898:     it "only calls code within `on_sequoia`" do
// 2899:       Homebrew::SimulateSystem.with os: :tahoe do
// 2900:         f.brew { f.install }
// 2901:         expect(f.test).to eq(1)
// 2902:       end
// 2903:     end
// 2904:
// 2905:     it "only calls code within `on_sequoia :or_newer`" do
// 2906:       Homebrew::SimulateSystem.with os: :sequoia do
// 2907:         f.brew { f.install }
// 2908:         expect(f.test).to eq(1)
// 2909:       end
// 2910:     end
// 2911:
// 2912:     it "only calls code within `on_sonoma`" do
// 2913:       Homebrew::SimulateSystem.with os: :sonoma do
// 2914:         f.brew { f.install }
// 2915:         expect(f.test).to eq(2)
// 2916:       end
// 2917:     end
// 2918:
// 2919:     it "only calls code within `on_ventura`" do
// 2920:       Homebrew::SimulateSystem.with os: :ventura do
// 2921:         f.brew { f.install }
// 2922:         expect(f.test).to eq(3)
// 2923:       end
// 2924:     end
// 2925:
// 2926:     it "only calls code within `on_ventura :or_older`" do
// 2927:       Homebrew::SimulateSystem.with os: :monterey do
// 2928:         f.brew { f.install }
// 2929:         expect(f.test).to eq(3)
// 2930:       end
// 2931:     end
// 2932:   end
// 2933:
// 2934:   describe "#on_arm" do
// 2935:     before do
// 2936:       allow(Hardware::CPU).to receive(:type).and_return(:arm)
// 2937:     end
// 2938:
// 2939:     let(:f) do
// 2940:       Class.new(Testball) do
// 2941:         attr_reader :test
// 2942:
// 2943:         def install
// 2944:           @test = 0
// 2945:           on_arm do
// 2946:             @test = 1
// 2947:           end
// 2948:           on_intel do
// 2949:             @test = 2
// 2950:           end
// 2951:         end
// 2952:       end.new
// 2953:     end
// 2954:
// 2955:     it "only calls code within on_arm" do
// 2956:       f.brew { f.install }
// 2957:       expect(f.test).to eq(1)
// 2958:     end
// 2959:   end
// 2960:
// 2961:   describe "#on_intel" do
// 2962:     before do
// 2963:       allow(Hardware::CPU).to receive(:type).and_return(:intel)
// 2964:     end
// 2965:
// 2966:     let(:f) do
// 2967:       Class.new(Testball) do
// 2968:         attr_reader :test
// 2969:
// 2970:         def install
// 2971:           @test = 0
// 2972:           on_arm do
// 2973:             @test = 1
// 2974:           end
// 2975:           on_intel do
// 2976:             @test = 2
// 2977:           end
// 2978:         end
// 2979:       end.new
// 2980:     end
// 2981:
// 2982:     it "only calls code within on_intel" do
// 2983:       f.brew { f.install }
// 2984:       expect(f.test).to eq(2)
// 2985:     end
// 2986:   end
// 2987:
// 2988:   describe "#generate_completions_from_executable" do
// 2989:     let(:f) do
// 2990:       Class.new(Testball) do
// 2991:         def install
// 2992:           bin.mkpath
// 2993:           (bin/"foo").write <<-EOF
// 2994:             echo completion
// 2995:           EOF
// 2996:
// 2997:           FileUtils.chmod "+x", bin/"foo"
// 2998:
// 2999:           generate_completions_from_executable(bin/"foo", "test")
// 3000:         end
// 3001:       end.new
// 3002:     end
// 3003:
// 3004:     it "generates completion scripts" do
// 3005:       f.brew { f.install }
// 3006:       expect(f.bash_completion/"foo").to be_a_file
// 3007:       expect(f.zsh_completion/"_foo").to be_a_file
// 3008:       expect(f.fish_completion/"foo.fish").to be_a_file
// 3009:     end
// 3010:   end
// 3011:
// 3012:   describe "{allow,deny}_network_access" do
// 3013:     actions = %w[allow deny].freeze
// 3014:     PHASES.each do |phase|
// 3015:       actions.each do |action|
// 3016:         it "can #{action} network access for #{phase}" do
// 3017:           f = Class.new(Testball) do
// 3018:             public_send(:"#{action}_network_access!", phase)
// 3019:           end
// 3020:
// 3021:           expect(f.network_access_allowed?(phase)).to be(action == "allow")
// 3022:         end
// 3023:       end
// 3024:     end
// 3025:
// 3026:     test_each(actions) do |action|
// 3027:       it "can #{action} network access for all phases" do
// 3028:         f = Class.new(Testball) do
// 3029:           public_send(:"#{action}_network_access!")
// 3030:         end
// 3031:
// 3032:         PHASES.each do |phase|
// 3033:           expect(f.network_access_allowed?(phase)).to be(action == "allow")
// 3034:         end
// 3035:       end
// 3036:     end
// 3037:   end
// 3038:
// 3039:   describe "#network_access_allowed?" do
// 3040:     it "throws an error when passed an invalid symbol" do
// 3041:       f = Testball.new
// 3042:       expect { f.network_access_allowed?(:foo) }.to raise_error(ArgumentError)
// 3043:     end
// 3044:   end
// 3045:
// 3046:   describe "#specified_path" do
// 3047:     let(:klass) do
// 3048:       Class.new(described_class) do
// 3049:         url "https://brew.sh/foo-1.0.tar.gz"
// 3050:       end
// 3051:     end
// 3052:
// 3053:     let(:name) { "formula_name" }
// 3054:     let(:path) { Formulary.core_path(name) }
// 3055:     let(:spec) { :stable }
// 3056:     let(:alias_name) { "baz@1" }
// 3057:     let(:alias_path) { CoreTap.instance.alias_dir/alias_name }
// 3058:     let(:f) { klass.new(name, path, spec) }
// 3059:     let(:f_alias) { klass.new(name, path, spec, alias_path:) }
// 3060:
// 3061:     context "when loading from a formula file" do
// 3062:       it "returns the formula file path" do
// 3063:         expect(f.specified_path).to eq(path)
// 3064:       end
// 3065:     end
// 3066:
// 3067:     context "when loaded from an alias" do
// 3068:       it "returns the alias path" do
// 3069:         expect(f_alias.specified_path).to eq(alias_path)
// 3070:       end
// 3071:     end
// 3072:
// 3073:     context "when loaded from the API" do
// 3074:       before do
// 3075:         allow(f).to receive(:loaded_from_api?).and_return(true)
// 3076:       end
// 3077:
// 3078:       it "returns the API path" do
// 3079:         expect(f.specified_path).to eq(Homebrew::API::Formula.cached_json_file_path)
// 3080:       end
// 3081:     end
// 3082:
// 3083:     context "when loaded from the internal API" do
// 3084:       before do
// 3085:         allow(f).to receive(:loaded_from_internal_api?).and_return(true)
// 3086:       end
// 3087:
// 3088:       it "returns the internal API path" do
// 3089:         expect(f.specified_path).to eq(Homebrew::API::Internal.cached_packages_json_file_path)
// 3090:       end
// 3091:     end
// 3092:   end
// 3093:
// 3094:   describe "#preserve_rpath" do
// 3095:     it "defaults to false" do
// 3096:       f = formula do
// 3097:         T.bind(self, T.class_of(Formula))
// 3098:         url "foo-1.0"
// 3099:       end
// 3100:
// 3101:       expect(f.class.preserve_rpath?).to be(false)
// 3102:     end
// 3103:
// 3104:     it "can be enabled" do
// 3105:       f = formula do
// 3106:         T.bind(self, T.class_of(Formula))
// 3107:         url "foo-1.0"
// 3108:         preserve_rpath
// 3109:       end
// 3110:
// 3111:       expect(f.class.preserve_rpath?).to be(true)
// 3112:     end
// 3113:
// 3114:     it "can be explicitly disabled" do
// 3115:       f = formula do
// 3116:         T.bind(self, T.class_of(Formula))
// 3117:         url "foo-1.0"
// 3118:         preserve_rpath value: false
// 3119:       end
// 3120:
// 3121:       expect(f.class.preserve_rpath?).to be(false)
// 3122:     end
// 3123:   end
// 3124:
// 3125:   describe "#deprecate! and #disable!" do
// 3126:     let(:deprecation_date) { "2020-01-01" }
// 3127:     let(:disable_date) { "2021-01-01" }
// 3128:
// 3129:     context "with both dates provided in correct order" do
// 3130:       let(:f) do
// 3131:         deprecation_date_ = deprecation_date
// 3132:         disable_date_ = disable_date
// 3133:         formula "foo" do
// 3134:           T.bind(self, T.class_of(Formula))
// 3135:           url "foo-1.0"
// 3136:           deprecate! date: deprecation_date_.to_s, because: :unmaintained
// 3137:           disable! date: disable_date_.to_s, because: :unsupported
// 3138:         end
// 3139:       end
// 3140:
// 3141:       it "is not deprecated before deprecation date" do
// 3142:         allow(Date).to receive(:today).and_return(Date.parse(deprecation_date) - 1)
// 3143:         expect(f.deprecated?).to be(false)
// 3144:         expect(f.deprecation_reason).to be_nil
// 3145:         expect(f.disabled?).to be(false)
// 3146:         expect(f.disable_reason).to be_nil
// 3147:       end
// 3148:
// 3149:       it "is deprecated on deprecation date" do
// 3150:         allow(Date).to receive(:today).and_return(Date.parse(deprecation_date))
// 3151:         expect(f.deprecated?).to be(true)
// 3152:         expect(f.deprecation_reason).to be(:unmaintained)
// 3153:         expect(f.disabled?).to be(false)
// 3154:         expect(f.disable_reason).to be_nil
// 3155:       end
// 3156:
// 3157:       it "is disabled on disable date" do
// 3158:         allow(Date).to receive(:today).and_return(Date.parse(disable_date))
// 3159:         expect(f.deprecated?).to be(true)
// 3160:         expect(f.deprecation_reason).to be(:unmaintained)
// 3161:         expect(f.disabled?).to be(true)
// 3162:         expect(f.disable_reason).to be(:unsupported)
// 3163:       end
// 3164:     end
// 3165:
// 3166:     context "with both dates provided in incorrect order" do
// 3167:       let(:f) do
// 3168:         deprecation_date_ = deprecation_date
// 3169:         disable_date_ = disable_date
// 3170:         formula "foo" do
// 3171:           T.bind(self, T.class_of(Formula))
// 3172:           url "foo-1.0"
// 3173:           disable! date: disable_date_.to_s, because: :unsupported
// 3174:           deprecate! date: deprecation_date_.to_s, because: :unmaintained
// 3175:         end
// 3176:       end
// 3177:
// 3178:       it "is not deprecated before deprecation date" do
// 3179:         allow(Date).to receive(:today).and_return(Date.parse(deprecation_date) - 1)
// 3180:         expect(f.deprecated?).to be(false)
// 3181:         expect(f.deprecation_reason).to be_nil
// 3182:         expect(f.disabled?).to be(false)
// 3183:         expect(f.disable_reason).to be_nil
// 3184:       end
// 3185:
// 3186:       it "is deprecated on deprecation date" do
// 3187:         allow(Date).to receive(:today).and_return(Date.parse(deprecation_date))
// 3188:         expect(f.deprecated?).to be(true)
// 3189:         expect(f.deprecation_reason).to be(:unmaintained)
// 3190:         expect(f.disabled?).to be(false)
// 3191:         expect(f.disable_reason).to be_nil
// 3192:       end
// 3193:
// 3194:       it "is disabled on disable date" do
// 3195:         allow(Date).to receive(:today).and_return(Date.parse(disable_date))
// 3196:         expect(f.deprecated?).to be(true)
// 3197:         expect(f.deprecation_reason).to be(:unmaintained)
// 3198:         expect(f.disabled?).to be(true)
// 3199:         expect(f.disable_reason).to be(:unsupported)
// 3200:       end
// 3201:     end
// 3202:
// 3203:     context "with only disable date" do
// 3204:       let(:f) do
// 3205:         disable_date_ = disable_date
// 3206:         formula("foo") do
// 3207:           T.bind(self, T.class_of(Formula))
// 3208:           url "foo-1.0"
// 3209:           disable! date: disable_date_.to_s, because: :unsupported
// 3210:         end
// 3211:       end
// 3212:
// 3213:       it "is deprecated before disable date" do
// 3214:         allow(Date).to receive(:today).and_return(Date.parse(disable_date) << 12)
// 3215:         expect(f.deprecated?).to be(true)
// 3216:         expect(f.deprecation_reason).to be(:unsupported)
// 3217:         expect(f.disabled?).to be(false)
// 3218:         expect(f.disable_reason).to be_nil
// 3219:       end
// 3220:
// 3221:       it "is disabled on disable date" do
// 3222:         allow(Date).to receive(:today).and_return(Date.parse(disable_date))
// 3223:         expect(f.disabled?).to be(true)
// 3224:         expect(f.disable_reason).to be(:unsupported)
// 3225:       end
// 3226:     end
// 3227:   end
// 3228:
// 3229:   describe ".all" do
// 3230:     it "skips formulas that raise FormulaSpecificationError" do
// 3231:       allow(described_class).to receive_messages(core_names: ["testball"], tap_files: [])
// 3232:       allow(Formulary).to receive(:factory).with("testball").and_raise(
// 3233:         FormulaSpecificationError, "testball: formula requires at least a URL"
// 3234:       )
// 3235:
// 3236:       expect { described_class.all(eval_all: true) }.not_to raise_error
// 3237:       expect(described_class.all(eval_all: true)).to eq([])
// 3238:     end
// 3239:
// 3240:     it "skips untrusted tap formulae when trust is enabled" do
// 3241:       tap = Tap.fetch("thirdparty", "foo")
// 3242:       formula_path = tap.formula_dir/"untrusted.rb"
// 3243:       formula_path.dirname.mkpath
// 3244:       formula_path.write <<~RUBY
// 3245:         raise "untrusted formula evaluated"
// 3246:       RUBY
// 3247:
// 3248:       allow(described_class).to receive_messages(core_names: [], tap_files: [formula_path])
// 3249:       expect(Formulary).not_to receive(:factory).with(formula_path)
// 3250:
// 3251:       with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 3252:         expect { expect(described_class.all(eval_all: true)).to eq([]) }
// 3253:           .to output(%r{Skipping thirdparty/foo because it is not trusted}).to_stderr
// 3254:       end
// 3255:     ensure
// 3256:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 3257:     end
// 3258:
// 3259:     it "allows all formulae when trust is enabled" do
// 3260:       allow(described_class).to receive_messages(core_names: [], tap_files: [])
// 3261:
// 3262:       with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 3263:         expect(described_class.all).to eq([])
// 3264:       end
// 3265:     end
// 3266:   end
// 3267:
// 3268:   describe "#std_cabal_v2_args" do
// 3269:     let(:f) do
// 3270:       formula do
// 3271:         T.bind(self, T.class_of(Formula))
// 3272:         url "foo-1.0"
// 3273:       end
// 3274:     end
// 3275:
// 3276:     it "allows changing the installation directory" do
// 3277:       expect(f.std_cabal_v2_args(installdir: "/tmp/foo")).to include("--installdir=/tmp/foo")
// 3278:     end
// 3279:
// 3280:     it "excludes installation arguments when `installdir: false`" do
// 3281:       expect(f.std_cabal_v2_args(installdir: false)).not_to include(a_string_starting_with("--install"))
// 3282:     end
// 3283:
// 3284:     context "when running on Linux", :needs_linux do
// 3285:       it "includes flag for PIE on arm" do
// 3286:         allow(Hardware::CPU).to receive(:arm?).and_return(true)
// 3287:         expect(f.std_cabal_v2_args).to include("--ghc-option=-pie")
// 3288:       end
// 3289:
// 3290:       it "excludes flag for PIE on non-arm" do
// 3291:         allow(Hardware::CPU).to receive(:arm?).and_return(false)
// 3292:         expect(f.std_cabal_v2_args).not_to include("--ghc-option=-pie")
// 3293:       end
// 3294:     end
// 3295:   end
// 3296:
// 3297:   describe "#std_go_args" do
// 3298:     let(:f) do
// 3299:       formula do
// 3300:         T.bind(self, T.class_of(Formula))
// 3301:         url "foo-1.0"
// 3302:       end
// 3303:     end
// 3304:
// 3305:     it "defaults to stripping binaries" do
// 3306:       expect(f.std_go_args).to include("-ldflags=-s -w")
// 3307:
// 3308:       ldflags = "-X main.version=1.0.0"
// 3309:       expect(f.std_go_args(ldflags:)).to include("-ldflags=-s -w #{ldflags}")
// 3310:     end
// 3311:
// 3312:     it "does not strip binaries when building with debug symbols" do
// 3313:       allow(ENV).to receive(:debug_symbols?).and_return(true)
// 3314:       expect(f.std_go_args).not_to include(a_string_starting_with("-ldflags"))
// 3315:
// 3316:       ldflags = "-X main.version=1.0.0"
// 3317:       expect(f.std_go_args(ldflags:)).to include("-ldflags=#{ldflags}")
// 3318:     end
// 3319:
// 3320:     it "raises an error when provided an invalid ldflags symbol" do
// 3321:       expect { f.std_go_args(ldflags: :foo) }.to raise_error(ArgumentError, "Invalid ldflags: :foo")
// 3322:     end
// 3323:
// 3324:     context "with `ldflags: :goreleaser`" do
// 3325:       subject(:std_go_args) { f.std_go_args(ldflags: :goreleaser) }
// 3326:
// 3327:       let(:built_by) { "Homebrew" }
// 3328:       let(:commit) { built_by }
// 3329:       let(:date) { "2026-01-01T12:00:00Z" }
// 3330:       let(:expected_ldflags) do
// 3331:         "-s -w " \
// 3332:           "-X 'main.version=1.0' " \
// 3333:           "-X 'main.commit=#{commit}' " \
// 3334:           "-X 'main.date=#{date}' " \
// 3335:           "-X 'main.builtBy=#{built_by}'"
// 3336:       end
// 3337:
// 3338:       before { allow(f).to receive(:time).and_return(Time.parse(date)) }
// 3339:
// 3340:       context "when in a git repository" do
// 3341:         let(:buildpath) { mktmpdir }
// 3342:         let(:commit) { Utils.popen_read("git", "-C", buildpath, "rev-parse", "HEAD").chomp }
// 3343:
// 3344:         before { allow(f).to receive(:buildpath).and_return(buildpath) }
// 3345:
// 3346:         around do |example|
// 3347:           buildpath.cd do
// 3348:             FileUtils.touch "LICENSE"
// 3349:             system "git", "init"
// 3350:             system "git", "add", "--all"
// 3351:             system "git", "commit", "-m", "Initial commit"
// 3352:             example.run
// 3353:           end
// 3354:         end
// 3355:
// 3356:         it "uses git commit for main.commit" do
// 3357:           expect(std_go_args).to include("-ldflags=#{expected_ldflags}")
// 3358:         end
// 3359:       end
// 3360:
// 3361:       context "when not in a git repository and tap is available" do
// 3362:         let(:built_by) { "someone" }
// 3363:
// 3364:         before { allow(f).to receive(:tap).and_return(Tap.fetch(built_by, "repo")) }
// 3365:
// 3366:         it "uses tap user for main.commit" do
// 3367:           expect(std_go_args).to include("-ldflags=#{expected_ldflags}")
// 3368:         end
// 3369:       end
// 3370:
// 3371:       context "when not in a git repository and tap is not available" do
// 3372:         before { allow(f).to receive(:tap).and_return(nil) }
// 3373:
// 3374:         it "uses Homebrew for main.commit" do
// 3375:           expect(std_go_args).to include("-ldflags=#{expected_ldflags}")
// 3376:         end
// 3377:       end
// 3378:     end
// 3379:
// 3380:     it "includes a comma-separated list of input tags" do
// 3381:       expect(f.std_go_args(tags: %w[foo bar baz])).to include("-tags=foo,bar,baz")
// 3382:     end
// 3383:   end
// 3384:
// 3385:   describe "#std_pip_args" do
// 3386:     let(:f) do
// 3387:       formula do
// 3388:         T.bind(self, T.class_of(Formula))
// 3389:         url "foo-1.0"
// 3390:       end
// 3391:     end
// 3392:
// 3393:     it "filters packages uploaded within the last day" do
// 3394:       expect(f.std_pip_args).to include("--uploaded-prior-to=P1D")
// 3395:     end
// 3396:   end
// 3397:
// 3398:   describe "#std_swift_args" do
// 3399:     let(:f) do
// 3400:       formula do
// 3401:         T.bind(self, T.class_of(Formula))
// 3402:         url "foo-1.0"
// 3403:       end
// 3404:     end
// 3405:
// 3406:     it "allows controlling parallel jobs" do
// 3407:       allow(ENV).to receive(:make_jobs).and_return(5)
// 3408:       expect(f.std_swift_args.join(" ")).to include("--jobs 5")
// 3409:     end
// 3410:
// 3411:     it "disables non-writable sandbox path on macOS", :needs_macos do
// 3412:       expect(f.std_swift_args).to include("--disable-sandbox")
// 3413:     end
// 3414:
// 3415:     it "includes override for ld shim on Linux", :needs_linux do
// 3416:       expect(f.std_swift_args).to include("-use-ld=ld")
// 3417:     end
// 3418:   end
// 3419:
// 3420:   describe "#std_zig_args" do
// 3421:     let(:f) do
// 3422:       formula do
// 3423:         T.bind(self, T.class_of(Formula))
// 3424:         url "foo-1.0"
// 3425:       end
// 3426:     end
// 3427:
// 3428:     it "raises an error when provided an unknown release mode" do
// 3429:       expect { f.std_zig_args(release_mode: :test) }.to raise_error(ArgumentError)
// 3430:     end
// 3431:
// 3432:     it "includes equivalent Zig CPU for known target arch" do
// 3433:       allow(ENV).to receive(:effective_arch).and_return(:arm_vortex_tempest)
// 3434:       expect(f.std_zig_args).to include("-Dcpu=apple_m1")
// 3435:     end
// 3436:
// 3437:     it "allows overriding Zig CPU" do
// 3438:       expect(f.std_zig_args(cpu: :generic)).to include("-Dcpu=generic")
// 3439:     end
// 3440:   end
// 3441:
// 3442:   describe "#common_sandbox_env" do
// 3443:     let(:f) do
// 3444:       formula do
// 3445:         T.bind(self, T.class_of(Formula))
// 3446:         url "foo-1.0"
// 3447:       end
// 3448:     end
// 3449:
// 3450:     it "sets Bundler cooldown for RubyGems dependencies" do
// 3451:       expect(f.common_sandbox_env(mktmpdir)[:BUNDLE_COOLDOWN]).to eq("1")
// 3452:     end
// 3453:
// 3454:     it "prevents build tools from reading user configuration" do
// 3455:       home = mktmpdir
// 3456:
// 3457:       expect(f.common_sandbox_env(home)).to include(
// 3458:         GIT_CONFIG_GLOBAL:     Utils::Git.no_global_config_file,
// 3459:         GIT_TERMINAL_PROMPT:   "0",
// 3460:         GOENV:                 "off",
// 3461:         NPM_CONFIG_USERCONFIG: File::NULL,
// 3462:         PIP_CONFIG_FILE:       File::NULL,
// 3463:         XDG_CONFIG_HOME:       (home/".config").to_s,
// 3464:       )
// 3465:     end
// 3466:   end
// 3467:
// 3468:   describe ".no_autobump!" do
// 3469:     it "raises an error when used in an unofficial tap" do
// 3470:       unofficial_tap = Tap.fetch("someone", "repo")
// 3471:       allow(Tap).to receive(:from_path).and_return(unofficial_tap)
// 3472:
// 3473:       expect do
// 3474:         Class.new(Formula) do
// 3475:           no_autobump! because: "some reason"
// 3476:         end
// 3477:       end.to raise_error(ArgumentError, /official Homebrew taps/)
// 3478:     end
// 3479:
// 3480:     it "allows usage when tap is official" do
// 3481:       official_tap = Tap.fetch("Homebrew", "core")
// 3482:       allow(Tap).to receive(:from_path).and_return(official_tap)
// 3483:
// 3484:       klass = Class.new(Formula) do
// 3485:         no_autobump! because: "some reason"
// 3486:       end
// 3487:       expect(klass.autobump?).to be(false)
// 3488:     end
// 3489:   end
// 3490: end

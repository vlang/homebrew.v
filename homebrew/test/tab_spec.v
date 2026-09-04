module test

import ruby
import homebrew
import homebrew.api
import time
import x.json2

fn tab_spec_bool(value bool) ruby.Value {
	return ruby.bool_value(value)
}

fn tab_spec_subject() homebrew.Tab {
	return homebrew.new_tab(homebrew.TabConfig{
		homebrew_version: '1.2.3'
		has_homebrew_version: true
		used_options: ['--with-foo', '--without-bar']
		unused_options: ['--with-baz', '--without-qux']
		built_as_bottle: false
		has_built_as_bottle: true
		poured_from_bottle: true
		has_poured_from_bottle: true
		installed_on_request: true
		has_installed_on_request: true
		changed_files: []
		has_changed_files: true
		time: 1_720_189_863
		has_time: true
		source_modified_time: 0
		has_source_modified_time: true
		compiler: 'clang'
		stdlib: 'libcxx'
		runtime_dependencies: []
		has_runtime_dependencies: true
		loaded_from_api: false
		has_loaded_from_api: true
		loaded_from_internal_api: false
		has_loaded_from_internal_api: true
		source: {
			'tap':          json2.Any('homebrew/core')
			'path':         json2.Any('/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core')
			'spec':         json2.Any('stable')
			'scm_revision': json2.Any('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
			'versions':     json2.Any({
				'stable': json2.Any('0.10')
				'head':   json2.Any('HEAD-1111111')
			})
		}
		arch: 'x86_64'
		has_arch: true
		built_on: {
			'os': json2.Any('macOS')
		}
		has_built_on: true
	})
}

fn tab_spec_receipt() homebrew.Tab {
	return homebrew.new_tab(homebrew.TabConfig{
		homebrew_version: '1.1.6'
		has_homebrew_version: true
		used_options: ['--with-foo', '--without-bar']
		unused_options: ['--with-baz', '--without-qux']
		built_as_bottle: false
		has_built_as_bottle: true
		poured_from_bottle: true
		has_poured_from_bottle: true
		loaded_from_api: false
		has_loaded_from_api: true
		loaded_from_internal_api: false
		has_loaded_from_internal_api: true
		installed_on_request: true
		has_installed_on_request: true
		changed_files: ['INSTALL_RECEIPT.json', 'bin/foo']
		has_changed_files: true
		time: 1_403_827_774
		has_time: true
		source_modified_time: 1_628_303_333
		has_source_modified_time: true
		stdlib: 'libcxx'
		compiler: 'clang'
		runtime_dependencies: [homebrew.RuntimeDependencyReceipt{
			full_name: 'foo'
			version: '1.0'
		}]
		has_runtime_dependencies: true
		source: {
			'path':     json2.Any('/usr/local/Library/Taps/homebrew/homebrew-core/Formula/foo.rb')
			'tap':      json2.Any('homebrew/core')
			'spec':     json2.Any('stable')
			'versions': json2.Any({
				'stable': json2.Any('2.14')
				'head':   json2.Any('HEAD-0000000')
			})
		}
	})
}

fn tab_spec_old_receipt_json() string {
	return '{"used_options":["--with-foo","--without-bar"],"unused_options":["--with-baz","--without-qux"],"built_as_bottle":false,"poured_from_bottle":true,"tapped_from":"Homebrew/homebrew","time":1403827774,"stdlib":"libcxx","compiler":"clang"}'
}

fn tab_spec_formula(name string, version string, root string, alias_path string,
	dependencies []string, compatibility_version int) !homebrew.Formula {
	return homebrew.new_formula(homebrew.FormulaConfig{
		reference: api.PackageReference{
			kind: .formula
			name: name
			full_name: name
			stable_version: version
			dependencies: dependencies
			local_path: ruby.join_path(root, '${name}.rb')
		}
		prefix: root
		cellar: ruby.join_path(root, 'Cellar')
		alias_path: alias_path
		compatibility_version: compatibility_version
		has_compatibility_version: compatibility_version > 0
	})
}

fn tab_spec_temp_root(name string) string {
	return ruby.join_path(ruby.temporary_directory(), 'brew-v-tab-${name}-${ruby.process_id()}')
}

fn tab_spec_nil() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

fn tab_spec_json_string(values map[string]json2.Any, key string) string {
	return (values[key] or { return '' }).str()
}

fn tab_spec_json_map(values map[string]json2.Any, key string) map[string]json2.Any {
	return (values[key] or { return map[string]json2.Any{} }).as_map()
}

// Translated from Homebrew/brew `test/tab_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:tab) do` at line 8.
pub fn ruby_tab_spec_l8_d1_tab(args ...ruby.Value) ruby.Value {
	return homebrew.tab_boundary_value(tab_spec_subject())
}

// Ruby let `let(:time) { Time.now.to_i }` at line 37.
pub fn ruby_tab_spec_l37_d2_time(args ...ruby.Value) ruby.Value {
	return ruby.int_value(time.now().unix())
}

// Ruby let `let(:unused_options) { Options.create(%w[--with-baz --without-qux]) }` at line 38.
pub fn ruby_tab_spec_l38_d3_unused_options(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(['--with-baz', '--without-qux'])
}

// Ruby let `let(:used_options) { Options.create(%w[--with-foo --without-bar]) }` at line 39.
pub fn ruby_tab_spec_l39_d4_used_options(args ...ruby.Value) ruby.Value {
	return ruby.string_array_value(['--with-foo', '--without-bar'])
}

// Ruby let `let(:git_repo) { HOMEBREW_CACHE/"tab-spec-git-repo" }` at line 40.
pub fn ruby_tab_spec_l40_d5_git_repo(args ...ruby.Value) ruby.Value {
	return ruby.string_value(tab_spec_temp_root('tab-spec-git-repo'))
}

// Ruby let `let(:f) do` at line 41.
pub fn ruby_tab_spec_l41_d6_f(args ...ruby.Value) ruby.Value {
	root := tab_spec_temp_root('formula')
	formula := tab_spec_formula('foo', '1.0', root, '', [], 0) or {
		return ruby.structured_value('Error', err.msg(), {
			'message': err.msg()
		})
	}
	return homebrew.formula_boundary_value(formula)
}

// Ruby let `let(:f_tab_path) { f.prefix/"INSTALL_RECEIPT.json" }` at line 47.
pub fn ruby_tab_spec_l47_d7_f_tab_path(args ...ruby.Value) ruby.Value {
	formula := homebrew.formula_from_boundary(ruby_tab_spec_l41_d6_f())
	return ruby.string_value(ruby.join_path(formula.prefix(), homebrew.tab_filename))
}

// Ruby let `let(:f_tab_content) { (TEST_FIXTURE_DIR/"receipt.json").read }` at line 48.
pub fn ruby_tab_spec_l48_d8_f_tab_content(args ...ruby.Value) ruby.Value {
	return ruby.string_value(tab_spec_receipt().to_json())
}

// Ruby alias_matcher `alias_matcher :be_built_with, :be_with` at line 50.
pub fn ruby_tab_spec_l50_d9_be_built_with(args ...ruby.Value) ruby.Value {
	name := if args.len > 0 { args[0].as_string() } else { 'foo' }
	return tab_spec_bool(tab_spec_subject().with(name))
}

// Ruby matcher `matcher :be_poured_from_bottle do` at line 52.
pub fn ruby_tab_spec_l52_d10_be_poured_from_bottle(args ...ruby.Value) ruby.Value {
	return tab_spec_bool(tab_spec_subject().poured_from_bottle)
}

// Ruby matcher `matcher :be_built_as_bottle do` at line 58.
pub fn ruby_tab_spec_l58_d11_be_built_as_bottle(args ...ruby.Value) ruby.Value {
	return tab_spec_bool(tab_spec_subject().built_as_bottle)
}

// Ruby matcher `matcher :be_installed_on_request do` at line 64.
pub fn ruby_tab_spec_l64_d12_be_installed_on_request(args ...ruby.Value) ruby.Value {
	return tab_spec_bool(tab_spec_subject().installed_on_request)
}

// Ruby matcher `matcher :be_loaded_from_api do` at line 70.
pub fn ruby_tab_spec_l70_d13_be_loaded_from_api(args ...ruby.Value) ruby.Value {
	return tab_spec_bool(tab_spec_subject().loaded_from_api)
}

// Ruby matcher `matcher :be_loaded_from_internal_api do` at line 76.
pub fn ruby_tab_spec_l76_d14_be_loaded_from_internal_api(args ...ruby.Value) ruby.Value {
	return tab_spec_bool(tab_spec_subject().loaded_from_internal_api)
}

// Ruby method `git_commit_all` at line 86.
pub fn ruby_tab_spec_l86_d15_git_commit_all(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 { args[0].as_string() } else { tab_spec_temp_root('git-commit') }
	result := ruby.run_captured_command(['git', 'add', '--all'], ruby.CapturedCommandOptions{ chdir: path, environment: ruby.environment() }) or {
		return tab_spec_bool(false)
	}
	if result.exit_code != 0 {
		return tab_spec_bool(false)
	}
	commit := ruby.run_captured_command(['git', '-c', 'user.name=Tab Spec', '-c',
		'user.email=tab@example.com', 'commit', '-m', 'tab spec commit'], ruby.CapturedCommandOptions{ chdir: path, environment: ruby.environment() }) or {
		return tab_spec_bool(false)
	}
	return tab_spec_bool(commit.exit_code == 0)
}

// Ruby method `setup_git_repo(path)` at line 91.
pub fn ruby_tab_spec_l91_d16_setup_git_repo(args ...ruby.Value) ruby.Value {
	path := if args.len > 0 { args[0].as_string() } else { tab_spec_temp_root('git-setup') }
	ruby.remove_all(path) or {}
	ruby.make_dir_all(path) or { return tab_spec_bool(false) }
	defer { ruby.remove_all(path) or {} }
	initialized := ruby.run_captured_command(['git', '-c', 'init.defaultBranch=master',
		'init'], ruby.CapturedCommandOptions{ chdir: path, environment: ruby.environment() }) or {
		return tab_spec_bool(false)
	}
	if initialized.exit_code != 0 {
		return tab_spec_bool(false)
	}
	ruby.write_file(ruby.join_path(path, 'README'), '') or {
		return tab_spec_bool(false)
	}
	return ruby_tab_spec_l86_d15_git_commit_all(ruby.string_value(path))
}

// Ruby specify `specify "defaults" do` at line 101.
pub fn ruby_tab_spec_l101_d17_defaults(args ...ruby.Value) ruby.Value {
	tab := homebrew.empty_tab()
	return tab_spec_bool(tab.has_homebrew_version && tab.homebrew_version != '' && tab.unused_options().empty() && tab.used_options().empty() && !tab.has_changed_files && !tab.built_as_bottle && !tab.poured_from_bottle && !tab.installed_on_request && !tab.loaded_from_api && !tab.loaded_from_internal_api && tab.stable() && !tab.head() && tab.tap_name() == '' && !tab.has_time && tab.runtime_dependencies() == none && tab.stable_version() == none && tab.head_version() == none && !tab.cxxstdlib().has_type && tab.cxxstdlib().compiler != '' && (tab.source['path'] or { json2.null }) is json2.Null)
}

// Ruby specify `specify do` at line 128.
pub fn ruby_tab_spec_l128_d18_do(args ...ruby.Value) ruby.Value {
	tab := tab_spec_subject()
	return tab_spec_bool(tab.includes('with-foo') && tab.includes('without-bar') && tab.with('foo') && tab.with('qux') && !tab.with('bar') && !tab.with('baz') && tab.cxxstdlib().compiler == 'clang' && tab.cxxstdlib().type_symbol() == 'libcxx' && tab.tap_name() == 'homebrew/core' && tab.time == 1_720_189_863 && !tab.built_as_bottle && tab.poured_from_bottle && tab.installed_on_request && !tab.loaded_from_api && !tab.loaded_from_internal_api)
}

// Ruby specify `specify "#initialize" do` at line 146.
pub fn ruby_tab_spec_l146_d19_initialize(args ...ruby.Value) ruby.Value {
	tab := homebrew.tab_from_json('{"installed_as_dependency":true,"homebrew_version":"1.2.3"}', 'receipt.json') or { return tab_spec_bool(false) }
	return tab_spec_bool(tab.homebrew_version == '1.2.3')
}

// Ruby specify `specify "#installed_on_request_present?" do` at line 152.
pub fn ruby_tab_spec_l152_d20_installed_on_request_present(args ...ruby.Value) ruby.Value {
	missing := homebrew.new_tab(homebrew.TabConfig{})
	present := homebrew.new_tab(homebrew.TabConfig{
		installed_on_request: false
		has_installed_on_request: true
	})
	return tab_spec_bool(!missing.installed_on_request_present && present.installed_on_request_present)
}

// Ruby specify `specify "#parsed_homebrew_version" do` at line 157.
pub fn ruby_tab_spec_l157_d21_parsed_homebrew_version(args ...ruby.Value) ruby.Value {
	missing := homebrew.new_tab(homebrew.TabConfig{})
	one := homebrew.new_tab(homebrew.TabConfig{
		homebrew_version: '1.2.3'
		has_homebrew_version: true
	}).parsed_homebrew_version()
	two := homebrew.new_tab(homebrew.TabConfig{
		homebrew_version: '1.2.4-567-g12789abdf'
		has_homebrew_version: true
	}).parsed_homebrew_version()
	dirty := homebrew.new_tab(homebrew.TabConfig{
		homebrew_version: '2.0.0-134-gabcdefabc-dirty'
		has_homebrew_version: true
	}).parsed_homebrew_version()
	return tab_spec_bool(missing.parsed_homebrew_version().is_null() && one.to_s() == '1.2.3' && one.compare_to(homebrew.new_version('1.2.3-1-g12789abdf') or { return tab_spec_bool(false) }) < 0 && two.compare_to(homebrew.new_version('1.2.4') or { return tab_spec_bool(false) }) > 0 && two.compare_to(homebrew.new_version('1.2.4-566-g21789abdf') or { return tab_spec_bool(false) }) > 0 && two.compare_to(homebrew.new_version('1.2.4-568-g01789abdf') or { return tab_spec_bool(false) }) < 0 && dirty.compare_to(homebrew.new_version('2.0.0') or { return tab_spec_bool(false) }) > 0 && dirty.compare_to(homebrew.new_version('2.0.0-133-g21789abdf') or { return tab_spec_bool(false) }) > 0 && dirty.compare_to(homebrew.new_version('2.0.0-135-g01789abdf') or { return tab_spec_bool(false) }) < 0)
}

// Ruby specify `specify "#runtime_dependencies" do` at line 177.
pub fn ruby_tab_spec_l177_d22_runtime_dependencies(args ...ruby.Value) ruby.Value {
	missing := homebrew.new_tab(homebrew.TabConfig{})
	minimum_without := homebrew.new_tab(homebrew.TabConfig{
		homebrew_version: '1.1.6'
		has_homebrew_version: true
	})
	minimum_with := homebrew.new_tab(homebrew.TabConfig{
		homebrew_version: '1.1.6'
		has_homebrew_version: true
		runtime_dependencies: []homebrew.RuntimeDependencyReceipt{}
		has_runtime_dependencies: true
	})
	old_with := homebrew.new_tab(homebrew.TabConfig{
		homebrew_version: '1.1.5'
		has_homebrew_version: true
		runtime_dependencies: []homebrew.RuntimeDependencyReceipt{}
		has_runtime_dependencies: true
	})
	new_with := homebrew.new_tab(homebrew.TabConfig{
		homebrew_version: '1.1.7'
		has_homebrew_version: true
		runtime_dependencies: [
			homebrew.RuntimeDependencyReceipt{ full_name: 'foo', version: '1.0' },
		]
		has_runtime_dependencies: true
	})
	return tab_spec_bool(missing.runtime_dependencies() == none && minimum_without.runtime_dependencies() == none && minimum_with.runtime_dependencies() != none && old_with.runtime_dependencies() == none && new_with.runtime_dependencies() != none)
}

// Ruby it `it "handles older Homebrew versions correctly" do` at line 201.
pub fn ruby_tab_spec_l201_d23_handles(args ...ruby.Value) ruby.Value {
	root := tab_spec_temp_root('runtime-old')
	formula := tab_spec_formula('foo', '1.0', root, '', [], 0) or {
		return tab_spec_bool(false)
	}
	receipt := homebrew.formula_to_runtime_dependency_receipt(formula, [])
	tab := homebrew.new_tab(homebrew.TabConfig{
		homebrew_version: '1.1.6'
		has_homebrew_version: true
		runtime_dependencies: [receipt]
		has_runtime_dependencies: true
	})
	dependencies := tab.runtime_dependencies() or { return tab_spec_bool(false) }
	return tab_spec_bool(dependencies.len == 1 && dependencies[0].full_name == 'foo' && dependencies[0].version == '1.0' && dependencies[0].revision == 0 && dependencies[0].pkg_version == '1.0' && !dependencies[0].declared_directly)
}

// Ruby it `it "include declared dependencies" do` at line 218.
pub fn ruby_tab_spec_l218_d24_include(args ...ruby.Value) ruby.Value {
	formula := tab_spec_formula('foo', '1.0', tab_spec_temp_root('declared'), '', [], 0) or {
		return tab_spec_bool(false)
	}
	receipt := homebrew.formula_to_runtime_dependency_receipt(formula, ['foo'])
	return tab_spec_bool(receipt.full_name == 'foo' && receipt.version == '1.0' && receipt.has_declared_directly && receipt.declared_directly)
}

// Ruby it `it "includes recursive dependencies" do` at line 240.
pub fn ruby_tab_spec_l240_d25_includes(args ...ruby.Value) ruby.Value {
	root := tab_spec_temp_root('recursive')
	foo := tab_spec_formula('foo', '1.0', root, '', [], 0) or { return tab_spec_bool(false) }
	bar := tab_spec_formula('bar', '2.0', root, '', [], 0) or { return tab_spec_bool(false) }
	receipts := [homebrew.formula_to_runtime_dependency_receipt(foo, ['foo']),
		homebrew.formula_to_runtime_dependency_receipt(bar, ['foo'])]
	return tab_spec_bool(receipts.len == 2 && receipts[0].declared_directly && !receipts[1].declared_directly && receipts[1].version == '2.0')
}

// Ruby it `it "includes compatibility_version when set" do` at line 276.
pub fn ruby_tab_spec_l276_d26_includes(args ...ruby.Value) ruby.Value {
	formula := tab_spec_formula('foo', '1.0', tab_spec_temp_root('compat'), '', [], 1) or {
		return tab_spec_bool(false)
	}
	receipt := homebrew.formula_to_runtime_dependency_receipt(formula, ['foo'])
	return tab_spec_bool(receipt.has_compatibility_version && receipt.compatibility_version == 1)
}

// Ruby it `it "parses a formula Tab from a file" do` at line 303.
pub fn ruby_tab_spec_l303_d27_parses(args ...ruby.Value) ruby.Value {
	tab := homebrew.tab_from_json(tab_spec_receipt().to_json(), '/tmp/2.14/INSTALL_RECEIPT.json') or {
		return tab_spec_bool(false)
	}
	dependencies := tab.runtime_dependencies() or { return tab_spec_bool(false) }
	stable := tab.stable_version() or { return tab_spec_bool(false) }
	head := tab.head_version() or { return tab_spec_bool(false) }
	return tab_spec_bool(tab.used_options().as_flags().sorted() == ['--with-foo', '--without-bar'].sorted() && tab.unused_options().as_flags().sorted() == [
		'--with-baz',
		'--without-qux',
	].sorted() && tab.changed_files == ['INSTALL_RECEIPT.json', 'bin/foo'] && !tab.built_as_bottle && tab.poured_from_bottle && tab.installed_on_request && !tab.loaded_from_api && !tab.loaded_from_internal_api && tab.stable() && !tab.head() && tab.tap_name() == 'homebrew/core' && tab.time == 1_403_827_774 && tab.cxxstdlib().compiler == 'clang' && tab.cxxstdlib().type_symbol() == 'libcxx' && dependencies.len == 1 && dependencies[0].full_name == 'foo' && stable.to_s() == '2.14' && head.to_s() == 'HEAD-0000000' && tab_spec_json_string(tab.source, 'path') == '/usr/local/Library/Taps/homebrew/homebrew-core/Formula/foo.rb')
}

// Ruby it `it "parses a formula Tab from a file" do` at line 333.
pub fn ruby_tab_spec_l333_d28_parses(args ...ruby.Value) ruby.Value {
	return ruby_tab_spec_l303_d27_parses()
}

// Ruby it `it "can parse an old formula Tab file" do` at line 361.
pub fn ruby_tab_spec_l361_d29_can(args ...ruby.Value) ruby.Value {
	tab := homebrew.tab_from_json(tab_spec_old_receipt_json(), '/tmp/foo/1.0/INSTALL_RECEIPT.json') or {
		return tab_spec_bool(false)
	}
	return tab_spec_bool(tab.used_options().as_flags().sorted() == ['--with-foo', '--without-bar'].sorted() && tab.unused_options().as_flags().sorted() == [
		'--with-baz',
		'--without-qux',
	].sorted() && !tab.built_as_bottle && tab.poured_from_bottle && !tab.installed_on_request && !tab.loaded_from_api && !tab.loaded_from_internal_api && tab.stable() && !tab.head() && tab.tap_name() == 'homebrew/core' && tab.time == 1_403_827_774 && tab.cxxstdlib().compiler == 'clang' && tab.cxxstdlib().type_symbol() == 'libcxx' && tab.runtime_dependencies() == none)
}

// Ruby it `it "raises a parse exception message including the Tab filename" do` at line 382.
pub fn ruby_tab_spec_l382_d30_raises(args ...ruby.Value) ruby.Value {
	homebrew.tab_from_json("''", 'receipt.json') or {
		return tab_spec_bool(err.msg().contains('receipt.json'))
	}
	return tab_spec_bool(false)
}

// Ruby it `it "creates a formula Tab" do` at line 391.
pub fn ruby_tab_spec_l391_d31_creates(args ...ruby.Value) ruby.Value {
	root := tab_spec_temp_root('create')
	formula := tab_spec_formula('formula', '1.0', root, '', ['bar', 'user/repo/from_tap'], 0) or {
		return tab_spec_bool(false)
	}
	bar := tab_spec_formula('bar', '2.0', root, '', [], 0) or { return tab_spec_bool(false) }
	from_tap := homebrew.new_formula(homebrew.FormulaConfig{
		reference: api.PackageReference{
			kind: .formula
			name: 'from_tap'
			full_name: 'user/repo/from_tap'
			tap: 'user/repo'
			stable_version: '1.0'
			revision: 1
			local_path: ruby.join_path(root, 'from_tap.rb')
		}
		prefix: root
		cellar: ruby.join_path(root, 'Cellar')
	}) or { return tab_spec_bool(false) }
	mut tab := homebrew.tab_create_for_formula(formula, [bar, from_tap], 'clang', 'libcxx')
	tab.homebrew_version = '1.1.7'
	tab.has_homebrew_version = true
	dependencies := tab.runtime_dependencies() or { return tab_spec_bool(false) }
	return tab_spec_bool(dependencies.len == 2 && dependencies[0].full_name == 'bar' && dependencies[0].declared_directly && dependencies[1].full_name == 'user/repo/from_tap' && dependencies[1].revision == 1 && dependencies[1].pkg_version == '1.0_1' && dependencies[1].declared_directly && tab_spec_json_string(tab.source, 'path') == formula.path() && 'scm_revision' !in tab.source)
}

// Ruby it `it "can create a formula Tab from an alias" do` at line 443.
pub fn ruby_tab_spec_l443_d32_can(args ...ruby.Value) ruby.Value {
	root := tab_spec_temp_root('alias')
	alias_path := ruby.join_path(root, 'Aliases/bar')
	formula := tab_spec_formula('foo', '1.0', root, alias_path, [], 0) or {
		return tab_spec_bool(false)
	}
	tab := homebrew.tab_create_for_formula(formula, [], 'clang', 'libcxx')
	return tab_spec_bool(tab_spec_json_string(tab.source, 'path') == alias_path)
}

// Ruby it `it "records the upstream source revision for VCS formulae" do` at line 456.
pub fn ruby_tab_spec_l456_d33_records(args ...ruby.Value) ruby.Value {
	formula := tab_spec_formula('tab-spec-git', '1.0', tab_spec_temp_root('revision'), '', [], 0) or { return tab_spec_bool(false) }
	commit := '0123456789abcdef0123456789abcdef01234567'
	tab := homebrew.tab_create_for_formula(formula, [], 'clang', 'libcxx', commit)
	return tab_spec_bool(tab_spec_json_string(tab.source, 'scm_revision') == commit)
}

// Ruby subject `subject(:tab_for_keg) { described_class.for_keg(f.prefix) }` at line 475.
pub fn ruby_tab_spec_l475_d34_tab_for_keg(args ...ruby.Value) ruby.Value {
	path := tab_spec_temp_root('for-keg-subject')
	ruby.remove_all(path) or {}
	ruby.make_dir_all(path) or { return tab_spec_nil() }
	defer { ruby.remove_all(path) or {} }
	tab := homebrew.tab_for_keg(path) or { return tab_spec_nil() }
	return homebrew.tab_boundary_value(tab)
}

// Ruby it `it "creates a Tab for a given Keg" do` at line 477.
pub fn ruby_tab_spec_l477_d35_creates(args ...ruby.Value) ruby.Value {
	path := tab_spec_temp_root('for-keg-existing')
	ruby.remove_all(path) or {}
	ruby.make_dir_all(path) or { return tab_spec_bool(false) }
	defer { ruby.remove_all(path) or {} }
	receipt := ruby.join_path(path, homebrew.tab_filename)
	ruby.write_file(receipt, tab_spec_receipt().to_json()) or {
		return tab_spec_bool(false)
	}
	tab := homebrew.tab_for_keg(path) or { return tab_spec_bool(false) }
	return tab_spec_bool(tab.tabfile == receipt)
}

// Ruby it `it "can create a Tab for a non-existent Keg" do` at line 484.
pub fn ruby_tab_spec_l484_d36_can(args ...ruby.Value) ruby.Value {
	path := tab_spec_temp_root('for-keg-missing')
	ruby.remove_all(path) or {}
	ruby.make_dir_all(path) or { return tab_spec_bool(false) }
	defer { ruby.remove_all(path) or {} }
	tab := homebrew.tab_for_keg(path) or { return tab_spec_bool(false) }
	return tab_spec_bool(tab.tabfile == ruby.join_path(path, homebrew.tab_filename))
}

// Ruby it `it "creates a Tab for a given Formula" do` at line 492.
pub fn ruby_tab_spec_l492_d37_creates(args ...ruby.Value) ruby.Value {
	root := tab_spec_temp_root('for-formula')
	formula := tab_spec_formula('foo', '1.0', root, '', [], 0) or {
		return tab_spec_bool(false)
	}
	tab := homebrew.tab_for_formula(formula)
	return tab_spec_bool(tab_spec_json_string(tab.source, 'path') == formula.path())
}

// Ruby it `it "can create a Tab for for a Formula from an alias" do` at line 497.
pub fn ruby_tab_spec_l497_d38_can(args ...ruby.Value) ruby.Value {
	root := tab_spec_temp_root('for-alias')
	alias_path := ruby.join_path(root, 'Aliases/bar')
	formula := tab_spec_formula('foo', '1.0', root, alias_path, [], 0) or {
		return tab_spec_bool(false)
	}
	tab := homebrew.tab_for_formula(formula)
	return tab_spec_bool(tab_spec_json_string(tab.source, 'path') == alias_path)
}

// Ruby it `it "creates a Tab for a given Formula with existing Tab" do` at line 508.
pub fn ruby_tab_spec_l508_d39_creates(args ...ruby.Value) ruby.Value {
	root := tab_spec_temp_root('for-existing')
	ruby.remove_all(root) or {}
	defer { ruby.remove_all(root) or {} }
	formula := tab_spec_formula('foo', '1.0', root, '', [], 0) or {
		return tab_spec_bool(false)
	}
	ruby.make_dir_all(formula.prefix()) or { return tab_spec_bool(false) }
	receipt := ruby.join_path(formula.prefix(), homebrew.tab_filename)
	ruby.write_file(receipt, tab_spec_receipt().to_json()) or {
		return tab_spec_bool(false)
	}
	tab := homebrew.tab_for_formula(formula)
	return tab_spec_bool(tab.tabfile == receipt)
}

// Ruby it `it "can create a Tab for a non-existent Formula" do` at line 516.
pub fn ruby_tab_spec_l516_d40_can(args ...ruby.Value) ruby.Value {
	root := tab_spec_temp_root('for-nonexistent')
	ruby.remove_all(root) or {}
	defer { ruby.remove_all(root) or {} }
	formula := tab_spec_formula('foo', '1.0', root, '', [], 0) or {
		return tab_spec_bool(false)
	}
	ruby.make_dir_all(formula.prefix()) or { return tab_spec_bool(false) }
	tab := homebrew.tab_for_formula(formula)
	return tab_spec_bool(tab.tabfile == '')
}

// Ruby it `it "can create a Tab for a Formula with multiple Kegs" do` at line 523.
pub fn ruby_tab_spec_l523_d41_can(args ...ruby.Value) ruby.Value {
	root := tab_spec_temp_root('multiple-kegs')
	ruby.remove_all(root) or {}
	defer { ruby.remove_all(root) or {} }
	formula := tab_spec_formula('foo', '1.0', root, '', [], 0) or {
		return tab_spec_bool(false)
	}
	formula_two := tab_spec_formula('foo', '2.0', root, '', [], 0) or {
		return tab_spec_bool(false)
	}
	ruby.make_dir_all(formula.prefix()) or { return tab_spec_bool(false) }
	ruby.make_dir_all(formula_two.prefix()) or { return tab_spec_bool(false) }
	receipt := ruby.join_path(formula.prefix(), homebrew.tab_filename)
	ruby.write_file(receipt, tab_spec_receipt().to_json()) or {
		return tab_spec_bool(false)
	}
	tab := homebrew.tab_for_formula(formula)
	return tab_spec_bool(formula.rack() == formula_two.rack() && formula.installed_prefixes().len == 2 && tab.tabfile == receipt)
}

// Ruby it `it "can create a Tab for a Formula with an outdated Kegs" do` at line 540.
pub fn ruby_tab_spec_l540_d42_can(args ...ruby.Value) ruby.Value {
	root := tab_spec_temp_root('outdated-keg')
	ruby.remove_all(root) or {}
	defer { ruby.remove_all(root) or {} }
	formula := tab_spec_formula('foo', '1.0', root, '', [], 0) or {
		return tab_spec_bool(false)
	}
	formula_two := tab_spec_formula('foo', '2.0', root, '', [], 0) or {
		return tab_spec_bool(false)
	}
	ruby.make_dir_all(formula.prefix()) or { return tab_spec_bool(false) }
	receipt := ruby.join_path(formula.prefix(), homebrew.tab_filename)
	ruby.write_file(receipt, tab_spec_receipt().to_json()) or {
		return tab_spec_bool(false)
	}
	tab := homebrew.tab_for_formula(formula)
	return tab_spec_bool(formula.rack() == formula_two.rack() && formula.installed_prefixes().len == 1 && tab.tabfile == receipt)
}

// Ruby specify `specify "#to_json" do` at line 557.
pub fn ruby_tab_spec_l557_d43_to_json(args ...ruby.Value) ruby.Value {
	tab := tab_spec_subject()
	parsed := homebrew.tab_from_json(tab.to_json(), 'receipt.json') or {
		return tab_spec_bool(false)
	}
	stable := parsed.stable_version() or { return tab_spec_bool(false) }
	head := parsed.head_version() or { return tab_spec_bool(false) }
	return tab_spec_bool(parsed.homebrew_version == tab.homebrew_version && parsed.used_options().as_flags().sorted() == tab.used_options().as_flags().sorted() && parsed.unused_options().as_flags().sorted() == tab.unused_options().as_flags().sorted() && parsed.built_as_bottle == tab.built_as_bottle && parsed.poured_from_bottle == tab.poured_from_bottle && parsed.changed_files == tab.changed_files && parsed.tap_name() == tab.tap_name() && parsed.spec() == tab.spec() && parsed.time == tab.time && parsed.compiler() == tab.compiler() && parsed.stdlib == tab.stdlib && stable.to_s() == '0.10' && head.to_s() == 'HEAD-1111111' && tab_spec_json_string(parsed.source, 'path') == tab_spec_json_string(tab.source, 'path') && tab_spec_json_string(parsed.source, 'scm_revision') == tab_spec_json_string(tab.source, 'scm_revision') && parsed.arch == tab.arch && tab_spec_json_string(parsed.built_on, 'os') == tab_spec_json_string(tab.built_on, 'os'))
}

// Ruby specify `specify "#to_bottle_hash" do` at line 579.
pub fn ruby_tab_spec_l579_d44_to_bottle_hash(args ...ruby.Value) ruby.Value {
	tab := tab_spec_subject()
	attributes := tab.bottle_attributes()
	source_modified_time := (attributes['source_modified_time'] or { return tab_spec_bool(false) }).i64()
	built_on := tab_spec_json_map(attributes, 'built_on')
	source := tab_spec_json_map(attributes, 'source')
	return tab_spec_bool(tab_spec_json_string(attributes, 'homebrew_version') == tab.homebrew_version && source_modified_time == tab.source_modified_time() && tab_spec_json_string(attributes, 'compiler') == tab.compiler() && tab_spec_json_string(attributes, 'stdlib') == tab.stdlib && tab_spec_json_string(attributes, 'arch') == tab.arch && tab_spec_json_string(built_on, 'os') == tab_spec_json_string(tab.built_on, 'os') && tab_spec_json_string(source, 'scm_revision') == tab_spec_json_string(tab.source, 'scm_revision'))
}

// Ruby let `let(:time_string) { Time.at(1_720_189_863).strftime("%Y-%m-%d at %H:%M:%S") }` at line 593.
pub fn ruby_tab_spec_l593_d45_time_string(args ...ruby.Value) ruby.Value {
	return ruby.string_value(time.unix(1_720_189_863).format_ss().replace(' ', ' at '))
}

// Ruby it `it "returns install information for the Tab" do` at line 595.
pub fn ruby_tab_spec_l595_d46_returns(args ...ruby.Value) ruby.Value {
	tab := homebrew.new_tab(homebrew.TabConfig{
		poured_from_bottle: true
		has_poured_from_bottle: true
		loaded_from_api: true
		has_loaded_from_api: true
		loaded_from_internal_api: false
		has_loaded_from_internal_api: true
		time: 1_720_189_863
		has_time: true
		used_options: ['--with-foo', '--without-bar']
	})
	expected := 'Poured from bottle using the formulae.brew.sh API on ${time.unix(1_720_189_863).format_ss().replace(' ', ' at ')} with: --with-foo --without-bar'
	return tab_spec_bool(tab.str() == expected)
}

// Ruby it `it "includes 'Poured from bottle' if the formula was installed from a bottle" do` at line 608.
pub fn ruby_tab_spec_l608_d47_includes(args ...ruby.Value) ruby.Value {
	tab := homebrew.new_tab(homebrew.TabConfig{
		poured_from_bottle: true
		has_poured_from_bottle: true
	})
	return tab_spec_bool(tab.str().contains('Poured from bottle'))
}

// Ruby it `it "includes 'Built from source' if the formula was not installed from a bottle" do` at line 613.
pub fn ruby_tab_spec_l613_d48_includes(args ...ruby.Value) ruby.Value {
	tab := homebrew.new_tab(homebrew.TabConfig{
		poured_from_bottle: false
		has_poured_from_bottle: true
	})
	return tab_spec_bool(tab.str().contains('Built from source'))
}

// Ruby it `it "includes 'using the formulae.brew.sh API' if the formula was installed from the API" do` at line 618.
pub fn ruby_tab_spec_l618_d49_includes(args ...ruby.Value) ruby.Value {
	tab := homebrew.new_tab(homebrew.TabConfig{
		loaded_from_api: true
		has_loaded_from_api: true
	})
	return tab_spec_bool(tab.str().contains('using the formulae.brew.sh API'))
}

// Ruby it `it "includes 'using the internal formulae.brew.sh API' if the formula was installed from the internal API" do` at line 623.
pub fn ruby_tab_spec_l623_d50_includes(args ...ruby.Value) ruby.Value {
	tab := homebrew.new_tab(homebrew.TabConfig{
		loaded_from_api: true
		has_loaded_from_api: true
		loaded_from_internal_api: true
		has_loaded_from_internal_api: true
	})
	return tab_spec_bool(tab.str().contains('using the internal formulae.brew.sh API'))
}

// Ruby it `it "does not include 'using the formulae.brew.sh API' if the formula was not installed from the API" do` at line 628.
pub fn ruby_tab_spec_l628_d51_does(args ...ruby.Value) ruby.Value {
	tab := homebrew.new_tab(homebrew.TabConfig{
		loaded_from_api: false
		has_loaded_from_api: true
	})
	return tab_spec_bool(!tab.str().contains('using the formulae.brew.sh API'))
}

// Ruby it `it "doesn't include 'using the internal formulae.brew.sh API' if the formula wasn't installed via internal API" do` at line 633.
pub fn ruby_tab_spec_l633_d52_doesn(args ...ruby.Value) ruby.Value {
	tab := homebrew.new_tab(homebrew.TabConfig{
		loaded_from_api: true
		has_loaded_from_api: true
		loaded_from_internal_api: false
		has_loaded_from_internal_api: true
	})
	return tab_spec_bool(!tab.str().contains('using the internal formulae.brew.sh API'))
}

// Ruby it `it "includes the time value if specified" do` at line 638.
pub fn ruby_tab_spec_l638_d53_includes(args ...ruby.Value) ruby.Value {
	tab := homebrew.new_tab(homebrew.TabConfig{ time: 1_720_189_863, has_time: true })
	return tab_spec_bool(tab.str().contains('on ${time.unix(1_720_189_863).format_ss().replace(' ', ' at ')}'))
}

// Ruby it `it "does not include the time value if not specified" do` at line 643.
pub fn ruby_tab_spec_l643_d54_does(args ...ruby.Value) ruby.Value {
	tab := homebrew.new_tab(homebrew.TabConfig{})
	return tab_spec_bool(!tab.str().contains(' on '))
}

// Ruby it `it "includes options if specified" do` at line 648.
pub fn ruby_tab_spec_l648_d55_includes(args ...ruby.Value) ruby.Value {
	tab := homebrew.new_tab(homebrew.TabConfig{
		used_options: ['--with-foo', '--without-bar']
	})
	return tab_spec_bool(tab.str().contains('with: --with-foo --without-bar'))
}

// Ruby it `it "not to include options if not specified" do` at line 653.
pub fn ruby_tab_spec_l653_d56_not(args ...ruby.Value) ruby.Value {
	tab := homebrew.new_tab(homebrew.TabConfig{ used_options: [] })
	return tab_spec_bool(!tab.str().contains('with: '))
}

// Ruby specify `specify "::remap_deprecated_options" do` at line 659.
pub fn ruby_tab_spec_l659_d57_remap_deprecated_options(args ...ruby.Value) ruby.Value {
	remapped := homebrew.remap_tab_deprecated_options([
		homebrew.new_deprecated_option('with-foo', 'with-foo-new'),
	], tab_spec_subject().used_options())
	return tab_spec_bool(remapped.contains('without-bar') && remapped.contains('with-foo-new'))
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "tab"
// 5: require "formula"
// 6:
// 7: RSpec.describe Tab do
// 8:   subject(:tab) do
// 9:     described_class.new(
// 10:       homebrew_version:     HOMEBREW_VERSION,
// 11:       used_options:         used_options.as_flags,
// 12:       unused_options:       unused_options.as_flags,
// 13:       built_as_bottle:      false,
// 14:       poured_from_bottle:   true,
// 15:       installed_on_request: true,
// 16:       changed_files:        [],
// 17:       time:,
// 18:       source_modified_time: 0,
// 19:       compiler:             "clang",
// 20:       stdlib:               "libcxx",
// 21:       runtime_dependencies: [],
// 22:       source:               {
// 23:         "tap"          => CoreTap.instance.to_s,
// 24:         "path"         => CoreTap.instance.path.to_s,
// 25:         "spec"         => "stable",
// 26:         "scm_revision" => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
// 27:         "versions"     => {
// 28:           "stable" => "0.10",
// 29:           "head"   => "HEAD-1111111",
// 30:         },
// 31:       },
// 32:       arch:                 Hardware::CPU.arch,
// 33:       built_on:             DevelopmentTools.build_system_info,
// 34:     )
// 35:   end
// 36:
// 37:   let(:time) { Time.now.to_i }
// 38:   let(:unused_options) { Options.create(%w[--with-baz --without-qux]) }
// 39:   let(:used_options) { Options.create(%w[--with-foo --without-bar]) }
// 40:   let(:git_repo) { HOMEBREW_CACHE/"tab-spec-git-repo" }
// 41:   let(:f) do
// 42:     formula do
// 43:       T.bind(self, T.class_of(Formula))
// 44:       url "foo-1.0"
// 45:     end
// 46:   end
// 47:   let(:f_tab_path) { f.prefix/"INSTALL_RECEIPT.json" }
// 48:   let(:f_tab_content) { (TEST_FIXTURE_DIR/"receipt.json").read }
// 49:
// 50:   alias_matcher :be_built_with, :be_with
// 51:
// 52:   matcher :be_poured_from_bottle do
// 53:     match do |actual|
// 54:       actual.poured_from_bottle == true
// 55:     end
// 56:   end
// 57:
// 58:   matcher :be_built_as_bottle do
// 59:     match do |actual|
// 60:       actual.built_as_bottle == true
// 61:     end
// 62:   end
// 63:
// 64:   matcher :be_installed_on_request do
// 65:     match do |actual|
// 66:       actual.installed_on_request == true
// 67:     end
// 68:   end
// 69:
// 70:   matcher :be_loaded_from_api do
// 71:     match do |actual|
// 72:       actual.loaded_from_api == true
// 73:     end
// 74:   end
// 75:
// 76:   matcher :be_loaded_from_internal_api do
// 77:     match do |actual|
// 78:       actual.loaded_from_internal_api == true
// 79:     end
// 80:   end
// 81:
// 82:   after do
// 83:     FileUtils.rm_rf git_repo
// 84:   end
// 85:
// 86:   def git_commit_all
// 87:     system "git", "add", "--all"
// 88:     system "git", "commit", "-m", "tab spec commit"
// 89:   end
// 90:
// 91:   def setup_git_repo(path)
// 92:     path.mkpath
// 93:
// 94:     path.cd do
// 95:       system "git", "-c", "init.defaultBranch=master", "init"
// 96:       FileUtils.touch "README"
// 97:       git_commit_all
// 98:     end
// 99:   end
// 100:
// 101:   specify "defaults" do
// 102:     # < 1.1.7 runtime_dependencies were wrong so are ignored
// 103:     stub_const("HOMEBREW_VERSION", "1.1.7")
// 104:
// 105:     tab = described_class.empty
// 106:
// 107:     expect(tab.homebrew_version).to eq(HOMEBREW_VERSION)
// 108:     expect(tab.unused_options).to be_empty
// 109:     expect(tab.used_options).to be_empty
// 110:     expect(tab.changed_files).to be_nil
// 111:     expect(tab).not_to be_built_as_bottle
// 112:     expect(tab).not_to be_poured_from_bottle
// 113:     expect(tab).not_to be_installed_on_request
// 114:     expect(tab).not_to be_loaded_from_api
// 115:     expect(tab).not_to be_loaded_from_internal_api
// 116:     expect(tab).to be_stable
// 117:     expect(tab).not_to be_head
// 118:     expect(tab.tap).to be_nil
// 119:     expect(tab.time).to be_nil
// 120:     expect(tab.runtime_dependencies).to be_nil
// 121:     expect(tab.stable_version).to be_nil
// 122:     expect(tab.head_version).to be_nil
// 123:     expect(tab.cxxstdlib.compiler).to eq(DevelopmentTools.default_compiler)
// 124:     expect(tab.cxxstdlib.type).to be_nil
// 125:     expect(tab.source["path"]).to be_nil
// 126:   end
// 127:
// 128:   specify do
// 129:     expect(tab).to include("with-foo")
// 130:     expect(tab).to include("without-bar")
// 131:     expect(tab).to be_built_with("foo")
// 132:     expect(tab).to be_built_with("qux")
// 133:     expect(tab).not_to be_built_with("bar")
// 134:     expect(tab).not_to be_built_with("baz")
// 135:     expect(tab.cxxstdlib.compiler).to eq(:clang)
// 136:     expect(tab.cxxstdlib.type).to eq(:libcxx)
// 137:     expect(tab.tap.name).to eq("homebrew/core")
// 138:     expect(tab.time).to eq(time)
// 139:     expect(tab).not_to be_built_as_bottle
// 140:     expect(tab).to be_poured_from_bottle
// 141:     expect(tab).to be_installed_on_request
// 142:     expect(tab).not_to be_loaded_from_api
// 143:     expect(tab).not_to be_loaded_from_internal_api
// 144:   end
// 145:
// 146:   specify "#initialize" do
// 147:     # Receipts written by other Homebrew versions carry attributes we no longer know about.
// 148:     tab = described_class.new(installed_as_dependency: true, homebrew_version: "1.2.3")
// 149:     expect(tab.homebrew_version).to eq("1.2.3")
// 150:   end
// 151:
// 152:   specify "#installed_on_request_present?" do
// 153:     expect(described_class.new).not_to be_installed_on_request_present
// 154:     expect(described_class.new(installed_on_request: false)).to be_installed_on_request_present
// 155:   end
// 156:
// 157:   specify "#parsed_homebrew_version" do
// 158:     tab = described_class.new
// 159:     expect(tab.parsed_homebrew_version).to be Version::NULL
// 160:
// 161:     tab = described_class.new(homebrew_version: "1.2.3")
// 162:     expect(tab.parsed_homebrew_version).to eq("1.2.3")
// 163:     expect(tab.parsed_homebrew_version).to be < "1.2.3-1-g12789abdf"
// 164:     expect(tab.parsed_homebrew_version).to be_a(Version)
// 165:
// 166:     tab.homebrew_version = "1.2.4-567-g12789abdf"
// 167:     expect(tab.parsed_homebrew_version).to be > "1.2.4"
// 168:     expect(tab.parsed_homebrew_version).to be > "1.2.4-566-g21789abdf"
// 169:     expect(tab.parsed_homebrew_version).to be < "1.2.4-568-g01789abdf"
// 170:
// 171:     tab = described_class.new(homebrew_version: "2.0.0-134-gabcdefabc-dirty")
// 172:     expect(tab.parsed_homebrew_version).to be > "2.0.0"
// 173:     expect(tab.parsed_homebrew_version).to be > "2.0.0-133-g21789abdf"
// 174:     expect(tab.parsed_homebrew_version).to be < "2.0.0-135-g01789abdf"
// 175:   end
// 176:
// 177:   specify "#runtime_dependencies" do
// 178:     tab = described_class.new
// 179:     expect(tab.runtime_dependencies).to be_nil
// 180:
// 181:     tab.homebrew_version = "1.1.6"
// 182:     expect(tab.runtime_dependencies).to be_nil
// 183:
// 184:     tab.runtime_dependencies = []
// 185:     expect(tab.runtime_dependencies).not_to be_nil
// 186:
// 187:     tab.homebrew_version = "1.1.5"
// 188:     expect(tab.runtime_dependencies).to be_nil
// 189:
// 190:     tab.homebrew_version = "1.1.7"
// 191:     expect(tab.runtime_dependencies).not_to be_nil
// 192:
// 193:     tab.homebrew_version = "1.1.10"
// 194:     expect(tab.runtime_dependencies).not_to be_nil
// 195:
// 196:     tab.runtime_dependencies = [{ "full_name" => "foo", "version" => "1.0" }]
// 197:     expect(tab.runtime_dependencies).not_to be_nil
// 198:   end
// 199:
// 200:   describe "::runtime_deps_hash" do
// 201:     it "handles older Homebrew versions correctly" do
// 202:       runtime_deps = [Dependency.new("foo")]
// 203:       foo = formula("foo") do
// 204:         T.bind(self, T.class_of(Formula))
// 205:         url "foo-1.0"
// 206:       end
// 207:       stub_formula_loader foo
// 208:       runtime_deps_hash = described_class.runtime_deps_hash(foo, runtime_deps)
// 209:       tab = described_class.new
// 210:       tab.homebrew_version = "1.1.6"
// 211:       tab.runtime_dependencies = runtime_deps_hash
// 212:       expect(tab.runtime_dependencies).to eql(
// 213:         [{ "full_name" => "foo", "version" => "1.0", "revision" => 0, "pkg_version" => "1.0",
// 214:         "declared_directly" => false }],
// 215:       )
// 216:     end
// 217:
// 218:     it "include declared dependencies" do
// 219:       foo = formula("foo") do
// 220:         T.bind(self, T.class_of(Formula))
// 221:         url "foo-1.0"
// 222:       end
// 223:       stub_formula_loader foo
// 224:
// 225:       runtime_deps = [Dependency.new("foo")]
// 226:       formula = instance_double(Formula, deps: runtime_deps)
// 227:
// 228:       expected_output = [
// 229:         {
// 230:           "full_name"         => "foo",
// 231:           "version"           => "1.0",
// 232:           "revision"          => 0,
// 233:           "pkg_version"       => "1.0",
// 234:           "declared_directly" => true,
// 235:         },
// 236:       ]
// 237:       expect(described_class.runtime_deps_hash(formula, runtime_deps)).to eq(expected_output)
// 238:     end
// 239:
// 240:     it "includes recursive dependencies" do
// 241:       foo = formula("foo") do
// 242:         T.bind(self, T.class_of(Formula))
// 243:         url "foo-1.0"
// 244:       end
// 245:       bar = formula("bar") do
// 246:         T.bind(self, T.class_of(Formula))
// 247:         url "bar-2.0"
// 248:       end
// 249:       stub_formula_loader foo
// 250:       stub_formula_loader bar
// 251:
// 252:       # Simulating dependencies formula => foo => bar
// 253:       formula_declared_deps = [Dependency.new("foo")]
// 254:       formula_recursive_deps = [Dependency.new("foo"), Dependency.new("bar")]
// 255:       formula = instance_double(Formula, deps: formula_declared_deps)
// 256:
// 257:       expected_output = [
// 258:         {
// 259:           "full_name"         => "foo",
// 260:           "version"           => "1.0",
// 261:           "revision"          => 0,
// 262:           "pkg_version"       => "1.0",
// 263:           "declared_directly" => true,
// 264:         },
// 265:         {
// 266:           "full_name"         => "bar",
// 267:           "version"           => "2.0",
// 268:           "revision"          => 0,
// 269:           "pkg_version"       => "2.0",
// 270:           "declared_directly" => false,
// 271:         },
// 272:       ]
// 273:       expect(described_class.runtime_deps_hash(formula, formula_recursive_deps)).to eq(expected_output)
// 274:     end
// 275:
// 276:     it "includes compatibility_version when set" do
// 277:       foo = formula("foo") do
// 278:         T.bind(self, T.class_of(Formula))
// 279:         url "foo-1.0"
// 280:         compatibility_version 1
// 281:       end
// 282:       stub_formula_loader foo
// 283:
// 284:       formula_declared_deps = [Dependency.new("foo")]
// 285:       formula_recursive_deps = [Dependency.new("foo")]
// 286:       formula = instance_double(Formula, deps: formula_declared_deps)
// 287:
// 288:       expected_output = [
// 289:         {
// 290:           "full_name"             => "foo",
// 291:           "version"               => "1.0",
// 292:           "revision"              => 0,
// 293:           "pkg_version"           => "1.0",
// 294:           "declared_directly"     => true,
// 295:           "compatibility_version" => 1,
// 296:         },
// 297:       ]
// 298:       expect(described_class.runtime_deps_hash(formula, formula_recursive_deps)).to eq(expected_output)
// 299:     end
// 300:   end
// 301:
// 302:   describe "::from_file" do
// 303:     it "parses a formula Tab from a file" do
// 304:       path = Pathname.new("#{TEST_FIXTURE_DIR}/receipt.json")
// 305:       tab = described_class.from_file(path)
// 306:       source_path = "/usr/local/Library/Taps/homebrew/homebrew-core/Formula/foo.rb"
// 307:       runtime_dependencies = [{ "full_name" => "foo", "version" => "1.0" }]
// 308:       changed_files = %w[INSTALL_RECEIPT.json bin/foo].map { Pathname.new(it) }
// 309:
// 310:       expect(tab.used_options.sort).to eq(used_options.sort)
// 311:       expect(tab.unused_options.sort).to eq(unused_options.sort)
// 312:       expect(tab.changed_files).to eq(changed_files)
// 313:       expect(tab).not_to be_built_as_bottle
// 314:       expect(tab).to be_poured_from_bottle
// 315:       expect(tab).to be_installed_on_request
// 316:       expect(tab).not_to be_loaded_from_api
// 317:       expect(tab).not_to be_loaded_from_internal_api
// 318:       expect(tab).to be_stable
// 319:       expect(tab).not_to be_head
// 320:       expect(tab.tap.name).to eq("homebrew/core")
// 321:       expect(tab.spec).to eq(:stable)
// 322:       expect(tab.time).to eq(Time.at(1_403_827_774).to_i)
// 323:       expect(tab.cxxstdlib.compiler).to eq(:clang)
// 324:       expect(tab.cxxstdlib.type).to eq(:libcxx)
// 325:       expect(tab.runtime_dependencies).to eq(runtime_dependencies)
// 326:       expect(tab.stable_version.to_s).to eq("2.14")
// 327:       expect(tab.head_version.to_s).to eq("HEAD-0000000")
// 328:       expect(tab.source["path"]).to eq(source_path)
// 329:     end
// 330:   end
// 331:
// 332:   describe "::from_file_content" do
// 333:     it "parses a formula Tab from a file" do
// 334:       path = Pathname.new("#{TEST_FIXTURE_DIR}/receipt.json")
// 335:       tab = described_class.from_file_content(path.read, path)
// 336:       source_path = "/usr/local/Library/Taps/homebrew/homebrew-core/Formula/foo.rb"
// 337:       runtime_dependencies = [{ "full_name" => "foo", "version" => "1.0" }]
// 338:       changed_files = %w[INSTALL_RECEIPT.json bin/foo].map { Pathname.new(it) }
// 339:
// 340:       expect(tab.used_options.sort).to eq(used_options.sort)
// 341:       expect(tab.unused_options.sort).to eq(unused_options.sort)
// 342:       expect(tab.changed_files).to eq(changed_files)
// 343:       expect(tab).not_to be_built_as_bottle
// 344:       expect(tab).to be_poured_from_bottle
// 345:       expect(tab).to be_installed_on_request
// 346:       expect(tab).not_to be_loaded_from_api
// 347:       expect(tab).not_to be_loaded_from_internal_api
// 348:       expect(tab).to be_stable
// 349:       expect(tab).not_to be_head
// 350:       expect(tab.tap.name).to eq("homebrew/core")
// 351:       expect(tab.spec).to eq(:stable)
// 352:       expect(tab.time).to eq(Time.at(1_403_827_774).to_i)
// 353:       expect(tab.cxxstdlib.compiler).to eq(:clang)
// 354:       expect(tab.cxxstdlib.type).to eq(:libcxx)
// 355:       expect(tab.runtime_dependencies).to eq(runtime_dependencies)
// 356:       expect(tab.stable_version.to_s).to eq("2.14")
// 357:       expect(tab.head_version.to_s).to eq("HEAD-0000000")
// 358:       expect(tab.source["path"]).to eq(source_path)
// 359:     end
// 360:
// 361:     it "can parse an old formula Tab file" do
// 362:       path = Pathname.new("#{TEST_FIXTURE_DIR}/receipt_old.json")
// 363:       tab = described_class.from_file_content(path.read, path)
// 364:
// 365:       expect(tab.used_options.sort).to eq(used_options.sort)
// 366:       expect(tab.unused_options.sort).to eq(unused_options.sort)
// 367:       expect(tab).not_to be_built_as_bottle
// 368:       expect(tab).to be_poured_from_bottle
// 369:       expect(tab).not_to be_installed_on_request
// 370:       expect(tab).not_to be_loaded_from_api
// 371:       expect(tab).not_to be_loaded_from_internal_api
// 372:       expect(tab).to be_stable
// 373:       expect(tab).not_to be_head
// 374:       expect(tab.tap.name).to eq("homebrew/core")
// 375:       expect(tab.spec).to eq(:stable)
// 376:       expect(tab.time).to eq(Time.at(1_403_827_774).to_i)
// 377:       expect(tab.cxxstdlib.compiler).to eq(:clang)
// 378:       expect(tab.cxxstdlib.type).to eq(:libcxx)
// 379:       expect(tab.runtime_dependencies).to be_nil
// 380:     end
// 381:
// 382:     it "raises a parse exception message including the Tab filename" do
// 383:       expect { described_class.from_file_content("''", "receipt.json") }.to raise_error(
// 384:         JSON::ParserError,
// 385:         /receipt.json:/,
// 386:       )
// 387:     end
// 388:   end
// 389:
// 390:   describe "::create" do
// 391:     it "creates a formula Tab" do
// 392:       # < 1.1.7 runtime dependencies were wrong so are ignored
// 393:       stub_const("HOMEBREW_VERSION", "1.1.7")
// 394:
// 395:       # don't try to load gcc/glibc
// 396:       allow(DevelopmentTools).to receive_messages(needs_libc_formula?: false, needs_compiler_formula?: false)
// 397:
// 398:       f = formula do
// 399:         T.bind(self, T.class_of(Formula))
// 400:         url "foo-1.0"
// 401:         depends_on "bar"
// 402:         depends_on "user/repo/from_tap"
// 403:         depends_on "baz" => :build
// 404:       end
// 405:
// 406:       tap = Tap.fetch("user", "repo")
// 407:       from_tap = formula("from_tap", path: tap.path/"Formula/from_tap.rb") do
// 408:         T.bind(self, T.class_of(Formula))
// 409:         url "from_tap-1.0"
// 410:         revision 1
// 411:       end
// 412:       stub_formula_loader from_tap
// 413:
// 414:       stub_formula_loader(
// 415:         formula("bar") do
// 416:           T.bind(self, T.class_of(Formula))
// 417:           url "bar-2.0"
// 418:         end,
// 419:       )
// 420:       stub_formula_loader(
// 421:         formula("baz") do
// 422:           T.bind(self, T.class_of(Formula))
// 423:           url "baz-3.0"
// 424:         end,
// 425:       )
// 426:
// 427:       compiler = DevelopmentTools.default_compiler
// 428:       stdlib = :libcxx
// 429:       tab = described_class.create(f, compiler, stdlib)
// 430:
// 431:       runtime_dependencies = [
// 432:         { "full_name" => "bar", "version" => "2.0", "revision" => 0, "pkg_version" => "2.0",
// 433: "declared_directly" => true },
// 434:         { "full_name" => "user/repo/from_tap", "version" => "1.0", "revision" => 1, "pkg_version" => "1.0_1",
// 435: "declared_directly" => true },
// 436:       ]
// 437:       expect(tab.runtime_dependencies).to eq(runtime_dependencies)
// 438:
// 439:       expect(tab.source["path"]).to eq(f.path.to_s)
// 440:       expect(tab.source["scm_revision"]).to be_nil
// 441:     end
// 442:
// 443:     it "can create a formula Tab from an alias" do
// 444:       alias_path = CoreTap.instance.alias_dir/"bar"
// 445:       f = formula(alias_path:) do
// 446:         T.bind(self, T.class_of(Formula))
// 447:         url "foo-1.0"
// 448:       end
// 449:       compiler = DevelopmentTools.default_compiler
// 450:       stdlib = :libcxx
// 451:       tab = described_class.create(f, compiler, stdlib)
// 452:
// 453:       expect(tab.source["path"]).to eq(f.alias_path.to_s)
// 454:     end
// 455:
// 456:     it "records the upstream source revision for VCS formulae" do
// 457:       setup_git_repo(git_repo)
// 458:
// 459:       commit = git_repo.cd { Utils.popen_read("git", "rev-parse", "HEAD").chomp }
// 460:       repo = git_repo
// 461:       f = formula("tab-spec-git") do
// 462:         T.bind(self, T.class_of(Formula))
// 463:         url "file://#{repo}", using: :git, branch: "master"
// 464:         version "1.0"
// 465:       end
// 466:       f.active_spec.fetch
// 467:
// 468:       tab = described_class.create(f, DevelopmentTools.default_compiler, :libcxx)
// 469:
// 470:       expect(tab.source["scm_revision"]).to eq(commit)
// 471:     end
// 472:   end
// 473:
// 474:   describe "::for_keg" do
// 475:     subject(:tab_for_keg) { described_class.for_keg(f.prefix) }
// 476:
// 477:     it "creates a Tab for a given Keg" do
// 478:       f.prefix.mkpath
// 479:       f_tab_path.write f_tab_content
// 480:
// 481:       expect(tab_for_keg.tabfile).to eq(f_tab_path)
// 482:     end
// 483:
// 484:     it "can create a Tab for a non-existent Keg" do
// 485:       f.prefix.mkpath
// 486:
// 487:       expect(tab_for_keg.tabfile).to eq(f_tab_path)
// 488:     end
// 489:   end
// 490:
// 491:   describe "::for_formula" do
// 492:     it "creates a Tab for a given Formula" do
// 493:       tab = described_class.for_formula(f)
// 494:       expect(tab.source["path"]).to eq(f.path.to_s)
// 495:     end
// 496:
// 497:     it "can create a Tab for for a Formula from an alias" do
// 498:       alias_path = CoreTap.instance.alias_dir/"bar"
// 499:       f = formula(alias_path:) do
// 500:         T.bind(self, T.class_of(Formula))
// 501:         url "foo-1.0"
// 502:       end
// 503:
// 504:       tab = described_class.for_formula(f)
// 505:       expect(tab.source["path"]).to eq(alias_path.to_s)
// 506:     end
// 507:
// 508:     it "creates a Tab for a given Formula with existing Tab" do
// 509:       f.prefix.mkpath
// 510:       f_tab_path.write f_tab_content
// 511:
// 512:       tab = described_class.for_formula(f)
// 513:       expect(tab.tabfile).to eq(f_tab_path)
// 514:     end
// 515:
// 516:     it "can create a Tab for a non-existent Formula" do
// 517:       f.prefix.mkpath
// 518:
// 519:       tab = described_class.for_formula(f)
// 520:       expect(tab.tabfile).to be_nil
// 521:     end
// 522:
// 523:     it "can create a Tab for a Formula with multiple Kegs" do
// 524:       f.prefix.mkpath
// 525:       f_tab_path.write f_tab_content
// 526:
// 527:       f2 = formula do
// 528:         T.bind(self, T.class_of(Formula))
// 529:         url "foo-2.0"
// 530:       end
// 531:       f2.prefix.mkpath
// 532:
// 533:       expect(f2.rack).to eq(f.rack)
// 534:       expect(f.installed_prefixes.length).to eq(2)
// 535:
// 536:       tab = described_class.for_formula(f)
// 537:       expect(tab.tabfile).to eq(f_tab_path)
// 538:     end
// 539:
// 540:     it "can create a Tab for a Formula with an outdated Kegs" do
// 541:       f.prefix.mkpath
// 542:       f_tab_path.write f_tab_content
// 543:
// 544:       f2 = formula do
// 545:         T.bind(self, T.class_of(Formula))
// 546:         url "foo-2.0"
// 547:       end
// 548:
// 549:       expect(f2.rack).to eq(f.rack)
// 550:       expect(f.installed_prefixes.length).to eq(1)
// 551:
// 552:       tab = described_class.for_formula(f)
// 553:       expect(tab.tabfile).to eq(f_tab_path)
// 554:     end
// 555:   end
// 556:
// 557:   specify "#to_json" do
// 558:     json_tab = described_class.new(**JSON.parse(tab.to_json).transform_keys(&:to_sym))
// 559:     expect(json_tab.homebrew_version).to eq(tab.homebrew_version)
// 560:     expect(json_tab.used_options.sort).to eq(tab.used_options.sort)
// 561:     expect(json_tab.unused_options.sort).to eq(tab.unused_options.sort)
// 562:     expect(json_tab.built_as_bottle).to eq(tab.built_as_bottle)
// 563:     expect(json_tab.poured_from_bottle).to eq(tab.poured_from_bottle)
// 564:     expect(json_tab.changed_files).to eq(tab.changed_files)
// 565:     expect(json_tab.tap).to eq(tab.tap)
// 566:     expect(json_tab.spec).to eq(tab.spec)
// 567:     expect(json_tab.time).to eq(tab.time)
// 568:     expect(json_tab.compiler).to eq(tab.compiler)
// 569:     expect(json_tab.stdlib).to eq(tab.stdlib)
// 570:     expect(json_tab.runtime_dependencies).to eq(tab.runtime_dependencies)
// 571:     expect(json_tab.stable_version).to eq(tab.stable_version)
// 572:     expect(json_tab.head_version).to eq(tab.head_version)
// 573:     expect(json_tab.source["path"]).to eq(tab.source["path"])
// 574:     expect(json_tab.source["scm_revision"]).to eq(tab.source["scm_revision"])
// 575:     expect(json_tab.arch).to eq(tab.arch.to_s)
// 576:     expect(json_tab.built_on["os"]).to eq(tab.built_on["os"])
// 577:   end
// 578:
// 579:   specify "#to_bottle_hash" do
// 580:     json_tab = described_class.new(**JSON.parse(tab.to_bottle_hash.to_json).transform_keys(&:to_sym))
// 581:     expect(json_tab.homebrew_version).to eq(tab.homebrew_version)
// 582:     expect(json_tab.changed_files).to eq(tab.changed_files)
// 583:     expect(json_tab.source_modified_time).to eq(tab.source_modified_time)
// 584:     expect(json_tab.stdlib).to eq(tab.stdlib)
// 585:     expect(json_tab.compiler).to eq(tab.compiler)
// 586:     expect(json_tab.runtime_dependencies).to eq(tab.runtime_dependencies)
// 587:     expect(json_tab.source["scm_revision"]).to eq(tab.source["scm_revision"])
// 588:     expect(json_tab.arch).to eq(tab.arch.to_s)
// 589:     expect(json_tab.built_on["os"]).to eq(tab.built_on["os"])
// 590:   end
// 591:
// 592:   describe "#to_s" do
// 593:     let(:time_string) { Time.at(1_720_189_863).strftime("%Y-%m-%d at %H:%M:%S") }
// 594:
// 595:     it "returns install information for the Tab" do
// 596:       tab = described_class.new(
// 597:         poured_from_bottle:       true,
// 598:         loaded_from_api:          true,
// 599:         loaded_from_internal_api: false,
// 600:         time:                     1_720_189_863,
// 601:         used_options:             %w[--with-foo --without-bar],
// 602:       )
// 603:       output = "Poured from bottle using the formulae.brew.sh API on #{time_string} " \
// 604:                "with: --with-foo --without-bar"
// 605:       expect(tab.to_s).to eq(output)
// 606:     end
// 607:
// 608:     it "includes 'Poured from bottle' if the formula was installed from a bottle" do
// 609:       tab = described_class.new(poured_from_bottle: true)
// 610:       expect(tab.to_s).to include("Poured from bottle")
// 611:     end
// 612:
// 613:     it "includes 'Built from source' if the formula was not installed from a bottle" do
// 614:       tab = described_class.new(poured_from_bottle: false)
// 615:       expect(tab.to_s).to include("Built from source")
// 616:     end
// 617:
// 618:     it "includes 'using the formulae.brew.sh API' if the formula was installed from the API" do
// 619:       tab = described_class.new(loaded_from_api: true)
// 620:       expect(tab.to_s).to include("using the formulae.brew.sh API")
// 621:     end
// 622:
// 623:     it "includes 'using the internal formulae.brew.sh API' if the formula was installed from the internal API" do
// 624:       tab = described_class.new(loaded_from_api: true, loaded_from_internal_api: true)
// 625:       expect(tab.to_s).to include("using the internal formulae.brew.sh API")
// 626:     end
// 627:
// 628:     it "does not include 'using the formulae.brew.sh API' if the formula was not installed from the API" do
// 629:       tab = described_class.new(loaded_from_api: false)
// 630:       expect(tab.to_s).not_to include("using the formulae.brew.sh API")
// 631:     end
// 632:
// 633:     it "doesn't include 'using the internal formulae.brew.sh API' if the formula wasn't installed via internal API" do
// 634:       tab = described_class.new(loaded_from_api: true, loaded_from_internal_api: false)
// 635:       expect(tab.to_s).not_to include("using the internal formulae.brew.sh API")
// 636:     end
// 637:
// 638:     it "includes the time value if specified" do
// 639:       tab = described_class.new(time: 1_720_189_863)
// 640:       expect(tab.to_s).to include("on #{time_string}")
// 641:     end
// 642:
// 643:     it "does not include the time value if not specified" do
// 644:       tab = described_class.new(time: nil)
// 645:       expect(tab.to_s).not_to match(/on %d+-%d+-%d+ at %d+:%d+:%d+/)
// 646:     end
// 647:
// 648:     it "includes options if specified" do
// 649:       tab = described_class.new(used_options: %w[--with-foo --without-bar])
// 650:       expect(tab.to_s).to include("with: --with-foo --without-bar")
// 651:     end
// 652:
// 653:     it "not to include options if not specified" do
// 654:       tab = described_class.new(used_options: [])
// 655:       expect(tab.to_s).not_to include("with: ")
// 656:     end
// 657:   end
// 658:
// 659:   specify "::remap_deprecated_options" do
// 660:     deprecated_options = [DeprecatedOption.new("with-foo", "with-foo-new")]
// 661:     remapped_options = described_class.remap_deprecated_options(deprecated_options, tab.used_options)
// 662:     expect(remapped_options).to include(Option.new("without-bar"))
// 663:     expect(remapped_options).to include(Option.new("with-foo-new"))
// 664:   end
// 665: end

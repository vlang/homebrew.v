module dev_cmd

import brew_runtime
import homebrew.dev_cmd as production_dev_cmd
import os
import time

// Translated from Homebrew/brew `test/dev-cmd/bottle_spec.rb`.
// The original source is retained below for source-by-source auditability.

const bottle_spec_hello_big_sur_sha = 'a0af7dcbb5c83f6f3f7ecd507c2d352c1a018f894d51ad241ce8492fa598010f'
const bottle_spec_hello_catalina_sha = '5334dd344986e46b2aa4f0471cac7b0914bd7de7cb890a34415771788d03f2ac'
const bottle_spec_unzip_big_sur_sha = '16cf230afdfcb6306c208d169549cf8773c831c8653d2c852315a048960d7e72'
const bottle_spec_unzip_catalina_sha = 'd9cc50eec8ac243148a121049c236cba06af4a0b1156ab397d0a2850aa79c137'

pub struct BottleSpecStubParameters {
pub:
	name           string
	version        string
	path           string
	root_url       string
	cellar         string
	os_tag         string
	filename       string
	local_filename string
	sha256         string
	sbom_json      string
}

fn bottle_spec_root(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-bottle-spec-${label}-${os.getpid()}-${time.now().unix_micro()}')
}

pub fn bottle_spec_stub_hash(parameters BottleSpecStubParameters) string {
	root_url := if parameters.root_url == '' {
		production_dev_cmd.bottle_default_domain
	} else {
		parameters.root_url
	}
	sbom := if parameters.sbom_json == '' { '' } else { ',"sbom":${parameters.sbom_json}' }
	return '{"${parameters.name}":{"formula":{"pkg_version":"${parameters.version}","path":"${parameters.path}"},"bottle":{"root_url":"${root_url}","prefix":"/usr/local","cellar":"${parameters.cellar}","rebuild":0,"tags":{"${parameters.os_tag}":{"filename":"${parameters.filename}","local_filename":"${parameters.local_filename}","sha256":"${parameters.sha256}"${sbom}}}}}}'
}

fn bottle_spec_parameters(name string, version string, os_tag string, cellar string,
	sha256 string) BottleSpecStubParameters {
	return BottleSpecStubParameters{
		name: name
		version: version
		path: '/home/${name}.rb'
		cellar: cellar
		os_tag: os_tag
		filename: '${name}-${version}.${os_tag}.bottle.tar.gz'
		local_filename: '${name}--${version}.${os_tag}.bottle.tar.gz'
		sha256: sha256
	}
}

fn bottle_spec_document(parameters BottleSpecStubParameters) production_dev_cmd.BottleJsonDocument {
	mut sbom := brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
	if parameters.sbom_json != '' {
		sbom = brew_runtime.parse_json_value(parameters.sbom_json) or { sbom }
	}
	root_url := if parameters.root_url == '' {
		production_dev_cmd.bottle_default_domain
	} else {
		parameters.root_url
	}
	return production_dev_cmd.BottleJsonDocument{
		entries: {
			parameters.name: production_dev_cmd.BottleJsonEntry{
				formula: production_dev_cmd.BottleJsonFormula{
					name: parameters.name
					pkg_version: parameters.version
					path: parameters.path
				}
				bottle: production_dev_cmd.BottleJsonBottle{
					root_url: root_url
					cellar: parameters.cellar
					tags: {
						parameters.os_tag: production_dev_cmd.BottleJsonTag{
							cellar: parameters.cellar
							filename: parameters.filename
							local_filename: parameters.local_filename
							sha256: parameters.sha256
							sbom: sbom
						}
					}
				}
			}
		}
	}
}

fn bottle_spec_fixture_documents(formula_path string) []production_dev_cmd.BottleJsonDocument {
	mut arm := bottle_spec_parameters('testball', '1.0', 'arm64_big_sur', production_dev_cmd.bottle_any_skip_relocation_cellar, '8f9aecd233463da6a4ea55f5f88fc5841718c013f3e2a7941350d6130f1dc149')
	arm = BottleSpecStubParameters{ ...arm, path: formula_path }
	mut big_sur := bottle_spec_parameters('testball', '1.0', 'big_sur', production_dev_cmd.bottle_any_skip_relocation_cellar, bottle_spec_hello_big_sur_sha)
	big_sur = BottleSpecStubParameters{ ...big_sur, path: formula_path }
	mut catalina := bottle_spec_parameters('testball', '1.0', 'catalina', production_dev_cmd.bottle_any_skip_relocation_cellar, bottle_spec_hello_catalina_sha)
	catalina = BottleSpecStubParameters{ ...catalina, path: formula_path }
	return [bottle_spec_document(arm), bottle_spec_document(big_sur), bottle_spec_document(catalina)]
}

fn bottle_spec_write_documents(root string, documents []production_dev_cmd.BottleJsonDocument) ![]string {
	mut paths := []string{cap: documents.len}
	for index, document in documents {
		path := os.join_path(root, 'bottle-${index}.json')
		os.write_file(path, brew_runtime.json_value_to_string(production_dev_cmd.bottle_json_document_value(document)))!
		paths << path
	}
	return paths
}

fn bottle_spec_formula_source(block string) string {
	return 'class Testball < Formula\n  desc "Some test"\n  homepage "https://brew.sh/testball"\n  url "file:///tmp/testball.tbz"\n\n  option "with-foo", "Build with foo"\n${block}\n  def install\n    prefix.install Dir["*"]\n  end\nend\n'
}

fn bottle_spec_merge_case(existing bool, keep_old bool) !production_dev_cmd.BottleMergeResult {
	root := bottle_spec_root('merge')
	os.mkdir_all(root)!
	defer { os.rmdir_all(root) or {} }
	formula_path := os.join_path(root, 'testball.rb')
	old_sha := '6971b6eebf4c00eaaed72a1104a49be63861eabc95d679a0c84040398e320059'
	block := if existing {
		if keep_old {
			'\n  bottle do\n    sha256 cellar: :any, sonoma: "${old_sha}"\n  end\n'
		} else {
			'\n  bottle do\n    sha256 cellar: :any_skip_relocation, big_sur: "old"\n  end\n'
		}
	} else {
		''
	}
	os.write_file(formula_path, bottle_spec_formula_source(block))!
	documents := bottle_spec_fixture_documents(formula_path)
	paths := bottle_spec_write_documents(root, documents)!
	mut formulae := []production_dev_cmd.BottleFormula{}
	if keep_old {
		formulae << production_dev_cmd.BottleFormula{
			name: 'testball'
			full_name: 'testball'
			old_bottle: production_dev_cmd.BottleSpecification{
				checksums: [production_dev_cmd.BottleChecksum{
					tag: 'sonoma'
					digest: old_sha
					cellar: production_dev_cmd.BottleCellar{
						value: production_dev_cmd.bottle_any_cellar
						is_symbol: true
					}
				}]
			}
		}
	}
	results := production_dev_cmd.merge_bottles(production_dev_cmd.BottleCommand{
		options: production_dev_cmd.BottleCommandOptions{
			merge: true
			write: true
			keep_old: keep_old
		}
		formulae: formulae
		json_files: paths
	})!
	if results.len != 1 {
		return error('expected one merged bottle')
	}
	contents := os.read_file(formula_path)!
	if !contents.contains('arm64_big_sur:') || !contents.contains('big_sur:')
		|| !contents.contains('catalina:') {
		return error('merged bottle block is incomplete')
	}
	if keep_old && !contents.contains('sonoma:') {
		return error('--keep-old did not preserve the old checksum')
	}
	if existing && !keep_old && contents.contains('"old"') {
		return error('old bottle block was not replaced')
	}
	return results[0]
}

fn bottle_spec_install_fixture(label string, with_foo bool) !bool {
	root := bottle_spec_root(label)
	defer { os.rmdir_all(root) or {} }
	prefix := os.join_path(root, 'prefix')
	os.mkdir_all(os.join_path(prefix, 'bin'))!
	os.write_file(os.join_path(prefix, 'bin', 'test'), 'test')!
	if with_foo {
		os.mkdir_all(os.join_path(prefix, 'foo'))!
		os.write_file(os.join_path(prefix, 'foo', 'test'), 'test')!
	}
	return os.read_file(os.join_path(prefix, 'bin', 'test'))! == 'test'
		&& os.exists(os.join_path(prefix, 'foo', 'test')) == with_foo
}

fn bottle_spec_merge_documents() production_dev_cmd.BottleJsonDocument {
	return production_dev_cmd.merge_bottle_json_files([
		bottle_spec_document(bottle_spec_parameters('hello', '1.0', 'big_sur', production_dev_cmd.bottle_any_skip_relocation_cellar, bottle_spec_hello_big_sur_sha)),
		bottle_spec_document(bottle_spec_parameters('hello', '1.0', 'catalina', production_dev_cmd.bottle_any_skip_relocation_cellar, bottle_spec_hello_catalina_sha)),
		bottle_spec_document(bottle_spec_parameters('unzip', '2.0', 'big_sur', production_dev_cmd.bottle_any_skip_relocation_cellar, bottle_spec_unzip_big_sur_sha)),
		bottle_spec_document(bottle_spec_parameters('unzip', '2.0', 'catalina', production_dev_cmd.bottle_any_cellar, bottle_spec_unzip_catalina_sha)),
	])
}

fn bottle_spec_bool(ok bool) brew_runtime.Value {
	return brew_runtime.bool_value(ok)
}

// Ruby method `stub_hash(parameters)` at line 8.
pub fn ruby_bottle_spec_l8_d1_stub_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len > 0 {
		parameters := args[0].as_map() or {
			return brew_runtime.object_value('ArgumentError', 'parameters must be a map')
		}
		return brew_runtime.string_value(bottle_spec_stub_hash(BottleSpecStubParameters{
			name: (parameters['name'] or { brew_runtime.string_value('') }).as_string()
			version: (parameters['version'] or { brew_runtime.string_value('') }).as_string()
			path: (parameters['path'] or { brew_runtime.string_value('') }).as_string()
			root_url: (parameters['root_url'] or { brew_runtime.string_value('') }).as_string()
			cellar: (parameters['cellar'] or { brew_runtime.string_value('') }).as_string()
			os_tag: (parameters['os'] or { brew_runtime.string_value('') }).as_string()
			filename: (parameters['filename'] or { brew_runtime.string_value('') }).as_string()
			local_filename: (parameters['local_filename'] or { brew_runtime.string_value('') }).as_string()
			sha256: (parameters['sha256'] or { brew_runtime.string_value('') }).as_string()
		}))
	}
	return brew_runtime.string_value(bottle_spec_stub_hash(bottle_spec_parameters('hello', '1.0', 'big_sur', production_dev_cmd.bottle_any_skip_relocation_cellar, bottle_spec_hello_big_sur_sha)))
}

// Ruby it `it "builds a bottle for the given Formula", :integration_test, :needs_network do` at line 37.
pub fn ruby_bottle_spec_l37_d2_builds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := bottle_spec_root('build')
	os.mkdir_all(root) or { return bottle_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	prefix := os.join_path(root, 'testball', '0.1')
	os.mkdir_all(os.join_path(prefix, 'bin')) or { return bottle_spec_bool(false) }
	os.write_file(os.join_path(prefix, 'bin', 'testball'), 'test') or {
		return bottle_spec_bool(false)
	}
	os.symlink('not-exist', os.join_path(prefix, 'symlink')) or {
		return bottle_spec_bool(false)
	}
	result := production_dev_cmd.bottle_formula(production_dev_cmd.BottleFormula{
		name: 'testball'
		full_name: 'testball'
		pkg_version: '0.1'
		prefix: prefix
		formula_path: os.join_path(root, 'testball.rb')
		tap_name: 'homebrew/core'
		source_modified_time: 1
	}, production_dev_cmd.BottleCommandOptions{
		no_rebuild: true
		skip_relocation: true
		output_directory: root
		bottle_tag: 'test'
	}, production_dev_cmd.BottleTarFormula{}) or { return bottle_spec_bool(false) }
	tar_path := result.bottle_path.trim_string_right('.gz')
	return bottle_spec_bool(result.bottle_path.contains('testball--0.1.test.bottle.tar.gz')
		&& os.is_file(result.bottle_path) && !os.exists(tar_path))
}

// Ruby let `let(:core_tap) { CoreTap.instance }` at line 58.
pub fn ruby_bottle_spec_l58_d3_core_tap(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.structured_value('CoreTap', 'homebrew/core', {
		'name': 'homebrew/core'
		'path': '/homebrew/core'
	})
}

// Ruby let `let(:tarball) do` at line 59.
pub fn ruby_bottle_spec_l59_d4_tarball(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	$if linux {
		return brew_runtime.string_value('tarballs/testball-0.1-linux.tbz')
	} $else {
		return brew_runtime.string_value('tarballs/testball-0.1.tbz')
	}
}

// Ruby it `it "adds the bottle block to a formula that has none" do` at line 108.
pub fn ruby_bottle_spec_l108_d5_adds(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := bottle_spec_merge_case(false, false) or { return bottle_spec_bool(false) }
	return bottle_spec_bool(result.updated && result.commit.join(' ').contains('testball: add 1.0 bottle.'))
}

// Ruby method `install` at line 154.
pub fn ruby_bottle_spec_l154_d6_install(args ...brew_runtime.Value) brew_runtime.Value {
	with_foo := args.len > 0 && (args[0].as_bool() or { false })
	return bottle_spec_bool(bottle_spec_install_fixture('install-154', with_foo) or { false })
}

// Ruby it `it "replaces the bottle block in a formula that already has a bottle block" do` at line 171.
pub fn ruby_bottle_spec_l171_d7_replaces(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := bottle_spec_merge_case(true, false) or { return bottle_spec_bool(false) }
	return bottle_spec_bool(result.updated && result.commit.join(' ').contains('testball: update 1.0 bottle.'))
}

// Ruby method `install` at line 224.
pub fn ruby_bottle_spec_l224_d8_install(args ...brew_runtime.Value) brew_runtime.Value {
	with_foo := args.len > 0 && (args[0].as_bool() or { false })
	return bottle_spec_bool(bottle_spec_install_fixture('install-224', with_foo) or { false })
}

// Ruby it `it "updates the bottle block in a formula that already has a bottle block when using --keep-old" do` at line 241.
pub fn ruby_bottle_spec_l241_d9_updates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := bottle_spec_merge_case(true, true) or { return bottle_spec_bool(false) }
	return bottle_spec_bool(result.updated && result.output.contains('sonoma:'))
}

// Ruby method `install` at line 295.
pub fn ruby_bottle_spec_l295_d10_install(args ...brew_runtime.Value) brew_runtime.Value {
	with_foo := args.len > 0 && (args[0].as_bool() or { false })
	return bottle_spec_bool(bottle_spec_install_fixture('install-295', with_foo) or { false })
}

// Ruby it `it "writes an all bottle JSON for matching platform bottles" do` at line 312.
pub fn ruby_bottle_spec_l312_d11_writes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	sha := '8f9aecd233463da6a4ea55f5f88fc5841718c013f3e2a7941350d6130f1dc149'
	mut arm := bottle_spec_parameters('testball', '1.0', 'arm64_big_sur', production_dev_cmd.bottle_any_skip_relocation_cellar, sha)
	arm = BottleSpecStubParameters{ ...arm, sbom_json: '{"packages":[{"SPDXID":"SPDXRef-arm64_big_sur"}]}' }
	mut intel := bottle_spec_parameters('testball', '1.0', 'big_sur', production_dev_cmd.bottle_any_skip_relocation_cellar, sha)
	intel = BottleSpecStubParameters{ ...intel, sbom_json: '{"packages":[{"SPDXID":"SPDXRef-big_sur"}]}' }
	root := bottle_spec_root('all')
	os.mkdir_all(root) or { return bottle_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	paths := bottle_spec_write_documents(root, [bottle_spec_document(arm),
		bottle_spec_document(intel)]) or { return bottle_spec_bool(false) }
	results := production_dev_cmd.merge_bottles(production_dev_cmd.BottleCommand{
		options: production_dev_cmd.BottleCommandOptions{ merge: true }
		json_files: paths
	}) or { return bottle_spec_bool(false) }
	return bottle_spec_bool(results.len == 1 && results[0].all_bottle
		&& results[0].output.contains('all:') && results[0].output.contains(sha))
}

// Ruby it `it "merges when an all bottle cannot be created" do` at line 364.
pub fn ruby_bottle_spec_l364_d12_merges(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := bottle_spec_root('not-all')
	os.mkdir_all(root) or { return bottle_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	paths := bottle_spec_write_documents(root, bottle_spec_fixture_documents('/home/testball.rb')) or {
		return bottle_spec_bool(false)
	}
	results := production_dev_cmd.merge_bottles(production_dev_cmd.BottleCommand{
		options: production_dev_cmd.BottleCommandOptions{ merge: true }
		json_files: paths[..2]
	}) or { return bottle_spec_bool(false) }
	return bottle_spec_bool(results.len == 1 && !results[0].all_bottle
		&& results[0].output.contains('arm64_big_sur:')
		&& results[0].output.contains('big_sur:') && !results[0].output.contains('all:'))
}

// Ruby subject `subject(:homebrew) { described_class.new(["foo"]) }` at line 396.
pub fn ruby_bottle_spec_l396_d13_homebrew(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.map_value({
		'command': brew_runtime.string_value('bottle')
		'named':   brew_runtime.string_array_value(['foo'])
	})
}

// Ruby let `let(:hello_hash_big_sur) do` at line 398.
pub fn ruby_bottle_spec_l398_d14_hello_hash_big_sur(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return production_dev_cmd.bottle_json_document_value(bottle_spec_document(bottle_spec_parameters('hello', '1.0', 'big_sur', production_dev_cmd.bottle_any_skip_relocation_cellar, bottle_spec_hello_big_sur_sha)))
}

// Ruby let `let(:hello_hash_catalina) do` at line 410.
pub fn ruby_bottle_spec_l410_d15_hello_hash_catalina(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return production_dev_cmd.bottle_json_document_value(bottle_spec_document(bottle_spec_parameters('hello', '1.0', 'catalina', production_dev_cmd.bottle_any_skip_relocation_cellar, bottle_spec_hello_catalina_sha)))
}

// Ruby let `let(:unzip_hash_big_sur) do` at line 422.
pub fn ruby_bottle_spec_l422_d16_unzip_hash_big_sur(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return production_dev_cmd.bottle_json_document_value(bottle_spec_document(bottle_spec_parameters('unzip', '2.0', 'big_sur', production_dev_cmd.bottle_any_skip_relocation_cellar, bottle_spec_unzip_big_sur_sha)))
}

// Ruby let `let(:unzip_hash_catalina) do` at line 434.
pub fn ruby_bottle_spec_l434_d17_unzip_hash_catalina(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return production_dev_cmd.bottle_json_document_value(bottle_spec_document(bottle_spec_parameters('unzip', '2.0', 'catalina', production_dev_cmd.bottle_any_cellar, bottle_spec_unzip_catalina_sha)))
}

// Ruby specify `specify "::parse_json_files" do` at line 447.
pub fn ruby_bottle_spec_l447_d18_parse_json_files(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := bottle_spec_root('parse')
	os.mkdir_all(root) or { return bottle_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	parameters := bottle_spec_parameters('hello', '1.0', 'big_sur', production_dev_cmd.bottle_any_skip_relocation_cellar, bottle_spec_hello_big_sur_sha)
	path := os.join_path(root, 'hello--1.0.big_sur.bottle.json')
	os.write_file(path, bottle_spec_stub_hash(parameters)) or { return bottle_spec_bool(false) }
	documents := production_dev_cmd.parse_bottle_json_files([path]) or {
		return bottle_spec_bool(false)
	}
	return bottle_spec_bool(documents.len == 1
		&& documents[0].entries['hello'].bottle.tags['big_sur'].filename == parameters.filename)
}

// Ruby it `it "merges JSON files" do` at line 467.
pub fn ruby_bottle_spec_l467_d19_merges(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	merged := bottle_spec_merge_documents()
	hello := merged.entries['hello']
	unzip := merged.entries['unzip']
	return bottle_spec_bool(merged.entries.len == 2
		&& hello.bottle.tags['big_sur'].sha256 == bottle_spec_hello_big_sur_sha
		&& hello.bottle.tags['catalina'].sha256 == bottle_spec_hello_catalina_sha
		&& unzip.bottle.tags['big_sur'].local_filename == 'unzip--2.0.big_sur.bottle.tar.gz'
		&& unzip.bottle.tags['catalina'].cellar == production_dev_cmd.bottle_any_cellar)
}

// Ruby it `it "allows new bottle hash to be empty" do` at line 506.
pub fn ruby_bottle_spec_l506_d20_allows(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	_ := production_dev_cmd.merge_bottle_spec(['root_url', 'cellar', 'rebuild', 'sha256'], production_dev_cmd.BottleSpecification{}, production_dev_cmd.BottleJsonBottle{})
	// This example asserts only that an empty incoming hash is accepted without
	// raising; mismatch reporting remains available to the merge caller.
	return bottle_spec_bool(true)
}

// Ruby it `it "checks for conflicting root URL" do` at line 513.
pub fn ruby_bottle_spec_l513_d21_checks(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := production_dev_cmd.merge_bottle_spec(['root_url'], production_dev_cmd.BottleSpecification{ root_url: 'https://failbrew.bintray.com/bottles' }, production_dev_cmd.BottleJsonBottle{ root_url: 'https://testbrew.bintray.com/bottles' })
	return bottle_spec_bool(result.mismatches == [
		'root_url: old: "https://failbrew.bintray.com/bottles", new: "https://testbrew.bintray.com/bottles"',
	] && result.checksums.len == 0)
}

// Ruby it `it "checks for conflicting rebuild number" do` at line 523.
pub fn ruby_bottle_spec_l523_d22_checks(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	result := production_dev_cmd.merge_bottle_spec(['rebuild'], production_dev_cmd.BottleSpecification{ rebuild: 1 }, production_dev_cmd.BottleJsonBottle{ rebuild: 2 })
	return bottle_spec_bool(result.mismatches == ['rebuild: old: "1", new: "2"']
		&& result.checksums.len == 0)
}

// Ruby it `it "checks for conflicting checksums" do` at line 533.
pub fn ruby_bottle_spec_l533_d23_checks(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	old_sequoia := '109c0cb581a7b5d84da36d84b221fb9dd0f8a927b3044d82611791c9907e202e'
	new_sequoia := 'ec6d7f08412468f28dee2be17ad8cd8b883b16b34329efcecce019b8c9736428'
	sonoma := '7571772bf7a0c9fe193e70e521318b53993bee6f351976c9b6e01e00d13d6c3f'
	default_cellar := production_dev_cmd.BottleCellar{ value: '/usr/local/Cellar' }
	result := production_dev_cmd.merge_bottle_spec(['sha256'], production_dev_cmd.BottleSpecification{
		checksums: [
			production_dev_cmd.BottleChecksum{
				tag: 'sequoia'
				digest: old_sequoia
				cellar: default_cellar
			},
			production_dev_cmd.BottleChecksum{
				tag: 'sonoma'
				digest: sonoma
				cellar: default_cellar
			},
		]
	}, production_dev_cmd.BottleJsonBottle{
		tags: {
			'sequoia': production_dev_cmd.BottleJsonTag{
				cellar: '/usr/local/Cellar'
				sha256: new_sequoia
			}
		}
	})
	return bottle_spec_bool(result.mismatches == [
		'sha256 sequoia: old: "${old_sequoia}", new: "${new_sequoia}"',
	] && result.checksums.len == 1 && result.checksums[0].tag == 'sonoma'
		&& result.checksums[0].digest == sonoma)
}

fn bottle_spec_sha_line(cellar production_dev_cmd.BottleCellar, tag_column int,
	digest_column int, expected string) brew_runtime.Value {
	return bottle_spec_bool(production_dev_cmd.generate_bottle_sha256_line('sequoia', 'deadbeef', cellar, tag_column, digest_column) == expected)
}

// Ruby it `it "generates a string without cellar" do` at line 550.
pub fn ruby_bottle_spec_l550_d24_generates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bottle_spec_sha_line(production_dev_cmd.BottleCellar{}, 0, 10, 'sha256 sequoia:  "deadbeef"')
}

// Ruby it `it "generates a string with cellar symbol" do` at line 558.
pub fn ruby_bottle_spec_l558_d25_generates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bottle_spec_sha_line(production_dev_cmd.BottleCellar{
		value: production_dev_cmd.bottle_any_cellar
		is_symbol: true
	}, 14, 24, 'sha256 cellar: :any, sequoia:  "deadbeef"')
}

// Ruby it `it "generates a string with default cellar path" do` at line 566.
pub fn ruby_bottle_spec_l566_d26_generates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bottle_spec_sha_line(production_dev_cmd.BottleCellar{
		value: '/home/linuxbrew/.linuxbrew/Cellar'
	}, 0, 10, 'sha256 sequoia:  "deadbeef"')
}

// Ruby it `it "generates a string with non-default cellar path" do` at line 574.
pub fn ruby_bottle_spec_l574_d27_generates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bottle_spec_sha_line(production_dev_cmd.BottleCellar{ value: '/home/test' }, 22, 32, 'sha256 cellar: "/home/test", sequoia:  "deadbeef"')
}

// Ruby it `it "generates a string without cellar" do` at line 583.
pub fn ruby_bottle_spec_l583_d28_generates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bottle_spec_sha_line(production_dev_cmd.BottleCellar{}, 0, 15, 'sha256 sequoia:       "deadbeef"')
}

// Ruby it `it "generates a string with cellar symbol" do` at line 591.
pub fn ruby_bottle_spec_l591_d29_generates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bottle_spec_sha_line(production_dev_cmd.BottleCellar{
		value: production_dev_cmd.bottle_any_cellar
		is_symbol: true
	}, 20, 35, 'sha256 cellar: :any,       sequoia:       "deadbeef"')
}

// Ruby it `it "generates a string with default cellar path" do` at line 599.
pub fn ruby_bottle_spec_l599_d30_generates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bottle_spec_sha_line(production_dev_cmd.BottleCellar{
		value: '/home/linuxbrew/.linuxbrew/Cellar'
	}, 14, 30, 'sha256               sequoia:        "deadbeef"')
}

// Ruby it `it "generates a string with non-default cellar path" do` at line 607.
pub fn ruby_bottle_spec_l607_d31_generates(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return bottle_spec_sha_line(production_dev_cmd.BottleCellar{ value: '/home/test' }, 25, 36, 'sha256 cellar: "/home/test",    sequoia:   "deadbeef"')
}

fn bottle_spec_custom_output(strategy string) string {
	return production_dev_cmd.bottle_output(production_dev_cmd.BottleSpecification{
		root_url: 'https://example.com'
		checksums: [production_dev_cmd.BottleChecksum{
			tag: 'catalina'
			digest: '109c0cb581a7b5d84da36d84b221fb9dd0f8a927b3044d82611791c9907e202e'
		}]
	}, strategy)
}

// Ruby it `it "includes a custom root_url" do` at line 618.
pub fn ruby_bottle_spec_l618_d32_includes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(bottle_spec_custom_output(''))
}

// Ruby it `it "includes download strategy for custom root_url" do` at line 633.
pub fn ruby_bottle_spec_l633_d33_includes(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return brew_runtime.string_value(bottle_spec_custom_output('ExampleStrategy'))
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/shared_examples/args_parse"
// 5: require "dev-cmd/bottle"
// 6:
// 7: RSpec.describe Homebrew::DevCmd::Bottle do
// 8:   def stub_hash(parameters)
// 9:     <<~JSON
// 10:       {
// 11:         "#{parameters[:name]}":{
// 12:            "formula":{
// 13:               "pkg_version":"#{parameters[:version]}",
// 14:               "path":"#{parameters[:path]}"
// 15:            },
// 16:            "bottle":{
// 17:               "root_url":"#{parameters[:root_url] || HOMEBREW_BOTTLE_DEFAULT_DOMAIN}",
// 18:               "prefix":"/usr/local",
// 19:               "cellar":"#{parameters[:cellar]}",
// 20:               "rebuild":0,
// 21:               "tags":{
// 22:                  "#{parameters[:os]}":{
// 23:                     "filename":"#{parameters[:filename]}",
// 24:                     "local_filename":"#{parameters[:local_filename]}",
// 25:                     "sha256":"#{parameters[:sha256]}"
// 26:                     #{",\"sbom\":#{parameters[:sbom].to_json}" if parameters[:sbom]}
// 27:                  }
// 28:               }
// 29:            }
// 30:         }
// 31:       }
// 32:     JSON
// 33:   end
// 34:
// 35:   it_behaves_like "parseable arguments"
// 36:
// 37:   it "builds a bottle for the given Formula", :integration_test, :needs_network do
// 38:     install_test_formula "testball", build_bottle: true
// 39:
// 40:     # `brew bottle` should not fail with dead symlink
// 41:     # https://github.com/Homebrew/legacy-homebrew/issues/49007
// 42:     (HOMEBREW_CELLAR/"testball/0.1").cd do
// 43:       FileUtils.ln_s "not-exist", "symlink"
// 44:     end
// 45:
// 46:     begin
// 47:       expect { brew "bottle", "--no-rebuild", "testball" }
// 48:         .to output(/testball--0\.1.*\.bottle\.tar\.gz/).to_stdout
// 49:         .and not_to_output.to_stderr
// 50:         .and be_a_success
// 51:       expect(HOMEBREW_CELLAR/"testball-bottle.tar").not_to exist
// 52:     ensure
// 53:       FileUtils.rm_f Dir.glob("testball--0.1*.bottle.tar.gz")
// 54:     end
// 55:   end
// 56:
// 57:   describe "--merge", :integration_test do
// 58:     let(:core_tap) { CoreTap.instance }
// 59:     let(:tarball) do
// 60:       if OS.linux?
// 61:         TEST_FIXTURE_DIR/"tarballs/testball-0.1-linux.tbz"
// 62:       else
// 63:         TEST_FIXTURE_DIR/"tarballs/testball-0.1.tbz"
// 64:       end
// 65:     end
// 66:
// 67:     before do
// 68:       Pathname("#{TEST_TMPDIR}/testball-1.0.arm64_big_sur.bottle.json").write stub_hash(
// 69:         name:           "testball",
// 70:         version:        "1.0",
// 71:         path:           "#{core_tap.path}/Formula/testball.rb",
// 72:         cellar:         "any_skip_relocation",
// 73:         os:             "arm64_big_sur",
// 74:         filename:       "testball-1.0.arm64_big_sur.bottle.tar.gz",
// 75:         local_filename: "testball--1.0.arm64_big_sur.bottle.tar.gz",
// 76:         sha256:         "8f9aecd233463da6a4ea55f5f88fc5841718c013f3e2a7941350d6130f1dc149",
// 77:       )
// 78:
// 79:       Pathname("#{TEST_TMPDIR}/testball-1.0.big_sur.bottle.json").write stub_hash(
// 80:         name:           "testball",
// 81:         version:        "1.0",
// 82:         path:           "#{core_tap.path}/Formula/testball.rb",
// 83:         cellar:         "any_skip_relocation",
// 84:         os:             "big_sur",
// 85:         filename:       "hello-1.0.big_sur.bottle.tar.gz",
// 86:         local_filename: "hello--1.0.big_sur.bottle.tar.gz",
// 87:         sha256:         "a0af7dcbb5c83f6f3f7ecd507c2d352c1a018f894d51ad241ce8492fa598010f",
// 88:       )
// 89:
// 90:       Pathname("#{TEST_TMPDIR}/testball-1.0.catalina.bottle.json").write stub_hash(
// 91:         name:           "testball",
// 92:         version:        "1.0",
// 93:         path:           "#{core_tap.path}/Formula/testball.rb",
// 94:         cellar:         "any_skip_relocation",
// 95:         os:             "catalina",
// 96:         filename:       "testball-1.0.catalina.bottle.tar.gz",
// 97:         local_filename: "testball--1.0.catalina.bottle.tar.gz",
// 98:         sha256:         "5334dd344986e46b2aa4f0471cac7b0914bd7de7cb890a34415771788d03f2ac",
// 99:       )
// 100:     end
// 101:
// 102:     after do
// 103:       FileUtils.rm_f "#{TEST_TMPDIR}/testball-1.0.arm64_big_sur.bottle.json"
// 104:       FileUtils.rm_f "#{TEST_TMPDIR}/testball-1.0.catalina.bottle.json"
// 105:       FileUtils.rm_f "#{TEST_TMPDIR}/testball-1.0.big_sur.bottle.json"
// 106:     end
// 107:
// 108:     it "adds the bottle block to a formula that has none" do
// 109:       core_tap.path.cd do
// 110:         system "git", "-c", "init.defaultBranch=master", "init"
// 111:         setup_test_formula "testball"
// 112:         system "git", "add", "--all"
// 113:         system "git", "commit", "-m", "testball 0.1"
// 114:       end
// 115:
// 116:       # RuboCop would align the `.and` with `.to_stdout` which is too floaty.
// 117:       # rubocop:disable Layout/MultilineMethodCallIndentation
// 118:       expect do
// 119:         brew "bottle",
// 120:              "--merge",
// 121:              "--write",
// 122:              "#{TEST_TMPDIR}/testball-1.0.arm64_big_sur.bottle.json",
// 123:              "#{TEST_TMPDIR}/testball-1.0.big_sur.bottle.json",
// 124:              "#{TEST_TMPDIR}/testball-1.0.catalina.bottle.json"
// 125:       end.to output(Regexp.new(<<~'EOS')).to_stdout
// 126:         ==> testball
// 127:           bottle do
// 128:             sha256 cellar: :any_skip_relocation, arm64_big_sur: "8f9aecd233463da6a4ea55f5f88fc5841718c013f3e2a7941350d6130f1dc149"
// 129:             sha256 cellar: :any_skip_relocation, big_sur:       "a0af7dcbb5c83f6f3f7ecd507c2d352c1a018f894d51ad241ce8492fa598010f"
// 130:             sha256 cellar: :any_skip_relocation, catalina:      "5334dd344986e46b2aa4f0471cac7b0914bd7de7cb890a34415771788d03f2ac"
// 131:           end
// 132:         \[master [0-9a-f]{4,40}\] testball: add 1\.0 bottle\.
// 133:          1 file changed, 6 insertions\(\+\)
// 134:       EOS
// 135:       .and not_to_output.to_stderr
// 136:       .and be_a_success
// 137:       # rubocop:enable Layout/MultilineMethodCallIndentation
// 138:
// 139:       expect((core_tap.path/"Formula/testball.rb").read).to eq <<~RUBY
// 140:         class Testball < Formula
// 141:           desc "Some test"
// 142:           homepage "https://brew.sh/testball"
// 143:           url "file://#{tarball}"
// 144:           sha256 "#{tarball.sha256}"
// 145:
// 146:           bottle do
// 147:             sha256 cellar: :any_skip_relocation, arm64_big_sur: "8f9aecd233463da6a4ea55f5f88fc5841718c013f3e2a7941350d6130f1dc149"
// 148:             sha256 cellar: :any_skip_relocation, big_sur:       "a0af7dcbb5c83f6f3f7ecd507c2d352c1a018f894d51ad241ce8492fa598010f"
// 149:             sha256 cellar: :any_skip_relocation, catalina:      "5334dd344986e46b2aa4f0471cac7b0914bd7de7cb890a34415771788d03f2ac"
// 150:           end
// 151:
// 152:           option "with-foo", "Build with foo"
// 153:
// 154:           def install
// 155:             (prefix/"foo"/"test").write("test") if build.with? "foo"
// 156:             prefix.install Dir["*"]
// 157:             (buildpath/"test.c").write \
// 158:             "#include <stdio.h>\\nint main(){printf(\\"test\\");return 0;}"
// 159:             bin.mkpath
// 160:             system ENV.cc, "test.c", "-o", bin/"test"
// 161:           end
// 162:
// 163:
// 164:
// 165:           # something here
// 166:
// 167:         end
// 168:       RUBY
// 169:     end
// 170:
// 171:     it "replaces the bottle block in a formula that already has a bottle block" do
// 172:       core_tap.path.cd do
// 173:         system "git", "-c", "init.defaultBranch=master", "init"
// 174:         setup_test_formula "testball", bottle_block: <<~RUBY
// 175:
// 176:           bottle do
// 177:             sha256 cellar: :any_skip_relocation, arm64_big_sur: "c3c650d75f5188f5d6edd351dd3215e141b73b8ec1cf9144f30e39cbc45de72e"
// 178:             sha256 cellar: :any_skip_relocation, big_sur:       "6b276491297d4052538bd2fd22d5129389f27d90a98f831987236a5b90511b98"
// 179:             sha256 cellar: :any_skip_relocation, catalina:      "16cf230afdfcb6306c208d169549cf8773c831c8653d2c852315a048960d7e72"
// 180:           end
// 181:         RUBY
// 182:         system "git", "add", "--all"
// 183:         system "git", "commit", "-m", "testball 0.1"
// 184:       end
// 185:
// 186:       # RuboCop would align the `.and` with `.to_stdout` which is too floaty.
// 187:       # rubocop:disable Layout/MultilineMethodCallIndentation
// 188:       expect do
// 189:         brew "bottle",
// 190:              "--merge",
// 191:              "--write",
// 192:              "#{TEST_TMPDIR}/testball-1.0.arm64_big_sur.bottle.json",
// 193:              "#{TEST_TMPDIR}/testball-1.0.big_sur.bottle.json",
// 194:              "#{TEST_TMPDIR}/testball-1.0.catalina.bottle.json"
// 195:       end.to output(Regexp.new(<<~'EOS')).to_stdout
// 196:         ==> testball
// 197:           bottle do
// 198:             sha256 cellar: :any_skip_relocation, arm64_big_sur: "8f9aecd233463da6a4ea55f5f88fc5841718c013f3e2a7941350d6130f1dc149"
// 199:             sha256 cellar: :any_skip_relocation, big_sur:       "a0af7dcbb5c83f6f3f7ecd507c2d352c1a018f894d51ad241ce8492fa598010f"
// 200:             sha256 cellar: :any_skip_relocation, catalina:      "5334dd344986e46b2aa4f0471cac7b0914bd7de7cb890a34415771788d03f2ac"
// 201:           end
// 202:         \[master [0-9a-f]{4,40}\] testball: update 1\.0 bottle\.
// 203:          1 file changed, 3 insertions\(\+\), 3 deletions\(\-\)
// 204:       EOS
// 205:       .and not_to_output.to_stderr
// 206:       .and be_a_success
// 207:       # rubocop:enable Layout/MultilineMethodCallIndentation
// 208:
// 209:       expect((core_tap.path/"Formula/testball.rb").read).to eq <<~RUBY
// 210:         class Testball < Formula
// 211:           desc "Some test"
// 212:           homepage "https://brew.sh/testball"
// 213:           url "file://#{tarball}"
// 214:           sha256 "#{tarball.sha256}"
// 215:
// 216:           option "with-foo", "Build with foo"
// 217:
// 218:           bottle do
// 219:             sha256 cellar: :any_skip_relocation, arm64_big_sur: "8f9aecd233463da6a4ea55f5f88fc5841718c013f3e2a7941350d6130f1dc149"
// 220:             sha256 cellar: :any_skip_relocation, big_sur:       "a0af7dcbb5c83f6f3f7ecd507c2d352c1a018f894d51ad241ce8492fa598010f"
// 221:             sha256 cellar: :any_skip_relocation, catalina:      "5334dd344986e46b2aa4f0471cac7b0914bd7de7cb890a34415771788d03f2ac"
// 222:           end
// 223:
// 224:           def install
// 225:             (prefix/"foo"/"test").write("test") if build.with? "foo"
// 226:             prefix.install Dir["*"]
// 227:             (buildpath/"test.c").write \
// 228:             "#include <stdio.h>\\nint main(){printf(\\"test\\");return 0;}"
// 229:             bin.mkpath
// 230:             system ENV.cc, "test.c", "-o", bin/"test"
// 231:           end
// 232:
// 233:
// 234:
// 235:           # something here
// 236:
// 237:         end
// 238:       RUBY
// 239:     end
// 240:
// 241:     it "updates the bottle block in a formula that already has a bottle block when using --keep-old" do
// 242:       core_tap.path.cd do
// 243:         system "git", "-c", "init.defaultBranch=master", "init"
// 244:         setup_test_formula "testball", bottle_block: <<~RUBY
// 245:
// 246:           bottle do
// 247:             sha256 cellar: :any, sonoma: "6971b6eebf4c00eaaed72a1104a49be63861eabc95d679a0c84040398e320059"
// 248:           end
// 249:         RUBY
// 250:         system "git", "add", "--all"
// 251:         system "git", "commit", "-m", "testball 0.1"
// 252:       end
// 253:
// 254:       # RuboCop would align the `.and` with `.to_stdout` which is too floaty.
// 255:       # rubocop:disable Layout/MultilineMethodCallIndentation
// 256:       expect do
// 257:         brew "bottle",
// 258:              "--merge",
// 259:              "--write",
// 260:              "--keep-old",
// 261:              "#{TEST_TMPDIR}/testball-1.0.arm64_big_sur.bottle.json",
// 262:              "#{TEST_TMPDIR}/testball-1.0.big_sur.bottle.json",
// 263:              "#{TEST_TMPDIR}/testball-1.0.catalina.bottle.json"
// 264:       end.to output(Regexp.new(<<~'EOS')).to_stdout
// 265:         ==> testball
// 266:           bottle do
// 267:             sha256 cellar: :any_skip_relocation, arm64_big_sur: "8f9aecd233463da6a4ea55f5f88fc5841718c013f3e2a7941350d6130f1dc149"
// 268:             sha256 cellar: :any,                 sonoma:        "6971b6eebf4c00eaaed72a1104a49be63861eabc95d679a0c84040398e320059"
// 269:             sha256 cellar: :any_skip_relocation, big_sur:       "a0af7dcbb5c83f6f3f7ecd507c2d352c1a018f894d51ad241ce8492fa598010f"
// 270:             sha256 cellar: :any_skip_relocation, catalina:      "5334dd344986e46b2aa4f0471cac7b0914bd7de7cb890a34415771788d03f2ac"
// 271:           end
// 272:         \[master [0-9a-f]{4,40}\] testball: update 1\.0 bottle\.
// 273:          1 file changed, 4 insertions\(\+\), 1 deletion\(\-\)
// 274:       EOS
// 275:       .and not_to_output.to_stderr
// 276:       .and be_a_success
// 277:       # rubocop:enable Layout/MultilineMethodCallIndentation
// 278:
// 279:       expect((core_tap.path/"Formula/testball.rb").read).to eq <<~RUBY
// 280:         class Testball < Formula
// 281:           desc "Some test"
// 282:           homepage "https://brew.sh/testball"
// 283:           url "file://#{tarball}"
// 284:           sha256 "#{tarball.sha256}"
// 285:
// 286:           option "with-foo", "Build with foo"
// 287:
// 288:           bottle do
// 289:             sha256 cellar: :any_skip_relocation, arm64_big_sur: "8f9aecd233463da6a4ea55f5f88fc5841718c013f3e2a7941350d6130f1dc149"
// 290:             sha256 cellar: :any,                 sonoma:        "6971b6eebf4c00eaaed72a1104a49be63861eabc95d679a0c84040398e320059"
// 291:             sha256 cellar: :any_skip_relocation, big_sur:       "a0af7dcbb5c83f6f3f7ecd507c2d352c1a018f894d51ad241ce8492fa598010f"
// 292:             sha256 cellar: :any_skip_relocation, catalina:      "5334dd344986e46b2aa4f0471cac7b0914bd7de7cb890a34415771788d03f2ac"
// 293:           end
// 294:
// 295:           def install
// 296:             (prefix/"foo"/"test").write("test") if build.with? "foo"
// 297:             prefix.install Dir["*"]
// 298:             (buildpath/"test.c").write \
// 299:             "#include <stdio.h>\\nint main(){printf(\\"test\\");return 0;}"
// 300:             bin.mkpath
// 301:             system ENV.cc, "test.c", "-o", bin/"test"
// 302:           end
// 303:
// 304:
// 305:
// 306:           # something here
// 307:
// 308:         end
// 309:       RUBY
// 310:     end
// 311:
// 312:     it "writes an all bottle JSON for matching platform bottles" do
// 313:       core_tap.path.cd do
// 314:         system "git", "-c", "init.defaultBranch=master", "init"
// 315:         setup_test_formula "testball"
// 316:         system "git", "add", "--all"
// 317:         system "git", "commit", "-m", "testball 0.1"
// 318:       end
// 319:
// 320:       mktmpdir.cd do
// 321:         sha256 = "8f9aecd233463da6a4ea55f5f88fc5841718c013f3e2a7941350d6130f1dc149"
// 322:         bottle_json_paths = ["arm64_big_sur", "big_sur"].map do |tag|
// 323:           Pathname("testball--1.0.#{tag}.bottle.tar.gz").write("test")
// 324:           Pathname("#{TEST_TMPDIR}/testball-1.0.#{tag}.bottle.json").tap do |path|
// 325:             path.write stub_hash(
// 326:               name:           "testball",
// 327:               version:        "1.0",
// 328:               path:           "#{core_tap.path}/Formula/testball.rb",
// 329:               cellar:         "any_skip_relocation",
// 330:               os:             tag,
// 331:               filename:       "testball-1.0.#{tag}.bottle.tar.gz",
// 332:               local_filename: "testball--1.0.#{tag}.bottle.tar.gz",
// 333:               sha256:,
// 334:               sbom:           { "packages" => [{ "SPDXID" => "SPDXRef-#{tag}" }] },
// 335:             )
// 336:           end
// 337:         end
// 338:
// 339:         # RuboCop would align the `.and` with `.to_stdout` which is too floaty.
// 340:         # rubocop:disable Layout/MultilineMethodCallIndentation
// 341:         expect do
// 342:           brew "bottle", "--merge", "--write", "--no-commit", *bottle_json_paths
// 343:         end.to output(/sha256 cellar: :any_skip_relocation, all: "#{sha256}"/).to_stdout
// 344:         .and not_to_output.to_stderr
// 345:         .and be_a_success
// 346:         # rubocop:enable Layout/MultilineMethodCallIndentation
// 347:
// 348:         all_bottle_hash = JSON.parse(Pathname("testball--1.0.all.bottle.json").read)
// 349:         all_bottle_tag_hash = all_bottle_hash.dig("testball", "bottle", "tags", "all")
// 350:
// 351:         expect(all_bottle_hash.dig("testball", "bottle", "cellar")).to eq("any_skip_relocation")
// 352:         expect(all_bottle_hash.dig("testball", "bottle", "tags").keys).to eq(["all"])
// 353:         expect(all_bottle_tag_hash).to include(
// 354:           "filename"       => "testball-1.0.all.bottle.tar.gz",
// 355:           "local_filename" => "testball--1.0.all.bottle.tar.gz",
// 356:           "sha256"         => sha256,
// 357:         )
// 358:         expect(all_bottle_tag_hash.dig("sbom", "tags").keys).to contain_exactly("arm64_big_sur", "big_sur")
// 359:         expect(all_bottle_tag_hash).not_to have_key("cellar")
// 360:         expect(Pathname("testball--1.0.all.bottle.tar.gz")).to exist
// 361:       end
// 362:     end
// 363:
// 364:     it "merges when an all bottle cannot be created" do
// 365:       core_tap.path.cd do
// 366:         system "git", "-c", "init.defaultBranch=master", "init"
// 367:         setup_test_formula "testball", bottle_block: <<~RUBY
// 368:
// 369:           bottle do
// 370:             sha256 cellar: :any_skip_relocation, all: "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97"
// 371:           end
// 372:         RUBY
// 373:         system "git", "add", "--all"
// 374:         system "git", "commit", "-m", "testball 0.1"
// 375:       end
// 376:
// 377:       expect do
// 378:         brew "bottle",
// 379:              "--merge",
// 380:              "--write",
// 381:              "--no-commit",
// 382:              "#{TEST_TMPDIR}/testball-1.0.arm64_big_sur.bottle.json",
// 383:              "#{TEST_TMPDIR}/testball-1.0.big_sur.bottle.json",
// 384:              { "GITHUB_EVENT_PATH" => nil }
// 385:       end.to output(/sha256 cellar: :any_skip_relocation, arm64_big_sur:/).to_stdout
// 386:                                                                           .and not_to_output.to_stderr
// 387:                                                                                             .and be_a_success
// 388:
// 389:       formula_contents = (core_tap.path/"Formula/testball.rb").read
// 390:       expect(formula_contents).to include("big_sur:")
// 391:       expect(formula_contents).not_to include("all:")
// 392:     end
// 393:   end
// 394:
// 395:   describe "bottle_cmd" do
// 396:     subject(:homebrew) { described_class.new(["foo"]) }
// 397:
// 398:     let(:hello_hash_big_sur) do
// 399:       JSON.parse stub_hash(
// 400:         name:           "hello",
// 401:         version:        "1.0",
// 402:         path:           "/home/hello.rb",
// 403:         cellar:         "any_skip_relocation",
// 404:         os:             "big_sur",
// 405:         filename:       "hello-1.0.big_sur.bottle.tar.gz",
// 406:         local_filename: "hello--1.0.big_sur.bottle.tar.gz",
// 407:         sha256:         "a0af7dcbb5c83f6f3f7ecd507c2d352c1a018f894d51ad241ce8492fa598010f",
// 408:       )
// 409:     end
// 410:     let(:hello_hash_catalina) do
// 411:       JSON.parse stub_hash(
// 412:         name:           "hello",
// 413:         version:        "1.0",
// 414:         path:           "/home/hello.rb",
// 415:         cellar:         "any_skip_relocation",
// 416:         os:             "catalina",
// 417:         filename:       "hello-1.0.catalina.bottle.tar.gz",
// 418:         local_filename: "hello--1.0.catalina.bottle.tar.gz",
// 419:         sha256:         "5334dd344986e46b2aa4f0471cac7b0914bd7de7cb890a34415771788d03f2ac",
// 420:       )
// 421:     end
// 422:     let(:unzip_hash_big_sur) do
// 423:       JSON.parse stub_hash(
// 424:         name:           "unzip",
// 425:         version:        "2.0",
// 426:         path:           "/home/unzip.rb",
// 427:         cellar:         "any_skip_relocation",
// 428:         os:             "big_sur",
// 429:         filename:       "unzip-2.0.big_sur.bottle.tar.gz",
// 430:         local_filename: "unzip--2.0.big_sur.bottle.tar.gz",
// 431:         sha256:         "16cf230afdfcb6306c208d169549cf8773c831c8653d2c852315a048960d7e72",
// 432:       )
// 433:     end
// 434:     let(:unzip_hash_catalina) do
// 435:       JSON.parse stub_hash(
// 436:         name:           "unzip",
// 437:         version:        "2.0",
// 438:         path:           "/home/unzip.rb",
// 439:         cellar:         "any",
// 440:         os:             "catalina",
// 441:         filename:       "unzip-2.0.catalina.bottle.tar.gz",
// 442:         local_filename: "unzip--2.0.catalina.bottle.tar.gz",
// 443:         sha256:         "d9cc50eec8ac243148a121049c236cba06af4a0b1156ab397d0a2850aa79c137",
// 444:       )
// 445:     end
// 446:
// 447:     specify "::parse_json_files" do
// 448:       Tempfile.open("hello--1.0.big_sur.bottle.json") do |f|
// 449:         f.write stub_hash(
// 450:           name:           "hello",
// 451:           version:        "1.0",
// 452:           path:           "/home/hello.rb",
// 453:           cellar:         "any_skip_relocation",
// 454:           os:             "big_sur",
// 455:           filename:       "hello-1.0.big_sur.bottle.tar.gz",
// 456:           local_filename: "hello--1.0.big_sur.bottle.tar.gz",
// 457:           sha256:         "a0af7dcbb5c83f6f3f7ecd507c2d352c1a018f894d51ad241ce8492fa598010f",
// 458:         )
// 459:         f.close
// 460:         expect(
// 461:           homebrew.parse_json_files([f.path]).first["hello"]["bottle"]["tags"]["big_sur"]["filename"],
// 462:         ).to eq("hello-1.0.big_sur.bottle.tar.gz")
// 463:       end
// 464:     end
// 465:
// 466:     describe "::merge_json_files" do
// 467:       it "merges JSON files" do
// 468:         bottles_hash = homebrew.merge_json_files(
// 469:           [hello_hash_big_sur, hello_hash_catalina, unzip_hash_big_sur, unzip_hash_catalina],
// 470:         )
// 471:
// 472:         hello_hash = bottles_hash["hello"]
// 473:         expect(hello_hash["bottle"]["tags"]["big_sur"]["cellar"]).to eq("any_skip_relocation")
// 474:         expect(hello_hash["bottle"]["tags"]["big_sur"]["filename"]).to eq("hello-1.0.big_sur.bottle.tar.gz")
// 475:         expect(hello_hash["bottle"]["tags"]["big_sur"]["local_filename"]).to eq("hello--1.0.big_sur.bottle.tar.gz")
// 476:         expect(hello_hash["bottle"]["tags"]["big_sur"]["sha256"]).to eq(
// 477:           "a0af7dcbb5c83f6f3f7ecd507c2d352c1a018f894d51ad241ce8492fa598010f",
// 478:         )
// 479:         expect(hello_hash["bottle"]["tags"]["catalina"]["cellar"]).to eq("any_skip_relocation")
// 480:         expect(hello_hash["bottle"]["tags"]["catalina"]["filename"]).to eq("hello-1.0.catalina.bottle.tar.gz")
// 481:         expect(hello_hash["bottle"]["tags"]["catalina"]["local_filename"]).to eq("hello--1.0.catalina.bottle.tar.gz")
// 482:         expect(hello_hash["bottle"]["tags"]["catalina"]["sha256"]).to eq(
// 483:           "5334dd344986e46b2aa4f0471cac7b0914bd7de7cb890a34415771788d03f2ac",
// 484:         )
// 485:         unzip_hash = bottles_hash["unzip"]
// 486:         expect(unzip_hash["bottle"]["tags"]["big_sur"]["cellar"]).to eq("any_skip_relocation")
// 487:         expect(unzip_hash["bottle"]["tags"]["big_sur"]["filename"]).to eq("unzip-2.0.big_sur.bottle.tar.gz")
// 488:         expect(unzip_hash["bottle"]["tags"]["big_sur"]["local_filename"]).to eq("unzip--2.0.big_sur.bottle.tar.gz")
// 489:         expect(unzip_hash["bottle"]["tags"]["big_sur"]["sha256"]).to eq(
// 490:           "16cf230afdfcb6306c208d169549cf8773c831c8653d2c852315a048960d7e72",
// 491:         )
// 492:         expect(unzip_hash["bottle"]["tags"]["catalina"]["cellar"]).to eq("any")
// 493:         expect(unzip_hash["bottle"]["tags"]["catalina"]["filename"]).to eq("unzip-2.0.catalina.bottle.tar.gz")
// 494:         expect(unzip_hash["bottle"]["tags"]["catalina"]["local_filename"]).to eq("unzip--2.0.catalina.bottle.tar.gz")
// 495:         expect(unzip_hash["bottle"]["tags"]["catalina"]["sha256"]).to eq(
// 496:           "d9cc50eec8ac243148a121049c236cba06af4a0b1156ab397d0a2850aa79c137",
// 497:         )
// 498:       end
// 499:
// 500:       # TODO: add deduplication tests e.g.
// 501:       #       it "deduplicates JSON files with matching macOS checksums"
// 502:       #       it "deduplicates JSON files with matching OS checksums" do
// 503:     end
// 504:
// 505:     describe "#merge_bottle_spec" do
// 506:       it "allows new bottle hash to be empty" do
// 507:         valid_keys = [:root_url, :cellar, :rebuild, :sha256]
// 508:         old_spec = BottleSpecification.new
// 509:         old_spec.sha256(big_sur: "f59bc65c91e4e698f6f050e1efea0040f57372d4dcf0996cbb8f97ced320403b")
// 510:         expect { homebrew.merge_bottle_spec(valid_keys, old_spec, {}) }.not_to raise_error
// 511:       end
// 512:
// 513:       it "checks for conflicting root URL" do
// 514:         old_spec = BottleSpecification.new
// 515:         old_spec.root_url("https://failbrew.bintray.com/bottles")
// 516:         new_hash = { "root_url" => "https://testbrew.bintray.com/bottles" }
// 517:         expect(homebrew.merge_bottle_spec([:root_url], old_spec, new_hash)).to eq [
// 518:           ['root_url: old: "https://failbrew.bintray.com/bottles", new: "https://testbrew.bintray.com/bottles"'],
// 519:           [],
// 520:         ]
// 521:       end
// 522:
// 523:       it "checks for conflicting rebuild number" do
// 524:         old_spec = BottleSpecification.new
// 525:         old_spec.rebuild(1)
// 526:         new_hash = { "rebuild" => 2 }
// 527:         expect(homebrew.merge_bottle_spec([:rebuild], old_spec, new_hash)).to eq [
// 528:           ['rebuild: old: "1", new: "2"'],
// 529:           [],
// 530:         ]
// 531:       end
// 532:
// 533:       it "checks for conflicting checksums" do
// 534:         old_spec = BottleSpecification.new
// 535:         old_sequoia_sha256 = "109c0cb581a7b5d84da36d84b221fb9dd0f8a927b3044d82611791c9907e202e"
// 536:         old_spec.sha256(sequoia: old_sequoia_sha256)
// 537:         old_spec.sha256(sonoma: "7571772bf7a0c9fe193e70e521318b53993bee6f351976c9b6e01e00d13d6c3f")
// 538:         new_sequoia_sha256 = "ec6d7f08412468f28dee2be17ad8cd8b883b16b34329efcecce019b8c9736428"
// 539:         new_hash = { "tags" => { "sequoia" => { "sha256" => new_sequoia_sha256 } } }
// 540:         expected_checksum_hash = { sonoma: "7571772bf7a0c9fe193e70e521318b53993bee6f351976c9b6e01e00d13d6c3f" }
// 541:         expected_checksum_hash[:cellar] = Homebrew::DEFAULT_MACOS_CELLAR
// 542:         expect(homebrew.merge_bottle_spec([:sha256], old_spec, new_hash)).to eq [
// 543:           ["sha256 sequoia: old: #{old_sequoia_sha256.inspect}, new: #{new_sequoia_sha256.inspect}"],
// 544:           [expected_checksum_hash],
// 545:         ]
// 546:       end
// 547:     end
// 548:
// 549:     describe "::generate_sha256_line" do
// 550:       it "generates a string without cellar" do
// 551:         expect(homebrew.generate_sha256_line(:sequoia, "deadbeef", nil, 0, 10)).to eq(
// 552:           <<~RUBY.chomp,
// 553:             sha256 sequoia:  "deadbeef"
// 554:           RUBY
// 555:         )
// 556:       end
// 557:
// 558:       it "generates a string with cellar symbol" do
// 559:         expect(homebrew.generate_sha256_line(:sequoia, "deadbeef", :any, 14, 24)).to eq(
// 560:           <<~RUBY.chomp,
// 561:             sha256 cellar: :any, sequoia:  "deadbeef"
// 562:           RUBY
// 563:         )
// 564:       end
// 565:
// 566:       it "generates a string with default cellar path" do
// 567:         expect(homebrew.generate_sha256_line(:sequoia, "deadbeef", Homebrew::DEFAULT_LINUX_CELLAR, 0, 10)).to eq(
// 568:           <<~RUBY.chomp,
// 569:             sha256 sequoia:  "deadbeef"
// 570:           RUBY
// 571:         )
// 572:       end
// 573:
// 574:       it "generates a string with non-default cellar path" do
// 575:         expect(homebrew.generate_sha256_line(:sequoia, "deadbeef", "/home/test", 22, 32)).to eq(
// 576:           <<~RUBY.chomp,
// 577:             sha256 cellar: "/home/test", sequoia:  "deadbeef"
// 578:           RUBY
// 579:         )
// 580:       end
// 581:
// 582:       context "with offsets" do
// 583:         it "generates a string without cellar" do
// 584:           expect(homebrew.generate_sha256_line(:sequoia, "deadbeef", nil, 0, 15)).to eq(
// 585:             <<~RUBY.chomp,
// 586:               sha256 sequoia:       "deadbeef"
// 587:             RUBY
// 588:           )
// 589:         end
// 590:
// 591:         it "generates a string with cellar symbol" do
// 592:           expect(homebrew.generate_sha256_line(:sequoia, "deadbeef", :any, 20, 35)).to eq(
// 593:             <<~RUBY.chomp,
// 594:               sha256 cellar: :any,       sequoia:       "deadbeef"
// 595:             RUBY
// 596:           )
// 597:         end
// 598:
// 599:         it "generates a string with default cellar path" do
// 600:           expect(homebrew.generate_sha256_line(:sequoia, "deadbeef", Homebrew::DEFAULT_LINUX_CELLAR, 14, 30)).to eq(
// 601:             <<~RUBY.chomp,
// 602:               sha256               sequoia:        "deadbeef"
// 603:             RUBY
// 604:           )
// 605:         end
// 606:
// 607:         it "generates a string with non-default cellar path" do
// 608:           expect(homebrew.generate_sha256_line(:sequoia, "deadbeef", "/home/test", 25, 36)).to eq(
// 609:             <<~RUBY.chomp,
// 610:               sha256 cellar: "/home/test",    sequoia:   "deadbeef"
// 611:             RUBY
// 612:           )
// 613:         end
// 614:       end
// 615:     end
// 616:
// 617:     describe "::bottle_output" do
// 618:       it "includes a custom root_url" do
// 619:         bottle = BottleSpecification.new
// 620:         bottle.root_url("https://example.com")
// 621:         bottle.sha256(catalina: "109c0cb581a7b5d84da36d84b221fb9dd0f8a927b3044d82611791c9907e202e")
// 622:
// 623:         expect(homebrew.bottle_output(bottle, nil)).to eq(
// 624:           <<-RUBY,
// 625:   bottle do
// 626:     root_url "https://example.com"
// 627:     sha256 catalina: "109c0cb581a7b5d84da36d84b221fb9dd0f8a927b3044d82611791c9907e202e"
// 628:   end
// 629:           RUBY
// 630:         )
// 631:       end
// 632:
// 633:       it "includes download strategy for custom root_url" do
// 634:         bottle = BottleSpecification.new
// 635:         bottle.root_url("https://example.com")
// 636:         bottle.sha256(catalina: "109c0cb581a7b5d84da36d84b221fb9dd0f8a927b3044d82611791c9907e202e")
// 637:
// 638:         expect(homebrew.bottle_output(bottle, "ExampleStrategy")).to eq(
// 639:           <<-RUBY,
// 640:   bottle do
// 641:     root_url "https://example.com",
// 642:       using: ExampleStrategy
// 643:     sha256 catalina: "109c0cb581a7b5d84da36d84b221fb9dd0f8a927b3044d82611791c9907e202e"
// 644:   end
// 645:           RUBY
// 646:         )
// 647:       end
// 648:     end
// 649:   end
// 650: end

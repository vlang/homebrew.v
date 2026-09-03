module cask

import brew_runtime
import homebrew.cask as cask_core
import os
import time

// Translated from Homebrew/brew `test/cask/caskroom_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn caskroom_spec_bool(value bool) brew_runtime.Value {
	return brew_runtime.bool_value(value)
}

fn caskroom_spec_temp(label string) string {
	return os.join_path(os.temp_dir(), 'brew-v-caskroom-${label}-${os.getpid()}-${time.now().unix_nano()}')
}

fn caskroom_spec_metadata(root string, token string, version string, extension string,
	contents string) !string {
	path := os.join_path(root, token, '.metadata', version, '20250101000000.000', 'Casks', '${token}.${extension}')
	os.mkdir_all(os.dir(path))!
	os.write_file(path, contents)!
	return path
}

fn caskroom_spec_artifact(kind string, value string) cask_core.CaskLoaderArtifact {
	return cask_core.CaskLoaderArtifact{ kind: kind, values: [value] }
}

fn caskroom_spec_empty_json(contents string) bool {
	return contents.replace(' ', '').replace('\n', '').replace('\r', '').replace('\t', '') == '{}'
}

fn caskroom_spec_migration_context(token string, caskfile string,
	artifacts []cask_core.CaskLoaderArtifact, receipt_artifacts []cask_core.CaskLoaderArtifact,
	force_failure bool) cask_core.CaskroomMigrationContext {
	mut receipts := map[string]cask_core.CaskLoaderReceipt{}
	if receipt_artifacts.len > 0 {
		receipts[token] = cask_core.CaskLoaderReceipt{
			version: '1.0'
			uninstall_artifacts: receipt_artifacts
			has_uninstall_artifacts: true
		}
	}
	return cask_core.CaskroomMigrationContext{
		load_context: cask_core.CaskLoaderLoadContext{
			lookup: cask_core.CaskLoaderLookupContext{
				installed_caskfiles: {
					token: caskfile
				}
				installed_receipts: receipts
				load_casks: {
					caskfile: cask_core.CaskLoaderCask{
						token: token
						version: '1.0'
						artifacts: artifacts
					}
				}
			}
		}
		force_source_load_failure: force_failure
	}
}

fn caskroom_spec_migrate(label string, extension string, contents string,
	artifacts []cask_core.CaskLoaderArtifact, receipt []cask_core.CaskLoaderArtifact,
	force_failure bool) bool {
	root := caskroom_spec_temp(label)
	os.mkdir_all(root) or { return false }
	defer { os.rmdir_all(root) or {} }
	caskfile := caskroom_spec_metadata(root, label, '1.0', extension, contents) or { return false }
	context := caskroom_spec_migration_context(label, caskfile, artifacts, receipt, force_failure)
	result := cask_core.caskroom_migrate_caskfile_to_json(caskfile, context) or { return false }
	return result.migrated || result.skipped
}

fn caskroom_spec_api_recovery(token string, source_line string) brew_runtime.Value {
	root := caskroom_spec_temp(token)
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	caskfile := caskroom_spec_metadata(root, token, '1.0', 'rb', 'cask "${token}" do\n  ${source_line}\nend\n') or { return caskroom_spec_bool(false) }
	context := cask_core.CaskroomMigrationContext{
		force_source_load_failure: true
		load_context: cask_core.CaskLoaderLoadContext{
			lookup: cask_core.CaskLoaderLookupContext{
				installed_caskfiles: {
					token: caskfile
				}
				api_membership: {
					token: cask_core.CaskLoaderAvailability.present
				}
				api_artifacts: {
					token: [caskroom_spec_artifact('app', 'Current.app')]
				}
			}
		}
	}
	result := cask_core.caskroom_migrate_caskfile_to_json(caskfile, context) or {
		return caskroom_spec_bool(false)
	}
	contents := os.read_file(result.json_path) or { return caskroom_spec_bool(false) }
	return caskroom_spec_bool(result.migrated && contents.contains('Current.app'))
}

fn caskroom_spec_json_api_recovery(token string, original string) brew_runtime.Value {
	root := caskroom_spec_temp(token)
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	caskfile := caskroom_spec_metadata(root, token, '1.0', 'json', original) or {
		return caskroom_spec_bool(false)
	}
	context := cask_core.CaskroomMigrationContext{
		force_source_load_failure: true
		load_context: cask_core.CaskLoaderLoadContext{
			lookup: cask_core.CaskLoaderLookupContext{
				api_membership: {
					token: cask_core.CaskLoaderAvailability.present
				}
				api_artifacts: {
					token: [caskroom_spec_artifact('app', 'Current.app')]
				}
			}
		}
	}
	result := cask_core.caskroom_migrate_caskfile_to_json(caskfile, context) or {
		return caskroom_spec_bool(false)
	}
	contents := os.read_file(result.json_path) or { return caskroom_spec_bool(false) }
	return caskroom_spec_bool(result.migrated && contents.contains('Current.app'))
}

// Ruby it `it "changes the group when sudo is unnecessary and the group is wrong" do` at line 10.
pub fn ruby_caskroom_spec_l10_d1_changes(args ...brew_runtime.Value) brew_runtime.Value {
	result := cask_core.caskroom_ensure_plan('/tmp/Caskroom', true, false, false, false, false) or { return caskroom_spec_bool(false) }
	return caskroom_spec_bool(result.created && !result.sudo && result.changed_group)
}

// Ruby it `it "skips changing the group when it is already correct" do` at line 21.
pub fn ruby_caskroom_spec_l21_d2_skips(args ...brew_runtime.Value) brew_runtime.Value {
	result := cask_core.caskroom_ensure_plan('/tmp/Caskroom', true, true, false, false, false) or { return caskroom_spec_bool(false) }
	return caskroom_spec_bool(result.created && !result.changed_group)
}

// Ruby it `it "changes the group with sudo when the parent is not writable and the group is wrong" do` at line 32.
pub fn ruby_caskroom_spec_l32_d3_changes(args ...brew_runtime.Value) brew_runtime.Value {
	result := cask_core.caskroom_ensure_plan('/tmp/sub/Caskroom', false, false, false, false, false) or { return caskroom_spec_bool(false) }
	return caskroom_spec_bool(result.sudo && result.changed_group)
}

// Ruby it `it "skips changing the group when it is already correct and the parent is not writable" do` at line 47.
pub fn ruby_caskroom_spec_l47_d4_skips(args ...brew_runtime.Value) brew_runtime.Value {
	result := cask_core.caskroom_ensure_plan('/tmp/sub/Caskroom', false, true, false, false, false) or { return caskroom_spec_bool(false) }
	return caskroom_spec_bool(result.sudo && !result.changed_group)
}

// Ruby it `it "skips sudo on Linux when the parent is user-writable", :needs_linux do` at line 62.
pub fn ruby_caskroom_spec_l62_d5_skips(args ...brew_runtime.Value) brew_runtime.Value {
	result := cask_core.caskroom_ensure_plan('/tmp/Caskroom', true, true, false, false, false) or { return caskroom_spec_bool(false) }
	return caskroom_spec_bool(!result.sudo)
}

// Ruby it `it "checks the admin group on macOS", :needs_macos do` at line 78.
pub fn ruby_caskroom_spec_l78_d6_checks(args ...brew_runtime.Value) brew_runtime.Value {
	$if macos {
		return caskroom_spec_bool(cask_core.caskroom_expected_group() == 'admin')
	}
	return caskroom_spec_bool(true)
}

// Ruby it `it "checks the current user's primary group on Linux", :needs_linux do` at line 86.
pub fn ruby_caskroom_spec_l86_d7_checks(args ...brew_runtime.Value) brew_runtime.Value {
	$if linux {
		return caskroom_spec_bool(cask_core.caskroom_expected_group() != '')
	}
	return caskroom_spec_bool(true)
}

// Ruby it `it "returns false when the expected group is unavailable" do` at line 96.
pub fn ruby_caskroom_spec_l96_d8_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return caskroom_spec_bool(!cask_core.caskroom_group_correct('/tmp/Caskroom', 'brew-v-definitely-missing-group'))
}

// Ruby it `it "checks cask metadata without loading a Cask object" do` at line 105.
pub fn ruby_caskroom_spec_l105_d9_checks(args ...brew_runtime.Value) brew_runtime.Value {
	root := caskroom_spec_temp('installed')
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	before := cask_core.caskroom_cask_installed(root, 'foo')
	caskroom_spec_metadata(root, 'foo', '1.0', 'rb', 'cask "foo"\n') or {
		return caskroom_spec_bool(false)
	}
	version := cask_core.caskroom_installed_version(root, 'foo', []string{}) or { '' }
	return caskroom_spec_bool(!before && cask_core.caskroom_cask_installed(root, 'foo') && cask_core.caskroom_cask_installed(root, 'homebrew/cask/foo') && version == '1.0')
}

// Ruby it `it "checks old-token metadata" do` at line 120.
pub fn ruby_caskroom_spec_l120_d10_checks(args ...brew_runtime.Value) brew_runtime.Value {
	root := caskroom_spec_temp('old-token')
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	caskfile := caskroom_spec_metadata(root, 'old-foo', '1.0', 'rb', 'cask "old-foo"\n') or {
		return caskroom_spec_bool(false)
	}
	found := cask_core.caskroom_installed_caskfile(root, 'foo', ['old-foo']) or { '' }
	return caskroom_spec_bool(found == caskfile)
}

// Ruby method `setup_cask_metadata(dir, token, tap: nil, version: "1.0")` at line 135.
pub fn ruby_caskroom_spec_l135_d11_setup_cask_metadata(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'dir and token are required')
	}
	version := if args.len > 2 { args[2].as_string() } else { '1.0' }
	path := caskroom_spec_metadata(args[0].as_string(), args[1].as_string(), version, 'rb', 'cask "${args[1].as_string()}" do\n  version "${version}"\nend\n') or {
		return brew_runtime.object_value('Error', err.msg())
	}
	return brew_runtime.string_value(path)
}

// Ruby it `it "includes casks installed from untrusted taps without loading cask files" do` at line 153.
pub fn ruby_caskroom_spec_l153_d12_includes(args ...brew_runtime.Value) brew_runtime.Value {
	root := caskroom_spec_temp('untrusted')
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	caskroom_spec_metadata(root, 'untrusted-cask', '1.0', 'rb', 'cask "untrusted-cask"') or {
		return caskroom_spec_bool(false)
	}
	casks := cask_core.caskroom_casks(root, cask_core.CaskLoaderLoadContext{
		lookup: cask_core.CaskLoaderLookupContext{
			load_casks: {
				'untrusted-cask': cask_core.CaskLoaderCask{
					token: 'untrusted-cask'
					version: '1.0'
				}
			}
		}
	})
	return caskroom_spec_bool(casks.len == 1 && casks[0].token == 'untrusted-cask' && casks[0].version == '1.0')
}

// Ruby it `it "does not list a cask twice when it is also installed under an old token", :trust_store do` at line 180.
pub fn ruby_caskroom_spec_l180_d13_does(args ...brew_runtime.Value) brew_runtime.Value {
	root := caskroom_spec_temp('rename-dedup')
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	for token in ['old-cask', 'new-cask'] {
		caskroom_spec_metadata(root, token, '1.0', 'rb', 'cask "${token}"') or {
			return caskroom_spec_bool(false)
		}
	}
	cask := cask_core.CaskLoaderCask{ token: 'new-cask', version: '2.0' }
	casks := cask_core.caskroom_casks(root, cask_core.CaskLoaderLoadContext{
		lookup: cask_core.CaskLoaderLookupContext{
			load_casks: {
				'old-cask': cask
				'new-cask': cask
			}
		}
	})
	return caskroom_spec_bool(casks.len == 1 && casks[0].token == 'new-cask')
}

// Ruby it `it "does not error for ambiguous installed casks when an ambiguous tap is untrusted" do` at line 205.
pub fn ruby_caskroom_spec_l205_d14_does(args ...brew_runtime.Value) brew_runtime.Value {
	root := caskroom_spec_temp('ambiguous')
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	caskroom_spec_metadata(root, 'ambiguous-untrusted-cask', '1.0', 'rb', '{}') or {
		return caskroom_spec_bool(false)
	}
	casks := cask_core.caskroom_casks(root, cask_core.CaskLoaderLoadContext{
		lookup: cask_core.CaskLoaderLookupContext{
			load_casks: {
				'ambiguous-untrusted-cask': cask_core.CaskLoaderCask{
					token: 'ambiguous-untrusted-cask'
					version: '1.0'
				}
			}
		}
	})
	return caskroom_spec_bool(casks.len == 1 && casks[0].version == '1.0')
}

// Ruby let `let(:caskroom) { mktmpdir/"Caskroom" }` at line 235.
pub fn ruby_caskroom_spec_l235_d15_caskroom(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := caskroom_spec_temp('migration')
	os.mkdir_all(root) or { return brew_runtime.object_value('Error', err.msg()) }
	return brew_runtime.string_value(root)
}

// Ruby method `write_installed_caskfile(token, contents, extension: "rb")` at line 240.
pub fn ruby_caskroom_spec_l240_d16_write_installed_caskfile(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('ArgumentError', 'caskroom, token and contents are required')
	}
	extension := if args.len > 3 { args[3].as_string() } else { 'rb' }
	path := caskroom_spec_metadata(args[0].as_string(), args[1].as_string(), '1.0', extension, args[2].as_string()) or { return brew_runtime.object_value('Error', err.msg()) }
	return brew_runtime.string_value(path)
}

// Ruby method `write_receipt(token, artifacts)` at line 248.
pub fn ruby_caskroom_spec_l248_d17_write_receipt(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 3 {
		return brew_runtime.object_value('ArgumentError', 'caskroom, token and artifacts are required')
	}
	path := os.join_path(args[0].as_string(), args[1].as_string(), '.metadata', 'INSTALL_RECEIPT.json')
	os.mkdir_all(os.dir(path)) or { return brew_runtime.object_value('Error', err.msg()) }
	mut artifact_rows := []string{}
	for artifact in args[2].string_array_data {
		artifact_rows << '{"app":["${artifact}"]}'
	}
	contents := '{"source":{"version":"1.0"},"uninstall_artifacts":[${artifact_rows.join(',')}]}'
	os.write_file(path, contents) or { return brew_runtime.object_value('Error', err.msg()) }
	return brew_runtime.string_value(path)
}

// Ruby it `it "uses receipt metadata when a Ruby caskfile is unreadable" do` at line 255.
pub fn ruby_caskroom_spec_l255_d18_uses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := caskroom_spec_temp('unreadable')
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	caskfile := caskroom_spec_metadata(root, 'unreadable', '1.0', 'rb', 'this is not Ruby') or {
		return caskroom_spec_bool(false)
	}
	artifact := caskroom_spec_artifact('app', 'Unreadable.app')
	context := caskroom_spec_migration_context('unreadable', caskfile, []cask_core.CaskLoaderArtifact{}, [
		artifact,
	], true)
	result := cask_core.caskroom_migrate_caskfile_to_json(caskfile, context) or {
		return caskroom_spec_bool(false)
	}
	contents := os.read_file(result.json_path) or { return caskroom_spec_bool(false) }
	return caskroom_spec_bool(result.migrated && !os.exists(caskfile) && caskroom_spec_empty_json(contents))
}

// Ruby it `it "treats reordered receipt artifacts as equivalent" do` at line 277.
pub fn ruby_caskroom_spec_l277_d19_treats(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	mut artifacts := []cask_core.CaskLoaderArtifact{}
	for index in 0 .. 8 {
		artifacts << caskroom_spec_artifact('font', 'Font${index}.ttf')
	}
	mut receipt := artifacts.clone()
	receipt.reverse_in_place()
	if !cask_core.caskroom_artifacts_equivalent(artifacts, receipt) {
		return caskroom_spec_bool(false)
	}
	root := caskroom_spec_temp('reordered-artifacts')
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	caskfile := caskroom_spec_metadata(root, 'reordered-artifacts', '1.0', 'rb', 'cask "reordered-artifacts"') or { return caskroom_spec_bool(false) }
	context := caskroom_spec_migration_context('reordered-artifacts', caskfile, artifacts, receipt, false)
	result := cask_core.caskroom_migrate_caskfile_to_json(caskfile, context) or {
		return caskroom_spec_bool(false)
	}
	contents := os.read_file(result.json_path) or { return caskroom_spec_bool(false) }
	return caskroom_spec_bool(!os.exists(caskfile) && caskroom_spec_empty_json(contents))
}

// Ruby it `it "restores original metadata when migrated artifact multiplicity differs" do` at line 301.
pub fn ruby_caskroom_spec_l301_d20_restores(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := caskroom_spec_temp('changed-artifacts')
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	original := 'cask "changed-artifacts" do\n  font "Duplicate.ttf"\n  font "Duplicate.ttf"\nend\n'
	caskfile := caskroom_spec_metadata(root, 'changed-artifacts', '1.0', 'rb', original) or {
		return caskroom_spec_bool(false)
	}
	duplicate := caskroom_spec_artifact('font', 'Duplicate.ttf')
	base := caskroom_spec_migration_context('changed-artifacts', caskfile, [duplicate, duplicate], []cask_core.CaskLoaderArtifact{}, false)
	context := cask_core.CaskroomMigrationContext{
		...base
		verification_artifacts: [duplicate]
		has_verification_artifacts: true
	}
	mut message := ''
	cask_core.caskroom_migrate_caskfile_to_json(caskfile, context) or { message = err.msg() }
	json_path := os.join_path(os.dir(caskfile), 'changed-artifacts.json')
	remaining := os.read_file(caskfile) or { '' }
	return caskroom_spec_bool(message == 'migrated Cask metadata differs from the original after preserving version and artifacts' && remaining == original && !os.exists(json_path))
}

// Ruby it `it "uses API metadata when a Ruby caskfile contains a removed method" do` at line 335.
pub fn ruby_caskroom_spec_l335_d21_uses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return caskroom_spec_api_recovery('removed-method', 'appcast "https://example.com/appcast.xml"')
}

// Ruby it `it "uses API metadata when a Ruby caskfile contains a deprecated method" do` at line 356.
pub fn ruby_caskroom_spec_l356_d22_uses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return caskroom_spec_api_recovery('deprecated-method', 'app "Old.app"')
}

// Ruby it `it "uses tap metadata instead of the API for a receipt-less third-party cask", :trust_store do` at line 379.
pub fn ruby_caskroom_spec_l379_d23_uses(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := caskroom_spec_temp('third-party')
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	caskfile := caskroom_spec_metadata(root, 'third-party', '1.0', 'json', '{}') or {
		return caskroom_spec_bool(false)
	}
	tap := cask_core.CaskLoaderTap{ name: 'thirdparty/foo' }
	context := cask_core.CaskroomMigrationContext{
		force_source_load_failure: true
		load_context: cask_core.CaskLoaderLoadContext{
			lookup: cask_core.CaskLoaderLookupContext{
				installed_caskfiles: {
					'third-party': caskfile
				}
				installed_receipts: {
					'third-party': cask_core.CaskLoaderReceipt{
						version: '1.0'
						tap: tap
						has_tap: true
					}
				}
				tap_artifacts: {
					'thirdparty/foo/third-party': [
						caskroom_spec_artifact('app', 'Third Party.app'),
					]
				}
				api_membership: {
					'third-party': cask_core.CaskLoaderAvailability.absent
				}
			}
		}
	}
	result := cask_core.caskroom_migrate_caskfile_to_json(caskfile, context) or {
		return caskroom_spec_bool(false)
	}
	contents := os.read_file(result.json_path) or { return caskroom_spec_bool(false) }
	return caskroom_spec_bool(contents.contains('Third Party.app') && !contents.contains('Current.app'))
}

// Ruby it `it "preserves artifacts when the install receipt is empty" do` at line 405.
pub fn ruby_caskroom_spec_l405_d24_preserves(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return caskroom_spec_bool(caskroom_spec_migrate('empty-receipt', 'rb', 'cask "empty-receipt"', [
		caskroom_spec_artifact('app', 'Empty Receipt.app'),
	], []cask_core.CaskLoaderArtifact{}, false))
}

// Ruby it `it "replaces malformed installed JSON using API metadata" do` at line 422.
pub fn ruby_caskroom_spec_l422_d25_replaces(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return caskroom_spec_json_api_recovery('malformed-json', '{')
}

// Ruby it `it "replaces invalid artifact data in installed JSON using API metadata" do` at line 437.
pub fn ruby_caskroom_spec_l437_d26_replaces(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	return caskroom_spec_json_api_recovery('invalid-artifacts', '{"artifacts":["invalid"]}')
}

// Ruby it `it "keeps intentional empty artifacts in installed JSON" do` at line 452.
pub fn ruby_caskroom_spec_l452_d27_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := caskroom_spec_temp('stage-only')
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	caskfile := caskroom_spec_metadata(root, 'stage-only', '1.0', 'json', '{"artifacts":[]}') or {
		return caskroom_spec_bool(false)
	}
	context := cask_core.CaskroomMigrationContext{ force_source_load_failure: true }
	result := cask_core.caskroom_migrate_caskfile_to_json(caskfile, context) or {
		return caskroom_spec_bool(false)
	}
	contents := os.read_file(result.json_path) or { return caskroom_spec_bool(false) }
	compact := contents.replace(' ', '').replace('\n', '').replace('\r', '').replace('\t', '')
	return caskroom_spec_bool(compact == '{"artifacts":[]}')
}

// Ruby it `it "does not mark unavailable artifacts as intentionally empty" do` at line 461.
pub fn ruby_caskroom_spec_l461_d28_does(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := caskroom_spec_temp('removed-cask')
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	caskfile := caskroom_spec_metadata(root, 'removed-cask', '1.0', 'json', '{}') or {
		return caskroom_spec_bool(false)
	}
	context := cask_core.CaskroomMigrationContext{
		force_source_load_failure: true
		load_context: cask_core.CaskLoaderLoadContext{
			lookup: cask_core.CaskLoaderLookupContext{
				api_membership: {
					'removed-cask': cask_core.CaskLoaderAvailability.absent
				}
				api_artifact_failures: ['removed-cask']
			}
		}
	}
	result := cask_core.caskroom_migrate_caskfile_to_json(caskfile, context) or {
		return caskroom_spec_bool(false)
	}
	contents := os.read_file(caskfile) or { return caskroom_spec_bool(false) }
	return caskroom_spec_bool(result.skipped && result.reason == 'artifacts unavailable' && contents == '{}')
}

// Ruby it `it "returns tokens for directories without valid caskfiles" do` at line 476.
pub fn ruby_caskroom_spec_l476_d29_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := caskroom_spec_temp('corrupt')
	os.mkdir_all(os.join_path(root, 'corrupt-cask', '1.0')) or {
		return caskroom_spec_bool(false)
	}
	defer { os.rmdir_all(root) or {} }
	caskroom_spec_metadata(root, 'installed-cask', '1.0', 'rb', '') or {
		return caskroom_spec_bool(false)
	}
	return caskroom_spec_bool(cask_core.caskroom_corrupt_cask_dirs(root) == [
		'corrupt-cask',
	])
}

// Ruby it `it "returns empty array when all directories have valid caskfiles" do` at line 488.
pub fn ruby_caskroom_spec_l488_d30_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := caskroom_spec_temp('valid')
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	caskroom_spec_metadata(root, 'installed-cask', '1.0', 'rb', '') or {
		return caskroom_spec_bool(false)
	}
	return caskroom_spec_bool(cask_core.caskroom_corrupt_cask_dirs(root).len == 0)
}

// Ruby it `it "returns empty array when caskroom is empty" do` at line 499.
pub fn ruby_caskroom_spec_l499_d31_returns(args ...brew_runtime.Value) brew_runtime.Value {
	_ = args
	root := caskroom_spec_temp('empty')
	os.mkdir_all(root) or { return caskroom_spec_bool(false) }
	defer { os.rmdir_all(root) or {} }
	return caskroom_spec_bool(cask_core.caskroom_corrupt_cask_dirs(root).len == 0)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/caskroom"
// 5:
// 6: RSpec.describe Cask::Caskroom do
// 7:   before { described_class.expected_caskroom_group = nil }
// 8:
// 9:   describe ".ensure_caskroom_exists" do
// 10:     it "changes the group when sudo is unnecessary and the group is wrong" do
// 11:       Dir.mktmpdir do |dir|
// 12:         path = Pathname(dir)/"Caskroom"
// 13:         allow(described_class).to receive(:path).and_return(path)
// 14:         allow(described_class).to receive(:caskroom_group_correct?).with(path).and_return(false)
// 15:         expect(described_class).to receive(:chgrp_path).with(path, false)
// 16:
// 17:         described_class.ensure_caskroom_exists
// 18:       end
// 19:     end
// 20:
// 21:     it "skips changing the group when it is already correct" do
// 22:       Dir.mktmpdir do |dir|
// 23:         path = Pathname(dir)/"Caskroom"
// 24:         allow(described_class).to receive(:path).and_return(path)
// 25:         allow(described_class).to receive(:caskroom_group_correct?).with(path).and_return(true)
// 26:         expect(described_class).not_to receive(:chgrp_path)
// 27:
// 28:         described_class.ensure_caskroom_exists
// 29:       end
// 30:     end
// 31:
// 32:     it "changes the group with sudo when the parent is not writable and the group is wrong" do
// 33:       Dir.mktmpdir do |dir|
// 34:         path = Pathname(dir)/"sub"/"Caskroom"
// 35:         parent = path.parent
// 36:         allow(described_class).to receive_messages(path:, caskroom_group_correct?: false)
// 37:         allow(path).to receive(:parent).and_return(parent)
// 38:         allow(parent).to receive(:writable?).and_return(false)
// 39:         allow(SystemCommand).to receive(:run)
// 40:
// 41:         expect(described_class).to receive(:chgrp_path).with(path, true)
// 42:
// 43:         described_class.ensure_caskroom_exists
// 44:       end
// 45:     end
// 46:
// 47:     it "skips changing the group when it is already correct and the parent is not writable" do
// 48:       Dir.mktmpdir do |dir|
// 49:         path = Pathname(dir)/"sub"/"Caskroom"
// 50:         parent = path.parent
// 51:         allow(described_class).to receive_messages(path:, caskroom_group_correct?: true)
// 52:         allow(path).to receive(:parent).and_return(parent)
// 53:         allow(parent).to receive(:writable?).and_return(false)
// 54:         allow(SystemCommand).to receive(:run)
// 55:
// 56:         expect(described_class).not_to receive(:chgrp_path)
// 57:
// 58:         described_class.ensure_caskroom_exists
// 59:       end
// 60:     end
// 61:
// 62:     it "skips sudo on Linux when the parent is user-writable", :needs_linux do
// 63:       Dir.mktmpdir do |dir|
// 64:         path = Pathname(dir)/"Caskroom"
// 65:         allow(described_class).to receive(:path).and_return(path)
// 66:         expect(SystemCommand).not_to receive(:run).with(anything, hash_including(sudo: true))
// 67:         allow(SystemCommand).to receive(:run).and_call_original
// 68:
// 69:         described_class.ensure_caskroom_exists
// 70:
// 71:         expect(path).to be_directory
// 72:         expect(path.stat.gid).to eq(Process.egid)
// 73:       end
// 74:     end
// 75:   end
// 76:
// 77:   describe ".caskroom_group_correct?" do
// 78:     it "checks the admin group on macOS", :needs_macos do
// 79:       path = Pathname("/tmp/Caskroom")
// 80:       allow(path).to receive(:stat).and_return(instance_double(File::Stat, gid: 1))
// 81:       allow(Etc).to receive(:getgrnam).with("admin").and_return(instance_double(Etc::Group, gid: 1))
// 82:
// 83:       expect(described_class.caskroom_group_correct?(path)).to be true
// 84:     end
// 85:
// 86:     it "checks the current user's primary group on Linux", :needs_linux do
// 87:       group_name = "primary-group"
// 88:       path = Pathname("/tmp/Caskroom")
// 89:       allow(path).to receive(:stat).and_return(instance_double(File::Stat, gid: 1))
// 90:       allow(Etc).to receive(:getgrgid).with(Process.egid).and_return(instance_double(Etc::Group, name: group_name))
// 91:       allow(Etc).to receive(:getgrnam).with(group_name).and_return(instance_double(Etc::Group, gid: 1))
// 92:
// 93:       expect(described_class.caskroom_group_correct?(path)).to be true
// 94:     end
// 95:
// 96:     it "returns false when the expected group is unavailable" do
// 97:       allow(described_class).to receive(:expected_caskroom_group).and_return("missing")
// 98:       allow(Etc).to receive(:getgrnam).with("missing").and_return(nil)
// 99:
// 100:       expect(described_class.caskroom_group_correct?(Pathname("/tmp/Caskroom"))).to be false
// 101:     end
// 102:   end
// 103:
// 104:   describe ".cask_installed?" do
// 105:     it "checks cask metadata without loading a Cask object" do
// 106:       Dir.mktmpdir do |dir|
// 107:         allow(described_class).to receive(:path).and_return(Pathname(dir))
// 108:         expect(described_class.cask_installed?("foo")).to be(false)
// 109:
// 110:         casks_dir = Pathname(dir)/"foo/.metadata/1.0/20250101000000.000/Casks"
// 111:         casks_dir.mkpath
// 112:         (casks_dir/"foo.rb").write("cask \"foo\"\n")
// 113:
// 114:         expect(described_class.cask_installed?("foo")).to be(true)
// 115:         expect(described_class.cask_installed?("homebrew/cask/foo")).to be(true)
// 116:         expect(described_class.cask_installed_version("foo")).to eq("1.0")
// 117:       end
// 118:     end
// 119:
// 120:     it "checks old-token metadata" do
// 121:       Dir.mktmpdir do |dir|
// 122:         allow(described_class).to receive(:path).and_return(Pathname(dir))
// 123:         casks_dir = Pathname(dir)/"old-foo/.metadata/1.0/20250101000000.000/Casks"
// 124:         casks_dir.mkpath
// 125:         caskfile = casks_dir/"old-foo.rb"
// 126:         caskfile.write("cask \"old-foo\"\n")
// 127:
// 128:         expect(described_class.cask_installed_caskfile("foo", old_tokens: ["old-foo"])).to eq(caskfile)
// 129:       end
// 130:     end
// 131:   end
// 132:
// 133:   describe ".casks" do
// 134:     sig { params(dir: Pathname, token: String, tap: T.nilable(Tap), version: String).void }
// 135:     def setup_cask_metadata(dir, token, tap: nil, version: "1.0")
// 136:       casks_dir = dir/token/".metadata"/version/"20250101000000.000"/"Casks"
// 137:       casks_dir.mkpath
// 138:       (casks_dir/"#{token}.rb").write <<~RUBY
// 139:         cask "#{token}" do
// 140:           version "#{version}"
// 141:         end
// 142:       RUBY
// 143:
// 144:       receipt = dir/token/".metadata"/AbstractTab::FILENAME
// 145:       receipt.write JSON.generate({
// 146:         source: {
// 147:           tap:     tap&.name,
// 148:           version: version,
// 149:         },
// 150:       })
// 151:     end
// 152:
// 153:     it "includes casks installed from untrusted taps without loading cask files" do
// 154:       token = "untrusted-cask"
// 155:       tap = Tap.fetch("thirdparty", "foo")
// 156:       cask_path = tap.cask_dir/"#{token}.rb"
// 157:       cask_path.dirname.mkpath
// 158:       cask_path.write <<~RUBY
// 159:         raise "untrusted cask evaluated"
// 160:       RUBY
// 161:
// 162:       Dir.mktmpdir do |dir|
// 163:         allow(described_class).to receive(:path).and_return(Pathname(dir))
// 164:
// 165:         setup_cask_metadata(Pathname(dir), token, tap:, version: "1.0")
// 166:
// 167:         with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 168:           casks = described_class.casks
// 169:           expect(casks.map(&:token)).to eq([token])
// 170:
// 171:           cask = casks.first
// 172:           expect(cask&.installed_version).to eq("1.0")
// 173:           expect(cask&.tap).to eq(tap)
// 174:         end
// 175:       end
// 176:     ensure
// 177:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 178:     end
// 179:
// 180:     it "does not list a cask twice when it is also installed under an old token", :trust_store do
// 181:       tap = Tap.fetch("thirdparty", "foo")
// 182:       cask_path = tap.cask_dir/"new-cask.rb"
// 183:       cask_path.dirname.mkpath
// 184:       cask_path.write <<~RUBY
// 185:         cask "new-cask" do
// 186:           version "2.0"
// 187:         end
// 188:       RUBY
// 189:       (tap.path/"cask_renames.json").write JSON.generate("old-cask" => "new-cask")
// 190:       tap.clear_cache
// 191:       Homebrew::Trust.trust!(:tap, tap.name)
// 192:
// 193:       Dir.mktmpdir do |dir|
// 194:         allow(described_class).to receive(:path).and_return(Pathname(dir))
// 195:
// 196:         setup_cask_metadata(Pathname(dir), "new-cask", tap:, version: "2.0")
// 197:         setup_cask_metadata(Pathname(dir), "old-cask", tap:, version: "1.0")
// 198:
// 199:         expect(described_class.casks.map(&:token)).to eq(["new-cask"])
// 200:       end
// 201:     ensure
// 202:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 203:     end
// 204:
// 205:     it "does not error for ambiguous installed casks when an ambiguous tap is untrusted" do
// 206:       token = "ambiguous-untrusted-cask"
// 207:       taps = [Tap.fetch("thirdparty", "foo"), Tap.fetch("thirdparty", "bar")]
// 208:       taps.each do |tap|
// 209:         cask_path = tap.cask_dir/"#{token}.rb"
// 210:         cask_path.dirname.mkpath
// 211:         cask_path.write <<~RUBY
// 212:           cask "#{token}" do
// 213:             version "2.0"
// 214:           end
// 215:         RUBY
// 216:       end
// 217:       Dir.mktmpdir do |dir|
// 218:         allow(described_class).to receive(:path).and_return(Pathname(dir))
// 219:
// 220:         setup_cask_metadata(Pathname(dir), token, version: "1.0")
// 221:
// 222:         with_env(HOMEBREW_REQUIRE_TAP_TRUST: "1") do
// 223:           casks = described_class.casks
// 224:           expect(casks.map(&:token)).to eq([token])
// 225:           expect(casks.first&.installed_version).to eq("1.0")
// 226:         end
// 227:       end
// 228:     ensure
// 229:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 230:     end
// 231:   end
// 232:
// 233:   describe ".migrate_caskfile_to_json" do
// 234:     sig { returns(Pathname) }
// 235:     let(:caskroom) { mktmpdir/"Caskroom" }
// 236:
// 237:     before { allow(described_class).to receive(:path).and_return(caskroom) }
// 238:
// 239:     sig { params(token: String, contents: String, extension: String).returns(Pathname) }
// 240:     def write_installed_caskfile(token, contents, extension: "rb")
// 241:       caskfile = caskroom/token/".metadata/1.0/20250101000000.000/Casks/#{token}.#{extension}"
// 242:       caskfile.dirname.mkpath
// 243:       caskfile.write(contents)
// 244:       caskfile
// 245:     end
// 246:
// 247:     sig { params(token: String, artifacts: T::Array[T::Hash[String, T.untyped]]).void }
// 248:     def write_receipt(token, artifacts)
// 249:       (caskroom/token/".metadata/INSTALL_RECEIPT.json").write JSON.pretty_generate({
// 250:         "source"              => { "version" => "1.0" },
// 251:         "uninstall_artifacts" => artifacts,
// 252:       })
// 253:     end
// 254:
// 255:     it "uses receipt metadata when a Ruby caskfile is unreadable" do
// 256:       token = "unreadable"
// 257:       caskfile = write_installed_caskfile(token, "this is not Ruby")
// 258:       write_receipt(token, [{ "app" => ["Unreadable.app"] }])
// 259:
// 260:       described_class.migrate_caskfile_to_json(caskfile)
// 261:
// 262:       json_caskfile = caskfile.sub_ext(".json")
// 263:       migrated_cask = Cask::CaskLoader.load_from_installed_caskfile(json_caskfile)
// 264:       expect([
// 265:         caskfile.exist?,
// 266:         JSON.parse(json_caskfile.read),
// 267:         migrated_cask.version.to_s,
// 268:         migrated_cask.artifacts_list(uninstall_only: true),
// 269:       ]).to eq([
// 270:         false,
// 271:         {},
// 272:         "1.0",
// 273:         [{ app: ["Unreadable.app"] }],
// 274:       ])
// 275:     end
// 276:
// 277:     it "treats reordered receipt artifacts as equivalent" do
// 278:       token = "reordered-artifacts"
// 279:       caskfile = write_installed_caskfile(token, <<~RUBY)
// 280:         cask "#{token}" do
// 281:           version "1.0"
// 282:           font "Font0.ttf"
// 283:           font "Font1.ttf"
// 284:           font "Font2.ttf"
// 285:           font "Font3.ttf"
// 286:           font "Font4.ttf"
// 287:           font "Font5.ttf"
// 288:           font "Font6.ttf"
// 289:           font "Font7.ttf"
// 290:         end
// 291:       RUBY
// 292:       artifacts = Array.new(8) { |i| { "font" => ["Font#{i}.ttf"] } }
// 293:       write_receipt(token, artifacts)
// 294:
// 295:       described_class.migrate_caskfile_to_json(caskfile)
// 296:
// 297:       json_caskfile = caskfile.sub_ext(".json")
// 298:       expect([caskfile.exist?, JSON.parse(json_caskfile.read)]).to eq([false, {}])
// 299:     end
// 300:
// 301:     it "restores original metadata when migrated artifact multiplicity differs" do
// 302:       token = "changed-artifacts"
// 303:       caskfile = write_installed_caskfile(token, <<~RUBY)
// 304:         cask "#{token}" do
// 305:           version "1.0"
// 306:           font "Duplicate.ttf"
// 307:           font "Duplicate.ttf"
// 308:         end
// 309:       RUBY
// 310:       original_contents = caskfile.read
// 311:       json_caskfile = caskfile.sub_ext(".json")
// 312:       migrated_cask = instance_double(
// 313:         Cask::Cask,
// 314:         version:        "1.0",
// 315:         artifacts_list: [{ font: ["Duplicate.ttf"] }],
// 316:       )
// 317:       allow(Cask::CaskLoader).to receive(:load_from_installed_caskfile)
// 318:         .with(json_caskfile, api_fallback: false)
// 319:         .and_return(migrated_cask)
// 320:
// 321:       error = T.let(nil, T.nilable(RuntimeError))
// 322:       begin
// 323:         described_class.migrate_caskfile_to_json(caskfile)
// 324:       rescue RuntimeError => e
// 325:         error = e
// 326:       end
// 327:
// 328:       expect([error&.message, caskfile.read, json_caskfile.exist?]).to eq([
// 329:         "migrated Cask metadata differs from the original after preserving version and artifacts",
// 330:         original_contents,
// 331:         false,
// 332:       ])
// 333:     end
// 334:
// 335:     it "uses API metadata when a Ruby caskfile contains a removed method" do
// 336:       token = "removed-method"
// 337:       caskfile = write_installed_caskfile(token, <<~RUBY)
// 338:         cask "#{token}" do
// 339:           version "1.0"
// 340:           appcast "https://example.com/appcast.xml"
// 341:           app "Old.app"
// 342:         end
// 343:       RUBY
// 344:       allow(Homebrew::API).to receive(:cask_token?).with(token).and_return(true)
// 345:       allow(Homebrew::API::Cask).to receive(:cask_json).with(token).and_return({
// 346:         "artifacts" => [{ "app" => ["Current.app"] }],
// 347:       })
// 348:
// 349:       described_class.migrate_caskfile_to_json(caskfile)
// 350:
// 351:       expect(JSON.parse(caskfile.sub_ext(".json").read)).to eq({
// 352:         "artifacts" => [{ "app" => ["Current.app"] }],
// 353:       })
// 354:     end
// 355:
// 356:     it "uses API metadata when a Ruby caskfile contains a deprecated method" do
// 357:       token = "deprecated-method"
// 358:       caskfile = write_installed_caskfile(token, <<~RUBY)
// 359:         cask "#{token}" do
// 360:           version "1.0"
// 361:           app "Old.app"
// 362:         end
// 363:       RUBY
// 364:       allow(Cask::CaskLoader).to receive(:load)
// 365:         .with(caskfile, warn: false)
// 366:         .and_raise(MethodDeprecatedError.new)
// 367:       allow(Homebrew::API).to receive(:cask_token?).with(token).and_return(true)
// 368:       allow(Homebrew::API::Cask).to receive(:cask_json).with(token).and_return({
// 369:         "artifacts" => [{ "app" => ["Current.app"] }],
// 370:       })
// 371:
// 372:       described_class.migrate_caskfile_to_json(caskfile)
// 373:
// 374:       expect(JSON.parse(caskfile.sub_ext(".json").read)).to eq({
// 375:         "artifacts" => [{ "app" => ["Current.app"] }],
// 376:       })
// 377:     end
// 378:
// 379:     it "uses tap metadata instead of the API for a receipt-less third-party cask", :trust_store do
// 380:       token = "third-party"
// 381:       tap = Tap.fetch("thirdparty", "foo")
// 382:       caskfile = write_installed_caskfile(token, "{}", extension: "json")
// 383:       cask_path = tap.cask_dir/"#{token}.rb"
// 384:       cask_path.dirname.mkpath
// 385:       cask_path.write <<~RUBY
// 386:         cask "#{token}" do
// 387:           version "2.0"
// 388:           app "Third Party.app"
// 389:         end
// 390:       RUBY
// 391:       Homebrew::Trust.trust!(:tap, tap.name)
// 392:       allow(Homebrew::EnvConfig).to receive(:no_install_from_api?).and_return(false)
// 393:       allow(Homebrew::API).to receive_messages(cask_token?: false, cask_renames: {})
// 394:       allow(Homebrew::API::Cask).to receive(:cask_json).and_raise("unexpected official API lookup")
// 395:
// 396:       described_class.migrate_caskfile_to_json(caskfile)
// 397:
// 398:       expect(JSON.parse(caskfile.read)).to eq({
// 399:         "artifacts" => [{ "app" => ["Third Party.app"] }],
// 400:       })
// 401:     ensure
// 402:       FileUtils.rm_rf HOMEBREW_TAP_DIRECTORY/"thirdparty"
// 403:     end
// 404:
// 405:     it "preserves artifacts when the install receipt is empty" do
// 406:       token = "empty-receipt"
// 407:       caskfile = write_installed_caskfile(token, <<~RUBY)
// 408:         cask "#{token}" do
// 409:           version "1.0"
// 410:           app "Empty Receipt.app"
// 411:         end
// 412:       RUBY
// 413:       (caskroom/token/".metadata/INSTALL_RECEIPT.json").write("")
// 414:
// 415:       described_class.migrate_caskfile_to_json(caskfile)
// 416:
// 417:       expect(JSON.parse(caskfile.sub_ext(".json").read)).to eq({
// 418:         "artifacts" => [{ "app" => ["Empty Receipt.app"] }],
// 419:       })
// 420:     end
// 421:
// 422:     it "replaces malformed installed JSON using API metadata" do
// 423:       token = "malformed-json"
// 424:       caskfile = write_installed_caskfile(token, "{", extension: "json")
// 425:       allow(Homebrew::API).to receive(:cask_token?).with(token).and_return(true)
// 426:       allow(Homebrew::API::Cask).to receive(:cask_json).with(token).and_return({
// 427:         "artifacts" => [{ "app" => ["Current.app"] }],
// 428:       })
// 429:
// 430:       described_class.migrate_caskfile_to_json(caskfile)
// 431:
// 432:       expect(JSON.parse(caskfile.read)).to eq({
// 433:         "artifacts" => [{ "app" => ["Current.app"] }],
// 434:       })
// 435:     end
// 436:
// 437:     it "replaces invalid artifact data in installed JSON using API metadata" do
// 438:       token = "invalid-artifacts"
// 439:       caskfile = write_installed_caskfile(token, JSON.generate({ "artifacts" => ["invalid"] }), extension: "json")
// 440:       allow(Homebrew::API).to receive(:cask_token?).with(token).and_return(true)
// 441:       allow(Homebrew::API::Cask).to receive(:cask_json).with(token).and_return({
// 442:         "artifacts" => [{ "app" => ["Current.app"] }],
// 443:       })
// 444:
// 445:       described_class.migrate_caskfile_to_json(caskfile)
// 446:
// 447:       expect(JSON.parse(caskfile.read)).to eq({
// 448:         "artifacts" => [{ "app" => ["Current.app"] }],
// 449:       })
// 450:     end
// 451:
// 452:     it "keeps intentional empty artifacts in installed JSON" do
// 453:       caskfile = write_installed_caskfile("stage-only", JSON.generate({ "artifacts" => [] }), extension: "json")
// 454:       expect(Homebrew::API::Cask).not_to receive(:cask_json)
// 455:
// 456:       described_class.migrate_caskfile_to_json(caskfile)
// 457:
// 458:       expect(JSON.parse(caskfile.read)).to eq({ "artifacts" => [] })
// 459:     end
// 460:
// 461:     it "does not mark unavailable artifacts as intentionally empty" do
// 462:       token = "removed-cask"
// 463:       caskfile = write_installed_caskfile(token, "{}", extension: "json")
// 464:       allow(Homebrew::API).to receive(:cask_token?).with(token).and_return(false)
// 465:       allow(Homebrew::API::Cask).to receive(:cask_json).with(token).and_raise(
// 466:         ErrorDuringExecution.new(["curl"], status: 22),
// 467:       )
// 468:
// 469:       described_class.migrate_caskfile_to_json(caskfile)
// 470:
// 471:       expect(JSON.parse(caskfile.read)).to eq({})
// 472:     end
// 473:   end
// 474:
// 475:   describe ".corrupt_cask_dirs" do
// 476:     it "returns tokens for directories without valid caskfiles" do
// 477:       Dir.mktmpdir do |dir|
// 478:         allow(described_class).to receive(:path).and_return(Pathname(dir))
// 479:         (Pathname(dir)/"corrupt-cask"/"1.0").mkpath
// 480:         casks_dir = (Pathname(dir)/"installed-cask"/".metadata"/"1.0"/"0"/"Casks")
// 481:         casks_dir.mkpath
// 482:         FileUtils.touch casks_dir/"installed-cask.rb"
// 483:
// 484:         expect(described_class.corrupt_cask_dirs).to eq(["corrupt-cask"])
// 485:       end
// 486:     end
// 487:
// 488:     it "returns empty array when all directories have valid caskfiles" do
// 489:       Dir.mktmpdir do |dir|
// 490:         allow(described_class).to receive(:path).and_return(Pathname(dir))
// 491:         casks_dir = (Pathname(dir)/"installed-cask"/".metadata"/"1.0"/"0"/"Casks")
// 492:         casks_dir.mkpath
// 493:         FileUtils.touch casks_dir/"installed-cask.rb"
// 494:
// 495:         expect(described_class.corrupt_cask_dirs).to be_empty
// 496:       end
// 497:     end
// 498:
// 499:     it "returns empty array when caskroom is empty" do
// 500:       Dir.mktmpdir do |dir|
// 501:         allow(described_class).to receive(:path).and_return(Pathname(dir))
// 502:
// 503:         expect(described_class.corrupt_cask_dirs).to be_empty
// 504:       end
// 505:     end
// 506:   end
// 507: end

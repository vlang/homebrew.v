module cask

import ruby
import os
import x.json2

// Translated from Homebrew/brew `cask/caskroom.rb`.
pub const caskroom_caskfile_extensions = ['json', 'internal.json', 'rb']

pub struct CaskroomEnsureResult {
pub:
	created       bool
	sudo          bool
	changed_group bool
	commands      [][]string
	output        string
}

pub struct CaskroomMigrationContext {
pub:
	load_context               CaskLoaderLoadContext
	verification_artifacts     []CaskLoaderArtifact
	has_verification_artifacts bool
	verification_version       string
	force_source_load_failure  bool
}

pub struct CaskroomMigrationResult {
pub:
	token       string
	source_path string
	json_path   string
	migrated    bool
	skipped     bool
	reason      string
}

pub fn caskroom_path(homebrew_prefix string) string {
	return os.join_path(homebrew_prefix, 'Caskroom')
}

pub fn caskroom_paths(path string) []string {
	if !os.exists(path) {
		return []
	}
	mut paths := []string{}
	for name in os.ls(path) or { []string{} } {
		child := os.join_path(path, name)
		if os.is_dir(child) && !os.is_link(child) {
			paths << child
		}
	}
	return paths
}

pub fn caskroom_tokens(path string) []string {
	return caskroom_paths(path).map(os.base(it))
}

pub fn caskroom_any_casks_installed(path string) bool {
	return caskroom_paths(path).len > 0
}

pub fn caskroom_token_from_full_token(token string) string {
	parts := token.split_nth('/', 3)
	return if parts.len == 3 { parts[2] } else { token }
}

pub fn caskroom_installed_caskfile(path string, token string, old_tokens []string) ?string {
	mut candidates := [token]
	candidates << old_tokens
	mut seen := map[string]bool{}
	for full_token in candidates {
		cask_token := caskroom_token_from_full_token(full_token)
		if cask_token in seen {
			continue
		}
		seen[cask_token] = true
		cask_path := os.join_path(path, cask_token)
		if !os.is_dir(cask_path) || os.is_link(cask_path) {
			continue
		}
		mut timestamped := os.glob(os.join_path(cask_path, '.metadata', '*', '*')) or { []string{} }
		timestamped = timestamped.filter(os.is_dir(it))
		if timestamped.len == 0 {
			continue
		}
		timestamped.sort_with_compare(fn (left &string, right &string) int {
			return compare_strings(os.base(*left), os.base(*right))
		})
		latest := timestamped[timestamped.len - 1]
		for extension in caskroom_caskfile_extensions {
			caskfile := os.join_path(latest, 'Casks', '${cask_token}.${extension}')
			if os.exists(caskfile) {
				return caskfile
			}
		}
	}
	return none
}

pub fn caskroom_installed_version(path string, token string, old_tokens []string) ?string {
	caskfile := caskroom_installed_caskfile(path, token, old_tokens) or { return none }
	parts := os.norm_path(caskfile).split(os.path_separator)
	if parts.len < 4 {
		return none
	}
	return parts[parts.len - 4]
}

pub fn caskroom_cask_installed(path string, token string) bool {
	return caskroom_installed_version(path, token, []string{}) != none
}

fn caskroom_artifact_key(artifact CaskLoaderArtifact) string {
	return artifact.kind + '\x00' + artifact.values.join('\x00')
}

pub fn caskroom_artifacts_equivalent(first []CaskLoaderArtifact,
	second []CaskLoaderArtifact) bool {
	mut first_tally := map[string]int{}
	mut second_tally := map[string]int{}
	for artifact in first {
		key := caskroom_artifact_key(artifact)
		first_tally[key] = (first_tally[key] or { 0 }) + 1
	}
	for artifact in second {
		key := caskroom_artifact_key(artifact)
		second_tally[key] = (second_tally[key] or { 0 }) + 1
	}
	return first_tally == second_tally
}

fn caskroom_artifacts_any(artifacts []CaskLoaderArtifact) json2.Any {
	mut result := []json2.Any{}
	for artifact in artifacts {
		result << json2.Any({
			artifact.kind: json2.Any(artifact.values.map(json2.Any(it)))
		})
	}
	return json2.Any(result)
}

fn caskroom_write_installed_json(path string, values map[string]json2.Any) ! {
	ruby.atomic_write_file(path, json2.encode(json2.Any(values), prettify: true))!
}

pub fn caskroom_migrate_caskfile_to_json(caskfile string,
	context CaskroomMigrationContext) !CaskroomMigrationResult {
	token := cask_loader_token_from_path(caskfile)
	installed_json_caskfile := cask_loader_installed_json_caskfile(caskfile)
	source_json := cask_loader_load_installed_json(caskfile)
	mut has_source_artifacts := false
	mut source_url_specs := map[string]string{}
	mut current_json := false
	if source := source_json {
		source_url_specs = source.url_specs.clone()
		// CaskLoader rejects malformed values; a parsed installed source therefore
		// contains only the three keys retained by the source migration format.
		decoded := json2.decode[json2.Any](source.raw) or { json2.Any(map[string]json2.Any{}) }
		if decoded is map[string]json2.Any {
			values := decoded.clone()
			mut artifacts_valid := true
			if raw_artifacts := values['artifacts'] {
				if raw_artifacts is []json2.Any {
					artifacts_valid = raw_artifacts.all(it is map[string]json2.Any)
				} else {
					artifacts_valid = false
				}
			}
			has_source_artifacts = source.has_artifacts && artifacts_valid
			current_json = values.keys().all(it in ['artifacts', 'url_specs', 'version']) && artifacts_valid
		}
	}
	receipt := cask_loader_load_installed_tab(CaskLoaderReference{
		kind: .text
		value: token
	}, context.load_context.lookup)
	mut cask := CaskLoaderCask{}
	mut has_cask := false
	if !context.force_source_load_failure {
		if installed_json_caskfile {
			if loaded := cask_loader_load_from_installed_caskfile(caskfile, CaskLoaderConfig{}, false, true, context.load_context) {
				cask = loaded
				has_cask = true
			}
		} else {
			if loaded := cask_loader_load_reference(CaskLoaderReference{
				kind: .path
				value: caskfile
			}, CaskLoaderConfig{}, false, context.load_context) {
				cask = loaded
				has_cask = true
			}
		}
	}
	if current_json && has_cask && (has_source_artifacts || (receipt.has_uninstall_artifacts && receipt.uninstall_artifacts.len > 0)) {
		return CaskroomMigrationResult{
			token: token
			source_path: caskfile
			json_path: caskfile
			skipped: true
			reason: 'current metadata'
		}
	}
	if (has_cask && cask.uninstall_flight_blocks) || receipt.uninstall_flight_blocks {
		return CaskroomMigrationResult{
			token: token
			source_path: caskfile
			skipped: true
			reason: 'uninstall flight blocks'
		}
	}
	if !has_cask {
		if source := source_json {
			if current_json {
				parts := os.norm_path(caskfile).split(os.path_separator)
				path_version := if parts.len >= 4 { parts[parts.len - 4] } else { source.version }
				mut resolved_artifacts := source.artifacts.clone()
				if !has_source_artifacts {
					resolved_artifacts = cask_loader_resolve_installed_artifacts(token, []CaskLoaderArtifact{}, false, if receipt.has_tap {
						receipt.tap
					} else {
						none
					}, true, context.load_context.lookup)
				}
				cask = CaskLoaderCask{
					token: token
					version: if source.version != '' { source.version } else { path_version }
					artifacts: resolved_artifacts
					url_specs: source.url_specs
				}
				has_cask = true
			}
		}
	}
	if !has_cask {
		if recovered := cask_loader_recover_from_installed_caskfile(caskfile, receipt, none, CaskLoaderConfig{}, context.load_context.lookup) {
			cask = recovered
			has_cask = true
		}
	}
	if !has_cask {
		return CaskroomMigrationResult{
			token: token
			source_path: caskfile
			skipped: true
			reason: 'unrecoverable metadata'
		}
	}
	version := cask.version
	artifacts := cask.artifacts.clone()
	if !has_source_artifacts && (!receipt.has_uninstall_artifacts || receipt.uninstall_artifacts.len == 0) && artifacts.len == 0 {
		return CaskroomMigrationResult{
			token: token
			source_path: caskfile
			skipped: true
			reason: 'artifacts unavailable'
		}
	}
	mut installed_json := map[string]json2.Any{}
	if cask.url_specs.len > 0 {
		mut specs := map[string]json2.Any{}
		for key, value in cask.url_specs {
			specs[key] = json2.Any(value)
		}
		installed_json['url_specs'] = json2.Any(specs)
	} else if source_url_specs.len > 0 {
		mut specs := map[string]json2.Any{}
		for key, value in source_url_specs {
			specs[key] = json2.Any(value)
		}
		installed_json['url_specs'] = json2.Any(specs)
	}
	if !receipt.has_uninstall_artifacts || receipt.uninstall_artifacts.len == 0 || !caskroom_artifacts_equivalent(receipt.uninstall_artifacts, artifacts) {
		installed_json['artifacts'] = caskroom_artifacts_any(artifacts)
	}
	parts := os.norm_path(caskfile).split(os.path_separator)
	path_version := if parts.len >= 4 { parts[parts.len - 4] } else { '' }
	if path_version != version {
		installed_json['version'] = json2.Any(version)
	}
	json_caskfile := os.join_path(os.dir(caskfile), '${token}.json')
	original_contents := if caskfile == json_caskfile {
		os.read_file(caskfile) or { '' }
	} else {
		''
	}
	caskroom_write_installed_json(json_caskfile, installed_json)!
	verified_artifacts := if context.has_verification_artifacts {
		context.verification_artifacts
	} else {
		artifacts
	}
	verified_version := if context.verification_version != '' {
		context.verification_version
	} else {
		version
	}
	if verified_version != version || !caskroom_artifacts_equivalent(verified_artifacts, artifacts) {
		if original_contents != '' {
			ruby.atomic_write_file(json_caskfile, original_contents)!
		} else if os.exists(json_caskfile) {
			os.rm(json_caskfile)!
		}
		return error('migrated Cask metadata differs from the original after preserving version and artifacts')
	}
	if caskfile != json_caskfile {
		os.rm(caskfile)!
	}
	return CaskroomMigrationResult{
		token: token
		source_path: caskfile
		json_path: json_caskfile
		migrated: true
	}
}

pub fn caskroom_cask_with_metadata(cask_path string) bool {
	patterns := [os.join_path(cask_path, '.metadata', '*', '*', 'Casks', '*.rb'),
		os.join_path(cask_path, '.metadata', '*', '*', 'Casks', '*.json')]
	return patterns.any((os.glob(it) or { []string{} }).len > 0)
}

pub fn caskroom_corrupt_cask_dirs(path string) []string {
	return caskroom_paths(path).filter(!caskroom_cask_with_metadata(it)).map(os.base(it))
}

pub fn caskroom_expected_group() string {
	$if linux {
		return expected_caskroom_group()
	}
	return 'admin'
}

pub fn caskroom_group_correct(path string, expected_group string) bool {
	mut group_id := -1
	$if linux {
		group_result := ruby.run_command('getent', ['group', expected_group])
		if group_result.exit_code == 0 {
			fields := group_result.output.trim_space().split(':')
			if fields.len >= 3 {
				group_id = fields[2].int()
			}
		}
	} $else $if macos {
		group_result := ruby.run_command('dscl', ['.', '-read', '/Groups/${expected_group}',
			'PrimaryGroupID'])
		if group_result.exit_code == 0 {
			fields := group_result.output.fields()
			if fields.len > 0 {
				group_id = fields[fields.len - 1].int()
			}
		}
	} $else {
		if expected_group == caskroom_expected_group() {
			group_result := ruby.run_command('id', ['-g'])
			if group_result.exit_code == 0 {
				group_id = group_result.output.trim_space().int()
			}
		}
	}
	if group_id < 0 {
		return false
	}
	stat := os.stat(path) or { return false }
	return int(stat.gid) == group_id
}

pub fn caskroom_chgrp_path(path string, sudo bool, expected_group string) ! {
	mut command := 'chgrp'
	mut arguments := [expected_group, path]
	if sudo {
		command = 'sudo'
		arguments = ['chgrp', expected_group, path]
	}
	result := ruby.run_command(command, arguments)
	if result.exit_code != 0 {
		return error(result.output.trim_space())
	}
}

pub fn caskroom_ensure_exists(path string, group_is_correct bool,
	stdout_tty bool, sudo_askpass bool, run_commands bool) !CaskroomEnsureResult {
	if os.exists(path) {
		return CaskroomEnsureResult{}
	}
	return caskroom_ensure_plan(path, os.is_writable(os.dir(path)), group_is_correct, stdout_tty, sudo_askpass, run_commands)
}

pub fn caskroom_ensure_plan(path string, parent_writable bool, group_is_correct bool,
	stdout_tty bool, sudo_askpass bool, run_commands bool) !CaskroomEnsureResult {
	sudo := !parent_writable
	mut output := ''
	if sudo && !sudo_askpass && stdout_tty {
		output = "==> Creating Caskroom directory: ${path}\nWe'll set permissions properly so we won't need sudo in the future.\n"
	}
	mut commands := [
		['mkdir', '-p', path],
		['chmod', 'g+rwx', path],
		['chown', os.getuid().str(), path],
	]
	if !group_is_correct {
		commands << ['chgrp', caskroom_expected_group(), path]
	}
	if run_commands {
		os.mkdir_all(path)!
		os.chmod(path, int(os.inode(path).bitmask() | os.s_iwgrp | os.s_ixgrp | os.s_irgrp))!
		if !group_is_correct {
			caskroom_chgrp_path(path, sudo, caskroom_expected_group())!
		}
	}
	return CaskroomEnsureResult{
		created: true
		sudo: sudo
		changed_group: !group_is_correct
		commands: commands
		output: output
	}
}

pub fn caskroom_casks(path string, context CaskLoaderLoadContext) []CaskLoaderCask {
	mut tokens := caskroom_tokens(path)
	tokens.sort()
	mut casks := []CaskLoaderCask{}
	mut full_names := map[string]bool{}
	for token in tokens {
		mut cask := cask_loader_load_prefer_installed(token, CaskLoaderConfig{}, false, context) or {
			installed_path := caskroom_installed_caskfile(path, token, []string{}) or { continue }
			cask_loader_load_from_installed_caskfile(installed_path, CaskLoaderConfig{}, false, false, context) or { continue }
		}
		if cask.token == '' {
			continue
		}
		full_name := if cask.has_tap { '${cask.tap.name}/${cask.token}' } else { cask.token }
		if full_name in full_names {
			continue
		}
		full_names[full_name] = true
		casks << cask
	}
	return casks
}

module tap

import os

pub fn core_tap_uninstall(no_install_from_api bool) ! {
	if no_install_from_api {
		return error('Tap#uninstall is not available for CoreTap')
	}
}

pub fn core_tap_formula_names(files []string) []string {
	return files.map(os.base(it).trim_string_right('.rb'))
}

pub fn core_tap_alias_table(files []string) map[string]string {
	mut table := map[string]string{}
	for file in files {
		table[os.base(file)] = os.base(os.real_path(file)).trim_string_right('.rb')
	}
	return table
}

pub struct CoreTapState {
pub:
	user       string
	repository string
	name       string
}

pub struct CoreTapInstallPlan {
pub:
	remote             string
	clone_target       string
	custom_remote      bool
	quiet              bool
	force              bool
	configured_message string
}

pub struct CoreTapPathPlan {
pub:
	path           string
	ensure_install bool
}

pub struct CoreTapStringListPlan {
pub:
	ensure_install bool
	values         []string
}

pub struct CoreTapStringMapPlan {
pub:
	ensure_install bool
	values         map[string]string
}

pub struct CoreTapStringMatrixPlan {
pub:
	ensure_install bool
	values         [][]string
}

pub fn new_core_tap_state() CoreTapState {
	return CoreTapState{ user: 'Homebrew', repository: 'core', name: 'homebrew/core' }
}

pub fn core_tap_should_install(homebrew_tests bool, no_install_from_api bool,
	automatically_set_no_install_from_api bool, installed bool) bool {
	return !homebrew_tests && abstract_core_tap_should_install(no_install_from_api, automatically_set_no_install_from_api, installed)
}

pub fn core_tap_remote(no_install_from_api bool, inherited_remote ?string,
	core_git_remote string) ?string {
	return if no_install_from_api { inherited_remote } else { core_git_remote }
}

pub fn core_tap_canonical_remote(remote ?string, core_git_remote string,
	same_remote bool) bool {
	return remote == none || same_remote
}

pub fn core_tap_install_plan(core_git_remote string, clone_target ?string,
	default_remote string, quiet bool, custom_remote bool, force bool) !CoreTapInstallPlan {
	requested := clone_target or { core_git_remote }
	if requested != core_git_remote {
		return error('TapCoreRemoteMismatchError: homebrew/core: ${core_git_remote} != ${requested}')
	}
	return CoreTapInstallPlan{
		remote: core_git_remote
		clone_target: core_git_remote
		custom_remote: custom_remote
		quiet: quiet
		force: force
		configured_message: if core_git_remote != default_remote {
			'HOMEBREW_CORE_GIT_REMOTE set: using ${core_git_remote} as the Homebrew/homebrew-core Git remote.'
		} else {
			''
		}
	}
}

pub fn core_tap_linuxbrew_core(remote_repository ?string) bool {
	remote := remote_repository or { return false }
	return remote.ends_with('/linuxbrew-core') || remote == 'Linuxbrew/homebrew-core'
}

pub fn core_tap_formula_dir(path string, should_install bool) CoreTapPathPlan {
	return CoreTapPathPlan{ path: os.join_path(path, 'Formula'), ensure_install: should_install }
}

pub fn core_tap_new_formula_subdirectory(name string) string {
	if name.starts_with('lib') {
		return 'lib'
	}
	return if name == '' { '' } else { name[..1] }
}

pub fn core_tap_new_formula_path(formula_dir string, name string) string {
	subdirectory := core_tap_new_formula_subdirectory(name)
	if os.is_dir(os.join_path(formula_dir, subdirectory)) {
		return os.join_path(formula_dir, subdirectory, '${name.to_lower()}.rb')
	}
	return os.join_path(formula_dir, '${name.to_lower()}.rb')
}

pub fn core_tap_select_map(no_install_from_api bool, local map[string]string,
	api map[string]string) map[string]string {
	return if no_install_from_api { local } else { api }
}

pub fn core_tap_alias_file_to_name(file string) string {
	return os.base(file)
}

pub fn core_tap_formula_files_by_name(formula_dir string, formula_names []string) map[string]string {
	mut files := map[string]string{}
	for name in formula_names {
		new_path := os.join_path(formula_dir, core_tap_new_formula_subdirectory(name), '${name.to_lower()}.rb')
		existing := files[name] or { '' }
		if existing == '' || existing.len < new_path.len {
			files[name] = new_path
		}
	}
	return files
}

pub fn core_tap_formula_files(no_install_from_api bool, local_files []string,
	formula_dir string, api_names []string) []string {
	if no_install_from_api {
		return local_files
	}
	by_name := core_tap_formula_files_by_name(formula_dir, api_names)
	return api_names.map(by_name[it])
}

// Translated from Homebrew/brew `tap/core_tap.rb`.

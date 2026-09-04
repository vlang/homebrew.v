module homebrew

// Translated from Homebrew/brew `caveats.rb`.
pub struct CaveatShadow {
pub:
	name        string
	path        string
	sibling_keg string
}

pub struct CaveatCompletion {
pub:
	shell      string
	completion bool
	functions  bool
}

pub struct CaveatsService {
pub:
	defined          bool
	installed        bool
	plist_installed  bool
	command          bool
	manual_command   string
	requires_root    bool
	running          bool
	systemctl        bool = true
	launchctl        bool = true
	tmux_paste_fails bool
}

pub struct CaveatsFormula {
pub:
	name                      string = 'formula_name'
	full_name                 string = 'formula_name'
	prefix                    string = '/opt/homebrew/Cellar/formula_name/1.0'
	opt_prefix                string = '/opt/homebrew/opt/formula_name'
	homebrew_prefix           string = '/opt/homebrew'
	cellar                    string = '/opt/homebrew/Cellar'
	custom_caveats            string
	keg_only_reason           string
	linked                    bool
	bin_directory             bool
	sbin_directory            bool
	lib_directory             bool
	include_directory         bool
	lib_pkgconfig_directory   bool
	share_pkgconfig_directory bool
	lib_cmake_directory       bool
	share_cmake_directory     bool
	pkgconf_available         bool
	cmake_available           bool
	any_version_installed     bool
	no_path_shadow_check      bool
	no_env_hints              bool
	shadows                   []CaveatShadow
	unversioned_formula_name  string
	versioned_formulae_names  []string
	keg_available             bool = true
	preferred_shell           string
	available_shells          []string = ['bash', 'zsh', 'fish', 'pwsh']
	completions               []CaveatCompletion
	elisp_installed           bool
	service                   CaveatsService
}

pub struct Caveats {
pub:
	formula CaveatsFormula
}

pub fn new_caveats(formula CaveatsFormula) Caveats {
	return Caveats{
		formula: formula
	}
}

pub fn (c Caveats) text() string {
	mut parts := []string{}
	if c.formula.custom_caveats != '' {
		parts << '${c.formula.custom_caveats.trim_string_right('\n')}\n'
	}
	if value := c.keg_only_text(false) {
		parts << value
	}
	if value := c.shadowed_path_text() {
		parts << value
	}
	if value := c.service_caveats() {
		parts << value
	}
	return parts.join('\n')
}

pub fn (c Caveats) empty() bool {
	return c.text().trim_space() == '' && c.completions_and_elisp().len == 0
}

pub fn (c Caveats) completions_and_elisp() []string {
	valid := ['bash', 'zsh', 'fish', 'pwsh']
	shells := if c.formula.preferred_shell in valid {
		[c.formula.preferred_shell]
	} else {
		valid
	}
	mut output := []string{}
	for shell in shells {
		if text := c.function_completion_caveats(shell) {
			output << text
		}
	}
	if text := c.elisp_caveats() {
		output << text
	}
	return output
}

fn caveats_export(name string, value string) string {
	return 'export ${name}="${value}"'
}

pub fn (c Caveats) keg_only_text(skip_reason bool) ?string {
	f := c.formula
	if f.keg_only_reason == '' || f.linked {
		return none
	}
	mut text := if skip_reason {
		''
	} else {
		'${f.name} is keg-only, which means it was not symlinked into ${f.homebrew_prefix},\nbecause ${f.keg_only_reason.trim_string_right('\n')}.\n'
	}
	if f.bin_directory || f.sbin_directory {
		text += '\nIf you need to have ${f.name} first in your PATH, run:\n'
		if f.bin_directory {
			text += '  export PATH="${f.opt_prefix}/bin:\$PATH"\n'
		}
		if f.sbin_directory {
			text += '  export PATH="${f.opt_prefix}/sbin:\$PATH"\n'
		}
	}
	if f.lib_directory || f.include_directory {
		text += '\nFor compilers to find ${f.name} you may need to set:\n'
		if f.lib_directory {
			text += '  ${caveats_export('LDFLAGS', '-L\${f.opt_prefix}/lib')}\n'
		}
		if f.include_directory {
			text += '  ${caveats_export('CPPFLAGS', '-I\${f.opt_prefix}/include')}\n'
		}
		if f.pkgconf_available && (f.lib_pkgconfig_directory || f.share_pkgconfig_directory) {
			text += '\nFor pkgconf to find ${f.name} you may need to set:\n'
			if f.lib_pkgconfig_directory {
				text += '  ${caveats_export('PKG_CONFIG_PATH', '\${f.opt_prefix}/lib/pkgconfig')}\n'
			}
			if f.share_pkgconfig_directory {
				text += '  ${caveats_export('PKG_CONFIG_PATH', '\${f.opt_prefix}/share/pkgconfig')}\n'
			}
		}
		if f.cmake_available && (f.lib_cmake_directory || f.share_cmake_directory) {
			text += '\nFor cmake to find ${f.name} you may need to set:\n  ${caveats_export('CMAKE_PREFIX_PATH', f.opt_prefix)}\n'
		}
	}
	if !text.ends_with('\n') {
		text += '\n'
	}
	return text
}

pub fn (c Caveats) sibling_keg_name(shadower CaveatShadow) ?string {
	if shadower.sibling_keg == '' || shadower.sibling_keg == c.formula.name {
		return none
	}
	family := [c.formula.unversioned_formula_name, c.formula.name].filter(it != '')
	mut accepted := family.clone()
	accepted << c.formula.versioned_formulae_names
	if shadower.sibling_keg in accepted {
		return shadower.sibling_keg
	}
	return none
}

pub fn (c Caveats) shadowed_executables() []CaveatShadow {
	return c.formula.shadows.clone()
}

pub fn (c Caveats) shadowed_path_text() ?string {
	f := c.formula
	if f.no_path_shadow_check || !f.any_version_installed {
		return none
	}
	mut shadows := c.shadowed_executables()
	if f.keg_only_reason != '' && !f.linked {
		shadows = shadows.filter(c.sibling_keg_name(it) != none)
	}
	if shadows.len == 0 {
		return none
	}
	shadows.sort(a.name < b.name)
	mut sibling := []CaveatShadow{}
	mut external := []CaveatShadow{}
	for shadow in shadows {
		if c.sibling_keg_name(shadow) != none {
			sibling << shadow
		} else {
			external << shadow
		}
	}
	mut blocks := []string{}
	if external.len > 0 {
		lines := external.map('  ${it.name} (shadowed by ${it.path})')
		blocks << 'The following ${f.name} executables are shadowed by other commands earlier in your PATH:\n${lines.join('\n')}\nRunning these by name will not invoke the version provided by Homebrew.\n'
	}
	if sibling.len > 0 {
		lines := sibling.map('  ${it.name} (shadowed by ${it.path} from ${it.sibling_keg})')
		blocks << 'The following ${f.name} executables are shadowed by other linked Homebrew commands:\n${lines.join('\n')}\nRunning these by name will not invoke the version provided by this formula.\nRun `brew link ${f.name}` to switch the active version to this keg.\n'
	}
	mut text := blocks.join('\n')
	if !f.no_env_hints {
		text += 'Disable this behaviour by setting `HOMEBREW_NO_PATH_SHADOW_CHECK=1`.\n'
		text += 'Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).\n'
	}
	return text
}

pub fn (c Caveats) keg() bool {
	return c.formula.keg_available
}

pub fn (c Caveats) function_completion_caveats(shell string) ?string {
	if !c.keg() || shell !in c.formula.available_shells {
		return none
	}
	completion := c.formula.completions.filter(it.shell == shell)
	if completion.len == 0 || (!completion[0].completion && !completion[0].functions) {
		return none
	}
	entry := completion[0]
	root := if c.formula.keg_only_reason != '' {
		c.formula.opt_prefix
	} else {
		c.formula.homebrew_prefix
	}
	mut installed := []string{}
	if entry.completion {
		installed << 'completions'
	}
	if entry.functions {
		installed << 'functions'
	}
	return match shell {
		'bash' { 'Bash completion has been installed to:\n  ${root}/etc/bash_completion.d\n' }
		'fish' {
			mut text := 'fish ${installed.join(' and ')} have been installed to:'
			if entry.completion {
				text += '\n  ${root}/share/fish/vendor_completions.d'
			}
			if entry.functions {
				text += '\n  ${root}/share/fish/vendor_functions.d'
			}
			text
		}
		'zsh' {
			'zsh ${installed.join(' and ')} have been installed to:\n  ${root}/share/zsh/site-functions\n'
		}
		'pwsh' {
			'PowerShell completion has been installed to:\n  ${root}/share/pwsh/completions\n'
		}
		else {
			return none
		}
	}
}

pub fn (c Caveats) elisp_caveats() ?string {
	if c.formula.keg_only_reason != '' || !c.keg() || !c.formula.elisp_installed {
		return none
	}
	return 'Emacs Lisp files have been installed to:\n  ${c.formula.homebrew_prefix}/share/emacs/site-lisp/${c.formula.name}\n'
}

pub fn (c Caveats) service_caveats() ?string {
	f := c.formula
	s := f.service
	if !s.defined && !s.installed && !s.plist_installed {
		return none
	}
	if s.defined && !s.command && !s.installed {
		return none
	}
	if !s.systemctl && !s.launchctl && s.command {
		return 'Warning: ${f.name} provides a service which can only be used on macOS or systemd!\nYou can manually execute the service instead with:\n  ${s.manual_command}\n'
	}
	mut lines := []string{}
	if s.running {
		lines << 'To restart ${f.full_name} after an upgrade:'
		lines << '  ${if s.requires_root { 'sudo ' } else { '' }}brew services restart ${f.full_name}'
	} else if s.requires_root {
		lines << 'To start ${f.full_name} now and restart at startup:'
		lines << '  sudo brew services start ${f.full_name}'
	} else {
		lines << 'To start ${f.full_name} now and restart at login:'
		lines << '  brew services start ${f.full_name}'
	}
	if s.command {
		lines << "Or, if you don't want/need a background service you can just run:"
		lines << '  ${s.manual_command}'
	}
	if s.tmux_paste_fails {
		lines << ''
		lines << 'WARNING: brew services will fail when run under tmux.'
	}
	return if lines.len > 0 { '${lines.join('\n')}\n' } else { none }
}

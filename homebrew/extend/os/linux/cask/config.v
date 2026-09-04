module cask

// Translated from Homebrew/brew `extend/os/linux/cask/config.rb`.
pub struct LinuxCaskDefaults {
pub:
	languages   []string
	directories map[string]string
}

pub fn linux_cask_defaults(languages []string, xdg_data_home string) LinuxCaskDefaults {
	data_home := if xdg_data_home == '' { '~/.local/share' } else { xdg_data_home }
	return LinuxCaskDefaults{
		languages: languages.clone()
		directories: {
			'vst_plugindir':  '~/.vst'
			'vst3_plugindir': '~/.vst3'
			'fontdir':        '${data_home}/fonts'
			'appdir':         '~/.config/apps'
			'appimagedir':    '~/Applications'
		}
	}
}

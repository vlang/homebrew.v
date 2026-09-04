module cask

// Translated from Homebrew/brew `extend/os/mac/cask/config.rb`.
pub struct MacCaskDefaults {
pub:
	languages   []string
	directories map[string]string
}

pub fn mac_cask_defaults(languages []string) MacCaskDefaults {
	return MacCaskDefaults{
		languages: languages.clone()
		directories: {
			'appdir':               '/Applications'
			'appimagedir':          '~/Applications'
			'keyboard_layoutdir':   '/Library/Keyboard Layouts'
			'colorpickerdir':       '~/Library/ColorPickers'
			'prefpanedir':          '~/Library/PreferencePanes'
			'qlplugindir':          '~/Library/QuickLook'
			'mdimporterdir':        '~/Library/Spotlight'
			'dictionarydir':        '~/Library/Dictionaries'
			'fontdir':              '~/Library/Fonts'
			'servicedir':           '~/Library/Services'
			'input_methoddir':      '~/Library/Input Methods'
			'internet_plugindir':   '~/Library/Internet Plug-Ins'
			'audio_unit_plugindir': '~/Library/Audio/Plug-Ins/Components'
			'vst_plugindir':        '~/Library/Audio/Plug-Ins/VST'
			'vst3_plugindir':       '~/Library/Audio/Plug-Ins/VST3'
			'screen_saverdir':      '~/Library/Screen Savers'
		}
	}
}

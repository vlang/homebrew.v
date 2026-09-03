module cask

// Translated from Homebrew/brew `extend/os/mac/cask/config.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `defaults` at line 12.
pub fn ruby_config_l12_d1_defaults(languages []string) MacCaskDefaults {
	return mac_cask_defaults(languages)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module Cask
// 9:       module Config
// 10:         module ClassMethods
// 11:           T::Sig::WithoutRuntime.sig { returns(::Cask::Config::ConfigHash) }
// 12:           def defaults
// 13:             {
// 14:               languages: LazyObject.new { Mac.languages },
// 15:             }.merge(::Cask::Config::DEFAULT_DIRS).freeze
// 16:           end
// 17:         end
// 18:       end
// 19:     end
// 20:   end
// 21: end
// 22:
// 23: Cask::Config.singleton_class.prepend(OS::Mac::Cask::Config::ClassMethods)

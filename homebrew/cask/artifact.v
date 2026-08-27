module cask

// Translated from Homebrew/brew `cask/artifact.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/app"
// 5: require "cask/artifact/appimage"
// 6: require "cask/artifact/artifact" # generic 'artifact' stanza
// 7: require "cask/artifact/audio_unit_plugin"
// 8: require "cask/artifact/binary"
// 9: require "cask/artifact/colorpicker"
// 10: require "cask/artifact/command_wrapper"
// 11: require "cask/artifact/dictionary"
// 12: require "cask/artifact/install_steps"
// 13: require "cask/artifact/font"
// 14: require "cask/artifact/generated_script"
// 15: require "cask/artifact/input_method"
// 16: require "cask/artifact/installer"
// 17: require "cask/artifact/internet_plugin"
// 18: require "cask/artifact/keyboard_layout"
// 19: require "cask/artifact/manpage"
// 20: require "cask/artifact/vst_plugin"
// 21: require "cask/artifact/vst3_plugin"
// 22: require "cask/artifact/pkg"
// 23: require "cask/artifact/postflight_block"
// 24: require "cask/artifact/preflight_block"
// 25: require "cask/artifact/prefpane"
// 26: require "cask/artifact/qlplugin"
// 27: require "cask/artifact/mdimporter"
// 28: require "cask/artifact/screen_saver"
// 29: require "cask/artifact/bashcompletion"
// 30: require "cask/artifact/fishcompletion"
// 31: require "cask/artifact/generated_completion"
// 32: require "cask/artifact/zshcompletion"
// 33: require "cask/artifact/service"
// 34: require "cask/artifact/stage_only"
// 35: require "cask/artifact/suite"
// 36: require "cask/artifact/uninstall"
// 37: require "cask/artifact/zap"

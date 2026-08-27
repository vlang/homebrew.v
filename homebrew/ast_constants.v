module homebrew

// Translated from Homebrew/brew `ast_constants.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "macos_version"
// 5:
// 6: FORMULA_COMPONENT_PRECEDENCE_LIST = T.let([
// 7:   [{ name: :include,   type: :method_call }],
// 8:   [{ name: :desc,      type: :method_call }],
// 9:   [{ name: :homepage,  type: :method_call }],
// 10:   [{ name: :url,       type: :method_call }],
// 11:   [{ name: :mirror,    type: :method_call }],
// 12:   [{ name: :version,   type: :method_call }],
// 13:   [{ name: :sha256,    type: :method_call }],
// 14:   [{ name: :license, type: :method_call }],
// 15:   [{ name: :revision, type: :method_call }],
// 16:   [{ name: :version_scheme, type: :method_call }],
// 17:   [{ name: :compatibility_version, type: :method_call }],
// 18:   [{ name: :head,      type: :method_call }],
// 19:   [{ name: :stable,    type: :block_call }],
// 20:   [{ name: :livecheck, type: :block_call }],
// 21:   [{ name: :no_autobump!, type: :method_call }],
// 22:   [{ name: :bottle, type: :block_call }],
// 23:   [{ name: :pour_bottle?, type: :block_call }],
// 24:   [{ name: :head,      type: :block_call }],
// 25:   [{ name: :bottle,    type: :method_call }],
// 26:   [{ name: :keg_only,  type: :method_call }],
// 27:   [{ name: :option,    type: :method_call }],
// 28:   [{ name: :deprecated_option, type: :method_call }],
// 29:   [{ name: :deprecate!, type: :method_call }],
// 30:   [{ name: :disable!, type: :method_call }],
// 31:   [{ name: :depends_on, type: :method_call }],
// 32:   [{ name: :uses_from_macos, type: :method_call }],
// 33:   [{ name: :on_macos, type: :block_call }],
// 34:   *MacOSVersion::SYMBOLS.keys.map do |os_name|
// 35:     [{ name: :"on_#{os_name}", type: :block_call }]
// 36:   end,
// 37:   [{ name: :on_system, type: :block_call }],
// 38:   [{ name: :on_linux, type: :block_call }],
// 39:   [{ name: :on_arm, type: :block_call }],
// 40:   [{ name: :on_intel, type: :block_call }],
// 41:   [{ name: :conflicts_with, type: :method_call }],
// 42:   [{ name: :preserve_rpath, type: :method_call }],
// 43:   [{ name: :skip_clean, type: :method_call }],
// 44:   [{ name: :cxxstdlib_check, type: :method_call }],
// 45:   [{ name: :link_overwrite, type: :method_call }],
// 46:   [{ name: :fails_with, type: :method_call }, { name: :fails_with, type: :block_call }],
// 47:   [{ name: :pypi_packages, type: :method_call }],
// 48:   [{ name: :resource, type: :block_call }],
// 49:   [{ name: :patch, type: :method_call }, { name: :patch, type: :block_call }],
// 50:   [{ name: :needs, type: :method_call }],
// 51:   [{ name: :allow_network_access!, type: :method_call }],
// 52:   [{ name: :deny_network_access!, type: :method_call }],
// 53:   [{ name: :install, type: :method_definition }],
// 54:   [{ name: :post_install_steps, type: :block_call }],
// 55:   [{ name: :post_install, type: :method_definition }],
// 56:   [{ name: :caveats, type: :method_definition }],
// 57:   [{ name: :plist_options, type: :method_call }, { name: :plist, type: :method_definition }],
// 58:   [{ name: :test, type: :block_call }],
// 59: ].freeze, T::Array[T::Array[{ name: Symbol, type: Symbol }]])

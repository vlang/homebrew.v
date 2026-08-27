module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/edit.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 28.
pub fn ruby_edit_l28_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `core_formula_path?(path)` at line 99.
pub fn ruby_edit_l99_d2_core_formula_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('core_formula_path?', ...args)
}

// Ruby method `core_cask_path?(path)` at line 104.
pub fn ruby_edit_l104_d3_core_cask_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('core_cask_path?', ...args)
}

// Ruby method `core_formula_tap?(path)` at line 109.
pub fn ruby_edit_l109_d4_core_formula_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('core_formula_tap?', ...args)
}

// Ruby method `core_cask_tap?(path)` at line 114.
pub fn ruby_edit_l114_d5_core_cask_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('core_cask_tap?', ...args)
}

// Ruby method `raise_with_message!(path, cask)` at line 119.
pub fn ruby_edit_l119_d6_raise_with_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raise_with_message!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class Edit < AbstractCommand
// 10:       cmd_args do
// 11:         description <<~EOS
// 12:           Open a <formula>, <cask> or <tap> in the editor set by `$EDITOR` or `$HOMEBREW_EDITOR`,
// 13:           or open the Homebrew repository for editing if no argument is provided.
// 14:         EOS
// 15:         switch "--formula", "--formulae",
// 16:                description: "Treat all named arguments as formulae."
// 17:         switch "--cask", "--casks",
// 18:                description: "Treat all named arguments as casks."
// 19:         switch "--print-path",
// 20:                description: "Print the file path to be edited, without opening an editor."
// 21:
// 22:         conflicts "--formula", "--cask"
// 23:
// 24:         named_args [:formula, :cask, :tap], without_api: true
// 25:       end
// 26:
// 27:       sig { override.void }
// 28:       def run
// 29:         ENV["COLORTERM"] = ENV.fetch("HOMEBREW_COLORTERM", nil)
// 30:         # Recover $TMPDIR for emacsclient
// 31:         ENV["TMPDIR"] = ENV.fetch("HOMEBREW_TMPDIR", nil)
// 32:
// 33:         # VS Code remote development relies on this env var to work
// 34:         if which_editor(silent: true) == "code" && ENV.include?("HOMEBREW_VSCODE_IPC_HOOK_CLI")
// 35:           ENV["VSCODE_IPC_HOOK_CLI"] = ENV.fetch("HOMEBREW_VSCODE_IPC_HOOK_CLI", nil)
// 36:         end
// 37:
// 38:         unless (HOMEBREW_REPOSITORY/".git").directory?
// 39:           odie <<~EOS
// 40:             Changes will be lost!
// 41:             The first time you `brew update`, all local changes will be lost; you should
// 42:             thus `brew update` before you `brew edit`!
// 43:           EOS
// 44:         end
// 45:
// 46:         paths = if args.named.empty?
// 47:           # Sublime requires opting into the project editing path,
// 48:           # as opposed to VS Code which will infer from the .vscode path
// 49:           if which_editor(silent: true) == "subl"
// 50:             ["--project", HOMEBREW_REPOSITORY/".sublime/homebrew.sublime-project"]
// 51:           else
// 52:             # If no formulae are listed, open the project root in an editor.
// 53:             [HOMEBREW_REPOSITORY]
// 54:           end
// 55:         else
// 56:           args.named.each do |name|
// 57:             if !args.cask? && !CoreTap.instance.installed? &&
// 58:                Homebrew::API.formula_name?(name.delete_prefix("#{CoreTap.instance.name}/"))
// 59:               CoreTap.instance.install(force: true)
// 60:             elsif !args.formula? && !CoreCaskTap.instance.installed? &&
// 61:                   Homebrew::API.cask_token?(name.delete_prefix("#{CoreCaskTap.instance.name}/"))
// 62:               CoreCaskTap.instance.install(force: true)
// 63:             end
// 64:           end
// 65:
// 66:           expanded_paths = args.named.to_paths
// 67:           expanded_paths.each do |path|
// 68:             raise_with_message!(path, args.cask?) unless path.exist?
// 69:           end
// 70:           expanded_paths
// 71:         end
// 72:
// 73:         if args.print_path?
// 74:           paths.each { puts it }
// 75:           return
// 76:         end
// 77:
// 78:         exec_editor(*paths)
// 79:
// 80:         is_formula = T.let(false, T::Boolean)
// 81:         if !Homebrew::EnvConfig.no_env_hints? && paths.any? do |path|
// 82:              next if path == "--project"
// 83:
// 84:              is_formula = core_formula_path?(path)
// 85:              is_formula || core_cask_path?(path) || core_formula_tap?(path) || core_cask_tap?(path)
// 86:            end
// 87:           from_source = " --build-from-source" if is_formula
// 88:           no_api = "HOMEBREW_NO_INSTALL_FROM_API=1 " unless Homebrew::EnvConfig.no_install_from_api?
// 89:           puts <<~EOS
// 90:             To test your local edits, run:
// 91:               #{no_api}brew install#{from_source} --verbose --debug #{args.named.join(" ")}
// 92:           EOS
// 93:         end
// 94:       end
// 95:
// 96:       private
// 97:
// 98:       sig { params(path: Pathname).returns(T::Boolean) }
// 99:       def core_formula_path?(path)
// 100:         path.fnmatch?("**/homebrew-core/Formula/**.rb", File::FNM_DOTMATCH)
// 101:       end
// 102:
// 103:       sig { params(path: Pathname).returns(T::Boolean) }
// 104:       def core_cask_path?(path)
// 105:         path.fnmatch?("**/homebrew-cask/Casks/**.rb", File::FNM_DOTMATCH)
// 106:       end
// 107:
// 108:       sig { params(path: Pathname).returns(T::Boolean) }
// 109:       def core_formula_tap?(path)
// 110:         path == CoreTap.instance.path
// 111:       end
// 112:
// 113:       sig { params(path: Pathname).returns(T::Boolean) }
// 114:       def core_cask_tap?(path)
// 115:         path == CoreCaskTap.instance.path
// 116:       end
// 117:
// 118:       sig { params(path: Pathname, cask: T::Boolean).returns(T.noreturn) }
// 119:       def raise_with_message!(path, cask)
// 120:         name = path.basename(".rb").to_s
// 121:
// 122:         if (tap_match = Regexp.new("#{HOMEBREW_TAP_DIR_REGEX.source}$").match(path.to_s))
// 123:           raise TapUnavailableError, CoreTap.instance.name if core_formula_tap?(path)
// 124:           raise TapUnavailableError, CoreCaskTap.instance.name if core_cask_tap?(path)
// 125:
// 126:           raise TapUnavailableError, "#{tap_match[:user]}/#{tap_match[:repo]}"
// 127:         elsif cask || core_cask_path?(path)
// 128:           if !CoreCaskTap.instance.installed? && Homebrew::API.cask_token?(name)
// 129:             command = "brew tap --force #{CoreCaskTap.instance.name}"
// 130:             action = "tap #{CoreCaskTap.instance.name}"
// 131:           else
// 132:             command = "brew create --cask --set-name #{name} $URL"
// 133:             action = "create a new cask"
// 134:           end
// 135:         elsif core_formula_path?(path) &&
// 136:               !CoreTap.instance.installed? &&
// 137:               Homebrew::API.formula_name?(name)
// 138:           command = "brew tap --force #{CoreTap.instance.name}"
// 139:           action = "tap #{CoreTap.instance.name}"
// 140:         else
// 141:           command = "brew create --set-name #{name} $URL"
// 142:           action = "create a new formula"
// 143:         end
// 144:
// 145:         raise UsageError, <<~EOS
// 146:           #{name} doesn't exist on disk.
// 147:           Run #{Formatter.identifier(command)} to #{action}!
// 148:         EOS
// 149:       end
// 150:     end
// 151:   end
// 152: end

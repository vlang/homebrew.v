module cmd

import brew_runtime

// Translated from Homebrew/brew `test/cmd/exec_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:formula_name) { "test-executable" }` at line 11.
pub fn ruby_exec_spec_l11_d1_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_name', ...args)
}

// Ruby let `let(:executable_name) { "test-executable-tool" }` at line 12.
pub fn ruby_exec_spec_l12_d2_executable_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('executable_name', ...args)
}

// Ruby let `let(:shell_cellar) { HOMEBREW_CELLAR }` at line 13.
pub fn ruby_exec_spec_l13_d3_shell_cellar(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shell_cellar', ...args)
}

// Ruby let `let(:db) { HOMEBREW_CACHE/"api/internal/executables.txt" }` at line 14.
pub fn ruby_exec_spec_l14_d4_db(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('db', ...args)
}

// Ruby let `let(:active_executable) { shell_cellar/"#{formula_name}/2.10/bin/#{executable_name}" }` at line 15.
pub fn ruby_exec_spec_l15_d5_active_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('active_executable', ...args)
}

// Ruby let `let(:env_formula_name) { "test-env" }` at line 16.
pub fn ruby_exec_spec_l16_d6_env_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('env_formula_name', ...args)
}

// Ruby let `let(:env_executable_name) { "test-env-tool" }` at line 17.
pub fn ruby_exec_spec_l17_d7_env_executable_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('env_executable_name', ...args)
}

// Ruby let `let(:env_executable) { shell_cellar/"#{env_formula_name}/1.0/bin/#{env_executable_name}" }` at line 18.
pub fn ruby_exec_spec_l18_d8_env_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('env_executable', ...args)
}

// Ruby let `let(:installable_formula_name) { "test-installable" }` at line 19.
pub fn ruby_exec_spec_l19_d9_installable_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installable_formula_name', ...args)
}

// Ruby let `let(:installable_executable_name) { "test-installable-tool" }` at line 20.
pub fn ruby_exec_spec_l20_d10_installable_executable_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installable_executable_name', ...args)
}

// Ruby let `let(:brew_wrapper) { HOMEBREW_TEMP/"brew-exec-wrapper/brew" }` at line 21.
pub fn ruby_exec_spec_l21_d11_brew_wrapper(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brew_wrapper', ...args)
}

// Ruby let `let(:inline_script) { HOMEBREW_TEMP/"brew-exec-wrapper/script.sh" }` at line 22.
pub fn ruby_exec_spec_l22_d12_inline_script(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('inline_script', ...args)
}

// Ruby let `let(:brew_sh_env) do` at line 23.
pub fn ruby_exec_spec_l23_d13_brew_sh_env(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brew_sh_env', ...args)
}

// Ruby it `it "runs commands in formula environments and supports the x alias", :aggregate_failures, :integration_test do` at line 110.
pub fn ruby_exec_spec_l110_d14_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runs', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/exec"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::Exec do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   describe "exec" do
// 11:     let(:formula_name) { "test-executable" }
// 12:     let(:executable_name) { "test-executable-tool" }
// 13:     let(:shell_cellar) { HOMEBREW_CELLAR }
// 14:     let(:db) { HOMEBREW_CACHE/"api/internal/executables.txt" }
// 15:     let(:active_executable) { shell_cellar/"#{formula_name}/2.10/bin/#{executable_name}" }
// 16:     let(:env_formula_name) { "test-env" }
// 17:     let(:env_executable_name) { "test-env-tool" }
// 18:     let(:env_executable) { shell_cellar/"#{env_formula_name}/1.0/bin/#{env_executable_name}" }
// 19:     let(:installable_formula_name) { "test-installable" }
// 20:     let(:installable_executable_name) { "test-installable-tool" }
// 21:     let(:brew_wrapper) { HOMEBREW_TEMP/"brew-exec-wrapper/brew" }
// 22:     let(:inline_script) { HOMEBREW_TEMP/"brew-exec-wrapper/script.sh" }
// 23:     let(:brew_sh_env) do
// 24:       {
// 25:         "HOMEBREW_BREW_SH"               => (HOMEBREW_PREFIX/"bin/brew").to_s,
// 26:         "HOMEBREW_FORCE_BREW_WRAPPER"    => brew_wrapper.to_s,
// 27:         "HOMEBREW_NO_FORCE_BREW_WRAPPER" => "1",
// 28:         "HOMEBREW_TEMP"                  => HOMEBREW_TEMP.to_s,
// 29:         "HOMEBREW_COLOR"                 => nil,
// 30:         "GITHUB_ACTIONS"                 => nil,
// 31:       }
// 32:     end
// 33:
// 34:     before do
// 35:       FileUtils.ln_sf HOMEBREW_LIBRARY_PATH.parent.parent/"bin/brew", HOMEBREW_PREFIX/"bin/brew"
// 36:
// 37:       db.dirname.mkpath
// 38:       db.write(<<~EOS)
// 39:         test-uninstalled(1.0.0):#{executable_name}
// 40:         #{formula_name}(1.0.0):#{executable_name}
// 41:         #{installable_formula_name}(1.0.0):#{installable_executable_name}
// 42:       EOS
// 43:
// 44:       old_executable = shell_cellar/"#{formula_name}/2.9/bin/#{executable_name}"
// 45:       old_executable.dirname.mkpath
// 46:       old_executable.write("#!/bin/sh\necho old-version\n")
// 47:       FileUtils.chmod 0755, old_executable
// 48:
// 49:       active_executable.dirname.mkpath
// 50:       active_executable.write("#!/bin/sh\necho active-version \"$@\"\n")
// 51:       FileUtils.chmod 0755, active_executable
// 52:
// 53:       (HOMEBREW_PREFIX/"opt").mkpath
// 54:       FileUtils.ln_sf active_executable.dirname.parent, HOMEBREW_PREFIX/"opt/#{formula_name}"
// 55:
// 56:       env_executable.dirname.mkpath
// 57:       env_executable.write("#!/bin/sh\necho env-version \"$@\"\n")
// 58:       FileUtils.chmod 0755, env_executable
// 59:       FileUtils.ln_sf env_executable.dirname.parent, HOMEBREW_PREFIX/"opt/#{env_formula_name}"
// 60:
// 61:       linked_executable = HOMEBREW_PREFIX/"bin/#{executable_name}"
// 62:       linked_executable.write("#!/bin/sh\necho linked-provider\n")
// 63:       FileUtils.chmod 0755, linked_executable
// 64:
// 65:       brew_wrapper.dirname.mkpath
// 66:       inline_script.write(<<~SH)
// 67:         #!/bin/sh
// 68:         #{executable_name} "$@"
// 69:         #{env_executable_name} "$@"
// 70:       SH
// 71:       FileUtils.chmod 0755, inline_script
// 72:
// 73:       brew_wrapper.write(<<~SH)
// 74:         #!/bin/sh
// 75:         case "$1" in
// 76:           deps)
// 77:             exit 0
// 78:             ;;
// 79:           install)
// 80:             echo fake install stdout
// 81:             echo fake install stderr >&2
// 82:             mkdir -p "#{shell_cellar}/#{installable_formula_name}/1.0.0/bin" "#{HOMEBREW_PREFIX}/opt"
// 83:             cat > "#{shell_cellar}/#{installable_formula_name}/1.0.0/bin/#{installable_executable_name}" <<'EOS'
// 84:         #!/bin/sh
// 85:         echo installable-version "$@"
// 86:         EOS
// 87:             chmod 755 "#{shell_cellar}/#{installable_formula_name}/1.0.0/bin/#{installable_executable_name}"
// 88:             ln -sfn "#{shell_cellar}/#{installable_formula_name}/1.0.0" "#{HOMEBREW_PREFIX}/opt/#{installable_formula_name}"
// 89:             ;;
// 90:           *)
// 91:             echo "unexpected brew wrapper call: $*" >&2
// 92:             exit 1
// 93:             ;;
// 94:         esac
// 95:       SH
// 96:       FileUtils.chmod 0755, brew_wrapper
// 97:     end
// 98:
// 99:     after do
// 100:       FileUtils.rm_rf shell_cellar/formula_name
// 101:       FileUtils.rm_rf shell_cellar/env_formula_name
// 102:       FileUtils.rm_rf shell_cellar/installable_formula_name
// 103:       FileUtils.rm_rf HOMEBREW_PREFIX/"opt/#{formula_name}"
// 104:       FileUtils.rm_rf HOMEBREW_PREFIX/"opt/#{env_formula_name}"
// 105:       FileUtils.rm_rf HOMEBREW_PREFIX/"opt/#{installable_formula_name}"
// 106:       FileUtils.rm_f HOMEBREW_PREFIX/"bin/#{executable_name}"
// 107:       FileUtils.rm_rf brew_wrapper.dirname
// 108:     end
// 109:
// 110:     it "runs commands in formula environments and supports the x alias", :aggregate_failures, :integration_test do
// 111:       expect do
// 112:         expect(brew_sh("exec", executable_name, "arg", brew_sh_env)).to be_a_success
// 113:       end.to(
// 114:         output("active-version arg\n").to_stdout
// 115:           .and(output("").to_stderr),
// 116:       )
// 117:
// 118:       expect do
// 119:         expect(brew_sh("x", executable_name, brew_sh_env)).to be_a_success
// 120:       end.to(
// 121:         output("active-version\n").to_stdout
// 122:           .and(output("").to_stderr),
// 123:       )
// 124:
// 125:       expect do
// 126:         expect(brew_sh("exec", "--formulae=#{formula_name}, #{env_formula_name}", "--", inline_script.to_s, "arg",
// 127:                        brew_sh_env)).to be_a_success
// 128:       end.to(
// 129:         output("active-version arg\nenv-version arg\n").to_stdout
// 130:           .and(output("").to_stderr),
// 131:       )
// 132:
// 133:       expect do
// 134:         expect(brew_sh("exec", "--formulae=", executable_name, brew_sh_env)).to be_a_failure
// 135:       end.to(
// 136:         output("").to_stdout
// 137:           .and(output("Error: `--formulae` requires a comma-separated formula list.\n").to_stderr),
// 138:       )
// 139:
// 140:       expect do
// 141:         expect(brew_sh("exec", "--sandbox=", executable_name, brew_sh_env)).to be_a_failure
// 142:       end.to(
// 143:         output("").to_stdout
// 144:           .and(output("Error: `--sandbox` requires a writable path.\n").to_stderr),
// 145:       )
// 146:
// 147:       expect do
// 148:         expect(brew_sh("exec", installable_executable_name, "arg",
// 149:                        brew_sh_env)).to be_a_success
// 150:       end.to(
// 151:         output("installable-version arg\n").to_stdout
// 152:           .and(
// 153:             output(
// 154:               "==> Installing `#{installable_formula_name}` because it provides " \
// 155:               "`#{installable_executable_name}`.\n" \
// 156:               "fake install stdout\n" \
// 157:               "fake install stderr\n",
// 158:             ).to_stderr,
// 159:           ),
// 160:       )
// 161:     end
// 162:   end
// 163: end

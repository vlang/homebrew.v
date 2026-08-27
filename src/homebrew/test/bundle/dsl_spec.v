module bundle

import brew_runtime

// Translated from Homebrew/brew `test/bundle/dsl_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `dsl_from_string(string)` at line 8.
pub fn ruby_dsl_spec_l8_d1_dsl_from_string(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dsl_from_string', ...args)
}

// Ruby subject `subject(:dsl) do` at line 13.
pub fn ruby_dsl_spec_l13_d2_dsl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dsl', ...args)
}

// Ruby it `it "processes input" do` at line 41.
pub fn ruby_dsl_spec_l41_d3_processes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('processes', ...args)
}

// Ruby it `it "processes trusted options without a clone target" do` at line 70.
pub fn ruby_dsl_spec_l70_d4_processes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('processes', ...args)
}

// Ruby subject `subject(:dsl) do` at line 77.
pub fn ruby_dsl_spec_l77_d5_dsl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dsl', ...args)
}

// Ruby it `it "merges the arguments" do` at line 85.
pub fn ruby_dsl_spec_l85_d6_merges(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merges', ...args)
}

// Ruby it `it "processes flatpak without options" do` at line 91.
pub fn ruby_dsl_spec_l91_d7_processes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('processes', ...args)
}

// Ruby it `it "processes flatpak with remote option" do` at line 97.
pub fn ruby_dsl_spec_l97_d8_processes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('processes', ...args)
}

// Ruby it `it "processes flatpak with explicit flathub remote" do` at line 103.
pub fn ruby_dsl_spec_l103_d9_processes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('processes', ...args)
}

// Ruby it `it "processes flatpak with URL remote" do` at line 109.
pub fn ruby_dsl_spec_l109_d10_processes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('processes', ...args)
}

// Ruby it `it "accepts positional option hashes for extensions" do` at line 117.
pub fn ruby_dsl_spec_l117_d11_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "accepts a uv source option" do` at line 123.
pub fn ruby_dsl_spec_l123_d12_accepts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('accepts', ...args)
}

// Ruby it `it "handles completely invalid code" do` at line 130.
pub fn ruby_dsl_spec_l130_d13_handles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handles', ...args)
}

// Ruby it `it "handles valid commands but with invalid options" do` at line 134.
pub fn ruby_dsl_spec_l134_d14_handles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('handles', ...args)
}

// Ruby it `it "errors on bad options" do` at line 141.
pub fn ruby_dsl_spec_l141_d15_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby it `it "errors on unknown go options" do` at line 148.
pub fn ruby_dsl_spec_l148_d16_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby it `it "errors on invalid uv with options" do` at line 154.
pub fn ruby_dsl_spec_l154_d17_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby it `it "errors on invalid uv source options" do` at line 166.
pub fn ruby_dsl_spec_l166_d18_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby it `it "errors on invalid winget options" do` at line 175.
pub fn ruby_dsl_spec_l175_d19_errors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('errors', ...args)
}

// Ruby it `it ".sanitize_brew_name" do` at line 191.
pub fn ruby_dsl_spec_l191_d20_sanitize_brew_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('.sanitize_brew_name', ...args)
}

// Ruby it `it ".sanitize_tap_name" do` at line 198.
pub fn ruby_dsl_spec_l198_d21_sanitize_tap_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('.sanitize_tap_name', ...args)
}

// Ruby it `it ".sanitize_cask_name" do` at line 203.
pub fn ruby_dsl_spec_l203_d22_sanitize_cask_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('.sanitize_cask_name', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle"
// 5: require "bundle/dsl"
// 6:
// 7: RSpec.describe Homebrew::Bundle::Dsl do
// 8:   def dsl_from_string(string)
// 9:     Homebrew::Bundle::Dsl.new(StringIO.new(string))
// 10:   end
// 11:
// 12:   context "with a DSL example" do
// 13:     subject(:dsl) do
// 14:       dsl_from_string <<~RUBY
// 15:         # frozen_string_literal: true
// 16:         cask_args appdir: '/Applications'
// 17:         tap 'homebrew/cask'
// 18:         tap 'telemachus/brew', 'https://telemachus@bitbucket.org/telemachus/brew.git'
// 19:         tap 'auto/update', 'https://bitbucket.org/auto/update.git'
// 20:         brew 'imagemagick'
// 21:         brew 'mysql@5.6', restart_service: true, link: true, conflicts_with: ['mysql']
// 22:         brew 'emacs', args: ['with-cocoa', 'with-gnutls'], link: :overwrite
// 23:         cask 'google-chrome'
// 24:         cask 'java' unless system '/usr/libexec/java_home --failfast'
// 25:         cask 'firefox', args: { appdir: '~/my-apps/Applications' }
// 26:         mas '1Password', id: 443987910
// 27:         vscode 'GitHub.codespaces'
// 28:         winget 'PowerToys', id: 'XP89DCGQ3K6VLD', source: 'msstore'
// 29:         go 'github.com/charmbracelet/crush'
// 30:         cargo 'ripgrep'
// 31:         uv 'mkdocs', with: ['mkdocs-material<10']
// 32:       RUBY
// 33:     end
// 34:
// 35:     before do
// 36:       allow_any_instance_of(described_class).to receive(:system)
// 37:         .with("/usr/libexec/java_home --failfast")
// 38:         .and_return(false)
// 39:     end
// 40:
// 41:     it "processes input" do
// 42:       # Keep in sync with the README
// 43:       expect(dsl.cask_arguments).to eql(appdir: "/Applications")
// 44:       expect(dsl.entries[0].name).to eql("homebrew/cask")
// 45:       expect(dsl.entries[1].name).to eql("telemachus/brew")
// 46:       expect(dsl.entries[1].options).to eql(clone_target: "https://telemachus@bitbucket.org/telemachus/brew.git")
// 47:       expect(dsl.entries[2].options).to eql(clone_target: "https://bitbucket.org/auto/update.git")
// 48:       expect(dsl.entries[3].name).to eql("imagemagick")
// 49:       expect(dsl.entries[4].name).to eql("mysql@5.6")
// 50:       expect(dsl.entries[4].options).to eql(restart_service: true, link: true, conflicts_with: ["mysql"])
// 51:       expect(dsl.entries[5].name).to eql("emacs")
// 52:       expect(dsl.entries[5].options).to eql(args: ["with-cocoa", "with-gnutls"], link: :overwrite)
// 53:       expect(dsl.entries[6].name).to eql("google-chrome")
// 54:       expect(dsl.entries[7].name).to eql("java")
// 55:       expect(dsl.entries[8].name).to eql("firefox")
// 56:       expect(dsl.entries[8].options).to eql(args: { appdir: "~/my-apps/Applications" }, full_name: "firefox")
// 57:       expect(dsl.entries[9].name).to eql("1Password")
// 58:       expect(dsl.entries[9].options).to eql(id: 443_987_910)
// 59:       expect(dsl.entries[10].name).to eql("GitHub.codespaces")
// 60:       expect(dsl.entries[11].name).to eql("PowerToys")
// 61:       expect(dsl.entries[11].options).to eql(id: "XP89DCGQ3K6VLD", source: "msstore")
// 62:       expect(dsl.entries[12].name).to eql("github.com/charmbracelet/crush")
// 63:       expect(dsl.entries[13].name).to eql("ripgrep")
// 64:       expect(dsl.entries[14].name).to eql("mkdocs")
// 65:       expect(dsl.entries[14].options).to eql(with: ["mkdocs-material<10"])
// 66:     end
// 67:   end
// 68:
// 69:   context "with tap entries" do
// 70:     it "processes trusted options without a clone target" do
// 71:       dsl = dsl_from_string 'tap "thirdparty/tap", trusted: true'
// 72:       expect(dsl.entries[0].options).to eql(clone_target: nil, trusted: true)
// 73:     end
// 74:   end
// 75:
// 76:   context "with multiple cask_args" do
// 77:     subject(:dsl) do
// 78:       dsl_from_string <<~RUBY
// 79:         cask_args appdir: '/global-apps'
// 80:         cask_args require_sha: true
// 81:         cask_args appdir: '~/my-apps'
// 82:       RUBY
// 83:     end
// 84:
// 85:     it "merges the arguments" do
// 86:       expect(dsl.cask_arguments).to eql(appdir: "~/my-apps", require_sha: true)
// 87:     end
// 88:   end
// 89:
// 90:   context "with flatpak entries" do
// 91:     it "processes flatpak without options" do
// 92:       dsl = dsl_from_string 'flatpak "org.gnome.Calculator"'
// 93:       expect(dsl.entries[0].name).to eql("org.gnome.Calculator")
// 94:       expect(dsl.entries[0].options[:remote]).to eql("flathub")
// 95:     end
// 96:
// 97:     it "processes flatpak with remote option" do
// 98:       dsl = dsl_from_string 'flatpak "com.custom.App", remote: "custom-repo"'
// 99:       expect(dsl.entries[0].name).to eql("com.custom.App")
// 100:       expect(dsl.entries[0].options[:remote]).to eql("custom-repo")
// 101:     end
// 102:
// 103:     it "processes flatpak with explicit flathub remote" do
// 104:       dsl = dsl_from_string 'flatpak "org.gnome.Calculator", remote: "flathub"'
// 105:       expect(dsl.entries[0].name).to eql("org.gnome.Calculator")
// 106:       expect(dsl.entries[0].options[:remote]).to eql("flathub")
// 107:     end
// 108:
// 109:     it "processes flatpak with URL remote" do
// 110:       dsl = dsl_from_string 'flatpak "org.godotengine.Godot", remote: "https://dl.flathub.org/beta-repo/"'
// 111:       expect(dsl.entries[0].name).to eql("org.godotengine.Godot")
// 112:       expect(dsl.entries[0].options[:remote]).to eql("https://dl.flathub.org/beta-repo/")
// 113:     end
// 114:   end
// 115:
// 116:   context "with extension entries" do
// 117:     it "accepts positional option hashes for extensions" do
// 118:       dsl = dsl_from_string 'uv "mkdocs", { with: ["mkdocs-material<10"] }'
// 119:       expect(dsl.entries[0].name).to eql("mkdocs")
// 120:       expect(dsl.entries[0].options).to eql(with: ["mkdocs-material<10"])
// 121:     end
// 122:
// 123:     it "accepts a uv source option" do
// 124:       dsl = dsl_from_string 'uv "ruff", source: "git+https://github.com/astral-sh/ruff.git"'
// 125:       expect(dsl.entries[0].options).to eql(source: "git+https://github.com/astral-sh/ruff.git")
// 126:     end
// 127:   end
// 128:
// 129:   context "with invalid input" do
// 130:     it "handles completely invalid code" do
// 131:       expect { dsl_from_string "abcdef" }.to raise_error(RuntimeError)
// 132:     end
// 133:
// 134:     it "handles valid commands but with invalid options" do
// 135:       expect { dsl_from_string "brew 1" }.to raise_error(RuntimeError)
// 136:       expect { dsl_from_string "cask 1" }.to raise_error(RuntimeError)
// 137:       expect { dsl_from_string "tap 1" }.to raise_error(RuntimeError)
// 138:       expect { dsl_from_string "cask_args ''" }.to raise_error(RuntimeError)
// 139:     end
// 140:
// 141:     it "errors on bad options" do
// 142:       expect { dsl_from_string "brew 'foo', ['bad_option']" }.to raise_error(RuntimeError)
// 143:       expect { dsl_from_string "cask 'foo', ['bad_option']" }.to raise_error(RuntimeError)
// 144:       expect { dsl_from_string "tap 'foo', ['bad_clone_target']" }.to raise_error(RuntimeError)
// 145:       expect { dsl_from_string "flatpak 'foo', ['bad_option']" }.to raise_error(RuntimeError)
// 146:     end
// 147:
// 148:     it "errors on unknown go options" do
// 149:       expect do
// 150:         dsl_from_string 'go "github.com/charmbracelet/crush", with: ["github.com/charmbracelet/gum"]'
// 151:       end.to raise_error(RuntimeError, /unknown options\(\[:with\]\) for go/)
// 152:     end
// 153:
// 154:     it "errors on invalid uv with options" do
// 155:       expect do
// 156:         dsl_from_string 'uv "mkdocs", with: "mkdocs-material<10"'
// 157:       end.to raise_error(RuntimeError, /options\[:with\].*Array of String objects/)
// 158:       expect do
// 159:         dsl_from_string 'uv "mkdocs", with: [1]'
// 160:       end.to raise_error(RuntimeError, /options\[:with\].*Array of String objects/)
// 161:       expect do
// 162:         dsl_from_string 'uv "mkdocs", with: false'
// 163:       end.to raise_error(RuntimeError, /options\[:with\].*Array of String objects/)
// 164:     end
// 165:
// 166:     it "errors on invalid uv source options" do
// 167:       expect do
// 168:         dsl_from_string 'uv "ruff", source: 123'
// 169:       end.to raise_error(RuntimeError, /options\[:source\].*String object/)
// 170:       expect do
// 171:         dsl_from_string 'uv "ruff", branch: "main"'
// 172:       end.to raise_error(RuntimeError, /unknown options\(\[:branch\]\) for uv/)
// 173:     end
// 174:
// 175:     it "errors on invalid winget options" do
// 176:       expect do
// 177:         dsl_from_string 'winget "PowerToys", id: 123'
// 178:       end.to raise_error(RuntimeError, /options\[:id\].*String object/)
// 179:       expect do
// 180:         dsl_from_string 'winget "PowerToys", source: "chocolatey"'
// 181:       end.to raise_error(RuntimeError, /options\[:source\].*one of/)
// 182:       expect do
// 183:         dsl_from_string 'winget "PowerToys", interactive: true'
// 184:       end.to raise_error(RuntimeError, /unknown options\(\[:interactive\]\) for winget/)
// 185:       expect do
// 186:         dsl_from_string 'winget "PowerToys", elevated: true'
// 187:       end.to raise_error(RuntimeError, /unknown options\(\[:elevated\]\) for winget/)
// 188:     end
// 189:   end
// 190:
// 191:   it ".sanitize_brew_name" do
// 192:     expect(described_class.sanitize_brew_name("homebrew/homebrew/foo")).to eql("foo")
// 193:     expect(described_class.sanitize_brew_name("homebrew/homebrew-bar/foo")).to eql("homebrew/bar/foo")
// 194:     expect(described_class.sanitize_brew_name("homebrew/bar/foo")).to eql("homebrew/bar/foo")
// 195:     expect(described_class.sanitize_brew_name("foo")).to eql("foo")
// 196:   end
// 197:
// 198:   it ".sanitize_tap_name" do
// 199:     expect(described_class.sanitize_tap_name("homebrew/homebrew-foo")).to eql("homebrew/foo")
// 200:     expect(described_class.sanitize_tap_name("homebrew/foo")).to eql("homebrew/foo")
// 201:   end
// 202:
// 203:   it ".sanitize_cask_name" do
// 204:     expect(described_class.sanitize_cask_name("homebrew/cask-versions/adoptopenjdk8")).to eql("adoptopenjdk8")
// 205:     expect(described_class.sanitize_cask_name("adoptopenjdk8")).to eql("adoptopenjdk8")
// 206:   end
// 207: end

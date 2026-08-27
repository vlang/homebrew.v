module cask

import brew_runtime

// Translated from Homebrew/brew `test/cask/migrator_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:new_cask) { instance_double(Cask::Cask, token: "new-token", old_tokens: ["old-token"]) }` at line 8.
pub fn ruby_migrator_spec_l8_d1_new_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_cask', ...args)
}

// Ruby method `setup_installed_cask(dir, token)` at line 10.
pub fn ruby_migrator_spec_l10_d2_setup_installed_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_installed_cask', ...args)
}

// Ruby it `it "returns old tokens that are still installed in their own Caskroom directory" do` at line 16.
pub fn ruby_migrator_spec_l16_d3_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "returns old tokens even when the new cask is installed under its own token" do` at line 25.
pub fn ruby_migrator_spec_l25_d4_returns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('returns', ...args)
}

// Ruby it `it "ignores old tokens that have already been migrated" do` at line 35.
pub fn ruby_migrator_spec_l35_d5_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('ignores', ...args)
}

// Ruby it `it "removes an empty Caskroom directory for an old token" do` at line 45.
pub fn ruby_migrator_spec_l45_d6_removes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('removes', ...args)
}

// Ruby let `let(:old_cask) { Cask::CaskLoader.load(cask_path("local-caffeine")) }` at line 58.
pub fn ruby_migrator_spec_l58_d7_old_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_cask', ...args)
}

// Ruby let `let(:new_cask) { Cask::CaskLoader.load(cask_path("local-transmission")) }` at line 59.
pub fn ruby_migrator_spec_l59_d8_new_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_cask', ...args)
}

// Ruby let `let(:old_caskroom_path) { Cask::Caskroom.path/"local-caffeine" }` at line 60.
pub fn ruby_migrator_spec_l60_d9_old_caskroom_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_caskroom_path', ...args)
}

// Ruby let `let(:appdir) { Pathname(new_cask.config.appdir) }` at line 61.
pub fn ruby_migrator_spec_l61_d10_appdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('appdir', ...args)
}

// Ruby method `rename_old_cask_to_new_cask` at line 65.
pub fn ruby_migrator_spec_l65_d11_rename_old_cask_to_new_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rename_old_cask_to_new_cask', ...args)
}

// Ruby it `it "moves the old cask to the new token" do` at line 70.
pub fn ruby_migrator_spec_l70_d12_moves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('moves', ...args)
}

// Ruby it `it "moves the old cask to the new token without copying it into itself" do` at line 82.
pub fn ruby_migrator_spec_l82_d13_moves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('moves', ...args)
}

// Ruby it `it "uninstalls the old cask" do` at line 104.
pub fn ruby_migrator_spec_l104_d14_uninstalls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstalls', ...args)
}

// Ruby it `it "does not uninstall the old cask in a dry run" do` at line 116.
pub fn ruby_migrator_spec_l116_d15_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby let `let(:new_cask) { Cask::CaskLoader.load(cask_path("local-caffeine-clone")) }` at line 126.
pub fn ruby_migrator_spec_l126_d16_new_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_cask', ...args)
}

// Ruby it `it "keeps the shared artifact installed for the new cask" do` at line 135.
pub fn ruby_migrator_spec_l135_d17_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby let `let(:old_caskroom_path) { Pathname("/tmp/Caskroom/old-token") }` at line 149.
pub fn ruby_migrator_spec_l149_d18_old_caskroom_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_caskroom_path', ...args)
}

// Ruby let `let(:new_caskroom_path) { Pathname("/tmp/Caskroom/new-token") }` at line 150.
pub fn ruby_migrator_spec_l150_d19_new_caskroom_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_caskroom_path', ...args)
}

// Ruby let `let(:old_caskfile) { old_caskroom_path/".metadata/1.0/20240101000000/Casks/old-token.rb" }` at line 151.
pub fn ruby_migrator_spec_l151_d20_old_caskfile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_caskfile', ...args)
}

// Ruby let `let(:new_caskfile) { new_caskroom_path/".metadata/1.0/20240101000000/Casks/new-token.rb" }` at line 152.
pub fn ruby_migrator_spec_l152_d21_new_caskfile(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_caskfile', ...args)
}

// Ruby let `let(:old_pin_path) { Pathname("/tmp/pinned_casks/old-token") }` at line 153.
pub fn ruby_migrator_spec_l153_d22_old_pin_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_pin_path', ...args)
}

// Ruby let `let(:new_pin_path) { Pathname("/tmp/pinned_casks/new-token") }` at line 154.
pub fn ruby_migrator_spec_l154_d23_new_pin_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_pin_path', ...args)
}

// Ruby let `let(:old_cask) do` at line 155.
pub fn ruby_migrator_spec_l155_d24_old_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_cask', ...args)
}

// Ruby let `let(:new_cask) do` at line 165.
pub fn ruby_migrator_spec_l165_d25_new_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_cask', ...args)
}

// Ruby it `it "moves a cask pin to the new token" do` at line 185.
pub fn ruby_migrator_spec_l185_d26_moves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('moves', ...args)
}

// Ruby it `it "prints relative cask pin targets in dry run" do` at line 192.
pub fn ruby_migrator_spec_l192_d27_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "does not remove the old cask pin when creating the new pin fails" do` at line 198.
pub fn ruby_migrator_spec_l198_d28_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/migrator"
// 5:
// 6: RSpec.describe Cask::Migrator do
// 7:   describe ".old_tokens_needing_migration" do
// 8:     let(:new_cask) { instance_double(Cask::Cask, token: "new-token", old_tokens: ["old-token"]) }
// 9:
// 10:     def setup_installed_cask(dir, token)
// 11:       casks_dir = dir/token/".metadata/1.0/20250101000000.000/Casks"
// 12:       casks_dir.mkpath
// 13:       (casks_dir/"#{token}.rb").write("cask \"#{token}\"\n")
// 14:     end
// 15:
// 16:     it "returns old tokens that are still installed in their own Caskroom directory" do
// 17:       Dir.mktmpdir do |dir|
// 18:         allow(Cask::Caskroom).to receive(:path).and_return(Pathname(dir))
// 19:         setup_installed_cask(Pathname(dir), "old-token")
// 20:
// 21:         expect(described_class.old_tokens_needing_migration(new_cask)).to eq(["old-token"])
// 22:       end
// 23:     end
// 24:
// 25:     it "returns old tokens even when the new cask is installed under its own token" do
// 26:       Dir.mktmpdir do |dir|
// 27:         allow(Cask::Caskroom).to receive(:path).and_return(Pathname(dir))
// 28:         setup_installed_cask(Pathname(dir), "old-token")
// 29:         setup_installed_cask(Pathname(dir), "new-token")
// 30:
// 31:         expect(described_class.old_tokens_needing_migration(new_cask)).to eq(["old-token"])
// 32:       end
// 33:     end
// 34:
// 35:     it "ignores old tokens that have already been migrated" do
// 36:       Dir.mktmpdir do |dir|
// 37:         allow(Cask::Caskroom).to receive(:path).and_return(Pathname(dir))
// 38:         setup_installed_cask(Pathname(dir), "new-token")
// 39:         FileUtils.ln_s "new-token", Pathname(dir)/"old-token"
// 40:
// 41:         expect(described_class.old_tokens_needing_migration(new_cask)).to be_empty
// 42:       end
// 43:     end
// 44:
// 45:     it "removes an empty Caskroom directory for an old token" do
// 46:       Dir.mktmpdir do |dir|
// 47:         allow(Cask::Caskroom).to receive(:path).and_return(Pathname(dir))
// 48:         old_caskroom_path = Pathname(dir)/"old-token"
// 49:         old_caskroom_path.mkpath
// 50:
// 51:         expect([described_class.old_tokens_needing_migration(new_cask), old_caskroom_path.exist?])
// 52:           .to eq([[], false])
// 53:       end
// 54:     end
// 55:   end
// 56:
// 57:   describe ".migrate_if_needed", :cask do
// 58:     let(:old_cask) { Cask::CaskLoader.load(cask_path("local-caffeine")) }
// 59:     let(:new_cask) { Cask::CaskLoader.load(cask_path("local-transmission")) }
// 60:     let(:old_caskroom_path) { Cask::Caskroom.path/"local-caffeine" }
// 61:     let(:appdir) { Pathname(new_cask.config.appdir) }
// 62:
// 63:     # The new cask is renamed from the old cask, but stub this only once both casks are
// 64:     # installed so that installing the new cask does not migrate the old cask itself.
// 65:     def rename_old_cask_to_new_cask
// 66:       allow(new_cask).to receive(:old_tokens).and_return(["local-caffeine"])
// 67:     end
// 68:
// 69:     context "when the new cask is not installed" do
// 70:       it "moves the old cask to the new token" do
// 71:         InstallHelper.stub_cask_installation(old_cask)
// 72:         rename_old_cask_to_new_cask
// 73:
// 74:         described_class.migrate_if_needed(new_cask)
// 75:
// 76:         expect([old_caskroom_path.symlink?, new_cask.installed_version])
// 77:           .to eq([true, old_cask.version.to_s])
// 78:       end
// 79:     end
// 80:
// 81:     context "when the new token is an alias symlink pointing at the old directory" do
// 82:       it "moves the old cask to the new token without copying it into itself" do
// 83:         InstallHelper.stub_cask_installation(old_cask)
// 84:         FileUtils.ln_s "local-caffeine", Cask::Caskroom.path/"local-transmission"
// 85:         rename_old_cask_to_new_cask
// 86:
// 87:         described_class.migrate_if_needed(new_cask)
// 88:
// 89:         expect([
// 90:           old_caskroom_path.symlink?,
// 91:           new_cask.installed_version,
// 92:           (Cask::Caskroom.path/"local-transmission/local-caffeine").exist?,
// 93:         ]).to eq([true, old_cask.version.to_s, false])
// 94:       end
// 95:     end
// 96:
// 97:     context "when the new cask is already installed" do
// 98:       before do
// 99:         Cask::Installer.new(new_cask).install
// 100:         Cask::Installer.new(old_cask).install
// 101:         rename_old_cask_to_new_cask
// 102:       end
// 103:
// 104:       it "uninstalls the old cask" do
// 105:         expect { described_class.migrate_if_needed(new_cask) }
// 106:           .to output(/Uninstalling Cask local-caffeine/).to_stdout
// 107:
// 108:         expect([
// 109:           old_caskroom_path.symlink?,
// 110:           (appdir/"Caffeine.app").exist?,
// 111:           (appdir/"Transmission.app").exist?,
// 112:           new_cask.installed?,
// 113:         ]).to eq([true, false, true, true])
// 114:       end
// 115:
// 116:       it "does not uninstall the old cask in a dry run" do
// 117:         expect { described_class.migrate_if_needed(new_cask, dry_run: true) }
// 118:           .to output(/local-transmission is already installed, so local-caffeine would be uninstalled/)
// 119:           .to_stdout
// 120:
// 121:         expect([old_caskroom_path.directory?, (appdir/"Caffeine.app").exist?]).to eq([true, true])
// 122:       end
// 123:     end
// 124:
// 125:     context "when the new cask is already installed and shares an artifact with the old cask" do
// 126:       let(:new_cask) { Cask::CaskLoader.load(cask_path("local-caffeine-clone")) }
// 127:
// 128:       before do
// 129:         Cask::Installer.new(old_cask).install
// 130:         # Both casks install `Caffeine.app`, so the second install has to overwrite it.
// 131:         Cask::Installer.new(new_cask, force: true).install
// 132:         rename_old_cask_to_new_cask
// 133:       end
// 134:
// 135:       it "keeps the shared artifact installed for the new cask" do
// 136:         expect { described_class.migrate_if_needed(new_cask) }
// 137:           .to output(/Keeping Caffeine.app \(App\) as local-caffeine-clone installs it too/).to_stdout
// 138:
// 139:         expect([
// 140:           old_caskroom_path.symlink?,
// 141:           (appdir/"Caffeine.app").exist?,
// 142:           new_cask.installed?,
// 143:         ]).to eq([true, true, true])
// 144:       end
// 145:     end
// 146:   end
// 147:
// 148:   describe "#migrate" do
// 149:     let(:old_caskroom_path) { Pathname("/tmp/Caskroom/old-token") }
// 150:     let(:new_caskroom_path) { Pathname("/tmp/Caskroom/new-token") }
// 151:     let(:old_caskfile) { old_caskroom_path/".metadata/1.0/20240101000000/Casks/old-token.rb" }
// 152:     let(:new_caskfile) { new_caskroom_path/".metadata/1.0/20240101000000/Casks/new-token.rb" }
// 153:     let(:old_pin_path) { Pathname("/tmp/pinned_casks/old-token") }
// 154:     let(:new_pin_path) { Pathname("/tmp/pinned_casks/new-token") }
// 155:     let(:old_cask) do
// 156:       instance_double(
// 157:         Cask::Cask,
// 158:         token:              "old-token",
// 159:         caskroom_path:      old_caskroom_path,
// 160:         installed_caskfile: old_caskfile,
// 161:         pin_path:           old_pin_path,
// 162:         pinned_version:     "1.0",
// 163:       )
// 164:     end
// 165:     let(:new_cask) do
// 166:       instance_double(
// 167:         Cask::Cask,
// 168:         token:         "new-token",
// 169:         caskroom_path: new_caskroom_path,
// 170:         installed?:    true,
// 171:         pin_path:      new_pin_path,
// 172:       )
// 173:     end
// 174:
// 175:     before do
// 176:       allow(old_pin_path).to receive(:symlink?).and_return(true)
// 177:       allow(FileUtils).to receive(:cp_r).with(old_caskroom_path, new_caskroom_path)
// 178:       allow(FileUtils).to receive(:mv).with(new_caskroom_path/old_caskfile.relative_path_from(old_caskroom_path),
// 179:                                             new_caskfile)
// 180:       allow(FileUtils).to receive(:rm_r).with(old_caskroom_path)
// 181:       allow(FileUtils).to receive(:ln_s).with(new_caskroom_path.basename, old_caskroom_path)
// 182:       allow(described_class).to receive(:replace_caskfile_token).with(new_caskfile, "old-token", "new-token")
// 183:     end
// 184:
// 185:     it "moves a cask pin to the new token" do
// 186:       expect(old_cask).to receive(:unpin)
// 187:       expect(new_pin_path).to receive(:make_relative_symlink).with(new_caskroom_path/"1.0")
// 188:
// 189:       described_class.new(old_cask, new_cask).migrate
// 190:     end
// 191:
// 192:     it "prints relative cask pin targets in dry run" do
// 193:       expect do
// 194:         described_class.new(old_cask, new_cask).migrate(dry_run: true)
// 195:       end.to output(%r{ln -s ../Caskroom/new-token/1\.0 /tmp/pinned_casks/new-token}).to_stdout
// 196:     end
// 197:
// 198:     it "does not remove the old cask pin when creating the new pin fails" do
// 199:       allow(new_pin_path).to receive(:make_relative_symlink).and_raise(RuntimeError, "failed")
// 200:       expect(old_cask).not_to receive(:unpin)
// 201:
// 202:       expect do
// 203:         described_class.new(old_cask, new_cask).migrate
// 204:       end.to output(/Failed to migrate cask pin from old-token to new-token: failed/).to_stderr
// 205:     end
// 206:   end
// 207: end

module test

import brew_runtime

// Translated from Homebrew/brew `test/migrator_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:migrator) { described_class.new(new_formula, old_formula.name) }` at line 10.
pub fn ruby_migrator_spec_l10_d1_migrator(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('migrator', ...args)
}

// Ruby let `let(:new_formula) { Testball.new("newname") }` at line 12.
pub fn ruby_migrator_spec_l12_d2_new_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_formula', ...args)
}

// Ruby let `let(:old_formula) { Testball.new("oldname") }` at line 13.
pub fn ruby_migrator_spec_l13_d3_old_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_formula', ...args)
}

// Ruby let `let(:new_keg_record) { HOMEBREW_CELLAR/"newname/0.1" }` at line 14.
pub fn ruby_migrator_spec_l14_d4_new_keg_record(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('new_keg_record', ...args)
}

// Ruby let `let(:old_keg_record) { HOMEBREW_CELLAR/"oldname/0.1" }` at line 15.
pub fn ruby_migrator_spec_l15_d5_old_keg_record(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_keg_record', ...args)
}

// Ruby let `let(:old_tab) { Tab.empty }` at line 16.
pub fn ruby_migrator_spec_l16_d6_old_tab(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_tab', ...args)
}

// Ruby let `let(:keg) { Keg.new(old_keg_record) }` at line 17.
pub fn ruby_migrator_spec_l17_d7_keg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keg', ...args)
}

// Ruby let `let(:old_pin) { HOMEBREW_PINNED_KEGS/"oldname" }` at line 18.
pub fn ruby_migrator_spec_l18_d8_old_pin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_pin', ...args)
}

// Ruby it `it "raises an error if there is no old path" do` at line 59.
pub fn ruby_migrator_spec_l59_d9_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "raises an error if the Taps differ" do` at line 65.
pub fn ruby_migrator_spec_l65_d10_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby specify `specify "#move_to_new_directory" do` at line 79.
pub fn ruby_migrator_spec_l79_d11_move_to_new_directory(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#move_to_new_directory', ...args)
}

// Ruby specify `specify "#backup_oldname_cellar" do` at line 90.
pub fn ruby_migrator_spec_l90_d12_backup_oldname_cellar(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#backup_oldname_cellar', ...args)
}

// Ruby specify `specify "#repin" do` at line 100.
pub fn ruby_migrator_spec_l100_d13_repin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#repin', ...args)
}

// Ruby specify `specify "#unlink_oldname" do` at line 111.
pub fn ruby_migrator_spec_l111_d14_unlink_oldname(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#unlink_oldname', ...args)
}

// Ruby specify `specify "#link_newname" do` at line 121.
pub fn ruby_migrator_spec_l121_d15_link_newname(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#link_newname', ...args)
}

// Ruby specify `specify "#link_oldname_opt" do` at line 136.
pub fn ruby_migrator_spec_l136_d16_link_oldname_opt(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#link_oldname_opt', ...args)
}

// Ruby specify `specify "#link_oldname_cellar" do` at line 142.
pub fn ruby_migrator_spec_l142_d17_link_oldname_cellar(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#link_oldname_cellar', ...args)
}

// Ruby specify `specify "#update_tabs" do` at line 150.
pub fn ruby_migrator_spec_l150_d18_update_tabs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#update_tabs', ...args)
}

// Ruby specify `specify "#migrate" do` at line 160.
pub fn ruby_migrator_spec_l160_d19_migrate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#migrate', ...args)
}

// Ruby specify `specify "#unlinik_oldname_opt" do` at line 179.
pub fn ruby_migrator_spec_l179_d20_unlinik_oldname_opt(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#unlinik_oldname_opt', ...args)
}

// Ruby specify `specify "#unlink_oldname_cellar" do` at line 188.
pub fn ruby_migrator_spec_l188_d21_unlink_oldname_cellar(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#unlink_oldname_cellar', ...args)
}

// Ruby specify `specify "#backup_oldname_cellar after uninstall" do` at line 197.
pub fn ruby_migrator_spec_l197_d22_backup_oldname_cellar(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#backup_oldname_cellar', ...args)
}

// Ruby specify `specify "#backup_old_tabs" do` at line 205.
pub fn ruby_migrator_spec_l205_d23_backup_old_tabs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('#backup_old_tabs', ...args)
}

// Ruby it `it "backs up the old name" do` at line 218.
pub fn ruby_migrator_spec_l218_d24_backs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('backs', ...args)
}

// Ruby it `it "backs up the old name" do` at line 230.
pub fn ruby_migrator_spec_l230_d25_backs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('backs', ...args)
}

// Ruby it `it "backs up the old name" do` at line 245.
pub fn ruby_migrator_spec_l245_d26_backs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('backs', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "migrator"
// 5: require "test/support/fixtures/testball"
// 6: require "tab"
// 7: require "keg"
// 8:
// 9: RSpec.describe Migrator do
// 10:   subject(:migrator) { described_class.new(new_formula, old_formula.name) }
// 11:
// 12:   let(:new_formula) { Testball.new("newname") }
// 13:   let(:old_formula) { Testball.new("oldname") }
// 14:   let(:new_keg_record) { HOMEBREW_CELLAR/"newname/0.1" }
// 15:   let(:old_keg_record) { HOMEBREW_CELLAR/"oldname/0.1" }
// 16:   let(:old_tab) { Tab.empty }
// 17:   let(:keg) { Keg.new(old_keg_record) }
// 18:   let(:old_pin) { HOMEBREW_PINNED_KEGS/"oldname" }
// 19:
// 20:   before do |example|
// 21:     allow(new_formula).to receive(:oldnames).and_return(["oldname"])
// 22:     allow(Formulary).to receive(:factory).with("homebrew/core/oldname", any_args).and_return(old_formula)
// 23:     allow(Formulary).to receive(:factory).with("oldname", any_args).and_return(old_formula)
// 24:     allow(Formulary).to receive(:factory).with("newname", any_args).and_return(new_formula)
// 25:
// 26:     # do not create directories for error tests
// 27:     next if example.metadata[:description].start_with?("raises an error")
// 28:
// 29:     (old_keg_record/"bin").mkpath
// 30:
// 31:     %w[inside bindir].each do |file|
// 32:       FileUtils.touch old_keg_record/"bin/#{file}"
// 33:     end
// 34:
// 35:     old_tab.tabfile = HOMEBREW_CELLAR/"oldname/0.1/INSTALL_RECEIPT.json"
// 36:     old_tab.source["path"] = "/oldname"
// 37:     old_tab.write
// 38:
// 39:     keg.link
// 40:     keg.optlink
// 41:
// 42:     old_pin.make_relative_symlink old_keg_record
// 43:
// 44:     migrator # needs to be evaluated eagerly
// 45:
// 46:     (HOMEBREW_PREFIX/"bin").mkpath
// 47:   end
// 48:
// 49:   after do
// 50:     keg.unlink if !old_keg_record.parent.symlink? && old_keg_record.directory?
// 51:
// 52:     if new_keg_record.directory?
// 53:       new_keg = Keg.new(new_keg_record)
// 54:       new_keg.unlink
// 55:     end
// 56:   end
// 57:
// 58:   describe "::new" do
// 59:     it "raises an error if there is no old path" do
// 60:       expect do
// 61:         described_class.new(new_formula, "oldname")
// 62:       end.to raise_error(Migrator::MigratorNoOldpathError)
// 63:     end
// 64:
// 65:     it "raises an error if the Taps differ" do
// 66:       keg = HOMEBREW_CELLAR/"oldname/0.1"
// 67:       keg.mkpath
// 68:       tab = Tab.empty
// 69:       tab.tabfile = HOMEBREW_CELLAR/"oldname/0.1/INSTALL_RECEIPT.json"
// 70:       tab.source["tap"] = "homebrew/core"
// 71:       tab.write
// 72:
// 73:       expect do
// 74:         described_class.new(new_formula, "oldname")
// 75:       end.to raise_error(Migrator::MigratorDifferentTapsError)
// 76:     end
// 77:   end
// 78:
// 79:   specify "#move_to_new_directory" do
// 80:     keg.unlink
// 81:     migrator.move_to_new_directory
// 82:
// 83:     expect(new_keg_record).to be_a_directory
// 84:     expect(new_keg_record/"bin").to be_a_directory
// 85:     expect(new_keg_record/"bin/inside").to be_a_file
// 86:     expect(new_keg_record/"bin/bindir").to be_a_file
// 87:     expect(old_keg_record).not_to be_a_directory
// 88:   end
// 89:
// 90:   specify "#backup_oldname_cellar" do
// 91:     FileUtils.rm_r(old_keg_record.parent)
// 92:     (new_keg_record/"bin").mkpath
// 93:
// 94:     migrator.backup_oldname_cellar
// 95:
// 96:     expect(old_keg_record/"bin").to be_a_directory
// 97:     expect(old_keg_record/"bin").to be_a_directory
// 98:   end
// 99:
// 100:   specify "#repin" do
// 101:     (new_keg_record/"bin").mkpath
// 102:     expected_relative = new_keg_record.relative_path_from HOMEBREW_PINNED_KEGS
// 103:
// 104:     migrator.repin
// 105:
// 106:     expect(migrator.new_pin_record).to be_a_symlink
// 107:     expect(migrator.new_pin_record.readlink).to eq(expected_relative)
// 108:     expect(migrator.old_pin_record).not_to exist
// 109:   end
// 110:
// 111:   specify "#unlink_oldname" do
// 112:     expect(HOMEBREW_LINKED_KEGS.children.count).to eq(1)
// 113:     expect((HOMEBREW_PREFIX/"opt").children.count).to eq(1)
// 114:
// 115:     migrator.unlink_oldname
// 116:
// 117:     expect(HOMEBREW_LINKED_KEGS).not_to exist
// 118:     expect(HOMEBREW_LIBRARY/"bin").not_to exist
// 119:   end
// 120:
// 121:   specify "#link_newname" do
// 122:     keg.unlink
// 123:     keg.uninstall
// 124:
// 125:     (new_keg_record/"bin").mkpath
// 126:     %w[inside bindir].each do |file|
// 127:       FileUtils.touch new_keg_record/"bin"/file
// 128:     end
// 129:
// 130:     migrator.link_newname
// 131:
// 132:     expect(HOMEBREW_LINKED_KEGS.children.count).to eq(1)
// 133:     expect((HOMEBREW_PREFIX/"opt").children.count).to eq(1)
// 134:   end
// 135:
// 136:   specify "#link_oldname_opt" do
// 137:     new_keg_record.mkpath
// 138:     migrator.link_oldname_opt
// 139:     expect((HOMEBREW_PREFIX/"opt/oldname").realpath).to eq(new_keg_record.realpath)
// 140:   end
// 141:
// 142:   specify "#link_oldname_cellar" do
// 143:     (new_keg_record/"bin").mkpath
// 144:     keg.unlink
// 145:     keg.uninstall
// 146:     migrator.link_oldname_cellar
// 147:     expect((HOMEBREW_CELLAR/"oldname").realpath).to eq(new_keg_record.parent.realpath)
// 148:   end
// 149:
// 150:   specify "#update_tabs" do
// 151:     (new_keg_record/"bin").mkpath
// 152:     tab = Tab.empty
// 153:     tab.tabfile = HOMEBREW_CELLAR/"newname/0.1/INSTALL_RECEIPT.json"
// 154:     tab.source["path"] = "/path/that/must/be/changed/by/update_tabs"
// 155:     tab.write
// 156:     migrator.update_tabs
// 157:     expect(Tab.for_keg(new_keg_record).source["path"]).to eq(new_formula.path.to_s)
// 158:   end
// 159:
// 160:   specify "#migrate" do
// 161:     tab = Tab.empty
// 162:     tab.tabfile = HOMEBREW_CELLAR/"oldname/0.1/INSTALL_RECEIPT.json"
// 163:     tab.source["path"] = old_formula.path.to_s
// 164:     tab.write
// 165:
// 166:     migrator.migrate
// 167:
// 168:     expect(new_keg_record).to exist
// 169:     expect(old_keg_record.parent).to be_a_symlink
// 170:     expect(HOMEBREW_LINKED_KEGS/"oldname").not_to exist
// 171:     expect((HOMEBREW_LINKED_KEGS/"newname").realpath).to eq(new_keg_record.realpath)
// 172:     expect(old_keg_record.realpath).to eq(new_keg_record.realpath)
// 173:     expect((HOMEBREW_PREFIX/"opt/oldname").realpath).to eq(new_keg_record.realpath)
// 174:     expect((HOMEBREW_CELLAR/"oldname").realpath).to eq(new_keg_record.parent.realpath)
// 175:     expect((HOMEBREW_PINNED_KEGS/"newname").realpath).to eq(new_keg_record.realpath)
// 176:     expect(Tab.for_keg(new_keg_record).source["path"]).to eq(new_formula.path.to_s)
// 177:   end
// 178:
// 179:   specify "#unlinik_oldname_opt" do
// 180:     new_keg_record.mkpath
// 181:     old_opt_record = HOMEBREW_PREFIX/"opt/oldname"
// 182:     old_opt_record.unlink if old_opt_record.symlink?
// 183:     old_opt_record.make_relative_symlink(new_keg_record)
// 184:     migrator.unlink_oldname_opt
// 185:     expect(old_opt_record).not_to be_a_symlink
// 186:   end
// 187:
// 188:   specify "#unlink_oldname_cellar" do
// 189:     new_keg_record.mkpath
// 190:     keg.unlink
// 191:     keg.uninstall
// 192:     old_keg_record.parent.make_relative_symlink(new_keg_record.parent)
// 193:     migrator.unlink_oldname_cellar
// 194:     expect(old_keg_record.parent).not_to be_a_symlink
// 195:   end
// 196:
// 197:   specify "#backup_oldname_cellar after uninstall" do
// 198:     (new_keg_record/"bin").mkpath
// 199:     keg.unlink
// 200:     keg.uninstall
// 201:     migrator.backup_oldname_cellar
// 202:     expect(old_keg_record.subdirs).not_to be_empty
// 203:   end
// 204:
// 205:   specify "#backup_old_tabs" do
// 206:     tab = Tab.empty
// 207:     tab.tabfile = HOMEBREW_CELLAR/"oldname/0.1/INSTALL_RECEIPT.json"
// 208:     tab.source["path"] = "/should/be/the/same"
// 209:     tab.write
// 210:     migrator = described_class.new(new_formula, "oldname")
// 211:     tab.tabfile.delete
// 212:     migrator.backup_old_tabs
// 213:     expect(Tab.for_keg(old_keg_record).source["path"]).to eq("/should/be/the/same")
// 214:   end
// 215:
// 216:   describe "#backup_oldname" do
// 217:     context "when cellar exists" do
// 218:       it "backs up the old name" do
// 219:         migrator.backup_oldname
// 220:         expect(old_keg_record.parent).to be_a_directory
// 221:         expect(old_keg_record.parent.subdirs).not_to be_empty
// 222:         expect(HOMEBREW_LINKED_KEGS/"oldname").to exist
// 223:         expect(HOMEBREW_PREFIX/"opt/oldname").to exist
// 224:         expect(HOMEBREW_PINNED_KEGS/"oldname").to be_a_symlink
// 225:         expect(keg).to be_linked
// 226:       end
// 227:     end
// 228:
// 229:     context "when cellar is removed" do
// 230:       it "backs up the old name" do
// 231:         (new_keg_record/"bin").mkpath
// 232:         keg.unlink
// 233:         keg.uninstall
// 234:         migrator.backup_oldname
// 235:         expect(old_keg_record.parent).to be_a_directory
// 236:         expect(old_keg_record.parent.subdirs).not_to be_empty
// 237:         expect(HOMEBREW_LINKED_KEGS/"oldname").to exist
// 238:         expect(HOMEBREW_PREFIX/"opt/oldname").to exist
// 239:         expect(HOMEBREW_PINNED_KEGS/"oldname").to be_a_symlink
// 240:         expect(keg).to be_linked
// 241:       end
// 242:     end
// 243:
// 244:     context "when cellar is linked" do
// 245:       it "backs up the old name" do
// 246:         (new_keg_record/"bin").mkpath
// 247:         keg.unlink
// 248:         keg.uninstall
// 249:         old_keg_record.parent.make_relative_symlink(new_keg_record.parent)
// 250:         migrator.backup_oldname
// 251:         expect(old_keg_record.parent).to be_a_directory
// 252:         expect(old_keg_record.parent.subdirs).not_to be_empty
// 253:         expect(HOMEBREW_LINKED_KEGS/"oldname").to exist
// 254:         expect(HOMEBREW_PREFIX/"opt/oldname").to exist
// 255:         expect(HOMEBREW_PINNED_KEGS/"oldname").to be_a_symlink
// 256:         expect(keg).to be_linked
// 257:       end
// 258:     end
// 259:   end
// 260: end

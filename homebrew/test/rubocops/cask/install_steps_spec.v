module cask

import homebrew.rubocops.cask as install_steps_core

// Translated from Homebrew/brew `test/rubocops/cask/install_steps_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn install_steps_spec_source(body string) string {
	return 'cask "foo" do\n  version :latest\n  sha256 :no_check\n\n${body}\nend\n'
}

// Ruby it `it "allows a flight block after matching steps in third-party taps during migration" do` at line 7.
pub fn ruby_install_steps_spec_l7_d1_allows() bool {
	source := install_steps_spec_source('  postflight_steps do\n    touch "foo"\n  end\n\n  postflight do\n    touch "foo"\n  end')
	return install_steps_core.audit_cask_install_steps(source, '/Taps/example/homebrew-cask/Casks/f/foo.rb').len == 0
}

// Ruby it `it "rejects flight blocks in official Homebrew taps" do` at line 24.
pub fn ruby_install_steps_spec_l24_d2_rejects() bool {
	source := install_steps_spec_source('  postflight_steps do\n    touch "foo"\n  end\n\n  postflight do\n    touch "foo"\n  end')
	offenses := install_steps_core.audit_cask_install_steps(source, '/Taps/homebrew/homebrew-example/Casks/f/foo.rb')
	return offenses.len == 1 && offenses[0].message == 'Casks in official Homebrew taps must use `postflight_steps` instead of `postflight`.' && source[offenses[0].begin_pos..offenses[0].end_pos].starts_with('postflight do')
}

// Ruby it `it "reports an offense when a steps block contains Ruby code" do` at line 42.
pub fn ruby_install_steps_spec_l42_d3_reports() bool {
	source := install_steps_spec_source('  preflight_steps do\n    system "true"\n  end')
	offenses := install_steps_core.audit_cask_install_steps(source, '')
	return offenses.len == 1 && source[offenses[0].begin_pos..offenses[0].end_pos] == 'system "true"' && offenses[0].message.contains('Steps blocks may only contain install step DSL calls.')
}

// Ruby it `it "rejects `brew ruby` in steps blocks" do` at line 56.
pub fn ruby_install_steps_spec_l56_d4_rejects() bool {
	source := install_steps_spec_source('  preflight_steps do\n    run "{{HOMEBREW_BREW_FILE}}", args: ["ruby", "--", "{{staged_path}}/post-install.rb"]\n  end')
	offenses := install_steps_core.audit_cask_install_steps(source, '')
	return offenses.len == 1 && source[offenses[0].begin_pos..offenses[0].end_pos] == '"{{HOMEBREW_BREW_FILE}}"' && offenses[0].message == install_steps_core.cask_install_steps_brew_ruby_message
}

// Ruby it `it "reports an offense when cask steps contain formula rebuild actions" do` at line 70.
pub fn ruby_install_steps_spec_l70_d5_reports() bool {
	source := install_steps_spec_source('  preflight_steps do\n    update_desktop_database\n  end')
	offenses := install_steps_core.audit_cask_install_steps(source, '')
	return offenses.len == 1 && source[offenses[0].begin_pos..offenses[0].end_pos] == 'update_desktop_database'
}

// Ruby it `it "accepts install step DSL calls" do` at line 84.
pub fn ruby_install_steps_spec_l84_d6_accepts() bool {
	source := install_steps_spec_source('  preflight_steps do\n    mkdir_p "foo"\n    touch "foo/state"\n    touch "#{token}/state"\n    move "source", "target"\n    move_contents "source", "target"\n    inreplace "foo.conf", "@PREFIX@", "{{HOMEBREW_PREFIX}}"\n    symlink "source", "target", source_base: :relative, overwrite: true, remove_on_uninstall: true\n    write_file "foo.conf", "key = value\\n"\n    set_permissions "Foo.app", "0755"\n    set_ownership "Foo.app", user: "root", group: "wheel"\n    run "foo", args: ["--repair"], writable_paths: ["Library/Application Support/Foo"], writable_base: :home\n    terminate_process "foo", attempts: 3\n    change_dylib_id "Foo.app/Contents/Frameworks/libfoo.dylib", "@rpath/libfoo.dylib"\n    delete_keychain_certificates "Charles"\n    delete_keychain_certificates "NodeMITMProxyCA", fingerprint_of: "~/Library/Application Support/betwixt/ssl/certs/ca.pem"\n    on_macos do\n      if_path_exists "Foo.app" do\n        touch "Foo.app/marker"\n      end\n    end\n    on_linux do\n      unless_path_exists "foo.conf" do\n        write_file "foo.conf", "key = value\\n"\n      end\n    end\n  end')
	return install_steps_core.audit_cask_install_steps(source, '').len == 0
}

// Ruby it `it "autocorrects legacy install step names" do` at line 121.
pub fn ruby_install_steps_spec_l121_d7_autocorrects() bool {
	source := install_steps_spec_source('  preflight_steps do\n    mkdir "foo"\n    mv "source", "target"\n    move_children "source", "target"\n    ln_s "source", "target"\n    ln_sf "source", "target"\n    write "foo.conf", "content"\n    write "banner", <<~TEXT\n      banner\n    TEXT\n    delete_keychain_certificate "Charles", matching_certificate: "certificate.pem"\n  end')
	expected := install_steps_spec_source('  preflight_steps do\n    mkdir_p "foo"\n    move "source", "target"\n    move_contents "source", "target"\n    symlink "source", "target"\n    symlink "source", "target", overwrite: true\n    write_file "foo.conf", "content", overwrite: false, append_newline: true\n    write_file "banner", <<~TEXT, overwrite: false, append_newline: true\n      banner\n    TEXT\n    delete_keychain_certificates "Charles", fingerprint_of: "certificate.pem"\n  end')
	analysis := install_steps_core.analyze_cask_install_steps(source, '')
	return analysis.offenses.len == 9 && analysis.corrected == expected
}

// Ruby it `it "autocorrects legacy install step keywords" do` at line 172.
pub fn ruby_install_steps_spec_l172_d8_autocorrects() bool {
	source := install_steps_spec_source('  preflight_steps do\n    delete_keychain_certificates "Charles",\n                                 matching_certificate: "certificate.pem"\n  end')
	expected := source.replace('matching_certificate:', 'fingerprint_of:')
	analysis := install_steps_core.analyze_cask_install_steps(source, '')
	return analysis.offenses.len == 1 && source[analysis.offenses[0].begin_pos..analysis.offenses[0].end_pos] == 'matching_certificate' && analysis.corrected == expected
}

// Ruby it `it "reports an offense when a step string uses unsupported interpolation" do` at line 199.
pub fn ruby_install_steps_spec_l199_d9_reports() bool {
	source := install_steps_spec_source('  preflight_steps do\n    touch "#{appdir}/state"\n  end')
	offenses := install_steps_core.audit_cask_install_steps(source, '')
	return offenses.len == 1 && source[offenses[0].begin_pos..offenses[0].end_pos] == '#{appdir}'
}

// Ruby it `it "reports an offense when a scope contains Ruby code" do` at line 213.
pub fn ruby_install_steps_spec_l213_d10_reports() bool {
	source := install_steps_spec_source('  preflight_steps do\n    on_macos do\n      system "true"\n    end\n  end')
	offenses := install_steps_core.audit_cask_install_steps(source, '')
	return offenses.len == 1 && source[offenses[0].begin_pos..offenses[0].end_pos] == 'system "true"'
}

// Ruby it `it "autocorrects simple flight block file preparation" do` at line 229.
pub fn ruby_install_steps_spec_l229_d11_autocorrects() bool {
	source := install_steps_spec_source('  postflight do\n    (staged_path/"Prepared").mkpath\n    FileUtils.touch staged_path/"Prepared/touched"\n    FileUtils.mv staged_path/"source", staged_path/"target"\n    FileUtils.ln_s "target", staged_path/"Linked"\n  end')
	expected := install_steps_spec_source('  postflight_steps do\n    mkdir_p "Prepared"\n    touch "Prepared/touched"\n    move "source", "target"\n    symlink "target", "Linked", source_base: :relative\n  end')
	return install_steps_core.correct_cask_install_steps(source, '/Taps/homebrew/homebrew-cask/Casks/f/foo.rb') == expected
}

// Ruby it `it "autocorrects simple flight block config writes" do` at line 260.
pub fn ruby_install_steps_spec_l260_d12_autocorrects() bool {
	source := install_steps_spec_source('  postflight do\n    File.write staged_path/"Prepared/foo.conf", "key = value\\n"\n  end')
	expected := install_steps_spec_source('  postflight_steps do\n    write_file "Prepared/foo.conf", "key = value\\n"\n  end')
	return install_steps_core.correct_cask_install_steps(source, '') == expected
}

// Ruby it `it "autocorrects fixed keychain certificate deletion flight blocks" do` at line 285.
pub fn ruby_install_steps_spec_l285_d13_autocorrects() bool {
	source := install_steps_spec_source('  preflight do\n    stdout, * = system_command "/usr/bin/security",\n                               args: ["find-certificate", "-a", "-c", "Charles", "-Z"],\n                               sudo: true\n    hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }\n    hashes.each do |h|\n      system_command "/usr/bin/security",\n                     args: ["delete-certificate", "-Z", h],\n                     sudo: true\n    end\n  end\n\n  postflight do\n    ["AutoFirma ROOT", "127.0.0.1"].each do |cert_name|\n      stdout, * = system_command "/usr/bin/security",\n                                 args: ["find-certificate", "-a", "-c", cert_name, "-Z"],\n                                 sudo: true\n      hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }\n      hashes.each do |h|\n        system_command "/usr/bin/security",\n                       args: ["delete-certificate", "-Z", h],\n                       sudo: true\n      end\n    end\n  end\n\n  uninstall_postflight do\n    cert = Pathname("~/Library/Application Support/betwixt/ssl/certs/ca.pem").expand_path\n    next unless cert.exist?\n\n    stdout, * = system_command "/usr/bin/openssl",\n                               args: ["x509", "-fingerprint", "-sha256", "-noout", "-in", cert]\n    hash = stdout.lines.first.split("=").second.delete(":").strip\n    stdout, * = system_command "/usr/bin/security",\n                               args: ["find-certificate", "-a", "-c", "NodeMITMProxyCA", "-Z"],\n                               sudo: true\n    hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }\n    if hashes.include?(hash)\n      system_command "/usr/bin/security",\n                     args: ["delete-certificate", "-Z", hash],\n                     sudo: true\n    end\n  end')
	expected := install_steps_spec_source('  preflight_steps do\n    delete_keychain_certificates "Charles"\n  end\n\n  postflight_steps do\n    delete_keychain_certificates "AutoFirma ROOT"\n    delete_keychain_certificates "127.0.0.1"\n  end\n\n  uninstall_postflight_steps do\n    delete_keychain_certificates "NodeMITMProxyCA",\n                                 fingerprint_of: "~/Library/Application Support/betwixt/ssl/certs/ca.pem"\n  end')
	analysis := install_steps_core.analyze_cask_install_steps(source, '')
	return analysis.offenses.len == 3 && analysis.corrected == expected
}

// Ruby it `it "does not autocorrect altered or mixed keychain deletion blocks" do` at line 362.
pub fn ruby_install_steps_spec_l362_d14_does() bool {
	for body in [
		'  uninstall_postflight do\n    stdout, * = system_command "/usr/local/bin/security",\n                               args: ["find-certificate", "-a", "-c", "Charles", "-Z"],\n                               sudo: true\n    hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }\n    hashes.each do |h|\n      system_command "/usr/local/bin/security", args: ["delete-certificate", "-Z", h], sudo: true\n    end\n  end',
		'  uninstall_postflight do\n    stdout, * = system_command "/usr/bin/security",\n                               args: ["find-certificate", "-a", "-c", "Charles", "-Z", "login.keychain"],\n                               sudo: true\n    hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }\n    hashes.each do |h|\n      system_command "/usr/bin/security", args: ["delete-certificate", "-Z", h], sudo: true\n    end\n  end',
		'  uninstall_postflight do\n    stdout, * = system_command "/usr/bin/security", args: ["find-certificate", "-a", "-c", "Charles", "-Z"], sudo: true\n    hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }\n    hashes.each do |h|\n      system_command "/usr/bin/security", args: ["delete-certificate", "-Z", h], sudo: true\n    end\n    system_command "/usr/bin/true"\n  end',
	] {
		if install_steps_core.audit_cask_install_steps(install_steps_spec_source(body), '').len != 0 {
			return false
		}
	}
	return true
}

// Ruby it `it "does not re-report declarative keychain, permission or ownership steps" do` at line 422.
pub fn ruby_install_steps_spec_l422_d15_does() bool {
	source := install_steps_spec_source('  uninstall_postflight_steps do\n    delete_keychain_certificates "Charles"\n    set_permissions "Foo.app", "0755"\n    set_ownership "Foo.app", user: "root", group: "wheel"\n  end')
	return install_steps_core.audit_cask_install_steps(source, '').len == 0
}

// Ruby it `it "autocorrects pure permission and ownership flight blocks" do` at line 437.
pub fn ruby_install_steps_spec_l437_d16_autocorrects() bool {
	source := install_steps_spec_source('  preflight do\n    set_permissions "#{staged_path}/Foo.app", "0755"\n  end\n\n  postflight do\n    set_permissions "#{appdir}/Foo.app", "0555"\n    set_ownership "#{HOMEBREW_PREFIX}/foo"\n  end\n\n  uninstall_preflight do\n    set_ownership ["/usr/local/include", "/usr/local/lib"], user: "root", group: "wheel"\n  end\n\n  uninstall_postflight do\n    set_ownership staged_path.to_s\n  end')
	expected := install_steps_spec_source('  preflight_steps do\n    set_permissions "Foo.app", "0755"\n  end\n\n  postflight_steps do\n    set_permissions "Foo.app", "0555", base: :appdir\n    set_ownership "foo", base: :homebrew_prefix\n  end\n\n  uninstall_preflight_steps do\n    set_ownership ["/usr/local/include", "/usr/local/lib"], user: "root", group: "wheel"\n  end\n\n  uninstall_postflight_steps do\n    set_ownership "."\n  end')
	return install_steps_core.correct_cask_install_steps(source, '') == expected
}

// Ruby it `it "does not autocorrect dynamic, unsupported or mixed permission work" do` at line 491.
pub fn ruby_install_steps_spec_l491_d17_does() bool {
	for body in [
		'  postflight do\n    set_ownership "#{staged_path}/foo-#{arch}"\n  end',
		'  postflight do\n    set_permissions "#{staged_path}/Foo.app", "0755", recursive: false\n  end',
		'  postflight do\n    set_ownership ["#{staged_path}/Foo.app", "#{appdir}/Foo.app"]\n  end',
		'  postflight do\n    set_permissions "#{staged_path}/Foo.app", "0755"\n    system_command "/usr/bin/true"\n  end',
	] {
		if install_steps_core.audit_cask_install_steps(install_steps_spec_source(body), '').len != 0 {
			return false
		}
	}
	return true
}

// Ruby it `it "autocorrects config writes without trailing newlines" do` at line 538.
pub fn ruby_install_steps_spec_l538_d18_autocorrects() bool {
	source := install_steps_spec_source('  postflight do\n    File.write staged_path/"Prepared/foo.conf", "key = value"\n  end')
	expected := install_steps_spec_source('  postflight_steps do\n    write_file "Prepared/foo.conf", "key = value"\n  end')
	return install_steps_core.correct_cask_install_steps(source, '') == expected
}

// Ruby it `it "does not autocorrect non-file preparation in flight blocks" do` at line 563.
pub fn ruby_install_steps_spec_l563_d19_does() bool {
	source := install_steps_spec_source('  postflight do\n    system_command "/usr/bin/true"\n  end')
	return install_steps_core.audit_cask_install_steps(source, '').len == 0
}

// Ruby it `it "does not autocorrect formula rebuild actions in flight blocks" do` at line 576.
pub fn ruby_install_steps_spec_l576_d20_does() bool {
	source := install_steps_spec_source('  postflight do\n    system Formula["desktop-file-utils"].opt_bin/"update-desktop-database", HOMEBREW_PREFIX/"share/applications"\n  end')
	return install_steps_core.audit_cask_install_steps(source, '').len == 0
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/rubocop-cask"
// 5:
// 6: RSpec.describe RuboCop::Cop::Cask::InstallSteps, :config do
// 7:   it "allows a flight block after matching steps in third-party taps during migration" do
// 8:     expect_no_offenses <<~CASK, "/Taps/example/homebrew-cask/Casks/f/foo.rb"
// 9:       cask "foo" do
// 10:         version :latest
// 11:         sha256 :no_check
// 12:
// 13:         postflight_steps do
// 14:           touch "foo"
// 15:         end
// 16:
// 17:         postflight do
// 18:           touch "foo"
// 19:         end
// 20:       end
// 21:     CASK
// 22:   end
// 23:
// 24:   it "rejects flight blocks in official Homebrew taps" do
// 25:     expect_offense <<~CASK, "/Taps/homebrew/homebrew-example/Casks/f/foo.rb"
// 26:       cask "foo" do
// 27:         version :latest
// 28:         sha256 :no_check
// 29:
// 30:         postflight_steps do
// 31:           touch "foo"
// 32:         end
// 33:
// 34:         postflight do
// 35:         ^^^^^^^^^^^^^ Casks in official Homebrew taps must use `postflight_steps` instead of `postflight`.
// 36:           touch "foo"
// 37:         end
// 38:       end
// 39:     CASK
// 40:   end
// 41:
// 42:   it "reports an offense when a steps block contains Ruby code" do
// 43:     expect_offense <<~CASK
// 44:       cask "foo" do
// 45:         version :latest
// 46:         sha256 :no_check
// 47:
// 48:         preflight_steps do
// 49:           system "true"
// 50:           ^^^^^^^^^^^^^ Steps blocks may only contain install step DSL calls. Prefer canonical calls: `mkdir_p`, `touch`, `move`, `move_contents`, `copy`, `remove`, `inreplace`, `symlink`, `write_file`, `delete_keychain_certificates`, `set_permissions`, `set_ownership`, `run`, `terminate_process`, `change_dylib_id`, `if_path_exists`, `unless_path_exists`, `on_macos`, `on_linux`.
// 51:         end
// 52:       end
// 53:     CASK
// 54:   end
// 55:
// 56:   it "rejects `brew ruby` in steps blocks" do
// 57:     expect_offense <<~CASK
// 58:       cask "foo" do
// 59:         version :latest
// 60:         sha256 :no_check
// 61:
// 62:         preflight_steps do
// 63:           run "{{HOMEBREW_BREW_FILE}}", args: ["ruby", "--", "{{staged_path}}/post-install.rb"]
// 64:               ^^^^^^^^^^^^^^^^^^^^^^^^ Install steps must not use `brew ruby` because it enables developer mode.
// 65:         end
// 66:       end
// 67:     CASK
// 68:   end
// 69:
// 70:   it "reports an offense when cask steps contain formula rebuild actions" do
// 71:     expect_offense <<~CASK
// 72:       cask "foo" do
// 73:         version :latest
// 74:         sha256 :no_check
// 75:
// 76:         preflight_steps do
// 77:           update_desktop_database
// 78:           ^^^^^^^^^^^^^^^^^^^^^^^ Steps blocks may only contain install step DSL calls. Prefer canonical calls: `mkdir_p`, `touch`, `move`, `move_contents`, `copy`, `remove`, `inreplace`, `symlink`, `write_file`, `delete_keychain_certificates`, `set_permissions`, `set_ownership`, `run`, `terminate_process`, `change_dylib_id`, `if_path_exists`, `unless_path_exists`, `on_macos`, `on_linux`.
// 79:         end
// 80:       end
// 81:     CASK
// 82:   end
// 83:
// 84:   it "accepts install step DSL calls" do
// 85:     expect_no_offenses <<~'CASK'
// 86:       cask "foo" do
// 87:         version :latest
// 88:         sha256 :no_check
// 89:
// 90:         preflight_steps do
// 91:           mkdir_p "foo"
// 92:           touch "foo/state"
// 93:           touch "#{token}/state"
// 94:           move "source", "target"
// 95:           move_contents "source", "target"
// 96:           inreplace "foo.conf", "@PREFIX@", "{{HOMEBREW_PREFIX}}"
// 97:           symlink "source", "target", source_base: :relative, overwrite: true, remove_on_uninstall: true
// 98:           write_file "foo.conf", "key = value\n"
// 99:           set_permissions "Foo.app", "0755"
// 100:           set_ownership "Foo.app", user: "root", group: "wheel"
// 101:           run "foo", args: ["--repair"], writable_paths: ["Library/Application Support/Foo"], writable_base: :home
// 102:           terminate_process "foo", attempts: 3
// 103:           change_dylib_id "Foo.app/Contents/Frameworks/libfoo.dylib", "@rpath/libfoo.dylib"
// 104:           delete_keychain_certificates "Charles"
// 105:           delete_keychain_certificates "NodeMITMProxyCA", fingerprint_of: "~/Library/Application Support/betwixt/ssl/certs/ca.pem"
// 106:           on_macos do
// 107:             if_path_exists "Foo.app" do
// 108:               touch "Foo.app/marker"
// 109:             end
// 110:           end
// 111:           on_linux do
// 112:             unless_path_exists "foo.conf" do
// 113:               write_file "foo.conf", "key = value\n"
// 114:             end
// 115:           end
// 116:         end
// 117:       end
// 118:     CASK
// 119:   end
// 120:
// 121:   it "autocorrects legacy install step names" do
// 122:     expect_offense <<~CASK
// 123:       cask "foo" do
// 124:         version :latest
// 125:         sha256 :no_check
// 126:
// 127:         preflight_steps do
// 128:           mkdir "foo"
// 129:           ^^^^^ Use `mkdir_p` instead of legacy install step `mkdir`.
// 130:           mv "source", "target"
// 131:           ^^ Use `move` instead of legacy install step `mv`.
// 132:           move_children "source", "target"
// 133:           ^^^^^^^^^^^^^ Use `move_contents` instead of legacy install step `move_children`.
// 134:           ln_s "source", "target"
// 135:           ^^^^ Use `symlink` instead of legacy install step `ln_s`.
// 136:           ln_sf "source", "target"
// 137:           ^^^^^ Use `symlink` instead of legacy install step `ln_sf`.
// 138:           write "foo.conf", "content"
// 139:           ^^^^^ Use `write_file` instead of legacy install step `write`.
// 140:           write "banner", <<~TEXT
// 141:           ^^^^^ Use `write_file` instead of legacy install step `write`.
// 142:             banner
// 143:           TEXT
// 144:           delete_keychain_certificate "Charles", matching_certificate: "certificate.pem"
// 145:                                                  ^^^^^^^^^^^^^^^^^^^^ Use `fingerprint_of:` instead of legacy install step keyword `matching_certificate:`.
// 146:           ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `delete_keychain_certificates` instead of legacy install step `delete_keychain_certificate`.
// 147:         end
// 148:       end
// 149:     CASK
// 150:
// 151:     expect_correction <<~CASK
// 152:       cask "foo" do
// 153:         version :latest
// 154:         sha256 :no_check
// 155:
// 156:         preflight_steps do
// 157:           mkdir_p "foo"
// 158:           move "source", "target"
// 159:           move_contents "source", "target"
// 160:           symlink "source", "target"
// 161:           symlink "source", "target", overwrite: true
// 162:           write_file "foo.conf", "content", overwrite: false, append_newline: true
// 163:           write_file "banner", <<~TEXT, overwrite: false, append_newline: true
// 164:             banner
// 165:           TEXT
// 166:           delete_keychain_certificates "Charles", fingerprint_of: "certificate.pem"
// 167:         end
// 168:       end
// 169:     CASK
// 170:   end
// 171:
// 172:   it "autocorrects legacy install step keywords" do
// 173:     expect_offense <<~CASK
// 174:       cask "foo" do
// 175:         version :latest
// 176:         sha256 :no_check
// 177:
// 178:         preflight_steps do
// 179:           delete_keychain_certificates "Charles",
// 180:                                        matching_certificate: "certificate.pem"
// 181:                                        ^^^^^^^^^^^^^^^^^^^^ Use `fingerprint_of:` instead of legacy install step keyword `matching_certificate:`.
// 182:         end
// 183:       end
// 184:     CASK
// 185:
// 186:     expect_correction <<~CASK
// 187:       cask "foo" do
// 188:         version :latest
// 189:         sha256 :no_check
// 190:
// 191:         preflight_steps do
// 192:           delete_keychain_certificates "Charles",
// 193:                                        fingerprint_of: "certificate.pem"
// 194:         end
// 195:       end
// 196:     CASK
// 197:   end
// 198:
// 199:   it "reports an offense when a step string uses unsupported interpolation" do
// 200:     expect_offense <<~'CASK'
// 201:       cask "foo" do
// 202:         version :latest
// 203:         sha256 :no_check
// 204:
// 205:         preflight_steps do
// 206:           touch "#{appdir}/state"
// 207:                  ^^^^^^^^^ Steps blocks may only contain install step DSL calls. Prefer canonical calls: `mkdir_p`, `touch`, `move`, `move_contents`, `copy`, `remove`, `inreplace`, `symlink`, `write_file`, `delete_keychain_certificates`, `set_permissions`, `set_ownership`, `run`, `terminate_process`, `change_dylib_id`, `if_path_exists`, `unless_path_exists`, `on_macos`, `on_linux`.
// 208:         end
// 209:       end
// 210:     CASK
// 211:   end
// 212:
// 213:   it "reports an offense when a scope contains Ruby code" do
// 214:     expect_offense <<~CASK
// 215:       cask "foo" do
// 216:         version :latest
// 217:         sha256 :no_check
// 218:
// 219:         preflight_steps do
// 220:           on_macos do
// 221:             system "true"
// 222:             ^^^^^^^^^^^^^ Steps blocks may only contain install step DSL calls. Prefer canonical calls: `mkdir_p`, `touch`, `move`, `move_contents`, `copy`, `remove`, `inreplace`, `symlink`, `write_file`, `delete_keychain_certificates`, `set_permissions`, `set_ownership`, `run`, `terminate_process`, `change_dylib_id`, `if_path_exists`, `unless_path_exists`, `on_macos`, `on_linux`.
// 223:           end
// 224:         end
// 225:       end
// 226:     CASK
// 227:   end
// 228:
// 229:   it "autocorrects simple flight block file preparation" do
// 230:     expect_offense <<~CASK, "/Taps/homebrew/homebrew-cask/Casks/f/foo.rb"
// 231:       cask "foo" do
// 232:         version :latest
// 233:         sha256 :no_check
// 234:
// 235:         postflight do
// 236:         ^^^^^^^^^^^^^ Use `postflight_steps` for simple file preparation.
// 237:           (staged_path/"Prepared").mkpath
// 238:           FileUtils.touch staged_path/"Prepared/touched"
// 239:           FileUtils.mv staged_path/"source", staged_path/"target"
// 240:           FileUtils.ln_s "target", staged_path/"Linked"
// 241:         end
// 242:       end
// 243:     CASK
// 244:
// 245:     expect_correction <<~CASK
// 246:       cask "foo" do
// 247:         version :latest
// 248:         sha256 :no_check
// 249:
// 250:         postflight_steps do
// 251:           mkdir_p "Prepared"
// 252:           touch "Prepared/touched"
// 253:           move "source", "target"
// 254:           symlink "target", "Linked", source_base: :relative
// 255:         end
// 256:       end
// 257:     CASK
// 258:   end
// 259:
// 260:   it "autocorrects simple flight block config writes" do
// 261:     expect_offense <<~'CASK'
// 262:       cask "foo" do
// 263:         version :latest
// 264:         sha256 :no_check
// 265:
// 266:         postflight do
// 267:         ^^^^^^^^^^^^^ Use `postflight_steps` for simple file preparation.
// 268:           File.write staged_path/"Prepared/foo.conf", "key = value\n"
// 269:         end
// 270:       end
// 271:     CASK
// 272:
// 273:     expect_correction <<~'CASK'
// 274:       cask "foo" do
// 275:         version :latest
// 276:         sha256 :no_check
// 277:
// 278:         postflight_steps do
// 279:           write_file "Prepared/foo.conf", "key = value\n"
// 280:         end
// 281:       end
// 282:     CASK
// 283:   end
// 284:
// 285:   it "autocorrects fixed keychain certificate deletion flight blocks" do
// 286:     expect_offense <<~CASK
// 287:       cask "foo" do
// 288:         version :latest
// 289:         sha256 :no_check
// 290:
// 291:         preflight do
// 292:         ^^^^^^^^^^^^ Use `preflight_steps` for simple file preparation.
// 293:           stdout, * = system_command "/usr/bin/security",
// 294:                                      args: ["find-certificate", "-a", "-c", "Charles", "-Z"],
// 295:                                      sudo: true
// 296:           hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }
// 297:           hashes.each do |h|
// 298:             system_command "/usr/bin/security",
// 299:                            args: ["delete-certificate", "-Z", h],
// 300:                            sudo: true
// 301:           end
// 302:         end
// 303:
// 304:         postflight do
// 305:         ^^^^^^^^^^^^^ Use `postflight_steps` for simple file preparation.
// 306:           ["AutoFirma ROOT", "127.0.0.1"].each do |cert_name|
// 307:             stdout, * = system_command "/usr/bin/security",
// 308:                                        args: ["find-certificate", "-a", "-c", cert_name, "-Z"],
// 309:                                        sudo: true
// 310:             hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }
// 311:             hashes.each do |h|
// 312:               system_command "/usr/bin/security",
// 313:                              args: ["delete-certificate", "-Z", h],
// 314:                              sudo: true
// 315:             end
// 316:           end
// 317:         end
// 318:
// 319:         uninstall_postflight do
// 320:         ^^^^^^^^^^^^^^^^^^^^^^^ Use `uninstall_postflight_steps` for simple file preparation.
// 321:           cert = Pathname("~/Library/Application Support/betwixt/ssl/certs/ca.pem").expand_path
// 322:           next unless cert.exist?
// 323:
// 324:           stdout, * = system_command "/usr/bin/openssl",
// 325:                                      args: ["x509", "-fingerprint", "-sha256", "-noout", "-in", cert]
// 326:           hash = stdout.lines.first.split("=").second.delete(":").strip
// 327:           stdout, * = system_command "/usr/bin/security",
// 328:                                      args: ["find-certificate", "-a", "-c", "NodeMITMProxyCA", "-Z"],
// 329:                                      sudo: true
// 330:           hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }
// 331:           if hashes.include?(hash)
// 332:             system_command "/usr/bin/security",
// 333:                            args: ["delete-certificate", "-Z", hash],
// 334:                            sudo: true
// 335:           end
// 336:         end
// 337:       end
// 338:     CASK
// 339:
// 340:     expect_correction <<~CASK
// 341:       cask "foo" do
// 342:         version :latest
// 343:         sha256 :no_check
// 344:
// 345:         preflight_steps do
// 346:           delete_keychain_certificates "Charles"
// 347:         end
// 348:
// 349:         postflight_steps do
// 350:           delete_keychain_certificates "AutoFirma ROOT"
// 351:           delete_keychain_certificates "127.0.0.1"
// 352:         end
// 353:
// 354:         uninstall_postflight_steps do
// 355:           delete_keychain_certificates "NodeMITMProxyCA",
// 356:                                        fingerprint_of: "~/Library/Application Support/betwixt/ssl/certs/ca.pem"
// 357:         end
// 358:       end
// 359:     CASK
// 360:   end
// 361:
// 362:   it "does not autocorrect altered or mixed keychain deletion blocks" do
// 363:     expect_no_offenses <<~CASK
// 364:       cask "foo" do
// 365:         version :latest
// 366:         sha256 :no_check
// 367:
// 368:         uninstall_postflight do
// 369:           stdout, * = system_command "/usr/local/bin/security",
// 370:                                      args: ["find-certificate", "-a", "-c", "Charles", "-Z"],
// 371:                                      sudo: true
// 372:           hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }
// 373:           hashes.each do |h|
// 374:             system_command "/usr/local/bin/security",
// 375:                            args: ["delete-certificate", "-Z", h],
// 376:                            sudo: true
// 377:           end
// 378:         end
// 379:       end
// 380:     CASK
// 381:
// 382:     expect_no_offenses <<~CASK
// 383:       cask "foo" do
// 384:         version :latest
// 385:         sha256 :no_check
// 386:
// 387:         uninstall_postflight do
// 388:           stdout, * = system_command "/usr/bin/security",
// 389:                                      args: ["find-certificate", "-a", "-c", "Charles", "-Z", "login.keychain"],
// 390:                                      sudo: true
// 391:           hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }
// 392:           hashes.each do |h|
// 393:             system_command "/usr/bin/security",
// 394:                            args: ["delete-certificate", "-Z", h],
// 395:                            sudo: true
// 396:           end
// 397:         end
// 398:       end
// 399:     CASK
// 400:
// 401:     expect_no_offenses <<~CASK
// 402:       cask "foo" do
// 403:         version :latest
// 404:         sha256 :no_check
// 405:
// 406:         uninstall_postflight do
// 407:           stdout, * = system_command "/usr/bin/security",
// 408:                                      args: ["find-certificate", "-a", "-c", "Charles", "-Z"],
// 409:                                      sudo: true
// 410:           hashes = stdout.lines.grep(/^SHA-256 hash:/) { |l| l.split(":").second.strip }
// 411:           hashes.each do |h|
// 412:             system_command "/usr/bin/security",
// 413:                            args: ["delete-certificate", "-Z", h],
// 414:                            sudo: true
// 415:           end
// 416:           system_command "/usr/bin/true"
// 417:         end
// 418:       end
// 419:     CASK
// 420:   end
// 421:
// 422:   it "does not re-report declarative keychain, permission or ownership steps" do
// 423:     expect_no_offenses <<~CASK
// 424:       cask "foo" do
// 425:         version :latest
// 426:         sha256 :no_check
// 427:
// 428:         uninstall_postflight_steps do
// 429:           delete_keychain_certificates "Charles"
// 430:           set_permissions "Foo.app", "0755"
// 431:           set_ownership "Foo.app", user: "root", group: "wheel"
// 432:         end
// 433:       end
// 434:     CASK
// 435:   end
// 436:
// 437:   it "autocorrects pure permission and ownership flight blocks" do
// 438:     expect_offense <<~'CASK'
// 439:       cask "foo" do
// 440:         version :latest
// 441:         sha256 :no_check
// 442:
// 443:         preflight do
// 444:         ^^^^^^^^^^^^ Use `preflight_steps` for simple file preparation.
// 445:           set_permissions "#{staged_path}/Foo.app", "0755"
// 446:         end
// 447:
// 448:         postflight do
// 449:         ^^^^^^^^^^^^^ Use `postflight_steps` for simple file preparation.
// 450:           set_permissions "#{appdir}/Foo.app", "0555"
// 451:           set_ownership "#{HOMEBREW_PREFIX}/foo"
// 452:         end
// 453:
// 454:         uninstall_preflight do
// 455:         ^^^^^^^^^^^^^^^^^^^^^^ Use `uninstall_preflight_steps` for simple file preparation.
// 456:           set_ownership ["/usr/local/include", "/usr/local/lib"], user: "root", group: "wheel"
// 457:         end
// 458:
// 459:         uninstall_postflight do
// 460:         ^^^^^^^^^^^^^^^^^^^^^^^ Use `uninstall_postflight_steps` for simple file preparation.
// 461:           set_ownership staged_path.to_s
// 462:         end
// 463:       end
// 464:     CASK
// 465:
// 466:     expect_correction <<~CASK
// 467:       cask "foo" do
// 468:         version :latest
// 469:         sha256 :no_check
// 470:
// 471:         preflight_steps do
// 472:           set_permissions "Foo.app", "0755"
// 473:         end
// 474:
// 475:         postflight_steps do
// 476:           set_permissions "Foo.app", "0555", base: :appdir
// 477:           set_ownership "foo", base: :homebrew_prefix
// 478:         end
// 479:
// 480:         uninstall_preflight_steps do
// 481:           set_ownership ["/usr/local/include", "/usr/local/lib"], user: "root", group: "wheel"
// 482:         end
// 483:
// 484:         uninstall_postflight_steps do
// 485:           set_ownership "."
// 486:         end
// 487:       end
// 488:     CASK
// 489:   end
// 490:
// 491:   it "does not autocorrect dynamic, unsupported or mixed permission work" do
// 492:     expect_no_offenses <<~'CASK'
// 493:       cask "foo" do
// 494:         version :latest
// 495:         sha256 :no_check
// 496:
// 497:         postflight do
// 498:           set_ownership "#{staged_path}/foo-#{arch}"
// 499:         end
// 500:       end
// 501:     CASK
// 502:
// 503:     expect_no_offenses <<~'CASK'
// 504:       cask "foo" do
// 505:         version :latest
// 506:         sha256 :no_check
// 507:
// 508:         postflight do
// 509:           set_permissions "#{staged_path}/Foo.app", "0755", recursive: false
// 510:         end
// 511:       end
// 512:     CASK
// 513:
// 514:     expect_no_offenses <<~'CASK'
// 515:       cask "foo" do
// 516:         version :latest
// 517:         sha256 :no_check
// 518:
// 519:         postflight do
// 520:           set_ownership ["#{staged_path}/Foo.app", "#{appdir}/Foo.app"]
// 521:         end
// 522:       end
// 523:     CASK
// 524:
// 525:     expect_no_offenses <<~'CASK'
// 526:       cask "foo" do
// 527:         version :latest
// 528:         sha256 :no_check
// 529:
// 530:         postflight do
// 531:           set_permissions "#{staged_path}/Foo.app", "0755"
// 532:           system_command "/usr/bin/true"
// 533:         end
// 534:       end
// 535:     CASK
// 536:   end
// 537:
// 538:   it "autocorrects config writes without trailing newlines" do
// 539:     expect_offense <<~CASK
// 540:       cask "foo" do
// 541:         version :latest
// 542:         sha256 :no_check
// 543:
// 544:         postflight do
// 545:         ^^^^^^^^^^^^^ Use `postflight_steps` for simple file preparation.
// 546:           File.write staged_path/"Prepared/foo.conf", "key = value"
// 547:         end
// 548:       end
// 549:     CASK
// 550:
// 551:     expect_correction <<~CASK
// 552:       cask "foo" do
// 553:         version :latest
// 554:         sha256 :no_check
// 555:
// 556:         postflight_steps do
// 557:           write_file "Prepared/foo.conf", "key = value"
// 558:         end
// 559:       end
// 560:     CASK
// 561:   end
// 562:
// 563:   it "does not autocorrect non-file preparation in flight blocks" do
// 564:     expect_no_offenses <<~CASK
// 565:       cask "foo" do
// 566:         version :latest
// 567:         sha256 :no_check
// 568:
// 569:         postflight do
// 570:           system_command "/usr/bin/true"
// 571:         end
// 572:       end
// 573:     CASK
// 574:   end
// 575:
// 576:   it "does not autocorrect formula rebuild actions in flight blocks" do
// 577:     expect_no_offenses <<~CASK
// 578:       cask "foo" do
// 579:         version :latest
// 580:         sha256 :no_check
// 581:
// 582:         postflight do
// 583:           system Formula["desktop-file-utils"].opt_bin/"update-desktop-database", HOMEBREW_PREFIX/"share/applications"
// 584:         end
// 585:       end
// 586:     CASK
// 587:   end
// 588: end

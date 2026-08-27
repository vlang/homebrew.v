module cask

import brew_runtime

// Translated from Homebrew/brew `cask/quarantine.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.xattr` at line 24.
pub fn ruby_quarantine_l24_d1_self_xattr(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.xattr', ...args)
}

// Ruby method `self.xattr_available?` at line 30.
pub fn ruby_quarantine_l30_d2_self_xattr_available(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.xattr_available?', ...args)
}

// Ruby method `self.check_quarantine_support` at line 38.
pub fn ruby_quarantine_l38_d3_self_check_quarantine_support(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.check_quarantine_support', ...args)
}

// Ruby method `self.available?` at line 43.
pub fn ruby_quarantine_l43_d4_self_available(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.available?', ...args)
}

// Ruby method `self.detect(file)` at line 50.
pub fn ruby_quarantine_l50_d5_self_detect(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.detect', ...args)
}

// Ruby method `self.status(file)` at line 63.
pub fn ruby_quarantine_l63_d6_self_status(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.status', ...args)
}

// Ruby method `self.user_approved?(file)` at line 73.
pub fn ruby_quarantine_l73_d7_self_user_approved(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.user_approved?', ...args)
}

// Ruby method `self.inherit_user_approval!(download_path: nil)` at line 83.
pub fn ruby_quarantine_l83_d8_self_inherit_user_approval(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.inherit_user_approval!', ...args)
}

// Ruby method `self.signing_identity(_file); end` at line 111.
pub fn ruby_quarantine_l111_d9_self_signing_identity(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.signing_identity', ...args)
}

// Ruby method `self.signing_identity_match(_file, _identity); end` at line 117.
pub fn ruby_quarantine_l117_d10_self_signing_identity_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.signing_identity_match', ...args)
}

// Ruby method `self.toggle_no_translocation_bit(attribute)` at line 120.
pub fn ruby_quarantine_l120_d11_self_toggle_no_translocation_bit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.toggle_no_translocation_bit', ...args)
}

// Ruby method `self.release!(download_path: nil)` at line 134.
pub fn ruby_quarantine_l134_d12_self_release(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.release!', ...args)
}

// Ruby method `self.cask!(cask: nil, download_path: nil, action: true)` at line 156.
pub fn ruby_quarantine_l156_d13_self_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cask!', ...args)
}

// Ruby method `self.propagate(from: nil, to: nil)` at line 161.
pub fn ruby_quarantine_l161_d14_self_propagate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.propagate', ...args)
}

// Ruby method `self.copy_xattrs(from, to, command:)` at line 203.
pub fn ruby_quarantine_l203_d15_self_copy_xattrs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.copy_xattrs', ...args)
}

// Ruby method `self.app_management_permissions_granted?(app:, command:)` at line 211.
pub fn ruby_quarantine_l211_d16_self_app_management_permissions_granted(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.app_management_permissions_granted?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "development_tools"
// 5: require "cask/exceptions"
// 6: require "system_command"
// 7: require "utils/output"
// 8:
// 9: module Cask
// 10:   # Helper module for quarantining files.
// 11:   module Quarantine
// 12:     extend SystemCommand::Mixin
// 13:     extend ::Utils::Output::Mixin
// 14:
// 15:     class SigningIdentity < T::Struct
// 16:       const :requirement, String
// 17:     end
// 18:
// 19:     QUARANTINE_ATTRIBUTE = "com.apple.quarantine"
// 20:     # https://github.com/apple-oss-distributions/WebKit/blob/WebKit-7618.2.12.11.6/Source/WebCore/PAL/pal/spi/mac/QuarantineSPI.h#L40-L45
// 21:     USER_APPROVED_FLAG = 0x0040
// 22:
// 23:     sig { returns(T.nilable(Pathname)) }
// 24:     def self.xattr
// 25:       @xattr ||= T.let(DevelopmentTools.locate("xattr"), T.nilable(Pathname))
// 26:     end
// 27:     private_class_method :xattr
// 28:
// 29:     sig { returns(T::Boolean) }
// 30:     def self.xattr_available?
// 31:       xattr = self.xattr
// 32:       return false if xattr.nil?
// 33:
// 34:       system_command(xattr, args: ["-h"], print_stderr: false).success?
// 35:     end
// 36:
// 37:     sig { returns([Symbol, T.nilable(String)]) }
// 38:     def self.check_quarantine_support
// 39:       [:quarantine_unavailable, nil]
// 40:     end
// 41:
// 42:     sig { returns(T::Boolean) }
// 43:     def self.available?
// 44:       @quarantine_support ||= T.let(check_quarantine_support, T.nilable([Symbol, T.nilable(String)]))
// 45:
// 46:       @quarantine_support[0] == :quarantine_available
// 47:     end
// 48:
// 49:     sig { params(file: T.nilable(T.any(String, Pathname))).returns(T.nilable(T::Boolean)) }
// 50:     def self.detect(file)
// 51:       return if file.nil?
// 52:
// 53:       odebug "Verifying Gatekeeper status of #{file}"
// 54:
// 55:       quarantine_status = !status(file).empty?
// 56:
// 57:       odebug "#{file} is #{quarantine_status ? "quarantined" : "not quarantined"}"
// 58:
// 59:       quarantine_status
// 60:     end
// 61:
// 62:     sig { params(file: T.any(String, Pathname)).returns(String) }
// 63:     def self.status(file)
// 64:       xattr = self.xattr
// 65:       raise "unexpected nil xattr" if xattr.nil?
// 66:
// 67:       system_command(xattr,
// 68:                      args:         ["-p", QUARANTINE_ATTRIBUTE, file],
// 69:                      print_stderr: false).stdout.rstrip
// 70:     end
// 71:
// 72:     sig { params(file: T.any(String, Pathname)).returns(T::Boolean) }
// 73:     def self.user_approved?(file)
// 74:       return false if xattr.nil?
// 75:
// 76:       quarantine_status = status(file)
// 77:       return false if quarantine_status.empty?
// 78:
// 79:       quarantine_status.split(";").fetch(0).to_i(16).anybits?(USER_APPROVED_FLAG)
// 80:     end
// 81:
// 82:     sig { params(download_path: T.nilable(Pathname)).void }
// 83:     def self.inherit_user_approval!(download_path: nil)
// 84:       return if !download_path || !detect(download_path)
// 85:
// 86:       # Preserve quarantine provenance so Gatekeeper still checks the upgraded app while carrying forward
// 87:       # the user's approval only after the upgrade path verifies that its signing identity is unchanged.
// 88:       # https://developer.apple.com/forums/thread/706442
// 89:       odebug "Inheriting user approval for #{download_path}"
// 90:
// 91:       xattr = self.xattr
// 92:       raise "unexpected nil xattr" if xattr.nil?
// 93:
// 94:       quarantiner = system_command(xattr,
// 95:                                    args:         [
// 96:                                      "-w",
// 97:                                      QUARANTINE_ATTRIBUTE,
// 98:                                      status(download_path).sub(/\A[0-9a-f]+/i) do |flags|
// 99:                                        (flags.to_i(16) | USER_APPROVED_FLAG).to_s(16).rjust(flags.length, "0")
// 100:                                      end,
// 101:                                      download_path,
// 102:                                    ],
// 103:                                    print_stderr: false)
// 104:
// 105:       return if quarantiner.success?
// 106:
// 107:       raise CaskQuarantineReleaseError.new(download_path, quarantiner.stderr)
// 108:     end
// 109:
// 110:     sig { params(_file: T.any(String, Pathname)).returns(T.nilable(SigningIdentity)) }
// 111:     def self.signing_identity(_file); end
// 112:
// 113:     sig {
// 114:       params(_file: T.any(String, Pathname), _identity: SigningIdentity)
// 115:         .returns(T.nilable(T::Boolean))
// 116:     }
// 117:     def self.signing_identity_match(_file, _identity); end
// 118:
// 119:     sig { params(attribute: String).returns(String) }
// 120:     def self.toggle_no_translocation_bit(attribute)
// 121:       fields = attribute.split(";")
// 122:
// 123:       # Fields: status, epoch, download agent, event ID
// 124:       # Let's toggle the app translocation bit, bit 8
// 125:       # http://www.openradar.me/radar?id=5022734169931776
// 126:
// 127:       fields[0] = (fields.fetch(0).to_i(16) | 0x0100).to_s(16).rjust(4, "0")
// 128:
// 129:       fields.join(";")
// 130:     end
// 131:
// 132:     # Fully remove quarantine only when explicitly requested; upgrades preserve it and inherit approval above.
// 133:     sig { params(download_path: T.nilable(Pathname)).void }
// 134:     def self.release!(download_path: nil)
// 135:       return if !download_path || !detect(download_path)
// 136:
// 137:       odebug "Releasing #{download_path} from quarantine"
// 138:
// 139:       xattr = self.xattr
// 140:       raise "unexpected nil xattr" if xattr.nil?
// 141:
// 142:       quarantiner = system_command(xattr,
// 143:                                    args:         [
// 144:                                      "-d",
// 145:                                      QUARANTINE_ATTRIBUTE,
// 146:                                      download_path,
// 147:                                    ],
// 148:                                    print_stderr: false)
// 149:
// 150:       return if quarantiner.success?
// 151:
// 152:       raise CaskQuarantineReleaseError.new(download_path, quarantiner.stderr)
// 153:     end
// 154:
// 155:     sig { params(cask: T.nilable(Cask), download_path: T.nilable(Pathname), action: T::Boolean).void }
// 156:     def self.cask!(cask: nil, download_path: nil, action: true)
// 157:       raise NotImplementedError
// 158:     end
// 159:
// 160:     sig { params(from: T.nilable(Pathname), to: T.nilable(Pathname)).void }
// 161:     def self.propagate(from: nil, to: nil)
// 162:       return if from.nil? || to.nil?
// 163:
// 164:       raise CaskError, "#{from} was not quarantined properly." unless detect(from)
// 165:
// 166:       odebug "Propagating quarantine from #{from} to #{to}"
// 167:
// 168:       quarantine_status = toggle_no_translocation_bit(status(from))
// 169:
// 170:       resolved_paths = Pathname.glob(to/"**/*", File::FNM_DOTMATCH).reject(&:symlink?)
// 171:
// 172:       system_command!("/usr/bin/xargs",
// 173:                       args:  [
// 174:                         "-0",
// 175:                         "--",
// 176:                         "chmod",
// 177:                         "-h",
// 178:                         "u+w",
// 179:                       ],
// 180:                       input: resolved_paths.join("\0"))
// 181:
// 182:       xattr = self.xattr
// 183:       raise "unexpected nil xattr" if xattr.nil?
// 184:
// 185:       quarantiner = system_command("/usr/bin/xargs",
// 186:                                    args:         [
// 187:                                      "-0",
// 188:                                      "--",
// 189:                                      xattr,
// 190:                                      "-w",
// 191:                                      QUARANTINE_ATTRIBUTE,
// 192:                                      quarantine_status,
// 193:                                    ],
// 194:                                    input:        resolved_paths.join("\0"),
// 195:                                    print_stderr: false)
// 196:
// 197:       return if quarantiner.success?
// 198:
// 199:       raise CaskQuarantinePropagationError.new(to, quarantiner.stderr)
// 200:     end
// 201:
// 202:     sig { params(from: Pathname, to: Pathname, command: T.class_of(SystemCommand)).void }
// 203:     def self.copy_xattrs(from, to, command:)
// 204:       raise NotImplementedError
// 205:     end
// 206:
// 207:     # Ensures that Homebrew has permission to update apps on macOS Ventura.
// 208:     # This may be granted either through the App Management toggle or the Full Disk Access toggle.
// 209:     # The system will only show a prompt for App Management, so we ask the user to grant that.
// 210:     sig { params(app: Pathname, command: T.class_of(SystemCommand)).returns(T::Boolean) }
// 211:     def self.app_management_permissions_granted?(app:, command:)
// 212:       return true unless app.directory?
// 213:
// 214:       # To get macOS to prompt the user for permissions, we need to actually attempt to
// 215:       # modify a file in the app.
// 216:       test_file = app/".homebrew-write-test"
// 217:
// 218:       # We can't use app.writable? here because that conflates several access checks,
// 219:       # including both file ownership and whether system permissions are granted.
// 220:       # Here we just want to check whether sudo would be needed.
// 221:       looks_writable_without_sudo = if app.owned?
// 222:         app.lstat.mode.anybits?(0200)
// 223:       elsif app.grpowned?
// 224:         app.lstat.mode.anybits?(0020)
// 225:       else
// 226:         app.lstat.mode.anybits?(0002)
// 227:       end
// 228:
// 229:       if looks_writable_without_sudo
// 230:         begin
// 231:           File.write(test_file, "")
// 232:           test_file.delete
// 233:           return true
// 234:         rescue Errno::EACCES, Errno::EPERM
// 235:           # Using error handler below
// 236:         end
// 237:       else
// 238:         begin
// 239:           command.run!(
// 240:             "touch",
// 241:             args:         [
// 242:               test_file,
// 243:             ],
// 244:             print_stderr: false,
// 245:             sudo:         true,
// 246:           )
// 247:           command.run!(
// 248:             "rm",
// 249:             args:         [
// 250:               test_file,
// 251:             ],
// 252:             print_stderr: false,
// 253:             sudo:         true,
// 254:           )
// 255:           return true
// 256:         rescue ErrorDuringExecution => e
// 257:           # We only want to handle "touch" errors here; propagate "sudo" errors up
// 258:           raise e unless e.stderr.include?("touch: #{test_file}: Operation not permitted")
// 259:         end
// 260:       end
// 261:
// 262:       # Allow undocumented way to skip the prompt.
// 263:       if ENV["HOMEBREW_NO_APP_MANAGEMENT_PERMISSIONS_PROMPT"]
// 264:         opoo <<~EOF
// 265:           Your terminal does not have App Management permissions, so Homebrew will delete and reinstall the app.
// 266:           This may result in some configurations (like notification settings or location in the Dock/Launchpad) being lost.
// 267:           To fix this, go to System Settings → Privacy & Security → App Management and add or enable your terminal.
// 268:         EOF
// 269:       end
// 270:
// 271:       false
// 272:     end
// 273:   end
// 274: end
// 275:
// 276: require "extend/os/cask/quarantine"

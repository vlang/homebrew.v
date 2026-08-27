module cask

import brew_runtime

// Translated from Homebrew/brew `extend/os/mac/cask/quarantine.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `check_quarantine_support` at line 20.
pub fn ruby_quarantine_l20_d1_check_quarantine_support(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_quarantine_support', ...args)
}

// Ruby method `signing_identity(file)` at line 37.
pub fn ruby_quarantine_l37_d2_signing_identity(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('signing_identity', ...args)
}

// Ruby method `signing_identity_match(file, identity)` at line 50.
pub fn ruby_quarantine_l50_d3_signing_identity_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('signing_identity_match', ...args)
}

// Ruby method `cask!(cask: nil, download_path: nil, action: true)` at line 55.
pub fn ruby_quarantine_l55_d4_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask!', ...args)
}

// Ruby method `copy_xattrs(from, to, command:)` at line 104.
pub fn ruby_quarantine_l104_d5_copy_xattrs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('copy_xattrs', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module Cask
// 9:       module Quarantine
// 10:         COPY_XATTRS_SCRIPT = T.let((HOMEBREW_LIBRARY_PATH/"cask/utils/copy_xattrs.rb").freeze, ::Pathname)
// 11:
// 12:         module ClassMethods
// 13:           extend T::Helpers
// 14:           include Kernel
// 15:           include ::Utils::Output::Mixin
// 16:
// 17:           requires_ancestor { ::Cask::Quarantine }
// 18:
// 19:           sig { returns([Symbol, T.nilable(String)]) }
// 20:           def check_quarantine_support
// 21:             odebug "Checking quarantine support"
// 22:
// 23:             status = if ::Cask::Quarantine.xattr_available?
// 24:               odebug "Quarantine is available via FFI."
// 25:               :quarantine_available
// 26:             else
// 27:               odebug "There's no working version of `xattr` on this system."
// 28:               :xattr_broken
// 29:             end
// 30:             [status, nil]
// 31:           end
// 32:
// 33:           sig {
// 34:             params(file: T.any(String, ::Pathname))
// 35:               .returns(T.nilable(::Cask::Quarantine::SigningIdentity))
// 36:           }
// 37:           def signing_identity(file)
// 38:             requirement = MacOS::FFI::Security.designated_requirement(file.to_s)
// 39:             return if requirement.nil?
// 40:
// 41:             ::Cask::Quarantine::SigningIdentity.new(requirement:)
// 42:           end
// 43:
// 44:           sig {
// 45:             params(
// 46:               file:     T.any(String, ::Pathname),
// 47:               identity: ::Cask::Quarantine::SigningIdentity,
// 48:             ).returns(T.nilable(T::Boolean))
// 49:           }
// 50:           def signing_identity_match(file, identity)
// 51:             MacOS::FFI::Security.requirement_match(file.to_s, identity.requirement)
// 52:           end
// 53:
// 54:           sig { params(cask: T.nilable(::Cask::Cask), download_path: T.nilable(::Pathname), action: T::Boolean).void }
// 55:           def cask!(cask: nil, download_path: nil, action: true)
// 56:             return if cask.nil? || download_path.nil?
// 57:
// 58:             return if ::Cask::Quarantine.detect(download_path)
// 59:
// 60:             odebug "Quarantining #{download_path}"
// 61:
// 62:             path_cf_string = MacOS::FFI::CoreFoundation.string_create(download_path.to_s)
// 63:             if path_cf_string.null?
// 64:               Kernel.raise ::Cask::CaskQuarantineError.new(download_path,
// 65:                                                            "Failed to create CFString for path")
// 66:             end
// 67:
// 68:             path_cf_url = MacOS::FFI::CoreFoundation.url_create_with_file_system_path(path_cf_string)
// 69:             if path_cf_url.null?
// 70:               Kernel.raise ::Cask::CaskQuarantineError.new(download_path,
// 71:                                                            "Failed to create CFURL for path")
// 72:             end
// 73:
// 74:             quarantine_agent_name = MacOS::FFI::CoreFoundation.string_create("Homebrew Cask")
// 75:             quarantine_data_url = MacOS::FFI::CoreFoundation.string_create(cask.url.to_s)
// 76:             quarantine_origin_url = MacOS::FFI::CoreFoundation.string_create(cask.homepage.to_s)
// 77:             if quarantine_agent_name.null? || quarantine_data_url.null? || quarantine_origin_url.null?
// 78:               Kernel.raise ::Cask::CaskQuarantineError.new(download_path,
// 79:                                                            "Failed to create CFString for quarantine properties")
// 80:             end
// 81:
// 82:             quarantine_dictionary = MacOS::FFI::CoreFoundation.dictionary_create(
// 83:               MacOS::FFI::LaunchServices.quarantine_agent_name_key => quarantine_agent_name,
// 84:               MacOS::FFI::LaunchServices.quarantine_type_key       => MacOS::FFI::LaunchServices.quarantine_type_web_download,
// 85:               MacOS::FFI::LaunchServices.quarantine_data_url_key   => quarantine_data_url,
// 86:               MacOS::FFI::LaunchServices.quarantine_origin_url_key => quarantine_origin_url,
// 87:             )
// 88:             if quarantine_dictionary.null?
// 89:               Kernel.raise ::Cask::CaskQuarantineError.new(download_path, "Failed to create quarantine dictionary")
// 90:             end
// 91:
// 92:             success = MacOS::FFI::CoreFoundation.url_set_resource_property_for_key(
// 93:               path_cf_url,
// 94:               MacOS::FFI::CoreFoundation.url_quarantine_properties_key,
// 95:               quarantine_dictionary,
// 96:             )
// 97:
// 98:             return if success
// 99:
// 100:             Kernel.raise ::Cask::CaskQuarantineError.new(download_path, "Failed to set quarantine properties for URL")
// 101:           end
// 102:
// 103:           sig { params(from: ::Pathname, to: ::Pathname, command: T.class_of(::SystemCommand)).void }
// 104:           def copy_xattrs(from, to, command:)
// 105:             odebug "Copying xattrs from #{from} to #{to}"
// 106:
// 107:             if to.writable?
// 108:               MacOS::FFI.copy_xattrs(from.to_s, to.to_s)
// 109:               return
// 110:             end
// 111:
// 112:             ruby, *args = HOMEBREW_RUBY_EXEC_ARGS
// 113:             command.run!(
// 114:               ruby,
// 115:               args: args + [
// 116:                 "-I",
// 117:                 $LOAD_PATH.join(File::PATH_SEPARATOR),
// 118:                 COPY_XATTRS_SCRIPT,
// 119:                 from,
// 120:                 to,
// 121:               ],
// 122:               sudo: true,
// 123:             )
// 124:           end
// 125:         end
// 126:       end
// 127:     end
// 128:   end
// 129: end
// 130:
// 131: Cask::Quarantine.singleton_class.prepend(OS::Mac::Cask::Quarantine::ClassMethods)

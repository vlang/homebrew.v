module extensions

import brew_runtime

// Translated from Homebrew/brew `bundle/extensions/go.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `type = :go` at line 11.
pub fn ruby_go_l11_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby method `check_label = "Go Package"` at line 14.
pub fn ruby_go_l14_d2_check_label(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_label', ...args)
}

// Ruby method `banner_name = "Go packages"` at line 17.
pub fn ruby_go_l17_d3_banner_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('banner_name', ...args)
}

// Ruby method `reset!` at line 20.
pub fn ruby_go_l20_d4_reset(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset!', ...args)
}

// Ruby method `cleanup_heading` at line 26.
pub fn ruby_go_l26_d5_cleanup_heading(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cleanup_heading', ...args)
}

// Ruby method `packages` at line 31.
pub fn ruby_go_l31_d6_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('packages', ...args)
}

// Ruby method `install_package!(name, with: nil, verbose: false)` at line 82.
pub fn ruby_go_l82_d7_install_package(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_package!', ...args)
}

// Ruby method `installed_packages` at line 91.
pub fn ruby_go_l91_d8_installed_packages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_packages', ...args)
}

// Ruby method `cleanup!(items)` at line 99.
pub fn ruby_go_l99_d9_cleanup(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cleanup!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/extensions/extension"
// 5:
// 6: module Homebrew
// 7:   module Bundle
// 8:     class Go < Extension
// 9:       class << self
// 10:         sig { override.returns(Symbol) }
// 11:         def type = :go
// 12:
// 13:         sig { override.returns(String) }
// 14:         def check_label = "Go Package"
// 15:
// 16:         sig { override.returns(String) }
// 17:         def banner_name = "Go packages"
// 18:
// 19:         sig { override.void }
// 20:         def reset!
// 21:           @packages = T.let(nil, T.nilable(T::Array[String]))
// 22:           @installed_packages = T.let(nil, T.nilable(T::Array[String]))
// 23:         end
// 24:
// 25:         sig { override.returns(T.nilable(String)) }
// 26:         def cleanup_heading
// 27:           banner_name
// 28:         end
// 29:
// 30:         sig { override.returns(T::Array[String]) }
// 31:         def packages
// 32:           packages = @packages
// 33:           return packages if packages
// 34:
// 35:           @packages = if (go = package_manager_executable)
// 36:             ENV["GOBIN"] = ENV.fetch("HOMEBREW_GOBIN", nil)
// 37:             ENV["GOPATH"] = ENV.fetch("HOMEBREW_GOPATH", nil)
// 38:             gobin = `#{go} env GOBIN`.chomp
// 39:             gopath = `#{go} env GOPATH`.chomp
// 40:             bin_dir = gobin.empty? ? "#{gopath}/bin" : gobin
// 41:             if File.directory?(bin_dir)
// 42:               binaries = Dir.glob("#{bin_dir}/*").select do |file|
// 43:                 File.executable?(file) && !File.directory?(file) && !File.symlink?(file)
// 44:               end
// 45:
// 46:               binaries.filter_map do |binary|
// 47:                 output = `#{go} version -m "#{binary}" 2>/dev/null`
// 48:                 next if output.empty?
// 49:
// 50:                 lines = output.split("\n")
// 51:                 path_line = lines.find { |line| line.strip.start_with?("path\t") }
// 52:                 next unless path_line
// 53:
// 54:                 # Parse the output to find the path line
// 55:                 # Format: "\tpath\tgithub.com/user/repo"
// 56:                 parts = path_line.split("\t")
// 57:                 # Extract the package path (second field after splitting by tab)
// 58:                 # The line format is: "\tpath\tgithub.com/user/repo"
// 59:                 path = parts[2]&.strip
// 60:
// 61:                 # `command-line-arguments` is a dummy package name for binaries built
// 62:                 # from a list of source files instead of a specific package name.
// 63:                 # https://github.com/golang/go/issues/36043
// 64:                 next if path == "command-line-arguments"
// 65:
// 66:                 path
// 67:               end.uniq
// 68:             end
// 69:           end
// 70:           return [] if @packages.nil?
// 71:
// 72:           @packages
// 73:         end
// 74:
// 75:         sig {
// 76:           override.params(
// 77:             name:    String,
// 78:             with:    T.nilable(T::Array[String]),
// 79:             verbose: T::Boolean,
// 80:           ).returns(T::Boolean)
// 81:         }
// 82:         def install_package!(name, with: nil, verbose: false)
// 83:           _ = with
// 84:
// 85:           go = package_manager_executable!
// 86:
// 87:           Bundle.system(go.to_s, "install", "#{name}@latest", verbose:)
// 88:         end
// 89:
// 90:         sig { override.returns(T::Array[String]) }
// 91:         def installed_packages
// 92:           installed_packages = @installed_packages
// 93:           return installed_packages if installed_packages
// 94:
// 95:           @installed_packages = packages.dup
// 96:         end
// 97:
// 98:         sig { override.params(items: T::Array[String]).void }
// 99:         def cleanup!(items)
// 100:           go = package_manager_executable
// 101:           return if go.nil?
// 102:
// 103:           gobin = `#{go} env GOBIN`.chomp
// 104:           gopath = `#{go} env GOPATH`.chomp
// 105:           bin_dir = gobin.empty? ? "#{gopath}/bin" : gobin
// 106:           return unless File.directory?(bin_dir)
// 107:
// 108:           removed = 0
// 109:           Dir.glob("#{bin_dir}/*").each do |binary|
// 110:             next if !File.executable?(binary) || File.directory?(binary) || File.symlink?(binary)
// 111:
// 112:             output = `#{go} version -m "#{binary}" 2>/dev/null`
// 113:             next if output.empty?
// 114:
// 115:             path_line = output.split("\n").find { |line| line.strip.start_with?("path\t") }
// 116:             next unless path_line
// 117:
// 118:             module_path = path_line.split("\t")[2]&.strip
// 119:             next unless items.include?(module_path)
// 120:
// 121:             FileUtils.rm_f(binary)
// 122:             removed += 1
// 123:           end
// 124:           puts "Uninstalled #{removed} #{banner_name}#{"s" if removed != 1}"
// 125:         end
// 126:       end
// 127:     end
// 128:   end
// 129: end

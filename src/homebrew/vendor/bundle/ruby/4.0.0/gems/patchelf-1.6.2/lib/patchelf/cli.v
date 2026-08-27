module patchelf

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/patchelf-1.6.2/lib/patchelf/cli.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `work(argv)` at line 27.
pub fn ruby_cli_l27_d1_work(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('work', ...args)
}

// Ruby method `patcher` at line 50.
pub fn ruby_cli_l50_d2_patcher(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patcher', ...args)
}

// Ruby method `readonly` at line 54.
pub fn ruby_cli_l54_d3_readonly(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('readonly', ...args)
}

// Ruby method `patch_requests` at line 64.
pub fn ruby_cli_l64_d4_patch_requests(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('patch_requests', ...args)
}

// Ruby method `parse?(argv)` at line 74.
pub fn ruby_cli_l74_d5_parse(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse?', ...args)
}

// Ruby method `option_parser` at line 83.
pub fn ruby_cli_l83_d6_option_parser(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('option_parser', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require 'optparse'
// 4:
// 5: require 'patchelf/patcher'
// 6: require 'patchelf/version'
// 7:
// 8: module PatchELF
// 9:   # For command line interface to parsing arguments.
// 10:   module CLI
// 11:     # Name of binary.
// 12:     SCRIPT_NAME = 'patchelf.rb'
// 13:     # CLI usage string.
// 14:     USAGE = format('Usage: %s <commands> FILENAME [OUTPUT_FILE]', SCRIPT_NAME).freeze
// 15:
// 16:     module_function
// 17:
// 18:     # Main method of CLI.
// 19:     # @param [Array<String>] argv
// 20:     #   Command line arguments.
// 21:     # @return [void]
// 22:     # @example
// 23:     #   PatchELF::CLI.work(%w[--help])
// 24:     #   # usage message to stdout
// 25:     #   PatchELF::CLI.work(%w[--version])
// 26:     #   # version message to stdout
// 27:     def work(argv)
// 28:       @options = {
// 29:         set: {},
// 30:         print: [],
// 31:         needed: []
// 32:       }
// 33:       return $stdout.puts "PatchELF Version #{PatchELF::VERSION}" if argv.include?('--version')
// 34:       return $stdout.puts option_parser unless parse?(argv)
// 35:
// 36:       # Now the options are (hopefully) valid, let's process the ELF file.
// 37:       begin
// 38:         @patcher = PatchELF::Patcher.new(@options[:in_file])
// 39:       rescue ELFTools::ELFError, Errno::ENOENT => e
// 40:         return PatchELF::Logger.error(e.message)
// 41:       end
// 42:       patcher.use_rpath! if @options[:force_rpath]
// 43:       readonly
// 44:       patch_requests
// 45:       patcher.save(@options[:out_file])
// 46:     end
// 47:
// 48:     private
// 49:
// 50:     def patcher
// 51:       @patcher
// 52:     end
// 53:
// 54:     def readonly
// 55:       @options[:print].uniq.each do |s|
// 56:         content = patcher.__send__(s)
// 57:         next if content.nil?
// 58:
// 59:         s = :rpath if @options[:force_rpath] && s == :runpath
// 60:         $stdout.puts "#{s}: #{Array(content).join(' ')}"
// 61:       end
// 62:     end
// 63:
// 64:     def patch_requests
// 65:       @options[:set].each do |sym, val|
// 66:         patcher.__send__(:"#{sym}=", val)
// 67:       end
// 68:
// 69:       @options[:needed].each do |type, val|
// 70:         patcher.__send__(:"#{type}_needed", *val)
// 71:       end
// 72:     end
// 73:
// 74:     def parse?(argv)
// 75:       remain = option_parser.permute(argv)
// 76:       return false if remain.first.nil?
// 77:
// 78:       @options[:in_file] = remain.first
// 79:       @options[:out_file] = remain[1] # can be nil
// 80:       true
// 81:     end
// 82:
// 83:     def option_parser
// 84:       @option_parser ||= OptionParser.new do |opts|
// 85:         opts.banner = USAGE
// 86:
// 87:         opts.on('--print-interpreter', '--pi', 'Show interpreter\'s name.') do
// 88:           @options[:print] << :interpreter
// 89:         end
// 90:
// 91:         opts.on('--print-needed', '--pn', 'Show needed libraries specified in DT_NEEDED.') do
// 92:           @options[:print] << :needed
// 93:         end
// 94:
// 95:         opts.on('--print-runpath', '--pr', 'Show the path specified in DT_RUNPATH.') do
// 96:           @options[:print] << :runpath
// 97:         end
// 98:
// 99:         opts.on('--print-soname', '--ps', 'Show soname specified in DT_SONAME.') do
// 100:           @options[:print] << :soname
// 101:         end
// 102:
// 103:         opts.on('--set-interpreter INTERP', '--interp INTERP', 'Set interpreter\'s name.') do |interp|
// 104:           @options[:set][:interpreter] = interp
// 105:         end
// 106:
// 107:         opts.on('--set-needed LIB1,LIB2,LIB3', '--needed LIB1,LIB2,LIB3', Array,
// 108:                 'Set needed libraries, this will remove all existent needed libraries.') do |needs|
// 109:           @options[:set][:needed] = needs
// 110:         end
// 111:
// 112:         opts.on('--add-needed LIB', 'Append a new needed library.') do |lib|
// 113:           @options[:needed] << [:add, lib]
// 114:         end
// 115:
// 116:         opts.on('--remove-needed LIB', 'Remove a needed library.') do |lib|
// 117:           @options[:needed] << [:remove, lib]
// 118:         end
// 119:
// 120:         opts.on('--replace-needed LIB1,LIB2', Array, 'Replace needed library LIB1 as LIB2.') do |libs|
// 121:           @options[:needed] << [:replace, libs]
// 122:         end
// 123:
// 124:         opts.on('--set-runpath PATH', '--runpath PATH', 'Set the path of runpath.') do |path|
// 125:           @options[:set][:runpath] = path
// 126:         end
// 127:
// 128:         opts.on(
// 129:           '--force-rpath',
// 130:           'According to the ld.so docs, DT_RPATH is obsolete,',
// 131:           "#{SCRIPT_NAME} will always try to get/set DT_RUNPATH first.",
// 132:           'Use this option to force every operations related to runpath (e.g. --runpath)',
// 133:           'to consider \'DT_RPATH\' instead of \'DT_RUNPATH\'.'
// 134:         ) do
// 135:           @options[:force_rpath] = true
// 136:         end
// 137:
// 138:         opts.on('--set-soname SONAME', '--so SONAME', 'Set name of a shared library.') do |soname|
// 139:           @options[:set][:soname] = soname
// 140:         end
// 141:
// 142:         opts.on('--version', 'Show current gem\'s version.')
// 143:       end
// 144:     end
// 145:
// 146:     extend self
// 147:   end
// 148: end

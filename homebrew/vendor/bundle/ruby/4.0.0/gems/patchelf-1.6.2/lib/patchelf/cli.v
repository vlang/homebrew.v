module patchelf

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/patchelf-1.6.2/lib/patchelf/cli.rb`.
// The original source is retained below until every stub has a typed V body.
pub const patch_elf_cli_script_name = 'patchelf.rb'
pub const patch_elf_cli_usage = 'Usage: patchelf.rb <commands> FILENAME [OUTPUT_FILE]'
pub const patch_elf_version = '1.6.2'

pub fn patch_elf_cli_help() string {
	return [
		patch_elf_cli_usage,
		"        --print-interpreter, --pi Show interpreter's name.",
		'        --print-needed, --pn      Show needed libraries specified in DT_NEEDED.',
		'        --print-runpath, --pr     Show the path specified in DT_RUNPATH.',
		'        --print-soname, --ps      Show soname specified in DT_SONAME.',
		"        --set-interpreter INTERP  Set interpreter's name.",
		'        --set-needed LIB1,LIB2    Set needed libraries.',
		'        --add-needed LIB          Append a new needed library.',
		'        --remove-needed LIB       Remove a needed library.',
		'        --replace-needed A,B      Replace needed library A as B.',
		'        --set-runpath PATH        Set the path of runpath.',
		'        --force-rpath             Use DT_RPATH instead of DT_RUNPATH.',
		'        --set-soname SONAME       Set name of a shared library.',
		"        --version                 Show current gem's version.",
	].join('\n')
}

pub struct PatchElfNeededRequest {
pub:
	operation string
	values    []string
}

pub struct PatchElfCliOptions {
pub mut:
	in_file      string
	out_file     string
	has_out_file bool
	set          map[string]brew_runtime.Value
	print        []string
	needed       []PatchElfNeededRequest
	force_rpath  bool
}

pub struct PatchElfCliParse {
pub:
	valid   bool
	options PatchElfCliOptions
}

@[heap]
pub struct PatchElfCli {
pub mut:
	options     PatchElfCliOptions
	patcher     &Patcher = unsafe { nil }
	has_patcher bool
}

fn cli_nil_value() brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

fn cli_value(cli &PatchElfCli) brew_runtime.Value {
	return brew_runtime.structured_value('PatchELF::CLI', '#<PatchELF::CLI>', {
		'patch_elf_cli_address': u64(voidptr(cli)).str()
	})
}

fn cli_from_args(args []brew_runtime.Value) &PatchElfCli {
	if args.len == 0 {
		panic('PatchELF::CLI method requires a receiver')
	}
	address := args[0].attribute('patch_elf_cli_address') or {
		panic('invalid PatchELF::CLI receiver')
	}
	return unsafe { &PatchElfCli(voidptr(address.u64())) }
}

fn cli_arguments(args []brew_runtime.Value) []string {
	if args.len == 0 {
		return []string{}
	}
	if args[0].type_name == 'Array' {
		return args[0].as_string_array() or { args[0].as_array() or { return []string{} }.map(it.as_string()) }
	}
	return args.map(it.as_string())
}

fn cli_take_value(argv []string, index int, inline string, option string) !(string, int) {
	if inline != '' {
		return inline, index
	}
	if index + 1 >= argv.len {
		return error('missing argument for ${option}')
	}
	return argv[index + 1], index + 1
}

pub fn parse_patch_elf_cli(argv []string) !PatchElfCliParse {
	mut options := PatchElfCliOptions{
		set: map[string]brew_runtime.Value{}
	}
	mut remain := []string{}
	mut index := 0
	for index < argv.len {
		argument := argv[index]
		if argument == '--' {
			remain << argv[index + 1..]
			break
		}
		mut option := argument
		mut inline := ''
		if argument.starts_with('--') && argument.contains('=') {
			option = argument.all_before('=')
			inline = argument.all_after('=')
		}
		match option {
			'--print-interpreter', '--pi' { options.print << 'interpreter' }
			'--print-needed', '--pn' { options.print << 'needed' }
			'--print-runpath', '--pr' { options.print << 'runpath' }
			'--print-soname', '--ps' { options.print << 'soname' }
			'--force-rpath' {
				options.force_rpath = true
			}
			'--version', '--help', '-h' {}
			'--set-interpreter', '--interp' {
				value, next := cli_take_value(argv, index, inline, option)!
				index = next
				options.set['interpreter'] = brew_runtime.string_value(value)
			}
			'--set-needed', '--needed' {
				value, next := cli_take_value(argv, index, inline, option)!
				index = next
				options.set['needed'] = brew_runtime.string_array_value(value.split(','))
			}
			'--add-needed', '--remove-needed' {
				value, next := cli_take_value(argv, index, inline, option)!
				index = next
				options.needed << PatchElfNeededRequest{
					operation: option.trim_string_left('--').all_before('_').all_before('-')
					values: [value]
				}
			}
			'--replace-needed' {
				value, next := cli_take_value(argv, index, inline, option)!
				index = next
				values := value.split(',')
				if values.len != 2 {
					return error('--replace-needed requires LIB1,LIB2')
				}
				options.needed << PatchElfNeededRequest{
					operation: 'replace'
					values: values
				}
			}
			'--set-runpath', '--runpath' {
				value, next := cli_take_value(argv, index, inline, option)!
				index = next
				options.set['runpath'] = brew_runtime.string_value(value)
			}
			'--set-soname', '--so' {
				value, next := cli_take_value(argv, index, inline, option)!
				index = next
				options.set['soname'] = brew_runtime.string_value(value)
			}
			else {
				if argument.starts_with('-') {
					return error('invalid option: ${argument}')
				}
				remain << argument
			}
		}
		index++
	}
	if remain.len == 0 {
		return PatchElfCliParse{ options: options }
	}
	options.in_file = remain[0]
	if remain.len > 1 {
		options.out_file = remain[1]
		options.has_out_file = true
	}
	return PatchElfCliParse{ valid: true, options: options }
}

pub fn new_patch_elf_cli(options PatchElfCliOptions, patcher &Patcher) &PatchElfCli {
	return &PatchElfCli{
		options: options
		patcher: patcher
		has_patcher: true
	}
}

pub fn (cli &PatchElfCli) readonly() ![]string {
	if !cli.has_patcher {
		return error('PatchELF::CLI has no patcher')
	}
	mut seen := []string{}
	mut output := []string{}
	for request in cli.options.print {
		if request in seen {
			continue
		}
		seen << request
		mut label := request
		mut content := []string{}
		match request {
			'interpreter' {
				result := cli.patcher.interpreter()!
				if result.exists { content << result.value }
			}
			'needed' {
				result := cli.patcher.needed()!
				if result.exists {
					content = result.value.clone()
				}
			}
			'runpath' {
				result := cli.patcher.runpath()!
				if result.exists { content << result.value }
				if cli.options.force_rpath {
					label = 'rpath'
				}
			}
			'soname' {
				result := cli.patcher.soname()!
				if result.exists { content << result.value }
			}
			else {}
		}
		if content.len > 0 {
			output << '${label}: ${content.join(' ')}'
		}
	}
	return output
}

pub fn (mut cli PatchElfCli) patch_requests() ! {
	if !cli.has_patcher {
		return error('PatchELF::CLI has no patcher')
	}
	for name, value in cli.options.set {
		match name {
			'interpreter' { cli.patcher.set_interpreter(value.as_string())! }
			'needed' { cli.patcher.set_needed(value.as_string_array()!) }
			'runpath' { cli.patcher.set_runpath(value.as_string()) }
			'rpath' { cli.patcher.set_rpath(value.as_string()) }
			'soname' { cli.patcher.set_soname(value.as_string())! }
			else {
				return error('unknown patch request `${name}`')
			}
		}
	}
	for request in cli.options.needed {
		match request.operation {
			'add' { cli.patcher.add_needed(request.values[0])! }
			'remove' { cli.patcher.remove_needed(request.values[0])! }
			'replace' { cli.patcher.replace_needed(request.values[0], request.values[1])! }
			else {
				return error('unknown needed request `${request.operation}`')
			}
		}
	}
}

pub fn patch_elf_cli_work(argv []string) !string {
	if '--version' in argv {
		return 'PatchELF Version ${patch_elf_version}\n'
	}
	if '--help' in argv || '-h' in argv {
		return patch_elf_cli_help() + '\n'
	}
	parsed := parse_patch_elf_cli(argv)!
	if !parsed.valid {
		return patch_elf_cli_help() + '\n'
	}
	patcher := new_patcher(parsed.options.in_file, .log, true)!
	mut cli := new_patch_elf_cli(parsed.options, patcher)
	if cli.options.force_rpath {
		cli.patcher.use_rpath()
	}
	lines := cli.readonly()!
	cli.patch_requests()!
	output := if cli.options.has_out_file { ?string(cli.options.out_file) } else { ?string(none) }
	cli.patcher.save(output, false)!
	return if lines.len > 0 { lines.join('\n') + '\n' } else { '' }
}

// Ruby method `work(argv)` at line 27.
pub fn ruby_cli_l27_d1_work(args ...brew_runtime.Value) brew_runtime.Value {
	output := patch_elf_cli_work(cli_arguments(args)) or { panic(err) }
	return if output == '' { cli_nil_value() } else { brew_runtime.string_value(output) }
}

// Ruby method `patcher` at line 50.
pub fn ruby_cli_l50_d2_patcher(args ...brew_runtime.Value) brew_runtime.Value {
	cli := cli_from_args(args)
	return if cli.has_patcher { patcher_value(cli.patcher) } else { cli_nil_value() }
}

// Ruby method `readonly` at line 54.
pub fn ruby_cli_l54_d3_readonly(args ...brew_runtime.Value) brew_runtime.Value {
	lines := cli_from_args(args).readonly() or { panic(err) }
	return brew_runtime.string_array_value(lines)
}

// Ruby method `patch_requests` at line 64.
pub fn ruby_cli_l64_d4_patch_requests(args ...brew_runtime.Value) brew_runtime.Value {
	mut cli := cli_from_args(args)
	cli.patch_requests() or { panic(err) }
	return cli_nil_value()
}

// Ruby method `parse?(argv)` at line 74.
pub fn ruby_cli_l74_d5_parse(args ...brew_runtime.Value) brew_runtime.Value {
	parsed := parse_patch_elf_cli(cli_arguments(args)) or { panic(err) }
	return brew_runtime.bool_value(parsed.valid)
}

// Ruby method `option_parser` at line 83.
pub fn ruby_cli_l83_d6_option_parser(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(patch_elf_cli_help())
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

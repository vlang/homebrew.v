module homebrew

import brew_runtime

// Translated from Homebrew/brew `manpages.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.regenerate_man_pages(quiet:)` at line 26.
pub fn ruby_manpages_l26_d1_self_regenerate_man_pages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.regenerate_man_pages', ...args)
}

// Ruby method `self.build_man_page(quiet:)` at line 46.
pub fn ruby_manpages_l46_d2_self_build_man_page(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.build_man_page', ...args)
}

// Ruby method `self.sort_key_for_path(path)` at line 67.
pub fn ruby_manpages_l67_d3_self_sort_key_for_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sort_key_for_path', ...args)
}

// Ruby method `self.generate_cmd_manpages(cmd_paths)` at line 73.
pub fn ruby_manpages_l73_d4_self_generate_cmd_manpages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.generate_cmd_manpages', ...args)
}

// Ruby method `self.cmd_parser_manpage_lines(cmd_parser)` at line 96.
pub fn ruby_manpages_l96_d5_self_cmd_parser_manpage_lines(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cmd_parser_manpage_lines', ...args)
}

// Ruby method `self.option_manpage_lines(options)` at line 124.
pub fn ruby_manpages_l124_d6_self_option_manpage_lines(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.option_manpage_lines', ...args)
}

// Ruby method `self.cmd_comment_manpage_lines(cmd_path)` at line 141.
pub fn ruby_manpages_l141_d7_self_cmd_comment_manpage_lines(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cmd_comment_manpage_lines', ...args)
}

// Ruby method `self.global_cask_options_manpage` at line 175.
pub fn ruby_manpages_l175_d8_self_global_cask_options_manpage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.global_cask_options_manpage', ...args)
}

// Ruby method `self.global_options_manpage` at line 185.
pub fn ruby_manpages_l185_d9_self_global_options_manpage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.global_options_manpage', ...args)
}

// Ruby method `self.env_vars_manpage` at line 194.
pub fn ruby_manpages_l194_d10_self_env_vars_manpage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.env_vars_manpage', ...args)
}

// Ruby method `self.format_opt(opt)` at line 208.
pub fn ruby_manpages_l208_d11_self_format_opt(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.format_opt', ...args)
}

// Ruby method `self.generate_option_doc(short, long, desc)` at line 219.
pub fn ruby_manpages_l219_d12_self_generate_option_doc(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.generate_option_doc', ...args)
}

// Ruby method `self.format_usage_banner(usage_banner)` at line 234.
pub fn ruby_manpages_l234_d13_self_format_usage_banner(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.format_usage_banner', ...args)
}

// Ruby method `self.format_usage_text(usage_banner)` at line 239.
pub fn ruby_manpages_l239_d14_self_format_usage_text(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.format_usage_text', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cli/parser"
// 5: require "erb"
// 6:
// 7: module Homebrew
// 8:   # Helper functions for generating homebrew manual.
// 9:   module Manpages
// 10:     class Variables < T::Struct
// 11:       const :commands, String
// 12:       const :developer_commands, String
// 13:       const :environment_variables, String
// 14:       const :global_cask_options, String
// 15:       const :global_options, String
// 16:       const :project_leader, String
// 17:       const :lead_maintainers, String
// 18:       const :maintainers, String
// 19:     end
// 20:
// 21:     SOURCE_PATH = T.let((HOMEBREW_LIBRARY_PATH/"manpages").freeze, Pathname)
// 22:     TARGET_MAN_PATH = T.let((HOMEBREW_REPOSITORY/"manpages").freeze, Pathname)
// 23:     TARGET_DOC_PATH = T.let((HOMEBREW_REPOSITORY/"docs").freeze, Pathname)
// 24:
// 25:     sig { params(quiet: T::Boolean).void }
// 26:     def self.regenerate_man_pages(quiet:)
// 27:       require "kramdown"
// 28:       require "manpages/parser/ronn"
// 29:       require "manpages/converter/kramdown"
// 30:       require "manpages/converter/roff"
// 31:
// 32:       markup = build_man_page(quiet:)
// 33:       root, warnings = Parser::Ronn.parse(markup)
// 34:       $stderr.puts(warnings)
// 35:
// 36:       roff, warnings = Converter::Kramdown.convert(root)
// 37:       $stderr.puts(warnings)
// 38:       File.write(TARGET_DOC_PATH/"Manpage.md", roff)
// 39:
// 40:       roff, warnings = Converter::Roff.convert(root)
// 41:       $stderr.puts(warnings)
// 42:       File.write(TARGET_MAN_PATH/"brew.1", roff)
// 43:     end
// 44:
// 45:     sig { params(quiet: T::Boolean).returns(String) }
// 46:     def self.build_man_page(quiet:)
// 47:       template = (SOURCE_PATH/"brew.1.md.erb").read
// 48:       readme = HOMEBREW_REPOSITORY/"README.md"
// 49:       variables = Variables.new(
// 50:         commands:              generate_cmd_manpages(Commands.internal_commands_paths),
// 51:         developer_commands:    generate_cmd_manpages(Commands.internal_developer_commands_paths),
// 52:         global_cask_options:   global_cask_options_manpage,
// 53:         global_options:        global_options_manpage,
// 54:         environment_variables: env_vars_manpage,
// 55:         project_leader:        readme.read[/(Homebrew's \[Project Leader.*\.)/, 1]
// 56:                                      .gsub(/\[([^\]]+)\]\([^)]+\)/, '\1'),
// 57:         lead_maintainers:      readme.read[/(Homebrew's \[Lead Maintainers.*\.)/, 1]
// 58:                                      .gsub(/\[([^\]]+)\]\([^)]+\)/, '\1'),
// 59:         maintainers:           readme.read[/(Homebrew's other Maintainers .*\.)/, 1]
// 60:                                      .gsub(/\[([^\]]+)\]\([^)]+\)/, '\1'),
// 61:       )
// 62:
// 63:       ERB.new(template, trim_mode: ">").result(variables.instance_eval { binding })
// 64:     end
// 65:
// 66:     sig { params(path: Pathname).returns(String) }
// 67:     def self.sort_key_for_path(path)
// 68:       # Options after regular commands (`~` comes after `z` in ASCII table).
// 69:       path.basename.to_s.sub(/\.(rb|sh)$/, "").sub(/^--/, "~~")
// 70:     end
// 71:
// 72:     sig { params(cmd_paths: T::Array[Pathname]).returns(String) }
// 73:     def self.generate_cmd_manpages(cmd_paths)
// 74:       man_page_lines = []
// 75:
// 76:       # preserve existing manpage order
// 77:       cmd_paths.sort_by { sort_key_for_path(it) }
// 78:                .each do |cmd_path|
// 79:         cmd_man_page_lines = if (cmd_parser = Homebrew::CLI::Parser.from_cmd_path(cmd_path))
// 80:           next if cmd_parser.hide_from_man_page
// 81:
// 82:           cmd_parser_manpage_lines(cmd_parser).join
// 83:         else
// 84:           cmd_comment_manpage_lines(cmd_path)&.join("\n")
// 85:         end
// 86:         # Convert subcommands to definition lists
// 87:         cmd_man_page_lines&.gsub!(/(?<=\n\n)([\\?\[`].+):\n/, "\\1\n\n: ")
// 88:
// 89:         man_page_lines << cmd_man_page_lines
// 90:       end
// 91:
// 92:       man_page_lines.compact.join("\n")
// 93:     end
// 94:
// 95:     sig { params(cmd_parser: CLI::Parser).returns(T::Array[String]) }
// 96:     def self.cmd_parser_manpage_lines(cmd_parser)
// 97:       lines = []
// 98:       if cmd_parser.subcommands.present?
// 99:         root_usage_banner_text = cmd_parser.root_usage_banner_text
// 100:         lines << "#{format_usage_banner(root_usage_banner_text)}\n\n" if root_usage_banner_text
// 101:         if (description = cmd_parser.description).present?
// 102:           lines << "#{description}\n\n"
// 103:         end
// 104:
// 105:         root_options = cmd_parser.processed_options_for_root_command
// 106:         lines += option_manpage_lines(root_options)
// 107:
// 108:         cmd_parser.subcommands.each do |subcommand|
// 109:           usage_banner = subcommand.usage_banner
// 110:           next if usage_banner.blank?
// 111:
// 112:           lines << "#{format_usage_text(usage_banner)}\n\n"
// 113:           lines += option_manpage_lines(cmd_parser.processed_options_for_subcommand(subcommand.name) - root_options)
// 114:         end
// 115:       else
// 116:         usage_banner_text = cmd_parser.usage_banner_text
// 117:         lines << format_usage_banner(usage_banner_text) if usage_banner_text
// 118:         lines += option_manpage_lines(cmd_parser.processed_options)
// 119:       end
// 120:       lines
// 121:     end
// 122:
// 123:     sig { params(options: CLI::Args::OptionsType).returns(T::Array[String]) }
// 124:     def self.option_manpage_lines(options)
// 125:       options.filter_map do |short, long, desc, hidden|
// 126:         next if hidden
// 127:
// 128:         if long.present?
// 129:           next if Homebrew::CLI::Parser.global_options.include?([short, long, desc])
// 130:           next if Homebrew::CLI::Parser.global_cask_options.any? do |_, option, kwargs|
// 131:                     [long, "#{long}="].include?(option) && kwargs.fetch(:description) == desc
// 132:                   end
// 133:         end
// 134:
// 135:         generate_option_doc(short, long, desc)
// 136:       end
// 137:     end
// 138:     private_class_method :option_manpage_lines
// 139:
// 140:     sig { params(cmd_path: Pathname).returns(T.nilable(T::Array[String])) }
// 141:     def self.cmd_comment_manpage_lines(cmd_path)
// 142:       comment_lines = cmd_path.read.lines.grep(/^#:/)
// 143:       return if comment_lines.empty?
// 144:
// 145:       first_comment_line = comment_lines.first
// 146:       return unless first_comment_line
// 147:       return if first_comment_line.include?("@hide_from_man_page")
// 148:
// 149:       lines = [format_usage_banner(first_comment_line).chomp]
// 150:       all_but_first_comment_lines = comment_lines.slice(1..-1)
// 151:       return unless all_but_first_comment_lines
// 152:       return if all_but_first_comment_lines.empty?
// 153:
// 154:       all_but_first_comment_lines.each do |line|
// 155:         line = line.slice(4..-2)
// 156:         unless line
// 157:           lines.last << "\n"
// 158:           next
// 159:         end
// 160:
// 161:         # Omit the common global_options documented separately in the man page.
// 162:         next if line.match?(/--(debug|help|quiet|verbose) /)
// 163:
// 164:         # Format one option or a comma-separated pair of short and long options.
// 165:         line.gsub!(/^ +(-+[a-z-]+), (-+[a-z-]+) +(.*)$/, "`\\1`, `\\2`\n\n: \\3\n")
// 166:         line.gsub!(/^ +(-+[a-z-]+) +(.*)$/, "`\\1`\n\n: \\2\n")
// 167:
// 168:         lines << line
// 169:       end
// 170:       lines.last << "\n"
// 171:       lines
// 172:     end
// 173:
// 174:     sig { returns(String) }
// 175:     def self.global_cask_options_manpage
// 176:       lines = ["These options are applicable to the `install`, `reinstall` and `upgrade` " \
// 177:                "subcommands with the `--cask` switch.\n"]
// 178:       lines += Homebrew::CLI::Parser.global_cask_options.map do |_, long, kwargs|
// 179:         generate_option_doc(nil, long.chomp("="), kwargs.fetch(:description))
// 180:       end
// 181:       lines.join("\n")
// 182:     end
// 183:
// 184:     sig { returns(String) }
// 185:     def self.global_options_manpage
// 186:       lines = ["These options are applicable across multiple subcommands.\n"]
// 187:       lines += Homebrew::CLI::Parser.global_options.map do |short, long, desc|
// 188:         generate_option_doc(short, long, desc)
// 189:       end
// 190:       lines.join("\n")
// 191:     end
// 192:
// 193:     sig { returns(String) }
// 194:     def self.env_vars_manpage
// 195:       lines = Homebrew::EnvConfig::ENVS.filter_map do |env, hash|
// 196:         next if Homebrew::EnvConfig.hidden?(hash)
// 197:
// 198:         entry = "`#{env}`\n\n: #{hash[:description]}\n"
// 199:         default = Homebrew::EnvConfig.default_description(env)
// 200:         entry += "\n\n    *Default:* #{default}\n" if default
// 201:
// 202:         entry
// 203:       end
// 204:       lines.join("\n")
// 205:     end
// 206:
// 207:     sig { params(opt: T.nilable(String)).returns(T.nilable(String)) }
// 208:     def self.format_opt(opt)
// 209:       "`#{opt}`" unless opt.nil?
// 210:     end
// 211:
// 212:     sig {
// 213:       params(
// 214:         short: T.nilable(String),
// 215:         long:  T.nilable(String),
// 216:         desc:  String,
// 217:       ).returns(String)
// 218:     }
// 219:     def self.generate_option_doc(short, long, desc)
// 220:       comma = if short && long
// 221:         ", "
// 222:       else
// 223:         ""
// 224:       end
// 225:       <<~EOS
// 226:         #{format_opt(short)}#{comma}#{format_opt(long)}
// 227:
// 228:         : #{desc}
// 229:
// 230:       EOS
// 231:     end
// 232:
// 233:     sig { params(usage_banner: String).returns(String) }
// 234:     def self.format_usage_banner(usage_banner)
// 235:       format_usage_text(usage_banner).sub(/^(#: *\* )?/, "### ")
// 236:     end
// 237:
// 238:     sig { params(usage_banner: String).returns(String) }
// 239:     def self.format_usage_text(usage_banner)
// 240:       usage_banner.gsub(/(?<!`)\[([^\[\]]*)\](?!`)/, "\\[\\1\\]") # escape [] character (except those in code spans)
// 241:     end
// 242:     private_class_method :format_usage_text
// 243:   end
// 244: end

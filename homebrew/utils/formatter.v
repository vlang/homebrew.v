module utils

import brew_runtime

// Translated from Homebrew/brew `utils/formatter.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.arrow(string, color: nil)` at line 14.
pub fn ruby_formatter_l14_d1_self_arrow(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.arrow', ...args)
}

// Ruby method `self.headline(string, color: nil)` at line 23.
pub fn ruby_formatter_l23_d2_self_headline(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.headline', ...args)
}

// Ruby method `self.identifier(string)` at line 28.
pub fn ruby_formatter_l28_d3_self_identifier(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.identifier', ...args)
}

// Ruby method `self.bold(string)` at line 34.
pub fn ruby_formatter_l34_d4_self_bold(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.bold', ...args)
}

// Ruby method `self.option(string)` at line 39.
pub fn ruby_formatter_l39_d5_self_option(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.option', ...args)
}

// Ruby method `self.success(string, label: nil)` at line 47.
pub fn ruby_formatter_l47_d6_self_success(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.success', ...args)
}

// Ruby method `self.warning(string, label: nil)` at line 55.
pub fn ruby_formatter_l55_d7_self_warning(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.warning', ...args)
}

// Ruby method `self.error(string, label: nil)` at line 63.
pub fn ruby_formatter_l63_d8_self_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.error', ...args)
}

// Ruby method `self.truncate(string, max: 30, omission: "...")` at line 71.
pub fn ruby_formatter_l71_d9_self_truncate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.truncate', ...args)
}

// Ruby method `self.format_help_text(string, width: 172)` at line 94.
pub fn ruby_formatter_l94_d10_self_format_help_text(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.format_help_text', ...args)
}

// Ruby method `self.url(string)` at line 105.
pub fn ruby_formatter_l105_d11_self_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.url', ...args)
}

// Ruby method `self.label(label, string, color)` at line 110.
pub fn ruby_formatter_l110_d12_self_label(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.label', ...args)
}

// Ruby method `self.prefix(prefix, string, color)` at line 119.
pub fn ruby_formatter_l119_d13_self_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.prefix', ...args)
}

// Ruby method `self.columns(objects, gap_size: 2, min_width: 0)` at line 136.
pub fn ruby_formatter_l136_d14_self_columns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.columns', ...args)
}

// Ruby method `self.disk_usage_readable_size_unit(size_in_bytes, precision: nil)` at line 185.
pub fn ruby_formatter_l185_d15_self_disk_usage_readable_size_unit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.disk_usage_readable_size_unit', ...args)
}

// Ruby method `self.disk_usage_readable(size_in_bytes)` at line 198.
pub fn ruby_formatter_l198_d16_self_disk_usage_readable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.disk_usage_readable', ...args)
}

// Ruby method `self.number_readable(number)` at line 209.
pub fn ruby_formatter_l209_d17_self_number_readable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.number_readable', ...args)
}

// Ruby method `self.redact_secrets(input, secrets)` at line 216.
pub fn ruby_formatter_l216_d18_self_redact_secrets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.redact_secrets', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/tty"
// 5:
// 6: # Helper module for formatting output.
// 7: #
// 8: # @api internal
// 9: module Formatter
// 10:   COMMAND_DESC_WIDTH = 80
// 11:   OPTION_DESC_WIDTH = 45
// 12:
// 13:   sig { params(string: String, color: T.nilable(Symbol)).returns(String) }
// 14:   def self.arrow(string, color: nil)
// 15:     prefix("==>", string, color)
// 16:   end
// 17:
// 18:   # Format a string as headline.
// 19:   #
// 20:   # @api internal
// 21:   # Keep in sync with `headline` in Library/Homebrew/utils/formatter.sh.
// 22:   sig { params(string: String, color: T.nilable(Symbol)).returns(String) }
// 23:   def self.headline(string, color: nil)
// 24:     arrow("#{Tty.bold}#{string}#{Tty.reset}", color:)
// 25:   end
// 26:
// 27:   sig { params(string: Object).returns(String) }
// 28:   def self.identifier(string)
// 29:     "#{Tty.green}#{string}#{Tty.default}"
// 30:   end
// 31:
// 32:   # Keep in sync with `bold` in Library/Homebrew/utils/formatter.sh.
// 33:   sig { params(string: String).returns(String) }
// 34:   def self.bold(string)
// 35:     "#{Tty.bold}#{string}#{Tty.reset}"
// 36:   end
// 37:
// 38:   sig { params(string: String).returns(String) }
// 39:   def self.option(string)
// 40:     bold(string)
// 41:   end
// 42:
// 43:   # Format a string as success, with an optional label.
// 44:   #
// 45:   # @api internal
// 46:   sig { params(string: String, label: T.nilable(String)).returns(String) }
// 47:   def self.success(string, label: nil)
// 48:     label(label, string, :green)
// 49:   end
// 50:
// 51:   # Format a string as warning, with an optional label.
// 52:   #
// 53:   # @api internal
// 54:   sig { params(string: T.any(String, Exception), label: T.nilable(String)).returns(String) }
// 55:   def self.warning(string, label: nil)
// 56:     label(label, string, :yellow)
// 57:   end
// 58:
// 59:   # Format a string as error, with an optional label.
// 60:   #
// 61:   # @api internal
// 62:   sig { params(string: T.any(String, Exception), label: T.nilable(String)).returns(String) }
// 63:   def self.error(string, label: nil)
// 64:     label(label, string, :red)
// 65:   end
// 66:
// 67:   # Truncate a string to a specific length.
// 68:   #
// 69:   # @api internal
// 70:   sig { params(string: String, max: Integer, omission: String).returns(String) }
// 71:   def self.truncate(string, max: 30, omission: "...")
// 72:     return string if string.length <= max
// 73:
// 74:     length_with_room_for_omission = max - omission.length
// 75:     truncated = string[0, length_with_room_for_omission]
// 76:
// 77:     "#{truncated}#{omission}"
// 78:   end
// 79:
// 80:   # Wraps text to fit within a given number of columns using regular expressions that:
// 81:   #
// 82:   # 1. convert hard-wrapped paragraphs to a single line
// 83:   # 2. add line break and indent to subcommand descriptions
// 84:   # 3. find any option descriptions longer than a pre-set length and wrap between words
// 85:   #    with a hanging indent, without breaking any words that overflow
// 86:   # 4. wrap any remaining description lines that need wrapping with the same indent
// 87:   # 5. wrap all lines to the given width.
// 88:   #
// 89:   # Note that an option (e.g. `--foo`) may not be at the beginning of a line,
// 90:   # so we always wrap one word before an option.
// 91:   # @see https://github.com/Homebrew/brew/pull/12672
// 92:   # @see https://macromates.com/blog/2006/wrapping-text-with-regular-expressions/
// 93:   sig { params(string: String, width: Integer).returns(String) }
// 94:   def self.format_help_text(string, width: 172)
// 95:     desc = OPTION_DESC_WIDTH
// 96:     indent = width - desc
// 97:     string.gsub(/(?<=\S) *\n(?=\S)/, " ")
// 98:           .gsub(/([`>)\]]:) /, "\\1\n    ")
// 99:           .gsub(/^( +-.+  +(?=\S.{#{desc}}))(.{1,#{desc}})( +|$)(?!-)\n?/, "\\1\\2\n#{" " * indent}")
// 100:           .gsub(/^( {#{indent}}(?=\S.{#{desc}}))(.{1,#{desc}})( +|$)(?!-)\n?/, "\\1\\2\n#{" " * indent}")
// 101:           .gsub(/(.{1,#{width}})( +|$)(?!-)\n?/, "\\1\n")
// 102:   end
// 103:
// 104:   T::Sig::WithoutRuntime.sig { params(string: T.nilable(T.any(String, URI::Generic))).returns(String) }
// 105:   def self.url(string)
// 106:     "#{Tty.underline}#{string}#{Tty.no_underline}"
// 107:   end
// 108:
// 109:   sig { params(label: T.nilable(String), string: T.any(String, Exception), color: Symbol).returns(String) }
// 110:   def self.label(label, string, color)
// 111:     label = "#{label}:" unless label.nil?
// 112:     prefix(label, string, color)
// 113:   end
// 114:   private_class_method :label
// 115:
// 116:   sig {
// 117:     params(prefix: T.nilable(String), string: T.any(String, Exception), color: T.nilable(Symbol)).returns(String)
// 118:   }
// 119:   def self.prefix(prefix, string, color)
// 120:     if prefix.nil? && color.nil?
// 121:       string.to_s
// 122:     elsif prefix.nil?
// 123:       "#{Tty.public_send(T.must(color))}#{string}#{Tty.reset}"
// 124:     elsif color.nil?
// 125:       "#{prefix} #{string}"
// 126:     else
// 127:       "#{Tty.public_send(color)}#{prefix}#{Tty.reset} #{string}"
// 128:     end
// 129:   end
// 130:   private_class_method :prefix
// 131:
// 132:   # Layout objects in columns that fit the current terminal width.
// 133:   #
// 134:   # @api internal
// 135:   sig { params(objects: T::Array[String], gap_size: Integer, min_width: Integer).returns(String) }
// 136:   def self.columns(objects, gap_size: 2, min_width: 0)
// 137:     objects = objects.flatten.map(&:to_s)
// 138:
// 139:     fallback = proc do
// 140:       return objects.join("\n").concat("\n")
// 141:     end
// 142:
// 143:     fallback.call if objects.empty?
// 144:     fallback.call if respond_to?(:tty?) ? !T.unsafe(self).tty? : !$stdout.tty?
// 145:
// 146:     console_width = Tty.width
// 147:     object_lengths = objects.map { |obj| Tty.strip_ansi(obj).length }
// 148:     max_length = [*object_lengths, min_width].max || 0
// 149:     cols = (console_width + gap_size) / (max_length + gap_size)
// 150:
// 151:     fallback.call if cols < 2
// 152:
// 153:     rows = (objects.count + cols - 1) / cols
// 154:     cols = (objects.count + rows - 1) / rows if min_width.zero? # avoid empty trailing columns
// 155:     col_width = ((console_width + gap_size) / cols) - gap_size
// 156:
// 157:     gap_string = "".rjust(gap_size)
// 158:
// 159:     output = +""
// 160:
// 161:     rows.times do |row_index|
// 162:       item_indices_for_row = T.cast(row_index.step(objects.size - 1, rows).to_a, T::Array[Integer])
// 163:
// 164:       first_n = T.must(item_indices_for_row[0...-1]).map do |index|
// 165:         objects.fetch(index) + "".rjust(col_width - object_lengths.fetch(index))
// 166:       end
// 167:
// 168:       # don't add trailing whitespace to last column
// 169:       last = objects.values_at(item_indices_for_row.fetch(-1))
// 170:
// 171:       output.concat((first_n + last)
// 172:             .join(gap_string))
// 173:             .concat("\n")
// 174:     end
// 175:
// 176:     output.freeze
// 177:   end
// 178:
// 179:   sig {
// 180:     params(
// 181:       size_in_bytes: T.any(Integer, Float),
// 182:       precision:     T.nilable(Integer),
// 183:     ).returns([T.any(Integer, Float), String])
// 184:   }
// 185:   def self.disk_usage_readable_size_unit(size_in_bytes, precision: nil)
// 186:     size = size_in_bytes
// 187:     unit = "B"
// 188:     %w[KB MB GB].each do |next_unit|
// 189:       break if (precision ? size.abs.round(precision) : size.abs) < 1000
// 190:
// 191:       size /= 1000.0
// 192:       unit = next_unit
// 193:     end
// 194:     [size, unit]
// 195:   end
// 196:
// 197:   sig { params(size_in_bytes: T.any(Integer, Float)).returns(String) }
// 198:   def self.disk_usage_readable(size_in_bytes)
// 199:     size, unit = disk_usage_readable_size_unit(size_in_bytes)
// 200:     # avoid trailing zero after decimal point
// 201:     if ((size * 10).to_i % 10).zero?
// 202:       "#{size.to_i}#{unit}"
// 203:     else
// 204:       "#{format("%<size>.1f", size:)}#{unit}"
// 205:     end
// 206:   end
// 207:
// 208:   sig { params(number: Integer).returns(String) }
// 209:   def self.number_readable(number)
// 210:     numstr = number.to_i.to_s
// 211:     (numstr.size - 3).step(1, -3) { |i| numstr.insert(i.to_i, ",") }
// 212:     numstr
// 213:   end
// 214:
// 215:   sig { params(input: String, secrets: T::Array[String]).returns(String) }
// 216:   def self.redact_secrets(input, secrets)
// 217:     secrets.compact
// 218:            .reduce(input) { |str, secret| str.gsub secret, "******" }
// 219:            .freeze
// 220:   end
// 221: end

module homebrew

import ruby
import time

// Translated from Homebrew/brew `utils.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct AuthorIdentity {
pub:
	name  string
	email string
}

pub type ParallelValueOperation = fn(ruby.Value) !ruby.Value

struct ParallelValueResult {
	index         int
	value         ruby.Value
	error_message string
}

fn run_parallel_value(index int, item ruby.Value, operation ParallelValueOperation,
	results chan ParallelValueResult) {
	value := operation(item) or {
		results <- ParallelValueResult{
			index: index
			error_message: err.msg()
		}
		return
	}
	results <- ParallelValueResult{
		index: index
		value: value
	}
}

pub fn deconstantize(path string) string {
	index := path.last_index('::') or { return '' }
	return path[..index]
}

pub fn demodulize(path ?string) !string {
	value := path or { return error('No constant path provided') }
	index := value.last_index('::') or { return value }
	return value[index + 2..]
}

pub fn name_from_full_name(full_name string) string {
	parts := full_name.split_nth('/', 3)
	return if parts.len == 3 { parts[2] } else { full_name }
}

pub fn name_or_token(object ruby.Value) string {
	if object.type_name == 'Cask::Cask' {
		return object.attributes['token'] or { object.repr }
	}
	return object.attributes['name'] or { object.repr }
}

pub fn tap_from_full_name(full_name string) ?string {
	parts := full_name.split_nth('/', 3)
	if parts.len != 3 {
		return none
	}
	return '${parts[0]}/${parts[1]}'
}

pub fn is_full_name(full_name string) bool {
	return full_name.count('/') == 2
}

pub fn parallel_map_values(items []ruby.Value,
	operation ParallelValueOperation) ![]ruby.Value {
	if items.len == 0 {
		return []ruby.Value{}
	}
	results := chan ParallelValueResult{ cap: items.len }
	for index, item in items {
		spawn run_parallel_value(index, item, operation, results)
	}
	mut ordered := []ruby.Value{len: items.len}
	mut errors := []string{len: items.len}
	for _ in 0 .. items.len {
		result := <-results
		ordered[result.index] = result.value
		errors[result.index] = result.error_message
	}
	for message in errors {
		if message.len > 0 {
			return error(message)
		}
	}
	return ordered
}

pub fn pluralize(stem string, count i64, plural_suffix string, singular_suffix string,
	include_count bool) string {
	mut root := stem
	mut plural := plural_suffix
	mut singular := singular_suffix
	if root == 'formula' {
		plural = 'e'
	} else if root in ['dependency', 'try'] {
		root = root.trim_string_right('y')
		plural = 'ies'
		singular = 'y'
	}
	prefix := if include_count { '${count} ' } else { '' }
	suffix := if count == 1 { singular } else { plural }
	return '${prefix}${root}${suffix}'
}

pub fn exponential_backoff_wait(attempt int, base int) !i64 {
	if attempt < 0 || base < 0 {
		return error('negative exponential backoff values are unsupported')
	}
	mut wait := i64(1)
	for _ in 0 .. attempt {
		if base > 0 && wait > i64(9223372036854775807) / i64(base) {
			return error('exponential backoff overflow')
		}
		wait *= i64(base)
	}
	return wait
}

pub fn exponential_backoff_sleep(attempt int, base int, before_sleep fn(i64)) ! {
	wait := exponential_backoff_wait(attempt, base)!
	before_sleep(wait)
	time.sleep(time.Duration(wait) * time.second)
}

pub fn parse_author(author string) !AuthorIdentity {
	open := author.last_index('<') or { return error('Unable to parse name and email.') }
	if !author.ends_with('>') {
		return error('Unable to parse name and email.')
	}
	name := author[..open].trim_right(' \t')
	email := author[open + 1..author.len - 1]
	if name.len == 0 || email.len == 0 || email.contains('>') {
		return error('Unable to parse name and email.')
	}
	return AuthorIdentity{
		name: name
		email: email
	}
}

pub fn underscore(camel_cased_word string) string {
	if !camel_cased_word.contains('::') && !camel_cased_word.contains('-') && !camel_cased_word.bytes().any(it >= `A` && it <= `Z`) {
		return camel_cased_word
	}
	word := camel_cased_word.replace('::', '/')
	mut output := []u8{cap: word.len + 8}
	bytes := word.bytes()
	for index, character in bytes {
		if character == `-` {
			output << `_`
			continue
		}
		is_upper := character >= `A` && character <= `Z`
		if is_upper && index > 0 {
			previous := bytes[index - 1]
			next_is_lower := index + 1 < bytes.len && bytes[index + 1] >= `a` && bytes[index + 1] <= `z`
			previous_is_lower_or_digit := (previous >= `a` && previous <= `z`) || (previous >= `0` && previous <= `9`)
			previous_is_upper := previous >= `A` && previous <= `Z`
			if previous != `/` && (previous_is_lower_or_digit || (previous_is_upper && next_is_lower)) {
				output << `_`
			}
		}
		output << if is_upper { character + 32 } else { character }
	}
	return output.bytestr()
}

pub fn safe_filename_part(basename string) string {
	return basename.bytes().filter(it >= 32 && it != 127 && it != `/`).bytestr()
}

pub fn is_safe_filename(basename string) bool {
	return safe_filename_part(basename) == basename
}

pub fn convert_to_string_or_symbol(input string) ruby.Value {
	if input.starts_with(':') {
		return ruby.object_value('Symbol', input[1..])
	}
	return ruby.string_value(input)
}

pub fn deep_stringify_symbols(obj ruby.Value) ruby.Value {
	if obj.type_name == 'String' {
		return ruby.string_value(if obj.repr.starts_with(':') || obj.repr.starts_with('\\') {
			'\\${obj.repr}'
		} else {
			obj.repr
		})
	}
	if obj.type_name == 'Symbol' {
		return ruby.string_value(':${obj.repr}')
	}
	if obj.type_name == 'Array' {
		return ruby.array_value(obj.array_data.map(deep_stringify_symbols(it)))
	}
	if obj.type_name == 'Hash' {
		mut mapped := map[string]ruby.Value{}
		for key, value in obj.map_data {
			// Value maps encode Ruby Symbol keys with their leading `:`. Preserve
			// that source type while String keys still use the normal escaping.
			stringified_key := if key.starts_with(':') {
				key
			} else {
				deep_stringify_symbols(ruby.string_value(key)).repr
			}
			mapped[stringified_key] = deep_stringify_symbols(value)
		}
		return ruby.map_value(mapped)
	}
	return obj
}

pub fn deep_unstringify_symbols(obj ruby.Value) ruby.Value {
	if obj.type_name == 'String' {
		if obj.repr.starts_with('\\') {
			return ruby.string_value(obj.repr[1..])
		}
		if obj.repr.starts_with(':') {
			return ruby.object_value('Symbol', obj.repr[1..])
		}
		return obj
	}
	if obj.type_name == 'Array' {
		return ruby.array_value(obj.array_data.map(deep_unstringify_symbols(it)))
	}
	if obj.type_name == 'Hash' {
		mut mapped := map[string]ruby.Value{}
		for key, value in obj.map_data {
			converted_key := deep_unstringify_symbols(ruby.string_value(key))
			mapped[if converted_key.type_name == 'Symbol' {
				':${converted_key.repr}'
			} else {
				converted_key.repr
			}] = deep_unstringify_symbols(value)
		}
		return ruby.map_value(mapped)
	}
	return obj
}

fn value_is_blank(value ruby.Value, compact_zero bool, compact_false bool) bool {
	if value.type_name == 'NilClass' {
		return true
	}
	if value.type_name == 'Bool' && !value.bool_data {
		return compact_false
	}
	if value.type_name == 'Integer' && value.int_data == 0 {
		return compact_zero
	}
	if value.type_name == 'Float' && value.float_data == 0.0 {
		return compact_zero
	}
	if value.type_name == 'String' {
		return value.repr.trim_space().len == 0
	}
	return (value.type_name == 'Array' && value.array_data.len == 0) || (value.type_name == 'Hash' && value.map_data.len == 0)
}

pub fn deep_compact_blank(obj ruby.Value, compact_zero bool,
	compact_false bool) ?ruby.Value {
	mut compacted := obj
	if obj.type_name == 'Array' {
		mut values := []ruby.Value{}
		for value in obj.array_data {
			if kept := deep_compact_blank(value, compact_zero, compact_false) {
				values << kept
			}
		}
		compacted = ruby.array_value(values)
	} else if obj.type_name == 'Hash' {
		mut values := map[string]ruby.Value{}
		for key, value in obj.map_data {
			if kept := deep_compact_blank(value, compact_zero, compact_false) {
				values[key] = kept
			}
		}
		compacted = ruby.map_value(values)
	}
	if value_is_blank(compacted, compact_zero, compact_false) {
		return none
	}
	return compacted
}

fn nil_boundary_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Ruby method `self.deconstantize(path)` at line 17.
pub fn ruby_utils_l17_d1_self_deconstantize(args ...ruby.Value) ruby.Value {
	return ruby.string_value(deconstantize(args[0].as_string()))
}

// Ruby method `self.demodulize(path)` at line 33.
pub fn ruby_utils_l33_d2_self_demodulize(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		panic('No constant path provided')
	}
	return ruby.string_value(demodulize(args[0].as_string()) or { panic(err) })
}

// Ruby method `self.name_from_full_name(full_name)` at line 44.
pub fn ruby_utils_l44_d3_self_name_from_full_name(args ...ruby.Value) ruby.Value {
	return ruby.string_value(name_from_full_name(args[0].as_string()))
}

// Ruby method `self.name_or_token(formula_or_cask)` at line 51.
pub fn ruby_utils_l51_d4_self_name_or_token(args ...ruby.Value) ruby.Value {
	return ruby.string_value(name_or_token(args[0]))
}

// Ruby method `self.tap_from_full_name(full_name)` at line 56.
pub fn ruby_utils_l56_d5_self_tap_from_full_name(args ...ruby.Value) ruby.Value {
	return if tap := tap_from_full_name(args[0].as_string()) {
		ruby.string_value(tap)
	} else {
		nil_boundary_value()
	}
}

// Ruby method `self.full_name?(full_name)` at line 65.
pub fn ruby_utils_l65_d6_self_full_name(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(is_full_name(args[0].as_string()))
}

// Ruby method `self.parallel_map(items, &block)` at line 83.
pub fn ruby_utils_l83_d7_self_parallel_map(args ...ruby.Value) ruby.Value {
	items := args[0].as_array() or { panic(err) }
	return ruby.array_value(parallel_map_values(items, fn (value ruby.Value) !ruby.Value {
		return value
	}) or { panic(err) })
}

// Ruby method `self.pluralize(stem, count, plural: "s", singular: "", include_count: false)` at line 100.
pub fn ruby_utils_l100_d8_self_pluralize(args ...ruby.Value) ruby.Value {
	options := if args.len > 2 { args[2].map_data } else { map[string]ruby.Value{} }
	plural_suffix := options['plural'] or { ruby.string_value('s') }
	singular_suffix := options['singular'] or { ruby.string_value('') }
	include_count := options['include_count'] or { ruby.bool_value(false) }
	return ruby.string_value(pluralize(args[0].as_string(), args[1].as_int() or {
		panic(err)
	}, plural_suffix.as_string(), singular_suffix.as_string(), include_count.bool_data))
}

// Ruby method `self.exponential_backoff_sleep(try, base: 2, &_blk)` at line 118.
pub fn ruby_utils_l118_d9_self_exponential_backoff_sleep(args ...ruby.Value) ruby.Value {
	attempt := int(args[0].as_int() or { panic(err) })
	options := if args.len > 1 { args[1].map_data } else { map[string]ruby.Value{} }
	base_value := options['base'] or { ruby.int_value(2) }
	wait := exponential_backoff_wait(attempt, int(base_value.as_int() or { panic(err) })) or {
		panic(err)
	}
	return ruby.int_value(wait)
}

// Ruby method `self.parse_author!(author)` at line 125.
pub fn ruby_utils_l125_d10_self_parse_author(args ...ruby.Value) ruby.Value {
	author := parse_author(args[0].as_string()) or { panic(err) }
	return ruby.map_value({
		'name':  ruby.string_value(author.name)
		'email': ruby.string_value(author.email)
	})
}

// Ruby method `self.underscore(camel_cased_word)` at line 146.
pub fn ruby_utils_l146_d11_self_underscore(args ...ruby.Value) ruby.Value {
	return ruby.string_value(underscore(args[0].as_string()))
}

// Ruby method `self.safe_filename?(basename)` at line 162.
pub fn ruby_utils_l162_d12_self_safe_filename(args ...ruby.Value) ruby.Value {
	return ruby.bool_value(is_safe_filename(args[0].as_string()))
}

// Ruby method `self.safe_filename(basename)` at line 167.
pub fn ruby_utils_l167_d13_self_safe_filename(args ...ruby.Value) ruby.Value {
	return ruby.string_value(safe_filename_part(args[0].as_string()))
}

// Ruby method `self.convert_to_string_or_symbol(string)` at line 177.
pub fn ruby_utils_l177_d14_self_convert_to_string_or_symbol(args ...ruby.Value) ruby.Value {
	return convert_to_string_or_symbol(args[0].as_string())
}

// Ruby method `self.deep_stringify_symbols(obj)` at line 184.
pub fn ruby_utils_l184_d15_self_deep_stringify_symbols(args ...ruby.Value) ruby.Value {
	return deep_stringify_symbols(args[0])
}

// Ruby method `self.deep_unstringify_symbols(obj)` at line 207.
pub fn ruby_utils_l207_d16_self_deep_unstringify_symbols(args ...ruby.Value) ruby.Value {
	return deep_unstringify_symbols(args[0])
}

// Ruby method `self.deep_compact_blank(obj, compact_zero: true, compact_false: true)` at line 231.
pub fn ruby_utils_l231_d17_self_deep_compact_blank(args ...ruby.Value) ruby.Value {
	options := if args.len > 1 { args[1].map_data } else { map[string]ruby.Value{} }
	compact_zero := options['compact_zero'] or { ruby.bool_value(true) }
	compact_false := options['compact_false'] or { ruby.bool_value(true) }
	return deep_compact_blank(args[0], compact_zero.bool_data, compact_false.bool_data) or {
		nil_boundary_value()
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Utils
// 5:   # Removes the rightmost segment from the constant expression in the string.
// 6:   #
// 7:   #   deconstantize('Net::HTTP')   # => "Net"
// 8:   #   deconstantize('::Net::HTTP') # => "::Net"
// 9:   #   deconstantize('String')      # => ""
// 10:   #   deconstantize('::String')    # => ""
// 11:   #   deconstantize('')            # => ""
// 12:   #
// 13:   # See also #demodulize.
// 14:   # @see https://github.com/rails/rails/blob/b0dd7c7/activesupport/lib/active_support/inflector/methods.rb#L247-L258
// 15:   #   `ActiveSupport::Inflector.deconstantize`
// 16:   sig { params(path: String).returns(String) }
// 17:   def self.deconstantize(path)
// 18:     T.must(path[0, path.rindex("::") || 0]) # implementation based on the one in facets' Module#spacename
// 19:   end
// 20:
// 21:   # Removes the module part from the expression in the string.
// 22:   #
// 23:   #   demodulize('ActiveSupport::Inflector::Inflections') # => "Inflections"
// 24:   #   demodulize('Inflections')                           # => "Inflections"
// 25:   #   demodulize('::Inflections')                         # => "Inflections"
// 26:   #   demodulize('')                                      # => ""
// 27:   #
// 28:   # See also #deconstantize.
// 29:   # @see https://github.com/rails/rails/blob/b0dd7c7/activesupport/lib/active_support/inflector/methods.rb#L230-L245
// 30:   #   `ActiveSupport::Inflector.demodulize`
// 31:   # @raise [ArgumentError] if the provided path is nil
// 32:   sig { params(path: T.nilable(String)).returns(String) }
// 33:   def self.demodulize(path)
// 34:     raise ArgumentError, "No constant path provided" if path.nil?
// 35:
// 36:     if (i = path.rindex("::"))
// 37:       T.must(path[(i + 2)..])
// 38:     else
// 39:       path
// 40:     end
// 41:   end
// 42:
// 43:   sig { params(full_name: String).returns(String) }
// 44:   def self.name_from_full_name(full_name)
// 45:     _, _, name = full_name.split("/", 3)
// 46:
// 47:     name || full_name
// 48:   end
// 49:
// 50:   sig { params(formula_or_cask: T.any(Formula, Cask::Cask)).returns(String) }
// 51:   def self.name_or_token(formula_or_cask)
// 52:     formula_or_cask.is_a?(Cask::Cask) ? formula_or_cask.token : formula_or_cask.name
// 53:   end
// 54:
// 55:   sig { params(full_name: String).returns(T.nilable(String)) }
// 56:   def self.tap_from_full_name(full_name)
// 57:     user, repository, name = full_name.split("/", 3)
// 58:     return unless name
// 59:
// 60:     "#{user}/#{repository}"
// 61:   end
// 62:
// 63:   # Whether `full_name` is fully-qualified with a tap prefix, e.g. `user/tap/name`.
// 64:   sig { params(full_name: String).returns(T::Boolean) }
// 65:   def self.full_name?(full_name)
// 66:     full_name.count("/") == 2
// 67:   end
// 68:
// 69:   # Maps `items` to `block` results with one thread per item, so that
// 70:   # blocking waits (subprocesses, network requests) overlap instead of
// 71:   # accumulating serially. Results keep the order of `items`. If multiple
// 72:   # blocks raise, the exception re-raised by `Thread#value` is the earliest
// 73:   # in `items` order (not necessarily the chronologically first failure) and
// 74:   # other blocks may still run to completion. Only worthwhile when each block
// 75:   # spends its time waiting: the GVL serializes Ruby execution.
// 76:   sig {
// 77:     type_parameters(:Item, :Result)
// 78:       .params(
// 79:         items: T::Enumerable[T.type_parameter(:Item)],
// 80:         block: T.proc.params(item: T.type_parameter(:Item)).returns(T.type_parameter(:Result)),
// 81:       ).returns(T::Array[T.type_parameter(:Result)])
// 82:   }
// 83:   def self.parallel_map(items, &block)
// 84:     threads = items.map do |item|
// 85:       Thread.new do
// 86:         # The exception is re-raised by `Thread#value`; don't also report it.
// 87:         Thread.current.report_on_exception = false
// 88:         yield(item)
// 89:       end
// 90:     end
// 91:     threads.map { |thread| T.cast(thread.value, T.type_parameter(:Result)) }
// 92:   end
// 93:
// 94:   # A lightweight alternative to `ActiveSupport::Inflector.pluralize`:
// 95:   # Combines `stem` with the `singular` or `plural` suffix based on `count`.
// 96:   # Adds a prefix of the count value if `include_count` is set to true.
// 97:   sig {
// 98:     params(stem: String, count: Integer, plural: String, singular: String, include_count: T::Boolean).returns(String)
// 99:   }
// 100:   def self.pluralize(stem, count, plural: "s", singular: "", include_count: false)
// 101:     case stem
// 102:     when "formula"
// 103:       plural = "e"
// 104:     when "dependency", "try"
// 105:       stem = stem.delete_suffix("y")
// 106:       plural = "ies"
// 107:       singular = "y"
// 108:     end
// 109:
// 110:     prefix = include_count ? "#{count} " : ""
// 111:     suffix = (count == 1) ? singular : plural
// 112:     "#{prefix}#{stem}#{suffix}"
// 113:   end
// 114:
// 115:   # Sleeps for an exponentially increasing wait (`base ** try` seconds), yielding
// 116:   # the wait time first so callers can print a message before sleeping.
// 117:   sig { params(try: Integer, base: Integer, _blk: T.nilable(T.proc.params(wait: Integer).void)).void }
// 118:   def self.exponential_backoff_sleep(try, base: 2, &_blk)
// 119:     wait = base.pow(try)
// 120:     yield wait if block_given?
// 121:     sleep wait
// 122:   end
// 123:
// 124:   sig { params(author: String).returns({ email: String, name: String }) }
// 125:   def self.parse_author!(author)
// 126:     match_data = /^(?<name>[^<]+?)[ \t]*<(?<email>[^>]+?)>$/.match(author)
// 127:     if match_data
// 128:       name = match_data[:name]
// 129:       email = match_data[:email]
// 130:     end
// 131:     raise UsageError, "Unable to parse name and email." if name.blank? && email.blank?
// 132:
// 133:     { name: T.must(name), email: T.must(email) }
// 134:   end
// 135:
// 136:   # Makes an underscored, lowercase form from the expression in the string.
// 137:   #
// 138:   # Changes '::' to '/' to convert namespaces to paths.
// 139:   #
// 140:   #   underscore('ActiveModel')         # => "active_model"
// 141:   #   underscore('ActiveModel::Errors') # => "active_model/errors"
// 142:   #
// 143:   # @see https://github.com/rails/rails/blob/v6.1.7.2/activesupport/lib/active_support/inflector/methods.rb#L81-L100
// 144:   #   `ActiveSupport::Inflector.underscore`
// 145:   sig { params(camel_cased_word: T.any(String, Symbol)).returns(String) }
// 146:   def self.underscore(camel_cased_word)
// 147:     return camel_cased_word.to_s unless /[A-Z-]|::/.match?(camel_cased_word)
// 148:
// 149:     word = camel_cased_word.to_s.gsub("::", "/")
// 150:     word.gsub!(/([A-Z])(?=[A-Z][a-z])|([a-z\d])(?=[A-Z])/) do
// 151:       T.must(::Regexp.last_match(1) || ::Regexp.last_match(2)) << "_"
// 152:     end
// 153:     word.tr!("-", "_")
// 154:     word.downcase!
// 155:     word
// 156:   end
// 157:
// 158:   SAFE_FILENAME_REGEX = /[[:cntrl:]#{Regexp.escape("#{File::SEPARATOR}#{File::ALT_SEPARATOR}")}]/o
// 159:   private_constant :SAFE_FILENAME_REGEX
// 160:
// 161:   sig { params(basename: String).returns(T::Boolean) }
// 162:   def self.safe_filename?(basename)
// 163:     !SAFE_FILENAME_REGEX.match?(basename)
// 164:   end
// 165:
// 166:   sig { params(basename: String).returns(String) }
// 167:   def self.safe_filename(basename)
// 168:     basename.gsub(SAFE_FILENAME_REGEX, "")
// 169:   end
// 170:
// 171:   # Converts a string starting with `:` to a symbol, otherwise returns the
// 172:   # string itself.
// 173:   #
// 174:   #   convert_to_string_or_symbol(":example") # => :example
// 175:   #   convert_to_string_or_symbol("example")  # => "example"
// 176:   sig { params(string: String).returns(T.any(String, Symbol)) }
// 177:   def self.convert_to_string_or_symbol(string)
// 178:     return T.must(string[1..]).to_sym if string.start_with?(":")
// 179:
// 180:     string
// 181:   end
// 182:
// 183:   sig { params(obj: T.untyped).returns(T.untyped) }
// 184:   def self.deep_stringify_symbols(obj)
// 185:     case obj
// 186:     when String
// 187:       # Escape leading : or \ to avoid confusion with stringified symbols
// 188:       # ":foo" -> "\:foo"
// 189:       # "\foo" -> "\\foo"
// 190:       if obj.start_with?(":", "\\")
// 191:         "\\#{obj}"
// 192:       else
// 193:         obj
// 194:       end
// 195:     when Symbol
// 196:       ":#{obj}"
// 197:     when Hash
// 198:       obj.to_h { |k, v| [deep_stringify_symbols(k), deep_stringify_symbols(v)] }
// 199:     when Array
// 200:       obj.map { |v| deep_stringify_symbols(v) }
// 201:     else
// 202:       obj
// 203:     end
// 204:   end
// 205:
// 206:   sig { params(obj: T.untyped).returns(T.untyped) }
// 207:   def self.deep_unstringify_symbols(obj)
// 208:     case obj
// 209:     when String
// 210:       if obj.start_with?("\\")
// 211:         obj[1..]
// 212:       elsif obj.start_with?(":")
// 213:         T.must(obj[1..]).to_sym
// 214:       else
// 215:         obj
// 216:       end
// 217:     when Hash
// 218:       obj.to_h { |k, v| [deep_unstringify_symbols(k), deep_unstringify_symbols(v)] }
// 219:     when Array
// 220:       obj.map { |v| deep_unstringify_symbols(v) }
// 221:     else
// 222:       obj
// 223:     end
// 224:   end
// 225:
// 226:   sig {
// 227:     type_parameters(:U)
// 228:       .params(obj: T.all(T.type_parameter(:U), Object), compact_zero: T::Boolean, compact_false: T::Boolean)
// 229:       .returns(T.nilable(T.type_parameter(:U)))
// 230:   }
// 231:   def self.deep_compact_blank(obj, compact_zero: true, compact_false: true)
// 232:     obj = case obj
// 233:     when Hash
// 234:       obj.transform_values { |v| deep_compact_blank(v, compact_zero:, compact_false:) }
// 235:          .compact
// 236:     when Array
// 237:       obj.each_with_object([]) do |v, compacted|
// 238:         value = deep_compact_blank(v, compact_zero:, compact_false:)
// 239:         compacted << value unless value.nil?
// 240:       end
// 241:     else
// 242:       obj
// 243:     end
// 244:
// 245:     return if (compact_false || obj != false) &&
// 246:               (obj.blank? || (compact_zero && obj.is_a?(Numeric) && obj.zero?))
// 247:
// 248:     obj
// 249:   end
// 250: end

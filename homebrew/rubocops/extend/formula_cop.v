module extend

import brew_runtime

// Translated from Homebrew/brew `rubocops/extend/formula_cop.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :file_path` at line 18.
pub fn ruby_formula_cop_l18_d1_file_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file_path', ...args)
}

// Ruby attr_accessor `attr_accessor :file_path` at line 18.
pub fn ruby_formula_cop_l18_d2_file_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file_path=', ...args)
}

// Ruby method `on_class(node)` at line 31.
pub fn ruby_formula_cop_l31_d3_on_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_class', ...args)
}

// Ruby method `audit_formula(formula_nodes); end` at line 44.
pub fn ruby_formula_cop_l44_d4_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_urls(urls, regex, &_block)` at line 56.
pub fn ruby_formula_cop_l56_d5_audit_urls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_urls', ...args)
}

// Ruby method `depends_on?(dependency_name, *types)` at line 72.
pub fn ruby_formula_cop_l72_d6_depends_on(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('depends_on?', ...args)
}

// Ruby method `depends_on_name_type?(node, name = nil, type = :required)` at line 96.
pub fn ruby_formula_cop_l96_d7_depends_on_name_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('depends_on_name_type?', ...args)
}

// Ruby def_node_search `def_node_search :required_dependency?, <<~EOS` at line 118.
pub fn ruby_formula_cop_l118_d8_required_dependency(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('required_dependency?', ...args)
}

// Ruby def_node_search `def_node_search :required_dependency_name?, <<~EOS` at line 122.
pub fn ruby_formula_cop_l122_d9_required_dependency_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('required_dependency_name?', ...args)
}

// Ruby def_node_search `def_node_search :dependency_type_hash_match?, <<~EOS` at line 126.
pub fn ruby_formula_cop_l126_d10_dependency_type_hash_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependency_type_hash_match?', ...args)
}

// Ruby def_node_search `def_node_search :dependency_name_hash_match?, <<~EOS` at line 130.
pub fn ruby_formula_cop_l130_d11_dependency_name_hash_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependency_name_hash_match?', ...args)
}

// Ruby method `caveats_strings` at line 136.
pub fn ruby_formula_cop_l136_d12_caveats_strings(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('caveats_strings', ...args)
}

// Ruby method `get_checksum_node(call)` at line 144.
pub fn ruby_formula_cop_l144_d13_get_checksum_node(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('get_checksum_node', ...args)
}

// Ruby method `audit_comments(&_block)` at line 168.
pub fn ruby_formula_cop_l168_d14_audit_comments(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_comments', ...args)
}

// Ruby method `versioned_formula?` at line 177.
pub fn ruby_formula_cop_l177_d15_versioned_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('versioned_formula?', ...args)
}

// Ruby method `formula_tap` at line 185.
pub fn ruby_formula_cop_l185_d16_formula_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_tap', ...args)
}

// Ruby method `style_exceptions_dir` at line 193.
pub fn ruby_formula_cop_l193_d17_style_exceptions_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('style_exceptions_dir', ...args)
}

// Ruby method `tap_style_exception?(list, formula = nil)` at line 220.
pub fn ruby_formula_cop_l220_d18_tap_style_exception(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap_style_exception?', ...args)
}

// Ruby method `formula_class?(node)` at line 253.
pub fn ruby_formula_cop_l253_d19_formula_class(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_class?', ...args)
}

// Ruby method `file_path_allowed?` at line 266.
pub fn ruby_formula_cop_l266_d20_file_path_allowed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file_path_allowed?', ...args)
}

// Ruby method `on_system_methods` at line 273.
pub fn ruby_formula_cop_l273_d21_on_system_methods(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_system_methods', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shared/helper_functions"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     # Abstract base class for all formula cops.
// 9:     class FormulaCop < Base
// 10:       extend T::Helpers
// 11:       include RangeHelp
// 12:       include HelperFunctions
// 13:
// 14:       abstract!
// 15:       exclude_from_registry
// 16:
// 17:       sig { returns(T.nilable(String)) }
// 18:       attr_accessor :file_path
// 19:
// 20:       @registry = T.let(Registry.global, RuboCop::Cop::Registry)
// 21:
// 22:       class FormulaNodes < T::Struct
// 23:         prop :node, RuboCop::AST::ClassNode
// 24:         prop :class_node, RuboCop::AST::ConstNode
// 25:         prop :parent_class_node, RuboCop::AST::ConstNode
// 26:         prop :body_node, RuboCop::AST::Node
// 27:       end
// 28:
// 29:       # This method is called by RuboCop and is the main entry point.
// 30:       sig { params(node: RuboCop::AST::ClassNode).void }
// 31:       def on_class(node)
// 32:         @file_path = T.let(processed_source.file_path, T.nilable(String))
// 33:         return unless file_path_allowed?
// 34:         return unless formula_class?(node)
// 35:
// 36:         class_node, parent_class_node, body = *node
// 37:         @body = T.let(body, T.nilable(RuboCop::AST::Node))
// 38:
// 39:         @formula_name = T.let(Pathname.new(@file_path).basename(".rb").to_s, T.nilable(String))
// 40:         audit_formula(FormulaNodes.new(node:, class_node:, parent_class_node:, body_node: T.must(@body)))
// 41:       end
// 42:
// 43:       sig { abstract.params(formula_nodes: FormulaNodes).void }
// 44:       def audit_formula(formula_nodes); end
// 45:
// 46:       # Yields to block when there is a match.
// 47:       #
// 48:       # @param urls [Array] url/mirror method call nodes
// 49:       # @param regex [Regexp] pattern to match URLs
// 50:       sig {
// 51:         params(
// 52:           urls: T::Array[RuboCop::AST::Node], regex: Regexp,
// 53:           _block: T.proc.params(arg0: MatchData, arg1: String, arg2: Integer).void
// 54:         ).void
// 55:       }
// 56:       def audit_urls(urls, regex, &_block)
// 57:         urls.each_with_index do |url_node, index|
// 58:           url_string_node = parameters(url_node).fetch(0)
// 59:           url_string = string_content(url_string_node)
// 60:           match_object = regex_match_group(url_string_node, regex)
// 61:           next unless match_object
// 62:
// 63:           offending_node(url_string_node.parent)
// 64:           yield match_object, url_string, index
// 65:         end
// 66:       end
// 67:
// 68:       # Returns if the formula depends on dependency_name.
// 69:       #
// 70:       # @param dependency_name dependency's name
// 71:       sig { params(dependency_name: T.any(String, Symbol), types: Symbol).returns(T::Boolean) }
// 72:       def depends_on?(dependency_name, *types)
// 73:         return false if @body.nil?
// 74:
// 75:         types = [:any] if types.empty?
// 76:         dependency_nodes = find_every_method_call_by_name(@body, :depends_on)
// 77:         idx = dependency_nodes.index do |n|
// 78:           types.any? { |type| depends_on_name_type?(n, dependency_name, type) }
// 79:         end
// 80:         return false if idx.nil?
// 81:
// 82:         @offensive_node = T.let(dependency_nodes[idx], T.nilable(RuboCop::AST::Node))
// 83:
// 84:         true
// 85:       end
// 86:
// 87:       # Returns true if given dependency name and dependency type exist in given dependency method call node.
// 88:       # TODO: Add case where key of hash is an array
// 89:       sig {
// 90:         params(
// 91:           node: RuboCop::AST::Node, name: T.nilable(T.any(String, Symbol)), type: Symbol,
// 92:         ).returns(
// 93:           T::Boolean,
// 94:         )
// 95:       }
// 96:       def depends_on_name_type?(node, name = nil, type = :required)
// 97:         name_match = !name # Match only by type when name is nil
// 98:
// 99:         case type
// 100:         when :required
// 101:           type_match = required_dependency?(node)
// 102:           name_match ||= required_dependency_name?(node, name) if type_match
// 103:         when :build, :test, :optional, :recommended
// 104:           type_match = dependency_type_hash_match?(node, type)
// 105:           name_match ||= dependency_name_hash_match?(node, name) if type_match
// 106:         when :any
// 107:           type_match = true
// 108:           name_match ||= required_dependency_name?(node, name) || false
// 109:           name_match ||= dependency_name_hash_match?(node, name) || false
// 110:         else
// 111:           type_match = false
// 112:         end
// 113:
// 114:         @offensive_node = node if type_match || name_match
// 115:         type_match && name_match
// 116:       end
// 117:
// 118:       def_node_search :required_dependency?, <<~EOS
// 119:         (send nil? :depends_on ({str sym} _))
// 120:       EOS
// 121:
// 122:       def_node_search :required_dependency_name?, <<~EOS
// 123:         (send nil? :depends_on ({str sym} %1))
// 124:       EOS
// 125:
// 126:       def_node_search :dependency_type_hash_match?, <<~EOS
// 127:         (hash (pair ({str sym} _) ({str sym} %1)))
// 128:       EOS
// 129:
// 130:       def_node_search :dependency_name_hash_match?, <<~EOS
// 131:         (hash (pair ({str sym} %1) (...)))
// 132:       EOS
// 133:
// 134:       # Return all the caveats' string nodes in an array.
// 135:       sig { returns(T::Array[RuboCop::AST::Node]) }
// 136:       def caveats_strings
// 137:         return [] if @body.nil?
// 138:
// 139:         find_strings(find_method_def(@body, :caveats)).to_a
// 140:       end
// 141:
// 142:       # Returns the sha256 str node given a sha256 call node.
// 143:       sig { params(call: RuboCop::AST::Node).returns(T.nilable(RuboCop::AST::Node)) }
// 144:       def get_checksum_node(call)
// 145:         return if parameters(call).empty? || parameters(call).nil?
// 146:
// 147:         if parameters(call).fetch(0).str_type?
// 148:           parameters(call).first
// 149:         # sha256 is passed as a key-value pair in bottle blocks
// 150:         elsif parameters(call).fetch(0).hash_type?
// 151:           hash_node = T.cast(parameters(call).fetch(0), RuboCop::AST::HashNode)
// 152:           if hash_node.keys.first.value == :cellar
// 153:             # sha256 :cellar :any, :tag "hexdigest"
// 154:             hash_node.values.last
// 155:           elsif hash_node.keys.first.is_a?(RuboCop::AST::SymbolNode)
// 156:             # sha256 :tag "hexdigest"
// 157:             hash_node.values.first
// 158:           else
// 159:             # Legacy bottle block syntax
// 160:             # sha256 "hexdigest" => :tag
// 161:             hash_node.keys.first
// 162:           end
// 163:         end
// 164:       end
// 165:
// 166:       # Yields to a block with comment text as parameter.
// 167:       sig { params(_block: T.proc.params(arg0: String).void).void }
// 168:       def audit_comments(&_block)
// 169:         processed_source.comments.each do |comment_node|
// 170:           @offensive_node = comment_node
// 171:           yield comment_node.text
// 172:         end
// 173:       end
// 174:
// 175:       # Returns true if the formula is versioned.
// 176:       sig { returns(T::Boolean) }
// 177:       def versioned_formula?
// 178:         return false if @formula_name.nil?
// 179:
// 180:         @formula_name.include?("@")
// 181:       end
// 182:
// 183:       # Returns the formula tap.
// 184:       sig { returns(T.nilable(String)) }
// 185:       def formula_tap
// 186:         return unless (match_obj = @file_path&.match(%r{(?:/Taps/[\w-]+|^)/(homebrew-[\w-]+)/}))
// 187:
// 188:         match_obj[1]
// 189:       end
// 190:
// 191:       # Returns the style exceptions directory from the file path.
// 192:       sig { returns(T.nilable(String)) }
// 193:       def style_exceptions_dir
// 194:         file_directory = File.dirname(@file_path) if @file_path
// 195:         return unless file_directory
// 196:
// 197:         # if we're in a sharded subdirectory, look below that.
// 198:         directory_name = File.basename(file_directory)
// 199:         formula_directory = if directory_name.length == 1 || directory_name == "lib"
// 200:           File.dirname(file_directory)
// 201:         else
// 202:           file_directory
// 203:         end
// 204:
// 205:         # if we're in a Formula or HomebrewFormula subdirectory, look below that.
// 206:         formula_directory_names = ["Formula", "HomebrewFormula"].freeze
// 207:         directory_name = File.basename(formula_directory)
// 208:         tap_root_directory = if formula_directory_names.include?(directory_name)
// 209:           File.dirname(formula_directory)
// 210:         else
// 211:           formula_directory
// 212:         end
// 213:
// 214:         "#{tap_root_directory}/style_exceptions"
// 215:       end
// 216:
// 217:       # Returns whether the given formula exists in the given style exception list.
// 218:       # Defaults to the current formula being checked.
// 219:       sig { params(list: Symbol, formula: T.nilable(String)).returns(T::Boolean) }
// 220:       def tap_style_exception?(list, formula = nil)
// 221:         return false if formula_tap.nil? || (exceptions_dir = style_exceptions_dir).nil?
// 222:
// 223:         @tap_style_exceptions = T.let(
// 224:           @tap_style_exceptions,
// 225:           T.nilable(T::Hash[String, T::Hash[Symbol, T::Array[String]]]),
// 226:         )
// 227:         @tap_style_exceptions ||= {}
// 228:         unless @tap_style_exceptions.key?(exceptions_dir)
// 229:           tap_style_exceptions = T.let({}, T::Hash[Symbol, T::Array[String]])
// 230:           Pathname.glob("#{exceptions_dir}/*.json").each do |exception_file|
// 231:             list_name = exception_file.basename.to_s.chomp(".json").to_sym
// 232:             list_contents = begin
// 233:               JSON.parse exception_file.read
// 234:             rescue JSON::ParserError
// 235:               nil
// 236:             end
// 237:             next if list_contents.nil? || list_contents.none?
// 238:
// 239:             tap_style_exceptions[list_name] = list_contents
// 240:           end
// 241:           @tap_style_exceptions[exceptions_dir] = tap_style_exceptions
// 242:         end
// 243:
// 244:         tap_style_exceptions = @tap_style_exceptions.fetch(exceptions_dir)
// 245:         return false unless tap_style_exceptions.key? list
// 246:
// 247:         tap_style_exceptions.fetch(list).include?(formula || @formula_name)
// 248:       end
// 249:
// 250:       private
// 251:
// 252:       sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 253:       def formula_class?(node)
// 254:         _, class_node, = *node
// 255:         class_names = %w[
// 256:           Formula
// 257:           GithubGistFormula
// 258:           ScriptFileFormula
// 259:           AmazonWebServicesFormula
// 260:         ]
// 261:
// 262:         !!(class_node && class_names.include?(string_content(class_node)))
// 263:       end
// 264:
// 265:       sig { returns(T::Boolean) }
// 266:       def file_path_allowed?
// 267:         return true if @file_path.nil? # file_path is nil when source is directly passed to the cop, e.g. in specs
// 268:
// 269:         !@file_path.include?("/Library/Homebrew/test/")
// 270:       end
// 271:
// 272:       sig { returns(T::Array[Symbol]) }
// 273:       def on_system_methods
// 274:         @on_system_methods ||= T.let(
// 275:           [:intel, :arm, :macos, :linux, :system, *MacOSVersion::SYMBOLS.keys].map do |m|
// 276:             :"on_#{m}"
// 277:           end,
// 278:           T.nilable(T::Array[Symbol]),
// 279:         )
// 280:       end
// 281:     end
// 282:   end
// 283: end

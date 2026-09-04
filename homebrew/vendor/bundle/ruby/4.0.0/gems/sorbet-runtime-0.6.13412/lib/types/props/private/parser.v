module private

import ruby

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/sorbet-runtime-0.6.13412/lib/types/props/private/parser.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct RubyAstNode {
pub:
	node_type string
	children  []ruby.Value
	source    string
}

pub fn new_ruby_ast_node(node_type string, children []ruby.Value) RubyAstNode {
	return RubyAstNode{
		node_type: node_type.trim_left(':')
		children: children.clone()
	}
}

fn ast_node_value(node RubyAstNode) ruby.Value {
	return ruby.Value{
		type_name: 'Parser::AST::Node'
		repr: 's(:${node.node_type}${if node.children.len > 0 { ', ...' } else { '' }})'
		array_data: node.children.clone()
		attributes: {
			'type':   node.node_type
			'source': node.source
		}
	}
}

pub fn ast_node_from_value(value ruby.Value) RubyAstNode {
	return RubyAstNode{
		node_type: value.attribute('type') or { value.as_string().trim_left(':') }
		children: value.array_data.clone()
		source: value.attribute('source') or { '' }
	}
}

// parse_ruby_source models Parser::CurrentRuby's entry point without loading
// Ruby. It retains the complete source and extracts the top-level method shape
// consumed by generated-code validation; child expressions remain explicit
// source nodes for later parser expansion.
pub fn parse_ruby_source(source string) !RubyAstNode {
	trimmed := source.trim_space()
	if !trimmed.starts_with('def ') {
		return RubyAstNode{
			node_type: 'source'
			children: [ruby.string_value(source)]
			source: source
		}
	}
	header_end := trimmed.index('\n') or { trimmed.len }
	header := trimmed[4..header_end].trim_space()
	open := header.index('(') or { return error('invalid Ruby method definition') }
	close := header.last_index(')') or { return error('invalid Ruby method arguments') }
	name := header[..open]
	arguments := header[open + 1..close].split(',').map(it.trim_space()).filter(it.len > 0)
	arg_nodes := arguments.map(ast_node_value(new_ruby_ast_node('arg', [
		ruby.object_value('Symbol', ':${it}'),
	])))
	args_node := ast_node_value(new_ruby_ast_node('args', arg_nodes))
	body_source := if header_end < trimmed.len {
		trimmed[header_end + 1..].trim_space()
	} else {
		''
	}
	body_without_end := if body_source.ends_with('end') {
		body_source[..body_source.len - 3].trim_space()
	} else {
		body_source
	}
	body := ast_node_value(RubyAstNode{
		node_type: 'begin'
		children: [ruby.structured_value('Parser::AST::Node', body_without_end, {
			'type':   'raw'
			'source': body_without_end
		})]
		source: body_without_end
	})
	return RubyAstNode{
		node_type: 'def'
		children: [ruby.object_value('Symbol', ':${name}'), args_node, body]
		source: source
	}
}

pub fn require_parser_constant(constants []string) string {
	mut path := ['Parser']
	path << constants.map(it.trim_left(':'))
	return path.join('::')
}

// Ruby method `parse(source)` at line 7.
pub fn ruby_parser_l7_d1_parse(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Parse#parse requires source')
	}
	return ast_node_value(parse_ruby_source(args[args.len - 1].as_string()) or { panic(err) })
}

// Ruby method `s(type, *children)` at line 12.
pub fn ruby_parser_l12_d2_s(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('Parse#s requires a node type')
	}
	return ast_node_value(new_ruby_ast_node(args[0].as_string(), args[1..]))
}

// Ruby method `require_parser(*constants)` at line 17.
pub fn ruby_parser_l17_d3_require_parser(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('Class', 'Parser')
	}
	path := require_parser_constant(args.map(it.as_string()))
	return ruby.object_value('Class', path)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2: # typed: false
// 3:
// 4: module T::Props
// 5:   module Private
// 6:     module Parse
// 7:       def parse(source)
// 8:         @current_ruby ||= require_parser(:CurrentRuby)
// 9:         @current_ruby.parse(source)
// 10:       end
// 11:
// 12:       def s(type, *children)
// 13:         @node ||= require_parser(:AST, :Node)
// 14:         @node.new(type, children)
// 15:       end
// 16:
// 17:       private def require_parser(*constants)
// 18:         # This is an optional dependency for sorbet-runtime in general,
// 19:         # but is required here
// 20:         require 'parser/current'
// 21:
// 22:         # Hack to work around the static checker thinking the constant is
// 23:         # undefined
// 24:         cls = Kernel.const_get(:Parser, true)
// 25:         while (const = constants.shift)
// 26:           cls = cls.const_get(const, false)
// 27:         end
// 28:         cls
// 29:       end
// 30:     end
// 31:   end
// 32: end

module tab

import brew_runtime
import homebrew
import json2

// Translated from Homebrew/brew `tab/tab.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :poured_from_bottle` at line 11.
pub fn ruby_tab_l11_d1_poured_from_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_receiver(args, 'poured_from_bottle')
	return if tab.has_poured_from_bottle {
		brew_runtime.bool_value(tab.poured_from_bottle)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby attr_accessor `attr_accessor :poured_from_bottle` at line 11.
pub fn ruby_tab_l11_d2_poured_from_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_receiver(args, 'poured_from_bottle=')
	if args.len < 2 { panic('poured_from_bottle= requires a value') }
	tab.has_poured_from_bottle = args[1].type_name != 'NilClass'
	tab.poured_from_bottle = if tab.has_poured_from_bottle {
		args[1].as_bool() or { panic(err) }
	} else {
		false
	}
	return homebrew.tab_boundary_value(tab)
}

// Ruby attr_accessor `attr_accessor :built_as_bottle` at line 14.
pub fn ruby_tab_l14_d3_built_as_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_receiver(args, 'built_as_bottle')
	return if tab.has_built_as_bottle {
		brew_runtime.bool_value(tab.built_as_bottle)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby attr_accessor `attr_accessor :built_as_bottle` at line 14.
pub fn ruby_tab_l14_d4_built_as_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_receiver(args, 'built_as_bottle=')
	if args.len < 2 { panic('built_as_bottle= requires a value') }
	tab.has_built_as_bottle = args[1].type_name != 'NilClass'
	tab.built_as_bottle = if tab.has_built_as_bottle {
		args[1].as_bool() or { panic(err) }
	} else {
		false
	}
	return homebrew.tab_boundary_value(tab)
}

// Ruby attr_accessor `attr_accessor :stdlib` at line 17.
pub fn ruby_tab_l17_d5_stdlib(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_receiver(args, 'stdlib')
	return if tab.stdlib == '' {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		brew_runtime.string_value(tab.stdlib)
	}
}

// Ruby attr_accessor `attr_accessor :stdlib` at line 17.
pub fn ruby_tab_l17_d6_stdlib(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_receiver(args, 'stdlib=')
	if args.len < 2 { panic('stdlib= requires a value') }
	tab.stdlib = if args[1].type_name == 'NilClass' { '' } else { args[1].as_string() }
	return homebrew.tab_boundary_value(tab)
}

// Ruby attr_accessor `attr_accessor :aliases` at line 20.
pub fn ruby_tab_l20_d7_aliases(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_receiver(args, 'aliases')
	return if tab.has_aliases {
		brew_runtime.string_array_value(tab.aliases)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby attr_accessor `attr_accessor :aliases` at line 20.
pub fn ruby_tab_l20_d8_aliases(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_receiver(args, 'aliases=')
	if args.len < 2 { panic('aliases= requires a value') }
	tab.has_aliases = args[1].type_name != 'NilClass'
	tab.aliases = if tab.has_aliases {
		args[1].as_string_array() or { panic(err) }
	} else {
		[]string{}
	}
	return homebrew.tab_boundary_value(tab)
}

// Ruby attr_writer `attr_writer :used_options` at line 23.
pub fn ruby_tab_l23_d9_used_options(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_receiver(args, 'used_options=')
	if args.len < 2 { panic('used_options= requires a value') }
	tab.used_option_flags = if args[1].type_name == 'NilClass' { []string{} } else { args[1].as_string_array() or {
			panic(err)} }
	return homebrew.tab_boundary_value(tab)
}

// Ruby attr_writer `attr_writer :unused_options` at line 26.
pub fn ruby_tab_l26_d10_unused_options(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_receiver(args, 'unused_options=')
	if args.len < 2 { panic('unused_options= requires a value') }
	tab.unused_option_flags = if args[1].type_name == 'NilClass' { []string{} } else { args[1].as_string_array() or {
			panic(err)} }
	return homebrew.tab_boundary_value(tab)
}

// Ruby attr_writer `attr_writer :compiler` at line 29.
pub fn ruby_tab_l29_d11_compiler(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_receiver(args, 'compiler=')
	if args.len < 2 { panic('compiler= requires a value') }
	tab.compiler_value = if args[1].type_name == 'NilClass' { '' } else { args[1].as_string() }
	return homebrew.tab_boundary_value(tab)
}

// Ruby attr_writer `attr_writer :source_modified_time` at line 32.
pub fn ruby_tab_l32_d12_source_modified_time(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_receiver(args, 'source_modified_time=')
	if args.len < 2 { panic('source_modified_time= requires a value') }
	tab.has_source_modified_time = args[1].type_name != 'NilClass'
	tab.source_modified_time_value = if tab.has_source_modified_time { args[1].as_int() or {
			panic(err)} } else { 0 }
	return homebrew.tab_boundary_value(tab)
}

// Ruby attr_reader `attr_reader :tapped_from` at line 35.
pub fn ruby_tab_l35_d13_tapped_from(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_receiver(args, 'tapped_from')
	return if tab.tapped_from == '' {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		brew_runtime.string_value(tab.tapped_from)
	}
}

// Ruby attr_accessor `attr_accessor :changed_files` at line 38.
pub fn ruby_tab_l38_d14_changed_files(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_receiver(args, 'changed_files')
	return if tab.has_changed_files {
		brew_runtime.string_array_value(tab.changed_files)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby attr_accessor `attr_accessor :changed_files` at line 38.
pub fn ruby_tab_l38_d15_changed_files(args ...brew_runtime.Value) brew_runtime.Value {
	mut tab := tab_receiver(args, 'changed_files=')
	if args.len < 2 { panic('changed_files= requires a value') }
	tab.has_changed_files = args[1].type_name != 'NilClass'
	tab.changed_files = if tab.has_changed_files {
		args[1].as_string_array() or { panic(err) }
	} else {
		[]string{}
	}
	return homebrew.tab_boundary_value(tab)
}

// Ruby method `initialize(poured_from_bottle: nil, built_as_bottle: nil, changed_files: nil, stdlib: nil, aliases: nil,` at line 53.
pub fn ruby_tab_l53_d16_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return homebrew.ruby_tab_l76_d21_initialize(...args)
}

// Ruby method `self.create(formula_or_cask, compiler = DevelopmentTools.default_compiler, stdlib = nil)` at line 75.
pub fn ruby_tab_l75_d17_self_create(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name != 'Formula' {
		panic('Tab.create requires a Formula')
	}
	formula := homebrew.formula_from_boundary(args[0])
	runtime_dependencies := homebrew.formulary_runtime_dependency_formulae(formula,
		homebrew.default_formulary_lookup_config()) or { panic(err) }
	compiler := if args.len > 1 && args[1].type_name != 'NilClass' {
		args[1].as_string()
	} else {
		homebrew.default_tab_compiler()
	}
	stdlib := if args.len > 2 && args[2].type_name != 'NilClass' { args[2].as_string() } else { '' }
	return homebrew.tab_boundary_value(homebrew.tab_create_for_formula(formula,
		runtime_dependencies, compiler, stdlib))
}

// Ruby method `self.from_file_content(content, path)` at line 116.
pub fn ruby_tab_l116_d18_self_from_file_content(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Tab.from_file_content requires content and path') }
	return homebrew.tab_boundary_value(homebrew.tab_from_json(args[0].as_string(),
		args[1].as_string()) or { panic(err) })
}

// Ruby method `self.for_keg(keg)` at line 146.
pub fn ruby_tab_l146_d19_self_for_keg(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Tab.for_keg requires a path') }
	return homebrew.tab_boundary_value(homebrew.tab_for_keg(args[0].as_string()) or { panic(err) })
}

// Ruby method `self.for_name(name)` at line 162.
pub fn ruby_tab_l162_d20_self_for_name(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 { panic('Tab.for_name requires a name') }
	if receipt := homebrew.installed_tab_for_name(args[0].as_string()) {
		return homebrew.tab_boundary_value(receipt)
	}
	config := homebrew.default_formulary_lookup_config()
	rack := homebrew.formulary_to_rack(args[0].as_string(), config) or { panic(err) }
	formula := homebrew.formulary_from_rack(rack, '', '', false, []string{}, config) or {
		panic(err)
	}
	return homebrew.tab_boundary_value(homebrew.tab_for_formula(formula))
}

// Ruby method `self.remap_deprecated_options(deprecated_options, options)` at line 172.
pub fn ruby_tab_l172_d21_self_remap_deprecated_options(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Tab.remap_deprecated_options requires deprecated options and options') }
	mut deprecated := []homebrew.DeprecatedOption{}
	for old, current in args[0].attributes {
		deprecated << homebrew.new_deprecated_option(old, current)
	}
	flags := args[1].as_string_array() or { panic(err) }
	return brew_runtime.string_array_value(homebrew.remap_tab_deprecated_options(deprecated,
		homebrew.new_options(...flags)).as_flags())
}

// Ruby method `self.for_formula(formula)` at line 186.
pub fn ruby_tab_l186_d22_self_for_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name != 'Formula' {
		panic('Tab.for_formula requires a Formula')
	}
	return homebrew.tab_boundary_value(homebrew.tab_for_formula(homebrew.formula_from_boundary(args[0])))
}

// Ruby method `self.empty` at line 226.
pub fn ruby_tab_l226_d23_self_empty(args ...brew_runtime.Value) brew_runtime.Value {
	return homebrew.tab_boundary_value(homebrew.empty_tab())
}

// Ruby method `self.empty_source_versions` at line 244.
pub fn ruby_tab_l244_d24_self_empty_source_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Hash',
		json2.encode(json2.Any(homebrew.empty_tab_source_versions())))
}

// Ruby method `self.runtime_deps_hash(formula, deps)` at line 255.
pub fn ruby_tab_l255_d25_self_runtime_deps_hash(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 || args[0].type_name != 'Formula' {
		panic('Tab.runtime_deps_hash requires a Formula and dependencies')
	}
	dependencies := args[1].as_array() or { panic(err) }
	formula := homebrew.formula_from_boundary(args[0])
	declared := formula.deps().map(it.name)
	mut dependency_formulae := []homebrew.Formula{}
	for value in dependencies {
		if value.type_name == 'Formula' {
			dependency_formulae << homebrew.formula_from_boundary(value)
			continue
		}
		name := if value.type_name == 'Dependency' {
			value.attribute('name') or { value.as_string() }
		} else {
			value.as_string().split('\x1f')[0]
		}
		dependency_formulae << homebrew.dependency_to_formula(homebrew.new_dependency(name,
			[]string{}), false, homebrew.default_formulary_lookup_config()) or { panic(err) }
	}
	receipts :=
		dependency_formulae.map(homebrew.formula_to_runtime_dependency_receipt(it, declared))
	return brew_runtime.object_value('Array', json2.encode(receipts))
}

// Ruby method `any_args_or_options?` at line 262.
pub fn ruby_tab_l262_d26_any_args_or_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(tab_receiver(args, 'any_args_or_options?').any_args_or_options())
}

// Ruby method `with?(val)` at line 267.
pub fn ruby_tab_l267_d27_with(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Tab#with? requires a receiver and value') }
	tab := homebrew.tab_from_boundary(args[0])
	return brew_runtime.bool_value(if args[1].type_name == 'Dependency' {
		tab.with_dependency(homebrew.new_dependency(args[1].attribute('name') or {
			args[1].as_string()
		}, []string{}))
	} else {
		tab.with(args[1].as_string())
	})
}

// Ruby method `without?(val)` at line 276.
pub fn ruby_tab_l276_d28_without(args ...brew_runtime.Value) brew_runtime.Value {
	with_value := ruby_tab_l267_d27_with(...args)
	return brew_runtime.bool_value(!(with_value.as_bool() or { panic(err) }))
}

// Ruby method `include?(opt)` at line 281.
pub fn ruby_tab_l281_d29_include(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 { panic('Tab#include? requires a receiver and option') }
	return brew_runtime.bool_value(homebrew.tab_from_boundary(args[0]).includes(args[1].as_string()))
}

// Ruby method `head?` at line 286.
pub fn ruby_tab_l286_d30_head(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(tab_receiver(args, 'head?').head())
}

// Ruby method `stable?` at line 291.
pub fn ruby_tab_l291_d31_stable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(tab_receiver(args, 'stable?').stable())
}

// Ruby method `used_options` at line 299.
pub fn ruby_tab_l299_d32_used_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(tab_receiver(args, 'used_options').used_options().as_flags())
}

// Ruby method `unused_options` at line 304.
pub fn ruby_tab_l304_d33_unused_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(tab_receiver(args, 'unused_options').unused_options().as_flags())
}

// Ruby method `compiler` at line 309.
pub fn ruby_tab_l309_d34_compiler(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(tab_receiver(args, 'compiler').compiler())
}

// Ruby method `runtime_dependencies` at line 314.
pub fn ruby_tab_l314_d35_runtime_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_receiver(args, 'runtime_dependencies')
	return if dependencies := tab.runtime_dependencies() {
		brew_runtime.object_value('Array', json2.encode(dependencies))
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby method `cxxstdlib` at line 321.
pub fn ruby_tab_l321_d36_cxxstdlib(args ...brew_runtime.Value) brew_runtime.Value {
	stdlib := tab_receiver(args, 'cxxstdlib').cxxstdlib()
	return brew_runtime.structured_value('CxxStdlib', stdlib.inspect(), {
		'type':     stdlib.type_symbol()
		'compiler': stdlib.compiler
	})
}

// Ruby method `built_bottle?` at line 328.
pub fn ruby_tab_l328_d37_built_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(tab_receiver(args, 'built_bottle?').built_bottle())
}

// Ruby method `bottle?` at line 333.
pub fn ruby_tab_l333_d38_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(tab_receiver(args, 'bottle?').bottle())
}

// Ruby method `spec` at line 338.
pub fn ruby_tab_l338_d39_spec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Symbol', tab_receiver(args, 'spec').spec())
}

// Ruby method `versions` at line 343.
pub fn ruby_tab_l343_d40_versions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Hash',
		json2.encode(json2.Any(tab_receiver(args, 'versions').versions())))
}

// Ruby method `stable_version` at line 348.
pub fn ruby_tab_l348_d41_stable_version(args ...brew_runtime.Value) brew_runtime.Value {
	return if version := tab_receiver(args, 'stable_version').stable_version() {
		brew_runtime.object_value('Version', version.to_s())
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby method `head_version` at line 353.
pub fn ruby_tab_l353_d42_head_version(args ...brew_runtime.Value) brew_runtime.Value {
	return if version := tab_receiver(args, 'head_version').head_version() {
		brew_runtime.object_value('Version', version.to_s())
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby method `version_scheme` at line 358.
pub fn ruby_tab_l358_d43_version_scheme(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(i64(tab_receiver(args, 'version_scheme').version_scheme()))
}

// Ruby method `source_modified_time` at line 363.
pub fn ruby_tab_l363_d44_source_modified_time(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.int_value(tab_receiver(args, 'source_modified_time').source_modified_time())
}

// Ruby method `to_json(options = nil)` at line 368.
pub fn ruby_tab_l368_d45_to_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(tab_receiver(args, 'to_json').to_json())
}

// Ruby method `to_bottle_hash` at line 396.
pub fn ruby_tab_l396_d46_to_bottle_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('Hash', json2.encode(json2.Any(tab_receiver(args,
		'to_bottle_hash').bottle_attributes())))
}

// Ruby method `write` at line 414.
pub fn ruby_tab_l414_d47_write(args ...brew_runtime.Value) brew_runtime.Value {
	tab := tab_receiver(args, 'write')
	tab.write() or { panic(err) }
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `to_s` at line 423.
pub fn ruby_tab_l423_d48_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(tab_receiver(args, 'to_s').str())
}

fn tab_receiver(args []brew_runtime.Value, method string) homebrew.Tab {
	if args.len == 0 { panic('Tab#${method} requires a receiver') }
	return homebrew.tab_from_boundary(args[0])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class Tab < AbstractTab
// 5:   Cache = type_template { { fixed: T::Hash[T.any(Pathname, String), T.untyped] } }
// 6:
// 7:   # Check whether the formula was poured from a bottle.
// 8:   #
// 9:   # @api internal
// 10:   sig { returns(T.nilable(T::Boolean)) }
// 11:   attr_accessor :poured_from_bottle
// 12:
// 13:   sig { returns(T.nilable(T::Boolean)) }
// 14:   attr_accessor :built_as_bottle
// 15:
// 16:   sig { returns(T.nilable(T.any(String, Symbol))) }
// 17:   attr_accessor :stdlib
// 18:
// 19:   sig { returns(T.nilable(T::Array[String])) }
// 20:   attr_accessor :aliases
// 21:
// 22:   sig { params(used_options: T.nilable(T::Array[String])).returns(T.nilable(T::Array[String])) }
// 23:   attr_writer :used_options
// 24:
// 25:   sig { params(unused_options: T.nilable(T::Array[String])).returns(T.nilable(T::Array[String])) }
// 26:   attr_writer :unused_options
// 27:
// 28:   sig { params(compiler: T.nilable(T.any(String, Symbol))).returns(T.nilable(T.any(String, Symbol))) }
// 29:   attr_writer :compiler
// 30:
// 31:   sig { params(source_modified_time: T.nilable(Integer)).returns(T.nilable(Integer)) }
// 32:   attr_writer :source_modified_time
// 33:
// 34:   sig { returns(T.nilable(String)) }
// 35:   attr_reader :tapped_from
// 36:
// 37:   sig { returns(T.nilable(T::Array[Pathname])) }
// 38:   attr_accessor :changed_files
// 39:
// 40:   sig {
// 41:     params(poured_from_bottle:   T.nilable(T::Boolean),
// 42:            built_as_bottle:      T.nilable(T::Boolean),
// 43:            changed_files:        T.nilable(T::Array[T.any(Pathname, String)]),
// 44:            stdlib:               T.nilable(T.any(String, Symbol)),
// 45:            aliases:              T.nilable(T::Array[String]),
// 46:            used_options:         T.nilable(T::Array[String]),
// 47:            unused_options:       T.nilable(T::Array[String]),
// 48:            compiler:             T.nilable(T.any(String, Symbol)),
// 49:            source_modified_time: T.nilable(Integer),
// 50:            tapped_from:          T.nilable(String),
// 51:            rest:                 T.untyped).void
// 52:   }
// 53:   def initialize(poured_from_bottle: nil, built_as_bottle: nil, changed_files: nil, stdlib: nil, aliases: nil,
// 54:                  used_options: nil, unused_options: nil, compiler: nil, source_modified_time: nil,
// 55:                  tapped_from: nil, **rest)
// 56:     @poured_from_bottle = poured_from_bottle
// 57:     @built_as_bottle = built_as_bottle
// 58:     @changed_files = T.let(changed_files&.map { |f| Pathname(f) }, T.nilable(T::Array[Pathname]))
// 59:     @stdlib = stdlib
// 60:     @aliases = aliases
// 61:     @used_options = used_options
// 62:     @unused_options = unused_options
// 63:     @compiler = compiler
// 64:     @source_modified_time = source_modified_time
// 65:     @tapped_from = tapped_from
// 66:
// 67:     super(**rest)
// 68:   end
// 69:
// 70:   # Instantiates a {Tab} for a new installation of a formula.
// 71:   sig {
// 72:     override.params(formula_or_cask: T.any(Formula, Cask::Cask), compiler: T.any(Symbol, String),
// 73:                     stdlib: T.nilable(T.any(String, Symbol))).returns(T.attached_class)
// 74:   }
// 75:   def self.create(formula_or_cask, compiler = DevelopmentTools.default_compiler, stdlib = nil)
// 76:     formula = T.cast(formula_or_cask, Formula)
// 77:
// 78:     tab = super(formula)
// 79:     build = formula.build
// 80:     runtime_deps = formula.runtime_dependencies(undeclared: false)
// 81:
// 82:     tab.used_options = build.used_options.as_flags
// 83:     tab.unused_options = build.unused_options.as_flags
// 84:     tab.tabfile = formula.prefix/FILENAME
// 85:     tab.built_as_bottle = build.bottle?
// 86:     tab.poured_from_bottle = false
// 87:     tab.source_modified_time = formula.source_modified_time.to_i
// 88:     tab.compiler = compiler
// 89:     tab.stdlib = stdlib
// 90:     tab.aliases = formula.aliases
// 91:     tab.runtime_dependencies = Tab.runtime_deps_hash(formula, runtime_deps)
// 92:     active_spec = if formula.active_spec_sym == :head
// 93:       T.must(formula.head)
// 94:     else
// 95:       T.must(formula.stable)
// 96:     end
// 97:
// 98:     tab.source["spec"] = formula.active_spec_sym.to_s
// 99:     tab.source["path"] = formula.specified_path.to_s
// 100:     if (downloader = active_spec.downloader).cached_location.exist? &&
// 101:        (scm_revision = downloader.source_revision).present?
// 102:       tab.source["scm_revision"] = scm_revision
// 103:     end
// 104:     tab.source["versions"] = {
// 105:       "stable"                => formula.stable&.version&.to_s,
// 106:       "head"                  => formula.head&.version&.to_s,
// 107:       "version_scheme"        => formula.version_scheme,
// 108:       "compatibility_version" => formula.compatibility_version,
// 109:     }
// 110:
// 111:     tab
// 112:   end
// 113:
// 114:   # Like {from_file}, but bypass the cache.
// 115:   sig { params(content: String, path: T.any(Pathname, String)).returns(T.attached_class) }
// 116:   def self.from_file_content(content, path)
// 117:     tab = super
// 118:
// 119:     tab.tap = tab.tapped_from if !tab.tapped_from.nil? && tab.tapped_from != "path or URL"
// 120:     tab.tap = "homebrew/core" if ["mxcl/master", "Homebrew/homebrew"].include?(tab.tap)
// 121:
// 122:     if tab.source["spec"].nil?
// 123:       version = PkgVersion.parse(File.basename(File.dirname(path)))
// 124:       tab.source["spec"] = if version.head?
// 125:         "head"
// 126:       else
// 127:         "stable"
// 128:       end
// 129:     end
// 130:
// 131:     tab.source["versions"] ||= empty_source_versions
// 132:
// 133:     # Tabs created with Homebrew 1.5.13 through 4.0.17 inclusive created empty string versions in some cases.
// 134:     ["stable", "head"].each do |spec|
// 135:       tab.source["versions"][spec] = tab.source["versions"][spec].presence
// 136:     end
// 137:
// 138:     tab
// 139:   end
// 140:
// 141:   # Get the {Tab} for the given {Keg},
// 142:   # or a fake one if the formula is not installed.
// 143:   #
// 144:   # @api internal
// 145:   sig { params(keg: T.any(Keg, Pathname)).returns(T.attached_class) }
// 146:   def self.for_keg(keg)
// 147:     path = keg/FILENAME
// 148:
// 149:     tab = if path.exist?
// 150:       from_file(path)
// 151:     else
// 152:       empty
// 153:     end
// 154:
// 155:     tab.tabfile = path
// 156:     tab
// 157:   end
// 158:
// 159:   # Returns a {Tab} for the named formula's installation,
// 160:   # or a fake one if the formula is not installed.
// 161:   sig { params(name: String).returns(T.attached_class) }
// 162:   def self.for_name(name)
// 163:     rack = HOMEBREW_CELLAR/name
// 164:     if (keg = Keg.from_rack(rack))
// 165:       for_keg(keg)
// 166:     else
// 167:       for_formula(Formulary.from_rack(rack, keg:))
// 168:     end
// 169:   end
// 170:
// 171:   sig { params(deprecated_options: T::Array[DeprecatedOption], options: Options).returns(Options) }
// 172:   def self.remap_deprecated_options(deprecated_options, options)
// 173:     deprecated_options.each do |deprecated_option|
// 174:       option = options.find { |o| o.name == deprecated_option.old }
// 175:       next unless option
// 176:
// 177:       options -= [option]
// 178:       options << Option.new(deprecated_option.current, option.description)
// 179:     end
// 180:     options
// 181:   end
// 182:
// 183:   # Returns a {Tab} for an already installed formula,
// 184:   # or a fake one if the formula is not installed.
// 185:   sig { params(formula: Formula).returns(T.attached_class) }
// 186:   def self.for_formula(formula)
// 187:     paths = []
// 188:
// 189:     paths << formula.opt_prefix.resolved_path if formula.opt_prefix.symlink? && formula.opt_prefix.directory?
// 190:
// 191:     paths << formula.linked_keg.resolved_path if formula.linked_keg.symlink? && formula.linked_keg.directory?
// 192:
// 193:     if (dirs = formula.installed_prefixes).length == 1
// 194:       paths << dirs.first
// 195:     end
// 196:
// 197:     paths << formula.latest_installed_prefix
// 198:
// 199:     path = paths.map { |pathname| pathname/FILENAME }.find(&:file?)
// 200:
// 201:     if path
// 202:       tab = from_file(path)
// 203:       used_options = remap_deprecated_options(formula.deprecated_options, tab.used_options)
// 204:       tab.used_options = used_options.as_flags
// 205:     else
// 206:       # Formula is not installed. Return a fake tab.
// 207:       tab = empty
// 208:       tab.unused_options = formula.options.as_flags
// 209:       tab.source = {
// 210:         "path"         => formula.specified_path.to_s,
// 211:         "tap"          => formula.tap&.name,
// 212:         "tap_git_head" => formula.tap_git_head,
// 213:         "spec"         => formula.active_spec_sym.to_s,
// 214:         "versions"     => {
// 215:           "stable"         => formula.stable&.version&.to_s,
// 216:           "head"           => formula.head&.version&.to_s,
// 217:           "version_scheme" => formula.version_scheme,
// 218:         },
// 219:       }
// 220:     end
// 221:
// 222:     tab
// 223:   end
// 224:
// 225:   sig { returns(T.attached_class) }
// 226:   def self.empty
// 227:     tab = super
// 228:
// 229:     tab.used_options = []
// 230:     tab.unused_options = []
// 231:     tab.built_as_bottle = false
// 232:     tab.poured_from_bottle = false
// 233:     tab.source_modified_time = 0
// 234:     tab.stdlib = nil
// 235:     tab.compiler = DevelopmentTools.default_compiler
// 236:     tab.aliases = []
// 237:     tab.source["spec"] = "stable"
// 238:     tab.source["versions"] = empty_source_versions
// 239:
// 240:     tab
// 241:   end
// 242:
// 243:   sig { returns(T::Hash[String, T.untyped]) }
// 244:   def self.empty_source_versions
// 245:     {
// 246:       "stable"                => nil,
// 247:       "head"                  => nil,
// 248:       "version_scheme"        => 0,
// 249:       "compatibility_version" => nil,
// 250:     }
// 251:   end
// 252:   private_class_method :empty_source_versions
// 253:
// 254:   sig { params(formula: Formula, deps: T::Array[Dependency]).returns(T::Array[T::Hash[String, T.untyped]]) }
// 255:   def self.runtime_deps_hash(formula, deps)
// 256:     deps.map do |dep|
// 257:       formula_to_dep_hash(dep.to_formula, formula.deps.map(&:name))
// 258:     end
// 259:   end
// 260:
// 261:   sig { returns(T::Boolean) }
// 262:   def any_args_or_options?
// 263:     !used_options.empty? || !unused_options.empty?
// 264:   end
// 265:
// 266:   sig { params(val: T.any(String, Dependency, Requirement)).returns(T::Boolean) }
// 267:   def with?(val)
// 268:     option_names = val.is_a?(String) ? [val] : val.option_names
// 269:
// 270:     option_names.any? do |name|
// 271:       include?("with-#{name}") || unused_options.include?("without-#{name}")
// 272:     end
// 273:   end
// 274:
// 275:   sig { params(val: T.any(String, Dependency, Requirement)).returns(T::Boolean) }
// 276:   def without?(val)
// 277:     !with?(val)
// 278:   end
// 279:
// 280:   sig { params(opt: String).returns(T::Boolean) }
// 281:   def include?(opt)
// 282:     used_options.include? opt
// 283:   end
// 284:
// 285:   sig { returns(T::Boolean) }
// 286:   def head?
// 287:     spec == :head
// 288:   end
// 289:
// 290:   sig { returns(T::Boolean) }
// 291:   def stable?
// 292:     spec == :stable
// 293:   end
// 294:
// 295:   # The options used to install the formula.
// 296:   #
// 297:   # @api internal
// 298:   sig { returns(Options) }
// 299:   def used_options
// 300:     Options.create(@used_options)
// 301:   end
// 302:
// 303:   sig { returns(Options) }
// 304:   def unused_options
// 305:     Options.create(@unused_options)
// 306:   end
// 307:
// 308:   sig { returns(T.any(String, Symbol)) }
// 309:   def compiler
// 310:     @compiler || DevelopmentTools.default_compiler
// 311:   end
// 312:
// 313:   sig { override.returns(RuntimeDependencies) }
// 314:   def runtime_dependencies
// 315:     # Homebrew versions prior to 1.1.6 generated incorrect runtime dependency
// 316:     # lists.
// 317:     @runtime_dependencies if parsed_homebrew_version >= "1.1.6"
// 318:   end
// 319:
// 320:   sig { returns(CxxStdlib) }
// 321:   def cxxstdlib
// 322:     # Older tabs won't have these values, so provide sensible defaults
// 323:     lib = stdlib&.to_sym
// 324:     CxxStdlib.create(lib, compiler.to_sym)
// 325:   end
// 326:
// 327:   sig { returns(T::Boolean) }
// 328:   def built_bottle?
// 329:     !!built_as_bottle && !poured_from_bottle
// 330:   end
// 331:
// 332:   sig { returns(T::Boolean) }
// 333:   def bottle?
// 334:     !!built_as_bottle
// 335:   end
// 336:
// 337:   sig { returns(Symbol) }
// 338:   def spec
// 339:     source["spec"].to_sym
// 340:   end
// 341:
// 342:   sig { returns(T::Hash[String, T.untyped]) }
// 343:   def versions
// 344:     source["versions"]
// 345:   end
// 346:
// 347:   sig { returns(T.nilable(Version)) }
// 348:   def stable_version
// 349:     versions["stable"]&.then { Version.new(it) }
// 350:   end
// 351:
// 352:   sig { returns(T.nilable(Version)) }
// 353:   def head_version
// 354:     versions["head"]&.then { Version.new(it) }
// 355:   end
// 356:
// 357:   sig { returns(Integer) }
// 358:   def version_scheme
// 359:     versions["version_scheme"] || 0
// 360:   end
// 361:
// 362:   sig { returns(Time) }
// 363:   def source_modified_time
// 364:     Time.at(@source_modified_time || 0)
// 365:   end
// 366:
// 367:   sig { params(options: T.nilable(T::Hash[String, T.untyped])).returns(String) }
// 368:   def to_json(options = nil)
// 369:     attributes = {
// 370:       "homebrew_version"         => homebrew_version,
// 371:       "used_options"             => used_options.as_flags,
// 372:       "unused_options"           => unused_options.as_flags,
// 373:       "built_as_bottle"          => built_as_bottle,
// 374:       "poured_from_bottle"       => poured_from_bottle,
// 375:       "loaded_from_api"          => loaded_from_api,
// 376:       "loaded_from_internal_api" => loaded_from_internal_api,
// 377:       "installed_on_request"     => installed_on_request,
// 378:       "changed_files"            => changed_files&.map(&:to_s),
// 379:       "time"                     => time,
// 380:       "source_modified_time"     => source_modified_time.to_i,
// 381:       "stdlib"                   => stdlib&.to_s,
// 382:       "compiler"                 => compiler.to_s,
// 383:       "aliases"                  => aliases,
// 384:       "runtime_dependencies"     => runtime_dependencies,
// 385:       "source"                   => source,
// 386:       "arch"                     => arch,
// 387:       "built_on"                 => built_on,
// 388:     }
// 389:     attributes.delete("stdlib") if attributes["stdlib"].blank?
// 390:
// 391:     JSON.pretty_generate(attributes, options)
// 392:   end
// 393:
// 394:   # A subset of to_json that we care about for bottles.
// 395:   sig { returns(T::Hash[String, T.untyped]) }
// 396:   def to_bottle_hash
// 397:     attributes = {
// 398:       "homebrew_version"     => homebrew_version,
// 399:       "changed_files"        => changed_files&.map(&:to_s),
// 400:       "source_modified_time" => source_modified_time.to_i,
// 401:       "stdlib"               => stdlib&.to_s,
// 402:       "compiler"             => compiler.to_s,
// 403:       "runtime_dependencies" => runtime_dependencies,
// 404:       "source"               => source.slice("scm_revision").compact.presence,
// 405:       "arch"                 => arch,
// 406:       "built_on"             => built_on,
// 407:     }
// 408:     attributes.delete("stdlib") if attributes["stdlib"].blank?
// 409:     attributes.delete("source") if attributes["source"].blank?
// 410:     attributes
// 411:   end
// 412:
// 413:   sig { void }
// 414:   def write
// 415:     # If this is a new installation, the cache of installed formulae
// 416:     # will no longer be valid.
// 417:     Formula.clear_cache unless tabfile&.exist?
// 418:
// 419:     super
// 420:   end
// 421:
// 422:   sig { returns(String) }
// 423:   def to_s
// 424:     s = []
// 425:     s << if poured_from_bottle
// 426:       "Poured from bottle"
// 427:     else
// 428:       "Built from source"
// 429:     end
// 430:
// 431:     if loaded_from_internal_api
// 432:       s << "using the internal formulae.brew.sh API"
// 433:     elsif loaded_from_api
// 434:       s << "using the formulae.brew.sh API"
// 435:     end
// 436:
// 437:     if (t = time)
// 438:       s << Time.at(t).strftime("on %Y-%m-%d at %H:%M:%S")
// 439:     end
// 440:
// 441:     unless used_options.empty?
// 442:       s << "with:"
// 443:       s << used_options.to_a.join(" ")
// 444:     end
// 445:     s.join(" ")
// 446:   end
// 447: end

module bundle

import ruby

// Translated from Homebrew/brew `bundle/subcommand_context.rb`.

pub struct SubcommandContextArgs {
pub:
	predicates map[string]bool
}

pub struct SubcommandContextExtension {
pub:
	type_name                     string
	predicate_method              string
	dump_disable_predicate_method string
	disable_predicate_method      string
}

pub struct SubcommandTypeContext {
pub:
	no_type_args bool
	extensions   []SubcommandContextExtension
}

fn subcommand_predicate(args SubcommandContextArgs, method string) bool {
	return args.predicates[method]
}

pub fn subcommand_extension_selected(args SubcommandContextArgs,
	extension SubcommandContextExtension) bool {
	return subcommand_predicate(args, extension.predicate_method)
}

pub fn subcommand_extension_dump_disabled(args SubcommandContextArgs,
	extension SubcommandContextExtension) bool {
	return subcommand_predicate(args, extension.dump_disable_predicate_method)
		|| subcommand_predicate(args, 'no_dump_${extension.type_name}?')
}

pub fn subcommand_extension_disabled(args SubcommandContextArgs,
	extension SubcommandContextExtension) bool {
	return subcommand_predicate(args, extension.disable_predicate_method)
		|| subcommand_predicate(args, 'no_cleanup_${extension.type_name}?')
}

pub fn subcommand_type_disabled(args SubcommandContextArgs, disabled_methods []string) bool {
	for method in disabled_methods {
		if subcommand_predicate(args, method) {
			return true
		}
	}
	return false
}

pub fn subcommand_type_selected(args SubcommandContextArgs, context SubcommandTypeContext,
	predicate_method string, disabled_predicate_method string, env_disabled_predicate_method string,
	all bool) bool {
	return !subcommand_type_disabled(args, [disabled_predicate_method, env_disabled_predicate_method])
		&& (subcommand_predicate(args, predicate_method) || all || context.no_type_args)
}

pub fn subcommand_core_type_options(args SubcommandContextArgs, context SubcommandTypeContext,
	prefix string, all bool) map[string]bool {
	return {
		'formulae': subcommand_type_selected(args, context, 'formulae?', 'no_formulae?', 'no_${prefix}_brew?', all)
		'casks':    subcommand_type_selected(args, context, 'casks?', 'no_casks?', 'no_${prefix}_cask?', all)
		'taps':     subcommand_type_selected(args, context, 'taps?', 'no_taps?', 'no_${prefix}_tap?', all)
	}
}

pub fn subcommand_selected_types(args SubcommandContextArgs,
	context SubcommandTypeContext) []string {
	mut selected := []string{}
	if subcommand_predicate(args, 'formulae?') {
		selected << 'brew'
	}
	if subcommand_predicate(args, 'casks?') {
		selected << 'cask'
	}
	if subcommand_predicate(args, 'taps?') {
		selected << 'tap'
	}
	for extension in context.extensions {
		if subcommand_extension_selected(args, extension) && extension.type_name !in selected {
			selected << extension.type_name
		}
	}
	if context.no_type_args {
		selected << 'none'
	}
	return selected
}

fn subcommand_context_args_from_value(value ruby.Value) SubcommandContextArgs {
	mut predicates := map[string]bool{}
	if value.type_name == 'Hash' {
		for method, selected in value.map_data {
			predicates[method] = selected.as_bool() or { false }
		}
	} else {
		for entry in value.attributes['predicates'].split(',') {
			if entry != '' {
				predicates[entry] = true
			}
		}
	}
	return SubcommandContextArgs{ predicates: predicates }
}

fn subcommand_extension_from_value(value ruby.Value) SubcommandContextExtension {
	type_name := value.attributes['type']
	return SubcommandContextExtension{
		type_name: type_name
		predicate_method: if value.attributes['predicate_method'] != '' {
			value.attributes['predicate_method']
		} else {
			'${type_name}?'
		}
		dump_disable_predicate_method: if value.attributes['dump_disable_predicate_method'] != '' {
			value.attributes['dump_disable_predicate_method']
		} else {
			'no_${type_name}?'
		}
		disable_predicate_method: if value.attributes['disable_predicate_method'] != '' {
			value.attributes['disable_predicate_method']
		} else {
			'no_${type_name}?'
		}
	}
}

fn subcommand_type_context_from_value(value ruby.Value) SubcommandTypeContext {
	mut extensions := []SubcommandContextExtension{}
	for extension_value in value.array_data {
		extensions << subcommand_extension_from_value(extension_value)
	}
	return SubcommandTypeContext{
		no_type_args: value.attributes['no_type_args'] == 'true'
		extensions: extensions
	}
}

fn subcommand_bool_map_value(values map[string]bool) ruby.Value {
	mut result := map[string]ruby.Value{}
	for name, value in values {
		result[name] = ruby.bool_value(value)
	}
	return ruby.map_value(result)
}

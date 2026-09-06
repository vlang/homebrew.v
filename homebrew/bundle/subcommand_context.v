module bundle

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

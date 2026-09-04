module bundle

import ruby
import homebrew.bundle.extensions

// Translated from Homebrew/brew `bundle/subcommand.rb`.

pub struct BundleSubcommandArgs {
pub:
	subcommand         string = 'install'
	global             bool
	file               ?string
	no_upgrade         bool
	upgrade            bool
	verbose            bool
	force              bool
	quiet              bool
	jobs               ?string
	zap                bool
	formulae           bool
	casks              bool
	taps               bool
	extension_selected map[string]bool
	install            bool
	describe           bool
	no_describe        bool
	upgrade_formulae   ?string
}

pub struct BundleSubcommandContext {
pub:
	subcommand   string
	global       bool
	file         ?string
	no_upgrade   bool
	verbose      bool
	force        bool
	ask          bool
	jobs         int
	zap          bool
	no_type_args bool
	extensions   []extensions.ExtensionDefinition
}

pub struct BundleSubcommandConfig {
pub:
	environment            map[string]string
	ask                    bool = true
	bundle_jobs            ?string
	processor_count        int = 1
	registered_subcommands []string
}

pub struct BundleSubcommandRunOptions {
pub:
	quiet      bool
	cleanup    bool
	preinstall bool
}

pub struct BundleSubcommandInvocation {
pub:
	subcommand string
	options    BundleSubcommandRunOptions
}

pub struct BundleSubcommandDispatchResult {
pub:
	context                      BundleSubcommandContext
	environment_after            map[string]string
	bundle_dump_describe_checked bool
	upgrade_formulae             []string
	invocations                  []BundleSubcommandInvocation
	executions                   []ruby.Value
}

pub type BundleSubcommandRunner = fn (subcommand string, args BundleSubcommandArgs, context BundleSubcommandContext, options BundleSubcommandRunOptions) !ruby.Value

fn bundle_subcommand_registered(config BundleSubcommandConfig) []string {
	if config.registered_subcommands.len > 0 {
		return config.registered_subcommands.clone()
	}
	// These are the classes loaded by the Dir glob at lines 12-14 of the retained source.
	return ['add', 'check', 'cleanup', 'dump', 'edit', 'env', 'exec', 'install', 'list', 'remove',
		'sh']
}

fn bundle_subcommand_upgrade_formulae(value ?string) []string {
	if concrete := value {
		if concrete == '' {
			return []
		}
		return concrete.split(',')
	}
	return []
}

pub fn bundle_subcommand_no_type_args(args BundleSubcommandArgs,
	extension_definitions []extensions.ExtensionDefinition) bool {
	if args.formulae || args.casks || args.taps {
		return false
	}
	for extension in extension_definitions {
		if args.extension_selected[extension.type_name] {
			return false
		}
	}
	return true
}

pub fn build_bundle_subcommand_context(args BundleSubcommandArgs,
	extension_definitions []extensions.ExtensionDefinition, config BundleSubcommandConfig,
	ask bool) BundleSubcommandContext {
	jobs_argument := args.jobs or { config.bundle_jobs or { '' } }
	mut jobs := 1
	if jobs_argument == 'auto' {
		processors := if config.processor_count > 0 { config.processor_count } else { 1 }
		jobs = if processors < 4 { processors } else { 4 }
	} else if jobs_argument != '' {
		jobs = jobs_argument.int()
	}
	if jobs < 1 {
		jobs = 1
	}
	return BundleSubcommandContext{
		subcommand: if args.subcommand == '' { 'install' } else { args.subcommand }
		global: args.global
		file: args.file
		no_upgrade: if args.upgrade { false } else { args.no_upgrade }
		verbose: args.verbose
		force: args.force
		ask: ask
		jobs: jobs
		zap: args.zap
		no_type_args: bundle_subcommand_no_type_args(args, extension_definitions)
		extensions: extension_definitions.clone()
	}
}

pub fn dispatch_bundle_subcommand(args BundleSubcommandArgs,
	extension_definitions []extensions.ExtensionDefinition, config BundleSubcommandConfig,
	runner BundleSubcommandRunner) !BundleSubcommandDispatchResult {
	context := build_bundle_subcommand_context(args, extension_definitions, config, config.ask)
	mut environment_after := config.environment.clone()

	// Don't want to ask for input in Bundle
	environment_after.delete('HOMEBREW_ASK')
	environment_after['HOMEBREW_NO_ASK'] = '1'

	mut invocations := []BundleSubcommandInvocation{}
	mut executions := []ruby.Value{}
	if args.install {
		options := BundleSubcommandRunOptions{
			quiet: true
			cleanup: false
			preinstall: true
		}
		invocations << BundleSubcommandInvocation{
			subcommand: 'install'
			options: options
		}
		executions << runner('install', args, context, options)!
	}

	if context.subcommand !in bundle_subcommand_registered(config) {
		return error('Unknown subcommand: ${context.subcommand}')
	}
	options := BundleSubcommandRunOptions{
		quiet: args.quiet
	}
	invocations << BundleSubcommandInvocation{
		subcommand: context.subcommand
		options: options
	}
	executions << runner(context.subcommand, args, context, options)!
	return BundleSubcommandDispatchResult{
		context: context
		environment_after: environment_after
		bundle_dump_describe_checked: !args.describe && !args.no_describe
		upgrade_formulae: bundle_subcommand_upgrade_formulae(args.upgrade_formulae)
		invocations: invocations
		executions: executions
	}
}

fn bundle_subcommand_optional_string(values map[string]ruby.Value, key string) ?string {
	if value := values[key] {
		if value.type_name != 'NilClass' {
			return value.as_string()
		}
	}
	return none
}

fn bundle_subcommand_bool(values map[string]ruby.Value, key string, fallback bool) !bool {
	if value := values[key] {
		return value.as_bool()!
	}
	return fallback
}

fn bundle_subcommand_bool_map(value ruby.Value) !map[string]bool {
	values := value.as_map()!
	mut result := map[string]bool{}
	for name, selected in values {
		result[name] = selected.as_bool()!
	}
	return result
}

fn bundle_subcommand_args_from_value(value ruby.Value) !BundleSubcommandArgs {
	values := value.as_map()!
	return BundleSubcommandArgs{
		subcommand: (values['subcommand'] or { ruby.string_value('install') }).as_string()
		global: bundle_subcommand_bool(values, 'global', false)!
		file: bundle_subcommand_optional_string(values, 'file')
		no_upgrade: bundle_subcommand_bool(values, 'no_upgrade', false)!
		upgrade: bundle_subcommand_bool(values, 'upgrade', false)!
		verbose: bundle_subcommand_bool(values, 'verbose', false)!
		force: bundle_subcommand_bool(values, 'force', false)!
		quiet: bundle_subcommand_bool(values, 'quiet', false)!
		jobs: bundle_subcommand_optional_string(values, 'jobs')
		zap: bundle_subcommand_bool(values, 'zap', false)!
		formulae: bundle_subcommand_bool(values, 'formulae', false)!
		casks: bundle_subcommand_bool(values, 'casks', false)!
		taps: bundle_subcommand_bool(values, 'taps', false)!
		extension_selected: bundle_subcommand_bool_map(values['extension_selected'] or {
			ruby.map_value(map[string]ruby.Value{})
		})!
		install: bundle_subcommand_bool(values, 'install', false)!
		describe: bundle_subcommand_bool(values, 'describe', false)!
		no_describe: bundle_subcommand_bool(values, 'no_describe', false)!
		upgrade_formulae: bundle_subcommand_optional_string(values, 'upgrade_formulae')
	}
}

fn bundle_subcommand_extensions_from_value(value ruby.Value) ![]extensions.ExtensionDefinition {
	return value.as_array()!.map(extensions.extension_definition_from_value(it))
}

fn bundle_subcommand_string_map(value ruby.Value) !map[string]string {
	values := value.as_map()!
	mut result := map[string]string{}
	for name, item in values {
		result[name] = item.as_string()
	}
	return result
}

fn bundle_subcommand_config_from_value(value ruby.Value) !BundleSubcommandConfig {
	values := value.as_map()!
	return BundleSubcommandConfig{
		environment: bundle_subcommand_string_map(values['environment'] or {
			ruby.map_value(map[string]ruby.Value{})
		})!
		ask: bundle_subcommand_bool(values, 'ask', true)!
		bundle_jobs: bundle_subcommand_optional_string(values, 'bundle_jobs')
		processor_count: int((values['processor_count'] or { ruby.int_value(1) }).as_int()!)
		registered_subcommands: (values['registered_subcommands'] or {
			ruby.string_array_value([]string{})
		}).as_string_array()!
	}
}

fn bundle_subcommand_optional_value(value ?string) ruby.Value {
	return if concrete := value {
		ruby.string_value(concrete)
	} else {
		ruby.object_value('NilClass', '')
	}
}

pub fn bundle_subcommand_context_value(context BundleSubcommandContext) ruby.Value {
	return ruby.map_value({
		'subcommand':   ruby.string_value(context.subcommand)
		'global':       ruby.bool_value(context.global)
		'file':         bundle_subcommand_optional_value(context.file)
		'no_upgrade':   ruby.bool_value(context.no_upgrade)
		'verbose':      ruby.bool_value(context.verbose)
		'force':        ruby.bool_value(context.force)
		'ask':          ruby.bool_value(context.ask)
		'jobs':         ruby.int_value(context.jobs)
		'zap':          ruby.bool_value(context.zap)
		'no_type_args': ruby.bool_value(context.no_type_args)
		'extensions':   ruby.array_value(context.extensions.map(extensions.extension_definition_value(it)))
	})
}

fn bundle_subcommand_invocation_value(invocation BundleSubcommandInvocation) ruby.Value {
	return ruby.map_value({
		'subcommand': ruby.string_value(invocation.subcommand)
		'quiet':      ruby.bool_value(invocation.options.quiet)
		'cleanup':    ruby.bool_value(invocation.options.cleanup)
		'preinstall': ruby.bool_value(invocation.options.preinstall)
	})
}

fn bundle_subcommand_environment_value(environment map[string]string) ruby.Value {
	mut values := map[string]ruby.Value{}
	for name, value in environment {
		values[name] = ruby.string_value(value)
	}
	return ruby.map_value(values)
}

fn bundle_subcommand_dispatch_result_value(result BundleSubcommandDispatchResult) ruby.Value {
	return ruby.map_value({
		'context':                      bundle_subcommand_context_value(result.context)
		'environment_after':            bundle_subcommand_environment_value(result.environment_after)
		'bundle_dump_describe_checked': ruby.bool_value(result.bundle_dump_describe_checked)
		'upgrade_formulae':             ruby.string_array_value(result.upgrade_formulae)
		'invocations':                  ruby.array_value(result.invocations.map(bundle_subcommand_invocation_value(it)))
		'executions':                   ruby.array_value(result.executions)
	})
}

fn bundle_subcommand_boundary_runner(subcommand string, _ BundleSubcommandArgs,
	_ BundleSubcommandContext, options BundleSubcommandRunOptions) !ruby.Value {
	return ruby.map_value({
		'subcommand': ruby.string_value(subcommand)
		'quiet':      ruby.bool_value(options.quiet)
		'cleanup':    ruby.bool_value(options.cleanup)
		'preinstall': ruby.bool_value(options.preinstall)
	})
}

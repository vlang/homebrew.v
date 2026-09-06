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

fn bundle_subcommand_boundary_runner(subcommand string, _ BundleSubcommandArgs,
	_ BundleSubcommandContext, options BundleSubcommandRunOptions) !ruby.Value {
	return ruby.map_value({
		'subcommand': ruby.string_value(subcommand)
		'quiet':      ruby.bool_value(options.quiet)
		'cleanup':    ruby.bool_value(options.cleanup)
		'preinstall': ruby.bool_value(options.preinstall)
	})
}

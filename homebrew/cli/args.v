module cli

// Translated from Homebrew/brew `cli/args.rb`.

// ArgValueKind preserves the Ruby argument table's switch, scalar flag and
// comma-array values without falling back to an untyped boundary.
pub enum ArgValueKind {
	unset
	switch_value
	flag_value
	comma_array
}

pub struct ArgValue {
pub:
	kind    ArgValueKind
	enabled bool
	text    string
	items   []string
}

pub struct ArgsContext {
pub:
	debug   bool
	quiet   bool
	verbose bool
}

pub struct ArgsOsArch {
pub:
	os   string
	arch string
}

@[heap]
pub struct Args {
pub mut:
	options_only      []string
	flags_only        []string
	remaining         []string
	named             NamedArgs
	values            map[string]ArgValue
	processed_options []ProcessedOption
	cask_options      bool
	without_api       bool
	cli_args_cache    []string
	cli_args_loaded   bool
	current_os        string
	current_arch      string
}

pub fn new_args() &Args {
	return &Args{
		named: new_named_args([])
	}
}

pub fn (args Args) no_named() bool {
	return args.named.empty()
}

pub fn (args Args) has(name string) bool {
	value := args.values[option_to_name(name)] or { return false }
	return match value.kind {
		.switch_value { value.enabled }
		.flag_value { value.text.len > 0 }
		.comma_array { value.items.len > 0 }
		.unset { false }
	}
}

pub fn (args Args) switch_value(name string) ?bool {
	value := args.values[option_to_name(name)] or { return none }
	if value.kind != .switch_value {
		return none
	}
	return value.enabled
}

pub fn (args Args) flag_value(name string) ?string {
	value := args.values[option_to_name(name)] or { return none }
	if value.kind != .flag_value {
		return none
	}
	return value.text
}

pub fn (args Args) comma_array_value(name string) ?[]string {
	value := args.values[option_to_name(name)] or { return none }
	if value.kind != .comma_array {
		return none
	}
	return value.items.clone()
}

// value implements Args#value: only a long flag in --name=value form is
// returned, matching the flags_only lookup in the Ruby source.
pub fn (args Args) value(name string) ?string {
	prefix := '--${name}='
	for flag in args.flags_only {
		if flag.starts_with(prefix) {
			return flag[prefix.len..]
		}
	}
	return none
}

pub fn (args Args) only_formula_or_cask() ?string {
	formula := args.has('formula')
	cask := args.has('cask')
	if formula && !cask {
		return 'formula'
	}
	if cask && !formula {
		return 'cask'
	}
	return none
}

pub fn (mut args Args) freeze_remaining_args(remaining []string) {
	args.remaining = remaining.clone()
}

pub fn (mut args Args) freeze_named_args(named []string, cask_options bool, without_api bool) {
	args.cask_options = cask_options
	args.without_api = without_api
	args.named = new_named_args_with_config(named, NamedArgsConfig{
		parent: NamedArgsParent{
			package_type: args.only_formula_or_cask() or { '' }
			options_only: args.options_only.clone()
		}
		override_spec: if args.has('HEAD') { 'head' } else { '' }
		force_bottle: args.has('force_bottle')
		flags: args.flags_only.clone()
		cask_options: cask_options
		without_api: without_api
	})
}

fn args_table_name(name string) string {
	return option_to_name(name.trim_right('?'))
}

pub fn (mut args Args) set_arg(name string, value ArgValue) {
	args.values[args_table_name(name)] = value
	args.cli_args_loaded = false
}

pub fn (args Args) tap_value() ?ArgValue {
	return args.values['tap']
}

pub fn (mut args Args) freeze_processed_options(options []ProcessedOption) {
	args.processed_options << options
	args.cli_args_loaded = false
	rendered := args.cli_args()
	args.options_only = rendered.filter(it.starts_with('-'))
	args.flags_only = rendered.filter(it.starts_with('--'))
}

pub fn (args Args) build_from_source_formulae() ![]string {
	if !args.has('build_from_source') && !args.has('HEAD') && !args.has('build_bottle') {
		return []
	}
	formulae := args.named.to_formulae()!
	return formulae.map(if it.full_name != '' { it.full_name } else { it.name })
}

pub fn (args Args) include_test_formulae() ![]string {
	if !args.has('include_test') {
		return []
	}
	formulae := args.named.to_formulae()!
	return formulae.map(if it.full_name != '' { it.full_name } else { it.name })
}

pub fn (args Args) context() ArgsContext {
	return ArgsContext{
		debug: args.has('debug')
		quiet: args.has('quiet')
		verbose: args.has('verbose')
	}
}

fn native_args_os() string {
	$if linux {
		return 'linux'
	} $else {
		return 'macos'
	}
}

fn native_args_arch() string {
	$if arm64 {
		return 'arm'
	} $else {
		return 'intel'
	}
}

fn valid_args_os_arch(os_name string, arch string) bool {
	if arch != 'arm' || os_name == 'linux' || os_name == 'macos' {
		return true
	}
	return os_name in ['big_sur', 'monterey', 'ventura', 'sonoma', 'sequoia', 'tahoe', 'golden_gate']
}

pub fn (args Args) os_arch_combinations() []ArgsOsArch {
	all_platforms := args.has('all_platforms')
	os_value := if all_platforms { 'all' } else { args.flag_value('os') or { '' } }
	arch_value := if all_platforms { 'all' } else { args.flag_value('arch') or { '' } }
	current_os := if args.current_os != '' { args.current_os } else { native_args_os() }
	current_arch := if args.current_arch != '' { args.current_arch } else { native_args_arch() }
	oses := if os_value == 'all' {
		['golden_gate', 'tahoe', 'sequoia', 'sonoma', 'ventura', 'monterey', 'big_sur', 'catalina',
			'linux']
	} else if os_value != '' {
		[os_value]
	} else {
		[current_os]
	}
	arches := if arch_value == 'all' {
		['intel', 'arm']
	} else if arch_value != '' {
		[arch_value]
	} else {
		[current_arch]
	}
	filter_invalid := os_value == 'all' || arch_value == 'all'
	mut combinations := []ArgsOsArch{}
	for os_name in oses {
		for arch in arches {
			if !filter_invalid || valid_args_os_arch(os_name, arch) {
				combinations << ArgsOsArch{
					os: os_name
					arch: arch
				}
			}
		}
	}
	return combinations
}

pub fn (mut args Args) cli_args() []string {
	if args.cli_args_loaded {
		return args.cli_args_cache.clone()
	}
	mut rendered := []string{}
	for processed in args.processed_options {
		option := if processed.long != '' { processed.long } else { processed.short }
		if option == '' {
			continue
		}
		value := args.values[args_table_name(option)] or { continue }
		match value.kind {
			.switch_value {
				if value.enabled {
					rendered << option
				}
			}
			.flag_value {
				rendered << '${option}=${value.text}'
			}
			.comma_array {
				rendered << '${option}=${value.items.join(',')}'
			}
			.unset {}
		}
	}
	args.cli_args_cache = rendered.clone()
	args.cli_args_loaded = true
	return rendered
}

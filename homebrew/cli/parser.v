module cli

import os

// Translated from Homebrew/brew `cli/parser.rb`.
pub enum OptionKind {
	switch_option
	required_flag
	optional_flag
	comma_array
}

pub struct OptionConfig {
pub:
	description     string
	hidden          bool
	depends_on      string
	env             string
	env_is_set      bool
	env_value       string
	env_counterpart string
	env_hidden      bool
	subcommands     []string
	replacement     string
	deprecated      bool
	disabled        bool
}

pub struct OptionSpec {
pub:
	names       []string
	description string
	kind        OptionKind
	hidden      bool
	depends_on  string
	subcommands []string
	replacement string
	deprecated  bool
	disabled    bool
}

pub struct ProcessedOption {
pub:
	short       string
	long        string
	description string
	hidden      bool
	type_name   string
}

pub struct SubcommandConfig {
pub:
	aliases       []string
	alias_options map[string]string
	description   string
	default       bool
	hidden        bool
	replacement   string
	deprecated    bool
	disabled      bool
}

pub struct Subcommand {
pub:
	name          string
	aliases       []string
	alias_options map[string]string
	default       bool
	hidden        bool
	replacement   string
	deprecated    bool
	disabled      bool
pub mut:
	description             string
	usage_banner            string
	named_types             []string
	named_types_are_choices bool
	named_min               int
	named_max               int
	has_named_min           bool
	has_named_max           bool
	named_without_api       bool
}

pub struct NamedArgumentConfig {
pub:
	types             []string
	types_are_choices bool
	number            ?int
	minimum           ?int
	maximum           ?int
	without_api       bool
}

pub struct FormulaOption {
pub:
	formula_name string
	option       string
	description  string
}

pub struct SplitArguments {
pub:
	options     []string
	non_options []string
}

struct ConstraintSpec {
	primary     string
	secondary   string
	subcommands []string
}

enum OptionSource {
	none
	env
	args
}

pub struct Parser {
pub:
	command_name string
mut:
	options                  []OptionSpec
	conflict_groups          [][]string
	constraints              []ConstraintSpec
	named_types              []string
	named_types_are_choices  bool
	named_min                int
	named_max                int
	has_named_min            bool
	has_named_max            bool
	named_without_api        bool
	parsed                   bool
	description_text         string
	root_usage_banner        string
	hide_from_man_page_value bool
	subcommands              []Subcommand
	current_subcommands      []string
	default_values           map[string]ArgValue
	default_sources          map[string]OptionSource
	last_sources             map[string]OptionSource
	last_args                Args
	has_last_args            bool
	formula_options_enabled  bool
	cask_options_enabled     bool
	allowed_commands         map[string]bool
	formula_option_catalog   []FormulaOption
	is_dev_command           bool
	command_aliases          []string
}

struct OptionMatch {
	index   int
	negated bool
}

// option_to_name is the typed translation of Parser.option_to_name.
pub fn option_to_name(option string) string {
	mut name := option
	for name.starts_with('-') {
		name = name[1..]
	}
	if name.starts_with('[no-]') {
		name = name[5..]
	}
	return name.replace('-', '_').replace('=', '')
}

pub fn name_to_option(name string) string {
	if name.len == 1 {
		return '-${name}'
	}
	return '--${name.replace('_', '-')}'
}

pub fn new_parser(command_name string) Parser {
	mut parser := Parser{
		command_name: command_name
		named_max: -1
		named_min: -1
		default_values: map[string]ArgValue{}
		default_sources: map[string]OptionSource{}
		last_sources: map[string]OptionSource{}
		allowed_commands: map[string]bool{}
	}
	parser.add_switch(['-d', '--debug'], OptionConfig{
		description: 'Display any debugging information.'
	})
	parser.add_switch(['-q', '--quiet'], OptionConfig{
		description: 'Make some output more quiet.'
	})
	parser.add_switch(['-v', '--verbose'], OptionConfig{
		description: 'Make some output more verbose.'
	})
	parser.add_switch(['-h', '--help'], OptionConfig{
		description: 'Show this message.'
	})
	return parser
}

pub fn (mut parser Parser) add_switch(names []string, config OptionConfig) {
	parser.add_option(names, .switch_option, config)
}

pub fn (mut parser Parser) add_flag(names []string, config OptionConfig) {
	required := names.any(it.ends_with('='))
	clean_names := names.map(it.trim_string_right('='))
	parser.add_option(clean_names, if required { .required_flag } else { .optional_flag }, config)
}

pub fn (mut parser Parser) add_comma_array(name string, config OptionConfig) {
	parser.add_option([name.trim_string_right('=')], .comma_array, config)
}

fn (mut parser Parser) add_option(names []string, kind OptionKind, config OptionConfig) {
	clean_names := names.map(it.replace('_', '-'))
	if clean_names.len == 0 {
		return
	}
	mut scoped_subcommands := if config.subcommands.len > 0 {
		parser.canonical_subcommands(config.subcommands)
	} else {
		parser.current_subcommands.clone()
	}
	if clean_names.any(is_global_option(it)) {
		scoped_subcommands = []
	}
	mut description := parser.option_description(config.description, clean_names, config.hidden || config.disabled || config.deprecated)
	if kind == .switch_option && config.env.len > 0 && parser.has_non_global_options() && !config.hidden && !config.deprecated && !config.disabled && !config.env_hidden {
		affix := if config.env_counterpart.len > 0 {
			' and `${config.env_counterpart}` is passed.'
		} else {
			'.'
		}
		description += ' Enabled by default if `\$HOMEBREW_${config.env.to_upper()}` is set${affix}'
	}
	long_name := preferred_option(clean_names)
	if long_name.starts_with('--') && parser.options.any(preferred_option(it.names) == long_name) {
		index := parser.option_index(long_name)
		existing := parser.options[index]
		merged_subcommands := if existing.subcommands.len == 0 || scoped_subcommands.len == 0 {
			[]string{}
		} else {
			array_union(existing.subcommands, scoped_subcommands)
		}
		parser.options[index] = OptionSpec{
			names: array_union(existing.names, clean_names)
			description: description
			kind: kind
			hidden: config.hidden || config.disabled || config.deprecated
			depends_on: config.depends_on
			subcommands: merged_subcommands
			replacement: config.replacement
			deprecated: config.deprecated
			disabled: config.disabled
		}
	} else {
		parser.options << OptionSpec{
			names: clean_names
			description: description
			kind: kind
			hidden: config.hidden || config.disabled || config.deprecated
			depends_on: config.depends_on
			subcommands: scoped_subcommands
			replacement: config.replacement
			deprecated: config.deprecated
			disabled: config.disabled
		}
	}
	for name in clean_names {
		if config.depends_on.len > 0 {
			parser.constraints << ConstraintSpec{
				primary: option_to_name(config.depends_on)
				secondary: option_to_name(name)
				subcommands: scoped_subcommands.clone()
			}
		}
	}
	if kind == .switch_option && !config.disabled {
		parser.disable_switch_values(clean_names)
		parser.apply_environment_switch(clean_names, config)
	} else {
		for name in clean_names {
			parser.default_values.delete(option_to_name(name))
		}
	}
}

fn (parser Parser) option_index(long_name string) int {
	for index, option in parser.options {
		if preferred_option(option.names) == long_name {
			return index
		}
	}
	return -1
}

fn (parser Parser) has_non_global_options() bool {
	return parser.options.any(!is_global_option(preferred_option(it.names)) && !it.hidden)
}

fn (parser Parser) subcommand_index(name string) int {
	for index, subcommand in parser.subcommands {
		if subcommand.name == name {
			return index
		}
	}
	return -1
}

fn array_union(first []string, second []string) []string {
	mut result := first.clone()
	for item in second {
		if item !in result {
			result << item
		}
	}
	return result
}

fn option_names_overlap(first []string, second []string) bool {
	for first_name in first {
		for second_name in second {
			if option_to_name(first_name) == option_to_name(second_name) {
				return true
			}
		}
	}
	return false
}

fn is_global_option(name string) bool {
	canonical := option_to_name(name)
	return canonical in ['d', 'debug', 'q', 'quiet', 'v', 'verbose', 'h', 'help']
}

fn (parser Parser) canonical_subcommands(names []string) []string {
	mut canonical := []string{}
	for name in names {
		if subcommand := parser.subcommand_for_name(name) {
			canonical << subcommand.name
		} else {
			canonical << name
		}
	}
	return canonical
}

fn (mut parser Parser) disable_switch_values(names []string) {
	for name in names {
		canonical := option_to_name(name)
		if name.contains('[no-]') {
			parser.default_values.delete(canonical)
			continue
		}
		parser.default_values[canonical] = ArgValue{
			kind: .switch_value
			enabled: false
		}
		parser.default_sources[canonical] = .none
	}
}

fn environment_truth(value string) bool {
	return value.len > 0
}

fn (mut parser Parser) apply_environment_switch(names []string, config OptionConfig) {
	if config.env.len == 0 {
		return
	}
	mut found := config.env_is_set
	mut value := config.env_value
	if !found {
		if actual := os.getenv_opt('HOMEBREW_${config.env.to_upper()}') {
			value = actual
			found = true
		}
	}
	if !found {
		return
	}
	for name in names {
		canonical := option_to_name(name)
		parser.default_values[canonical] = ArgValue{
			kind: .switch_value
			enabled: environment_truth(value)
		}
		parser.default_sources[canonical] = .env
	}
}

pub fn (mut parser Parser) add_conflicts(options []string) {
	parser.conflict_groups << options.map(option_to_name(it))
}

pub fn (mut parser Parser) set_named_args(types []string, minimum ?int, maximum ?int) {
	parser.configure_named_args(NamedArgumentConfig{
		types: types
		minimum: minimum
		maximum: maximum
	}) or { panic(err) }
}

pub fn (mut parser Parser) set_exact_named_args(types []string, number int) {
	parser.configure_named_args(NamedArgumentConfig{
		types: types
		number: number
	}) or { panic(err) }
}

pub fn (mut parser Parser) configure_named_args(config NamedArgumentConfig) ! {
	if number := config.number {
		if config.minimum != none || config.maximum != none {
			return error('Do not specify both `number` and `min` or `max`')
		}
		if config.types == ['none'] {
			return error('Do not specify both `number`, `min` or `max` with `named_args :none`')
		}
		_ = number
	}
	if config.types == ['none'] && (config.minimum != none || config.maximum != none) {
		return error('Do not specify both `number`, `min` or `max` with `named_args :none`')
	}
	if parser.current_subcommands.len > 0 {
		for current_name in parser.current_subcommands {
			index := parser.subcommand_index(current_name)
			if index < 0 {
				return error('unknown subcommand: ${current_name}')
			}
			parser.apply_named_config_to_subcommand(index, config)
		}
		return
	}
	parser.named_types = config.types.clone()
	parser.named_types_are_choices = config.types_are_choices
	parser.named_without_api = config.without_api
	parser.has_named_min = false
	parser.has_named_max = false
	parser.named_min = -1
	parser.named_max = -1
	if config.types == ['none'] {
		parser.named_max = 0
		parser.has_named_max = true
	} else if number := config.number {
		parser.named_min = number
		parser.named_max = number
		parser.has_named_min = true
		parser.has_named_max = true
	} else {
		if minimum := config.minimum {
			parser.named_min = minimum
			parser.has_named_min = true
		}
		if maximum := config.maximum {
			parser.named_max = maximum
			parser.has_named_max = true
		}
	}
}

fn (mut parser Parser) apply_named_config_to_subcommand(index int, config NamedArgumentConfig) {
	mut subcommand := parser.subcommands[index]
	subcommand.named_types = config.types.clone()
	subcommand.named_types_are_choices = config.types_are_choices
	subcommand.named_without_api = config.without_api
	subcommand.has_named_min = false
	subcommand.has_named_max = false
	if config.types == ['none'] {
		subcommand.named_max = 0
		subcommand.has_named_max = true
	} else if number := config.number {
		subcommand.named_min = number
		subcommand.named_max = number
		subcommand.has_named_min = true
		subcommand.has_named_max = true
	} else {
		if minimum := config.minimum {
			subcommand.named_min = minimum
			subcommand.has_named_min = true
		}
		if maximum := config.maximum {
			subcommand.named_max = maximum
			subcommand.has_named_max = true
		}
	}
	parser.subcommands[index] = subcommand
}

pub fn (mut parser Parser) set_description(text string) {
	parser.description_text = text.trim_space()
}

pub fn (parser Parser) description() string {
	return parser.description_text
}

pub fn (mut parser Parser) set_usage_banner(text string) ! {
	clean := text.trim_space()
	mut banner := clean
	mut description := ''
	if clean.contains('\n\n') {
		banner = clean.all_before('\n\n')
		description = clean.all_after('\n\n')
	}
	if parser.current_subcommands.len > 0 {
		for current_name in parser.current_subcommands {
			index := parser.subcommand_index(current_name)
			if index < 0 {
				return error('unknown subcommand: ${current_name}')
			}
			mut subcommand := parser.subcommands[index]
			subcommand.usage_banner = clean
			mut derived_description := description.trim_space()
			if derived_description.len == 0 {
				lines := clean.split_into_lines()
				if lines.len > 1 {
					derived_description = lines[1..].join('\n').trim_space()
				}
			}
			if subcommand.description.len == 0 && derived_description.len > 0 {
				subcommand.description = derived_description.split_into_lines()[0].trim_space()
			}
			parser.subcommands[index] = subcommand
		}
		return
	}
	parser.root_usage_banner = banner
	if description.len > 0 {
		parser.description_text = description.trim_space()
	}
}

pub fn (mut parser Parser) hide_from_man_page() {
	parser.hide_from_man_page_value = true
}

pub fn (parser Parser) is_hidden_from_man_page() bool {
	return parser.hide_from_man_page_value
}

pub fn (mut parser Parser) add_subcommand(name string, config SubcommandConfig, configure fn (mut Parser) !) ! {
	mut aliases := config.aliases.clone()
	for alias_name, _ in config.alias_options {
		if alias_name !in aliases {
			aliases << alias_name
		}
	}
	hidden := config.hidden || config.deprecated || config.disabled
	parser.subcommands << Subcommand{
		name: name
		aliases: aliases
		alias_options: config.alias_options.clone()
		description: config.description
		default: config.default
		hidden: hidden
		replacement: config.replacement
		deprecated: config.deprecated
		disabled: config.disabled
		named_min: -1
		named_max: -1
	}
	previous := parser.current_subcommands.clone()
	parser.current_subcommands = [name]
	configure(mut parser) or {
		parser.current_subcommands = previous
		return err
	}
	parser.current_subcommands = previous
}

pub fn (mut parser Parser) add_subcommand_without_block(name string, config SubcommandConfig) {
	parser.subcommands << Subcommand{
		name: name
		aliases: array_union(config.aliases, config.alias_options.keys())
		alias_options: config.alias_options.clone()
		description: config.description
		default: config.default
		hidden: config.hidden || config.deprecated || config.disabled
		replacement: config.replacement
		deprecated: config.deprecated
		disabled: config.disabled
		named_min: -1
		named_max: -1
	}
}

pub fn (mut parser Parser) add_subcommand_names(names []string, config SubcommandConfig) ! {
	if names.len != 1 {
		return error('wrong number of arguments (given ${names.len}, expected 1)')
	}
	parser.add_subcommand_without_block(names[0], config)
}

pub fn (parser Parser) subcommand_list() []Subcommand {
	return parser.subcommands.clone()
}

pub fn (parser Parser) subcommand_names() []string {
	return parser.subcommands.map(it.name)
}

pub fn (parser Parser) default_subcommand() ?Subcommand {
	for subcommand in parser.subcommands {
		if subcommand.default {
			return subcommand
		}
	}
	return none
}

pub fn (parser Parser) subcommand_for_name(name string) ?Subcommand {
	for subcommand in parser.subcommands {
		if subcommand.name == name || name in subcommand.aliases {
			return subcommand
		}
	}
	return none
}

pub fn (parser Parser) subcommand_name(named []string) ?string {
	if named.len == 0 {
		if default_command := parser.default_subcommand() {
			return default_command.name
		}
		return none
	}
	if command := parser.subcommand_for_name(named[0]) {
		return command.name
	}
	return none
}

pub fn (parser Parser) named_args_type() []string {
	if parser.subcommands.len > 0 {
		return parser.subcommand_names()
	}
	return parser.named_types.clone()
}

pub fn (parser Parser) minimum_named_args() ?int {
	if parser.has_named_min {
		return parser.named_min
	}
	return none
}

pub fn (parser Parser) processed_options() []ProcessedOption {
	return parser.options.filter(!it.disabled).map(option_to_processed(it))
}

fn option_to_processed(option OptionSpec) ProcessedOption {
	mut short := ''
	mut long := ''
	for name in option.names {
		if name.starts_with('--') {
			long = name
		} else if name.starts_with('-') {
			short = name
		}
	}
	return ProcessedOption{
		short: short
		long: long
		description: option.description
		hidden: option.hidden
		type_name: option.kind.str()
	}
}

pub fn (parser Parser) processed_options_for_subcommand(name string) []ProcessedOption {
	mut canonical := ''
	if name.len > 0 {
		command := parser.subcommand_for_name(name) or { return parser.processed_options_for_root_command() }
		canonical = command.name
	} else {
		command := parser.default_subcommand() or { return parser.processed_options_for_root_command() }
		canonical = command.name
	}
	return parser.options.filter(!it.disabled && (it.subcommands.len == 0 || canonical in it.subcommands)).map(option_to_processed(it))
}

pub fn (parser Parser) processed_options_for_root_command() []ProcessedOption {
	return parser.options.filter(!it.disabled && it.subcommands.len == 0).map(option_to_processed(it))
}

pub fn (parser Parser) named_args_type_for_subcommand(name string) []string {
	command := parser.subcommand_for_name(name) or { return [] }
	return command.named_types.clone()
}

pub fn (parser Parser) subcommands_for_option(option string) []string {
	canonical := option_to_name(option)
	for spec in parser.options {
		if spec.names.any(option_to_name(it) == canonical) {
			return spec.subcommands.clone()
		}
	}
	return []
}

pub fn (mut parser Parser) set_allowed_commands(commands []string) {
	for command in commands {
		parser.allowed_commands[command] = true
	}
}

pub fn (mut parser Parser) set_command_aliases(aliases []string) {
	parser.command_aliases = aliases.filter(it !in ['instal', 'uninstal'])
	parser.command_aliases.sort()
}

pub fn (mut parser Parser) set_developer_command(is_developer bool) {
	parser.is_dev_command = is_developer
}

pub fn (mut parser Parser) set_formula_option_catalog(options []FormulaOption) {
	parser.formula_option_catalog = options.clone()
}

pub fn (mut parser Parser) enable_formula_options() {
	parser.formula_options_enabled = true
}

fn (mut parser Parser) record_option_metadata(names []string, kind OptionKind, subcommands []string) {
	effective := parser.canonical_subcommands(if subcommands.len > 0 {
		subcommands
	} else {
		parser.current_subcommands
	})
	for index, option in parser.options {
		if !option_names_overlap(option.names, names) {
			continue
		}
		mut option_subcommands := option.subcommands.clone()
		if !option.names.any(is_global_option(it)) && effective.len > 0 {
			option_subcommands = array_union(option_subcommands, effective)
		}
		parser.options[index] = OptionSpec{
			...option
			kind: kind
			subcommands: option_subcommands
		}
	}
}

fn preferred_option(names []string) string {
	for name in names {
		if name.starts_with('--') {
			return name
		}
	}
	return names[0]
}

fn expanded_names(spec OptionSpec) map[string]bool {
	mut names := map[string]bool{}
	for raw_name in spec.names {
		name := raw_name.replace('_', '-')
		if name.contains('[no-]') {
			names[name.replace('[no-]', '')] = false
			names[name.replace('[no-]', 'no-')] = true
		} else {
			names[name] = false
		}
	}
	return names
}

fn (parser Parser) find_long_option(argument string) !OptionMatch {
	query := argument.replace('_', '-').all_before('=')
	mut exact := []OptionMatch{}
	mut abbreviated := []OptionMatch{}
	for index, spec in parser.options {
		for name, negated in expanded_names(spec) {
			if name == query {
				exact << OptionMatch{
					index: index
					negated: negated
				}
			} else if name.starts_with(query) {
				abbreviated << OptionMatch{
					index: index
					negated: negated
				}
			}
		}
	}
	if exact.len == 1 {
		return exact[0]
	}
	mut unique := map[int]OptionMatch{}
	for candidate in abbreviated {
		unique[candidate.index] = candidate
	}
	if unique.len > 1 {
		return error('ambiguous option: ${argument.all_before('=')}')
	}
	for _, candidate in unique {
		return candidate
	}
	return error('invalid option: ${argument.all_before('=')}')
}

fn (parser Parser) find_short_option(argument string) ?OptionMatch {
	for index, spec in parser.options {
		for name, negated in expanded_names(spec) {
			if name == argument {
				return OptionMatch{
					index: index
					negated: negated
				}
			}
		}
	}
	return none
}

fn set_option_value(mut values map[string]ArgValue, spec OptionSpec, value ArgValue) {
	for raw_name in spec.names {
		values[option_to_name(raw_name)] = value
	}
}

fn set_option_source(mut sources map[string]OptionSource, spec OptionSpec, source OptionSource) {
	for raw_name in spec.names {
		sources[option_to_name(raw_name)] = source
	}
}

fn parse_flag_value(argument string, argv []string, index int, required bool) !(string, bool) {
	if argument.contains('=') {
		return argument.all_after('='), false
	}
	if !required {
		return '', false
	}
	if index + 1 >= argv.len {
		return error('missing argument: ${argument}')
	}
	return argv[index + 1], true
}

fn apply_match(spec OptionSpec, matched OptionMatch, argument string, argv []string, index int,
	mut values map[string]ArgValue, mut sources map[string]OptionSource) !(string, bool) {
	if spec.disabled {
		return error('the `${preferred_option(spec.names)}` option is disabled')
	}
	if spec.deprecated {
		return error('the `${preferred_option(spec.names)}` option is deprecated')
	}
	match spec.kind {
		.switch_option {
			value := ArgValue{
				kind: .switch_value
				enabled: !matched.negated
			}
			if spec.names.any(it.contains('[no-]')) {
				values[option_to_name(spec.names[0])] = value
				sources[option_to_name(spec.names[0])] = .args
			} else {
				set_option_value(mut values, spec, value)
				set_option_source(mut sources, spec, .args)
			}
			return '', false
		}
		.required_flag, .optional_flag {
			text, consumed_next := parse_flag_value(argument, argv, index, spec.kind == .required_flag)!
			set_option_value(mut values, spec, ArgValue{
				kind: .flag_value
				text: text
			})
			set_option_source(mut sources, spec, .args)
			return text, consumed_next
		}
		.comma_array {
			text, consumed_next := parse_flag_value(argument, argv, index, true)!
			set_option_value(mut values, spec, ArgValue{
				kind: .comma_array
				items: text.split(',')
			})
			set_option_source(mut sources, spec, .args)
			return text, consumed_next
		}
	}
}

fn passed(values map[string]ArgValue, name string) bool {
	value := values[option_to_name(name)] or { return false }
	return match value.kind {
		.switch_value { value.enabled }
		.flag_value { true }
		.comma_array { true }
		.unset { false }
	}
}

fn (parser Parser) check_conflicts(mut values map[string]ArgValue,
	mut sources map[string]OptionSource) ! {
	for group in parser.conflict_groups {
		mut violations := group.filter(passed(values, it))
		if violations.len >= 2 {
			environment_options := violations.filter(sources[option_to_name(it)] or {
				OptionSource.none
			} == .env)
			if violations.len - environment_options.len == 1 {
				for option in environment_options {
					values[option_to_name(option)] = ArgValue{
						kind: .switch_value
						enabled: false
					}
				}
				violations = group.filter(passed(values, it))
			} else {
				return option_conflict_error(violations.map(name_to_option(it)))
			}
		}
	}
}

fn (parser Parser) check_invalid_constraints() ! {
	for group in parser.conflict_groups {
		for constraint in parser.constraints {
			if constraint.primary in group && constraint.secondary in group {
				return invalid_constraint_error(constraint.primary, constraint.secondary)
			}
		}
	}
}

fn (parser Parser) check_constraints(named []string, values map[string]ArgValue) ! {
	for constraint in parser.constraints {
		if constraint.subcommands.len > 0 {
			subcommand := parser.subcommand_name(named) or { continue }
			if subcommand !in constraint.subcommands {
				continue
			}
		}
		secondary := constraint.secondary
		primary := constraint.primary
		if passed(values, secondary) && !passed(values, primary) {
			return option_constraint_error(name_to_option(primary), name_to_option(secondary), true)
		}
	}
}

fn (parser Parser) check_constraint_violations(named []string, mut values map[string]ArgValue,
	mut sources map[string]OptionSource) ! {
	parser.check_invalid_constraints()!
	parser.check_conflicts(mut values, mut sources)!
	parser.check_constraints(named, values)!
}

fn named_error_types(types []string, choices bool) []string {
	if choices && types.len > 0 {
		return ['subcommand']
	}
	return types.filter(it != 'none')
}

fn check_named_args_count(named []string, types []string, choices bool, minimum int, maximum int,
	has_minimum bool, has_maximum bool) ! {
	error_types := named_error_types(types, choices)
	if has_minimum && has_maximum && minimum == maximum && named.len != maximum {
		return number_of_named_arguments_error(minimum, error_types)
	}
	if has_minimum && named.len < minimum {
		return min_named_arguments_error(minimum, error_types)
	}
	if has_maximum && named.len > maximum {
		return max_named_arguments_error(maximum, error_types)
	}
}

fn (parser Parser) check_named_args(named []string) ! {
	check_named_args_count(named, parser.named_types, parser.named_types_are_choices, parser.named_min, parser.named_max, parser.has_named_min, parser.has_named_max)!
}

fn rendered_option(spec OptionSpec, value ArgValue) string {
	option := preferred_option(spec.names)
	return match value.kind {
		.switch_value {
			option
		}
		.flag_value {
			if value.text.len > 0 {
				'${option}=${value.text}'
			} else {
				option
			}
		}
		.comma_array {
			'${option}=${value.items.join(',')}'
		}
		.unset {
			''
		}
	}
}

// parse implements the OptionParser loop, `--` splitting, named arguments,
// constraints and processed option lists used by the Ruby Parser#parse method.
pub fn (mut parser Parser) parse(argv []string, ignore_invalid_options bool) !Args {
	if parser.parsed {
		return error('Arguments were already parsed!')
	}
	if parser.formula_options_enabled && !only_casks(argv) {
		parser.install_formula_options(argv)
	}
	parser.parsed = true
	split := split_non_options(argv)
	before_separator := split.options
	after_separator := split.non_options
	mut values := parser.default_values.clone()
	mut sources := parser.default_sources.clone()
	mut remaining := []string{}
	mut index := 0
	for index < before_separator.len {
		argument := before_separator[index]
		if !argument.starts_with('-') || argument == '-' {
			remaining << argument
			index++
			continue
		}
		if argument.starts_with('--') {
			matched := parser.find_long_option(argument) or {
				if (ignore_invalid_options || parser.command_option_allowed(argument)) && err.msg().starts_with('invalid option:') {
					remaining << argument
					index++
					continue
				}
				eprintln(parser.generate_help_text())
				return err
			}
			spec := parser.options[matched.index]
			_, consumed_next := apply_match(spec, matched, argument, before_separator, index, mut values, mut sources)!
			index += if consumed_next { 2 } else { 1 }
			continue
		}
		if argument.len > 2 && !argument.contains('=') {
			mut all_switches := true
			for short_byte in argument[1..].bytes() {
				short_option := '-${short_byte.ascii_str()}'
				matched := parser.find_short_option(short_option) or {
					all_switches = false
					break
				}
				if parser.options[matched.index].kind != .switch_option {
					all_switches = false
					break
				}
				apply_match(parser.options[matched.index], matched, short_option, before_separator, index, mut values, mut sources)!
			}
			if all_switches {
				index++
				continue
			}
		}
		matched := parser.find_short_option(argument.all_before('=')) or {
			if ignore_invalid_options {
				remaining << argument
				index++
				continue
			}
			eprintln(parser.generate_help_text())
			return error('invalid option: ${argument.all_before('=')}')
		}
		spec := parser.options[matched.index]
		_, consumed_next := apply_match(spec, matched, argument, before_separator, index, mut values, mut sources)!
		index += if consumed_next { 2 } else { 1 }
	}
	mut named := []string{}
	if !ignore_invalid_options {
		named = remaining.clone()
		named << after_separator
		parser.apply_subcommand_alias(named, mut values, mut sources)
		parser.set_default_options()
		parser.validate_options()
		parser.check_constraint_violations(named, mut values, mut sources)!
		parser.check_named_args(named)!
		parser.check_subcommand_violations(named, values, sources)!
	}
	parsed_subcommand := parser.subcommand_name(named)
	mut named_without_api := parser.named_without_api
	if subcommand_name := parsed_subcommand {
		subcommand := parser.subcommand_for_name(subcommand_name) or { Subcommand{} }
		named_without_api = subcommand.named_without_api
		if subcommand.deprecated || subcommand.disabled {
			state := if subcommand.disabled { 'disabled' } else { 'deprecated' }
			return error('the `${subcommand.name}` subcommand is ${state}')
		}
		values['subcommand'] = ArgValue{
			kind: .flag_value
			text: subcommand.name
		}
		if named.len > 0 && parser.subcommand_for_name(named[0]) != none {
			named = named[1..].clone()
		}
	} else if parser.subcommands.len > 0 {
		named = []
	}
	mut final_remaining := remaining.clone()
	if after_separator.len > 0 {
		final_remaining << '--'
		final_remaining << after_separator
	}
	mut options_only := []string{}
	for spec in parser.options {
		value := values[option_to_name(spec.names[0])] or { continue }
		if !passed(values, spec.names[0]) {
			continue
		}
		rendered := rendered_option(spec, value)
		if rendered.len > 0 {
			options_only << rendered
		}
	}
	result := Args{
		options_only: options_only
		flags_only: options_only.filter(it.starts_with('--'))
		remaining: final_remaining
		named: new_named_args_with_config(named, NamedArgsConfig{
			cask_options: parser.cask_options_enabled
			without_api: named_without_api
		})
		values: values
	}
	parser.last_args = result
	parser.has_last_args = true
	parser.last_sources = sources.clone()
	return result
}

pub fn split_non_options(argv []string) SplitArguments {
	separator := argv.index('--')
	if separator >= 0 {
		return SplitArguments{
			options: argv[..separator].clone()
			non_options: argv[separator + 1..].clone()
		}
	}
	return SplitArguments{
		options: argv.clone()
	}
}

pub fn only_casks(argv []string) bool {
	return '--casks' in argv || '--cask' in argv
}

pub fn formula_names(argv []string) []string {
	split := split_non_options(argv)
	mut names := split.options.filter(!it.starts_with('-'))
	names << split.non_options
	mut unique := []string{}
	for name in names {
		if name.contains('/homebrew/cask/') || name.starts_with('homebrew/cask/') {
			continue
		}
		if name !in unique {
			unique << name
		}
	}
	return unique
}

pub fn resolved_formula_names(argv []string, available []string) []string {
	mut resolved := []string{}
	for candidate in formula_names(argv) {
		if candidate in available && candidate !in resolved {
			resolved << candidate
		}
	}
	return resolved
}

fn (mut parser Parser) install_formula_options(argv []string) {
	for formula_name in formula_names(argv) {
		for catalog_option in parser.formula_option_catalog {
			if catalog_option.formula_name != formula_name {
				continue
			}
			description := '`${formula_name}`: ${catalog_option.description}'
			if catalog_option.option.ends_with('=') {
				parser.add_flag([catalog_option.option], OptionConfig{
					description: description
				})
			} else {
				parser.add_switch([catalog_option.option], OptionConfig{
					description: description
				})
			}
			parser.add_conflicts(['--cask', catalog_option.option])
		}
	}
}

fn (parser Parser) command_option_allowed(argument string) bool {
	if 'command' !in parser.named_types {
		return false
	}
	return parser.allowed_commands[argument] or { false }
}

fn (mut parser Parser) apply_subcommand_alias(named []string, mut values map[string]ArgValue,
	mut sources map[string]OptionSource) {
	if named.len == 0 {
		return
	}
	subcommand := parser.subcommand_for_name(named[0]) or { return }
	implied_option := subcommand.alias_options[named[0]] or { return }
	for spec in parser.options {
		if spec.names.any(option_to_name(it) == option_to_name(implied_option)) {
			set_option_value(mut values, spec, ArgValue{
				kind: .switch_value
				enabled: true
			})
			set_option_source(mut sources, spec, .args)
			return
		}
	}
}

fn (parser Parser) option_allowed_for_subcommand(option string, subcommand_name string) bool {
	for spec in parser.options {
		if spec.names.any(option_to_name(it) == option_to_name(option)) {
			return spec.subcommands.len == 0 || subcommand_name in spec.subcommands
		}
	}
	return true
}

fn (parser Parser) check_subcommand_violations(named []string, values map[string]ArgValue,
	sources map[string]OptionSource) ! {
	if parser.subcommands.len == 0 {
		return
	}
	subcommand := if named.len == 0 {
		parser.default_subcommand() or { return }
	} else {
		parser.subcommand_for_name(named[0]) or {
			return error('unknown subcommand: `${named[0]}`')
		}
	}
	subcommand_args := if named.len == 0 { named } else { named[1..].clone() }
	check_named_args_count(subcommand_args, subcommand.named_types, subcommand.named_types_are_choices, subcommand.named_min, subcommand.named_max, subcommand.has_named_min, subcommand.has_named_max)!
	for option, source in sources {
		if source == .env || !passed(values, option) {
			continue
		}
		if !parser.option_allowed_for_subcommand(option, subcommand.name) {
			mut kind_name := 'switch'
			for spec in parser.options {
				if spec.names.any(option_to_name(it) == option) && spec.kind != .switch_option {
					kind_name = 'flag'
				}
			}
			return error('The `${subcommand.name}` subcommand does not accept the `${name_to_option(option)}` ${kind_name}.')
		}
	}
}

pub fn (mut parser Parser) set_default_options() {}

pub fn (mut parser Parser) validate_options() {}

fn option_usage_text(option OptionSpec) string {
	mut name := preferred_option(option.names)
	if option.kind in [.required_flag, .comma_array] {
		name += '='
	}
	return name
}

fn named_usage_text(types []string, choices bool, minimum int, maximum int, has_minimum bool,
	has_maximum bool) string {
	if types.len == 0 || types == ['none'] {
		return ''
	}
	mut argument_type := ''
	if choices {
		argument_type = 'subcommand'
	} else {
		mut rendered_types := []string{}
		for argument in types {
			rendered_types << match argument {
				'service' { 'service' }
				'text_or_regex' { 'text|/regex/' }
				'url' { 'URL' }
				else { argument }
			}
		}
		argument_type = rendered_types.join('|')
	}
	if !has_minimum && has_maximum && maximum == 1 {
		return ' [${argument_type}]'
	}
	if !has_minimum {
		return ' [${argument_type} ...]'
	}
	if minimum == 1 && has_maximum && maximum == 1 {
		return ' ${argument_type}'
	}
	if minimum == 1 {
		return ' ${argument_type} [...]'
	}
	return ' ${argument_type} ...'
}

pub fn (parser Parser) generate_usage_banner() string {
	if parser.root_usage_banner.len > 0 {
		return parser.root_usage_banner
	}
	non_global := parser.options.filter(!is_global_option(preferred_option(it.names)) && !it.hidden && it.subcommands.len == 0)
	mut options_text := ''
	if non_global.len > 2 {
		options_text = ' [options]'
	} else {
		for option in non_global {
			options_text += ' [${option_usage_text(option)}]'
		}
	}
	mut named_text := named_usage_text(parser.named_types, parser.named_types_are_choices, parser.named_min, parser.named_max, parser.has_named_min, parser.has_named_max)
	if parser.subcommands.len > 0 {
		named_text = ' [subcommand]'
	}
	mut command_names := ['`${parser.command_name}`']
	command_names << parser.command_aliases.map('`${it}`')
	return '${command_names.join(', ')}${options_text}${named_text}'
}

pub fn (parser Parser) usage_description_text() string {
	mut parts := []string{}
	if parser.description_text.len > 0 {
		parts << parser.description_text
	}
	for subcommand in parser.subcommands {
		if subcommand.usage_banner.len > 0 {
			parts << subcommand.usage_banner
		}
	}
	return parts.join('\n\n')
}

pub fn (parser Parser) usage_banner_text() string {
	mut parts := [parser.generate_usage_banner()]
	description := parser.usage_description_text()
	if description.len > 0 {
		parts << description
	}
	return parts.join('\n\n')
}

pub fn (parser Parser) root_usage_banner_text() string {
	return if parser.root_usage_banner.len > 0 {
		parser.root_usage_banner
	} else {
		parser.generate_usage_banner()
	}
}

fn strip_help_markup(text string) string {
	return text.replace('`', '').replace('<', '').replace('>', '')
}

fn (parser Parser) option_summary_lines(subcommand_name ?string) []string {
	mut lines := []string{}
	for option in parser.options {
		if option.hidden {
			continue
		}
		if name := subcommand_name {
			if option.subcommands.len > 0 && name !in option.subcommands {
				continue
			}
		} else if option.subcommands.len > 0 {
			continue
		}
		mut names := option.names.clone()
		if option.kind in [.required_flag, .comma_array] {
			names = names.map('${it}=')
		}
		lines << '  ${names.join(', ')}  ${option.description}'
	}
	return lines
}

pub fn (parser Parser) option_summaries_text(subcommand_name ?string) string {
	return parser.option_summary_lines(subcommand_name).join('\n')
}

pub fn (parser Parser) generate_help_text() string {
	return parser.generate_help_text_for([]string{}, false)
}

pub fn (parser Parser) generate_help_text_for(remaining []string, supplied bool) string {
	mut parts := []string{}
	if supplied && parser.subcommands.len > 0 {
		mut matched := ?Subcommand(none)
		for argument in remaining {
			if argument.starts_with('-') {
				continue
			}
			if command := parser.subcommand_for_name(argument) {
				matched = command
				break
			}
		}
		if command := matched {
			banner := if command.usage_banner.len > 0 {
				command.usage_banner
			} else {
				'`${parser.command_name} ${command.name}`'
			}
			parts << banner
			summaries := parser.option_summaries_text(command.name)
			if summaries.len > 0 {
				parts << summaries
			}
		} else {
			parts << parser.generate_usage_banner()
			if parser.description_text.len > 0 {
				parts << parser.description_text
			}
			mut subcommand_lines := []string{}
			for command in parser.subcommands {
				if command.hidden {
					continue
				}
				summary := if command.description.len > 0 { ': ${command.description}' } else { '' }
				subcommand_lines << '  `${command.name}`${summary}'
			}
			parts << 'Subcommands:\n${subcommand_lines.join('\n')}'
			summaries := parser.option_summaries_text(none)
			if summaries.len > 0 {
				parts << summaries
			}
		}
	} else {
		parts << parser.generate_usage_banner()
		description := parser.usage_description_text()
		if description.len > 0 {
			parts << description
		}
		if parser.subcommands.len > 0 {
			mut subcommand_lines := []string{}
			for command in parser.subcommands {
				if command.hidden {
					continue
				}
				summary := if command.description.len > 0 { ': ${command.description}' } else { '' }
				subcommand_lines << '  `${command.name}`${summary}'
			}
			parts << 'Subcommands:\n${subcommand_lines.join('\n')}'
		}
		summaries := parser.option_summaries_text(none)
		if summaries.len > 0 {
			parts << summaries
		}
	}
	return 'Usage: brew ${strip_help_markup(parts.join('\n\n'))}'
}

pub fn (parser Parser) parse_help(argv []string) string {
	remaining := argv.filter(it != '--help' && it != '-h')
	return parser.generate_help_text_for(remaining, parser.subcommands.len > 0)
}

pub fn option_to_description(names []string) string {
	mut longest := ''
	for name in names {
		description := name.trim_left('-').replace('-', ' ')
		if description.len > longest.len {
			longest = description
		}
	}
	return longest
}

fn (parser Parser) option_description(description string, names []string, hidden bool) string {
	if hidden {
		return '@@HIDDEN@@'
	}
	if description.len > 0 {
		return description
	}
	return option_to_description(names)
}

pub fn wrap_option_description(description string, width int) []string {
	if width <= 0 || description.len <= width {
		return [description]
	}
	mut lines := []string{}
	mut current := ''
	for word in description.split(' ') {
		if current.len > 0 && current.len + 1 + word.len > width {
			lines << current
			current = word
		} else {
			current = if current.len == 0 { word } else { '${current} ${word}' }
		}
	}
	if current.len > 0 {
		lines << current
	}
	return lines
}

pub fn global_options() []ProcessedOption {
	return [
		ProcessedOption{ short: '-d', long: '--debug', description: 'Display any debugging information.', type_name: 'switch_option' },
		ProcessedOption{ short: '-q', long: '--quiet', description: 'Make some output more quiet.', type_name: 'switch_option' },
		ProcessedOption{ short: '-v', long: '--verbose', description: 'Make some output more verbose.', type_name: 'switch_option' },
		ProcessedOption{ short: '-h', long: '--help', description: 'Show this message.', type_name: 'switch_option' },
	]
}

pub fn global_cask_options() []OptionSpec {
	ordered_names := [
		'appdir',
		'appimagedir',
		'keyboard-layoutdir',
		'colorpickerdir',
		'prefpanedir',
		'qlplugindir',
		'mdimporterdir',
		'dictionarydir',
		'fontdir',
		'servicedir',
		'input-methoddir',
		'internet-plugindir',
		'audio-unit-plugindir',
		'vst-plugindir',
		'vst3-plugindir',
		'screen-saverdir',
	]
	directories := {
		'appdir':               '/Applications'
		'appimagedir':          '~/Applications'
		'keyboard-layoutdir':   '/Library/Keyboard Layouts'
		'colorpickerdir':       '~/Library/ColorPickers'
		'prefpanedir':          '~/Library/PreferencePanes'
		'qlplugindir':          '~/Library/QuickLook'
		'mdimporterdir':        '~/Library/Spotlight'
		'dictionarydir':        '~/Library/Dictionaries'
		'fontdir':              '~/Library/Fonts'
		'servicedir':           '~/Library/Services'
		'input-methoddir':      '~/Library/Input Methods'
		'internet-plugindir':   '~/Library/Internet Plug-Ins'
		'audio-unit-plugindir': '~/Library/Audio/Plug-Ins/Components'
		'vst-plugindir':        '~/Library/Audio/Plug-Ins/VST'
		'vst3-plugindir':       '~/Library/Audio/Plug-Ins/VST3'
		'screen-saverdir':      '~/Library/Screen Savers'
	}
	labels := {
		'appdir':               'Applications'
		'appimagedir':          'AppImages'
		'keyboard-layoutdir':   'Keyboard Layouts'
		'colorpickerdir':       'Color Pickers'
		'prefpanedir':          'Preference Panes'
		'qlplugindir':          'Quick Look Plugins'
		'mdimporterdir':        'Spotlight Plugins'
		'dictionarydir':        'Dictionaries'
		'fontdir':              'Fonts'
		'servicedir':           'Services'
		'input-methoddir':      'Input Methods'
		'internet-plugindir':   'Internet Plugins'
		'audio-unit-plugindir': 'Audio Unit Plugins'
		'vst-plugindir':        'VST Plugins'
		'vst3-plugindir':       'VST3 Plugins'
		'screen-saverdir':      'Screen Savers'
	}
	mut options := []OptionSpec{}
	for name in ordered_names {
		default_directory := directories[name]
		options << OptionSpec{
			names: ['--${name}']
			description: 'Target location for ${labels[name]} (default: `${default_directory}`).'
			kind: .required_flag
		}
	}
	options << OptionSpec{
		names: ['--language']
		description: "Comma-separated list of language codes to prefer for cask installation. The first matching language is used, otherwise it reverts to the cask's default language. The default value is the language of your system."
		kind: .comma_array
	}
	return options
}

pub fn (mut parser Parser) add_cask_options() {
	for option in global_cask_options() {
		if option.kind == .comma_array {
			parser.add_comma_array(option.names[0], OptionConfig{
				description: option.description
			})
		} else {
			parser.add_flag(['${option.names[0]}='], OptionConfig{
				description: option.description
			})
		}
		parser.add_conflicts(['--formula', option.names[0]])
	}
	parser.cask_options_enabled = true
}

pub fn (parser Parser) args() ?Args {
	if parser.has_last_args {
		return parser.last_args
	}
	return none
}

pub fn value_for_env(env string, values map[string]string) ?string {
	if env.len == 0 {
		return none
	}
	return values['HOMEBREW_${env.to_upper()}'] or { return none }
}

pub fn parser_from_command_path(command_path string, parsers map[string]Parser) ?Parser {
	mut base := command_path.all_after_last('/')
	if base.contains('.') {
		base = base.all_before_last('.')
	}
	command_name := base.replace('-', '_').to_lower()
	return parsers['${command_name}_args'] or { return none }
}

pub fn (mut parser Parser) parse_remaining(argv []string, ignore_invalid_options bool) !SplitArguments {
	split := split_non_options(argv)
	mut trial := parser
	trial.parsed = false
	parsed := trial.parse(split.options, ignore_invalid_options)!
	parser.default_values = parsed.values.clone()
	parser.default_sources = trial.last_sources.clone()
	return SplitArguments{
		options: parsed.remaining.clone()
		non_options: split.non_options.clone()
	}
}

pub fn (mut parser Parser) parse_with_help_exit(argv []string, ignore_invalid_options bool) !Args {
	parsed := parser.parse(argv, ignore_invalid_options)!
	if !ignore_invalid_options && parsed.has('help') {
		println(parser.parse_help(argv))
		return error('SystemExit')
	}
	return parsed
}

fn (mut parser Parser) set_switch(names []string, value bool, source OptionSource) {
	for spec in parser.options {
		mut matches := false
		for existing_name in spec.names {
			for requested_name in names {
				if option_to_name(existing_name) == option_to_name(requested_name) {
					matches = true
				}
			}
		}
		if !matches {
			continue
		}
		set_option_value(mut parser.default_values, spec, ArgValue{
			kind: .switch_value
			enabled: value
		})
		set_option_source(mut parser.default_sources, spec, source)
	}
}

fn (mut parser Parser) disable_switch(names []string) {
	parser.disable_switch_values(names)
}

fn (parser Parser) option_passed(name string) bool {
	if parser.has_last_args {
		return passed(parser.last_args.values, name)
	}
	return passed(parser.default_values, name)
}

fn (parser Parser) option_allowed(option string, subcommand_name ?string) bool {
	if name := subcommand_name {
		return parser.option_allowed_for_subcommand(option, name)
	}
	return parser.subcommands_for_option(option).len == 0
}

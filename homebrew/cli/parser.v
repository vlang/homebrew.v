module cli

import os

// Translated from Homebrew/brew `cli/parser.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub fn (mut parser Parser) add_subcommand(name string, config SubcommandConfig, configure fn(mut Parser) !) ! {
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

// Ruby attr_reader `attr_reader :args` at line 48.
pub fn ruby_parser_l48_d1_args(parser Parser) ?Args {
	return parser.args()
}

// Ruby attr_reader `attr_reader :processed_options` at line 51.
pub fn ruby_parser_l51_d2_processed_options(parser Parser) []ProcessedOption {
	return parser.processed_options()
}

// Ruby attr_reader `attr_reader :hide_from_man_page` at line 54.
pub fn ruby_parser_l54_d3_hide_from_man_page(parser Parser) bool {
	return parser.is_hidden_from_man_page()
}

// Ruby attr_reader `attr_reader :subcommands` at line 57.
pub fn ruby_parser_l57_d4_subcommands(parser Parser) []Subcommand {
	return parser.subcommand_list()
}

// Ruby attr_reader `attr_reader :min_named_args` at line 60.
pub fn ruby_parser_l60_d5_min_named_args(parser Parser) ?int {
	return parser.minimum_named_args()
}

// Ruby method `self.from_cmd_path(cmd_path)` at line 63.
pub fn ruby_parser_l63_d6_self_from_cmd_path(command_path string, parsers map[string]Parser) ?Parser {
	return parser_from_command_path(command_path, parsers)
}

// Ruby method `self.global_cask_options` at line 85.
pub fn ruby_parser_l85_d7_self_global_cask_options() []OptionSpec {
	return global_cask_options()
}

// Ruby method `self.global_options` at line 160.
pub fn ruby_parser_l160_d8_self_global_options() []ProcessedOption {
	return global_options()
}

// Ruby method `self.option_to_name(option)` at line 170.
pub fn ruby_parser_l170_d9_self_option_to_name(option string) string {
	return option_to_name(option)
}

// Ruby method `initialize(cmd, &block)` at line 177.
pub fn ruby_parser_l177_d10_initialize(command_name string) Parser {
	return new_parser(command_name)
}

// Ruby method `switch(*names, description: nil, env: nil,` at line 230.
pub fn ruby_parser_l230_d11_switch(mut parser Parser, names []string, config OptionConfig) {
	parser.add_switch(names, config)
}

// Ruby alias `alias switch_option switch` at line 275.
pub fn ruby_parser_l275_d12_switch_option(mut parser Parser, names []string, config OptionConfig) {
	parser.add_switch(names, config)
}

// Ruby method `description(text = nil)` at line 278.
pub fn ruby_parser_l278_d13_description(mut parser Parser, text ?string) string {
	if value := text {
		if value.trim_space().len > 0 {
			parser.set_description(value)
		}
	}
	return parser.description()
}

// Ruby method `usage_banner(text)` at line 285.
pub fn ruby_parser_l285_d14_usage_banner(mut parser Parser, text string) ! {
	parser.set_usage_banner(text)!
}

// Ruby method `usage_banner_text = @parser.banner` at line 312.
pub fn ruby_parser_l312_d15_usage_banner_text(parser Parser) string {
	return parser.usage_banner_text()
}

// Ruby method `root_usage_banner_text = @usage_banner` at line 315.
pub fn ruby_parser_l315_d16_root_usage_banner_text(parser Parser) string {
	return parser.root_usage_banner_text()
}

// Ruby method `named_args_type` at line 318.
pub fn ruby_parser_l318_d17_named_args_type(parser Parser) []string {
	return parser.named_args_type()
}

// Ruby method `comma_array(name, description: nil, hidden: false, subcommands: nil)` at line 328.
pub fn ruby_parser_l328_d18_comma_array(mut parser Parser, name string, config OptionConfig) {
	parser.add_comma_array(name, config)
}

// Ruby method `flag(*names, description: nil, replacement: nil, depends_on: nil, hidden: false, odeprecated: false,` at line 345.
pub fn ruby_parser_l345_d19_flag(mut parser Parser, names []string, config OptionConfig) {
	parser.add_flag(names, config)
}

// Ruby method `set_args_method(name, value)` at line 377.
pub fn ruby_parser_l377_d20_set_args_method(mut values map[string]ArgValue, name string, value ArgValue) {
	values[name] = value
}

// Ruby define_singleton_method `@args.define_singleton_method(name) do` at line 381.
pub fn ruby_parser_l381_d21_name(values map[string]ArgValue, name string) ?ArgValue {
	return values[name] or { return none }
}

// Ruby method `conflicts(*options)` at line 388.
pub fn ruby_parser_l388_d22_conflicts(mut parser Parser, options []string) [][]string {
	if options.len > 0 {
		parser.add_conflicts(options)
	}
	return parser.conflict_groups.clone()
}

// Ruby method `option_to_name(option) = self.class.option_to_name(option)` at line 395.
pub fn ruby_parser_l395_d23_option_to_name(option string) string {
	return option_to_name(option)
}

// Ruby method `name_to_option(name)` at line 398.
pub fn ruby_parser_l398_d24_name_to_option(name string) string {
	return name_to_option(name)
}

// Ruby method `option_to_description(*names)` at line 407.
pub fn ruby_parser_l407_d25_option_to_description(names []string) string {
	return option_to_description(names)
}

// Ruby method `option_description(description, *names, hidden: false)` at line 412.
pub fn ruby_parser_l412_d26_option_description(parser Parser, description string, names []string,
	hidden bool) string {
	return parser.option_description(description, names, hidden)
}

// Ruby method `parse_remaining(argv, ignore_invalid_options: false)` at line 423.
pub fn ruby_parser_l423_d27_parse_remaining(mut parser Parser, argv []string,
	ignore_invalid_options bool) !SplitArguments {
	return parser.parse_remaining(argv, ignore_invalid_options)
}

// Ruby method `parse(argv = ARGV.freeze, ignore_invalid_options: false)` at line 459.
pub fn ruby_parser_l459_d28_parse(mut parser Parser, argv []string, ignore_invalid_options bool) !Args {
	return parser.parse_with_help_exit(argv, ignore_invalid_options)
}

// Ruby method `set_default_options; end` at line 547.
pub fn ruby_parser_l547_d29_set_default_options(mut parser Parser) {
	parser.set_default_options()
}

// Ruby method `validate_options; end` at line 550.
pub fn ruby_parser_l550_d30_validate_options(mut parser Parser) {
	parser.validate_options()
}

// Ruby method `generate_help_text(remaining_args: nil)` at line 553.
pub fn ruby_parser_l553_d31_generate_help_text(parser Parser, remaining []string,
	remaining_supplied bool) string {
	return parser.generate_help_text_for(remaining, remaining_supplied)
}

// Ruby method `cask_options` at line 602.
pub fn ruby_parser_l602_d32_cask_options(mut parser Parser) {
	parser.add_cask_options()
}

// Ruby method `formula_options` at line 612.
pub fn ruby_parser_l612_d33_formula_options(mut parser Parser) {
	parser.enable_formula_options()
}

// Ruby method `named_args(type = nil, number: nil, min: nil, max: nil, without_api: false)` at line 625.
pub fn ruby_parser_l625_d34_named_args(mut parser Parser, config NamedArgumentConfig) ! {
	parser.configure_named_args(config)!
}

// Ruby method `hide_from_man_page!` at line 666.
pub fn ruby_parser_l666_d35_hide_from_man_page(mut parser Parser) {
	parser.hide_from_man_page()
}

// Ruby method `subcommand(name, aliases: [], alias_options: {}, description: nil, default: false, hidden: false,` at line 684.
pub fn ruby_parser_l684_d36_subcommand(mut parser Parser, names []string,
	config SubcommandConfig) ! {
	parser.add_subcommand_names(names, config)!
}

// Ruby method `subcommand_names = @subcommands.map(&:name)` at line 708.
pub fn ruby_parser_l708_d37_subcommand_names(parser Parser) []string {
	return parser.subcommand_names()
}

// Ruby method `default_subcommand = @subcommands.find(&:default)` at line 711.
pub fn ruby_parser_l711_d38_default_subcommand(parser Parser) ?Subcommand {
	return parser.default_subcommand()
}

// Ruby method `subcommand_for_name(name)` at line 714.
pub fn ruby_parser_l714_d39_subcommand_for_name(parser Parser, name string) ?Subcommand {
	return parser.subcommand_for_name(name)
}

// Ruby method `processed_options_for_subcommand(subcommand_name)` at line 719.
pub fn ruby_parser_l719_d40_processed_options_for_subcommand(parser Parser, name string) []ProcessedOption {
	return parser.processed_options_for_subcommand(name)
}

// Ruby method `processed_options_for_root_command` at line 734.
pub fn ruby_parser_l734_d41_processed_options_for_root_command(parser Parser) []ProcessedOption {
	return parser.processed_options_for_root_command()
}

// Ruby method `named_args_type_for_subcommand(subcommand_name)` at line 739.
pub fn ruby_parser_l739_d42_named_args_type_for_subcommand(parser Parser, name string) []string {
	return parser.named_args_type_for_subcommand(name)
}

// Ruby method `subcommand_name(named_args)` at line 744.
pub fn ruby_parser_l744_d43_subcommand_name(parser Parser, named []string) ?string {
	return parser.subcommand_name(named)
}

// Ruby method `subcommands_for_option(option)` at line 755.
pub fn ruby_parser_l755_d44_subcommands_for_option(parser Parser, option string) []string {
	return parser.subcommands_for_option(option)
}

// Ruby method `generate_usage_banner` at line 762.
pub fn ruby_parser_l762_d45_generate_usage_banner(parser Parser) string {
	return parser.generate_usage_banner()
}

// Ruby method `generate_banner` at line 818.
pub fn ruby_parser_l818_d46_generate_banner(parser Parser) string {
	return parser.usage_banner_text()
}

// Ruby method `set_switch(*names, value:, from:)` at line 830.
pub fn ruby_parser_l830_d47_set_switch(mut parser Parser, names []string, value bool,
	from_environment bool) {
	parser.set_switch(names, value, if from_environment { .env } else { .args })
}

// Ruby method `disable_switch(*args)` at line 841.
pub fn ruby_parser_l841_d48_disable_switch(mut parser Parser, names []string) {
	parser.disable_switch(names)
}

// Ruby method `option_passed?(name)` at line 853.
pub fn ruby_parser_l853_d49_option_passed(parser Parser, name string) bool {
	return parser.option_passed(name)
}

// Ruby method `wrap_option_desc(desc)` at line 860.
pub fn ruby_parser_l860_d50_wrap_option_desc(description string, width int) []string {
	return wrap_option_description(description, width)
}

// Ruby method `set_constraints(name, depends_on:, subcommands:)` at line 868.
pub fn ruby_parser_l868_d51_set_constraints(mut parser Parser, name string, depends_on string,
	subcommands []string) {
	if depends_on.len > 0 {
		parser.constraints << ConstraintSpec{
			primary: option_to_name(depends_on)
			secondary: option_to_name(name)
			subcommands: parser.canonical_subcommands(subcommands)
		}
	}
}

// Ruby method `check_constraints(args)` at line 877.
pub fn ruby_parser_l877_d52_check_constraints(parser Parser, named []string,
	values map[string]ArgValue) ! {
	parser.check_constraints(named, values)!
}

// Ruby method `check_conflicts` at line 895.
pub fn ruby_parser_l895_d53_check_conflicts(parser Parser, mut values map[string]ArgValue,
	mut sources map[string]bool) ! {
	mut typed_sources := map[string]OptionSource{}
	for name, from_environment in sources {
		typed_sources[name] = if from_environment { .env } else { .args }
	}
	parser.check_conflicts(mut values, mut typed_sources)!
	for name, source in typed_sources {
		sources[name] = source == .env
	}
}

// Ruby method `check_invalid_constraints` at line 915.
pub fn ruby_parser_l915_d54_check_invalid_constraints(parser Parser) ! {
	parser.check_invalid_constraints()!
}

// Ruby method `check_constraint_violations(args)` at line 926.
pub fn ruby_parser_l926_d55_check_constraint_violations(parser Parser, named []string,
	mut values map[string]ArgValue, mut sources map[string]bool) ! {
	mut typed_sources := map[string]OptionSource{}
	for name, from_environment in sources {
		typed_sources[name] = if from_environment { .env } else { .args }
	}
	parser.check_constraint_violations(named, mut values, mut typed_sources)!
	for name, source in typed_sources {
		sources[name] = source == .env
	}
}

// Ruby method `check_named_args_count(args, type, min, max)` at line 933.
pub fn ruby_parser_l933_d56_check_named_args_count(named []string, types []string, choices bool,
	minimum int, maximum int, has_minimum bool, has_maximum bool) ! {
	check_named_args_count(named, types, choices, minimum, maximum, has_minimum, has_maximum)!
}

// Ruby method `check_named_args(args)` at line 952.
pub fn ruby_parser_l952_d57_check_named_args(parser Parser, named []string) ! {
	parser.check_named_args(named)!
}

// Ruby method `check_subcommand_violations(args)` at line 957.
pub fn ruby_parser_l957_d58_check_subcommand_violations(parser Parser, named []string,
	values map[string]ArgValue, sources map[string]bool) ! {
	mut typed_sources := map[string]OptionSource{}
	for name, from_environment in sources {
		typed_sources[name] = if from_environment { .env } else { .args }
	}
	parser.check_subcommand_violations(named, values, typed_sources)!
}

// Ruby method `usage_description_text` at line 991.
pub fn ruby_parser_l991_d59_usage_description_text(parser Parser) string {
	return parser.usage_description_text()
}

// Ruby method `option_summaries_text(subcommand_name)` at line 1002.
pub fn ruby_parser_l1002_d60_option_summaries_text(parser Parser, subcommand ?string) string {
	return parser.option_summaries_text(subcommand)
}

// Ruby method `option_allowed_for_subcommand?(option, subcommand_name)` at line 1023.
pub fn ruby_parser_l1023_d61_option_allowed_for_subcommand(parser Parser, option string,
	subcommand ?string) bool {
	return parser.option_allowed(option, subcommand)
}

// Ruby method `effective_subcommands(subcommands)` at line 1031.
pub fn ruby_parser_l1031_d62_effective_subcommands(parser Parser, subcommands ?[]string) []string {
	if names := subcommands {
		return parser.canonical_subcommands(names)
	}
	return parser.current_subcommands.clone()
}

// Ruby method `record_option_metadata(option_names, type:, subcommands:)` at line 1043.
pub fn ruby_parser_l1043_d63_record_option_metadata(mut parser Parser, names []string,
	kind OptionKind, subcommands []string) {
	parser.record_option_metadata(names, kind, subcommands)
}

// Ruby method `global_option?(name)` at line 1060.
pub fn ruby_parser_l1060_d64_global_option(name string) bool {
	return is_global_option(name)
}

// Ruby method `process_option(*args, type:, hidden: false, subcommands: nil)` at line 1071.
pub fn ruby_parser_l1071_d65_process_option(mut parser Parser, names []string, kind OptionKind,
	config OptionConfig) {
	parser.add_option(names, kind, config)
}

// Ruby method `split_non_options(argv)` at line 1119.
pub fn ruby_parser_l1119_d66_split_non_options(argv []string) SplitArguments {
	return split_non_options(argv)
}

// Ruby method `formulae(argv)` at line 1128.
pub fn ruby_parser_l1128_d67_formulae(argv []string, available []string) []string {
	return resolved_formula_names(argv, available)
}

// Ruby method `only_casks?(argv)` at line 1151.
pub fn ruby_parser_l1151_d68_only_casks(argv []string) bool {
	return only_casks(argv)
}

// Ruby method `value_for_env(env)` at line 1156.
pub fn ruby_parser_l1156_d69_value_for_env(env string, values map[string]string) ?string {
	return value_for_env(env, values)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "env_config"
// 6: require "cask/config"
// 7: require "cli/args"
// 8: require "cli/error"
// 9: require "commands"
// 10: require "extend/ENV/sensitive"
// 11: require "optparse"
// 12: require "utils/tty"
// 13: require "utils/formatter"
// 14: require "utils/output"
// 15:
// 16: module Homebrew
// 17:   module CLI
// 18:     class Parser
// 19:       include Utils::Output::Mixin
// 20:
// 21:       ArgType = T.type_alias { T.nilable(T.any(Symbol, T::Array[String], T::Array[Symbol])) }
// 22:       HIDDEN_DESC_PLACEHOLDER = "@@HIDDEN@@"
// 23:       SYMBOL_TO_USAGE_MAPPING = T.let({
// 24:         service:       "<service>",
// 25:         text_or_regex: "<text>|`/`<regex>`/`",
// 26:         url:           "<URL>",
// 27:       }.freeze, T::Hash[Symbol, String])
// 28:       private_constant :ArgType, :HIDDEN_DESC_PLACEHOLDER, :SYMBOL_TO_USAGE_MAPPING
// 29:
// 30:       class Subcommand < T::Struct
// 31:         const :name, String
// 32:         const :aliases, T::Array[String], default: []
// 33:         const :alias_options, T::Hash[String, String], default: {}
// 34:         prop :description, T.nilable(String), default: nil
// 35:         prop :usage_banner, T.nilable(String), default: nil
// 36:         const :default, T::Boolean, default: false
// 37:         prop :named_args_type, ArgType, default: nil
// 38:         prop :max_named_args, T.nilable(Integer), default: nil
// 39:         prop :min_named_args, T.nilable(Integer), default: nil
// 40:         prop :named_args_without_api, T::Boolean, default: false
// 41:         const :hidden, T::Boolean, default: false
// 42:         const :replacement, T.nilable(T.any(String, Symbol)), default: nil
// 43:         const :odeprecated, T::Boolean, default: false
// 44:         const :odisabled, T::Boolean, default: false
// 45:       end
// 46:
// 47:       sig { returns(Args) }
// 48:       attr_reader :args
// 49:
// 50:       sig { returns(Args::OptionsType) }
// 51:       attr_reader :processed_options
// 52:
// 53:       sig { returns(T::Boolean) }
// 54:       attr_reader :hide_from_man_page
// 55:
// 56:       sig { returns(T::Array[Subcommand]) }
// 57:       attr_reader :subcommands
// 58:
// 59:       sig { returns(T.nilable(Integer)) }
// 60:       attr_reader :min_named_args
// 61:
// 62:       sig { params(cmd_path: Pathname).returns(T.nilable(CLI::Parser)) }
// 63:       def self.from_cmd_path(cmd_path)
// 64:         cmd_args_method_name = Commands.args_method_name(cmd_path)
// 65:         cmd_name = cmd_args_method_name.to_s.delete_suffix("_args").tr("_", "-")
// 66:
// 67:         begin
// 68:           if ENV.clear_sensitive_environment! { Homebrew.require?(cmd_path) }
// 69:             cmd = Homebrew::AbstractCommand.command(cmd_name)
// 70:             if cmd
// 71:               cmd.parser
// 72:             else
// 73:               # FIXME: remove once commands are all subclasses of `AbstractCommand`:
// 74:               Homebrew.send(cmd_args_method_name)
// 75:             end
// 76:           end
// 77:         rescue NoMethodError => e
// 78:           raise if e.name.to_sym != cmd_args_method_name
// 79:
// 80:           nil
// 81:         end
// 82:       end
// 83:
// 84:       sig { returns(T::Array[[Symbol, String, { description: String }]]) }
// 85:       def self.global_cask_options
// 86:         [
// 87:           [:flag, "--appdir=", {
// 88:             description: "Target location for Applications " \
// 89:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:appdir]}`).",
// 90:           }],
// 91:           [:flag, "--appimagedir=", {
// 92:             description: "Target location for AppImages " \
// 93:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:appimagedir]}`).",
// 94:           }],
// 95:           [:flag, "--keyboard-layoutdir=", {
// 96:             description: "Target location for Keyboard Layouts " \
// 97:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:keyboard_layoutdir]}`).",
// 98:           }],
// 99:           [:flag, "--colorpickerdir=", {
// 100:             description: "Target location for Color Pickers " \
// 101:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:colorpickerdir]}`).",
// 102:           }],
// 103:           [:flag, "--prefpanedir=", {
// 104:             description: "Target location for Preference Panes " \
// 105:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:prefpanedir]}`).",
// 106:           }],
// 107:           [:flag, "--qlplugindir=", {
// 108:             description: "Target location for Quick Look Plugins " \
// 109:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:qlplugindir]}`).",
// 110:           }],
// 111:           [:flag, "--mdimporterdir=", {
// 112:             description: "Target location for Spotlight Plugins " \
// 113:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:mdimporterdir]}`).",
// 114:           }],
// 115:           [:flag, "--dictionarydir=", {
// 116:             description: "Target location for Dictionaries " \
// 117:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:dictionarydir]}`).",
// 118:           }],
// 119:           [:flag, "--fontdir=", {
// 120:             description: "Target location for Fonts " \
// 121:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:fontdir]}`).",
// 122:           }],
// 123:           [:flag, "--servicedir=", {
// 124:             description: "Target location for Services " \
// 125:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:servicedir]}`).",
// 126:           }],
// 127:           [:flag, "--input-methoddir=", {
// 128:             description: "Target location for Input Methods " \
// 129:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:input_methoddir]}`).",
// 130:           }],
// 131:           [:flag, "--internet-plugindir=", {
// 132:             description: "Target location for Internet Plugins " \
// 133:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:internet_plugindir]}`).",
// 134:           }],
// 135:           [:flag, "--audio-unit-plugindir=", {
// 136:             description: "Target location for Audio Unit Plugins " \
// 137:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:audio_unit_plugindir]}`).",
// 138:           }],
// 139:           [:flag, "--vst-plugindir=", {
// 140:             description: "Target location for VST Plugins " \
// 141:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:vst_plugindir]}`).",
// 142:           }],
// 143:           [:flag, "--vst3-plugindir=", {
// 144:             description: "Target location for VST3 Plugins " \
// 145:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:vst3_plugindir]}`).",
// 146:           }],
// 147:           [:flag, "--screen-saverdir=", {
// 148:             description: "Target location for Screen Savers " \
// 149:                          "(default: `#{Cask::Config::DEFAULT_DIRS[:screen_saverdir]}`).",
// 150:           }],
// 151:           [:comma_array, "--language", {
// 152:             description: "Comma-separated list of language codes to prefer for cask installation. " \
// 153:                          "The first matching language is used, otherwise it reverts to the cask's " \
// 154:                          "default language. The default value is the language of your system.",
// 155:           }],
// 156:         ]
// 157:       end
// 158:
// 159:       sig { returns(T::Array[[String, String, String]]) }
// 160:       def self.global_options
// 161:         [
// 162:           ["-d", "--debug",   "Display any debugging information."],
// 163:           ["-q", "--quiet",   "Make some output more quiet."],
// 164:           ["-v", "--verbose", "Make some output more verbose."],
// 165:           ["-h", "--help",    "Show this message."],
// 166:         ]
// 167:       end
// 168:
// 169:       sig { params(option: String).returns(String) }
// 170:       def self.option_to_name(option)
// 171:         option.sub(/\A--?(\[no-\])?/, "").tr("-", "_").delete("=")
// 172:       end
// 173:
// 174:       sig {
// 175:         params(cmd: T.class_of(Homebrew::AbstractCommand), block: T.nilable(T.proc.bind(Parser).void)).void
// 176:       }
// 177:       def initialize(cmd, &block)
// 178:         @parser = T.let(OptionParser.new, OptionParser)
// 179:         @parser.summary_indent = "  "
// 180:         # Disable default handling of `--version` switch.
// 181:         @parser.base.long.delete("version")
// 182:         # Disable default handling of `--help` switch.
// 183:         @parser.base.long.delete("help")
// 184:
// 185:         @args = T.let((cmd.args_class || Args).new, Args)
// 186:
// 187:         @command_name = T.let(cmd.command_name, String)
// 188:         @is_dev_cmd = T.let(cmd.dev_cmd?, T::Boolean)
// 189:
// 190:         @constraints = T.let([], T::Array[[String, String, T.nilable(T::Array[String])]])
// 191:         @conflicts = T.let([], T::Array[T::Array[String]])
// 192:         @switch_sources = T.let({}, T::Hash[String, Symbol])
// 193:         @option_sources = T.let({}, T::Hash[String, Symbol])
// 194:         @option_subcommands = T.let({}, T::Hash[String, T::Array[String]])
// 195:         @option_types = T.let({}, T::Hash[String, Symbol])
// 196:         @processed_options = T.let([], Args::OptionsType)
// 197:         @processed_option_summaries = T.let([], T::Array[[T.untyped, T::Boolean]])
// 198:         @processed_options_by_subcommand = T.let({}, T::Hash[T.nilable(String), Args::OptionsType])
// 199:         @processed_option_summaries_by_subcommand =
// 200:           T.let({}, T::Hash[T.nilable(String), T::Array[[T.untyped, T::Boolean]]])
// 201:         @non_global_processed_options = T.let([], T::Array[[String, ArgType]])
// 202:         @named_args_type = T.let(nil, T.nilable(ArgType))
// 203:         @max_named_args = T.let(nil, T.nilable(Integer))
// 204:         @min_named_args = T.let(nil, T.nilable(Integer))
// 205:         @named_args_without_api = T.let(false, T::Boolean)
// 206:         @description = T.let(nil, T.nilable(String))
// 207:         @usage_banner = T.let(nil, T.nilable(String))
// 208:         @hide_from_man_page = T.let(false, T::Boolean)
// 209:         @formula_options = T.let(false, T::Boolean)
// 210:         @cask_options = T.let(false, T::Boolean)
// 211:         @subcommands = T.let([], T::Array[Subcommand])
// 212:         @current_subcommands = T.let(nil, T.nilable(T::Array[String]))
// 213:
// 214:         self.class.global_options.each do |short, long, desc|
// 215:           switch short, long, description: desc, env: option_to_name(long), method: :on_tail
// 216:         end
// 217:
// 218:         instance_eval(&block) if block
// 219:
// 220:         generate_banner
// 221:       end
// 222:
// 223:       sig {
// 224:         params(names: String, description: T.nilable(String), env: T.untyped,
// 225:                depends_on: T.nilable(String), method: Symbol,
// 226:                hidden: T::Boolean, replacement: T.nilable(T.any(String, FalseClass)),
// 227:                odeprecated: T::Boolean, odisabled: T::Boolean,
// 228:                subcommands: T.nilable(T.any(String, T::Array[String]))).void
// 229:       }
// 230:       def switch(*names, description: nil, env: nil,
// 231:                  depends_on: nil, method: :on,
// 232:                  hidden: false, replacement: nil,
// 233:                  odeprecated: false, odisabled: false,
// 234:                  subcommands: nil)
// 235:         global_switch = names.first.is_a?(Symbol)
// 236:         return if global_switch
// 237:
// 238:         hidden = true if odisabled || odeprecated
// 239:
// 240:         description = option_description(description, *names, hidden:)
// 241:         env, counterpart = env
// 242:         if env
// 243:           env_hidden = Homebrew::EnvConfig.hidden?(Homebrew::EnvConfig::ENVS.fetch(:"HOMEBREW_#{env.upcase}",
// 244:                                                                                    {}))
// 245:         end
// 246:         if env && @non_global_processed_options.any? && !hidden && !env_hidden
// 247:           affix = if counterpart
// 248:             " and `#{counterpart}` is passed."
// 249:           else
// 250:             "."
// 251:           end
// 252:           description += " Enabled by default if `$HOMEBREW_#{env.upcase}` is set#{affix}"
// 253:         end
// 254:         process_option(*names, description, type: :switch, hidden:, subcommands:) unless odisabled
// 255:
// 256:         @parser.public_send(method, *names, *wrap_option_desc(description)) do |value|
// 257:           # This odeprecated should stick around indefinitely.
// 258:           replacement_string = replacement if replacement
// 259:           if odeprecated || odisabled
// 260:             odeprecated "the `#{names.first}` switch", replacement_string, disable: odisabled
// 261:           end
// 262:           value = true if names.none? { |name| name.start_with?("--[no-]") }
// 263:
// 264:           set_switch(*names, value:, from: :args)
// 265:         end
// 266:
// 267:         names.each do |name|
// 268:           set_constraints(name, depends_on:, subcommands:)
// 269:         end
// 270:
// 271:         env_value = value_for_env(env)
// 272:         value = env_value&.present?
// 273:         set_switch(*names, value:, from: :env) unless value.nil?
// 274:       end
// 275:       alias switch_option switch
// 276:
// 277:       sig { params(text: T.nilable(String)).returns(T.nilable(String)) }
// 278:       def description(text = nil)
// 279:         return @description if text.blank?
// 280:
// 281:         @description = text.chomp
// 282:       end
// 283:
// 284:       sig { params(text: String).void }
// 285:       def usage_banner(text)
// 286:         banner, description = text.chomp.split("\n\n", 2)
// 287:
// 288:         if @current_subcommands.present?
// 289:           subcommand_description = description
// 290:           if subcommand_description.blank?
// 291:             usage_banner_lines = text.chomp.lines
// 292:             subcommand_description = usage_banner_lines.drop(1).join if usage_banner_lines.size > 1
// 293:           end
// 294:
// 295:           @current_subcommands.each do |subcommand_name|
// 296:             subcommand = subcommand_for_name(subcommand_name)
// 297:             raise ArgumentError, "unknown subcommand: #{subcommand_name}" if subcommand.nil?
// 298:
// 299:             subcommand.usage_banner = text.chomp
// 300:             next if subcommand.description.present? || subcommand_description.blank?
// 301:
// 302:             subcommand.description = subcommand_description.lines.first&.chomp
// 303:           end
// 304:           return
// 305:         end
// 306:
// 307:         @usage_banner = banner
// 308:         @description = description
// 309:       end
// 310:
// 311:       sig { returns(T.nilable(String)) }
// 312:       def usage_banner_text = @parser.banner
// 313:
// 314:       sig { returns(T.nilable(String)) }
// 315:       def root_usage_banner_text = @usage_banner
// 316:
// 317:       sig { returns(ArgType) }
// 318:       def named_args_type
// 319:         return @named_args_type if @subcommands.empty?
// 320:
// 321:         subcommand_names
// 322:       end
// 323:
// 324:       sig {
// 325:         params(name: String, description: T.nilable(String), hidden: T::Boolean,
// 326:                subcommands: T.nilable(T.any(String, T::Array[String]))).void
// 327:       }
// 328:       def comma_array(name, description: nil, hidden: false, subcommands: nil)
// 329:         name = name.chomp "="
// 330:         description = option_description(description, name, hidden:)
// 331:         process_option(name, description, type: :comma_array, hidden:, subcommands:)
// 332:         @parser.on(name, OptionParser::REQUIRED_ARGUMENT, Array, *wrap_option_desc(description)) do |list|
// 333:           option_name = option_to_name(name)
// 334:           @option_sources[option_name] = :args
// 335:           @option_types[option_name] ||= :comma_array
// 336:           set_args_method(option_name.to_sym, list)
// 337:         end
// 338:       end
// 339:
// 340:       sig {
// 341:         params(names: String, description: T.nilable(String), replacement: T.nilable(T.any(Symbol, String)),
// 342:                depends_on: T.nilable(String), hidden: T::Boolean, odeprecated: T::Boolean, odisabled: T::Boolean,
// 343:                subcommands: T.nilable(T.any(String, T::Array[String]))).void
// 344:       }
// 345:       def flag(*names, description: nil, replacement: nil, depends_on: nil, hidden: false, odeprecated: false,
// 346:                odisabled: false, subcommands: nil)
// 347:         required, flag_type = if names.any? { |name| name.end_with? "=" }
// 348:           [OptionParser::REQUIRED_ARGUMENT, :required_flag]
// 349:         else
// 350:           [OptionParser::OPTIONAL_ARGUMENT, :optional_flag]
// 351:         end
// 352:         names.map! { |name| name.chomp "=" }
// 353:         hidden = true if odeprecated || odisabled
// 354:         description = option_description(description, *names, hidden:)
// 355:         if odisabled
// 356:           description += " (disabled#{"; replaced by #{replacement}" if replacement.present?})"
// 357:         else
// 358:           process_option(*names, description, type: flag_type, hidden:, subcommands:)
// 359:         end
// 360:         @parser.on(*names, *wrap_option_desc(description), required) do |option_value|
// 361:           # This odisabled should stick around indefinitely.
// 362:           odeprecated "the `#{names.first}` flag", replacement, disable: odisabled if odeprecated || odisabled
// 363:           names.each do |name|
// 364:             option_name = option_to_name(name)
// 365:             @option_sources[option_name] = :args
// 366:             @option_types[option_name] ||= flag_type
// 367:             set_args_method(option_name.to_sym, option_value)
// 368:           end
// 369:         end
// 370:
// 371:         names.each do |name|
// 372:           set_constraints(name, depends_on:, subcommands:)
// 373:         end
// 374:       end
// 375:
// 376:       sig { params(name: Symbol, value: T.untyped).void }
// 377:       def set_args_method(name, value)
// 378:         @args.set_arg(name, value)
// 379:         return if @args.respond_to?(name)
// 380:
// 381:         @args.define_singleton_method(name) do
// 382:           # We cannot reference the ivar directly due to https://github.com/sorbet/sorbet/issues/8106
// 383:           instance_variable_get(:@table).fetch(name)
// 384:         end
// 385:       end
// 386:
// 387:       sig { params(options: String).returns(T::Array[T::Array[String]]) }
// 388:       def conflicts(*options)
// 389:         return @conflicts if options.empty?
// 390:
// 391:         @conflicts << options.map { |option| option_to_name(option) }
// 392:       end
// 393:
// 394:       sig { params(option: String).returns(String) }
// 395:       def option_to_name(option) = self.class.option_to_name(option)
// 396:
// 397:       sig { params(name: String).returns(String) }
// 398:       def name_to_option(name)
// 399:         if name.length == 1
// 400:           "-#{name}"
// 401:         else
// 402:           "--#{name.tr("_", "-")}"
// 403:         end
// 404:       end
// 405:
// 406:       sig { params(names: String).returns(T.nilable(String)) }
// 407:       def option_to_description(*names)
// 408:         names.map { |name| name.to_s.sub(/\A--?/, "").tr("-", " ") }.max
// 409:       end
// 410:
// 411:       sig { params(description: T.nilable(String), names: String, hidden: T::Boolean).returns(String) }
// 412:       def option_description(description, *names, hidden: false)
// 413:         return HIDDEN_DESC_PLACEHOLDER if hidden
// 414:         return description if description.present?
// 415:
// 416:         option_to_description(*names)
// 417:       end
// 418:
// 419:       sig {
// 420:         params(argv: T::Array[String], ignore_invalid_options: T::Boolean)
// 421:           .returns([T::Array[String], T::Array[String]])
// 422:       }
// 423:       def parse_remaining(argv, ignore_invalid_options: false)
// 424:         i = 0
// 425:         remaining = []
// 426:
// 427:         argv, non_options = split_non_options(argv)
// 428:         allow_commands = Array(@named_args_type).include?(:command)
// 429:
// 430:         while i < argv.count
// 431:           begin
// 432:             begin
// 433:               arg = argv[i]
// 434:
// 435:               remaining << arg unless @parser.parse([arg]).empty?
// 436:             rescue OptionParser::MissingArgument
// 437:               raise if i + 1 >= argv.count
// 438:
// 439:               args = argv[i..(i + 1)]
// 440:               @parser.parse(args)
// 441:               i += 1
// 442:             end
// 443:           rescue OptionParser::InvalidOption
// 444:             if ignore_invalid_options || (allow_commands && arg && Commands.path(arg))
// 445:               remaining << arg
// 446:             else
// 447:               $stderr.puts generate_help_text
// 448:               raise
// 449:             end
// 450:           end
// 451:
// 452:           i += 1
// 453:         end
// 454:
// 455:         [remaining, non_options]
// 456:       end
// 457:
// 458:       sig { params(argv: T::Array[String], ignore_invalid_options: T::Boolean).returns(Args) }
// 459:       def parse(argv = ARGV.freeze, ignore_invalid_options: false)
// 460:         raise "Arguments were already parsed!" if @args_parsed
// 461:
// 462:         # If we accept formula options, but the command isn't scoped only
// 463:         # to casks, parse once allowing invalid options so we can get the
// 464:         # remaining list containing formula names.
// 465:         if @formula_options && !only_casks?(argv)
// 466:           remaining, non_options = parse_remaining(argv, ignore_invalid_options: true)
// 467:
// 468:           argv = [*remaining, "--", *non_options]
// 469:
// 470:           formulae(argv).each do |f|
// 471:             next if f.options.empty?
// 472:
// 473:             f.options.each do |o|
// 474:               name = o.flag
// 475:               description = "`#{f.name}`: #{o.description}"
// 476:               if name.end_with? "="
// 477:                 flag(name, description:)
// 478:               else
// 479:                 switch name, description:
// 480:               end
// 481:
// 482:               conflicts "--cask", name
// 483:             end
// 484:           end
// 485:         end
// 486:
// 487:         remaining, non_options = parse_remaining(argv, ignore_invalid_options:)
// 488:
// 489:         named_args = if ignore_invalid_options
// 490:           []
// 491:         else
// 492:           remaining + non_options
// 493:         end
// 494:
// 495:         unless ignore_invalid_options
// 496:           if @subcommands.present? && named_args.present?
// 497:             subcommand_arg = named_args.fetch(0)
// 498:             if (subcommand = subcommand_for_name(subcommand_arg)) && subcommand.alias_options.key?(subcommand_arg)
// 499:               set_switch(subcommand.alias_options.fetch(subcommand_arg), value: true, from: :args)
// 500:             end
// 501:           end
// 502:           unless @is_dev_cmd
// 503:             set_default_options
// 504:             validate_options
// 505:           end
// 506:           check_constraint_violations(named_args)
// 507:           check_named_args(named_args)
// 508:           check_subcommand_violations(named_args)
// 509:         end
// 510:
// 511:         if @subcommands.present?
// 512:           parsed_subcommand = subcommand_name(named_args)
// 513:           # This odeprecated should stick around indefinitely.
// 514:           if parsed_subcommand && (subcommand = subcommand_for_name(parsed_subcommand)) &&
// 515:              (subcommand.odeprecated || subcommand.odisabled)
// 516:             odeprecated "the `#{subcommand.name}` subcommand", subcommand.replacement,
// 517:                         disable: subcommand.odisabled
// 518:           end
// 519:           set_args_method(:subcommand, parsed_subcommand)
// 520:           named_args = if parsed_subcommand && named_args.present?
// 521:             named_args.drop(1)
// 522:           else
// 523:             []
// 524:           end
// 525:         end
// 526:         @args.freeze_named_args!(named_args, cask_options: @cask_options, without_api: @named_args_without_api)
// 527:         remaining_args = if non_options.empty?
// 528:           remaining
// 529:         else
// 530:           [*remaining, "--", *non_options]
// 531:         end
// 532:         @args.freeze_remaining_args!(remaining_args)
// 533:         @args.freeze_processed_options!(@processed_options)
// 534:         @args.freeze
// 535:
// 536:         @args_parsed = T.let(true, T.nilable(TrueClass))
// 537:
// 538:         if !ignore_invalid_options && @args.help?
// 539:           puts generate_help_text(remaining_args: @subcommands.present? ? remaining : nil)
// 540:           exit
// 541:         end
// 542:
// 543:         @args
// 544:       end
// 545:
// 546:       sig { void }
// 547:       def set_default_options; end
// 548:
// 549:       sig { void }
// 550:       def validate_options; end
// 551:
// 552:       sig { params(remaining_args: T.nilable(T::Array[String])).returns(String) }
// 553:       def generate_help_text(remaining_args: nil)
// 554:         help_text = if remaining_args.nil? || @subcommands.empty?
// 555:           @parser.to_s
// 556:         elsif (subcommand = remaining_args.filter_map do |arg|
// 557:           subcommand_for_name(arg) unless arg.start_with?("-")
// 558:         end.first)
// 559:           parts = T.let([], T::Array[String])
// 560:           parts << (subcommand.usage_banner || "`#{@command_name} #{subcommand.name}`").sub(/\A`brew /, "`")
// 561:           option_summaries = option_summaries_text(subcommand.name)
// 562:           parts << option_summaries if option_summaries.present?
// 563:           parts.join("\n\n")
// 564:         else
// 565:           parts = T.let([], T::Array[String])
// 566:           usage_banner = @usage_banner
// 567:           description = @description
// 568:           parts << usage_banner if usage_banner.present?
// 569:           parts << description if description.present?
// 570:
// 571:           subcommand_lines = @subcommands.filter_map do |subcommand|
// 572:             next if subcommand.hidden
// 573:
// 574:             subcommand_summary = if (usage_banner = subcommand.usage_banner)
// 575:               usage_banner.lines.drop(1).map(&:strip).find(&:present?)
// 576:             end
// 577:             subcommand_summary ||= subcommand.description
// 578:             if subcommand_summary.present?
// 579:               "  `#{subcommand.name}`: #{subcommand_summary}"
// 580:             else
// 581:               "  `#{subcommand.name}`"
// 582:             end
// 583:           end
// 584:           parts << "Subcommands:\n#{subcommand_lines.join("\n")}"
// 585:
// 586:           option_summaries = option_summaries_text(nil)
// 587:           parts << option_summaries if option_summaries.present?
// 588:           parts.join("\n\n")
// 589:         end
// 590:
// 591:         Formatter.format_help_text(help_text, width: Formatter::COMMAND_DESC_WIDTH)
// 592:                  .gsub(/\n.*?@@HIDDEN@@.*?(?=\n)/, "")
// 593:                  .sub(/^/, "#{Tty.bold}Usage: brew#{Tty.reset} ")
// 594:                  .gsub(/`(.*?)`/m, "#{Tty.bold}\\1#{Tty.reset}")
// 595:                  .gsub(%r{<([^\s]+?://[^\s]+?)>}) { |url| Formatter.url(url) }
// 596:                  .gsub(/\*(.*?)\*|<(.*?)>/m) do |underlined|
// 597:                    underlined[1...-1].to_s.gsub(/^(\s*)(.*?)$/, "\\1#{Tty.underline}\\2#{Tty.reset}")
// 598:                  end
// 599:       end
// 600:
// 601:       sig { void }
// 602:       def cask_options
// 603:         self.class.global_cask_options.each do |args|
// 604:           options = T.cast(args.pop, T::Hash[Symbol, String])
// 605:           send(*args, **options)
// 606:           conflicts "--formula", args[1]
// 607:         end
// 608:         @cask_options = true
// 609:       end
// 610:
// 611:       sig { void }
// 612:       def formula_options
// 613:         @formula_options = true
// 614:       end
// 615:
// 616:       sig {
// 617:         params(
// 618:           type:        ArgType,
// 619:           number:      T.nilable(Integer),
// 620:           min:         T.nilable(Integer),
// 621:           max:         T.nilable(Integer),
// 622:           without_api: T::Boolean,
// 623:         ).void
// 624:       }
// 625:       def named_args(type = nil, number: nil, min: nil, max: nil, without_api: false)
// 626:         raise ArgumentError, "Do not specify both `number` and `min` or `max`" if number && (min || max)
// 627:
// 628:         if type == :none && (number || min || max)
// 629:           raise ArgumentError, "Do not specify both `number`, `min` or `max` with `named_args :none`"
// 630:         end
// 631:
// 632:         if @current_subcommands.present?
// 633:           @current_subcommands.each do |subcommand_name|
// 634:             subcommand = subcommand_for_name(subcommand_name)
// 635:             raise ArgumentError, "unknown subcommand: #{subcommand_name}" if subcommand.nil?
// 636:
// 637:             subcommand.named_args_type = type
// 638:             if type == :none
// 639:               subcommand.max_named_args = 0
// 640:             elsif number
// 641:               subcommand.min_named_args = subcommand.max_named_args = number
// 642:             elsif min || max
// 643:               subcommand.min_named_args = min
// 644:               subcommand.max_named_args = max
// 645:             end
// 646:             subcommand.named_args_without_api = without_api
// 647:           end
// 648:           return
// 649:         end
// 650:
// 651:         @named_args_type = type
// 652:
// 653:         if type == :none
// 654:           @max_named_args = 0
// 655:         elsif number
// 656:           @min_named_args = @max_named_args = number
// 657:         elsif min || max
// 658:           @min_named_args = min
// 659:           @max_named_args = max
// 660:         end
// 661:
// 662:         @named_args_without_api = without_api
// 663:       end
// 664:
// 665:       sig { void }
// 666:       def hide_from_man_page!
// 667:         @hide_from_man_page = true
// 668:       end
// 669:
// 670:       sig {
// 671:         params(
// 672:           name:          String,
// 673:           aliases:       T::Array[String],
// 674:           alias_options: T::Hash[String, String],
// 675:           description:   T.nilable(String),
// 676:           default:       T::Boolean,
// 677:           hidden:        T::Boolean,
// 678:           replacement:   T.nilable(T.any(String, Symbol)),
// 679:           odeprecated:   T::Boolean,
// 680:           odisabled:     T::Boolean,
// 681:           block:         T.nilable(T.proc.bind(Parser).void),
// 682:         ).void
// 683:       }
// 684:       def subcommand(name, aliases: [], alias_options: {}, description: nil, default: false, hidden: false,
// 685:                      replacement: nil, odeprecated: false, odisabled: false, &block)
// 686:         previous_subcommands = @current_subcommands
// 687:         hidden = true if odeprecated || odisabled
// 688:
// 689:         @subcommands << Subcommand.new(
// 690:           name:,
// 691:           aliases:       aliases | alias_options.keys,
// 692:           alias_options:,
// 693:           description:,
// 694:           default:,
// 695:           hidden:,
// 696:           replacement:,
// 697:           odeprecated:,
// 698:           odisabled:,
// 699:         )
// 700:
// 701:         @current_subcommands = [name]
// 702:         instance_eval(&block) if block
// 703:       ensure
// 704:         @current_subcommands = previous_subcommands
// 705:       end
// 706:
// 707:       sig { returns(T::Array[String]) }
// 708:       def subcommand_names = @subcommands.map(&:name)
// 709:
// 710:       sig { returns(T.nilable(Subcommand)) }
// 711:       def default_subcommand = @subcommands.find(&:default)
// 712:
// 713:       sig { params(name: String).returns(T.nilable(Subcommand)) }
// 714:       def subcommand_for_name(name)
// 715:         @subcommands.find { |subcommand| subcommand.name == name || subcommand.aliases.include?(name) }
// 716:       end
// 717:
// 718:       sig { params(subcommand_name: T.nilable(String)).returns(Args::OptionsType) }
// 719:       def processed_options_for_subcommand(subcommand_name)
// 720:         subcommand = if subcommand_name
// 721:           subcommand_for_name(subcommand_name)
// 722:         else
// 723:           default_subcommand
// 724:         end
// 725:         canonical_subcommand = subcommand&.name
// 726:
// 727:         root_options = @processed_options_by_subcommand.fetch(nil, [])
// 728:         return root_options if canonical_subcommand.nil?
// 729:
// 730:         root_options + @processed_options_by_subcommand.fetch(canonical_subcommand, [])
// 731:       end
// 732:
// 733:       sig { returns(Args::OptionsType) }
// 734:       def processed_options_for_root_command
// 735:         @processed_options_by_subcommand.fetch(nil, [])
// 736:       end
// 737:
// 738:       sig { params(subcommand_name: String).returns(ArgType) }
// 739:       def named_args_type_for_subcommand(subcommand_name)
// 740:         subcommand_for_name(subcommand_name)&.named_args_type
// 741:       end
// 742:
// 743:       sig { params(named_args: T::Array[String]).returns(T.nilable(String)) }
// 744:       def subcommand_name(named_args)
// 745:         subcommand = if named_args.empty?
// 746:           default_subcommand
// 747:         else
// 748:           subcommand_for_name(named_args.fetch(0))
// 749:         end
// 750:
// 751:         subcommand&.name
// 752:       end
// 753:
// 754:       sig { params(option: String).returns(T::Array[String]) }
// 755:       def subcommands_for_option(option)
// 756:         @option_subcommands.fetch(option_to_name(option), [])
// 757:       end
// 758:
// 759:       private
// 760:
// 761:       sig { returns(String) }
// 762:       def generate_usage_banner
// 763:         command_names = ["`#{@command_name}`"]
// 764:         aliases_to_skip = %w[instal uninstal]
// 765:         command_names += Commands::HOMEBREW_INTERNAL_COMMAND_ALIASES.filter_map do |command_alias, command|
// 766:           next if aliases_to_skip.include? command_alias
// 767:
// 768:           "`#{command_alias}`" if command == @command_name
// 769:         end.sort
// 770:
// 771:         options = if @non_global_processed_options.empty?
// 772:           ""
// 773:         elsif @non_global_processed_options.count > 2
// 774:           " [<options>]"
// 775:         else
// 776:           required_argument_types = [:required_flag, :comma_array]
// 777:           @non_global_processed_options.map do |option, type|
// 778:             next " [`#{option}=`]" if required_argument_types.include? type
// 779:
// 780:             " [`#{option}`]"
// 781:           end.join
// 782:         end
// 783:
// 784:         named_args = ""
// 785:         if @named_args_type.present? && @named_args_type != :none
// 786:           arg_type = if @named_args_type.is_a? Array
// 787:             types = @named_args_type.filter_map do |type|
// 788:               next unless type.is_a? Symbol
// 789:               next SYMBOL_TO_USAGE_MAPPING[type] if SYMBOL_TO_USAGE_MAPPING.key?(type)
// 790:
// 791:               "<#{type}>"
// 792:             end
// 793:             types << "<subcommand>" if @named_args_type.any?(String)
// 794:             types.join("|")
// 795:           elsif SYMBOL_TO_USAGE_MAPPING.key? @named_args_type
// 796:             SYMBOL_TO_USAGE_MAPPING[@named_args_type]
// 797:           else
// 798:             "<#{@named_args_type}>"
// 799:           end
// 800:
// 801:           named_args = if @min_named_args.nil? && @max_named_args == 1
// 802:             " [#{arg_type}]"
// 803:           elsif @min_named_args.nil?
// 804:             " [#{arg_type} ...]"
// 805:           elsif @min_named_args == 1 && @max_named_args == 1
// 806:             " #{arg_type}"
// 807:           elsif @min_named_args == 1
// 808:             " #{arg_type} [...]"
// 809:           else
// 810:             " #{arg_type} ..."
// 811:           end
// 812:         end
// 813:
// 814:         "#{command_names.join(", ")}#{options}#{named_args}"
// 815:       end
// 816:
// 817:       sig { returns(String) }
// 818:       def generate_banner
// 819:         @usage_banner ||= generate_usage_banner
// 820:
// 821:         @parser.banner = <<~BANNER
// 822:           #{@usage_banner}
// 823:
// 824:           #{usage_description_text}
// 825:
// 826:         BANNER
// 827:       end
// 828:
// 829:       sig { params(names: String, value: T.untyped, from: Symbol).void }
// 830:       def set_switch(*names, value:, from:)
// 831:         names.each do |name|
// 832:           option_name = option_to_name(name)
// 833:           @switch_sources[option_name] = from
// 834:           @option_sources[option_name] = from
// 835:           @option_types[option_name] ||= :switch
// 836:           set_args_method(:"#{option_name}?", value)
// 837:         end
// 838:       end
// 839:
// 840:       sig { params(args: String).void }
// 841:       def disable_switch(*args)
// 842:         args.each do |name|
// 843:           result = if name.start_with?("--[no-]")
// 844:             nil
// 845:           else
// 846:             false
// 847:           end
// 848:           set_args_method(:"#{option_to_name(name)}?", result)
// 849:         end
// 850:       end
// 851:
// 852:       sig { params(name: String).returns(T::Boolean) }
// 853:       def option_passed?(name)
// 854:         [name.to_sym, :"#{name}?"].any? do |method|
// 855:           @args.public_send(method) if @args.respond_to?(method)
// 856:         end
// 857:       end
// 858:
// 859:       sig { params(desc: String).returns(T::Array[String]) }
// 860:       def wrap_option_desc(desc)
// 861:         Formatter.format_help_text(desc, width: Formatter::OPTION_DESC_WIDTH).split("\n")
// 862:       end
// 863:
// 864:       sig {
// 865:         params(name: String, depends_on: T.nilable(String),
// 866:                subcommands: T.nilable(T.any(String, T::Array[String]))).void
// 867:       }
// 868:       def set_constraints(name, depends_on:, subcommands:)
// 869:         return if depends_on.nil?
// 870:
// 871:         primary = option_to_name(depends_on)
// 872:         secondary = option_to_name(name)
// 873:         @constraints << [primary, secondary, effective_subcommands(subcommands)]
// 874:       end
// 875:
// 876:       sig { params(args: T::Array[String]).void }
// 877:       def check_constraints(args)
// 878:         subcommand = subcommand_name(args)
// 879:         @constraints.each do |primary, secondary, subcommands|
// 880:           next if subcommands.present? && (subcommand.nil? || subcommands.exclude?(subcommand))
// 881:
// 882:           primary_passed = option_passed?(primary)
// 883:           secondary_passed = option_passed?(secondary)
// 884:
// 885:           next if !secondary_passed || (primary_passed && secondary_passed)
// 886:
// 887:           primary = name_to_option(primary)
// 888:           secondary = name_to_option(secondary)
// 889:
// 890:           raise OptionConstraintError.new(primary, secondary, missing: true)
// 891:         end
// 892:       end
// 893:
// 894:       sig { void }
// 895:       def check_conflicts
// 896:         @conflicts.each do |mutually_exclusive_options_group|
// 897:           violations = mutually_exclusive_options_group.select do |option|
// 898:             option_passed? option
// 899:           end
// 900:
// 901:           next if violations.count < 2
// 902:
// 903:           env_var_options = violations.select do |option|
// 904:             @switch_sources[option_to_name(option)] == :env
// 905:           end
// 906:
// 907:           select_cli_arg = violations.count - env_var_options.count == 1
// 908:           raise OptionConflictError, violations.map { name_to_option(it) } unless select_cli_arg
// 909:
// 910:           env_var_options.each { disable_switch(it) }
// 911:         end
// 912:       end
// 913:
// 914:       sig { void }
// 915:       def check_invalid_constraints
// 916:         @conflicts.each do |mutually_exclusive_options_group|
// 917:           @constraints.each do |p, s, _subcommands|
// 918:             next unless Set[p, s].subset?(Set[*mutually_exclusive_options_group])
// 919:
// 920:             raise InvalidConstraintError.new(p, s)
// 921:           end
// 922:         end
// 923:       end
// 924:
// 925:       sig { params(args: T::Array[String]).void }
// 926:       def check_constraint_violations(args)
// 927:         check_invalid_constraints
// 928:         check_conflicts
// 929:         check_constraints(args)
// 930:       end
// 931:
// 932:       sig { params(args: T::Array[String], type: ArgType, min: T.nilable(Integer), max: T.nilable(Integer)).void }
// 933:       def check_named_args_count(args, type, min, max)
// 934:         types = Array(type).filter_map do |type|
// 935:           next type if type.is_a? Symbol
// 936:
// 937:           :subcommand
// 938:         end.uniq
// 939:
// 940:         exception = if min && max && min == max && args.size != max
// 941:           NumberOfNamedArgumentsError.new(min, types:)
// 942:         elsif min && args.size < min
// 943:           MinNamedArgumentsError.new(min, types:)
// 944:         elsif max && args.size > max
// 945:           MaxNamedArgumentsError.new(max, types:)
// 946:         end
// 947:
// 948:         raise exception if exception
// 949:       end
// 950:
// 951:       sig { params(args: T::Array[String]).void }
// 952:       def check_named_args(args)
// 953:         check_named_args_count(args, @named_args_type, @min_named_args, @max_named_args)
// 954:       end
// 955:
// 956:       sig { params(args: T::Array[String]).void }
// 957:       def check_subcommand_violations(args)
// 958:         return if @subcommands.empty?
// 959:
// 960:         subcommand = if args.empty?
// 961:           default_subcommand
// 962:         else
// 963:           subcommand_for_name(args.fetch(0))
// 964:         end
// 965:         raise UsageError, "unknown subcommand: `#{args.first}`" if subcommand.nil? && args.present?
// 966:         return if subcommand.nil?
// 967:
// 968:         subcommand_args = if args.empty?
// 969:           args
// 970:         else
// 971:           args.drop(1)
// 972:         end
// 973:         check_named_args_count(subcommand_args, subcommand.named_args_type, subcommand.min_named_args,
// 974:                                subcommand.max_named_args)
// 975:         @option_sources.each do |option, source|
// 976:           next if source == :env
// 977:           next if option_allowed_for_subcommand?(option, subcommand.name)
// 978:
// 979:           option_type = @option_types.fetch(option)
// 980:           option_type_name = if option_type == :switch
// 981:             "switch"
// 982:           else
// 983:             "flag"
// 984:           end
// 985:           raise UsageError, "The `#{subcommand.name}` subcommand does not accept the `#{name_to_option(option)}` " \
// 986:                             "#{option_type_name}."
// 987:         end
// 988:       end
// 989:
// 990:       sig { returns(String) }
// 991:       def usage_description_text
// 992:         parts = T.let([], T::Array[String])
// 993:         parts << @description if @description.present?
// 994:         @subcommands.each do |subcommand|
// 995:           usage_banner = subcommand.usage_banner
// 996:           parts << usage_banner if usage_banner.present?
// 997:         end
// 998:         parts.join("\n\n")
// 999:       end
// 1000:
// 1001:       sig { params(subcommand_name: T.nilable(String)).returns(String) }
// 1002:       def option_summaries_text(subcommand_name)
// 1003:         lines = T.let([], T::Array[String])
// 1004:         short_options = T.let({}, T::Hash[String, T::Boolean])
// 1005:         long_options = T.let({}, T::Hash[String, T::Boolean])
// 1006:
// 1007:         processed_option_summaries = @processed_option_summaries_by_subcommand.fetch(nil, [])
// 1008:         if subcommand_name.present?
// 1009:           processed_option_summaries += @processed_option_summaries_by_subcommand.fetch(subcommand_name, [])
// 1010:         end
// 1011:
// 1012:         processed_option_summaries.each do |option, hidden|
// 1013:           next if hidden
// 1014:
// 1015:           option.summarize(short_options, long_options, @parser.summary_width, @parser.summary_width - 1,
// 1016:                            @parser.summary_indent) { |line| lines << line }
// 1017:         end
// 1018:
// 1019:         lines.join("\n")
// 1020:       end
// 1021:
// 1022:       sig { params(option: String, subcommand_name: T.nilable(String)).returns(T::Boolean) }
// 1023:       def option_allowed_for_subcommand?(option, subcommand_name)
// 1024:         subcommands = @option_subcommands[option]
// 1025:         return true if subcommands.blank?
// 1026:
// 1027:         subcommand_name.present? && subcommands.include?(subcommand_name)
// 1028:       end
// 1029:
// 1030:       sig { params(subcommands: T.nilable(T.any(String, T::Array[String]))).returns(T.nilable(T::Array[String])) }
// 1031:       def effective_subcommands(subcommands)
// 1032:         return @current_subcommands if subcommands.nil?
// 1033:
// 1034:         Array(subcommands).map do |subcommand|
// 1035:           subcommand_for_name(subcommand)&.name || subcommand
// 1036:         end
// 1037:       end
// 1038:
// 1039:       sig {
// 1040:         params(option_names: T::Array[String], type: Symbol,
// 1041:                subcommands: T.nilable(T.any(String, T::Array[String]))).void
// 1042:       }
// 1043:       def record_option_metadata(option_names, type:, subcommands:)
// 1044:         option_names.each do |name|
// 1045:           option_name = option_to_name(name)
// 1046:           @option_types[option_name] = type
// 1047:           # Global options are accepted everywhere, so a subcommand block
// 1048:           # re-declaring one (e.g. for a custom description) must not constrain it.
// 1049:           next if global_option?(name)
// 1050:
// 1051:           effective_subcommands = effective_subcommands(subcommands)
// 1052:           next if effective_subcommands.blank?
// 1053:
// 1054:           @option_subcommands[option_name] = (@option_subcommands[option_name] || []) |
// 1055:                                              effective_subcommands
// 1056:         end
// 1057:       end
// 1058:
// 1059:       sig { params(name: String).returns(T::Boolean) }
// 1060:       def global_option?(name)
// 1061:         option_name = option_to_name(name)
// 1062:         self.class.global_options.any? do |short, long, _desc|
// 1063:           option_to_name(short) == option_name || option_to_name(long) == option_name
// 1064:         end
// 1065:       end
// 1066:
// 1067:       sig {
// 1068:         params(args: String, type: Symbol, hidden: T::Boolean,
// 1069:                subcommands: T.nilable(T.any(String, T::Array[String]))).void
// 1070:       }
// 1071:       def process_option(*args, type:, hidden: false, subcommands: nil)
// 1072:         option, = @parser.make_switch(args)
// 1073:         @processed_options.reject! { |existing| existing.second == option.long.first } if option.long.first.present?
// 1074:         if option.long.first.present?
// 1075:           @processed_option_summaries.reject! do |existing,|
// 1076:             existing.long.first == option.long.first
// 1077:           end
// 1078:         end
// 1079:         @processed_options << [option.short.first, option.long.first, option.desc.first, hidden]
// 1080:         @processed_option_summaries << [option, hidden]
// 1081:
// 1082:         display_subcommands = effective_subcommands(subcommands)
// 1083:         subcommand_names = T.let([], T::Array[T.nilable(String)])
// 1084:         if display_subcommands.blank?
// 1085:           subcommand_names << nil
// 1086:         else
// 1087:           subcommand_names.concat(display_subcommands)
// 1088:         end
// 1089:
// 1090:         subcommand_names.each do |subcommand_name|
// 1091:           processed_options = @processed_options_by_subcommand[subcommand_name] ||= []
// 1092:           processed_options.reject! { |existing| existing.second == option.long.first } if option.long.first.present?
// 1093:           processed_options << [option.short.first, option.long.first, option.desc.first, hidden]
// 1094:
// 1095:           processed_option_summaries = @processed_option_summaries_by_subcommand[subcommand_name] ||= []
// 1096:           if option.long.first.present?
// 1097:             processed_option_summaries.reject! { |existing,| existing.long.first == option.long.first }
// 1098:           end
// 1099:           processed_option_summaries << [option, hidden]
// 1100:         end
// 1101:
// 1102:         args.pop # last argument is the description
// 1103:         record_option_metadata(args, type:, subcommands:)
// 1104:         if type == :switch
// 1105:           disable_switch(*args)
// 1106:         else
// 1107:           args.each do |name|
// 1108:             set_args_method(option_to_name(name).to_sym, nil)
// 1109:           end
// 1110:         end
// 1111:
// 1112:         return if hidden
// 1113:         return if self.class.global_options.include? [option.short.first, option.long.first, option.desc.first]
// 1114:
// 1115:         @non_global_processed_options << [option.long.first || option.short.first, type]
// 1116:       end
// 1117:
// 1118:       sig { params(argv: T::Array[String]).returns([T::Array[String], T::Array[String]]) }
// 1119:       def split_non_options(argv)
// 1120:         if (sep = argv.index("--"))
// 1121:           [argv.take(sep), argv.drop(sep + 1)]
// 1122:         else
// 1123:           [argv, []]
// 1124:         end
// 1125:       end
// 1126:
// 1127:       sig { params(argv: T::Array[String]).returns(T::Array[Formula]) }
// 1128:       def formulae(argv)
// 1129:         argv, non_options = split_non_options(argv)
// 1130:
// 1131:         named_args = argv.reject { |arg| arg.start_with?("-") } + non_options
// 1132:         spec = if argv.include?("--HEAD")
// 1133:           :head
// 1134:         else
// 1135:           :stable
// 1136:         end
// 1137:
// 1138:         # Only lowercase names, not paths, bottle filenames or URLs
// 1139:         named_args.filter_map do |arg|
// 1140:           next if arg.match?(HOMEBREW_CASK_TAP_CASK_REGEX)
// 1141:
// 1142:           begin
// 1143:             Formulary.factory(arg, spec, flags: argv.select { |a| a.start_with?("--") })
// 1144:           rescue FormulaUnavailableError, FormulaSpecificationError
// 1145:             nil
// 1146:           end
// 1147:         end.uniq(&:name)
// 1148:       end
// 1149:
// 1150:       sig { params(argv: T::Array[String]).returns(T::Boolean) }
// 1151:       def only_casks?(argv)
// 1152:         argv.include?("--casks") || argv.include?("--cask")
// 1153:       end
// 1154:
// 1155:       sig { params(env: T.nilable(T.any(String, Symbol))).returns(T.untyped) }
// 1156:       def value_for_env(env)
// 1157:         return if env.blank?
// 1158:
// 1159:         method_name = :"#{env}?"
// 1160:         if Homebrew::EnvConfig.respond_to?(method_name)
// 1161:           Homebrew::EnvConfig.public_send(method_name)
// 1162:         else
// 1163:           ENV.fetch("HOMEBREW_#{env.upcase}", nil)
// 1164:         end
// 1165:       end
// 1166:     end
// 1167:   end
// 1168: end

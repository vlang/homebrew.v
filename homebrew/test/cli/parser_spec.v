module cli

import homebrew.cli as brew_cli

// Translated from Homebrew/brew `test/cli/parser_spec.rb`.
// The original source is retained below until every stub has a typed V body.
fn switch_options_parser() brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['--more-verbose'], brew_cli.OptionConfig{
		description: 'Flag for higher verbosity'
	})
	parser.add_switch(['--pry'], brew_cli.OptionConfig{
		env: 'pry'
		env_is_set: true
		env_value: '1'
	})
	parser.add_switch(['--foo'], brew_cli.OptionConfig{
		env: 'foo'
		env_is_set: true
		env_value: ''
	})
	parser.add_switch(['--bar'], brew_cli.OptionConfig{
		env: 'bar'
		env_is_set: true
		env_value: '1'
	})
	parser.add_switch(['--hidden'], brew_cli.OptionConfig{
		hidden: true
	})
	return parser
}

fn binary_switch_parser() brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['--[no-]positive'], brew_cli.OptionConfig{})
	return parser
}

fn negative_switch_parser() brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['--no-positive'], brew_cli.OptionConfig{})
	return parser
}

fn ask_parser(no_ask string, ask string) brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['--no-ask', '--yes', '-y'], brew_cli.OptionConfig{
		env: 'no_ask'
		env_is_set: true
		env_value: no_ask
	})
	parser.add_switch(['--ask'], brew_cli.OptionConfig{
		env: 'ask'
		env_is_set: true
		env_value: ask
	})
	parser.add_conflicts(['--ask', '--no-ask'])
	return parser
}

fn describe_parser(no_describe string, describe string) brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['--no-describe'], brew_cli.OptionConfig{
		env: 'bundle_no_describe'
		env_is_set: true
		env_value: no_describe
	})
	parser.add_switch(['--describe'], brew_cli.OptionConfig{
		env: 'bundle_describe'
		env_is_set: true
		env_value: describe
	})
	parser.add_conflicts(['--describe', '--no-describe'])
	return parser
}

fn long_flag_parser() brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_flag(['--filename='], brew_cli.OptionConfig{
		description: 'Name of the file'
	})
	parser.add_comma_array('--files', brew_cli.OptionConfig{
		description: 'Comma-separated filenames'
	})
	parser.add_flag(['--hidden='], brew_cli.OptionConfig{
		hidden: true
	})
	parser.add_comma_array('--hidden-array', brew_cli.OptionConfig{
		hidden: true
	})
	return parser
}

fn short_flag_parser() brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_flag(['-f', '--filename='], brew_cli.OptionConfig{
		description: 'Name of the file'
	})
	return parser
}

fn flag_constraints_parser(invalid bool) brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_flag(['--flag1='], brew_cli.OptionConfig{})
	parser.add_flag(['--flag2='], brew_cli.OptionConfig{
		depends_on: '--flag1='
	})
	if !invalid {
		parser.add_flag(['--flag3='], brew_cli.OptionConfig{})
		parser.add_conflicts(['--flag1', '--flag3'])
	} else {
		parser.add_conflicts(['--flag1', '--flag2'])
	}
	return parser
}

fn switch_constraints_parser(env_a string, env_b string) brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['-a', '--switch-a'], brew_cli.OptionConfig{
		env: 'switch_a'
		env_is_set: true
		env_value: env_a
	})
	parser.add_switch(['-b', '--switch-b'], brew_cli.OptionConfig{
		env: 'switch_b'
		env_is_set: true
		env_value: env_b
	})
	parser.add_switch(['--switch-c'], brew_cli.OptionConfig{
		depends_on: '--switch-a'
	})
	parser.add_conflicts(['--switch-a', '--switch-b'])
	return parser
}

fn immutability_parser() brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['-a', '--switch-a'], brew_cli.OptionConfig{})
	parser.add_switch(['-b', '--switch-b'], brew_cli.OptionConfig{})
	return parser
}

fn inferrability_parser() brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['--switch-a'], brew_cli.OptionConfig{})
	parser.add_switch(['--switch-b'], brew_cli.OptionConfig{})
	parser.add_switch(['--foo-switch'], brew_cli.OptionConfig{})
	parser.add_flag(['--flag-foo='], brew_cli.OptionConfig{})
	parser.add_comma_array('--comma-array-foo', brew_cli.OptionConfig{})
	return parser
}

fn argv_parser() brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['--foo'], brew_cli.OptionConfig{})
	parser.add_flag(['--bar'], brew_cli.OptionConfig{})
	parser.add_switch(['-s'], brew_cli.OptionConfig{})
	return parser
}

fn parser_none() brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['none']
	}) or { panic(err) }
	return parser
}

fn parser_number() brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		number: 1
	}) or { panic(err) }
	return parser
}

fn configure_install_subcommand(mut parser brew_cli.Parser) ! {
	parser.set_usage_banner('`test install`:\nInstall dependencies.')!
	parser.add_switch(['--force'], brew_cli.OptionConfig{})
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['none']
	})!
}

fn configure_info_subcommand(mut parser brew_cli.Parser) ! {
	parser.set_usage_banner('`test info` <service>:\nShow service information.')!
	parser.add_switch(['--json'], brew_cli.OptionConfig{})
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['service']
		minimum: 1
	})!
}

fn subcommand_parser() brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.set_usage_banner('`test` [<subcommand>]') or { panic(err) }
	parser.set_description('Test command.')
	parser.add_switch(['--global'], brew_cli.OptionConfig{})
	parser.add_subcommand('install', brew_cli.SubcommandConfig{
		default: true
	}, configure_install_subcommand) or { panic(err) }
	parser.add_subcommand('info', brew_cli.SubcommandConfig{
		aliases: ['i']
	}, configure_info_subcommand) or { panic(err) }
	return parser
}

fn switch_value_is(args brew_cli.Args, name string, expected bool) bool {
	value := args.switch_value(name) or { return false }
	return value == expected
}

fn configure_none_subcommand(mut parser brew_cli.Parser) ! {
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['none']
	})!
}

fn configure_verbose_subcommand(mut parser brew_cli.Parser) ! {
	parser.add_switch(['-v', '--verbose'], brew_cli.OptionConfig{
		description: 'Print output from commands as they are run.'
	})
	configure_none_subcommand(mut parser)!
}

fn configure_install_constraints(mut parser brew_cli.Parser) ! {
	parser.add_switch(['--cleanup'], brew_cli.OptionConfig{})
	parser.add_switch(['--zap'], brew_cli.OptionConfig{
		depends_on: '--cleanup'
	})
	configure_none_subcommand(mut parser)!
}

fn configure_cleanup_constraints(mut parser brew_cli.Parser) ! {
	parser.add_switch(['--zap'], brew_cli.OptionConfig{})
	configure_none_subcommand(mut parser)!
}

fn configure_alias_install(mut parser brew_cli.Parser) ! {
	parser.add_switch(['--upgrade'], brew_cli.OptionConfig{})
	parser.add_switch(['--force'], brew_cli.OptionConfig{})
	configure_none_subcommand(mut parser)!
}

fn parser_with_global_redeclaration() !brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_subcommand('install', brew_cli.SubcommandConfig{
		default: true
	}, configure_verbose_subcommand)!
	parser.add_subcommand('cleanup', brew_cli.SubcommandConfig{}, configure_none_subcommand)!
	return parser
}

fn parser_with_scoped_constraints() !brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_subcommand('install', brew_cli.SubcommandConfig{
		default: true
	}, configure_install_constraints)!
	parser.add_subcommand('cleanup', brew_cli.SubcommandConfig{}, configure_cleanup_constraints)!
	return parser
}

// Ruby subject `subject(:parser) do` at line 10.
pub fn ruby_parser_spec_l10_d1_parser() brew_cli.Parser {
	return switch_options_parser()
}

// Ruby subject `subject(:parser) do` at line 28.
pub fn ruby_parser_spec_l28_d2_parser() brew_cli.Parser {
	return binary_switch_parser()
}

// Ruby it `it "does not create no_positive?" do` at line 34.
pub fn ruby_parser_spec_l34_d3_does() bool {
	mut parser := binary_switch_parser()
	parsed := parser.parse(['--no-positive'], false) or { return false }
	if _ := parsed.switch_value('no_positive') {
		return false
	}
	return true
}

// Ruby it `it "sets the positive name to false if the negative switch is passed" do` at line 39.
pub fn ruby_parser_spec_l39_d4_sets() bool {
	mut parser := binary_switch_parser()
	parsed := parser.parse(['--no-positive'], false) or { return false }
	return switch_value_is(parsed, 'positive', false)
}

// Ruby it `it "sets the positive name to true if the positive switch is passed" do` at line 44.
pub fn ruby_parser_spec_l44_d5_sets() bool {
	mut parser := binary_switch_parser()
	parsed := parser.parse(['--positive'], false) or { return false }
	return switch_value_is(parsed, 'positive', true)
}

// Ruby it `it "does not set the positive name if the positive switch is not passed" do` at line 49.
pub fn ruby_parser_spec_l49_d6_does() bool {
	mut parser := binary_switch_parser()
	parsed := parser.parse([]string{}, false) or { return false }
	if _ := parsed.switch_value('positive') {
		return false
	}
	return true
}

// Ruby subject `subject(:parser) do` at line 56.
pub fn ruby_parser_spec_l56_d7_parser() brew_cli.Parser {
	return negative_switch_parser()
}

// Ruby it `it "does not set the positive name" do` at line 62.
pub fn ruby_parser_spec_l62_d8_does() bool {
	mut parser := negative_switch_parser()
	parsed := parser.parse(['--no-positive'], false) or { return false }
	if _ := parsed.switch_value('positive') {
		return false
	}
	return true
}

// Ruby it `it "fails when using the positive name" do` at line 67.
pub fn ruby_parser_spec_l67_d9_fails() bool {
	mut parser := negative_switch_parser()
	parser.parse(['--positive'], false) or { return err.msg().contains('invalid option') }
	return false
}

// Ruby it `it "sets the negative name to true if the negative switch is passed" do` at line 73.
pub fn ruby_parser_spec_l73_d10_sets() bool {
	mut parser := negative_switch_parser()
	parsed := parser.parse(['--no-positive'], false) or { return false }
	return switch_value_is(parsed, 'no_positive', true)
}

// Ruby it `it "passes through invalid options" do` at line 80.
pub fn ruby_parser_spec_l80_d11_passes() bool {
	mut parser := switch_options_parser()
	parsed := parser.parse(['-v', 'named-arg', '--not-a-valid-option'], true) or { return false }
	return parsed.remaining == ['named-arg', '--not-a-valid-option'] && parsed.named.empty()
}

// Ruby it `it "flattens arguments after `--` into remaining" do` at line 87.
pub fn ruby_parser_spec_l87_d12_flattens() bool {
	mut parser := switch_options_parser()
	parsed := parser.parse(['-v', '--', 'foo', 'bar'], false) or { return false }
	return parsed.remaining == ['--', 'foo', 'bar']
}

// Ruby it `it "parses short option" do` at line 92.
pub fn ruby_parser_spec_l92_d13_parses() bool {
	mut parser := switch_options_parser()
	parsed := parser.parse(['-v'], false) or { return false }
	return switch_value_is(parsed, 'verbose', true)
}

// Ruby it `it "parses a single valid option" do` at line 97.
pub fn ruby_parser_spec_l97_d14_parses() bool {
	mut parser := switch_options_parser()
	parsed := parser.parse(['--verbose'], false) or { return false }
	return switch_value_is(parsed, 'verbose', true)
}

// Ruby it `it "parses a valid option along with few unnamed args" do` at line 102.
pub fn ruby_parser_spec_l102_d15_parses() bool {
	mut parser := switch_options_parser()
	parsed := parser.parse(['--verbose', 'unnamed', 'args'], false) or { return false }
	return switch_value_is(parsed, 'verbose', true) && parsed.named.values == [
		'unnamed',
		'args',
	]
}

// Ruby it `it "parses a single option and checks other options to be false" do` at line 108.
pub fn ruby_parser_spec_l108_d16_parses() bool {
	mut parser := switch_options_parser()
	parsed := parser.parse(['--verbose'], false) or { return false }
	return switch_value_is(parsed, 'verbose', true) && switch_value_is(parsed, 'more_verbose', false)
}

// Ruby it `it "sets the correct value for a hidden switch" do` at line 114.
pub fn ruby_parser_spec_l114_d17_sets() bool {
	mut parser := switch_options_parser()
	parsed := parser.parse([]string{}, false) or { return false }
	return switch_value_is(parsed, 'hidden', false)
}

// Ruby it `it "raises an exception and outputs help text when an invalid option is passed" do` at line 119.
pub fn ruby_parser_spec_l119_d18_raises() bool {
	mut parser := switch_options_parser()
	parser.parse(['--random'], false) or {
		return err.msg().contains('--random') && parser.generate_help_text().contains('Usage: brew')
	}
	return false
}

// Ruby it `it "maps environment var to an option" do` at line 124.
pub fn ruby_parser_spec_l124_d19_maps() bool {
	mut parser := switch_options_parser()
	parsed := parser.parse([]string{}, false) or { return false }
	return switch_value_is(parsed, 'pry', true) && switch_value_is(parsed, 'foo', false) && switch_value_is(parsed, 'bar', true)
}

// Ruby subject `subject(:parser) do` at line 133.
pub fn ruby_parser_spec_l133_d20_parser() brew_cli.Parser {
	return ask_parser('', '')
}

// Ruby it `it "lets HOMEBREW_NO_ASK override default ask mode" do` at line 141.
pub fn ruby_parser_spec_l141_d21_lets() bool {
	mut parser := ask_parser('1', '')
	parsed := parser.parse([]string{}, false) or { return false }
	return switch_value_is(parsed, 'no_ask', true)
}

// Ruby it `it "lets --ask override HOMEBREW_NO_ASK" do` at line 147.
pub fn ruby_parser_spec_l147_d22_lets() bool {
	mut parser := ask_parser('1', '')
	parsed := parser.parse(['--ask'], false) or { return false }
	return switch_value_is(parsed, 'ask', true) && switch_value_is(parsed, 'no_ask', false)
}

// Ruby it `it "lets --no-ask, --yes and -y override default ask mode" do` at line 155.
pub fn ruby_parser_spec_l155_d23_lets() bool {
	for option in ['--no-ask', '--yes', '-y'] {
		mut parser := ask_parser('', '')
		parsed := parser.parse([option], false) or { return false }
		if !switch_value_is(parsed, 'no_ask', true) {
			return false
		}
	}
	return true
}

// Ruby subject `subject(:parser) do` at line 167.
pub fn ruby_parser_spec_l167_d24_parser() brew_cli.Parser {
	return describe_parser('', '')
}

// Ruby it `it "lets --describe override HOMEBREW_BUNDLE_NO_DESCRIBE" do` at line 175.
pub fn ruby_parser_spec_l175_d25_lets() bool {
	mut parser := describe_parser('1', '')
	parsed := parser.parse(['--describe'], false) or { return false }
	return switch_value_is(parsed, 'describe', true) && switch_value_is(parsed, 'no_describe', false)
}

// Ruby subject `subject(:parser) do` at line 185.
pub fn ruby_parser_spec_l185_d26_parser() brew_cli.Parser {
	return long_flag_parser()
}

// Ruby it `it "parses a long flag option with its argument" do` at line 194.
pub fn ruby_parser_spec_l194_d27_parses() bool {
	mut parser := long_flag_parser()
	parsed := parser.parse(['--filename=random.txt'], false) or { return false }
	filename := parsed.flag_value('filename') or { return false }
	return filename == 'random.txt'
}

// Ruby it `it "raises an exception when a flag's required value is not passed" do` at line 199.
pub fn ruby_parser_spec_l199_d28_raises() bool {
	mut parser := long_flag_parser()
	parser.parse(['--filename'], false) or { return err.msg().contains('--filename') }
	return false
}

// Ruby it `it "parses a comma array flag option" do` at line 203.
pub fn ruby_parser_spec_l203_d29_parses() bool {
	mut parser := long_flag_parser()
	parsed := parser.parse(['--files=random1.txt,random2.txt'], false) or { return false }
	files := parsed.comma_array_value('files') or { return false }
	return files == ['random1.txt', 'random2.txt']
}

// Ruby it `it "sets the correct value for hidden flags" do` at line 208.
pub fn ruby_parser_spec_l208_d30_sets() bool {
	mut parser := long_flag_parser()
	parsed := parser.parse(['--hidden=foo', '--hidden-array=bar,baz'], false) or { return false }
	hidden := parsed.flag_value('hidden') or { return false }
	hidden_array := parsed.comma_array_value('hidden_array') or { return false }
	return hidden == 'foo' && hidden_array == ['bar', 'baz']
}

// Ruby subject `subject(:parser) do` at line 216.
pub fn ruby_parser_spec_l216_d31_parser() brew_cli.Parser {
	return short_flag_parser()
}

// Ruby it `it "parses a short flag option with its argument" do` at line 222.
pub fn ruby_parser_spec_l222_d32_parses() bool {
	mut parser := short_flag_parser()
	parsed := parser.parse(['--filename=random.txt'], false) or { return false }
	filename := parsed.flag_value('filename') or { return false }
	short := parsed.flag_value('f') or { return false }
	return filename == 'random.txt' && short == 'random.txt'
}

// Ruby subject `subject(:parser) do` at line 230.
pub fn ruby_parser_spec_l230_d33_parser() brew_cli.Parser {
	return flag_constraints_parser(false)
}

// Ruby it `it "raises exception on depends_on constraint violation" do` at line 240.
pub fn ruby_parser_spec_l240_d34_raises() bool {
	mut parser := flag_constraints_parser(false)
	parser.parse(['--flag2=flag2'], false) or { return err.msg().contains('cannot be passed without') }
	return false
}

// Ruby it `it "raises exception for conflict violation" do` at line 244.
pub fn ruby_parser_spec_l244_d35_raises() bool {
	mut parser := flag_constraints_parser(false)
	parser.parse(['--flag1=flag1', '--flag3=flag3'], false) or {
		return err.msg().contains('mutually exclusive')
	}
	return false
}

// Ruby it `it "raises no exception" do` at line 248.
pub fn ruby_parser_spec_l248_d36_raises() bool {
	mut parser := flag_constraints_parser(false)
	parsed := parser.parse(['--flag1=flag1', '--flag2=flag2'], false) or { return false }
	flag1 := parsed.flag_value('flag1') or { return false }
	flag2 := parsed.flag_value('flag2') or { return false }
	return flag1 == 'flag1' && flag2 == 'flag2'
}

// Ruby it `it "raises no exception for optional dependency" do` at line 254.
pub fn ruby_parser_spec_l254_d37_raises() bool {
	mut parser := flag_constraints_parser(false)
	parsed := parser.parse(['--flag3=flag3'], false) or { return false }
	flag3 := parsed.flag_value('flag3') or { return false }
	return flag3 == 'flag3'
}

// Ruby subject `subject(:parser) do` at line 261.
pub fn ruby_parser_spec_l261_d38_parser() brew_cli.Parser {
	return flag_constraints_parser(true)
}

// Ruby it `it "raises exception due to invalid constraints" do` at line 270.
pub fn ruby_parser_spec_l270_d39_raises() bool {
	mut parser := flag_constraints_parser(true)
	parser.parse([]string{}, false) or { return err.msg().contains('simultaneously') }
	return false
}

// Ruby subject `subject(:parser) do` at line 276.
pub fn ruby_parser_spec_l276_d40_parser() brew_cli.Parser {
	return switch_constraints_parser('', '')
}

// Ruby it `it "raises exception on depends_on constraint violation" do` at line 286.
pub fn ruby_parser_spec_l286_d41_raises() bool {
	mut parser := switch_constraints_parser('', '')
	parser.parse(['--switch-c'], false) or { return err.msg().contains('cannot be passed without') }
	return false
}

// Ruby it `it "raises exception for conflict violation" do` at line 290.
pub fn ruby_parser_spec_l290_d42_raises() bool {
	mut parser := switch_constraints_parser('', '')
	parser.parse(['-ab'], false) or { return err.msg().contains('mutually exclusive') }
	return false
}

// Ruby it `it "raises no exception" do` at line 294.
pub fn ruby_parser_spec_l294_d43_raises() bool {
	mut parser := switch_constraints_parser('', '')
	parsed := parser.parse(['--switch-a', '--switch-c'], false) or { return false }
	return switch_value_is(parsed, 'switch_a', true) && switch_value_is(parsed, 'switch_c', true)
}

// Ruby it `it "raises no exception for optional dependency" do` at line 300.
pub fn ruby_parser_spec_l300_d44_raises() bool {
	mut parser := switch_constraints_parser('', '')
	parsed := parser.parse(['--switch-b'], false) or { return false }
	return switch_value_is(parsed, 'switch_b', true)
}

// Ruby it `it "prioritizes cli arguments over env vars when they conflict" do` at line 305.
pub fn ruby_parser_spec_l305_d45_prioritizes() bool {
	mut parser := switch_constraints_parser('1', '')
	parsed := parser.parse(['--switch-b'], false) or { return false }
	return switch_value_is(parsed, 'switch_a', false) && switch_value_is(parsed, 'switch_b', true)
}

// Ruby it `it "raises an exception on constraint violation when both are env vars" do` at line 314.
pub fn ruby_parser_spec_l314_d46_raises() bool {
	mut parser := switch_constraints_parser('1', '1')
	parser.parse([]string{}, false) or { return err.msg().contains('mutually exclusive') }
	return false
}

// Ruby subject `subject(:parser) do` at line 323.
pub fn ruby_parser_spec_l323_d47_parser() brew_cli.Parser {
	return immutability_parser()
}

// Ruby it `it "raises exception when arguments were already parsed" do` at line 330.
pub fn ruby_parser_spec_l330_d48_raises() bool {
	mut parser := immutability_parser()
	parser.parse(['--switch-a'], false) or { return false }
	parser.parse(['--switch-b'], false) or { return err.msg().contains('Arguments were already parsed!') }
	return false
}

// Ruby subject `subject(:parser) do` at line 337.
pub fn ruby_parser_spec_l337_d49_parser() brew_cli.Parser {
	return inferrability_parser()
}

// Ruby it `it "parses a valid switch that uses `_` instead of `-`" do` at line 347.
pub fn ruby_parser_spec_l347_d50_parses() bool {
	mut parser := inferrability_parser()
	parsed := parser.parse(['--switch_a'], false) or { return false }
	return switch_value_is(parsed, 'switch_a', true)
}

// Ruby it `it "parses a valid flag that uses `_` instead of `-`" do` at line 352.
pub fn ruby_parser_spec_l352_d51_parses() bool {
	mut parser := inferrability_parser()
	parsed := parser.parse(['--flag_foo=foo.txt'], false) or { return false }
	flag := parsed.flag_value('flag_foo') or { return false }
	return flag == 'foo.txt'
}

// Ruby it `it "parses a valid comma_array that uses `_` instead of `-`" do` at line 357.
pub fn ruby_parser_spec_l357_d52_parses() bool {
	mut parser := inferrability_parser()
	parsed := parser.parse(['--comma_array_foo=foo.txt,bar.txt'], false) or { return false }
	items := parsed.comma_array_value('comma_array_foo') or { return false }
	return items == ['foo.txt', 'bar.txt']
}

// Ruby it `it "raises an error when option is ambiguous" do` at line 362.
pub fn ruby_parser_spec_l362_d53_raises() bool {
	mut parser := inferrability_parser()
	parser.parse(['--switch'], false) or { return err.msg().contains('ambiguous option: --switch') }
	return false
}

// Ruby it `it "inferrs the option from an abbreviated name" do` at line 366.
pub fn ruby_parser_spec_l366_d54_inferrs() bool {
	mut parser := inferrability_parser()
	parsed := parser.parse(['--foo'], false) or { return false }
	return switch_value_is(parsed, 'foo_switch', true)
}

// Ruby subject `subject(:parser) do` at line 373.
pub fn ruby_parser_spec_l373_d55_parser() brew_cli.Parser {
	return argv_parser()
}

// Ruby it `it "#options_only" do` at line 381.
pub fn ruby_parser_spec_l381_d56_options_only() bool {
	mut parser := argv_parser()
	parsed := parser.parse(['--foo', '--bar=value', '-v', '-s', 'a', 'b', 'cdefg'], false) or {
		return false
	}
	return parsed.options_only == ['--verbose', '--foo', '--bar=value', '-s']
}

// Ruby it `it "#flags_only" do` at line 386.
pub fn ruby_parser_spec_l386_d57_flags_only() bool {
	mut parser := argv_parser()
	parsed := parser.parse(['--foo', '--bar=value', '-v', '-s', 'a', 'b', 'cdefg'], false) or {
		return false
	}
	return parsed.flags_only == ['--verbose', '--foo', '--bar=value']
}

// Ruby it `it "#named returns an array of non-option arguments" do` at line 391.
pub fn ruby_parser_spec_l391_d58_named() bool {
	mut parser := argv_parser()
	parsed := parser.parse(['foo', '-v', '-s'], false) or { return false }
	return parsed.named.values == ['foo']
}

// Ruby it `it "#named returns an empty array when there are no named arguments" do` at line 396.
pub fn ruby_parser_spec_l396_d59_named() bool {
	mut parser := argv_parser()
	parsed := parser.parse([]string{}, false) or { return false }
	return parsed.named.empty()
}

// Ruby it `it "includes `[options]` if more than two non-global options are available" do` at line 403.
pub fn ruby_parser_spec_l403_d60_includes() bool {
	mut parser := brew_cli.new_parser('test')
	for option in ['--foo', '--baz', '--bar'] {
		parser.add_switch([option], brew_cli.OptionConfig{})
	}
	return parser.generate_help_text().contains('[options]')
}

// Ruby it `it "includes individual options if less than two non-global options are available" do` at line 412.
pub fn ruby_parser_spec_l412_d61_includes() bool {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['--foo'], brew_cli.OptionConfig{})
	parser.add_switch(['--bar'], brew_cli.OptionConfig{})
	return parser.generate_help_text().contains('[--foo] [--bar]')
}

// Ruby it `it "formats flags correctly when less than two non-global options are available" do` at line 420.
pub fn ruby_parser_spec_l420_d62_formats() bool {
	mut parser := brew_cli.new_parser('test')
	parser.add_flag(['--foo'], brew_cli.OptionConfig{})
	parser.add_flag(['--bar='], brew_cli.OptionConfig{})
	return parser.generate_help_text().contains('[--foo] [--bar=]')
}

// Ruby it `it "formats comma arrays correctly when less than two non-global options are available" do` at line 428.
pub fn ruby_parser_spec_l428_d63_formats() bool {
	mut parser := brew_cli.new_parser('test')
	parser.add_comma_array('--foo', brew_cli.OptionConfig{})
	return parser.generate_help_text().contains('[--foo=]')
}

// Ruby it `it "does not include hidden options" do` at line 435.
pub fn ruby_parser_spec_l435_d64_does() bool {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['--foo'], brew_cli.OptionConfig{
		hidden: true
	})
	return !parser.generate_help_text().contains('[--foo]')
}

// Ruby it `it "doesn't include `[options]` if non non-global options are available" do` at line 442.
pub fn ruby_parser_spec_l442_d65_doesn() bool {
	parser := brew_cli.new_parser('test')
	return !parser.generate_help_text().contains('[options]')
}

// Ruby it `it "includes a description" do` at line 447.
pub fn ruby_parser_spec_l447_d66_includes() bool {
	mut parser := brew_cli.new_parser('test')
	parser.set_description('This command does something\n')
	return parser.generate_help_text().contains('This command does something')
}

// Ruby it `it "allows the usage banner to be overridden" do` at line 456.
pub fn ruby_parser_spec_l456_d67_allows() bool {
	mut parser := brew_cli.new_parser('test')
	parser.set_usage_banner('`test` [foo] <bar>') or { return false }
	return parser.generate_help_text().contains('test [foo] bar')
}

// Ruby it `it "allows a usage banner and a description to be overridden" do` at line 463.
pub fn ruby_parser_spec_l463_d68_allows() bool {
	mut parser := brew_cli.new_parser('test')
	parser.set_usage_banner('`test` [foo] <bar>') or { return false }
	parser.set_description('This command does something')
	help := parser.generate_help_text()
	return help.contains('test [foo] bar') && help.contains('This command does something')
}

// Ruby it `it "shows the correct usage for no named argument" do` at line 474.
pub fn ruby_parser_spec_l474_d69_shows() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['none']
	}) or { return false }
	first_line := parser.generate_help_text().split_into_lines()[0]
	return !first_line.contains('[')
}

// Ruby it `it "shows the correct usage for a single typed argument" do` at line 481.
pub fn ruby_parser_spec_l481_d70_shows() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['formula']
		number: 1
	}) or { return false }
	return parser.generate_help_text().split_into_lines()[0].ends_with(' formula')
}

// Ruby it `it "shows the correct usage for a subcommand argument with a maximum" do` at line 488.
pub fn ruby_parser_spec_l488_d71_shows() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['off', 'on']
		types_are_choices: true
		maximum: 1
	}) or { return false }
	return parser.generate_help_text().split_into_lines()[0].ends_with(' [subcommand]')
}

// Ruby it `it "shows the correct usage for multiple typed argument with no maximum or minimum" do` at line 495.
pub fn ruby_parser_spec_l495_d72_shows() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['tap', 'command']
	}) or { return false }
	return parser.generate_help_text().split_into_lines()[0].ends_with(' [tap|command ...]')
}

// Ruby it `it "shows the correct usage for a subcommand argument with a minimum of 1" do` at line 502.
pub fn ruby_parser_spec_l502_d73_shows() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['installed_formula']
		minimum: 1
	}) or { return false }
	return parser.generate_help_text().split_into_lines()[0].ends_with(' installed_formula [...]')
}

// Ruby it `it "shows the correct usage for a subcommand argument with a minimum greater than 1" do` at line 509.
pub fn ruby_parser_spec_l509_d74_shows() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['installed_formula']
		minimum: 2
	}) or { return false }
	return parser.generate_help_text().split_into_lines()[0].ends_with(' installed_formula ...')
}

// Ruby let `let(:parser_none) do` at line 518.
pub fn ruby_parser_spec_l518_d75_parser_none() brew_cli.Parser {
	return parser_none()
}

// Ruby let `let(:parser_number) do` at line 523.
pub fn ruby_parser_spec_l523_d76_parser_number() brew_cli.Parser {
	return parser_number()
}

// Ruby it `it "doesn't allow :none passed with a number" do` at line 529.
pub fn ruby_parser_spec_l529_d77_doesn() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['none']
		number: 1
	}) or { return err.msg().contains('named_args :none') }
	return false
}

// Ruby it `it "doesn't allow number and min" do` at line 537.
pub fn ruby_parser_spec_l537_d78_doesn() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		number: 1
		minimum: 1
	}) or { return err.msg().contains('both `number` and `min` or `max`') }
	return false
}

// Ruby it `it "doesn't accept fewer than the passed number of arguments" do` at line 545.
pub fn ruby_parser_spec_l545_d79_doesn() bool {
	mut parser := parser_number()
	parser.parse([]string{}, false) or { return err.msg().contains('exactly 1') }
	return false
}

// Ruby it `it "doesn't accept more than the passed number of arguments" do` at line 549.
pub fn ruby_parser_spec_l549_d80_doesn() bool {
	mut parser := parser_number()
	parser.parse(['foo', 'bar'], false) or { return err.msg().contains('exactly 1') }
	return false
}

// Ruby it `it "accepts the passed number of arguments" do` at line 553.
pub fn ruby_parser_spec_l553_d81_accepts() bool {
	mut parser := parser_number()
	parsed := parser.parse(['foo'], false) or { return false }
	return parsed.named.values == ['foo']
}

// Ruby it `it "doesn't accept any arguments with :none" do` at line 557.
pub fn ruby_parser_spec_l557_d82_doesn() bool {
	mut parser := parser_none()
	parser.parse(['foo'], false) or { return err.msg().contains('does not take named arguments') }
	return false
}

// Ruby it `it "accepts no arguments with :none" do` at line 562.
pub fn ruby_parser_spec_l562_d83_accepts() bool {
	mut parser := parser_none()
	parsed := parser.parse([]string{}, false) or { return false }
	return parsed.named.empty()
}

// Ruby it `it "displays the correct error message with no arg types and min" do` at line 566.
pub fn ruby_parser_spec_l566_d84_displays() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		minimum: 2
	}) or { return false }
	parser.parse([]string{}, false) or { return err.msg().contains('at least 2 named arguments') }
	return false
}

// Ruby it `it "displays the correct error message with no arg types and number" do` at line 575.
pub fn ruby_parser_spec_l575_d85_displays() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		number: 2
	}) or { return false }
	parser.parse([]string{}, false) or { return err.msg().contains('exactly 2 named arguments') }
	return false
}

// Ruby it `it "displays the correct error message with no arg types and max" do` at line 584.
pub fn ruby_parser_spec_l584_d86_displays() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		maximum: 1
	}) or { return false }
	parser.parse(['foo', 'bar'], false) or { return err.msg().contains('more than 1 named argument') }
	return false
}

// Ruby it `it "displays the correct error message with an array of strings" do` at line 593.
pub fn ruby_parser_spec_l593_d87_displays() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['on', 'off']
		types_are_choices: true
		number: 1
	}) or { return false }
	parser.parse([]string{}, false) or { return err.msg().contains('exactly 1 subcommand') }
	return false
}

// Ruby it `it "displays the correct error message with an array of symbols" do` at line 602.
pub fn ruby_parser_spec_l602_d88_displays() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['formula', 'cask']
		minimum: 1
	}) or { return false }
	parser.parse([]string{}, false) or { return err.msg().contains('at least 1 formula or cask argument') }
	return false
}

// Ruby it `it "displays the correct error message with an array of symbols and max" do` at line 611.
pub fn ruby_parser_spec_l611_d89_displays() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['formula', 'cask']
		maximum: 1
	}) or { return false }
	parser.parse(['foo', 'bar'], false) or { return err.msg().contains('more than 1 formula or cask argument') }
	return false
}

// Ruby it `it "accepts commands with :command" do` at line 620.
pub fn ruby_parser_spec_l620_d90_accepts() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['command']
	}) or { return false }
	parser.set_allowed_commands(['--prefix', '--version'])
	parsed := parser.parse(['--prefix', '--version'], false) or { return false }
	return parsed.named.values == ['--prefix', '--version']
}

// Ruby it `it "doesn't accept invalid options with :command" do` at line 627.
pub fn ruby_parser_spec_l627_d91_doesn() bool {
	mut parser := brew_cli.new_parser('test')
	parser.configure_named_args(brew_cli.NamedArgumentConfig{
		types: ['command']
	}) or { return false }
	parser.set_allowed_commands(['--prefix', '--version'])
	parser.parse(['--not-a-command'], false) or { return err.msg().contains('--not-a-command') }
	return false
}

// Ruby method `subcommand_parser` at line 636.
pub fn ruby_parser_spec_l636_d92_subcommand_parser() brew_cli.Parser {
	return subcommand_parser()
}

// Ruby it `it "exposes subcommand metadata as named args" do` at line 662.
pub fn ruby_parser_spec_l662_d93_exposes() bool {
	parser := subcommand_parser()
	commands := parser.subcommand_list()
	return parser.named_args_type() == ['install', 'info'] && commands.map(it.name) == [
		'install',
		'info',
	] && commands[1].aliases == ['i'] && commands[1].description == 'Show service information.' && commands[1].usage_banner.contains('`test info` <service>:')
}

// Ruby it `it "combines subcommand usage banners with the main usage banner" do` at line 672.
pub fn ruby_parser_spec_l672_d94_combines() bool {
	text := subcommand_parser().usage_banner_text()
	return text.contains('`test install`:') && text.contains('Show service information.')
}

// Ruby it `it "generates usage-error help for the matched subcommand" do` at line 677.
pub fn ruby_parser_spec_l677_d95_generates() bool {
	help := subcommand_parser().generate_help_text_for(['info', 'foo', '--force'], true)
	return help.contains('Usage: brew test info service:') && help.contains('Show service information.') && help.contains('--json') && help.contains('--global') && !help.contains('--force') && !help.contains('Usage: brew test install')
}

// Ruby it `it "generates usage-error help for the root command when no subcommand matches" do` at line 688.
pub fn ruby_parser_spec_l688_d96_generates() bool {
	help := subcommand_parser().generate_help_text_for(['unknown'], true)
	return help.contains('Usage: brew test [subcommand]') && help.contains('Subcommands:') && help.contains('install') && help.contains('info') && help.contains('--global') && !help.contains('--force') && !help.contains('--json') && !help.contains('Usage: brew test install') && !help.contains('Usage: brew test info')
}

// Ruby it `it "prints root command help for the help switch" do` at line 702.
pub fn ruby_parser_spec_l702_d97_prints() bool {
	mut parser := subcommand_parser()
	parser.parse_with_help_exit(['--help'], false) or {
		help := parser.parse_help(['--help'])
		return err.msg() == 'SystemExit' && help.contains('Subcommands:') && help.contains('--global') && !help.contains('--force') && !help.contains('--json') && !help.contains('Usage: brew test install')
	}
	return false
}

// Ruby it `it "prints matched subcommand help for the help switch" do` at line 709.
pub fn ruby_parser_spec_l709_d98_prints() bool {
	mut parser := subcommand_parser()
	parser.parse_with_help_exit(['install', '--help'], false) or {
		help := parser.parse_help(['install', '--help'])
		return err.msg() == 'SystemExit' && help.contains('Usage: brew test install') && help.contains('--force') && help.contains('--global') && !help.contains('--json') && !help.contains('Subcommands:')
	}
	return false
}

// Ruby it `it "stores the canonical subcommand name" do` at line 716.
pub fn ruby_parser_spec_l716_d99_stores() bool {
	mut parser := subcommand_parser()
	parsed := parser.parse(['i', 'foo', '--json'], false) or { return false }
	command := parsed.flag_value('subcommand') or { return false }
	return command == 'info' && parsed.named.values == ['foo'] && switch_value_is(parsed, 'json', true)
}

// Ruby it `it "rejects multiple positional names when defining a subcommand" do` at line 724.
pub fn ruby_parser_spec_l724_d100_rejects() bool {
	mut parser := brew_cli.new_parser('test')
	parser.add_subcommand_names(['install', 'upgrade'], brew_cli.SubcommandConfig{}) or {
		return err.msg().contains('wrong number of arguments')
	}
	return false
}

// Ruby it `it "uses the default subcommand when one is not passed" do` at line 732.
pub fn ruby_parser_spec_l732_d101_uses() bool {
	mut parser := subcommand_parser()
	parsed := parser.parse(['--force'], false) or { return false }
	command := parsed.flag_value('subcommand') or { return false }
	return command == 'install' && switch_value_is(parsed, 'force', true)
}

// Ruby it `it "validates named args for the matched subcommand" do` at line 739.
pub fn ruby_parser_spec_l739_d102_validates() bool {
	mut parser := subcommand_parser()
	parser.parse(['info'], false) or { return err.msg().contains('at least 1 service argument') }
	return false
}

// Ruby it `it "rejects options from other subcommands" do` at line 744.
pub fn ruby_parser_spec_l744_d103_rejects() bool {
	mut parser := subcommand_parser()
	parser.parse(['info', 'foo', '--force'], false) or {
		return err.msg().contains('`info` subcommand does not accept the `--force` switch')
	}
	return false
}

// Ruby it `it "accepts global options re-declared inside a subcommand on every subcommand", :aggregate_failures do` at line 749.
pub fn ruby_parser_spec_l749_d104_accepts() bool {
	for arguments in [['install', '--verbose'], ['cleanup', '--verbose'], ['cleanup', '-v']] {
		mut parser := parser_with_global_redeclaration() or { return false }
		parsed := parser.parse(arguments, false) or { return false }
		if !switch_value_is(parsed, 'verbose', true) {
			return false
		}
	}
	return true
}

// Ruby it `it "applies option constraints only for the matching subcommand", :aggregate_failures do` at line 768.
pub fn ruby_parser_spec_l768_d105_applies() bool {
	mut first := parser_with_scoped_constraints() or { return false }
	first.parse(['--zap'], false) or {
		if !err.msg().contains('`--zap` cannot be passed without `--cleanup`') {
			return false
		}
	}
	mut second := parser_with_scoped_constraints() or { return false }
	second_args := second.parse(['--cleanup', '--zap'], false) or { return false }
	second_command := second_args.flag_value('subcommand') or { return false }
	if second_command != 'install' {
		return false
	}
	mut third := parser_with_scoped_constraints() or { return false }
	third_args := third.parse(['cleanup', '--zap'], false) or { return false }
	third_command := third_args.flag_value('subcommand') or { return false }
	return third_command == 'cleanup'
}

// Ruby it `it "allows global options on all subcommands" do` at line 790.
pub fn ruby_parser_spec_l790_d106_allows() bool {
	mut parser := subcommand_parser()
	parsed := parser.parse(['info', 'foo', '--global'], false) or { return false }
	command := parsed.flag_value('subcommand') or { return false }
	return command == 'info' && switch_value_is(parsed, 'global', true)
}

// Ruby it `it "applies implied options from subcommand aliases", :aggregate_failures do` at line 797.
pub fn ruby_parser_spec_l797_d107_applies() bool {
	mut parser := brew_cli.new_parser('test')
	parser.add_subcommand('install', brew_cli.SubcommandConfig{
		alias_options: {
			'upgrade': '--upgrade'
		}
	}, configure_alias_install) or { return false }
	parsed := parser.parse(['upgrade', '--force'], false) or { return false }
	commands := parser.subcommand_list()
	command := parsed.flag_value('subcommand') or { return false }
	return commands[0].aliases == ['upgrade'] && command == 'install' && switch_value_is(parsed, 'upgrade', true) && switch_value_is(parsed, 'force', true)
}

// Ruby it `it "deprecates subcommands" do` at line 814.
pub fn ruby_parser_spec_l814_d108_deprecates() bool {
	mut parser := brew_cli.new_parser('test')
	parser.add_subcommand('install', brew_cli.SubcommandConfig{
		deprecated: true
	}, configure_none_subcommand) or { return false }
	parser.parse(['install'], false) or {
		return err.msg().contains('the `install` subcommand') && err.msg().contains('deprecated')
	}
	return false
}

// Ruby it `it "disables subcommands" do` at line 825.
pub fn ruby_parser_spec_l825_d109_disables() bool {
	mut parser := brew_cli.new_parser('test')
	parser.add_subcommand('install', brew_cli.SubcommandConfig{
		disabled: true
	}, configure_none_subcommand) or { return false }
	parser.parse(['install'], false) or {
		return err.msg().contains('the `install` subcommand') && err.msg().contains('disabled')
	}
	return false
}

// Ruby it `it "hides deprecated subcommands from root help" do` at line 836.
pub fn ruby_parser_spec_l836_d110_hides() bool {
	mut parser := brew_cli.new_parser('test')
	parser.set_usage_banner('`test` [<subcommand>]') or { return false }
	parser.add_subcommand('install', brew_cli.SubcommandConfig{
		deprecated: true
	}, configure_none_subcommand) or { return false }
	parser.add_subcommand('info', brew_cli.SubcommandConfig{}, configure_none_subcommand) or {
		return false
	}
	help := parser.generate_help_text()
	return help.contains('info') && !help.contains('install')
}

// Ruby it `it "returns options for a specific subcommand" do` at line 851.
pub fn ruby_parser_spec_l851_d111_returns() bool {
	parser := subcommand_parser()
	install_options := parser.processed_options_for_subcommand('install').map(it.long)
	info_options := parser.processed_options_for_subcommand('info').map(it.long)
	return '--force' in install_options && '--json' !in install_options && '--json' in info_options && '--force' !in info_options
}

// Ruby subject `subject(:parser) do` at line 866.
pub fn ruby_parser_spec_l866_d112_parser() brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['--cask'], brew_cli.OptionConfig{})
	return parser
}

// Ruby it `it "succeeds for developer commands" do` at line 874.
pub fn ruby_parser_spec_l874_d113_succeeds() bool {
	mut parser := ruby_parser_spec_l866_d112_parser()
	parsed := parser.parse(['--cask', 'cask_name'], false) or { return false }
	return switch_value_is(parsed, 'cask', true)
}

// Ruby subject `subject(:parser) do` at line 882.
pub fn ruby_parser_spec_l882_d114_parser() brew_cli.Parser {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['--cask'], brew_cli.OptionConfig{})
	parser.add_switch(['--formula'], brew_cli.OptionConfig{})
	parser.add_conflicts(['--cask', '--formula'])
	return parser
}

// Ruby it `it "throws an error when both defined" do` at line 890.
pub fn ruby_parser_spec_l890_d115_throws() bool {
	mut parser := ruby_parser_spec_l882_d114_parser()
	parser.parse(['--cask', '--formula'], false) or { return err.msg().contains('mutually exclusive') }
	return false
}

// Ruby it `it "doesn't set --formula when not defined" do` at line 898.
pub fn ruby_parser_spec_l898_d116_doesn() bool {
	mut parser := brew_cli.new_parser('test')
	parsed := parser.parse([]string{}, false) or { return false }
	if _ := parsed.switch_value('formula') {
		return false
	}
	return true
}

// Ruby it `it "doesn't set --formula when defined" do` at line 904.
pub fn ruby_parser_spec_l904_d117_doesn() bool {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['--formula'], brew_cli.OptionConfig{})
	parsed := parser.parse([]string{}, false) or { return false }
	return switch_value_is(parsed, 'formula', false)
}

// Ruby it `it "does not set --formula to true when --cask" do` at line 912.
pub fn ruby_parser_spec_l912_d118_does() bool {
	mut parser := brew_cli.new_parser('test')
	parser.add_switch(['--cask'], brew_cli.OptionConfig{})
	parsed := parser.parse([]string{}, false) or { return false }
	if _ := parsed.switch_value('formula') {
		return false
	}
	return true
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require_relative "../../cli/parser"
// 5:
// 6: RSpec.describe Homebrew::CLI::Parser do
// 7:   before { stub_const("Cmd", Class.new(Homebrew::AbstractCommand)) }
// 8:
// 9:   describe "test switch options" do
// 10:     subject(:parser) do
// 11:       described_class.new(Cmd) do
// 12:         switch "--more-verbose", description: "Flag for higher verbosity"
// 13:         switch "--pry", env: :pry
// 14:         switch "--foo", env: :foo
// 15:         switch "--bar", env: :bar
// 16:         switch "--hidden", hidden: true
// 17:       end
// 18:     end
// 19:
// 20:     before do
// 21:       allow(Homebrew::EnvConfig).to receive(:pry?).and_return(true)
// 22:       allow(ENV).to receive(:fetch).and_call_original
// 23:       allow(ENV).to receive(:fetch).with("HOMEBREW_FOO", nil).and_return("")
// 24:       allow(ENV).to receive(:fetch).with("HOMEBREW_BAR", nil).and_return("1")
// 25:     end
// 26:
// 27:     context "when using binary options" do
// 28:       subject(:parser) do
// 29:         described_class.new(Cmd) do
// 30:           switch "--[no-]positive"
// 31:         end
// 32:       end
// 33:
// 34:       it "does not create no_positive?" do
// 35:         args = parser.parse(["--no-positive"])
// 36:         expect { args.no_positive? }.to raise_error(NoMethodError)
// 37:       end
// 38:
// 39:       it "sets the positive name to false if the negative switch is passed" do
// 40:         args = parser.parse(["--no-positive"])
// 41:         expect(args).not_to be_positive
// 42:       end
// 43:
// 44:       it "sets the positive name to true if the positive switch is passed" do
// 45:         args = parser.parse(["--positive"])
// 46:         expect(args).to be_positive
// 47:       end
// 48:
// 49:       it "does not set the positive name if the positive switch is not passed" do
// 50:         args = parser.parse([])
// 51:         expect(args.positive?).to be_nil
// 52:       end
// 53:     end
// 54:
// 55:     context "when using negative options" do
// 56:       subject(:parser) do
// 57:         described_class.new(Cmd) do
// 58:           switch "--no-positive"
// 59:         end
// 60:       end
// 61:
// 62:       it "does not set the positive name" do
// 63:         args = parser.parse(["--no-positive"])
// 64:         expect { args.positive? }.to raise_error(NoMethodError)
// 65:       end
// 66:
// 67:       it "fails when using the positive name" do
// 68:         expect do
// 69:           parser.parse(["--positive"])
// 70:         end.to raise_error(/invalid option/)
// 71:       end
// 72:
// 73:       it "sets the negative name to true if the negative switch is passed" do
// 74:         args = parser.parse(["--no-positive"])
// 75:         expect(args.no_positive?).to be true
// 76:       end
// 77:     end
// 78:
// 79:     context "when `ignore_invalid_options` is true" do
// 80:       it "passes through invalid options" do
// 81:         args = parser.parse(["-v", "named-arg", "--not-a-valid-option"], ignore_invalid_options: true)
// 82:         expect(args.remaining).to eq ["named-arg", "--not-a-valid-option"]
// 83:         expect(args.named).to be_empty
// 84:       end
// 85:     end
// 86:
// 87:     it "flattens arguments after `--` into remaining" do
// 88:       args = parser.parse(["-v", "--", "foo", "bar"])
// 89:       expect(args.remaining).to eq ["--", "foo", "bar"]
// 90:     end
// 91:
// 92:     it "parses short option" do
// 93:       args = parser.parse(["-v"])
// 94:       expect(args).to be_verbose
// 95:     end
// 96:
// 97:     it "parses a single valid option" do
// 98:       args = parser.parse(["--verbose"])
// 99:       expect(args).to be_verbose
// 100:     end
// 101:
// 102:     it "parses a valid option along with few unnamed args" do
// 103:       args = parser.parse(%w[--verbose unnamed args])
// 104:       expect(args).to be_verbose
// 105:       expect(args.named).to eq %w[unnamed args]
// 106:     end
// 107:
// 108:     it "parses a single option and checks other options to be false" do
// 109:       args = parser.parse(["--verbose"])
// 110:       expect(args).to be_verbose
// 111:       expect(args.more_verbose?).to be false
// 112:     end
// 113:
// 114:     it "sets the correct value for a hidden switch" do
// 115:       args = parser.parse([])
// 116:       expect(args.hidden?).to be false
// 117:     end
// 118:
// 119:     it "raises an exception and outputs help text when an invalid option is passed" do
// 120:       expect { parser.parse(["--random"]) }.to raise_error(OptionParser::InvalidOption, /--random/)
// 121:                                            .and output(/Usage: brew/).to_stderr
// 122:     end
// 123:
// 124:     it "maps environment var to an option" do
// 125:       args = parser.parse([])
// 126:       expect(args.pry?).to be true
// 127:       expect(args.foo?).to be false
// 128:       expect(args.bar?).to be true
// 129:     end
// 130:   end
// 131:
// 132:   describe "ask environment variable precedence" do
// 133:     subject(:parser) do
// 134:       described_class.new(Cmd) do
// 135:         switch "--no-ask", "--yes", "-y", env: :no_ask
// 136:         switch "--ask",    env: :ask
// 137:         conflicts "--ask", "--no-ask"
// 138:       end
// 139:     end
// 140:
// 141:     it "lets HOMEBREW_NO_ASK override default ask mode" do
// 142:       with_env(HOMEBREW_NO_ASK: "1") do
// 143:         expect(parser.parse([]).no_ask?).to be(true)
// 144:       end
// 145:     end
// 146:
// 147:     it "lets --ask override HOMEBREW_NO_ASK" do
// 148:       with_env(HOMEBREW_NO_ASK: "1") do
// 149:         args = parser.parse(["--ask"])
// 150:         expect(args.ask?).to be(true)
// 151:         expect(args.no_ask?).to be(false)
// 152:       end
// 153:     end
// 154:
// 155:     it "lets --no-ask, --yes and -y override default ask mode" do
// 156:       expect(parser.parse(["--no-ask"]).no_ask?).to be(true)
// 157:       expect(described_class.new(Cmd) do
// 158:         switch "--no-ask", "--yes", "-y", env: :no_ask
// 159:       end.parse(["--yes"]).no_ask?).to be(true)
// 160:       expect(described_class.new(Cmd) do
// 161:         switch "--no-ask", "--yes", "-y", env: :no_ask
// 162:       end.parse(["-y"]).no_ask?).to be(true)
// 163:     end
// 164:   end
// 165:
// 166:   describe "describe environment variable precedence" do
// 167:     subject(:parser) do
// 168:       described_class.new(Cmd) do
// 169:         switch "--no-describe", env: :bundle_no_describe
// 170:         switch "--describe",    env: :bundle_describe
// 171:         conflicts "--describe", "--no-describe"
// 172:       end
// 173:     end
// 174:
// 175:     it "lets --describe override HOMEBREW_BUNDLE_NO_DESCRIBE" do
// 176:       with_env(HOMEBREW_BUNDLE_NO_DESCRIBE: "1") do
// 177:         args = parser.parse(["--describe"])
// 178:         expect(args.describe?).to be(true)
// 179:         expect(args.no_describe?).to be(false)
// 180:       end
// 181:     end
// 182:   end
// 183:
// 184:   describe "test long flag options" do
// 185:     subject(:parser) do
// 186:       described_class.new(Cmd) do
// 187:         flag        "--filename=", description: "Name of the file"
// 188:         comma_array "--files",     description: "Comma-separated filenames"
// 189:         flag        "--hidden=",      hidden: true
// 190:         comma_array "--hidden-array", hidden: true
// 191:       end
// 192:     end
// 193:
// 194:     it "parses a long flag option with its argument" do
// 195:       args = parser.parse(["--filename=random.txt"])
// 196:       expect(args.filename).to eq "random.txt"
// 197:     end
// 198:
// 199:     it "raises an exception when a flag's required value is not passed" do
// 200:       expect { parser.parse(["--filename"]) }.to raise_error(OptionParser::MissingArgument, /--filename/)
// 201:     end
// 202:
// 203:     it "parses a comma array flag option" do
// 204:       args = parser.parse(["--files=random1.txt,random2.txt"])
// 205:       expect(args.files).to eq %w[random1.txt random2.txt]
// 206:     end
// 207:
// 208:     it "sets the correct value for hidden flags" do
// 209:       args = parser.parse(["--hidden=foo", "--hidden-array=bar,baz"])
// 210:       expect(args.hidden).to eq "foo"
// 211:       expect(args.hidden_array).to eq %w[bar baz]
// 212:     end
// 213:   end
// 214:
// 215:   describe "test short flag options" do
// 216:     subject(:parser) do
// 217:       described_class.new(Cmd) do
// 218:         flag "-f", "--filename=", description: "Name of the file"
// 219:       end
// 220:     end
// 221:
// 222:     it "parses a short flag option with its argument" do
// 223:       args = parser.parse(["--filename=random.txt"])
// 224:       expect(args.filename).to eq "random.txt"
// 225:       expect(args.f).to eq "random.txt"
// 226:     end
// 227:   end
// 228:
// 229:   describe "test constraints for flag options" do
// 230:     subject(:parser) do
// 231:       described_class.new(Cmd) do
// 232:         flag      "--flag1="
// 233:         flag      "--flag2=", depends_on: "--flag1="
// 234:         flag      "--flag3="
// 235:
// 236:         conflicts "--flag1", "--flag3"
// 237:       end
// 238:     end
// 239:
// 240:     it "raises exception on depends_on constraint violation" do
// 241:       expect { parser.parse(["--flag2=flag2"]) }.to raise_error(Homebrew::CLI::OptionConstraintError)
// 242:     end
// 243:
// 244:     it "raises exception for conflict violation" do
// 245:       expect { parser.parse(["--flag1=flag1", "--flag3=flag3"]) }.to raise_error(Homebrew::CLI::OptionConflictError)
// 246:     end
// 247:
// 248:     it "raises no exception" do
// 249:       args = parser.parse(["--flag1=flag1", "--flag2=flag2"])
// 250:       expect(args.flag1).to eq "flag1"
// 251:       expect(args.flag2).to eq "flag2"
// 252:     end
// 253:
// 254:     it "raises no exception for optional dependency" do
// 255:       args = parser.parse(["--flag3=flag3"])
// 256:       expect(args.flag3).to eq "flag3"
// 257:     end
// 258:   end
// 259:
// 260:   describe "test invalid constraints" do
// 261:     subject(:parser) do
// 262:       described_class.new(Cmd) do
// 263:         flag      "--flag1="
// 264:         flag      "--flag2=", depends_on: "--flag1="
// 265:
// 266:         conflicts "--flag1", "--flag2"
// 267:       end
// 268:     end
// 269:
// 270:     it "raises exception due to invalid constraints" do
// 271:       expect { parser.parse([]) }.to raise_error(Homebrew::CLI::InvalidConstraintError)
// 272:     end
// 273:   end
// 274:
// 275:   describe "test constraints for switch options" do
// 276:     subject(:parser) do
// 277:       described_class.new(Cmd) do
// 278:         switch      "-a", "--switch-a", env: "switch_a"
// 279:         switch      "-b", "--switch-b", env: "switch_b"
// 280:         switch      "--switch-c", depends_on: "--switch-a"
// 281:
// 282:         conflicts "--switch-a", "--switch-b"
// 283:       end
// 284:     end
// 285:
// 286:     it "raises exception on depends_on constraint violation" do
// 287:       expect { parser.parse(["--switch-c"]) }.to raise_error(Homebrew::CLI::OptionConstraintError)
// 288:     end
// 289:
// 290:     it "raises exception for conflict violation" do
// 291:       expect { parser.parse(["-ab"]) }.to raise_error(Homebrew::CLI::OptionConflictError)
// 292:     end
// 293:
// 294:     it "raises no exception" do
// 295:       args = parser.parse(["--switch-a", "--switch-c"])
// 296:       expect(args.switch_a?).to be true
// 297:       expect(args.switch_c?).to be true
// 298:     end
// 299:
// 300:     it "raises no exception for optional dependency" do
// 301:       args = parser.parse(["--switch-b"])
// 302:       expect(args.switch_b?).to be true
// 303:     end
// 304:
// 305:     it "prioritizes cli arguments over env vars when they conflict" do
// 306:       without_partial_double_verification do
// 307:         allow(Homebrew::EnvConfig).to receive_messages(switch_a?: true, switch_b?: false)
// 308:       end
// 309:       args = parser.parse(["--switch-b"])
// 310:       expect(args.switch_a?).to be false
// 311:       expect(args).to be_switch_b
// 312:     end
// 313:
// 314:     it "raises an exception on constraint violation when both are env vars" do
// 315:       without_partial_double_verification do
// 316:         allow(Homebrew::EnvConfig).to receive_messages(switch_a?: true, switch_b?: true)
// 317:       end
// 318:       expect { parser.parse([]) }.to raise_error(Homebrew::CLI::OptionConflictError)
// 319:     end
// 320:   end
// 321:
// 322:   describe "test immutability of args" do
// 323:     subject(:parser) do
// 324:       described_class.new(Cmd) do
// 325:         switch "-a", "--switch-a"
// 326:         switch "-b", "--switch-b"
// 327:       end
// 328:     end
// 329:
// 330:     it "raises exception when arguments were already parsed" do
// 331:       parser.parse(["--switch-a"])
// 332:       expect { parser.parse(["--switch-b"]) }.to raise_error(RuntimeError, /Arguments were already parsed!/)
// 333:     end
// 334:   end
// 335:
// 336:   describe "test inferrability of args" do
// 337:     subject(:parser) do
// 338:       described_class.new(Cmd) do
// 339:         switch "--switch-a"
// 340:         switch "--switch-b"
// 341:         switch "--foo-switch"
// 342:         flag "--flag-foo="
// 343:         comma_array "--comma-array-foo"
// 344:       end
// 345:     end
// 346:
// 347:     it "parses a valid switch that uses `_` instead of `-`" do
// 348:       args = parser.parse(["--switch_a"])
// 349:       expect(args).to be_switch_a
// 350:     end
// 351:
// 352:     it "parses a valid flag that uses `_` instead of `-`" do
// 353:       args = parser.parse(["--flag_foo=foo.txt"])
// 354:       expect(args.flag_foo).to eq "foo.txt"
// 355:     end
// 356:
// 357:     it "parses a valid comma_array that uses `_` instead of `-`" do
// 358:       args = parser.parse(["--comma_array_foo=foo.txt,bar.txt"])
// 359:       expect(args.comma_array_foo).to eq %w[foo.txt bar.txt]
// 360:     end
// 361:
// 362:     it "raises an error when option is ambiguous" do
// 363:       expect { parser.parse(["--switch"]) }.to raise_error(RuntimeError, /ambiguous option: --switch/)
// 364:     end
// 365:
// 366:     it "inferrs the option from an abbreviated name" do
// 367:       args = parser.parse(["--foo"])
// 368:       expect(args).to be_foo_switch
// 369:     end
// 370:   end
// 371:
// 372:   describe "test argv extensions" do
// 373:     subject(:parser) do
// 374:       described_class.new(Cmd) do
// 375:         switch "--foo"
// 376:         flag   "--bar"
// 377:         switch "-s"
// 378:       end
// 379:     end
// 380:
// 381:     it "#options_only" do
// 382:       args = parser.parse(["--foo", "--bar=value", "-v", "-s", "a", "b", "cdefg"])
// 383:       expect(args.options_only).to eq %w[--verbose --foo --bar=value -s]
// 384:     end
// 385:
// 386:     it "#flags_only" do
// 387:       args = parser.parse(["--foo", "--bar=value", "-v", "-s", "a", "b", "cdefg"])
// 388:       expect(args.flags_only).to eq %w[--verbose --foo --bar=value]
// 389:     end
// 390:
// 391:     it "#named returns an array of non-option arguments" do
// 392:       args = parser.parse(["foo", "-v", "-s"])
// 393:       expect(args.named).to eq ["foo"]
// 394:     end
// 395:
// 396:     it "#named returns an empty array when there are no named arguments" do
// 397:       args = parser.parse([])
// 398:       expect(args.named).to be_empty
// 399:     end
// 400:   end
// 401:
// 402:   describe "usage banner generation" do
// 403:     it "includes `[options]` if more than two non-global options are available" do
// 404:       parser = described_class.new(Cmd) do
// 405:         switch "--foo"
// 406:         switch "--baz"
// 407:         switch "--bar"
// 408:       end
// 409:       expect(parser.generate_help_text).to include("[options]")
// 410:     end
// 411:
// 412:     it "includes individual options if less than two non-global options are available" do
// 413:       parser = described_class.new(Cmd) do
// 414:         switch "--foo"
// 415:         switch "--bar"
// 416:       end
// 417:       expect(parser.generate_help_text).to include("[--foo] [--bar]")
// 418:     end
// 419:
// 420:     it "formats flags correctly when less than two non-global options are available" do
// 421:       parser = described_class.new(Cmd) do
// 422:         flag "--foo"
// 423:         flag "--bar="
// 424:       end
// 425:       expect(parser.generate_help_text).to include("[--foo] [--bar=]")
// 426:     end
// 427:
// 428:     it "formats comma arrays correctly when less than two non-global options are available" do
// 429:       parser = described_class.new(Cmd) do
// 430:         comma_array "--foo"
// 431:       end
// 432:       expect(parser.generate_help_text).to include("[--foo=]")
// 433:     end
// 434:
// 435:     it "does not include hidden options" do
// 436:       parser = described_class.new(Cmd) do
// 437:         switch "--foo", hidden: true
// 438:       end
// 439:       expect(parser.generate_help_text).not_to include("[--foo]")
// 440:     end
// 441:
// 442:     it "doesn't include `[options]` if non non-global options are available" do
// 443:       parser = described_class.new(Cmd)
// 444:       expect(parser.generate_help_text).not_to include("[options]")
// 445:     end
// 446:
// 447:     it "includes a description" do
// 448:       parser = described_class.new(Cmd) do
// 449:         description <<~EOS
// 450:           This command does something
// 451:         EOS
// 452:       end
// 453:       expect(parser.generate_help_text).to include("This command does something")
// 454:     end
// 455:
// 456:     it "allows the usage banner to be overridden" do
// 457:       parser = described_class.new(Cmd) do
// 458:         usage_banner "`test` [foo] <bar>"
// 459:       end
// 460:       expect(parser.generate_help_text).to include("test [foo] bar")
// 461:     end
// 462:
// 463:     it "allows a usage banner and a description to be overridden" do
// 464:       parser = described_class.new(Cmd) do
// 465:         usage_banner "`test` [foo] <bar>"
// 466:         description <<~EOS
// 467:           This command does something
// 468:         EOS
// 469:       end
// 470:       expect(parser.generate_help_text).to include("test [foo] bar")
// 471:       expect(parser.generate_help_text).to include("This command does something")
// 472:     end
// 473:
// 474:     it "shows the correct usage for no named argument" do
// 475:       parser = described_class.new(Cmd) do
// 476:         named_args :none
// 477:       end
// 478:       expect(parser.generate_help_text).to match(/^Usage: [^\[]+$/s)
// 479:     end
// 480:
// 481:     it "shows the correct usage for a single typed argument" do
// 482:       parser = described_class.new(Cmd) do
// 483:         named_args :formula, number: 1
// 484:       end
// 485:       expect(parser.generate_help_text).to match(/^Usage: .* formula$/s)
// 486:     end
// 487:
// 488:     it "shows the correct usage for a subcommand argument with a maximum" do
// 489:       parser = described_class.new(Cmd) do
// 490:         named_args %w[off on], max: 1
// 491:       end
// 492:       expect(parser.generate_help_text).to match(/^Usage: .* \[subcommand\]$/s)
// 493:     end
// 494:
// 495:     it "shows the correct usage for multiple typed argument with no maximum or minimum" do
// 496:       parser = described_class.new(Cmd) do
// 497:         named_args [:tap, :command]
// 498:       end
// 499:       expect(parser.generate_help_text).to match(/^Usage: .* \[tap|command ...\]$/s)
// 500:     end
// 501:
// 502:     it "shows the correct usage for a subcommand argument with a minimum of 1" do
// 503:       parser = described_class.new(Cmd) do
// 504:         named_args :installed_formula, min: 1
// 505:       end
// 506:       expect(parser.generate_help_text).to match(/^Usage: .* installed_formula \[...\]$/s)
// 507:     end
// 508:
// 509:     it "shows the correct usage for a subcommand argument with a minimum greater than 1" do
// 510:       parser = described_class.new(Cmd) do
// 511:         named_args :installed_formula, min: 2
// 512:       end
// 513:       expect(parser.generate_help_text).to match(/^Usage: .* installed_formula ...$/s)
// 514:     end
// 515:   end
// 516:
// 517:   describe "named_args" do
// 518:     let(:parser_none) do
// 519:       described_class.new(Cmd) do
// 520:         named_args :none
// 521:       end
// 522:     end
// 523:     let(:parser_number) do
// 524:       described_class.new(Cmd) do
// 525:         named_args number: 1
// 526:       end
// 527:     end
// 528:
// 529:     it "doesn't allow :none passed with a number" do
// 530:       expect do
// 531:         described_class.new(Cmd) do
// 532:           named_args :none, number: 1
// 533:         end
// 534:       end.to raise_error(ArgumentError, /Do not specify both `number`, `min` or `max` with `named_args :none`/)
// 535:     end
// 536:
// 537:     it "doesn't allow number and min" do
// 538:       expect do
// 539:         described_class.new(Cmd) do
// 540:           named_args number: 1, min: 1
// 541:         end
// 542:       end.to raise_error(ArgumentError, /Do not specify both `number` and `min` or `max`/)
// 543:     end
// 544:
// 545:     it "doesn't accept fewer than the passed number of arguments" do
// 546:       expect { parser_number.parse([]) }.to raise_error(Homebrew::CLI::NumberOfNamedArgumentsError)
// 547:     end
// 548:
// 549:     it "doesn't accept more than the passed number of arguments" do
// 550:       expect { parser_number.parse(["foo", "bar"]) }.to raise_error(Homebrew::CLI::NumberOfNamedArgumentsError)
// 551:     end
// 552:
// 553:     it "accepts the passed number of arguments" do
// 554:       expect { parser_number.parse(["foo"]) }.not_to raise_error
// 555:     end
// 556:
// 557:     it "doesn't accept any arguments with :none" do
// 558:       expect { parser_none.parse(["foo"]) }
// 559:         .to raise_error(Homebrew::CLI::MaxNamedArgumentsError, /This command does not take named arguments/)
// 560:     end
// 561:
// 562:     it "accepts no arguments with :none" do
// 563:       expect { parser_none.parse([]) }.not_to raise_error
// 564:     end
// 565:
// 566:     it "displays the correct error message with no arg types and min" do
// 567:       parser = described_class.new(Cmd) do
// 568:         named_args min: 2
// 569:       end
// 570:       expect { parser.parse([]) }.to raise_error(
// 571:         Homebrew::CLI::MinNamedArgumentsError, /This command requires at least 2 named arguments/
// 572:       )
// 573:     end
// 574:
// 575:     it "displays the correct error message with no arg types and number" do
// 576:       parser = described_class.new(Cmd) do
// 577:         named_args number: 2
// 578:       end
// 579:       expect { parser.parse([]) }.to raise_error(
// 580:         Homebrew::CLI::NumberOfNamedArgumentsError, /This command requires exactly 2 named arguments/
// 581:       )
// 582:     end
// 583:
// 584:     it "displays the correct error message with no arg types and max" do
// 585:       parser = described_class.new(Cmd) do
// 586:         named_args max: 1
// 587:       end
// 588:       expect { parser.parse(%w[foo bar]) }.to raise_error(
// 589:         Homebrew::CLI::MaxNamedArgumentsError, /This command does not take more than 1 named argument/
// 590:       )
// 591:     end
// 592:
// 593:     it "displays the correct error message with an array of strings" do
// 594:       parser = described_class.new(Cmd) do
// 595:         named_args %w[on off], number: 1
// 596:       end
// 597:       expect { parser.parse([]) }.to raise_error(
// 598:         Homebrew::CLI::NumberOfNamedArgumentsError, /This command requires exactly 1 subcommand/
// 599:       )
// 600:     end
// 601:
// 602:     it "displays the correct error message with an array of symbols" do
// 603:       parser = described_class.new(Cmd) do
// 604:         named_args [:formula, :cask], min: 1
// 605:       end
// 606:       expect { parser.parse([]) }.to raise_error(
// 607:         Homebrew::CLI::MinNamedArgumentsError, /This command requires at least 1 formula or cask argument/
// 608:       )
// 609:     end
// 610:
// 611:     it "displays the correct error message with an array of symbols and max" do
// 612:       parser = described_class.new(Cmd) do
// 613:         named_args [:formula, :cask], max: 1
// 614:       end
// 615:       expect { parser.parse(%w[foo bar]) }.to raise_error(
// 616:         Homebrew::CLI::MaxNamedArgumentsError, /This command does not take more than 1 formula or cask argument/
// 617:       )
// 618:     end
// 619:
// 620:     it "accepts commands with :command" do
// 621:       parser = described_class.new(Cmd) do
// 622:         named_args :command
// 623:       end
// 624:       expect { parser.parse(["--prefix", "--version"]) }.not_to raise_error
// 625:     end
// 626:
// 627:     it "doesn't accept invalid options with :command" do
// 628:       parser = described_class.new(Cmd) do
// 629:         named_args :command
// 630:       end
// 631:       expect { parser.parse(["--not-a-command"]) }.to raise_error(OptionParser::InvalidOption, /--not-a-command/)
// 632:     end
// 633:   end
// 634:
// 635:   describe "subcommands" do
// 636:     def subcommand_parser
// 637:       Homebrew::CLI::Parser.new(Cmd) do
// 638:         usage_banner "`test` [<subcommand>]"
// 639:         description "Test command."
// 640:         switch "--global"
// 641:
// 642:         subcommand "install", default: true do
// 643:           usage_banner <<~EOS
// 644:             `test install`:
// 645:             Install dependencies.
// 646:           EOS
// 647:           switch "--force"
// 648:           named_args :none
// 649:         end
// 650:
// 651:         subcommand "info", aliases: ["i"] do
// 652:           usage_banner <<~EOS
// 653:             `test info` <service>:
// 654:             Show service information.
// 655:           EOS
// 656:           switch "--json"
// 657:           named_args :service, min: 1
// 658:         end
// 659:       end
// 660:     end
// 661:
// 662:     it "exposes subcommand metadata as named args" do
// 663:       parser = subcommand_parser
// 664:
// 665:       expect(parser.named_args_type).to eq(%w[install info])
// 666:       expect(parser.subcommands.map(&:name)).to eq(%w[install info])
// 667:       expect(parser.subcommands.last.aliases).to eq(["i"])
// 668:       expect(parser.subcommands.last.description).to eq("Show service information.")
// 669:       expect(parser.subcommands.last.usage_banner).to include("`test info` <service>:")
// 670:     end
// 671:
// 672:     it "combines subcommand usage banners with the main usage banner" do
// 673:       expect(subcommand_parser.usage_banner_text).to include("`test install`:")
// 674:       expect(subcommand_parser.usage_banner_text).to include("Show service information.")
// 675:     end
// 676:
// 677:     it "generates usage-error help for the matched subcommand" do
// 678:       help_text = subcommand_parser.generate_help_text(remaining_args: %w[info foo --force])
// 679:
// 680:       expect(help_text).to include("Usage: brew test info service:")
// 681:       expect(help_text).to include("Show service information.")
// 682:       expect(help_text).to include("--json")
// 683:       expect(help_text).to include("--global")
// 684:       expect(help_text).not_to include("--force")
// 685:       expect(help_text).not_to include("Usage: brew test install")
// 686:     end
// 687:
// 688:     it "generates usage-error help for the root command when no subcommand matches" do
// 689:       help_text = subcommand_parser.generate_help_text(remaining_args: ["unknown"])
// 690:
// 691:       expect(help_text).to include("Usage: brew test [subcommand]")
// 692:       expect(help_text).to include("Subcommands:")
// 693:       expect(help_text).to include("install")
// 694:       expect(help_text).to include("info")
// 695:       expect(help_text).to include("--global")
// 696:       expect(help_text).not_to include("--force")
// 697:       expect(help_text).not_to include("--json")
// 698:       expect(help_text).not_to include("Usage: brew test install")
// 699:       expect(help_text).not_to include("Usage: brew test info")
// 700:     end
// 701:
// 702:     it "prints root command help for the help switch" do
// 703:       expect { subcommand_parser.parse(["--help"]) }
// 704:         .to output(/\A(?=.*Subcommands:)(?=.*--global)(?!.*--force)(?!.*--json)(?!.*Usage: brew test install)/m)
// 705:         .to_stdout
// 706:         .and raise_error(SystemExit)
// 707:     end
// 708:
// 709:     it "prints matched subcommand help for the help switch" do
// 710:       expect { subcommand_parser.parse(%w[install --help]) }
// 711:         .to output(/\A(?=.*Usage: brew test install)(?=.*--force)(?=.*--global)(?!.*--json)(?!.*Subcommands:)/m)
// 712:         .to_stdout
// 713:         .and raise_error(SystemExit)
// 714:     end
// 715:
// 716:     it "stores the canonical subcommand name" do
// 717:       args = subcommand_parser.parse(%w[i foo --json])
// 718:
// 719:       expect(args.subcommand).to eq("info")
// 720:       expect(args.named).to eq(["foo"])
// 721:       expect(args.json?).to be(true)
// 722:     end
// 723:
// 724:     it "rejects multiple positional names when defining a subcommand" do
// 725:       expect do
// 726:         described_class.new(Cmd) do
// 727:           subcommand "install", "upgrade"
// 728:         end
// 729:       end.to raise_error(ArgumentError, /wrong number of arguments/)
// 730:     end
// 731:
// 732:     it "uses the default subcommand when one is not passed" do
// 733:       args = subcommand_parser.parse(["--force"])
// 734:
// 735:       expect(args.subcommand).to eq("install")
// 736:       expect(args.force?).to be(true)
// 737:     end
// 738:
// 739:     it "validates named args for the matched subcommand" do
// 740:       expect { subcommand_parser.parse(["info"]) }
// 741:         .to raise_error(Homebrew::CLI::MinNamedArgumentsError, /at least 1 service argument/)
// 742:     end
// 743:
// 744:     it "rejects options from other subcommands" do
// 745:       expect { subcommand_parser.parse(%w[info foo --force]) }
// 746:         .to raise_error(UsageError, /`info` subcommand does not accept the `--force` switch/)
// 747:     end
// 748:
// 749:     it "accepts global options re-declared inside a subcommand on every subcommand", :aggregate_failures do
// 750:       parser = lambda do
// 751:         described_class.new(Cmd) do
// 752:           subcommand "install", default: true do
// 753:             switch "-v", "--verbose", description: "Print output from commands as they are run."
// 754:             named_args :none
// 755:           end
// 756:
// 757:           subcommand "cleanup" do
// 758:             named_args :none
// 759:           end
// 760:         end
// 761:       end
// 762:
// 763:       expect(parser.call.parse(%w[install --verbose]).verbose?).to be(true)
// 764:       expect(parser.call.parse(%w[cleanup --verbose]).verbose?).to be(true)
// 765:       expect(parser.call.parse(%w[cleanup -v]).verbose?).to be(true)
// 766:     end
// 767:
// 768:     it "applies option constraints only for the matching subcommand", :aggregate_failures do
// 769:       parser = lambda do
// 770:         described_class.new(Cmd) do
// 771:           subcommand "install", default: true do
// 772:             switch "--cleanup"
// 773:             switch "--zap", depends_on: "--cleanup"
// 774:             named_args :none
// 775:           end
// 776:
// 777:           subcommand "cleanup" do
// 778:             switch "--zap"
// 779:             named_args :none
// 780:           end
// 781:         end
// 782:       end
// 783:
// 784:       expect { parser.call.parse(["--zap"]) }
// 785:         .to raise_error(Homebrew::CLI::OptionConstraintError, /`--zap` cannot be passed without `--cleanup`/)
// 786:       expect(parser.call.parse(%w[--cleanup --zap]).subcommand).to eq("install")
// 787:       expect(parser.call.parse(%w[cleanup --zap]).subcommand).to eq("cleanup")
// 788:     end
// 789:
// 790:     it "allows global options on all subcommands" do
// 791:       args = subcommand_parser.parse(%w[info foo --global])
// 792:
// 793:       expect(args.subcommand).to eq("info")
// 794:       expect(args.global?).to be(true)
// 795:     end
// 796:
// 797:     it "applies implied options from subcommand aliases", :aggregate_failures do
// 798:       parser = described_class.new(Cmd) do
// 799:         subcommand "install", alias_options: { "upgrade" => "--upgrade" } do
// 800:           switch "--upgrade"
// 801:           switch "--force"
// 802:           named_args :none
// 803:         end
// 804:       end
// 805:
// 806:       args = parser.parse(%w[upgrade --force])
// 807:
// 808:       expect(parser.subcommands.first.aliases).to eq(["upgrade"])
// 809:       expect(args.subcommand).to eq("install")
// 810:       expect(args.upgrade?).to be(true)
// 811:       expect(args.force?).to be(true)
// 812:     end
// 813:
// 814:     it "deprecates subcommands" do
// 815:       parser = described_class.new(Cmd) do
// 816:         subcommand "install", odeprecated: true do
// 817:           named_args :none
// 818:         end
// 819:       end
// 820:
// 821:       expect { parser.parse(["install"]) }
// 822:         .to raise_error(MethodDeprecatedError, /the `install` subcommand.*deprecated/)
// 823:     end
// 824:
// 825:     it "disables subcommands" do
// 826:       parser = described_class.new(Cmd) do
// 827:         subcommand "install", odisabled: true do
// 828:           named_args :none
// 829:         end
// 830:       end
// 831:
// 832:       expect { parser.parse(["install"]) }
// 833:         .to raise_error(MethodDeprecatedError, /the `install` subcommand.*disabled/)
// 834:     end
// 835:
// 836:     it "hides deprecated subcommands from root help" do
// 837:       parser = described_class.new(Cmd) do
// 838:         usage_banner "`test` [<subcommand>]"
// 839:         subcommand "install", odeprecated: true do
// 840:           named_args :none
// 841:         end
// 842:         subcommand "info" do
// 843:           named_args :none
// 844:         end
// 845:       end
// 846:
// 847:       expect(parser.generate_help_text).to include("info")
// 848:       expect(parser.generate_help_text).not_to include("install")
// 849:     end
// 850:
// 851:     it "returns options for a specific subcommand" do
// 852:       parser = subcommand_parser
// 853:
// 854:       install_options = parser.processed_options_for_subcommand("install").map { |_, long| long }
// 855:       info_options = parser.processed_options_for_subcommand("info").map { |_, long| long }
// 856:
// 857:       expect(install_options).to include("--force")
// 858:       expect(install_options).not_to include("--json")
// 859:       expect(info_options).to include("--json")
// 860:       expect(info_options).not_to include("--force")
// 861:     end
// 862:   end
// 863:
// 864:   describe "--cask on linux", :needs_linux do
// 865:     context "without --formula switch" do
// 866:       subject(:parser) do
// 867:         described_class.new(Cmd) do
// 868:           switch "--cask"
// 869:         end
// 870:       end
// 871:
// 872:       # Developers want to be able to use `audit` and `bump`
// 873:       # commands for formulae and casks on Linux.
// 874:       it "succeeds for developer commands" do
// 875:         require "dev-cmd/cat"
// 876:         args = Homebrew::DevCmd::Cat.new(["--cask", "cask_name"]).args
// 877:         expect(args.cask?).to be(true)
// 878:       end
// 879:     end
// 880:
// 881:     context "with conflicting --formula switch" do
// 882:       subject(:parser) do
// 883:         described_class.new(Cmd) do
// 884:           switch "--cask"
// 885:           switch "--formula"
// 886:           conflicts "--cask", "--formula"
// 887:         end
// 888:       end
// 889:
// 890:       it "throws an error when both defined" do
// 891:         expect { parser.parse(["--cask", "--formula"]) }
// 892:           .to raise_exception Homebrew::CLI::OptionConflictError
// 893:       end
// 894:     end
// 895:   end
// 896:
// 897:   describe "--formula on linux", :needs_linux do
// 898:     it "doesn't set --formula when not defined" do
// 899:       parser = described_class.new(Cmd)
// 900:       args = parser.parse([])
// 901:       expect(args.respond_to?(:formula?)).to be(false)
// 902:     end
// 903:
// 904:     it "doesn't set --formula when defined" do
// 905:       parser = described_class.new(Cmd) do
// 906:         switch "--formula"
// 907:       end
// 908:       args = parser.parse([])
// 909:       expect(args.formula?).to be(false)
// 910:     end
// 911:
// 912:     it "does not set --formula to true when --cask" do
// 913:       parser = described_class.new(Cmd) do
// 914:         switch "--cask"
// 915:       end
// 916:       args = parser.parse([])
// 917:       expect(args.respond_to?(:formula?)).to be(false)
// 918:     end
// 919:   end
// 920: end

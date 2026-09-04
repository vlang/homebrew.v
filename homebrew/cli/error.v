module cli

import ruby

// Translated from Homebrew/brew `cli/error.rb`.

fn sentence(items []string, connector string) string {
	if items.len == 0 {
		return ''
	}
	if items.len == 1 {
		return items[0]
	}
	if items.len == 2 {
		return '${items[0]} ${connector} ${items[1]}'
	}
	return '${items[..items.len - 1].join(', ')}, ${connector} ${items.last()}'
}

fn argument_types(types []string) string {
	mut actual_types := types.clone()
	if actual_types.len == 0 {
		actual_types << 'named'
	}
	return sentence(actual_types.map(it.replace('_', ' ')), 'or')
}

fn plural_argument(count int) string {
	return if count == 1 { 'argument' } else { 'arguments' }
}

pub fn option_constraint_error(arg1 string, arg2 string, missing bool) IError {
	if missing {
		return error('`${arg2}` cannot be passed without `${arg1}`.')
	}
	return error('`${arg1}` and `${arg2}` should be passed together.')
}

pub fn option_conflict_error(options []string) IError {
	formatted := options.map('`${it}`')
	return error('Options ${sentence(formatted, 'and')} are mutually exclusive.')
}

pub fn invalid_constraint_error(arg1 string, arg2 string) IError {
	return error('`${arg1}` and `${arg2}` cannot be mutually exclusive and mutually dependent simultaneously.')
}

pub fn max_named_arguments_error(maximum int, types []string) IError {
	if maximum == 0 {
		return error('This command does not take named arguments.')
	}
	return error('This command does not take more than ${maximum} ${argument_types(types)} ${plural_argument(maximum)}.')
}

pub fn min_named_arguments_error(minimum int, types []string) IError {
	return error('This command requires at least ${minimum} ${argument_types(types)} ${plural_argument(minimum)}.')
}

pub fn number_of_named_arguments_error(number int, types []string) IError {
	return error('This command requires exactly ${number} ${argument_types(types)} ${plural_argument(number)}.')
}

fn cli_error_value(type_name string, value IError) ruby.Value {
	return ruby.structured_value(type_name, value.msg(), {
		'message': value.msg()
	})
}

fn cli_error_types(args []ruby.Value, index int) []string {
	return if args.len > index {
		args[index].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
}

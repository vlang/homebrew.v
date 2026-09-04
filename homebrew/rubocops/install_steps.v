module rubocops

import ruby
import homebrew.rubocops.@shared as install_steps_shared

// Translated from Homebrew/brew `rubocops/install_steps.rb`.
// The original source is retained below until every stub has a typed V body.
const formula_install_steps_conflict_message = '`post_install` and `post_install_steps` cannot both be used.'
const formula_install_steps_legacy_message = 'Formulae in official Homebrew taps must use `post_install_steps` instead of `post_install`.'
const formula_install_steps_explicit_base_message = 'Formula install-step paths must specify their base explicitly.'
const formula_install_steps_brew_ruby_message = 'Install steps must not use `brew ruby` because it enables developer mode.'
const formula_install_steps_simple_message = 'Use `post_install_steps` for simple file preparation.'

pub struct FormulaInstallStepsOffense {
pub:
	begin_pos int
	end_pos   int
	message   string
}

pub struct FormulaInstallStepsAnalysis {
pub:
	source    string
	file_path string
	offenses  []FormulaInstallStepsOffense
	corrected string
}

struct FormulaInstallStepsEdit {
	begin_pos   int
	end_pos     int
	replacement string
}

fn formula_install_steps_offense(begin_pos int, end_pos int, message string) FormulaInstallStepsOffense {
	return FormulaInstallStepsOffense{ begin_pos: begin_pos, end_pos: end_pos, message: message }
}

fn formula_install_steps_apply_edits(source string, edits []FormulaInstallStepsEdit) string {
	mut ordered := edits.clone()
	ordered.sort(a.begin_pos > b.begin_pos)
	mut result := source
	for edit in ordered {
		if edit.begin_pos < 0 || edit.end_pos < edit.begin_pos || edit.end_pos > result.len {
			continue
		}
		result = result[..edit.begin_pos] + edit.replacement + result[edit.end_pos..]
	}
	return result
}

fn formula_install_steps_remove_span(source string, span install_steps_shared.InstallStepSpan) string {
	mut begin := span.begin_pos
	for begin > 0 && source[begin - 1].is_space() {
		begin--
	}
	return source[..begin] + source[span.end_pos..]
}

fn formula_install_steps_class_name(source string) string {
	for line in source.split('\n') {
		trimmed := line.trim_space()
		if trimmed.starts_with('class ') {
			return trimmed[6..].all_before(' ').trim_space()
		}
	}
	return ''
}

fn formula_install_steps_string_value(expression string) ?string {
	trimmed := expression.trim_space()
	if trimmed.len < 2 {
		return none
	}
	quote := trimmed[0]
	if (quote != `"` && quote != `'`) || trimmed[trimmed.len - 1] != quote {
		return none
	}
	return trimmed[1..trimmed.len - 1]
}

fn formula_install_steps_explicit_expression(expression string) bool {
	trimmed := expression.trim_space()
	if trimmed.starts_with('[') && trimmed.ends_with(']') {
		items := trimmed[1..trimmed.len - 1].split(',')
		return items.len > 0 && items.all(formula_install_steps_string_value(it) != none && install_steps_shared.install_steps_explicit_formula_path(formula_install_steps_string_value(it) or {
			''
		}))
	}
	path := formula_install_steps_string_value(trimmed) or { return false }
	return install_steps_shared.install_steps_explicit_formula_path(path)
}

fn formula_install_steps_add_base(statement string) string {
	if statement.contains(', {}') {
		return statement.replace(', {}', ', base: :var')
	}
	if position := statement.index(' do') {
		return statement[..position] + ', base: :var' + statement[position..]
	}
	return statement.trim_right(' \t\n') + ', base: :var'
}

fn formula_install_steps_bare_symbol(source string) string {
	mut value := source.trim_space().trim_left(':')
	for separator in [',', ' ', '}', '\n'] {
		if index := value.index(separator) {
			value = value[..index]
		}
	}
	return value
}

fn formula_install_steps_implicit_analysis(source string) ([]FormulaInstallStepsOffense, string) {
	mut offenses := []FormulaInstallStepsOffense{}
	mut corrected := source
	base_methods := ['if_path_exists', 'unless_path_exists', 'mkdir', 'mkdir_p', 'touch', 'remove',
		'inreplace', 'write', 'write_file', 'init_data_dir', 'set_permissions']
	for statement in install_steps_shared.install_steps_all_statements(source, 'post_install_steps') {
		if statement.name in base_methods {
			argument := install_steps_shared.install_steps_first_argument(statement.source)
			if argument != '' && !formula_install_steps_explicit_expression(argument) && !statement.source.contains('base:') {
				offenses << formula_install_steps_offense(statement.begin_pos, statement.end_pos, formula_install_steps_explicit_base_message)
				corrected = corrected.replace(statement.source, formula_install_steps_add_base(statement.source))
			}
		} else if statement.name == 'run' {
			for keyword in ['stdin_path', 'stdout_path', 'chdir'] {
				marker := '${keyword}:'
				position := statement.source.index(marker) or { continue }
				rest := statement.source[position + marker.len..].trim_left(' \t')
				if rest.len < 2 || (rest[0] != `"` && rest[0] != `'`) {
					continue
				}
				quote := rest[0]
				end := rest.index_after(quote.ascii_str(), 1) or { continue }
				path := rest[1..end]
				if install_steps_shared.install_steps_explicit_formula_path(path) {
					continue
				}
				value_start := statement.begin_pos + position + marker.len + (statement.source[position + marker.len..].len - rest.len)
				offenses << formula_install_steps_offense(value_start, value_start + end + 1, formula_install_steps_explicit_base_message)
				corrected = corrected.replace('${keyword}: ${quote.ascii_str()}${path}${quote.ascii_str()}', '${keyword}: "{{var}}/${path}"')
			}
		}
	}
	return offenses, corrected
}

fn formula_install_steps_simple_lines(source string) ?[]string {
	statements := install_steps_shared.install_steps_direct_statements(source, 'post_install')
	if statements.len == 0 {
		return none
	}
	mut lines := []string{}
	for statement in statements {
		if statement.source.contains('.atomic_write <<~') {
			position := statement.source.index('.atomic_write ') or { return none }
			path := install_steps_shared.install_steps_parse_path(statement.source[..position]) or {
				return none
			}
			if install_steps_shared.install_steps_relative_path(path) {
				return none
			}
			first_line := statement.source.all_before('\n')
			heredoc := first_line[position + '.atomic_write '.len..]
			mut line := 'write_file ${install_steps_shared.install_steps_path_source(path)}, ${heredoc}${install_steps_shared.install_steps_path_keywords(path, 'var', 'base')}'
			if statement.source.contains('\n') {
				line += '\n' + statement.source.all_after('\n')
			}
			lines << line
			continue
		}
		line := install_steps_shared.install_steps_simple_line(statement.source, 'var', 'prefix', 'prefix', true) or { return none }
		lines << line
	}
	return lines
}

fn formula_install_steps_service_paths(source string) []install_steps_shared.InstallStepPath {
	mut paths := []install_steps_shared.InstallStepPath{}
	for statement in install_steps_shared.install_steps_direct_statements(source, 'service') {
		if statement.name !in ['working_dir', 'root_dir', 'input_path', 'log_path', 'error_log_path'] {
			continue
		}
		argument := install_steps_shared.install_steps_first_argument(statement.source)
		mut path := install_steps_shared.install_steps_parse_path(argument) or { continue }
		if statement.name in ['input_path', 'log_path', 'error_log_path'] {
			path = install_steps_shared.install_steps_path_parent(path) or { continue }
		}
		if !paths.any(install_steps_shared.install_steps_paths_match(it, path)) {
			paths << path
		}
	}
	return paths
}

fn formula_install_steps_statement_path(statement install_steps_shared.InstallStepSpan,
	block_name string) ?install_steps_shared.InstallStepPath {
	if block_name == 'post_install' {
		normalised := install_steps_shared.install_steps_normalised_source(statement.source)
		if !normalised.ends_with('.mkpath') {
			return none
		}
		return install_steps_shared.install_steps_parse_path(normalised[..normalised.len - '.mkpath'.len])
	}
	if statement.name !in ['mkdir', 'mkdir_p'] {
		return none
	}
	path := install_steps_shared.install_steps_parse_path(install_steps_shared.install_steps_first_argument(statement.source)) or {
		return none
	}
	if path.base == '' && !install_steps_shared.install_steps_absolute_path(path) {
		base := if statement.source.contains('base:') {
			formula_install_steps_bare_symbol(statement.source.all_after('base:'))
		} else {
			'var'
		}
		return install_steps_shared.InstallStepPath{
			path: path.path
			base: base
		}
	}
	return path
}

fn formula_install_steps_redundant(source string, block_name string,
	service_paths []install_steps_shared.InstallStepPath) bool {
	statements := install_steps_shared.install_steps_direct_statements(source, block_name)
	if statements.len == 0 || service_paths.len == 0 {
		return false
	}
	for statement in statements {
		path := formula_install_steps_statement_path(statement, block_name) or { return false }
		if !service_paths.any(install_steps_shared.install_steps_paths_match(path, it)) {
			return false
		}
	}
	return true
}

fn formula_install_steps_special_conversion(source string, class_name string,
	post install_steps_shared.InstallStepSpan, steps ?install_steps_shared.InstallStepSpan) ?string {
	normalised := install_steps_shared.install_steps_normalised_source(post.source)
	mut step_lines := []string{}
	mut remaining := ''
	mut removable_names := []string{}
	if normalised.contains('(var/"log").mkpath') && normalised.contains('postgresql_datadir.mkpath') && normalised.contains('return if ENV["HOMEBREW_GITHUB_ACTIONS"]') && normalised.contains('system bin/"initdb"') && source.contains('def postgresql_datadir') && source.contains('def pg_version_exists?') {
		step_lines << 'mkdir_p "log", base: :var'
		if normalised.contains('%w[include lib share].each') {
			step_lines << [
				'symlink_tree "include/postgresql", "include/{{formula_name}}"',
				'symlink_tree "lib/postgresql", "lib/{{formula_name}}"',
				'symlink_tree "share/postgresql", "share/{{formula_name}}"',
			]
		}
		if normalised.contains('bin.each_child') {
			step_lines << 'symlink_children "bin", suffix: "-{{version.major}}"'
		}
		init := if normalised.contains('--locale=C') {
			'init_data_dir formula_name, using: :postgresql, base: :var, locale: "C"'
		} else {
			'init_data_dir formula_name, using: :postgresql, base: :var'
		}
		step_lines << init
		remaining = post.source.split('\n').filter(it.trim_space().starts_with('opoo ')).join('\n')
		removable_names << 'pg_version_exists?'
	} else if (class_name == 'Mysql' || (class_name.starts_with('MysqlAT') && class_name['MysqlAT'.len..].bytes().all(it.is_digit()))) && normalised.contains('(var/"mysql").mkpath') && normalised.contains('return if ENV["HOMEBREW_GITHUB_ACTIONS"]') && normalised.contains('system bin/"mysqld", "--initialize-insecure"') && source.contains('def datadir') {
		step_lines << 'init_data_dir "mysql", using: :mysql, base: :var'
		if normalised.contains('if File.exist? "/etc/my.cnf"') {
			remaining = 'if File.exist? "/etc/my.cnf"\n    opoo "existing configuration"\n  end'
		}
	} else if normalised.contains('(var/"mysql").mkpath') && normalised.contains('return if ENV["HOMEBREW_GITHUB_ACTIONS"]') && normalised.contains('system bin/"mysql_install_db", "--verbose"') {
		step_lines << 'init_data_dir "mysql", using: :mariadb, base: :var'
	} else if normalised.contains('rm(pkgetc/"cert.pem") if (pkgetc/"cert.pem").exist?') && normalised.contains('pkgetc.install_symlink Formula["ca-certificates"].pkgetc/"cert.pem"') {
		step_lines << 'symlink "cert.pem", "cert.pem",\n        source_formula: "ca-certificates",\n        source_base: :formula_pkgetc,\n        target_base: :pkgetc,\n        overwrite: true'
		remaining = post.source.split('\n').filter(it.trim_space().starts_with('opoo ')).join('\n')
	} else {
		return none
	}
	mut corrected := source
	if existing := steps {
		updated := install_steps_shared.install_steps_append_lines(existing.source, step_lines, existing.indent)
		corrected = corrected.replace(existing.source, updated)
	} else {
		block := install_steps_shared.install_steps_block_source('post_install_steps', step_lines, post.indent)
		corrected = corrected[..post.begin_pos] + block + '\n\n' + ' '.repeat(post.indent) + corrected[post.begin_pos..]
	}
	if remaining == '' {
		current_post := install_steps_shared.install_steps_find_block(corrected, 'post_install') or {
			return corrected
		}
		corrected = formula_install_steps_remove_span(corrected, current_post)
	} else {
		current_post := install_steps_shared.install_steps_find_block(corrected, 'post_install') or {
			return corrected
		}
		body := remaining.split('\n').map(' '.repeat(current_post.indent + 2) + it.trim_space()).join('\n')
		replacement := 'def post_install\n${body}\n${' '.repeat(current_post.indent)}end'
		corrected = corrected[..current_post.begin_pos] + replacement + corrected[current_post.end_pos..]
	}
	for method in removable_names {
		if removable := install_steps_shared.install_steps_find_block(corrected, method) {
			corrected = formula_install_steps_remove_span(corrected, removable)
		}
	}
	return corrected
}

pub fn analyze_formula_install_steps(source string, file_path string) FormulaInstallStepsAnalysis {
	mut offenses := []FormulaInstallStepsOffense{}
	mut corrected := source
	steps := install_steps_shared.install_steps_find_block(source, 'post_install_steps')
	post := install_steps_shared.install_steps_find_block(source, 'post_install')
	service_paths := formula_install_steps_service_paths(source)
	if step_block := steps {
		if post != none {
			offenses << formula_install_steps_offense(step_block.begin_pos, step_block.end_pos, formula_install_steps_conflict_message)
		}
		compatibility := install_steps_shared.install_steps_compatibility_analysis(corrected, 'post_install_steps', install_steps_shared.install_steps_allowed_methods())
		for offense in compatibility.offenses {
			offenses << formula_install_steps_offense(offense.begin_pos, offense.end_pos, offense.message)
		}
		corrected = compatibility.corrected
		if brew_offense := install_steps_shared.install_steps_brew_ruby_offense(source, 'post_install_steps') {
			offenses << formula_install_steps_offense(brew_offense.begin_pos, brew_offense.end_pos, formula_install_steps_brew_ruby_message)
		} else if block_offense := install_steps_shared.install_steps_block_offense_for(source, 'post_install_steps', install_steps_shared.install_steps_allowed_methods()) {
			offenses << formula_install_steps_offense(block_offense.begin_pos, block_offense.end_pos, install_steps_shared.install_steps_step_block_message(install_steps_shared.install_steps_allowed_methods()))
		} else {
			implicit_offenses, implicit_corrected := formula_install_steps_implicit_analysis(corrected)
			offenses << implicit_offenses
			corrected = implicit_corrected
		}
	}
	mut redundant_post := false
	if post_block := post {
		if formula_install_steps_redundant(source, 'post_install', service_paths) {
			redundant_post = true
			offenses << formula_install_steps_offense(post_block.begin_pos, post_block.end_pos, '`post_install` only creates directories created by `brew services`.')
			current := install_steps_shared.install_steps_find_block(corrected, 'post_install') or {
				post_block
			}
			corrected = formula_install_steps_remove_span(corrected, current)
		}
	}
	if step_block := steps {
		if formula_install_steps_redundant(source, 'post_install_steps', service_paths) {
			offenses << formula_install_steps_offense(step_block.begin_pos, step_block.end_pos, '`post_install_steps` only creates directories created by `brew services`.')
			current := install_steps_shared.install_steps_find_block(corrected, 'post_install_steps') or { step_block }
			corrected = formula_install_steps_remove_span(corrected, current)
		}
	}
	mut converted := false
	if !redundant_post {
		if post_block := post {
			step_after_post := if step_block := steps {
				step_block.begin_pos > post_block.begin_pos
			} else {
				false
			}
			if !step_after_post {
				if special := formula_install_steps_special_conversion(corrected, formula_install_steps_class_name(source), post_block, steps) {
					converted = true
					corrected = special
					offenses << formula_install_steps_offense(post_block.begin_pos, post_block.end_pos, formula_install_steps_simple_message)
				} else if steps == none {
					if step_lines := formula_install_steps_simple_lines(source) {
						converted = true
						block := install_steps_shared.install_steps_block_source('post_install_steps', step_lines, post_block.indent)
						corrected = corrected.replace(post_block.source, block)
						offenses << formula_install_steps_offense(post_block.begin_pos, post_block.end_pos, formula_install_steps_simple_message)
					}
				}
			}
		}
	}
	if post_block := post {
		if install_steps_shared.install_steps_official_homebrew_tap(file_path) && !converted && !redundant_post {
			offenses << formula_install_steps_offense(post_block.begin_pos, post_block.end_pos, formula_install_steps_legacy_message)
		}
	}
	return FormulaInstallStepsAnalysis{ source: source, file_path: file_path, offenses: offenses, corrected: corrected }
}

fn formula_install_steps_offense_value(offense FormulaInstallStepsOffense) ruby.Value {
	return ruby.Value{
		type_name: 'RuboCop::Cop::Offense'
		repr: offense.message
		map_data: {
			'message': ruby.string_value(offense.message)
		}
		attributes: {
			'begin_pos': offense.begin_pos.str()
			'end_pos':   offense.end_pos.str()
		}
	}
}

fn formula_install_steps_analysis_value(analysis FormulaInstallStepsAnalysis) ruby.Value {
	return ruby.Value{
		type_name: 'RuboCop::Cop::FormulaAudit::InstallSteps::Analysis'
		repr: analysis.source
		array_data: analysis.offenses.map(formula_install_steps_offense_value(it))
		map_data: {
			'offenses':  ruby.array_value(analysis.offenses.map(formula_install_steps_offense_value(it)))
			'corrected': ruby.string_value(analysis.corrected)
		}
	}
}

fn formula_install_steps_args(args []ruby.Value) (string, string) {
	source := if args.len > 0 { args[0].as_string() } else { 'class Foo < Formula\nend\n' }
	path := if args.len > 1 { args[1].as_string() } else { '' }
	return source, path
}

fn formula_install_steps_path_value(path install_steps_shared.InstallStepPath) ruby.Value {
	return ruby.Value{
		type_name: 'RuboCop::Cop::InstallStepsHelper::InstallStepPath'
		repr: install_steps_shared.install_steps_path_source(path)
		map_data: {
			'path':   ruby.string_value(path.path)
			'base':   ruby.string_value(path.base)
			'source': ruby.string_value(path.source)
		}
	}
}

fn formula_install_steps_path_arg(value ruby.Value) ?install_steps_shared.InstallStepPath {
	if value.type_name == 'RuboCop::Cop::InstallStepsHelper::InstallStepPath' {
		return install_steps_shared.InstallStepPath{
			path: (value.map_data['path'] or { ruby.string_value('') }).as_string()
			base: (value.map_data['base'] or { ruby.string_value('') }).as_string()
			source: (value.map_data['source'] or { ruby.string_value('') }).as_string()
		}
	}
	return install_steps_shared.install_steps_parse_path(value.as_string())
}

// Ruby method `audit_formula(formula_nodes)` at line 85.
pub fn ruby_install_steps_l85_d1_audit_formula(args ...ruby.Value) ruby.Value {
	source, path := formula_install_steps_args(args)
	return formula_install_steps_analysis_value(analyze_formula_install_steps(source, path))
}

// Ruby method `audit_step_block(block_node)` at line 121.
pub fn ruby_install_steps_l121_d2_audit_step_block(args ...ruby.Value) ruby.Value {
	source, _ := formula_install_steps_args(args)
	return formula_install_steps_analysis_value(analyze_formula_install_steps(source, ''))
}

// Ruby method `add_implicit_var_path_offenses(block_node)` at line 142.
pub fn ruby_install_steps_l142_d3_add_implicit_var_path_offenses(args ...ruby.Value) ruby.Value {
	source, _ := formula_install_steps_args(args)
	offenses, corrected := formula_install_steps_implicit_analysis(source)
	return formula_install_steps_analysis_value(FormulaInstallStepsAnalysis{
		source: source
		offenses: offenses
		corrected: corrected
	})
}

// Ruby method `add_implicit_var_base_offense(send_node)` at line 156.
pub fn ruby_install_steps_l156_d4_add_implicit_var_base_offense(args ...ruby.Value) ruby.Value {
	statement := if args.len > 0 { args[0].as_string() } else { '' }
	source := 'post_install_steps do\n  ${statement}\nend'
	offenses, corrected := formula_install_steps_implicit_analysis(source)
	return formula_install_steps_analysis_value(FormulaInstallStepsAnalysis{
		source: source
		offenses: offenses
		corrected: corrected
	})
}

// Ruby method `add_implicit_var_run_path_offenses(send_node)` at line 190.
pub fn ruby_install_steps_l190_d5_add_implicit_var_run_path_offenses(args ...ruby.Value) ruby.Value {
	return ruby_install_steps_l156_d4_add_implicit_var_base_offense(...args)
}

// Ruby method `explicit_formula_step_path?(node)` at line 208.
pub fn ruby_install_steps_l208_d6_explicit_formula_step_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	if args[0].type_name == 'Array' {
		values := args[0].as_array() or { [] }
		return ruby.bool_value(values.len > 0 && values.all(install_steps_shared.install_steps_explicit_formula_path(it.as_string())))
	}
	value := args[0].as_string().trim('"\'')
	return ruby.bool_value(install_steps_shared.install_steps_explicit_formula_path(value))
}

// Ruby method `autocorrect_post_install_method?(post_install_method, post_install_steps_block, formula_body,` at line 229.
pub fn ruby_install_steps_l229_d7_autocorrect_post_install_method(args ...ruby.Value) ruby.Value {
	source, path := formula_install_steps_args(args)
	analysis := analyze_formula_install_steps(source, path)
	return ruby.bool_value(analysis.corrected != source)
}

// Ruby method `add_postgresql_step_nodes(direct_nodes, formula_body, step_nodes, removable_methods)` at line 279.
pub fn ruby_install_steps_l279_d8_add_postgresql_step_nodes(args ...ruby.Value) ruby.Value {
	source, path := formula_install_steps_args(args)
	return ruby.string_value(analyze_formula_install_steps(source, path).corrected)
}

// Ruby method `add_mysql_step_nodes(direct_nodes, formula_body, step_nodes)` at line 322.
pub fn ruby_install_steps_l322_d9_add_mysql_step_nodes(args ...ruby.Value) ruby.Value {
	return ruby_install_steps_l279_d8_add_postgresql_step_nodes(...args)
}

// Ruby method `add_mariadb_step_nodes(direct_nodes, step_nodes)` at line 336.
pub fn ruby_install_steps_l336_d10_add_mariadb_step_nodes(args ...ruby.Value) ruby.Value {
	return ruby_install_steps_l279_d8_add_postgresql_step_nodes(...args)
}

// Ruby method `add_mysql_data_step_nodes(direct_nodes, step_nodes, initialise_source, using)` at line 348.
pub fn ruby_install_steps_l348_d11_add_mysql_data_step_nodes(args ...ruby.Value) ruby.Value {
	return ruby_install_steps_l279_d8_add_postgresql_step_nodes(...args)
}

// Ruby method `add_postgresql_link_step_nodes(direct_nodes, step_nodes)` at line 370.
pub fn ruby_install_steps_l370_d12_add_postgresql_link_step_nodes(args ...ruby.Value) ruby.Value {
	return ruby_install_steps_l279_d8_add_postgresql_step_nodes(...args)
}

// Ruby method `add_certificate_symlink_step_nodes(direct_nodes, step_nodes)` at line 391.
pub fn ruby_install_steps_l391_d13_add_certificate_symlink_step_nodes(args ...ruby.Value) ruby.Value {
	return ruby_install_steps_l279_d8_add_postgresql_step_nodes(...args)
}

// Ruby method `nodes_in_source_order?(nodes)` at line 410.
pub fn ruby_install_steps_l410_d14_nodes_in_source_order(args ...ruby.Value) ruby.Value {
	values := if args.len > 0 { args[0].as_array() or { [] } } else { [] }
	mut previous := -1
	for value in values {
		position := (value.attributes['begin_pos'] or { value.int_data.str() }).int()
		if previous >= position {
			return ruby.bool_value(false)
		}
		previous = position
	}
	return ruby.bool_value(true)
}

// Ruby method `add_formula_step_conversion_offense(post_install_def, post_install_steps_block, direct_nodes, step_nodes,` at line 425.
pub fn ruby_install_steps_l425_d15_add_formula_step_conversion_offense(args ...ruby.Value) ruby.Value {
	source, path := formula_install_steps_args(args)
	return formula_install_steps_analysis_value(analyze_formula_install_steps(source, path))
}

// Ruby method `matched_install_step_node_groups(direct_nodes, step_nodes)` at line 467.
pub fn ruby_install_steps_l467_d16_matched_install_step_node_groups(args ...ruby.Value) ruby.Value {
	source, _ := formula_install_steps_args(args)
	statements := install_steps_shared.install_steps_direct_statements(source, 'post_install')
	return ruby.array_value(statements.map(ruby.array_value([
		ruby.structured_value('RuboCop::AST::Node', it.source, {
			'begin_pos': it.begin_pos.str()
			'end_pos':   it.end_pos.str()
		}),
	])))
}

// Ruby method `range_for_install_step_node_group(nodes)` at line 473.
pub fn ruby_install_steps_l473_d17_range_for_install_step_node_group(args ...ruby.Value) ruby.Value {
	values := if args.len > 0 { args[0].as_array() or { [] } } else { [] }
	if values.len == 0 {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	begin := (values[0].attributes['begin_pos'] or { '0' }).int()
	end := (values.last().attributes['end_pos'] or { begin.str() }).int()
	return ruby.structured_value('Parser::Source::Range', '${begin}...${end}', {
		'begin_pos': begin.str()
		'end_pos':   end.str()
	})
}

// Ruby method `add_redundant_service_path_dirs_offense(node, service_path_dirs, block_name)` at line 491.
pub fn ruby_install_steps_l491_d18_add_redundant_service_path_dirs_offense(args ...ruby.Value) ruby.Value {
	source, path := formula_install_steps_args(args)
	return formula_install_steps_analysis_value(analyze_formula_install_steps(source, path))
}

// Ruby method `redundant_service_path_dirs_block?(node, service_path_dirs, block_name)` at line 507.
pub fn ruby_install_steps_l507_d19_redundant_service_path_dirs_block(args ...ruby.Value) ruby.Value {
	source, _ := formula_install_steps_args(args)
	name := if args.len > 1 { args[1].as_string().trim_left(':') } else { 'post_install_steps' }
	return ruby.bool_value(formula_install_steps_redundant(source, name, formula_install_steps_service_paths(source)))
}

// Ruby method `redundant_service_path_dir?(node, path_dir, block_name)` at line 530.
pub fn ruby_install_steps_l530_d20_redundant_service_path_dir(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	path := formula_install_steps_path_arg(args[1]) or { return ruby.bool_value(false) }
	statement := install_steps_shared.InstallStepSpan{
		name: install_steps_shared.install_steps_normalised_source(args[0].as_string()).all_before(' ')
		source: args[0].as_string()
	}
	block_name := if args.len > 2 {
		args[2].as_string().trim_left(':')
	} else {
		'post_install_steps'
	}
	actual := formula_install_steps_statement_path(statement, block_name) or {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(install_steps_shared.install_steps_paths_match(actual, path))
}

// Ruby method `service_path_dirs(block_node)` at line 550.
pub fn ruby_install_steps_l550_d21_service_path_dirs(args ...ruby.Value) ruby.Value {
	source, _ := formula_install_steps_args(args)
	paths := formula_install_steps_service_paths(source)
	return ruby.array_value(paths.map(formula_install_steps_path_value(it)))
}

// Ruby method `install_step_path_with_base(node, last_arg, default_base:)` at line 581.
pub fn ruby_install_steps_l581_d22_install_step_path_with_base(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	mut path := formula_install_steps_path_arg(args[0]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	default_base := if args.len > 2 { args[2].as_string().trim_left(':') } else { 'var' }
	if args.len > 1 && args[1].as_string().contains('base:') {
		path = install_steps_shared.InstallStepPath{
			path: path.path
			base: args[1].as_string().all_after('base:').trim_space().trim_left(':')
		}
	} else if path.base == '' && !install_steps_shared.install_steps_absolute_path(path) {
		path = install_steps_shared.InstallStepPath{
			path: path.path
			base: default_base
		}
	}
	return formula_install_steps_path_value(path)
}

// Ruby method `install_step_path_hash_base(node)` at line 596.
pub fn ruby_install_steps_l596_d23_install_step_path_hash_base(args ...ruby.Value) ruby.Value {
	if args.len == 0 || !args[0].as_string().contains('base:') {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	base := formula_install_steps_bare_symbol(args[0].as_string().all_after('base:'))
	return ruby.object_value('Symbol', ':${base}')
}

// Ruby method `path_parent(path)` at line 611.
pub fn ruby_install_steps_l611_d24_path_parent(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	path := formula_install_steps_path_arg(args[0]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	parent := install_steps_shared.install_steps_path_parent(path) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	return formula_install_steps_path_value(parent)
}

// Ruby method `paths_match?(path, other_path)` at line 621.
pub fn ruby_install_steps_l621_d25_paths_match(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	path := formula_install_steps_path_arg(args[0]) or { return ruby.bool_value(false) }
	other := formula_install_steps_path_arg(args[1]) or { return ruby.bool_value(false) }
	return ruby.bool_value(install_steps_shared.install_steps_paths_match(path, other))
}

// Ruby method `path_key(path)` at line 628.
pub fn ruby_install_steps_l628_d26_path_key(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	path := formula_install_steps_path_arg(args[0]) or {
		return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
	}
	return ruby.array_value([
		if path.base == '' {
			ruby.Value{ type_name: 'NilClass', repr: 'nil' }
		} else {
			ruby.object_value('Symbol', ':${path.base}')
		},
		ruby.string_value(path.path),
	])
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5: require "rubocops/shared/install_steps_helper"
// 6:
// 7: module RuboCop
// 8:   module Cop
// 9:     module FormulaAudit
// 10:       # This cop checks declarative install step usage.
// 11:       class InstallSteps < FormulaCop
// 12:         extend AutoCorrector
// 13:         include InstallStepsHelper
// 14:
// 15:         CONFLICT_MSG = "`post_install` and `post_install_steps` cannot both be used."
// 16:         LEGACY_POST_INSTALL_MSG =
// 17:           "Formulae in official Homebrew taps must use `post_install_steps` instead of `post_install`."
// 18:         REDUNDANT_SERVICE_PATH_DIRS_MSG = "`%<block>s` only creates directories created by `brew services`."
// 19:         EXPLICIT_BASE_MSG = "Formula install-step paths must specify their base explicitly."
// 20:         EXPLICIT_BASE_STEP_METHODS = [:if_path_exists, :unless_path_exists, :mkdir, :mkdir_p, :touch, :remove,
// 21:                                       :inreplace, :write, :write_file, :init_data_dir, :set_permissions].freeze
// 22:         RUN_PATH_KEYWORDS = [:stdin_path, :stdout_path, :chdir].freeze
// 23:         ABSOLUTE_PATH_TEMPLATE_TOKENS = %w[
// 24:           HOMEBREW_PREFIX HOMEBREW_CELLAR prefix opt_prefix bin sbin lib libexec share pkgshare var etc pkgetc rack
// 25:           staged_path appdir caskroom_path temp bash_completion zsh_completion fish_completion pwsh_completion
// 26:         ].freeze
// 27:         CERTIFICATE_REMOVE_SOURCE = 'rm(pkgetc/"cert.pem") if (pkgetc/"cert.pem").exist?'
// 28:         CERTIFICATE_INSTALL_SYMLINK_SOURCE =
// 29:           'pkgetc.install_symlink Formula["ca-certificates"].pkgetc/"cert.pem"'
// 30:         GITHUB_ACTIONS_GUARD_SOURCE = "return if ENV[\"HOMEBREW_GITHUB_ACTIONS\"]"
// 31:         MYSQL_FORMULA_CLASS_REGEX = /\AMysql(?:AT\d+)?\z/
// 32:         MYSQL_DATADIR_METHOD_SOURCE = "def datadir var/\"mysql\" end"
// 33:         MYSQL_INITIALISE_SOURCE = T.let(
// 34:           <<~'RUBY'.gsub(/\s+/, " ").strip.freeze,
// 35:             unless (datadir/"mysql/general_log.CSM").exist?
// 36:               ENV["TMPDIR"] = nil
// 37:               system bin/"mysqld", "--initialize-insecure", "--user=#{ENV["USER"]}",
// 38:                                    "--basedir=#{prefix}", "--datadir=#{datadir}", "--tmpdir=/tmp"
// 39:             end
// 40:           RUBY
// 41:           String,
// 42:         )
// 43:         MARIADB_INITIALISE_SOURCE = T.let(
// 44:           <<~'RUBY'.gsub(/\s+/, " ").strip.freeze,
// 45:             unless File.exist? "#{var}/mysql/mysql/user.frm"
// 46:               ENV["TMPDIR"] = nil
// 47:               system bin/"mysql_install_db", "--verbose", "--user=#{ENV["USER"]}",
// 48:                 "--basedir=#{prefix}", "--datadir=#{var}/mysql", "--tmpdir=/tmp"
// 49:             end
// 50:           RUBY
// 51:           String,
// 52:         )
// 53:         POSTGRESQL_DATADIR_METHOD_SOURCE = "def postgresql_datadir var/name end"
// 54:         POSTGRESQL_MARKER_METHOD_SOURCE = "def pg_version_exists? (postgresql_datadir/\"PG_VERSION\").exist? end"
// 55:         POSTGRESQL_INIT_SOURCE_REGEX = Regexp.new(
// 56:           '\Asystem bin/"initdb", "--locale=(C|en_US\\.UTF-8)", "-E", "UTF-8", ' \
// 57:           'postgresql_datadir unless pg_version_exists\\?\\z',
// 58:         ).freeze
// 59:         POSTGRESQL_LINK_DIR_SOURCE = T.let(
// 60:           <<~RUBY.gsub(/\s+/, " ").strip.freeze,
// 61:             %w[include lib share].each do |dir|
// 62:               dst_dir = HOMEBREW_PREFIX/dir/name
// 63:               src_dir = prefix/dir/"postgresql"
// 64:               src_dir.find do |src|
// 65:                 dst = dst_dir/src.relative_path_from(src_dir)
// 66:                 next if dst.directory? && !dst.symlink? && src.directory? && !src.symlink?
// 67:
// 68:                 rm_r(dst) if dst.exist? || dst.symlink?
// 69:                 if src.symlink? || src.file?
// 70:                   Find.prune if src.basename.to_s == ".DS_Store"
// 71:                   dst.parent.install_symlink src
// 72:                 elsif src.directory?
// 73:                   dst.mkpath
// 74:                 end
// 75:               end
// 76:             end
// 77:           RUBY
// 78:           String,
// 79:         )
// 80:         POSTGRESQL_LINK_CHILDREN_SOURCE =
// 81:           "bin.each_child { |f| (HOMEBREW_PREFIX/\"bin\").install_symlink " \
// 82:           "f => \"\#{f.basename}-\#{version.major}\" }"
// 83:
// 84:         sig { override.params(formula_nodes: FormulaNodes).void }
// 85:         def audit_formula(formula_nodes)
// 86:           return if (body_node = formula_nodes.body_node).nil?
// 87:
// 88:           service_path_dirs = service_path_dirs(find_block(body_node, :service))
// 89:           post_install_steps_block = find_block(body_node, :post_install_steps)
// 90:           post_install_method = find_method_def(body_node, :post_install)
// 91:
// 92:           if post_install_steps_block && post_install_method
// 93:             offending_node(post_install_steps_block)
// 94:             problem CONFLICT_MSG
// 95:           end
// 96:
// 97:           redundant_post_install_steps = post_install_steps_block.present? &&
// 98:                                          redundant_service_path_dirs_block?(post_install_steps_block,
// 99:                                                                             service_path_dirs,
// 100:                                                                             :post_install_steps)
// 101:           audit_step_block(post_install_steps_block) unless redundant_post_install_steps
// 102:           add_redundant_service_path_dirs_offense(post_install_steps_block, service_path_dirs, :post_install_steps)
// 103:           redundant_post_install = post_install_method.present? &&
// 104:                                    redundant_service_path_dirs_block?(post_install_method, service_path_dirs,
// 105:                                                                       :post_install)
// 106:           add_redundant_service_path_dirs_offense(post_install_method, service_path_dirs, :post_install)
// 107:           return if redundant_post_install
// 108:
// 109:           converted_post_install = autocorrect_post_install_method?(post_install_method, post_install_steps_block,
// 110:                                                                     body_node, formula_nodes.class_node.const_name)
// 111:           # odeprecated: remove the official-tap scope in the next major or minor release.
// 112:           return unless official_homebrew_tap?(processed_source.file_path)
// 113:           return if post_install_method.nil? || converted_post_install
// 114:
// 115:           add_offense(post_install_method, message: LEGACY_POST_INSTALL_MSG)
// 116:         end
// 117:
// 118:         private
// 119:
// 120:         sig { params(block_node: T.nilable(RuboCop::AST::BlockNode)).void }
// 121:         def audit_step_block(block_node)
// 122:           return if block_node.nil?
// 123:
// 124:           add_compatibility_step_offenses(block_node)
// 125:
// 126:           if (offense_node = brew_ruby_step_node(block_node))
// 127:             offending_node(offense_node)
// 128:             problem BREW_RUBY_STEP_MSG
// 129:             return
// 130:           end
// 131:
// 132:           if (offense_node = install_step_block_offense_node(block_node))
// 133:             offending_node(offense_node)
// 134:             problem STEP_BLOCK_MSG
// 135:             return
// 136:           end
// 137:
// 138:           add_implicit_var_path_offenses(block_node)
// 139:         end
// 140:
// 141:         sig { params(block_node: RuboCop::AST::BlockNode).void }
// 142:         def add_implicit_var_path_offenses(block_node)
// 143:           block_node.each_descendant(:send) do |node|
// 144:             send_node = T.cast(node, RuboCop::AST::SendNode)
// 145:             next if send_node.receiver
// 146:
// 147:             if EXPLICIT_BASE_STEP_METHODS.include?(send_node.method_name)
// 148:               add_implicit_var_base_offense(send_node)
// 149:             elsif send_node.method_name == :run
// 150:               add_implicit_var_run_path_offenses(send_node)
// 151:             end
// 152:           end
// 153:         end
// 154:
// 155:         sig { params(send_node: RuboCop::AST::SendNode).void }
// 156:         def add_implicit_var_base_offense(send_node)
// 157:           path_node = send_node.arguments.first
// 158:           return if path_node.nil? || explicit_formula_step_path?(path_node)
// 159:
// 160:           options = send_node.arguments.last
// 161:           options = nil unless options&.hash_type?
// 162:           return if options && T.cast(options, RuboCop::AST::HashNode).pairs.any? do |pair|
// 163:             pair.key.sym_type? && pair.key.value == :base
// 164:           end
// 165:
// 166:           add_offense(send_node, message: EXPLICIT_BASE_MSG) do |corrector|
// 167:             if options
// 168:               options = T.cast(options, RuboCop::AST::HashNode)
// 169:               pair = options.pairs.last
// 170:               if pair
// 171:                 corrector.insert_after(pair.source_range, ", base: :var")
// 172:               else
// 173:                 corrector.replace(options, "base: :var")
// 174:               end
// 175:             else
// 176:               argument = send_node.arguments.last
// 177:               next if argument.nil?
// 178:
// 179:               range = if argument.loc.respond_to?(:heredoc_end) && argument.loc.heredoc_end
// 180:                 argument.loc.expression
// 181:               else
// 182:                 argument.source_range
// 183:               end
// 184:               corrector.insert_after(range, ", base: :var")
// 185:             end
// 186:           end
// 187:         end
// 188:
// 189:         sig { params(send_node: RuboCop::AST::SendNode).void }
// 190:         def add_implicit_var_run_path_offenses(send_node)
// 191:           options = send_node.arguments.last
// 192:           return unless options&.hash_type?
// 193:
// 194:           T.cast(options, RuboCop::AST::HashNode).pairs.each do |pair|
// 195:             next if !pair.key.sym_type? || !RUN_PATH_KEYWORDS.include?(pair.key.value)
// 196:             next if explicit_formula_step_path?(pair.value)
// 197:
// 198:             add_offense(pair.value, message: EXPLICIT_BASE_MSG) do |corrector|
// 199:               next unless pair.value.str_type?
// 200:
// 201:               path = T.cast(pair.value, RuboCop::AST::StrNode).str_content
// 202:               corrector.replace(pair.value, "{{var}}/#{path}".dump)
// 203:             end
// 204:           end
// 205:         end
// 206:
// 207:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 208:         def explicit_formula_step_path?(node)
// 209:           if node.array_type?
// 210:             paths = node.child_nodes
// 211:             return paths.present? && paths.all? { |path| explicit_formula_step_path?(path) }
// 212:           end
// 213:           return false unless node.str_type?
// 214:
// 215:           path = T.cast(node, RuboCop::AST::StrNode).str_content
// 216:           return true if path.start_with?("/", "~")
// 217:
// 218:           ABSOLUTE_PATH_TEMPLATE_TOKENS.any? { |token| path.start_with?("{{#{token}}}") }
// 219:         end
// 220:
// 221:         sig {
// 222:           params(
// 223:             post_install_method:      T.nilable(RuboCop::AST::Node),
// 224:             post_install_steps_block: T.nilable(RuboCop::AST::BlockNode),
// 225:             formula_body:             RuboCop::AST::Node,
// 226:             formula_class:            String,
// 227:           ).returns(T::Boolean)
// 228:         }
// 229:         def autocorrect_post_install_method?(post_install_method, post_install_steps_block, formula_body,
// 230:                                              formula_class)
// 231:           return false if post_install_method.nil?
// 232:           return false unless post_install_method.def_type?
// 233:
// 234:           post_install_def = T.cast(post_install_method, RuboCop::AST::DefNode)
// 235:           return false if post_install_steps_block && post_install_steps_block.loc.line > post_install_def.loc.line
// 236:
// 237:           step_nodes = T.let({}, T::Hash[RuboCop::AST::Node, T::Array[String]])
// 238:           removable_methods = T.let([], T::Array[RuboCop::AST::Node])
// 239:           direct_nodes = direct_install_step_nodes(post_install_def.body)
// 240:           add_postgresql_step_nodes(direct_nodes, formula_body, step_nodes, removable_methods)
// 241:           if formula_class.match?(MYSQL_FORMULA_CLASS_REGEX)
// 242:             add_mysql_step_nodes(direct_nodes, formula_body, step_nodes)
// 243:           end
// 244:           add_mariadb_step_nodes(direct_nodes, step_nodes)
// 245:           add_postgresql_link_step_nodes(direct_nodes, step_nodes)
// 246:           add_certificate_symlink_step_nodes(direct_nodes, step_nodes)
// 247:           unless step_nodes.empty?
// 248:             add_formula_step_conversion_offense(post_install_def, post_install_steps_block, direct_nodes, step_nodes,
// 249:                                                 removable_methods)
// 250:             return true
// 251:           end
// 252:
// 253:           return false if post_install_steps_block
// 254:
// 255:           step_lines = simple_install_step_lines(post_install_def.body,
// 256:                                                  default_base:        :var,
// 257:                                                  default_source_base: :prefix,
// 258:                                                  default_target_base: :prefix)
// 259:           return false if step_lines.blank?
// 260:
// 261:           add_offense(post_install_method,
// 262:                       message: format(SIMPLE_STEP_CONVERSION_MSG, steps_block: "post_install_steps")) do |corrector|
// 263:             corrector.replace(
// 264:               post_install_method.source_range,
// 265:               install_steps_block_source(:post_install_steps, step_lines, post_install_method.source_range.column),
// 266:             )
// 267:           end
// 268:           true
// 269:         end
// 270:
// 271:         sig {
// 272:           params(
// 273:             direct_nodes:      T::Array[RuboCop::AST::Node],
// 274:             formula_body:      RuboCop::AST::Node,
// 275:             step_nodes:        T::Hash[RuboCop::AST::Node, T::Array[String]],
// 276:             removable_methods: T::Array[RuboCop::AST::Node],
// 277:           ).void
// 278:         }
// 279:         def add_postgresql_step_nodes(direct_nodes, formula_body, step_nodes, removable_methods)
// 280:           log_node = direct_nodes.find { |node| normalised_install_step_source(node) == '(var/"log").mkpath' }
// 281:           datadir_node = direct_nodes.find do |node|
// 282:             normalised_install_step_source(node) == "postgresql_datadir.mkpath"
// 283:           end
// 284:           guard_node = direct_nodes.find do |node|
// 285:             normalised_install_step_source(node) == GITHUB_ACTIONS_GUARD_SOURCE
// 286:           end
// 287:           init_node = direct_nodes.find do |node|
// 288:             normalised_install_step_source(node).match?(POSTGRESQL_INIT_SOURCE_REGEX)
// 289:           end
// 290:           return if log_node.nil? || datadir_node.nil? || guard_node.nil? || init_node.nil?
// 291:           return unless nodes_in_source_order?([log_node, datadir_node, guard_node, init_node])
// 292:
// 293:           datadir_method = find_method_def(formula_body, :postgresql_datadir)
// 294:           marker_method = find_method_def(formula_body, :pg_version_exists?)
// 295:           return if datadir_method.nil? || marker_method.nil?
// 296:           return if normalised_install_step_source(datadir_method) != POSTGRESQL_DATADIR_METHOD_SOURCE
// 297:           return if normalised_install_step_source(marker_method) != POSTGRESQL_MARKER_METHOD_SOURCE
// 298:
// 299:           match = normalised_install_step_source(init_node).match(POSTGRESQL_INIT_SOURCE_REGEX)
// 300:           return if match.nil?
// 301:
// 302:           locale = match[1]
// 303:           step_nodes[log_node] = ["mkdir_p \"log\""]
// 304:           step_nodes[datadir_node] = []
// 305:           step_nodes[guard_node] = []
// 306:           init_step_line = "init_data_dir formula_name, using: :postgresql"
// 307:           init_step_line += ', locale: "C"' if locale == "C"
// 308:           step_nodes[init_node] = [init_step_line]
// 309:           pg_version_calls = formula_body.each_descendant(:send).count do |node|
// 310:             T.cast(node, RuboCop::AST::SendNode).method_name == :pg_version_exists?
// 311:           end
// 312:           removable_methods << marker_method if pg_version_calls == 1
// 313:         end
// 314:
// 315:         sig {
// 316:           params(
// 317:             direct_nodes: T::Array[RuboCop::AST::Node],
// 318:             formula_body: RuboCop::AST::Node,
// 319:             step_nodes:   T::Hash[RuboCop::AST::Node, T::Array[String]],
// 320:           ).void
// 321:         }
// 322:         def add_mysql_step_nodes(direct_nodes, formula_body, step_nodes)
// 323:           datadir_method = find_method_def(formula_body, :datadir)
// 324:           return if datadir_method.nil?
// 325:           return if normalised_install_step_source(datadir_method) != MYSQL_DATADIR_METHOD_SOURCE
// 326:
// 327:           add_mysql_data_step_nodes(direct_nodes, step_nodes, MYSQL_INITIALISE_SOURCE, :mysql)
// 328:         end
// 329:
// 330:         sig {
// 331:           params(
// 332:             direct_nodes: T::Array[RuboCop::AST::Node],
// 333:             step_nodes:   T::Hash[RuboCop::AST::Node, T::Array[String]],
// 334:           ).void
// 335:         }
// 336:         def add_mariadb_step_nodes(direct_nodes, step_nodes)
// 337:           add_mysql_data_step_nodes(direct_nodes, step_nodes, MARIADB_INITIALISE_SOURCE, :mariadb)
// 338:         end
// 339:
// 340:         sig {
// 341:           params(
// 342:             direct_nodes:      T::Array[RuboCop::AST::Node],
// 343:             step_nodes:        T::Hash[RuboCop::AST::Node, T::Array[String]],
// 344:             initialise_source: String,
// 345:             using:             Symbol,
// 346:           ).void
// 347:         }
// 348:         def add_mysql_data_step_nodes(direct_nodes, step_nodes, initialise_source, using)
// 349:           datadir_node = direct_nodes.find { |node| normalised_install_step_source(node) == '(var/"mysql").mkpath' }
// 350:           guard_node = direct_nodes.find do |node|
// 351:             normalised_install_step_source(node) == GITHUB_ACTIONS_GUARD_SOURCE
// 352:           end
// 353:           init_node = direct_nodes.find do |node|
// 354:             normalised_install_step_source(node) == initialise_source
// 355:           end
// 356:           return if datadir_node.nil? || guard_node.nil? || init_node.nil?
// 357:           return unless nodes_in_source_order?([datadir_node, guard_node, init_node])
// 358:
// 359:           step_nodes[datadir_node] = []
// 360:           step_nodes[guard_node] = []
// 361:           step_nodes[init_node] = ["init_data_dir \"mysql\", using: :#{using}"]
// 362:         end
// 363:
// 364:         sig {
// 365:           params(
// 366:             direct_nodes: T::Array[RuboCop::AST::Node],
// 367:             step_nodes:   T::Hash[RuboCop::AST::Node, T::Array[String]],
// 368:           ).void
// 369:         }
// 370:         def add_postgresql_link_step_nodes(direct_nodes, step_nodes)
// 371:           direct_nodes.each do |node|
// 372:             case normalised_install_step_source(node)
// 373:             when POSTGRESQL_LINK_DIR_SOURCE
// 374:               step_nodes[node] = [
// 375:                 "symlink_tree \"include/postgresql\", \"include/{{formula_name}}\"",
// 376:                 "symlink_tree \"lib/postgresql\", \"lib/{{formula_name}}\"",
// 377:                 "symlink_tree \"share/postgresql\", \"share/{{formula_name}}\"",
// 378:               ]
// 379:             when POSTGRESQL_LINK_CHILDREN_SOURCE
// 380:               step_nodes[node] = ["symlink_children \"bin\", suffix: \"-{{version.major}}\""]
// 381:             end
// 382:           end
// 383:         end
// 384:
// 385:         sig {
// 386:           params(
// 387:             direct_nodes: T::Array[RuboCop::AST::Node],
// 388:             step_nodes:   T::Hash[RuboCop::AST::Node, T::Array[String]],
// 389:           ).void
// 390:         }
// 391:         def add_certificate_symlink_step_nodes(direct_nodes, step_nodes)
// 392:           (0...(direct_nodes.length - 1)).each do |index|
// 393:             remove_node = direct_nodes.fetch(index)
// 394:             symlink_node = direct_nodes.fetch(index + 1)
// 395:             next if normalised_install_step_source(remove_node) != CERTIFICATE_REMOVE_SOURCE
// 396:             next if normalised_install_step_source(symlink_node) != CERTIFICATE_INSTALL_SYMLINK_SOURCE
// 397:
// 398:             step_nodes[remove_node] = []
// 399:             step_nodes[symlink_node] = [<<~RUBY.chomp]
// 400:               symlink "cert.pem", "cert.pem",
// 401:                       source_formula: "ca-certificates",
// 402:                       source_base: :formula_pkgetc,
// 403:                       target_base: :pkgetc,
// 404:                       overwrite: true
// 405:             RUBY
// 406:           end
// 407:         end
// 408:
// 409:         sig { params(nodes: T::Array[RuboCop::AST::Node]).returns(T::Boolean) }
// 410:         def nodes_in_source_order?(nodes)
// 411:           nodes.each_index.all? do |index|
// 412:             index.zero? || nodes.fetch(index - 1).source_range.begin_pos < nodes.fetch(index).source_range.begin_pos
// 413:           end
// 414:         end
// 415:
// 416:         sig {
// 417:           params(
// 418:             post_install_def:         RuboCop::AST::DefNode,
// 419:             post_install_steps_block: T.nilable(RuboCop::AST::BlockNode),
// 420:             direct_nodes:             T::Array[RuboCop::AST::Node],
// 421:             step_nodes:               T::Hash[RuboCop::AST::Node, T::Array[String]],
// 422:             removable_methods:        T::Array[RuboCop::AST::Node],
// 423:           ).void
// 424:         }
// 425:         def add_formula_step_conversion_offense(post_install_def, post_install_steps_block, direct_nodes, step_nodes,
// 426:                                                 removable_methods)
// 427:           step_lines = step_nodes.sort_by { |node, _| node.source_range.begin_pos }.flat_map(&:last)
// 428:           remaining_nodes = direct_nodes.reject { |node| step_nodes.key?(node) }
// 429:           add_offense(post_install_def,
// 430:                       message: format(SIMPLE_STEP_CONVERSION_MSG, steps_block: "post_install_steps")) do |corrector|
// 431:             if post_install_steps_block
// 432:               append_install_step_lines(corrector, post_install_steps_block, step_lines)
// 433:             elsif remaining_nodes.empty?
// 434:               corrector.replace(
// 435:                 post_install_def.source_range,
// 436:                 install_steps_block_source(:post_install_steps, step_lines, post_install_def.source_range.column),
// 437:               )
// 438:             else
// 439:               corrector.insert_before(
// 440:                 post_install_def.source_range,
// 441:                 "#{install_steps_block_source(:post_install_steps, step_lines,
// 442:                                               post_install_def.source_range.column)}\n\n" \
// 443:                 "#{" " * post_install_def.source_range.column}",
// 444:               )
// 445:             end
// 446:
// 447:             if post_install_steps_block || remaining_nodes.present?
// 448:               matched_install_step_node_groups(direct_nodes, step_nodes).each do |nodes|
// 449:                 corrector.remove(range_for_install_step_node_group(nodes))
// 450:               end
// 451:               if remaining_nodes.empty?
// 452:                 corrector.remove(range_with_surrounding_space(range: post_install_def.source_range, side: :left))
// 453:               end
// 454:             end
// 455:             removable_methods.each do |method|
// 456:               corrector.remove(range_with_surrounding_space(range: method.source_range, side: :left))
// 457:             end
// 458:           end
// 459:         end
// 460:
// 461:         sig {
// 462:           params(
// 463:             direct_nodes: T::Array[RuboCop::AST::Node],
// 464:             step_nodes:   T::Hash[RuboCop::AST::Node, T::Array[String]],
// 465:           ).returns(T::Array[T::Array[RuboCop::AST::Node]])
// 466:         }
// 467:         def matched_install_step_node_groups(direct_nodes, step_nodes)
// 468:           direct_nodes.chunk_while { |left, right| step_nodes.key?(left) && step_nodes.key?(right) }
// 469:                       .select { |nodes| step_nodes.key?(nodes.fetch(0)) }
// 470:         end
// 471:
// 472:         sig { params(nodes: T::Array[RuboCop::AST::Node]).returns(::Parser::Source::Range) }
// 473:         def range_for_install_step_node_group(nodes)
// 474:           first_range = range_by_whole_lines(nodes.fetch(0).source_range)
// 475:           last_range = range_by_whole_lines(nodes.fetch(-1).source_range, include_final_newline: true)
// 476:           range = ::Parser::Source::Range.new(processed_source.buffer, first_range.begin_pos, last_range.end_pos)
// 477:           prefix = processed_source.buffer.source[...range.begin_pos]
// 478:           preceding_blank_lines = prefix[/\n(?:[ \t]*\n)+\z/].to_s.length
// 479:           preceding_blank_lines -= 1 if preceding_blank_lines.positive?
// 480:           blank_lines = processed_source.buffer.source[range.end_pos..].to_s[/\A(?:[ \t]*\n)*/].to_s
// 481:           range.adjust(begin_pos: -preceding_blank_lines, end_pos: blank_lines.length)
// 482:         end
// 483:
// 484:         sig {
// 485:           params(
// 486:             node:              T.nilable(RuboCop::AST::Node),
// 487:             service_path_dirs: T::Array[InstallStepPath],
// 488:             block_name:        Symbol,
// 489:           ).void
// 490:         }
// 491:         def add_redundant_service_path_dirs_offense(node, service_path_dirs, block_name)
// 492:           return if node.nil? || service_path_dirs.empty?
// 493:           return unless redundant_service_path_dirs_block?(node, service_path_dirs, block_name)
// 494:
// 495:           add_offense(node, message: format(REDUNDANT_SERVICE_PATH_DIRS_MSG, block: block_name)) do |corrector|
// 496:             corrector.remove(range_with_surrounding_space(range: node.source_range, side: :left))
// 497:           end
// 498:         end
// 499:
// 500:         sig {
// 501:           params(
// 502:             node:              RuboCop::AST::Node,
// 503:             service_path_dirs: T::Array[InstallStepPath],
// 504:             block_name:        Symbol,
// 505:           ).returns(T::Boolean)
// 506:         }
// 507:         def redundant_service_path_dirs_block?(node, service_path_dirs, block_name)
// 508:           body = if node.def_type?
// 509:             T.cast(node, RuboCop::AST::DefNode).body
// 510:           elsif node.block_type?
// 511:             T.cast(node, RuboCop::AST::BlockNode).body
// 512:           end
// 513:           return false if body.nil?
// 514:
// 515:           direct_nodes = body.begin_type? ? body.child_nodes : [body]
// 516:           direct_nodes.all? do |direct_node|
// 517:             service_path_dirs.any? do |path_dir|
// 518:               redundant_service_path_dir?(direct_node, path_dir, block_name)
// 519:             end
// 520:           end
// 521:         end
// 522:
// 523:         sig {
// 524:           params(
// 525:             node:       RuboCop::AST::Node,
// 526:             path_dir:   InstallStepPath,
// 527:             block_name: Symbol,
// 528:           ).returns(T::Boolean)
// 529:         }
// 530:         def redundant_service_path_dir?(node, path_dir, block_name)
// 531:           return false unless node.send_type?
// 532:
// 533:           send_node = T.cast(node, RuboCop::AST::SendNode)
// 534:           path = if block_name == :post_install && send_node.method_name == :mkpath && send_node.arguments.empty?
// 535:             install_step_path(send_node.receiver)
// 536:           else
// 537:             return false unless [:mkdir, :mkdir_p].include?(send_node.method_name)
// 538:
// 539:             fileutils_receiver = block_name == :post_install &&
// 540:                                  send_node.receiver&.const_type? &&
// 541:                                  send_node.receiver&.const_name == "FileUtils"
// 542:             return false if send_node.receiver.present? && !fileutils_receiver
// 543:
// 544:             install_step_path_with_base(send_node.arguments.first, send_node.last_argument, default_base: :var)
// 545:           end
// 546:           paths_match?(path, path_dir)
// 547:         end
// 548:
// 549:         sig { params(block_node: T.nilable(RuboCop::AST::BlockNode)).returns(T::Array[InstallStepPath]) }
// 550:         def service_path_dirs(block_node)
// 551:           return [] if block_node.nil?
// 552:
// 553:           body = block_node.body
// 554:           return [] if body.nil?
// 555:
// 556:           direct_nodes = body.begin_type? ? body.child_nodes : [body]
// 557:           paths = direct_nodes.filter_map do |node|
// 558:             next unless node.send_type?
// 559:
// 560:             send_node = T.cast(node, RuboCop::AST::SendNode)
// 561:             next if send_node.receiver.present? || send_node.arguments.empty?
// 562:
// 563:             path = install_step_path(send_node.arguments.first)
// 564:             case send_node.method_name
// 565:             when :working_dir, :root_dir
// 566:               path
// 567:             when :input_path, :log_path, :error_log_path
// 568:               path_parent(path)
// 569:             end
// 570:           end
// 571:           paths.uniq { |path| path_key(path) }
// 572:         end
// 573:
// 574:         sig {
// 575:           params(
// 576:             node:         T.nilable(RuboCop::AST::Node),
// 577:             last_arg:     T.nilable(RuboCop::AST::Node),
// 578:             default_base: Symbol,
// 579:           ).returns(T.nilable(InstallStepPath))
// 580:         }
// 581:         def install_step_path_with_base(node, last_arg, default_base:)
// 582:           path = install_step_path(node)
// 583:           return if path.nil?
// 584:
// 585:           base = install_step_path_hash_base(last_arg)
// 586:           return InstallStepPath.new(path: path.path, base:) if base
// 587:           if path.base.nil? && !absolute_install_step_path?(path)
// 588:             return InstallStepPath.new(path: path.path,
// 589:                                        base: default_base)
// 590:           end
// 591:
// 592:           path
// 593:         end
// 594:
// 595:         sig { params(node: T.nilable(RuboCop::AST::Node)).returns(T.nilable(Symbol)) }
// 596:         def install_step_path_hash_base(node)
// 597:           return unless node&.hash_type?
// 598:
// 599:           T.cast(node, RuboCop::AST::HashNode).pairs.each do |pair|
// 600:             key = pair.key
// 601:             next unless key.sym_type?
// 602:             next if T.cast(key, RuboCop::AST::SymbolNode).value != :base
// 603:
// 604:             value = pair.value
// 605:             return T.cast(value, RuboCop::AST::SymbolNode).value if value.sym_type?
// 606:           end
// 607:           nil
// 608:         end
// 609:
// 610:         sig { params(path: T.nilable(InstallStepPath)).returns(T.nilable(InstallStepPath)) }
// 611:         def path_parent(path)
// 612:           return if path.nil?
// 613:
// 614:           parent_path = Pathname.new(path.path).dirname.to_s
// 615:           return if parent_path == "."
// 616:
// 617:           InstallStepPath.new(path: parent_path, base: path.base)
// 618:         end
// 619:
// 620:         sig { params(path: T.nilable(InstallStepPath), other_path: InstallStepPath).returns(T::Boolean) }
// 621:         def paths_match?(path, other_path)
// 622:           return false if path.nil?
// 623:
// 624:           path_key(path) == path_key(other_path)
// 625:         end
// 626:
// 627:         sig { params(path: InstallStepPath).returns([T.nilable(Symbol), String]) }
// 628:         def path_key(path)
// 629:           [path.base, path.path]
// 630:         end
// 631:       end
// 632:     end
// 633:   end
// 634: end

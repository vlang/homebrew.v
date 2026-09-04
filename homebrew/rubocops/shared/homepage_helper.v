module shared

import ruby

// Translated from Homebrew/brew `rubocops/shared/homepage_helper.rb`.
pub struct HomepageProblem {
pub:
	kind          string
	homepage_type string
	content       string
	begin_pos     int
	end_pos       int
	message       string
	replacement   string
}

fn homepage_type_name(homepage_type string) string {
	if homepage_type.len == 0 {
		return ''
	}
	return homepage_type[..1].to_upper() + homepage_type[1..]
}

fn homepage_freedesktop(content string) bool {
	prefix := 'http://'
	if !content.starts_with(prefix) {
		return false
	}
	remainder := content[prefix.len..]
	slash := remainder.index('/') or { return false }
	host := remainder[..slash]
	return host == 'freedesktop.org' || host in [
		'www.freedesktop.org',
		'nice.freedesktop.org',
		'libopenraw.freedesktop.org',
		'liboil.freedesktop.org',
		'telepathy.freedesktop.org',
		'xorg.freedesktop.org',
	]
}

fn homepage_google_code(content string) bool {
	prefix := if content.starts_with('https://code.google.com/p/') {
		'https://code.google.com/p/'
	} else if content.starts_with('http://code.google.com/p/') {
		'http://code.google.com/p/'
	} else {
		return false
	}
	project := content[prefix.len..]
	// This preserves the pinned Ruby regexp's two non-slash atoms.
	return project.len >= 2 && !project.contains('/')
}

fn homepage_sourceforge_legacy(content string) ?string {
	prefix := 'http://'
	if !content.starts_with(prefix) {
		return none
	}
	remainder := content[prefix.len..]
	host_end := remainder.index('/') or { remainder.len }
	host := remainder[..host_end]
	for suffix in ['.sourceforge.net', '.sf.net'] {
		if host.ends_with(suffix) {
			return host[..host.len - suffix.len]
		}
	}
	return none
}

fn homepage_http_upgrade(content string) bool {
	prefix := 'http://'
	if !content.starts_with(prefix) {
		return false
	}
	remainder := content[prefix.len..]
	host_end := remainder.index('/') or { remainder.len }
	host := remainder[..host_end]
	has_slash := host_end < remainder.len
	if content.starts_with('http://github.com/') || (host.ends_with('.github.io') && has_slash) || content.starts_with('http://savannah.nongnu.org/') || (host.ends_with('.sourceforge.io') && has_slash) {
		return true
	}
	if host == 'gnome.org' || host in [
		'build.gnome.org',
		'cloud.gnome.org',
		'developer.gnome.org',
		'download.gnome.org',
		'extensions.gnome.org',
		'git.gnome.org',
		'glade.gnome.org',
		'help.gnome.org',
		'library.gnome.org',
		'live.gnome.org',
		'nagios.gnome.org',
		'news.gnome.org',
		'people.gnome.org',
		'projects.gnome.org',
		'rt.gnome.org',
		'static.gnome.org',
		'wiki.gnome.org',
		'www.gnome.org',
	] {
		return true
	}
	return host.ends_with('.apache.org') || host == 'packages.debian.org' || content.starts_with('http://wiki.freedesktop.org/') || ((host == 'gnupg.org' || host == 'www.gnupg.org') && has_slash) || host == 'ietf.org' || (host.ends_with('.ietf.org') && !host[..host.len - '.ietf.org'.len].contains('.')) || (host.ends_with('.tools.ietf.org') && !host[..host.len - '.tools.ietf.org'.len].contains('.')) || content.starts_with('http://www.gnu.org/') || content.starts_with('http://code.google.com/') || content.starts_with('http://bitbucket.org/') || host == 'archive.org' || host.ends_with('.archive.org')
}

pub fn audit_homepage_content(homepage_type string, content string, homepage_begin int, homepage_end int, parameter_begin int, parameter_end int) []HomepageProblem {
	mut problems := []HomepageProblem{}
	type_name := homepage_type_name(homepage_type)
	if content.len == 0 {
		problems << HomepageProblem{
			kind: 'empty'
			homepage_type: homepage_type
			content: content
			begin_pos: homepage_begin
			end_pos: homepage_end
			message: '${type_name} should have a `homepage`.'
		}
	}
	if !content.starts_with('http://') && !content.starts_with('https://') {
		problems << HomepageProblem{
			kind: 'protocol'
			homepage_type: homepage_type
			content: content
			begin_pos: parameter_begin
			end_pos: parameter_end
			message: 'The `homepage` should start with http or https.'
		}
	}
	mut specific := HomepageProblem{}
	if homepage_freedesktop(content) {
		style := if content.contains('Software') {
			'https://wiki.freedesktop.org/www/Software/project_name'
		} else {
			'https://wiki.freedesktop.org/project_name'
		}
		specific = HomepageProblem{
			kind: 'freedesktop_style'
			message: 'Freedesktop homepages should be styled: ${style}'
		}
	} else if homepage_google_code(content) {
		specific = HomepageProblem{
			kind: 'google_code_slash'
			message: 'Google Code homepages should end with a slash'
			replacement: '"${content}/"'
		}
	} else if project := homepage_sourceforge_legacy(content) {
		fixed := 'https://${project}.sourceforge.io/'
		specific = HomepageProblem{
			kind: 'sourceforge_style'
			message: 'SourceForge homepages should be: ${fixed}'
			replacement: '"${fixed}"'
		}
	} else if content.contains('readthedocs.org') {
		fixed := content.replace_once('readthedocs.org', 'readthedocs.io')
		specific = HomepageProblem{
			kind: 'readthedocs_domain'
			message: 'Readthedocs homepages should be: ${fixed}'
			replacement: '"${fixed}"'
		}
	} else if content.starts_with('https://github.com') && content.ends_with('.git') {
		specific = HomepageProblem{
			kind: 'github_dot_git'
			message: 'GitHub homepages should not end with .git'
			replacement: '"${content[..content.len - '.git'.len]}"'
		}
	} else if homepage_http_upgrade(content) {
		specific = HomepageProblem{
			kind: 'https'
			message: 'Please use https:// for ${content}'
			replacement: '"${content.replace_once('http', 'https')}"'
		}
	}
	if specific.kind != '' {
		problems << HomepageProblem{
			...specific
			homepage_type: homepage_type
			content: content
			begin_pos: parameter_begin
			end_pos: parameter_end
		}
	}
	return problems
}

fn homepage_problem_value(problem HomepageProblem) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':          problem.kind
		'homepage_type': problem.homepage_type
		'content':       problem.content
		'begin_pos':     problem.begin_pos.str()
		'end_pos':       problem.end_pos.str()
		'message':       problem.message
		'replacement':   problem.replacement
	})
}

module shared

import brew_runtime

// Translated from Homebrew/brew `rubocops/shared/homepage_helper.rb`.
// The original source is retained below until every stub has a typed V body.
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

fn homepage_problem_value(problem HomepageProblem) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':          problem.kind
		'homepage_type': problem.homepage_type
		'content':       problem.content
		'begin_pos':     problem.begin_pos.str()
		'end_pos':       problem.end_pos.str()
		'message':       problem.message
		'replacement':   problem.replacement
	})
}

// Ruby method `audit_homepage(type, content, homepage_node, homepage_parameter_node)` at line 19.
pub fn ruby_homepage_helper_l19_d1_audit_homepage(args ...brew_runtime.Value) brew_runtime.Value {
	homepage_type := if args.len > 0 { args[0].as_string() } else { 'formula' }
	content := if args.len > 1 { args[1].as_string() } else { '' }
	homepage_begin := if args.len > 2 { int(args[2].int_data) } else { 0 }
	homepage_end := if args.len > 3 { int(args[3].int_data) } else { content.len }
	parameter_begin := if args.len > 4 { int(args[4].int_data) } else { homepage_begin }
	parameter_end := if args.len > 5 { int(args[5].int_data) } else { homepage_end }
	return brew_runtime.array_value(audit_homepage_content(homepage_type, content, homepage_begin, homepage_end, parameter_begin, parameter_end).map(homepage_problem_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shared/helper_functions"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     # This module performs common checks the `homepage` field in both formulae and casks.
// 9:     module HomepageHelper
// 10:       include HelperFunctions
// 11:
// 12:       sig {
// 13:         params(
// 14:           type: Symbol, content: String,
// 15:           homepage_node: RuboCop::AST::Node,
// 16:           homepage_parameter_node: RuboCop::AST::Node
// 17:         ).void
// 18:       }
// 19:       def audit_homepage(type, content, homepage_node, homepage_parameter_node)
// 20:         @offensive_node = T.let(homepage_node, T.nilable(RuboCop::AST::Node))
// 21:
// 22:         problem "#{type.to_s.capitalize} should have a `homepage`." if content.empty?
// 23:
// 24:         @offensive_node = homepage_parameter_node
// 25:         problem "The `homepage` should start with http or https." unless content.match?(%r{^https?://})
// 26:
// 27:         case content
// 28:           # Freedesktop is complicated to handle - It has SSL/TLS, but only on certain subdomains.
// 29:           # To enable https Freedesktop change the URL from http://project.freedesktop.org/wiki to
// 30:           # https://wiki.freedesktop.org/project_name.
// 31:           # "Software" is redirected to https://wiki.freedesktop.org/www/Software/project_name
// 32:         when %r{^http://((?:www|nice|libopenraw|liboil|telepathy|xorg)\.)?freedesktop\.org/(?:wiki/)?}
// 33:           if content.include?("Software")
// 34:             problem "Freedesktop homepages should be styled: https://wiki.freedesktop.org/www/Software/project_name"
// 35:           else
// 36:             problem "Freedesktop homepages should be styled: https://wiki.freedesktop.org/project_name"
// 37:           end
// 38:
// 39:           # Google Code homepages should end in a slash
// 40:         when %r{^https?://code\.google\.com/p/[^/]+[^/]$}
// 41:           problem "Google Code homepages should end with a slash" do |corrector|
// 42:             corrector.replace(homepage_parameter_node.source_range, "\"#{content}/\"")
// 43:           end
// 44:
// 45:         when %r{^http://([^/]*)\.(sf|sourceforge)\.net(/|$)}
// 46:           fixed = "https://#{Regexp.last_match(1)}.sourceforge.io/"
// 47:           problem "SourceForge homepages should be: #{fixed}" do |corrector|
// 48:             corrector.replace(homepage_parameter_node.source_range, "\"#{fixed}\"")
// 49:           end
// 50:
// 51:         when /readthedocs\.org/
// 52:           fixed = content.sub("readthedocs.org", "readthedocs.io")
// 53:           problem "Readthedocs homepages should be: #{fixed}" do |corrector|
// 54:             corrector.replace(homepage_parameter_node.source_range, "\"#{fixed}\"")
// 55:           end
// 56:
// 57:         when %r{^https://github.com.*\.git$}
// 58:           problem "GitHub homepages should not end with .git" do |corrector|
// 59:             corrector.replace(homepage_parameter_node.source_range, "\"#{content.delete_suffix(".git")}\"")
// 60:           end
// 61:
// 62:           # People will run into mixed content sometimes, but we should enforce and then add
// 63:           # exemptions as they are discovered. Treat mixed content on homepages as a bug.
// 64:           # Justify each exemptions with a code comment so we can keep track here.
// 65:           #
// 66:           # Compact the above into this list as we're able to remove detailed notations, etc over time.
// 67:         when
// 68:                # Check for `http://` GitHub homepage URLs, `https://` is preferred.
// 69:                # NOTE: Only check homepages that are repository pages, not `*.github.com` hosts.
// 70:                %r{^http://github\.com/},
// 71:                %r{^http://[^/]*\.github\.io/},
// 72:
// 73:                # Savannah has full SSL/TLS support but no auto-redirect.
// 74:                # Doesn't apply to the download URLs, only the homepage.
// 75:                %r{^http://savannah\.nongnu\.org/},
// 76:
// 77:                %r{^http://[^/]*\.sourceforge\.io/},
// 78:                # There's an auto-redirect here, but this mistake is incredibly common too.
// 79:                # Only applies to the homepage and subdomains for now, not the FTP URLs.
// 80:                %r{^http://((?:build|cloud|developer|download|extensions|git|
// 81:                                glade|help|library|live|nagios|news|people|
// 82:                                projects|rt|static|wiki|www)\.)?gnome\.org}x,
// 83:                %r{^http://[^/]*\.apache\.org},
// 84:                %r{^http://packages\.debian\.org},
// 85:                %r{^http://wiki\.freedesktop\.org/},
// 86:                %r{^http://((?:www)\.)?gnupg\.org/},
// 87:                %r{^http://ietf\.org},
// 88:                %r{^http://[^/.]+\.ietf\.org},
// 89:                %r{^http://[^/.]+\.tools\.ietf\.org},
// 90:                %r{^http://www\.gnu\.org/},
// 91:                %r{^http://code\.google\.com/},
// 92:                %r{^http://bitbucket\.org/},
// 93:                %r{^http://(?:[^/]*\.)?archive\.org}
// 94:           problem "Please use https:// for #{content}" do |corrector|
// 95:             corrector.replace(homepage_parameter_node.source_range, "\"#{content.sub("http", "https")}\"")
// 96:           end
// 97:         end
// 98:       end
// 99:     end
// 100:   end
// 101: end

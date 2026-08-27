module shared

import brew_runtime

// Translated from Homebrew/brew `rubocops/shared/homepage_helper.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_homepage(type, content, homepage_node, homepage_parameter_node)` at line 19.
pub fn ruby_homepage_helper_l19_d1_audit_homepage(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_homepage', ...args)
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

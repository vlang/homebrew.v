module lib

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/plist-3.7.2/lib/plist.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # encoding: utf-8
// 2:
// 3: # = plist
// 4: #
// 5: # This is the main file for plist. Everything interesting happens in
// 6: # Plist and Plist::Emit.
// 7: #
// 8: # Copyright 2006-2010 Ben Bleything and Patrick May
// 9: # Distributed under the MIT License
// 10: #
// 11:
// 12: require 'cgi'
// 13: require 'stringio'
// 14:
// 15: require_relative 'plist/generator'
// 16: require_relative 'plist/parser'
// 17: require_relative 'plist/version'

#! /usr/bin/ruby
# typed: strict

# This is a simple generator for creating the addons list displayed at
# https://github.com/yast/yast-registration/wiki/Available-SCC-Extensions-for-Use-in-Autoyast
# from the /var/log/YaST2/registration_addons.yml file.

require "yast"
require "registration/addon"
require "registration/addon_sorter"

require_relative "yaml_workaround"

INDENT_WIDTH = 2

# convert addon data to an XML document snippet
def dump_addon(a)
  prefix = " " * INDENT_WIDTH * 2
  prefix_outer = " " * INDENT_WIDTH

  ret = prefix_outer + "<addon>\n"

  ret += prefix + "<!-- #{a.name} -->\n"

  ret += prefix + "<!-- Depends on: #{a.depends_on.name} -->\n" if a.depends_on

  ret += prefix + "<name>#{a.identifier.encode(xml: :text)}</name>\n" +
    prefix + "<version>#{a.version.encode(xml: :text)}</version>\n" +
    prefix + "<arch>#{a.arch.encode(xml: :text)}</arch>\n"

  ret += prefix + "<reg_code>REG_CODE_REQUIRED</reg_code>\n" unless a.free

  ret += prefix_outer + "</addon>\n"

  ret
end

if ARGV[0]
  addons = YAML.load_file(ARGV[0])
  # sort the addons
  addons.sort!(&::Registration::ADDON_SORTER)

  puts "<addons config:type=\"list\">"
  puts addons.map { |a| dump_addon(a) }.join("\n")
  puts "</addons>"
else
  puts "This is a simple generator for AutoYaST addons configuration."
  puts
  puts "Usage: dump_ay_addons <file_path>"
  puts
  puts "  <file_path> is the addons dump file, originally stored at"
  puts "  /var/log/YaST2/registration_addons.yml"
  exit 1
end

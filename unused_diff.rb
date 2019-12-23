#!/usr/bin/env ruby

require 'fileutils'

MASTER_UNUSED_PATH = '../unused.master'.freeze
BRANCH_UNUSED_PATH = '../unused.branch'.freeze
MASTER_UNUSED_TMP_PATH = '../unused.master.tmp'.freeze
BRANCH_UNUSED_TMP_PATH = '../unused.branch.tmp'.freeze

puts ''
unless %w[--skip-master].include?(ARGV[0])
  system 'git checkout master'
  puts 'Analyzing master unused code...'
  system "git ls-files | grep .rb | xargs ctags -f tmp/tags && cat tmp/tags | unused -s -g none --stdin -C > #{MASTER_UNUSED_TMP_PATH}"

  File.delete(MASTER_UNUSED_PATH) if File.exist?(MASTER_UNUSED_PATH)
  FileUtils.cp(MASTER_UNUSED_TMP_PATH, MASTER_UNUSED_PATH)
  File.delete(MASTER_UNUSED_TMP_PATH)

  system 'git checkout -'
end

unless %w[--skip-branch].include?(ARGV[0])
  puts 'Analyzing branch unused code...'
  system "git ls-files | grep .rb | xargs ctags -f tmp/tags && cat tmp/tags | unused -s -g none --stdin -C > #{BRANCH_UNUSED_PATH}.tmp"

  File.delete(BRANCH_UNUSED_PATH) if File.exist?(BRANCH_UNUSED_PATH)
  FileUtils.cp(BRANCH_UNUSED_TMP_PATH, BRANCH_UNUSED_PATH)
  File.delete(BRANCH_UNUSED_TMP_PATH)
end

def clean_output(file_content)
  file_content.lines.map(&:strip).reject{|line| line.match?(/Unused: (.*)analyzing/) }
end

master = clean_output(File.read(MASTER_UNUSED_PATH))
branch = clean_output(File.read(BRANCH_UNUSED_PATH))

new_unused_lines = branch.reject{|line| master.include?(line)}

puts ''
if new_unused_lines.any?
  puts '❌ New unused code introduced by the current branch ❌'
  puts new_unused_lines
else
  puts '✅ No unused code was introduced by the current branch! :D ✅'
end
puts ''

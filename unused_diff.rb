MASTER_UNUSED_PATH = '../unused.master'.freeze
BRANCH_UNUSED_PATH = '../unused.branch'.freeze

# Unused Diff
# -----------
#
# This small script runs the unused library on both master and your current
# branch comparing the results and showing only the unused code introduced by
# the current branch.
#
# But it's kinda slow (full run takes ~17min in my machine) and CPU intensive :/
#
# Requirements:
# -------------
# - unused (brew tap joshuaclayton/formulae && brew install unused)
# - ctags  (brew install ctags)
#
# How to use:
# -----------
# > git checkout <branch you want to compare with master>
# > ruby unused_diff.rb
#
# Another option is to run
# > ruby unused_diff.rb --skip-master
#
# This will run the check without generating new unused analysis for the master
# it should be useful if you already performed the fixes and want to re-run the
# analysis just in your branch (comparing with the previous master output).

puts ''
unless %w[--skip-master].include?(ARGV[0])
  File.delete(MASTER_UNUSED_PATH) if File.exist?(MASTER_UNUSED_PATH)
  system 'git checkout master'
  puts 'Analyzing master unused code...'
  system "git ls-files | grep .rb | xargs ctags -f tmp/tags && cat tmp/tags | unused -s -g none --stdin -C > #{MASTER_UNUSED_PATH}"
end

unless %w[--skip-branch].include?(ARGV[0])
  File.delete(BRANCH_UNUSED_PATH) if File.exist?(BRANCH_UNUSED_PATH)
  system 'git checkout -'
  puts 'Analyzing branch unused code...'
  system "git ls-files | grep .rb | xargs ctags -f tmp/tags && cat tmp/tags | unused -s -g none --stdin -C > #{BRANCH_UNUSED_PATH}"
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

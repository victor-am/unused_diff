# Unused Diff

This small script runs the unused library on both master and your current branch comparing the results and showing only the unused code introduced by the current branch.

But it's kinda slow on and CPU intensive :/

## Requirements:
- unused (brew tap joshuaclayton/formulae && brew install unused)
- ctags  (brew install ctags)

## How to use:
```
git checkout <branch you want to compare with master>
./unused_diff.rb
```

Another option is to run
```
./unused_diff.rb --skip-master
```

This will run the check without generating new unused analysis for the master it should be useful if you already performed the fixes and want to re-run the analysis just in your branch (comparing with the previous master output).

GIT_CHANGED=git diff-index --name-only --diff-filter=ACMRX --merge-base origin/master '*.rb'
GIT_WORKING_DIR=git ls-files --others --exclude-standard '*.rb'

.PHONY: all

pre-push: test rubocop sorbet

.makegems: Gemfile.lock
	bundle install

test: .makegems
	bundle exec rspec

rubocop: .makegems
	bundle exec rubocop --autocorrect

sorbet: .makegems
	bundle exec tapioca gems
	bundle exec srb tc

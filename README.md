# Qpdf

Grand Rounds simple forking wrapper around the
[qpdf](https://github.com/qpdf/qpdf) executable.

We wrote it ourselves because there was no simple
Ruby wrapper for `qpdf`. It is roughly copied from the
[pdftk](https://rubygems.org/gems/pdftk) gem, which is not actively
maintained as of this writing.

## How to Create a Release

Releases happen in CircleCI when a tag is pushed to the repository.

To create a release, you will need to do the following:

1. Change the version in `qpdf.gemspec` to the new version and create a PR with the change.
1. Once the PR is merged, switch to the master branch and `git pull`.
1. `git tag <version from version.rb>`
1. `git push origin --tags`

CircleCI will see the tag push, build, and release a new version of the library.


# release-collator

My crackpot idea for a GH Action to collate changelogs/release notes

## Motivation

Change logs are great if you're a user of a project, but they can be a pain to maintain.

It's common to have a `CHANGELOG.md` file that each PR has to update with the PR title and a link to the PR.

The problem with this is that you don't know what your PR number is until you've created the PR.

You have to create the PR as a draft, get the number, update the `CHANGELOG.md` file, push your commit, and then mark the PR ready for review.

There are tools that will automate this process by prepending your PR title to the changelog file, so that's a definite improvement.

Both of these run into the same issue though. Every time a PR is merged, the changes to the `CHANGELOG.md` file cause merge conflicts with every other PR that's in progress.

This is a pain for contributors since it's a race to see who can get their PR merged before there are more merge conflicts to resolve.

This will be my attempt at solving the problem by distributing unreleased changes across multiple files, and then collating them into a single file when a release is made.

## Planned Solution

### Repository Preparation

1. Create a new directory in the project root called `unreleased_changes`
2. Add labels to the repository for each of the SemVer levels. e.g.
   1. `semver-epoch`
   2. `semver-major`
   3. `semver-minor`
   4. `semver-patch`

### PR Action

When a PR is created/updated, a github action will run that will perform the following:

1. Assert that the PR has a semver label.

2. Write a file in the `unreleased_changes` directory with the name `PR_<PR_NUMBER>.yml`. It will contain the following:

```yml
title: <PR Title>
labels: <PR Labels>
author: <PR Author>
pullRequest: <PR_NUMBER>
semver: <SemVer Level>
```

3. If `git` detects this has caused a change in the `unreleased_changes` directory, the action will commit the changes to the branch the PR is on.

### Collate Release Action

When the owner is ready to make a release, they will manually trigger the collate release action.

This action will:

1. Read all the files in the `unreleased_changes` directory
2. Sort them by `semver` level
3. Determine the next version number based on the highest semver level.
4. Render the changes into a `tmp/NEXT_VERSION_CHANGES.md` file
5. Prepend the contents of the `tmp/NEXT_VERSION_CHANGES.md` file to the `CHANGELOG.md` file
6. Delete all the files in the `unreleased_changes` directory
7. --- User may specify additional steps here e.g. `gem bump -v <NEXT_VERSION>`
8. Commit the changes in the repository to `main`
9. Tag the commit `<NEXT_VERSION>`
10. Push the commit and tag to the repository
11. Create a release on the repository from that tag and the contents of the `tmp/NEXT_VERSION_CHANGES.md` file

### Distributing The Release

The owner can then distribute the release as they see fit.

If they want to have additional automation with the release, then a github action can be created to run on the `release[published]` event.

From my experience with ruby gems where a `lib/<gem_name>/version.rb` file is updated with the new version number, `rake release` would be able to push the new version to rubygems.org without any further input.

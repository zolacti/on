# GH Action for Zola CLI - with deploy

![Build Status](https://img.shields.io/github/actions/workflow/status/knzai/zola-cli/test.yml)

A GitHub action that mostly replicates the [zola](https://github.com/getzola/zola) static site generator's [CLI](https://www.getzola.org/documentation/getting-started/cli-usage/). The default deploy options are included, with some details on how to explicitely specify a separate deploy action for full control.

## Table of Contents

 - [Notes](#Notes)
 - [Variables](#Variables)
 - [Examples](#Examples)
 - [Development](#Development)
 - [Acknowledgements](#Acknowledgements)

## Notes

If you want to push this content to GH Pages, make sure that workflows have read *and write* permissions in the repos **Settings > Actions > General > in Workflow permissions**

Also, after a push as been made pages branch (generally gh-pages) **Settings > General > Pages > Build and deployment** should be set to "deploy from a branch" and the branch you using for pages. GH's [internal action](https://github.com/actions/deploy-pages) will then handle pushing the artifact up and publishing.

Rather than redo a less powerful version of [James Ives' action for pushing content to gh-pages](JamesIves/github-pages-deploy-action) this repo just focuses actually running the zola commands and passes to that action for the default case. More advanced deployes should explicitely call that instead (see examples)

## Variables
Matches the flags and usage in the Zola CLI as closely as makes sense for a GH Action (there is no serve or init)

```yml
inputs:
  command:
    description: Specify zola command. Install is always run and idempotetent. Deploy runs all of them.
    required: false
    default: 'deploy'
    type: choice
    options:
      - install
      - check
      - build
      - both
      - deploy
  root:
    description: Directory to use as root of project 
    required: false
    default: '.'
    type: string
  config:
    description: Path to a config file other than config.toml in the root of project
    required: false
    default: 'config.toml'
    type: string
  base-url:
    description: Force the base URL to be that value (defaults to the one in config)
    required: false
    default: ''
    type: string
  drafts:
    description: Include drafts when loading the site
    required: false
    default: false
    type: boolean
  output-dir:
    description: Outputs the generated site in the given path (by default 'public' dir in project root)
    required: false
    default: 'public'
    type: string
  force:
    description: Force building the site even if output directory is non-empty
    required: false
    default: false
    type: boolean
```

## Examples

Check out the repo (with submodules for themes), build and push to gh-pages on after push to the main branch. The default GH Pages action will then deploy it, if set.
```yml
name: Deploy Zola to GH Pages
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
      with:
        submodules: true
    - uses: knzai/zola-cli@main
```

If you want more flexibility, like not running check, or different deploy options, etc, add an explicit JamesIves/github-pages-deploy-action with options.

Checks out out a different branch for the content, without submodules; skips the check by only running build; includes drafts; and passes some additional flags to the deploy (erasing history on the non standard branch it deploys to). This still depends on the default GH action to publish, unless you include an action to push the artifacts yourself.
```yml
name: Deploy Zola to GH Pages
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
      with:
        ref: site
    - uses: knzai/zola-cli@main 
      with:
        command: build
        drafts: true
        root: docs
    - name: Deploy 🚀
      uses: JamesIves/github-pages-deploy-action@v4
      with:
        folder: public
        single-commit: true
        branch: not-gh-pages
```

Deploy to gh-pages branch on a push to the main branch and it will just build (and check links) on pull requests
```yml
name: Deploy Zola to GH Pages
on:
  push:
    branches:
      - main 
  pull_request:
  
jobs:
  build:
    runs-on: ubuntu-latest
    if: github.ref != 'refs/heads/main'
    steps:
      -uses: knzai/zola-cli@main
       with:
         command: both
          
  build_and_deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: knzai/zola-cli@main
```


## Development

The test site lives in the `site` branch

The `idepempotent_install` branch is used for the logic for installing zola. For convenience during development and testing without an extra checkout, it is also [in a subtree](https://git-memo.readthedocs.io/en/latest/subtree.html) in the main repo via
```git subtree add --prefix idempotent_install idempotent_install``` If you aren't touching that you don't need to know about it.


## Acknowledgements

This project was a simplification of [my earlier version](zola-deploy-action) removing the GH Pages deploy logic to use more robust existing actions for that. My earlier version was a itself a port of [Shaleen Jain's Dockerfile based Zola Deploy Action](shalzz/zola-deploy-action) over to a composite action.

##

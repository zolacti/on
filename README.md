# Build (and/or deploy) a getzola/zola site

![Build Status](https://img.shields.io/github/actions/workflow/status/knzai/zola-build/test.yml)

Builds [zola](https://github.com/getzola/zola) static site generator's site and pushes to gh-pages. If you want a deploy with non default settings an example is giving explicitely calling [JamesIves/github-pages-deploy-action]
## Table of Contents

 - [Setup](#Setup)
 - [Variables](#Variables)
 - [Examples](#Examples)
 - [Development](#Development)
 - [Acknowledgements](#Acknowledgements)

## Setup

- If you want to push this content to GH Pages, make sure that workflows have read *and write* permissions in the repos **Settings > Actions > General > in Workflow permissions**

- Also, after a push as been made to the gh-pages branch (or manually create the branch first and avoid having to push twice) **Settings > General > Pages > Build and deployment** should be set to "deploy from a branch" and the branch you using for pages (gh-pages). GH's [internal action](https://github.com/actions/deploy-pages) will then handle pushing the artifact up and publishing if you set it in the above step.

## Variables
Matches the flags and usage in the Zola CLI as closely as makes sense for a GH Action (there is no serve or init)

```yml
inputs:
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
  deploy:
    description: Push to GitHub-Pages using JamesIves/github-pages-deploy-action defaults
    required: false
    default: true
    type: boolean
  check:
    description: Check external links with `zola check`
    required: false
    default: true
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
    - uses: knzai/zola-build@main
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
    - uses: knzai/zola-build@main 
      with:
        check: false
        deploy: false
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
      -uses: knzai/zola-build@main
       with:
         deploy: false
          
  build_and_deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: knzai/zola-build@main
```


## Development

The test site lives in the `site` branch

The `idepempotent_install` branch is used for the logic for installing zola. For convenience during development and testing without an extra checkout, it is also [in a subtree](https://git-memo.readthedocs.io/en/latest/subtree.html) in the main repo via
```git subtree add --prefix idempotent_install idempotent_install``` If you aren't touching that you don't need to know about it.


## Acknowledgements

This project was a simplification of [my earlier version](zola-deploy-action) removing the GH Pages deploy logic to use more robust [existing actions for that](JamesIves/github-pages-deploy-action). My earlier version was a itself a port of [Shaleen Jain's Dockerfile based Zola Deploy Action](shalzz/zola-deploy-action) over to a composite action. Mostly I wanted the option of maintaining history on the gh-pages branch and James Ives' action does that and more.

##

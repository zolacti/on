# GH Action for Zola CLI

![Build Status](https://img.shields.io/github/actions/workflow/status/knzai/zola-cli/test.yml)

A GitHub action that mostly replicates the [zola](https://github.com/getzola/zola) static site generator's [CLI](https://www.getzola.org/documentation/getting-started/cli-usage/). This is used for compiling the content before pushing it to somewhere, like GH-Pages

## Table of Contents

 - [Notes](#Notes)
 - [Variables](#Variables)
 - [Examples](#Examples)
 - [Development](#Development)
 - [Acknowledgements](#Acknowledgements)

## Notes

If you want to push this content to GH Pages, make sure that workflows have read *and write* permissions in the repos **Settings > Actions > General > in Workflow permissions**

Also, after a push as been made pages branch (generally gh-pages) **Settings > General > Pages > Build and deployment** should be set to "deploy from a branch" and the branch you using for pages. GH's [internal action](https://github.com/actions/deploy-pages) will then handle pushing the artifact up and publishing.

Rather than redo a less powerful version of [James Ives' action for pushing content to gh-pages](JamesIves/github-pages-deploy-action) this repo just focuses actually running the zola commands

## Variables
Matches the flags and usage in the Zola CLI as closely as makes sense for a GH Action (there is no serve or init)

```yml
inputs:
  command:
    description: specify zola command, otherwise defaults to both. Install is idempotent and always called
    required: false
    default: 'both'
    type: choice
    options:
      - install
      - check
      - build
      - both
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

This example will checkout the repo (with submodules for themes), build and push to gh-pages on after push to the main branch. The default GH Pages action will then deploy if set.

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
        submodules: true
    - uses: knzai/zola-cli@main #or action/zola-cli after I publish
    - name: Deploy 🚀
      uses: JamesIves/github-pages-deploy-action@v4
      with:
        folder: public
```

This example will build, check external links, and deploy to gh-pages branch on a push to the main branch
and it will just build on pull requests, with some extra parameters passed.
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
         command: build
         root: docs
         drafts: true
          
  build_and_deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: knzai/zola-cli@main
        with:
          command: both
          root: docs
          drafts: true
      - name: Deploy 🚀
        uses: JamesIves/github-pages-deploy-action@v4
        with:
          folder: public
```


## Development

The test site lives in the `site` branch

The `idepempotent_install` branch is used for the logic for installing zola. For convenience during development and testing without an extra checkout, it is also [in a subtree](https://git-memo.readthedocs.io/en/latest/subtree.html) in the main repo via
```git subtree add --prefix idempotent_install idempotent_install``` If you aren't touching that you don't need to know about it.


## Acknowledgements

This project was a simplification of [my earlier version](zola-deploy-action) removing the GH Pages deploy logic to use more robust existing actions for that. My earlier version was a itself a port of [Shaleen Jain's Dockerfile based Zola Deploy Action](shalzz/zola-deploy-action) over to a composite action.

##

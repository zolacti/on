# Build, check, and/or deploy a zola site

![Build Status](https://img.shields.io/github/actions/workflow/status/zolacti/on/test.yml)

Builds [zola](https://github.com/getzola/zola) static site generator's site and pushes to gh-pages, or installs and runs individual zola commands

## Setup

- If you want to push this content to GH Pages, make sure that workflows have read *and write* permissions in the repos **Settings > Actions > General > in Workflow permissions**

- Also, after a push as been made to the gh-pages branch (or manually create the branch first and avoid having to push twice) **Settings > General > Pages > Build and deployment** should be set to "deploy from a branch" and the branch you using for pages (gh-pages). GH's [internal action](https://github.com/actions/deploy-pages) will then handle pushing the artifact up and publishing if you set it in the above step.

## Notes

The logic for the actual zola commands is in subaction via `uses: owner/repo@ref` calls. Deploy is handled via [JamesIves/github-pages-deploy-action](https://github.com/JamesIves/github-pages-deploy-action) with default arguments. Call that action separately if you need different deploy settings. See examples below.

## Variables
Matches the flags and usage in the Zola CLI as closely as makes sense for a GH Action (there is no serve or init)

### zolacti/on@main (or @vn)
Main branch for running full builds/deploys
```yml
inputs:
  root:
    description: Directory to use as root of project. Deploy does not like this and requires an addition checkout in root
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

### zolacti/on@build
Command/subaction that just installs and runs zola build
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
```

### zolacti/on@check
Command/subaction that just installs and runs zola check
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
  drafts:
    description: Include drafts when loading the site
    required: false
    default: false
    type: boolean
```

## Examples

### Standard deploy
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
    - uses: zolacti/on@main
```

### Deploy with non-default parameters
If you want more flexibility, like not running check, or different deploy options, etc, add an explicit JamesIves/github-pages-deploy-action with options.

Checks out out a different branch for the content, without submodules; skips the check by only running build; includes drafts; and passes some additional flags to the deploy (erasing history on the non standard branch it deploys to). This still depends on the default GH action to publish, unless you include an action to push the artifacts yourself.
```yml
name: Deploy Zola to GH Pages
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    #the deploy action requires a checkout and it's messy to do a checkout in public first (gotta deal with deletes etc)
    #so it's simpler to checkout in root first, then content in folder. Or easier just don't use the root in such a way
    #that you can't have it still be in the root of the repo. Just checkout docs into the root! But you can do it:
    - uses: actions/checkout@master
    - uses: actions/checkout@master
      with:
        ref: docs
        path: docs
    - uses: zolacti/on@main 
      with:
        check: false
        deploy: false
        drafts: true
        root: docs
    - uses: actions/checkout@master #the deploy action requires a .git in root
    - name: Deploy 🚀
      uses: JamesIves/github-pages-deploy-action@v4
      with:
        folder: public
        single-commit: true
        branch: not-gh-pages
```

### Build or Deploy based on trigger
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
      -uses: zolacti/on@main
       with:
         deploy: false
          
  build_and_deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: zolacti/on@main
```

### Call individual commands/subactions
If you want to be able to run commands seperately for more flexibility then call this action with the appropriate @ref

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
    - uses: zolacti/on@build 
      with:
        drafts: true
        root: docs
        output-dir: not-public
    - name: Deploy 🚀
      uses: JamesIves/github-pages-deploy-action@v4
      with:
        folder: not-public
        single-commit: true
        branch: not-gh-pages
```

## Development

The test site lives in the `site` branch. There's a workflow in main that triggers on push to deploy the test site.

The commands/subactions with the logic are in their respective branches. 
## Acknowledgements

This project was a simplification of [my earlier version](zola-deploy-action) removing the GH Pages deploy logic to use more robust [existing actions for that](JamesIves/github-pages-deploy-action). My earlier version was a itself a port of [Shaleen Jain's Dockerfile based Zola Deploy Action](shalzz/zola-deploy-action) over to a composite action. Mostly I wanted the option of maintaining history on the gh-pages branch and James Ives' action does that and more.

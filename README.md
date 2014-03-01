setup
=====



# deploy

  Minimalistic shell deployment shell script.

## Installation

    $ make install

  Visit the [wiki](https://github.com/visionmedia/deploy/wiki) for additional usage information.

## Usage


      Usage: deploy [options] <env> [command]

      Options:

        -C, --chdir <path>   change the working directory to <path>
        -c, --config <path>  set config path. defaults to ./deploy.conf
        -T, --no-tests       ignore test hook
        -V, --version        output program version
        -h, --help           output help information

      Commands:

        setup                run remote setup commands
        update               update deploy to the latest release
        revert [n]           revert to [n]th last deployment or 1
        config [key]         output config file or [key]
        curr[ent]            output current release commit
        prev[ious]           output previous release commit
        exec|run <cmd>       execute the given <cmd>
        console              open an ssh session to the host
        list                 list previous deploy commits
        [ref]                deploy to [ref], the 'ref' setting, or latest tag

## Configuration

 By default `deploy(1)` will look for _./deploy.conf_, consisting of one or more environments, `[stage]`, `[production]`, etc, followed by directives.

    [stage]
    key /path/to/some.pem
    user deployer
    host n.n.n.n
    repo git@github.com:visionmedia/express.git
    path /var/www/myapp.com
    ref origin/master
    post-deploy /var/www/myapp.com/update.sh

## Directives

### key (optional)

  Path to identity file used by `ssh -i`.

      key /path/to/some.pem

### ref (optional)

  When specified, __HEAD__ is reset to `ref`. When deploying
  production typically this will _not_ be used, as `deploy(1)` will
  utilize the most recent tag by default, however this is useful
  for a staging environment, as shown below where __HEAD__ is updated
  and set to the develop branch.

        ref origin/develop

### user

  User for deployment.

       user deployer

### host

  Server hostname.

       host 50.17.255.50

### repo

  GIT repository to clone.

       repo git@github.com:visionmedia/express.git

### path

  Deployment path.

        path /var/www/myapp.com

### forward-agent

  Webhosts normally use read-only deploy keys to access private git repositories.
  If you'd rather use the credentials of the person invoking the deploy
  command, put `forward-agent yes` in the relevant config sections.
  Now the deploy script will invoke `ssh -A` when deploying and there's
  no need to keep SSH keys on your servers.

### needs_tty

  If your deployment scripts require any user interaction (which they shouldn't, but
  often do) you'll probably want SSH to allocate a tty for you. Put `needs_tty yes`
  in the config section if you'd like the deploy script to invoke `ssh -t` and ensure
  you have a tty available.

## Hooks

  All hooks are arbitrary commands, executed relative to `path/current`,
  aka the previous deployment for `pre-deploy`, and the new deployment
  for `post-deploy`. Of course you may specify absolute paths as well.

### pre-deploy

      pre-deploy ./bin/something

### post-deploy

      post-deploy ./bin/restart

### test

  Post-deployment test command after `post-deploy`. If this
  command fails, `deploy(1)` will attempt to revert to the previous
  deployment, ignoring tests (for now), as they are assumed to have run correctly.

      test ./something

## License

(The MIT License)

Copyright (c) 2011 TJ Holowaychuk &lt;tj@vision-media.ca&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.





Bang.sh - for easy Shell Scripting
==================================

[![Build Status](https://travis-ci.org/bellthoven/bangsh.png)](https://travis-ci.org/bellthoven/bangsh)

This framework is intended to help on easy bash script development. It is totally modularized.
It helps you developing new Bash Script programs by forcing you to modularize and organize
your code in functions, so that your program can be tested.

# Installation

You can clone the bang repository in any path. For instance,

```bash
cd /usr/local/
git clone git://github.com/bellthoven/bangsh.git
```

You can `cd bangsh` and then `bin/bang test`. It will run all test suites.
If all tests pass, you're good to go. In order to have a better experience,
add the `bin/` path to your `$PATH` environment variable, something like:

```bash
export PATH="$PATH:/usr/local/bangsh/bin/"
```

# Creating a new project

Since `bang` is now executable from any directory, you can create your own
project by typing:

```bash
bang new my_project
```

This command will create a directory called `my_project/`. There will be some
directories which are intended to place some specific files. They are listed below.

## Modules

A module is a bunch of functions that have a certain domain. It works like a
namespace for aggregating functions. The general idea is to have it isolated,
so it could be copied and pasted into another project in a such way it would
not rely on any other dependency but Bang.

### Example:

```bash
# modules/my_first_module.sh

function my_first_module_says () {
  echo "My first module says: $*"
}
```

Now, you can use the module in your executable file:

```bash
#!/usr/bin/env bash
source "/usr/local/bangsh/src/bang.sh"

b.module.require my_first_module

my_first_module_says "Hey!"
```

This will lookup into `modules/` path looking for the module and source it.
More directories can be added to the list with
*prepend_module_dir* and *append_module_dir*. Unfortunately, the framework is not fully documented, so you may have
to dig into its code to see what you can do. A good start point are the unit tests !

## Tasks

A task is like an action your executable will perform. It is how `bang new` and `bang test` work.
To see more about tasks, check [bang's executable](https://github.com/bellthoven/bangsh/blob/master/bin/bang)
function tarbz2 () {
  #! /bin/bash
  export COPY_EXTENDED_ATTRIBUTES_DISABLE=true
  export COPYFILE_DISABLE=true
  tar -c --exclude='._*' --exclude='.svn' --exclude='.DS_Store' --exclude='*.bak' --exclude='*~' -vjf "$@"
}

function targz () {
  #! /bin/bash
  export COPY_EXTENDED_ATTRIBUTES_DISABLE=true
  export COPYFILE_DISABLE=true
  tar -c --exclude='._*' --exclude='.svn' --exclude='.DS_Store' --exclude='*.bak' --exclude='*~' -vzf "$@"
}

function untarbz2 () {
  #! /bin/bash
  tar -xvjf "$@"
}

function untargz () {
  #! /bin/bash
  tar -xvzf "$@"
}
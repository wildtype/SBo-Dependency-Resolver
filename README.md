# SBo-Dependency-Resolver
For those who want to manually compile install slackware packages using slackbuilds, but don't want to manually track each package's dependencies. This script will list package dependencies ordered by which package must be installed first.

##Usage
Download SLACKBUILDS.TXT from slackbuilds.org (eg: https://slackbuilds.org/slackbuilds/14.2/SLACKBUILDS.TXT), put in the same directory as this script.

###Listing package dependencies
```
sbo_dependency_resolver xmonad
```

or

```
sbo_dependency_resolver Xmonad
```

results:
```
darkstar:~$ ./sbo_dependency_resolver xmonad
Required packages to install xmonad:
  ghc
  haskell-extensible-exceptions
  haskell-data-default-class
  haskell-data-default-instances-containers
  haskell-dlist
  haskell-data-default-instances-dlist
  haskell-data-default-instances-old-locale
  haskell-data-default-instances-base
  haskell-data-default
  haskell-X11
  haskell-utf8-string
  haskell-mtl
  xmonad
```

###searching package name with regexp
```
sbo_dependency_resolver '(py|neo)vim'
```

results:
```
darkstar:~$ sbo_dependency_resolver '(py|neo)vim'
Matched package name:
  pyvim
  neovim
```

#TODO
 * Install Slackware and actually use this script (shame I don't have slackware on my workstation rightnow).
 * Feature to list sources URL need to be downloaded, build the web version. Afterall, initially I made this script inspired by apt-web.
 * Improve interface, wording, and whatnot.
 * etc

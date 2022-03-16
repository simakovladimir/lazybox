#! /bin/sh

# Work in progress
# Enable input of optional arguments via kdialog or its DE-agnostic  alternative
# Split ok function: crypto (bidirectional), base64 (bidirectional), link extraction
# traps for exit codes on errors
# Smarter base64 en/de-code: with support for refs to labeled boundaries
# Create auxiliary subroutine where put all miscellaneous (non-public) builtins
#
# Since actual behavior of the lazybox is exactly defined by its variables,
#   various nasty hacks are supported but not welcome:
# 16 -- out=10 ; au
# 16 0- eval 'while true ; do echo hello ; done'
# 16 -- au -- -- au -- -- true
# 16 -- 16 -- 16 -- true
# All those tricks do not affect current environment as being executed within
#   "sandbox" (subshell). Nevertheless, use them on your own risk
#
# ax (standing for "AuXiliary") - miscellaneous tools
# go (standing for "GOogle&friends") - follow URLs and search requests
# ex (standing for "EXtract pattern") - extract lines from input text according to a given pattern (which specifies URLs by default). N.B. No whitespaces expected
# rx (standing for "Regular eXpressions") - convert character strings
# tx (standing for "TricKS") - base64 toys
# xx (standing for "eXXtra conspiracy") - (en|de)crypt input text
#
# TODO:
# up -- rUn & Play lazybox
# tt -- Take & puT data being processed
# pp -- create a named PiPe
# gp -- Generate a random secured Password
# es -- EScape command and arguments
# bx -- invoke ioBoX (KDialog wrapper)
#
# Passphrase should be passed in the most secure (i.e invisible) way
# Put into "entropy" hashed personal data

# Copyright 2017 Vladimir Simakov
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

return values 0 or 1

set \
  -e \
  -f \
  -u ; \

ax () \
  { \
    test \
      "$#" \
      -eq \
      0 && \
    { \
      rm \
        -f \
        "$ppi" \
        "$ppo" || \
      true ; \
      exit \
        "$(($out))" ; \
      } || \
    case \
      $1 \
      in \
      (up) \
      out="1" ; \
      exec \
        2>/dev/null ; \
      trap \
        ax \
        INT \
        TERM \
        EXIT ; \
      test \
        "$#" \
        -ge \
        2 ; \
      ppi=$( \
        ax \
          pp \
        ) ; \
      ppo=$( \
        ax \
          pp \
        ) ; \
      echo \
        "$2" | \
      grep \
        -q \
        -E \
        "^[-0bps]{2}\$" ; \
      aux="$2" ; \
      shift \
        2 ; \
      cmd=$( \
        ax \
          es \
          "$@" \
        ) ; \
      eval \
        "$cmd" \
        0<"$ppi" \
        1>"$ppo" & \
      foo="$!" ; \
      ax \
        tt \
        "${aux#?}" \
        -i \
        0<"$ppo" & \
      bar="$!" ; \
      ax \
        tt \
        "${aux%?}" \
        -o \
        1>"$ppi" && \
      true ; \
      res="$?" ; \
      wait \
        "$foo" && \
      true ; \
      res="$(($res | $?))" ; \
      wait \
        "$bar" && \
      true ; \
      res="$(($res | $?))" ; \
      test \
        "$res" \
        -eq \
        0 ; \
      out="0" ; \
      ;; \
      (tt) \
      test \
        "$#" \
        -eq \
        3 ; \
      echo \
        "$3" | \
      grep \
        -q \
        -E \
        "^-[io]\$" ; \
      shift \
        1 ; \
      case \
        $1 \
        in \
        (-) \
        cat ; \
        ;; \
        (0) \
        test \
          "$2" \
          = \
          "-i" && \
        cat \
          1>/dev/null || \
        cat \
          0</dev/null ; \
        ;; \
        ([bps]) \
        xsel \
          "-$@" ; \
        ;; \
        (*) \
        false ; \
        ;; \
        esac ; \
      ;; \
      (pp) \
      test \
        "$#" \
        -eq \
        1 ; \
      false && \
      true ; \
      until \
        test \
          "$?" \
          -eq \
          0 ; \
        do \
        foo=$( \
          mktemp \
            -u \
            -q \
            -t \
            -p \
            /tmp \
            "16_XXXXXXXXXX" \
          ) && \
        mkfifo \
          "$foo" && \
        true ; \
        done ; \
      printf \
        "%s" \
        "$foo" ; \
      ;; \
      (gp) \
      test \
        "$#" \
        -le \
        2 ; \
      foo="${2:-48}" ; \
      until \
        test \
          $(($foo % 4)) \
          -eq \
          0 ; \
        do \
        foo="$(($foo + 1))" ; \
        done ; \
      bar=$(($foo * 3 / 4)) ; \
      openssl \
        rand \
        "$bar" | \
      base64 \
        -w \
        0 | \
      head \
        --quiet \
        --bytes="${2:-48}" ; \
      ;; \
      (es) \
      shift \
        1 ; \
      for \
        foo \
        in \
        "$@" ; \
        do \
        echo \
          "$foo" | \
        sed \
          -E \
          "s/'/'\\\\''/g" | \
        { \
          bar=$( \
            cat \
            ) ; \
          printf \
            "'%s' " \
            "$bar" ; \
          } ; \
        done ; \
      ;; \
      (bx) \
      test \
        "$#" \
        -ge \
        3 ; \
      test \
        "$#" \
        -le \
        4 ; \
      case \
        $2 \
        in \
        (ed) \
        foo="inputbox" ; \
        ;; \
        (in) \
        test \
          "$#" \
          -eq \
          3 ; \
        foo="msgbox" ; \
        ;;
        (pw) \
        test \
          "$#" \
          -eq \
          3 ; \
        foo="password" ; \
        ;; \
        (*) \
        false ; \
        ;; \
        esac ; \
      shift \
        2 ; \
      kdialog \
        --caption \
        "LazyBox" \
        --title \
        "Psst! Your attention needed" \
        "--$foo" \
        "$@" ; \
      ;; \
      (*) \
      false ; \
      ;; \
      esac ; \
    } ; \

ex () \
  { \
    foo="" ; \
    test \
      "$#" \
      -eq \
      0 || \
    case \
      $1 \
      in \
      (ln) \
      test \
        "$#" \
        -eq \
        1 ; \
      foo="\\w+://[^[:space:]\"']*(?=[[:space:]]|\"|'|\$)" ; \
      ;; \
      (pn) \
      test \
        "$#" \
        -eq \
        1 ; \
      foo="(\\+[[:space:].-]?[[:digit:]]{1,3}[[:space:].-]?)?" ; \
      foo="$foo\\(?[[:digit:]]{2,3}\\)?[[:space:].-]?" ; \
      foo="$foo[[:digit:]]{3}[[:space:].-]?" ; \
      foo="$foo[[:digit:]]{2}[[:space:].-]?" ; \
      foo="$foo[[:digit:]]{2}" ; \
      ;; \
      (--) \
      case \
        $# \
        in \
        (1) \
        foo=$( \
          ax \
            bx \
            ed \
            "You know better what to put here"\
            "\\b\\w+\\b" \
          ) ; \
        ;; \
        (2) \
        foo="$2" ; \
        ;; \
        (*) \
        false ; \
        ;; \
        esac ; \
      ;; \
      (*) \
      false ; \
      ;; \
      esac ; \
    bar=$( \
      printf \
        "s\\001%s\\001\\002\$&\\002\\001g" \
        "$foo" \
      ) ; \
    grep \
      -E \
      "$foo" | \
    perl \
      -p \
      -e \
      "$bar" | \
    sed \
      -E \
      "y/\\o002/\\n/" | \
    grep \
      -E \
      "$foo" | \
    sort | \
    uniq ; \
    } ; \

fx () \
  { \
    foo="" ; \
    test \
      "$#" \
      -eq \
      0 || \
    case \
      $1 \
      in \
      (lo) \
      test \
        "$#" \
        -eq \
        1 ; \
      foo="s/./\\L&/g" ; \
      ;; \
      (up) \
      test \
        "$#" \
        -eq \
        1 ; \
      foo="s/\\b./\\U&/g" ; \
      ;; \
      (xx) \
      test \
        "$#" \
        -eq \
        1 ; \
      foo="s/([[:lower:]])|([[:upper:]])/\\U\\1\\L\\2/g" ; \
      ;; \
      (--) \
      case \
        $# \
        in \
        (1) \
        foo=$( \
          ax \
            bx \
            ed \
            "{your nastiest fantasy here}"\
            "s/sugar/honey/g" \
          ) ; \
        ;; \
        (2) \
        foo="$2" ; \
        ;; \
        (*) \
        false ; \
        ;; \
        esac ; \
      ;; \
      (*) \
      false ; \
      ;; \
      esac ; \
    sed \
      -E \
      "$foo" ; \
    } ; \

gx () \
  { \
    foo="" ; \
    test \
      "$#" \
      -eq \
      0 || \
    case \
      $1 \
      in \
      (du) \
      test \
        "$#" \
        -eq \
        1 ; \
      foo="https://duckduckgo.com/?q=" ; \
      ;; \
      (go) \
      test \
        "$#" \
        -eq \
        1 ; \
      foo="https://www.google.com/search?q=" ; \
      ;; \
      (wi) \
      test \
        "$#" \
        -eq \
        1 ; \
      foo="https://en.wikipedia.org/wiki/Special:Search?search=" ; \
      ;; \
      (--) \
      case \
        $# \
        in \
        (1) \
        foo=$( \
          ax \
            bx \
            ed \
            "Please, enter something what you think worth entering" \
          ) ; \
        ;; \
        (2) \
        foo="$2" ; \
        ;; \
        (*) \
        false ; \
        ;; \
        esac ; \
      ;; \
      (*) \
      false ; \
      ;; \
      esac ; \
    bar=$( \
      cat \
      ) ; \
    xdg-open \
      "$foo$bar" ; \
    } ; \

tx () \
  { \
    test \
      "$#" \
      -ge \
      1 ; \
    test \
      "$#" \
      -le \
      2 ; \
    case \
      $1 \
      in \
      (de) \
      test \
        "$#" \
        -eq \
        2 && \
      foo="$2" || \
      foo=$( \
        ax \
          bx \
          ed \
          "Your input is very important for us" \
          txt \
        ) ; \
      test \
        "$foo" \
        = \
        "--" || \
      { \
        echo \
          "$foo" | \
        grep \
          -q \
          -E \
          "^\\w+\$" && \
        bar=$( \
          mktemp \
            -q \
            -t \
            -p \
            /tmp \
            "16_XXXXXXXXXX.$foo" \
          ) && \
        exec \
          1>"$bar" ; \
        } ; \
      base64 \
        -d \
        -w \
        80 | \
      zcat ; \
      test \
        "$foo" \
        = \
        "--" ||
      xdg-open \
        "$bar" ; \
      ;; \
      (en) \
      test \
        "$#" \
        -eq \
        2 && \
      { \
        test \
          -e \
          "$2" && \
        test \
          -r \
          "$2" && \
        { \
          test \
            -f \
            "$2" || \
          { \
            test \
              -d \
              "$2" && \
            test \
              -x \
              "$2" ; \
            } ; \
          } ; \
        } || \
      test \
        "$#" \
        -eq \
        1 ; \
      { \
        test \
          "$#" \
          -eq \
          1 || \
        test \
          -f \
          "$2" && \
        cat \
          "${2:--}" || \
        tar \
          -c \
          -f \
          - \
          -C \
          "$2" \
          . ; \
        } | \
      gzip \
        --no-name \
        --best | \
      base64 \
        -w \
        80 ; \
      ;; \
      (*) \
      false ; \
      ;; \
      esac ; \
    } ; \

xx () \
  { \
    test \
      "$#" \
      -ge \
      1 ; \
    test \
      "$#" \
      -le \
      2 ; \
    echo \
      "$1" | \
    grep \
      -q \
      -E \
      "^(de|en)\$" ; \
    case \
      $# \
      in \
      (1) \
      foo=$( \
        ax \
          bx \
          pw \
          "Please, enter your (-_-)" \
        ) ; \
      bar="$foo" ; \
      test \
        "$1" \
        = \
        "de" || \
      bar=$( \
        ax \
          bx \
          pw \
          "And now, please, enter your (^_^)" \
        ) ; \
      test \
        "$foo" \
        = \
        "$bar" ; \
      ;; \
      (2) \
      foo="$2" ; \
      ;; \
      (*) \
      false ; \
      ;; \
      esac ; \
    case \
      $1 \
      in \
      (de) \
      base64 \
        -d \
        -w \
        80 | \
      openssl \
        enc \
        -aes-256-cbc \
        -d \
        -pass \
        "pass:$foo" | \
      zcat ; \
      ;; \
      (en) \
      gzip \
        --no-name \
        --best | \
      openssl \
        enc \
        -aes-256-cbc \
        -pass \
        "pass:$foo" | \
      base64 \
        -w \
        80 ; \
      ;; \
      esac ; \
    } ; \

ax \
  up \
  "$@" ; \

# lazybox

## Summary

A single POSIX-friendly shell script aggregating an updatable
collection of some useful tools designed to be executed in pipelines.
The goal is to create a list of aliases to common commandline patterns
as well as new commands with the shortest possible names

## Usage

Please, make sure that the `lazybox.sh` file is symlinked into a
`$PATH`-recognizable location under the name `16` (which means `lb` which
in turn means `lazybox`) with executable attribute. After that you can use
the tool in the following way:

```
16 <cmd> <args>
```

where `<cmd>` is a `16`-specific command and `<args>` are its arguments

Currently supported list of commands includes:

- `ax` (standing for "AuXiliary") - miscellaneous tools;

- `go` (standing for "GOogle&friends") - follow URLs and search requests;

- `ex` (standing for "EXtract pattern") - extract lines from input text
  according to a given pattern (which specifies URLs by default).
  No whitespaces expected;

- `rx` (standing for "Regular eXpressions") - convert character strings;

- `tx` (standing for "TricKS") - base64 toys;

- `xx` (standing for "eXXtra conspiracy") - (en|de)crypt input text

## Value

Because of using pipelines in main processing routine, the script always returns 0
except for the cases with invalid first argument or runtine errors (e.g. during `xsel`
execution)

## Important Notion

The work is still in progress. Please, refer to the `lazybox.sh` for more details

## License

MIT License

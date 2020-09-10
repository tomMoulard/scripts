# scripts
Useful scripts to manage a computer

## How to:
Script: <something>.<else>
README: <something>.md

## Installation
Get scripts locally
```bash
git clone https://github.com:tomMoulard/scripts ${HOME}/workspace/scripts
```

Install them, either way
### Bash way
Adding this to your `~/.bashrc` file:
```bash
[ -f "${HOME}/workspace/scripts" ] && PATH="${PATH}:${HOME}/workspace/scripts"

```

### Script way

```bash
$ ./install.sh
```

And have $HOME/.scripts in your PATH(`$PATH`).

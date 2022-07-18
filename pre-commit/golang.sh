#!/bin/bash

# //usr/bin/env go test "$0" "$@"; exit "$?"
DIR="$(mktemp -d)"

# TODO: it might be useless to recompile each time
cd /home/tm/workspace/scripts/pre-commit && \
	go test -c -o ${DIR}/go-pre-commit

cd - >/dev/null
${DIR}/go-pre-commit "$@"
# ${DIR}/go-pre-commit -test.v "$@"
EX="$?"

rm -r ${DIR}

exit ${EX}

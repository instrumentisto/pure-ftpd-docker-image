#!/bin/sh

set -e

PURE_PASSWDFILE=${PURE_PASSWDFILE:-/etc/pureftpd.passwd}
PURE_DBFILE=${PURE_DBFILE:-/etc/pureftpd.pdb}

if [ -f "$PURE_PASSWDFILE" ]; then
  pure-pw mkdb "$PURE_DBFILE" -f "$PURE_PASSWDFILE"
fi

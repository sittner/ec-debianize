#!/bin/bash

DEB_VERSION=`(cd etherlabmaster && dpkg-parsechangelog | sed -rne 's/^Version: ([0-9.]+(\+[0-9]*hg[0-9a-z]*)?).*$$/\1/p')`
DEB_ORIG="etherlabmaster_$DEB_VERSION.orig.tar.gz"

HG_REPOS="http://hg.code.sf.net/p/etherlabmaster/code"
HG_COMMIT=`(echo "$DEB_VERSION" | sed -rne 's/^[0-9.]+\+[0-9]*hg([0-9a-z]*)p([0-9a-z]*).*$$/\1/p')`
HG_DIR="etherlabmaster-hg"

PATCH_REPOS="http://hg.code.sf.net/u/uecasm/etherlab-patches"
PATCH_COMMIT=`(echo "$DEB_VERSION" | sed -rne 's/^[0-9.]+\+[0-9]*hg([0-9a-z]*)p([0-9a-z]*).*$$/\2/p')`

function cleanup {
  rm -rf "$HG_DIR"
}
trap cleanup EXIT
set -e

echo "Cloning HG commit $HG_COMMIT..."
hg clone $HG_REPOS "$HG_DIR" -r $HG_COMMIT

echo "Cloning patchset commit $PATCH_COMMIT..."
hg clone $PATCH_REPOS "$HG_DIR/.hg/patches" -r $PATCH_COMMIT

echo "Apply patchset..."
(cd $HG_DIR && hg qpush -a)

echo "Create source archive..."
(cd $HG_DIR && hg archive "../$DEB_ORIG")

echo "Extracting source..."
(cd etherlabmaster && tar xfz "../$DEB_ORIG" --strip 1)

echo "DONE."


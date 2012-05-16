TMPFILE=/tmp/tmp.$$

for f in v*; do
  sed 's/brridder/stephan' $f > $TMPFILE
  exit 1     # DEBUG
  mv $TMPFILE $f
fi
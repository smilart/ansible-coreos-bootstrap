#/bin/bash

PYTHON_HOME=/opt/python

set -e

cd $PYTHON_HOME

if [[ -e $PYTHON_HOME/.bootstrapped ]]; then
  exit 0
fi

PYPY_VERSION=6.0.0

if [[ -e $PYTHON_HOME/pypy-$PYPY_VERSION-linux_x86_64-portable.tar.bz2 ]]; then
  tar -xjf $PYTHON_HOME/pypy-$PYPY_VERSION-linux_x86_64-portable.tar.bz2
  rm -rf $PYTHON_HOME/pypy-$PYPY_VERSION-linux_x86_64-portable.tar.bz2
else
  wget -O - https://bitbucket.org/squeaky/portable-pypy/downloads/pypy-$PYPY_VERSION-linux_x86_64-portable.tar.bz2 |tar -xjf -
fi

mv -n pypy-$PYPY_VERSION-linux_x86_64-portable pypy

## library fixup
mkdir -p pypy/lib
[ -f /lib64/libncurses.so.5.9 ] && ln -snf /lib64/libncurses.so.5.9 $PYTHON_HOME/pypy/lib/libtinfo.so.5
[ -f /lib64/libncurses.so.6.1 ] && ln -snf /lib64/libncurses.so.6.1 $PYTHON_HOME/pypy/lib/libtinfo.so.5

mkdir -p $PYTHON_HOME/bin

cat > $PYTHON_HOME/bin/python <<EOF
#!/bin/bash
LD_LIBRARY_PATH=$HOME/pypy/lib:$LD_LIBRARY_PATH exec $HOME/pypy/bin/pypy "\$@"
EOF

chmod +x $PYTHON_HOME/bin/python
$PYTHON_HOME/bin/python --version

touch $PYTHON_HOME/.bootstrapped

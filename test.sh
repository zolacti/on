set -e 

if command -v foo > /dev/null 2>&1; then
    echo "FOO_INSTALLED=true"
fi

if command -v zola > /dev/null 2>&1; then
    echo "ZOLA_INSTALLED=true"
fi

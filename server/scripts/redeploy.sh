
echo -- cd kfly
cd $KFLY_HOME

echo -- git pull
git pull

server-rebuild

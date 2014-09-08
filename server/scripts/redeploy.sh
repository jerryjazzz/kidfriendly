
echo -- cd kfly
cd $KFLY_HOME

echo -- git pull
git pull

echo -- cd kfly/server/forever
cd $KFLY_HOME/server/forever

echo -- npm install
npm install

echo -- cd kfly/server
cd $KFLY_HOME/server

echo -- npm install
npm install

echo -- gulp build
node node_modules/gulp/bin/gulp.js build



cd $KFLY_HOME

echo -- git reset
git reset --hard HEAD

cd $KFLY_HOME/server

echo -- npm install
npm install

echo -- gulp build
node node_modules/gulp/bin/gulp.js build

echo -- initctl reload-configuration
sudo initctl reload-configuration

echo -- initctl reload improv-web
sudo initctl restart kfly/node

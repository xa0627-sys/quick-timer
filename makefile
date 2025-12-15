all:
./node_modules/.bin/pug index.pug
./node_modules/.bin/stylus -p index.styl > index.css
./node_modules/.bin/lsc -cb index.ls

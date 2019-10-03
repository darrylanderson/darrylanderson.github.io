git config user.name "Darryl Anderson"
git config user.email "6097929+darrylanderson@users.noreply.github.com"

rm package-lock.json

git checkout master
git pull origin master

find . -maxdepth 1 ! -name '_site' ! -name '.git' ! -name '.gitignore' -exec rm -rf {} \;
mv _site/* .
rm -R _site/

echo "www.darrylanderson.dev" > CNAME

git add -fA
git commit --allow-empty -m "$(git log develop -1 --pretty=%B)"
git push origin master

echo "deployed successfully"

#/bin/bash
echo -e "\033[0;32mCreating Public folder in GIT...\033[0m"
git init
git add .
git commit -m "First commit"
git remote add origin https://github.com/dkalyanreddy/dkalyanreddy.github.io.git
git push origin master
echo -e "\033[0;32mCompleted Creating git repo\033[0m"
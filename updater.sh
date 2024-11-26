#!/bin/bash

# A git repo aktuális könyvtárában vagyunk
# Ellenőrizzük, hogy a script a git repóban van-e

if [ ! -d ".git" ]; then
    echo "Ez a script csak git repositoryban futtatható."
    exit 1
fi

# A git reset --hard parancs végrehajtása
git reset --hard

# Ellenőrizni, hogy a git reset parancs sikeres volt-e
if [ $? -ne 0 ]; then
    exit 1
fi

# A git pull parancs végrehajtása
git pull

# Ellenőrizni, hogy a git pull parancs sikeres volt-e
if [ $? -eq 0 ]; then
    # Zöld színnel írás a sikeres frissítésről
    echo -e "\033[0;32mA git repository sikeresen frissítve.\033[0m"
fi

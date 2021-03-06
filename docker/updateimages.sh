#!/bin/bash

missing=$(uniq -u <(sort <(cat ignored <(git ls-remote --tags git://github.com/nim-lang/nim.git | sed -n 's/.*refs\/tags\/\(.*\)^{}/\1/p') <(docker images | sed -n 's/virtual_machine *\(v[^ ]*\).*/\1/p'))))
latest=$(git ls-remote --tags git://github.com/nim-lang/nim.git | sed -n 's/.*refs\/tags\/\(.*\)^{}/\1/p' | sed 's/v/0./' | sort -t. -n -k1,1 -k2,2 -k3,3 -k4,4 | sed 's/0./v/' | tail -n1)

while read -r line; do
  if [ ! -z "$line" ]; then
    echo $line > curtag
    cat curtag
    if [ "$line" == "$latest" ]; then
      docker build --no-cache -t "virtual_machine:$line" .
    else
      docker build --no-cache -t "virtual_machine:$line" -f Dockerfile_nopackages .
    fi
  fi
done <<< $missing

rm curtag

docker tag virtual_machine:$(docker images | sed -n 's/virtual_machine *\(v[^ ]*\).*/\1/p' | sort --version-sort | tail -n1) virtual_machine:latest

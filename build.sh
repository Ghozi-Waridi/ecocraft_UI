#!/bin/bash

echo "Checking Flutter installation..."

if [ -d "flutter" ]; then
    echo "Flutter exists, updating..."
    cd flutter
    git pull
    cd ..
else
    echo "Cloning Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

echo "Building project..."
./flutter/bin/flutter config --enable-web
./flutter/bin/flutter build web --release
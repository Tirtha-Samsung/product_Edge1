#!/usr/bin/env bash

cp config_presets/tp1x_product.config ./.config
echo "tp1x_product.config copied."

if [ -f $(pwd)/utils/flatbuild.sh ]; then
docker run --rm -v $(pwd):/root/product -w /root/product tizenrt/tizenrt:1.5.6 utils/build.sh $1 $2 $3 $4
else
docker run --rm -v $(pwd):/root/product -w /root/product tizenrt/tizenrt:1.5.6 tools/build.sh $1 $2 $3 $4
fi

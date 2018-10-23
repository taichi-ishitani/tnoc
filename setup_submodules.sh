#! /bin/bash -f
submodules=(
  env/tue
  env/axi_vip
)

for submodule in ${submodules[@]} ; do
  git submodule update --init ${submodule}
done

#!/bin/bash

set -ex

echo "Build project"
rojo build test-model.project.json --output model.rbxmx
echo "Remove .robloxrc from dev dependencies"
find Packages/Dev -name "*.robloxrc" | xargs rm -f
find Packages/_Index -name "*.robloxrc" | xargs rm -f
echo "Run static analysis"
roblox-cli analyze test-model.project.json
echo "Run tests"
roblox-cli run --load.model model.rbxmx --run bin/spec.lua

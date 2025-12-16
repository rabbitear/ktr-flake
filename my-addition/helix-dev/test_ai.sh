#!/usr/bin/env bash
# Test the ai-generate command
timeout 10 ./helix/target/release/hx --command "ai-generate hello world" /tmp/test.txt 2>&1 | head -20
echo "Test completed"

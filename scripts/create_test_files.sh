#!/bin/bash

DIR="test_files"
mkdir -p "$DIR"

# Create 1KB file
dd if=/dev/zero of="$DIR/file1KB" bs=1K count=1

# Create 1MB file
dd if=/dev/zero of="$DIR/file1MB" bs=1M count=1

# Create 1GB file
dd if=/dev/zero of="$DIR/file1GB" bs=1G count=1

echo "Test files created in $DIR:"

#!/bin/bash

echo "Check for existing go.mod and go.sum files."

GOMODFILE=go.mod
GOSUMFILE=go.sum

if [[ -f "$GOMODFILE" ]] && [[ -f "$GOSUMFILE" ]]; then
    echo "$GOMODFILE and $GOSUMFILE exists."
else
    echo "$GOMODFILE and $GOSUMFILE does not exist."
fi

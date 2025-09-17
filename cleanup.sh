#!/bin/bash
shopt -s nullglob

for group in *.ovpn; do
  base=$(echo "$group" | sed -E 's/[[:space:]]*\([0-9]+\)\.ovpn$/.ovpn/')
  base_name="${base%.ovpn}"

  # collect all matching files (with and without suffixes)
  files=("$base_name".ovpn "$base_name"*.ovpn)
  files=("${files[@]}") # normalize

  # if only one file, skip
  [ ${#files[@]} -le 1 ] && continue

  # sort by suffix number (or 0 if none), keep highest
  latest=$(printf "%s\n" "${files[@]}" |
    sed -E "s/.*\(([0-9]+)\)\.ovpn$/\1\t&/; t; s/\.ovpn$/0\t&/" |
    sort -n | tail -n1 | cut -f2)

  # delete all others
  for f in "${files[@]}"; do
    if [[ "$f" != "$latest" ]]; then
      rm -f -- "$f"
      echo "Deleted: $f"
    fi
  done

  # rename latest -> base.ovpn
  if [[ "$latest" != "$base_name.ovpn" ]]; then
    mv -- "$latest" "$base_name.ovpn"
    echo "Renamed: $latest -> $base_name.ovpn"
  else
    echo "Kept: $latest"
  fi
done

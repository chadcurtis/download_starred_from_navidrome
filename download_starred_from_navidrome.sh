#!/bin/bash

# download_starred_from_navidrome.sh
# Script to programatically download starred (favorited) songs from a Navidrome instance

# Set to whichever directory you're pulling music files in from
BASEDIR=~/Music

# Navidrome Info
USERNAME=""
HOST=""

# Any leading path that should not be included when attempting to replicate host's file structure locally
NOPATH="/music/"

# Navigate to download dir
cd $BASEDIR

# Attempt to grab auth items
read -sp "Enter your password: " password
auth=$(curl -sk --json "{\"username\": \"$USERNAME\", \"password\": \"$password\"}" "$HOST/auth/login")
id=$(jq -r '.id' <<< $auth)
token=$(jq -r '.token' <<< $auth)
subsonic_token=$(jq -r '.subsonicToken' <<< $auth)
subsonic_salt=$(jq -r '.subsonicSalt' <<< $auth)
for auth_item in $id $token $subsonic_token $subsonic_salt; do
  if [[ "$auth_item" = 'null' ]]; then
    echo "One or more auth elements wasn't provided. Check your username and/or password."
    exit 1
  fi
done
echo "Auth acquired!"

# Grab starred (favorited) songs - the file path on the host and the song ID
list=$(curl -sk -H "x-nd-client-unique-id: $id" -H "x-nd-authorization: Bearer $token" "$HOST/api/song?&starred=true&_order=DESC&_sort=starred%20ASC%2C%20starredAt%20ASC&_start=0")

# Attempt to parse list of starred songs and download each
total=$(jq -r '.[] | .path' <<< $list | wc -l)
current=1
jq -r '.[] | "\(.path) | \(.id)"' <<< $list | while IFS='|' read item song_id; do 
  song_id=$(awk '{$1=$1};1' <<< $song_id)
  file_name=$(grep -Po '\/(?:.(?!\/))+$' <<< $item | sed 's|/||')
  file_path=$(grep -Po '\/((?:.(?!\/)).+\/)' <<< $item | sed "s|$NOPATH||")
  full_path="./${file_path}${file_name}"
  full_path=$(awk '{$1=$1};1' <<< $full_path)
  if [[ -f "$full_path" ]]; then
    echo "'$full_path' exists, skipping..."
  else
    mkdir -p "./${file_path}" # Create the host file path locally
    echo "[$current/$total] Downloading '$full_path'"
    curl -sk -H "x-nd-client-unique-id: $id" -H "x-nd-authorization: Bearer $token" "$HOST/rest/download?u=${USERNAME}&t=${subsonic_token}&s=${subsonic_salt}&f=json&v=1.8.0&c=NavidromeUI&id=${song_id}&format=raw&bitrate=0" -o "$full_path"
  fi
  current=$((current+1))
done
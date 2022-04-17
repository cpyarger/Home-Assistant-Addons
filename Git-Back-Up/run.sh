#!/bin/sh
export LANG=C
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

CONFIG_PATH=/data/options.json
  include_secrets_file="$(jq --raw-output '.include_secrets_file' $CONFIG_PATH)"
  deployment_key="$(jq --raw-output '.deployment_key' $CONFIG_PATH)"
  deployment_key_protocol="$(jq --raw-output '.deployment_key_protocol' $CONFIG_PATH)"
  deployment_password="$(jq --raw-output '.deployment_password' $CONFIG_PATH)"
  deployment_user="$(jq --raw-output '.deployment_user' $CONFIG_PATH)"
  git_branch="$(jq --raw-output '.git_branch' $CONFIG_PATH)"
  git_remote="$(jq --raw-output '.git_remote' $CONFIG_PATH)"
  repository="$(jq --raw-output '.repository' $CONFIG_PATH)"



if [! -d /config/.git ]; then
  echo Not yet a git repo;
  #echo "# git-back-up" >> README.md
  #git init
  #git add README.md
  #git commit -m "first commit"
  #git branch -M main
  #git remote add origin git@github.com:cpyarger/git-back-up-backup.git
  #git push -u origin main
fi;

echo "Git Back Up Start"

inotifywait  -r -e close_write,moved_to,create -m /config |
while read -r directory events filename; do
  if [[ "$filename" == *".yaml"* ]] || [[ "$filename" == *".Yaml"* ]] || [[ "$filename" == *".YAML"* ]]; then
    echo "File" $events ": " $directory$filename
  fi
done
sleep 1
echo "Git Back Up Start"

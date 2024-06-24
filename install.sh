#!/usr/bin/env bash

echo -e "\n"

echo -e "✅️ Making sure there's a $HOME/.local/bin...\n"
if [[ ! -d "$HOME/.local/bin" ]]; then
  mkdir -p $HOME/.local/bin
  if [[ $? -ne 0 ]] ; then
      echo -e "\n❌️ Failed to create $HOME/.local/bin... Exiting...\n"
      exit 1
  fi
fi

echo -e "\n💾️ Copying cpdf to $HOME/.local/bin...\n"
cp cpdf $HOME/.local/bin


echo -e "\n${GREEN}**************"
echo -e " 💯️ COMPLETED"
echo -e "**************${NC}\n"

echo -e "⚠️  Make sure $HOME/.local/bin is already in \$PATH...\n"

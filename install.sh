#!/usr/bin/env bash
ruby=`which ruby`

function add_alias() {
	cd ~/.aa-vimeo-downloader
	aavimeodownloader=$PWD/getaavids.rb
	echo "alias getaavids='"$ruby" "$aavimeodownloader"'" >> $1
}

if 	[ -e ~/.aliases ]
then
	echo "Aren't you fancy, with your aliases file. You fancy pants"
	add_alias ~/.aliases	
elif [ -e ~/.profile ]
then
	echo "Oh look at you, you've got a Mac, .bashrc ain't good enough for you, that's cool though, .profile is hip"
	add_alias ~/.profile
elif [ -e ~/.bashrc  ]
then
	echo "Aw yee .bashrc vanilla nix wassup"
	add_alias ~/.bashrc
elif [ -e ~/.zshrc]
then
	echo "bash aint good enough for you? You just have to rock the boat don't you? Filthy zshell user!"
	echo "... it's okay, I'll install in your .zshrc anyways."
	add_alias ~/.zshrc
else
	echo "ERROR: Could not find ~/.aliases, ~/.profile, ~/.zshrc or ~/.bashrc"
fi

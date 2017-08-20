# aa-vimeo-downloader

A script for App Academy students which downloads the day's videos

## Usage

```bash
getaavids <week+day> <url to readme raw>
```

"_<week+day>_" could be _w4d1_, _w2d2_, etc.

To get the url for the readme raw, simply navigate to the README.md file and select _raw_. 
Once your screen is filled with plain, unformatted text, grab the url.

Here's an example where the user wants to download all the week 2, day 4 videos (with the url truncated):

```bash
getaavids w2d4 https://raw.githubusercontent.com/appacademy/curriculum/.......
```

The program will make a folder called _W2D4_videos_ and place all the day's videos in that folder. It might be smart to
navigate to the user's _Videos_ directory before running this script!

## Install

### via copy-pasting this shell script into your terminal:
```bash
cd && \
git clone https://github.com/candyapplecorn/aa-vimeo-downloader.git && \
mv aa-vimeo-downloader .aa-vimeo-downloader && \
cd .aa-vimeo-downloader && \
bash install.sh && \
exec bash
```

### Manual:

After cloning this repository, run the install shell script like so:

```bash 
bash install.sh
```

This will add an alias to your `.profile`, `.bashrc`, `.asliases` or .`zshrc`, whichever one is found first.
The alias will allow the user to run _getaavids.rb_ by entering `getaavids` in the command line.

## Dependencies

This program requires youtube-dl. I've added an automatic installer to the program, so the user doesn't have to install it manually.
If you'd like to install it manually, refer to its website: [https://rg3.github.io/youtube-dl/](https://rg3.github.io/youtube-dl/)

## Video Playback

If you don't have a video player which allows the playback speed to be adjusted, consider giving VLC a try. [https://www.videolan.org/vlc/index.html](https://www.videolan.org/vlc/index.html)

download_starred_from_navidrome.sh
========================

`download_starred_from_navidrome.sh` is a basic Bash script that allows one to download all starred/favorited/liked songs from a Navidrome instance.

*This is a script for my personal use case, but hopefully you may find some usefulness in it as well.*

Requirements
--

- Bash
- A Navidrome instance
- `curl`
- `jq`


How to use
---

Within the script, modify the following variables to match your use case:

- `NOPATH` - Any leading path string that you would need to remove from the full local path on the Navidrome host. This is used to recreate the directory structure locally. Defaults to `/music/`.
- `BASEDIR` - Your music directory. Defaults to `~/Music`.
- `USERNAME` - Your Navidrome username. Defaults to `""`.
- `HOST` - Your Navidrome host domain. Defaults to `""`.

To execute, use the following commands:
* `chmod +x ./download_starred_from_navidrome.sh`
* `./download_starred_from_navidrome.sh`

You will be prompted for your password at runtime. When the prompt appears, type your password, press Enter, and the script should automatically continue.


If your credentials were not accepted, you will see the following output:
```
"One or more auth elements wasn't provided. Check your username and/or password."
```

Otherwise, the script will begin to parse and download a list of your starred songs from the Navidrome host.
# 👻 GhostGrab

**GhostGrab** is a standalone PowerShell tool for downloading videos from various platforms — including YouTube, Instagram, TikTok, and more — with no browser or app overhead.

> **Disclaimer:** This project is for educational and academic purposes only.  
> It is not intended for production use or to handle copyrighted or sensitive material.

<br>

## 📑 Table of Contents

- [What Is It?](#-what-is-it)
- [How It Works?](#-how-it-works)
- [Installation](#-installation)
- [Usage](#-usage)
- [Example Output](#-example-output)
- [Future Plans](#-future-plans)
- [Contributing](#-contributing)
- [License](#-license)
- [Third-Party Licenses](#-third-party-licenses)

<br>

## ❓ What Is It?

**GhostGrab** is a CLI utility written in PowerShell 7+ that automates the video download process using `yt-dlp` and `ffmpeg`. It avoids browser-based bottlenecks and handles everything natively via terminal — ideal for clean, fast, and repeatable downloads.

It also supports:
- Cookie-based authentication
- Filename customization and sanitization
- Custom output directories
- Pre-flight checks for dependencies and system compatibility
- (Experimental) Optional log configuration — selection prompt exists, but logs are not yet functional

<br>

## ⚙️ How It Works?

1. Verifies PowerShell 7+ is being used.
2. Checks for required tools (`yt-dlp.exe` and `ffmpeg.exe`).
3. Asks for the video URL and validates it.
4. Prompts for log preference (not yet functional).
5. Checks if authentication is needed (via domain cookies).
6. Retrieves the video title and allows filename override.
7. Asks for the output folder (default is `downloads/`).
8. Attempts download — using cookies if needed.
9. Verifies success, logs if enabled, and cleans up.

> Everything happens via terminal prompts — lightweight and interactive.

<br>

## 📦 Installation

There’s no installer. Just extract and run.

1. Download the latest `.zip` from the [Releases](https://github.com/Nespre/ghostgrab/releases) page.
2. Extract the archive.
3. Double-click `downloader.exe` or launch `downloader.ps1` in PowerShell 7+.

All dependencies (yt-dlp, ffmpeg, folder structure, etc.) come bundled.

<br>

## 🚀 Usage

Once launched, you'll be guided via terminal prompts:
1. Paste the video URL.
2. Choose whether to enable logging.
3. If required, provide cookie file (placed in the /cookies folder).
4. Customize the output filename and directory if desired.
5. Let GhostGrab do the rest.

> Tip: Cookie files should be named like cookies_tiktok.com.txt, cookies_youtube.com.txt, etc.

<br>

## 🧪 Example Output

```
[OK] Running with PowerShell version 7.4.1

[INFO] Current directory: C:\GhostGrab\scr
[INFO] Checking folder: C:\GhostGrab\tools

Enter video/page URL.
Or type 'L' to reconfigure log preferences.
Insert URL: https://www.youtube.com/watch?v=abc123

[INFO] Checking if this video requires authentication or cookies...

[OK] No authentication required.

Default file name: lo-fi_beats_to_study
Type desired file name (or press ENTER to use Default): study-mix

Default output directory: C:\GhostGrab\downloads
Type desired output directory (or press ENTER to use Default): D:\Videos\YT

[INFO] Attempting download WITHOUT cookies...

Output file: D:\Videos\YT\study-mix.mp4
```

<br>

## 🛣️ Future Plans

Some planned enhancements include:

* Playlist downloads
* Quality and format selection (mp3, mkv, etc.)
* Better error messaging
* Separate folders for video/audio outputs
* Subtitles detection and handling
* Visual download progress bar
* cookies.txt fetcher (via helper .exe)
* Full support for logs/ output
* Make a clean and intuitive interface

<br>

## 🤝 Contributing

Pull requests are welcome!

Feel free to open issues for suggestions, bug reports, or improvements.
Let’s make GhostGrab even better — together.

<br>

## 📄 License

This project is licensed under the MIT License. See LICENSE for details.

<br>

## 📄 Third-Party Licenses

This project uses the following third-party tools:

- [yt-dlp](https://github.com/yt-dlp/yt-dlp): Licensed under [Unlicense and GPLv3](https://github.com/yt-dlp/yt-dlp/blob/master/LICENSE).
- [ffmpeg](https://ffmpeg.org): Licensed under [LGPL-2.1 or GPL-2.0](https://ffmpeg.org/legal.html), depending on build configuration.

These tools are redistributed in their original binary form for user convenience. Please consult their official license pages for more information.

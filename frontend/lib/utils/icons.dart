import 'package:flutter/material.dart';

class AppIconMapper {
  static const Map<String, String> _domainMap = {
    // 🌐 Browsers
    'chrome': 'google.com',
    'msedge': 'microsoft.com',
    'firefox': 'mozilla.org',
    'brave': 'brave.com',
    'opera': 'opera.com',
    'vivaldi': 'vivaldi.com',
    'tor': 'torproject.org',
    'safari': 'apple.com',

    // 💬 Social & Chat
    'discord': 'discord.com',
    'slack': 'slack.com',
    'whatsapp': 'whatsapp.com',
    'telegram': 'telegram.org',
    'teams': 'microsoft.com', // MS Teams
    'skype': 'skype.com',
    'zoom': 'zoom.us',
    'signal': 'signal.org',
    'messenger': 'messenger.com',
    'viber': 'viber.com',

    // 💻 Coding & Dev
    'code': 'code.visualstudio.com', // VS Code
    'devenv': 'visualstudio.microsoft.com', // Visual Studio
    'studio64': 'developer.android.com', // Android Studio
    'idea64': 'jetbrains.com', // IntelliJ
    'pycharm64': 'jetbrains.com',
    'webstorm64': 'jetbrains.com',
    'golang64': 'jetbrains.com', // GoLand
    'github': 'github.com',
    'git': 'git-scm.com',
    'docker': 'docker.com',
    'postman': 'postman.com',
    'sublime_text': 'sublimetext.com',
    'notepad++': 'notepad-plus-plus.org',
    'cmd': 'microsoft.com',
    'powershell': 'microsoft.com',
    'terminal': 'microsoft.com',

    // 🎵 Media & Creative
    'spotify': 'spotify.com',
    'vlc': 'videolan.org',
    'itunes': 'apple.com',
    'audacity': 'audacityteam.org',
    'obs64': 'obsproject.com',
    'photoshop': 'adobe.com',
    'illustrator': 'adobe.com',
    'premiere': 'adobe.com',
    'afterfx': 'adobe.com',
    'blender': 'blender.org',
    'figma': 'figma.com',
    'canva': 'canva.com',

    // 🎮 Games & Launchers
    'steam': 'steampowered.com',
    'epicgameslauncher': 'epicgames.com',
    'battlenet': 'blizzard.com',
    'origin': 'ea.com',
    'riotclient': 'riotgames.com',
    'league of legends': 'leagueoflegends.com',
    'valorant': 'playvalorant.com',
    'minecraft': 'minecraft.net',
    'roblox': 'roblox.com',
    'csgo': 'counter-strike.net',
    'dota2': 'dota2.com',
    'fortnite': 'fortnite.com',

    // 📄 Office & Productivity
    'winword': 'office.com', // Word
    'excel': 'office.com',
    'powerpnt': 'office.com', // PowerPoint
    'outlook': 'office.com',
    'onenote': 'onenote.com',
    'notion': 'notion.so',
    'evernote': 'evernote.com',
    'trello': 'trello.com',
    'acrobat': 'adobe.com', // Adobe Reader

    // ⚙️ System & Utils
    'explorer': 'microsoft.com',
    'taskmgr': 'microsoft.com',
    'settings': 'microsoft.com',
    'calculator': 'microsoft.com',
    'nvidia share': 'nvidia.com',
    'teamviewer': 'teamviewer.com',
    'anydesk': 'anydesk.com',
    'dropbox': 'dropbox.com',
    'googledrivesync': 'google.com',
  };

  static Widget getIcon(String rawName, {double size = 30}) {
    String name = rawName.toLowerCase().replaceAll(".exe", "").trim();

    if (_domainMap.containsKey(name)) {
      String domain = _domainMap[name]!;
      String iconUrl = "https://www.google.com/s2/favicons?domain=$domain&sz=64";

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          iconUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _getFallbackIcon(name, size),
        ),
      );
    }

    return _getFallbackIcon(name, size);
  }

  static Widget _getFallbackIcon(String name, double size) {
    IconData icon = Icons.window;
    Color color = Colors.grey;

    if (name.contains('code') || name.contains('dev')) {
      icon = Icons.code; color = Colors.blueAccent;
    } else if (name.contains('music') || name.contains('sound')) {
      icon = Icons.music_note; color = Colors.green;
    } else if (name.contains('game')) {
      icon = Icons.videogame_asset; color = Colors.purple;
    } else if (name.contains('term') || name.contains('cmd')) {
      icon = Icons.terminal; color = Colors.white;
    } else if (name.contains('browser') || name.contains('web')) {
      icon = Icons.public; color = Colors.blue;
    } else if (name.contains('folder') || name.contains('explorer')) {
      icon = Icons.folder; color = Colors.amber;
    }

    return Icon(icon, color: color, size: size);
  }
}
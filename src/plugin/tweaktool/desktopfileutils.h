/*
  This file is part of ut-tweak-tool
  Copyright (C) 2015, 2016 Stefano Verzegnassi

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License 3 as published by
  the Free Software Foundation.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program. If not, see http://www.gnu.org/licenses/.
*/

#ifndef DESKTOPFILEUTILS_H
#define DESKTOPFILEUTILS_H

#define DESKTOP_FILES_FOLDER_USER       QDir::homePath() + "/.local/share/applications"
#define DESKTOP_FILES_FOLDER_SYSTEM     "/usr/share/applications"

#define DESKTOP_FILE_KEY_NAME           "Desktop Entry/Name"
#define DESKTOP_FILE_KEY_COMMENT        "Desktop Entry/Comment"
#define DESKTOP_FILE_KEY_ICON           "Desktop Entry/Icon"
#define DESKTOP_FILE_KEY_NO_DISPLAY     "Desktop Entry/NoDisplay"
#define DESKTOP_FILE_KEY_APP_ID         "Desktop Entry/X-Lomiri-Application-ID"
#define DESKTOP_FILE_KEY_UBUNTU_TOUCH   "Desktop Entry/X-Ubuntu-Touch"
#define DESKTOP_FILE_KEY_LOMIRI_TOUCH   "Desktop Entry/X-Lomiri-Touch"
#define DESKTOP_FILE_KEY_ONLY_SHOW_IN   "Desktop Entry/OnlyShowIn"
#define DESKTOP_FILE_KEY_NOT_SHOW_IN    "Desktop Entry/NotShowIn"

#include <QObject>
#include <QSettings>

class DesktopFileUtils : public QObject
{
    Q_OBJECT

public:
    static QString getAppIdFromDesktopFile(const QSettings &ini);
    static bool isDesktopFileVisible(const QSettings &ini);
    static QString getIconFromDesktopFile(const QSettings &ini);
    static QString getCommentFromDesktopFile(const QSettings &ini);
    static QString getNameFromDesktopFile(const QSettings &ini);
    static QString getExecFromDesktopFile(const QSettings &ini);
};

#endif // DESKTOPFILEUTILS_H

/*
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

#include "desktopfileutils.h"

#include <QSettings>
#include <QFileInfo>


static QString KeyWithLocale(const QString &key, const QString &locale) {
    return key + QString("[%1]").arg(locale);
}

static QString getLocalizedKey(const QSettings &ini, const QString &key) {
    // https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s04.html
    // http://comments.gmane.org/gmane.comp.window-managers.sawfish/6112

    QString locale = qgetenv("LANG");

    if (locale.isEmpty())
        locale = qgetenv("LANGUAGE");

    if (locale.isEmpty())
        locale = qgetenv("LC_MESSAGE");

    if (locale.isEmpty())
        locale = qgetenv("LC_ALL");

    QString value;

    value = ini.value(KeyWithLocale(key, locale)).toString();

    if (value.isEmpty()) {
        int n = locale.indexOf("@");
        if (n > -1)
            locale.truncate(n);

        value = ini.value(KeyWithLocale(key, locale)).toString();
    }

    if (value.isEmpty()) {
        int n = locale.indexOf(".");
        if (n > -1)
            locale.truncate(n);

        value = ini.value(KeyWithLocale(key, locale)).toString();
    }

    if (value.isEmpty()) {
        int n = locale.indexOf("_");
        if (n > -1)
            locale.truncate(n);

        value = ini.value(KeyWithLocale(key, locale)).toString();
    }

    if (value.isEmpty())
        value = ini.value(key).toString();

    return value;
}

QString DesktopFileUtils::getAppIdFromDesktopFile(const QSettings &ini)
{
    return QFileInfo(ini.fileName()).baseName();
}

bool DesktopFileUtils::isDesktopFileVisible(const QSettings &ini)
{
    bool isUbuntuTouchApp = ini.value(DESKTOP_FILE_KEY_LOMIRI_TOUCH, bool(false)).toBool() || \
                            ini.value(DESKTOP_FILE_KEY_UBUNTU_TOUCH, bool(false)).toBool();
    bool shouldNotBeDisplay = ini.value(DESKTOP_FILE_KEY_NO_DISPLAY, bool(false)).toBool();
    bool shouldDisplayOnUnity = ini.value(DESKTOP_FILE_KEY_ONLY_SHOW_IN, QString("Unity")).toString() == QString("Unity");
    bool shouldNotDisplayOnUnity = ini.value(DESKTOP_FILE_KEY_ONLY_SHOW_IN).toString() == QString("Unity");

    if (shouldNotDisplayOnUnity || shouldNotBeDisplay)
        return false;

    return isUbuntuTouchApp && shouldDisplayOnUnity;
}

QString DesktopFileUtils::getIconFromDesktopFile(const QSettings &ini)
{
    QString iconName = ini.value(DESKTOP_FILE_KEY_ICON).toString();

    if (iconName.isEmpty())
        return QString();

    if (QFileInfo(iconName).isAbsolute())
        return iconName;

    else
        // Use Lomiri UITK's LomiriThemeIconProvider
        return QString("image://theme/%1").arg(iconName);
}

QString DesktopFileUtils::getCommentFromDesktopFile(const QSettings &ini)
{
    return getLocalizedKey(ini, DESKTOP_FILE_KEY_COMMENT);
}

QString DesktopFileUtils::getNameFromDesktopFile(const QSettings &ini)
{
    return getLocalizedKey(ini, DESKTOP_FILE_KEY_NAME);
}

QString DesktopFileUtils::getExecFromDesktopFile(const QSettings &ini)
{
    if (ini.contains(DESKTOP_FILE_KEY_APP_ID))
        return ini.value(DESKTOP_FILE_KEY_APP_ID).toString().split("_").at(0);

    else {
        QFileInfo fi(ini.fileName());
        return fi.completeBaseName();
    }
}

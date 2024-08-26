/*
  Copyright (C) 2013-2015 Stefano Verzegnassi

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

#ifndef STORAGEMANAGER_H
#define STORAGEMANAGER_H

#include <QObject>
#include <QStringList>
#include <QFileDevice>

class StorageManager : public QObject
{
    Q_OBJECT
    Q_ENUMS(XdgFolders)
    Q_ENUMS(Permissions)

public:
    enum XdgFolders {
        HomeLocation = 0,
        CacheLocation = 1,
        DataLocation = 2,
        ConfigLocation = 3
    };

    enum Permissions {
        ReadOwner   =    QFileDevice::ReadOwner,
        WriteOwner  =    QFileDevice::WriteOwner,
        ExeOwner    =    QFileDevice::ExeOwner,
        ReadUser    =    QFileDevice::ReadUser,
        WriteUser   =    QFileDevice::WriteUser,
        ExeUser     =    QFileDevice::ExeUser,
        ReadGroup   =    QFileDevice::ReadGroup,
        WriteGroup  =    QFileDevice::WriteGroup,
        ExeGroup    =    QFileDevice::ExeGroup,
        ReadOther   =    QFileDevice::ReadOther,
        WriteOther  =    QFileDevice::WriteOther,
        ExeOther    =    QFileDevice::ExeOther
    };

    Q_INVOKABLE QString getXdgFolder(StorageManager::XdgFolders folder);

    Q_INVOKABLE bool exists(QString path);
    Q_INVOKABLE bool mkPath(QString path);
    Q_INVOKABLE bool rename(QString completePathFile, QString newBaseName);
    Q_INVOKABLE bool rm(QString path);
    Q_INVOKABLE bool copyFile(QString sourcePath, QString destDir);

    Q_INVOKABLE bool setPermissions(const QString &fileName, Permissions permissions);

    Q_INVOKABLE QString getFileBaseNameFromPath(QString path);
    Q_INVOKABLE QString getFileCompleteSuffixFromPath(QString path);
    Q_INVOKABLE QString getFileFullName(QString path);

    Q_INVOKABLE QStringList searchRecursively(QString path, QStringList filters);

    Q_INVOKABLE bool createEmptyFile(QString path);
    Q_INVOKABLE bool createTextFile(QString path, QString text);

    Q_INVOKABLE bool isFile(QString path);
    Q_INVOKABLE bool isDir(QString path);
};

#endif // STORAGEMANAGER_H


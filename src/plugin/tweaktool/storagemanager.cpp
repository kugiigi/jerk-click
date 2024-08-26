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

#include "storagemanager.h"
#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QDirIterator>
#include <QTextStream>

QString StorageManager::getXdgFolder(XdgFolders folder)
{
    switch(folder) {
    case HomeLocation:
        return QDir::homePath();
    case CacheLocation:
        return QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    case DataLocation:
        return QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    case ConfigLocation:
        return QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
    default:
        return "invalid";
    }
}

bool StorageManager::exists(QString path)
{
    QFileInfo fi(path);

    if (fi.isFile()) {
        return fi.exists();
    } else {
        return QDir(path).exists();
    }
}

bool StorageManager::mkPath(QString path)
{
    QDir dir;
    dir.setPath(QDir::rootPath());

    return dir.mkpath(path);
}

QString StorageManager::getFileBaseNameFromPath(QString path)
{
    QFileInfo fi(path);
    return fi.baseName();
}

QString StorageManager::getFileCompleteSuffixFromPath(QString path)
{
    QFileInfo fi(path);
    QString completeSuffix = fi.completeSuffix();

    // It does not include the first dot
    return completeSuffix;
}

QString StorageManager::getFileFullName(QString path)
{
    QFileInfo fi(path);
    return fi.fileName();
}

QStringList StorageManager::searchRecursively(QString path, QStringList filters)
{
    QDirIterator dir(path, QDir::Files | QDir::NoDotAndDotDot | QDir::Readable,
                     QDirIterator::Subdirectories);

    QStringList results;
    QRegExp rx;
    while (dir.hasNext()) {
        dir.next();

        foreach(QString filter, filters) {
            rx = QRegExp(filter, Qt::CaseInsensitive);
            rx.setPatternSyntax(QRegExp::Wildcard);

            if (rx.exactMatch(dir.fileName()))
                results.append(dir.fileInfo().absoluteFilePath());
        }
    }

    return results;
}

bool StorageManager::createEmptyFile(QString path)
{
    QFile file(path);
    if(!file.open(QIODevice::WriteOnly))
        return false;

    file.close();
    return true;
}


bool StorageManager::createTextFile(QString path, QString text)
{
    QFile file(path);
    if(!file.open(QIODevice::WriteOnly))
        return false;

    QTextStream stream(&file);
    stream << text;

    file.close();
    return true;
}

bool StorageManager::setPermissions(const QString &fileName, Permissions permissions)
{
    return QFile::setPermissions(fileName, QFileDevice::Permission(permissions));
}

bool StorageManager::isFile(QString path)
{
    QFileInfo fi(path);
    return fi.isFile();
}

bool StorageManager::isDir(QString path)
{
    QFileInfo fi(path);
    return fi.isDir();
}

bool StorageManager::rename(QString completePathFile, QString newBaseName)
{
    QFileInfo pathfile(completePathFile);
    QString newPath = pathfile.canonicalPath() + QDir::separator() + newBaseName;
    if (!pathfile.completeSuffix().isEmpty()) {
        newPath += "." + pathfile.completeSuffix();
    }

    QFile file(completePathFile);
    return file.rename(newPath);
}

bool StorageManager::rm(QString path)
{
    bool result = false;
    QDir dir(path);

    if (dir.exists()) {
        result = dir.removeRecursively();
    } else {
        QFile fi(path);
        result = fi.remove();
    }

    return result;
}

bool StorageManager::copyFile(QString sourcePath, QString destDir)
{
    bool result = false;
    QFile fi(sourcePath);
    QFileInfo fiInfo(fi);

    if (fiInfo.isFile()) {
        destDir = destDir + "/" + fiInfo.fileName();
        result = fi.copy(destDir);
    }

    return result;
}

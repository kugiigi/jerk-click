/*
  This file is part of ut-tweak-tool
  Copyright (C) 2015 Stefano Verzegnassi

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

#include "package_p.h"

#include <QGSettings>

#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QDirIterator>

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include <QDebug>

#define CACHE_FOLDER "/home/phablet/.cache/"
#define APPDATA_FOLDER "/home/phablet/.local/share/"
#define CONFIG_FOLDER "/home/phablet/.config/"

Package::Package(const QString &appId, const QString &directory, bool removable,
                 const QString &architecture, const QString &description,
                 const QString &framework, const QList<Hook> &hooks,
                 const QString &iconPath, const QString &maintainer,
                 const QString &title, const QString &version):
    m_appId(appId),
    m_directory(directory),
    m_removable(removable),
    m_architecture(architecture),
    m_description(description),
    m_framework(framework),
    m_hooks(hooks),
    m_iconPath(iconPath),
    m_maintainer(maintainer),
    m_title(title),
    m_version(version),
    m_installedSize(0),
    m_dataSize(0),
    m_configSize(0),
    m_cacheSize(0),
    m_lifeCycleException(false)
{
    // Get life cycle exception state
    QGSettings lceSettings("com.canonical.qtmir", "/com/canonical/qtmir/");
    QStringList appIds = lceSettings.get("lifecycle-exempt-appids").toStringList();

    Q_FOREACH(const QString &id, appIds) {
        if (id == m_appId) {
            m_lifeCycleException = true;
            Q_EMIT lifeCycleExceptionChanged();

            break;
        }
    }

    connect(this, &Package::lifeCycleExceptionChanged, this, &Package::updateLifeCycleExceptionState);

    // Get general hooks info
    int appsNumber = 0;
    int scopesNumber = 0;
    int accountsNumber = 0;
    int pushHelpersNumber = 0;

    Q_FOREACH(const Hook &hook, hooks) {
        if (hook.type == Hook::HookType::App)
            ++appsNumber;

        if (hook.type == Hook::HookType::Scope)
            ++scopesNumber;

        if (hook.type == Hook::HookType::OnlineAccount)
            ++accountsNumber;

        if (hook.type == Hook::HookType::PushHelper)
            ++pushHelpersNumber;
    }

    m_containsApp = (appsNumber > 0);
    m_containsScope = (scopesNumber > 0);
    m_containsOnlineAccount = (accountsNumber > 0);
    m_containsPushHelper = (pushHelpersNumber > 0);
}

void Package::clearAppData()
{
    QDir d(APPDATA_FOLDER + m_appId);

    if (d.exists())
        d.removeRecursively();

    updateSize();
}

void Package::clearAppCache()
{
    QDir d(CACHE_FOLDER + m_appId);

    if (d.exists())
        d.removeRecursively();

    updateSize();
}

void Package::clearAppConfig()
{
    QDir d(CONFIG_FOLDER + m_appId);

    if (d.exists())
        d.removeRecursively();

    updateSize();
}

QVariantMap Package::getHook(int index)
{
    const Hook &hook = m_hooks.at(index);

    QVariantMap result;

    result["name"] = hook.name;

    switch(hook.type) {
    case Hook::HookType::Unknown:
        result["type"] = "Unknown";
        break;
    case Hook::HookType::App:
        result["type"] = "App";
        break;
    case Hook::HookType::Scope:
        result["type"] = "Scope";
        break;
    case Hook::HookType::OnlineAccount:
        result["type"] = "OnlineAccount";
        break;
    case Hook::HookType::PushHelper:
        result["type"] = "PushHelper";
        break;
    }

    qDebug() << "Looking for an AppArmor profile at" << hook.appArmorPath;

    QVariantMap appArmor;

    if (QFile::exists(hook.appArmorPath)) {
        QFile file(hook.appArmorPath);

        if (file.open(QIODevice::ReadOnly)) {
            QTextStream in(&file);
            const QString &apparmorTxt = in.readAll();
            file.close();

            appArmor = QJsonDocument::fromJson(apparmorTxt.toUtf8()).object().toVariantMap();
        } else {
            qDebug() << "Cannot read the AppArmor profile!";
        }
    } else {
        qDebug() << "AppArmor profile not found!";
    }

    result["apparmor"] = appArmor;

    return result;
}

void Package::updateSize()
{
    QDirIterator appFolderIt(m_directory, QDirIterator::Subdirectories);
    qint64 newInstalledSize = 0;
    while (appFolderIt.hasNext()) {
        appFolderIt.next();
        newInstalledSize += appFolderIt.fileInfo().size();
    }

    QDirIterator appDataIt(APPDATA_FOLDER + m_appId, QDirIterator::Subdirectories);
    qint64 newAppDataSize = 0;
    while (appDataIt.hasNext()) {
        appDataIt.next();
        newAppDataSize += appDataIt.fileInfo().size();
    }

    QDirIterator cacheIt(CACHE_FOLDER + m_appId, QDirIterator::Subdirectories);
    qint64 newCacheSize = 0;
    while (cacheIt.hasNext()) {
        cacheIt.next();
        newCacheSize += cacheIt.fileInfo().size();
    }

    QDirIterator configIt(CONFIG_FOLDER + m_appId, QDirIterator::Subdirectories);
    qint64 newConfigSize = 0;
    while (configIt.hasNext()) {
        configIt.next();
        newConfigSize += configIt.fileInfo().size();
    }

    if (m_installedSize != newInstalledSize) {
        m_installedSize = newInstalledSize;
        Q_EMIT installedSizeChanged();
    }


    if (m_dataSize != newAppDataSize) {
        m_dataSize = newAppDataSize;
        Q_EMIT dataSizeChanged();
    }

    if (m_configSize != newConfigSize) {
        m_configSize = newConfigSize;
        Q_EMIT configSizeChanged();
    }

    if (m_cacheSize != newCacheSize) {
        m_cacheSize = newCacheSize;
        Q_EMIT cacheSizeChanged();
    }
}

void Package::updateLifeCycleExceptionState()
{
    QGSettings lceSettings("com.canonical.qtmir", "/com/canonical/qtmir/");
    QStringList appIds = lceSettings.get("lifecycle-exempt-appids").toStringList();

    if (m_lifeCycleException) {     // Set to true -> add exception
        if (!appIds.contains(m_appId)) {
            appIds.append(m_appId);
        }
    } else {    // Set to false -> remove exception
        if (appIds.contains(m_appId)) {
            appIds.removeAll(m_appId);
        }
    }

    lceSettings.set("lifecycle-exempt-appids", appIds);
}

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

#ifndef PACKAGE_H
#define PACKAGE_H

#include <QObject>
#include <QVariantMap>

struct Hook {
    enum HookType {
        Unknown,
        App,
        OnlineAccount,
        Scope,
        PushHelper
    };

    QString name;
    HookType type = HookType::Unknown;

    QString accountApplicationPath;
    QString accountServicePath;
    QString accountProviderPath;
    QString accountQmlPluginPath;
    QString appArmorPath;
    QString scopePath;
    QString desktopPath;
    QString contentHubPath;
    QString urlsPath;
    QString pushHelperPath;
};

class Package : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString appId READ appId CONSTANT)
    Q_PROPERTY(QString directory READ directory CONSTANT)
    Q_PROPERTY(bool isRemovable READ isRemovable CONSTANT)
    Q_PROPERTY(QString architecture READ architecture CONSTANT)
    Q_PROPERTY(QString description READ description CONSTANT)
    Q_PROPERTY(QString framework READ framework CONSTANT)
    Q_PROPERTY(QList<Hook> hooks READ hooks CONSTANT)
    Q_PROPERTY(QString iconPath READ iconPath CONSTANT)
    Q_PROPERTY(QString maintainer READ maintainer CONSTANT)
    Q_PROPERTY(QString title READ title CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(qint64 installedSize READ installedSize NOTIFY installedSizeChanged)
    Q_PROPERTY(qint64 dataSize READ dataSize NOTIFY dataSizeChanged)
    Q_PROPERTY(qint64 configSize READ configSize NOTIFY configSizeChanged)
    Q_PROPERTY(qint64 cacheSize READ cacheSize NOTIFY cacheSizeChanged)
    Q_PROPERTY(bool lifeCycleException MEMBER m_lifeCycleException NOTIFY lifeCycleExceptionChanged)
    Q_PROPERTY(bool containsApp READ containsApp CONSTANT)
    Q_PROPERTY(bool containsScope READ containsScope CONSTANT)
    Q_PROPERTY(bool containsOnlineAccount READ containsOnlineAccount CONSTANT)
    Q_PROPERTY(bool containsPushHelper READ containsPushHelper CONSTANT)
    Q_PROPERTY(int hooksCount READ hooksCount CONSTANT)

public:
    explicit Package(const QString &appId, const QString &directory,
                     bool removable, const QString &architecture,
                     const QString &description, const QString &framework,
                     const QList<Hook> &hooks, const QString &iconPath,
                     const QString &maintainer, const QString &title,
                     const QString &version);

    QString appId() const { return m_appId; }
    QString directory() const { return m_directory; }
    bool isRemovable() { return m_removable; }
    QString architecture() const { return m_architecture; }
    QString description() const { return m_description; }
    QString framework() const { return m_framework; }
    QList<Hook> hooks() const { return m_hooks; }
    QString iconPath() const { return m_iconPath; }
    qint64 installedSize() const { return m_installedSize; }
    QString maintainer() const { return m_maintainer; }
    QString title() const { return m_title; }
    QString version() const { return m_version; }
    qint64 dataSize() const { return m_dataSize; }
    qint64 configSize() const { return m_configSize; }
    qint64 cacheSize() const { return m_cacheSize; }
    bool containsApp() { return m_containsApp; }
    bool containsScope() { return m_containsScope; }
    bool containsOnlineAccount() { return m_containsOnlineAccount; }
    bool containsPushHelper() { return m_containsPushHelper; }
    int hooksCount() { return m_hooks.count(); }

    Q_INVOKABLE void clearAppData();
    Q_INVOKABLE void clearAppCache();
    Q_INVOKABLE void clearAppConfig();

    Q_INVOKABLE QVariantMap getHook(int index);
    Q_INVOKABLE void updateSize();

Q_SIGNALS:
    void installedSizeChanged();
    void dataSizeChanged();
    void configSizeChanged();
    void cacheSizeChanged();
    void lifeCycleExceptionChanged();

private:
    void updateLifeCycleExceptionState();

private:
    QString m_appId;
    QString m_directory;
    bool m_removable;
    QString m_architecture;
    QString m_description;
    QString m_framework;
    QList<Hook> m_hooks;
    QString m_iconPath;
    QString m_maintainer;
    QString m_title;
    QString m_version;
    qint64 m_installedSize;
    qint64 m_dataSize;
    qint64 m_configSize;
    qint64 m_cacheSize;
    bool m_lifeCycleException;
    bool m_containsApp;
    bool m_containsScope;
    bool m_containsOnlineAccount;
    bool m_containsPushHelper;
};

#endif // PACKAGE_H

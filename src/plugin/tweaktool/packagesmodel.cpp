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

#include "packagesmodel.h"
#include "package_p.h"
#include "desktopfileutils.h"

#include <QDebug>

#include <QProcess>

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>

#include <QJsonDocument>
#include <QJsonArray>

#include <QSettings>

#define MODEL_START_REFRESH() m_ready = false; Q_EMIT readyChanged();
#define MODEL_END_REFRESH() m_ready = true; Q_EMIT readyChanged();

#define UNINSTALL_COMMAND_PROGRAM         "gdbus"
#define UNINSTALL_COMMAND_ARGS(pkg_id)    QStringList() << "call" << "--system" \
                                                        << "--dest" << "com.lomiri.click" \
                                                        << "--object-path" << "/com/lomiri/click" \
                                                        << "--method" << "com.lomiri.click.Remove" << pkg_id

PackagesModel::PackagesModel(QAbstractListModel * parent)
    : QAbstractListModel(parent)
    , m_clickProcess(new QProcess())
    , m_showFilter(ShowFilters::ShowAll)
    , m_ready(false)
{
    qRegisterMetaType<PackageList>("PackageList");

    connect(this, &PackagesModel::showFilterChanged, this, &PackagesModel::refresh);

    connect(m_clickProcess, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished),
        this, &PackagesModel::finalizeRefresh);

    refresh();
}

QHash<int, QByteArray> PackagesModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles.insert(AppIdRole, "appId");
    roles.insert(DirectoryRole, "directory");
    roles.insert(IsRemovableRole, "isRemovable");
    roles.insert(ArchitectureRole, "architecture");
    roles.insert(DescriptionRole, "description");
    roles.insert(FrameworkRole, "framework");
    roles.insert(IconPathRole, "iconPath");
    roles.insert(MaintainerRole, "maintainer");
    roles.insert(TitleRole, "title");
    roles.insert(VersionRole, "version");

    return roles;
}

int PackagesModel::rowCount(const QModelIndex & parent) const
{
    Q_UNUSED(parent)
    return m_packagesList.count();
}

QVariant PackagesModel::data(const QModelIndex & index, int role) const
{
    if (index.row() < 0 || index.row() > rowCount())
        return QVariant();

    auto pkg = m_packagesList.at(index.row());

    switch (role) {
    case AppIdRole:
        return pkg->appId();
    case DirectoryRole:
        return pkg->directory();
    case IsRemovableRole:
        return pkg->isRemovable();
    case ArchitectureRole:
        return pkg->architecture();
    case DescriptionRole:
        return pkg->description();
   case FrameworkRole:
        return pkg->framework();
    case IconPathRole:
        return pkg->iconPath();
    case MaintainerRole:
        return pkg->maintainer();
    case TitleRole:
        return pkg->title();
    case VersionRole:
        return pkg->version();

    default:
        return QVariant();
    }
}

void PackagesModel::refresh()
{
    qDebug() << Q_FUNC_INFO << "called";

    MODEL_START_REFRESH();

    beginResetModel();
    qDeleteAll(m_packagesList);
    m_packagesList.clear();
    endResetModel();

    // TODO: We should use libclick here!
    m_clickProcess->start("click", QStringList() << "list" << "--manifest", QIODevice::ReadOnly);
}

void PackagesModel::finalizeRefresh()
{
    const QString &jsonManifest = m_clickProcess->readAll();
    const QJsonArray &mArray = QJsonDocument::fromJson(jsonManifest.toUtf8()).array();

    Q_FOREACH(const QJsonValue &pkg, mArray) {
        auto package = processPackage(pkg.toObject());

        if (package) {
            beginInsertRows(QModelIndex(), rowCount(), rowCount());
            m_packagesList << package;
            endInsertRows();
        }
    }

    appendSystemApps();

    MODEL_END_REFRESH();
}

void PackagesModel::appendSystemApps()
{
    QStringList systemApps;

    systemApps << QString(DESKTOP_FILES_FOLDER_SYSTEM) + "/address-book-app.desktop";
    systemApps << QString(DESKTOP_FILES_FOLDER_SYSTEM) + "/ciborium.desktop";
    systemApps << QString(DESKTOP_FILES_FOLDER_SYSTEM) + "/dialer-app.desktop";
    systemApps << QString(DESKTOP_FILES_FOLDER_SYSTEM) + "/lomiri-system-settings.desktop";
    systemApps << QString(DESKTOP_FILES_FOLDER_SYSTEM) + "/mediaplayer-app.desktop";
    systemApps << QString(DESKTOP_FILES_FOLDER_SYSTEM) + "/messaging-app.desktop";
    systemApps << QString(DESKTOP_FILES_FOLDER_SYSTEM) + "/morph-browser.desktop";

    Q_FOREACH(const QString &path, systemApps) {
        if (QFileInfo::exists(path)) {
            qDebug() << "Desktop file found:" << path;

            QSettings appInfo(path, QSettings::IniFormat);
            appInfo.setIniCodec("UTF-8");

            Hook appHook;
            appHook.type = Hook::App;

            auto pkg = new Package (
                        DesktopFileUtils::getAppIdFromDesktopFile(appInfo),     // App ID
                        "",                                                     // Directory
                        false,                                                  // Is removable?
                        "Unknown",                                              // Architecture
                        DesktopFileUtils::getCommentFromDesktopFile(appInfo),   // Description
                        "Unknown",                                              // Framework
                        QList<Hook>() << appHook,                               // Hooks
                        DesktopFileUtils::getIconFromDesktopFile(appInfo),      // Icon path
                        "Ubuntu Touch System Apps",                             // Maintainer
                        DesktopFileUtils::getNameFromDesktopFile(appInfo),      // Title
                        "");                                                    // Version

            beginInsertRows(QModelIndex(), rowCount(), rowCount());
            m_packagesList << pkg;
            endInsertRows();
        }
    }
}

Package* PackagesModel::get(int index) const
{
    return m_packagesList.at(index);
}

Package* PackagesModel::get(const QString &appId) const
{
    Q_FOREACH(Package* pkg, m_packagesList)
        if (pkg->appId() == appId)
            return pkg;

    return nullptr;
}

void PackagesModel::uninstallPackage(int index)
{
    Package* pkg = get(index);
    uninstallPackage(pkg);
}

void PackagesModel::uninstallPackage(Package* package)
{
    qDebug() << Q_FUNC_INFO << "called";

    QProcess p;
    p.start(UNINSTALL_COMMAND_PROGRAM, UNINSTALL_COMMAND_ARGS(package->appId()));
    p.waitForFinished();

    refresh();
}

Package* PackagesModel::processPackage(const QJsonObject &pkg)
{
    // Get info from manifest
    const QString &appId = pkg.value("name").toString();
    const QString &directory = pkg.value("_directory").toString();
    bool removable = bool(pkg.value("_removable").toDouble());
    const QString &architecture = pkg.value("architecture").toString();
    const QString &description = pkg.value("description").toString();
    const QString &framework = pkg.value("framework").toString();
    QString iconPath = pkg.value("icon").toString();
    const QString &maintainer = pkg.value("maintainer").toString();
    const QString &title = pkg.value("title").toString();
    const QString &version = pkg.value("version").toString();

    int containsApp = 0;
    int containsScope = 0;

    QList<Hook> packageHooks;

    // Get hooks from manifest
    QJsonObject hooksObj = pkg.value("hooks").toObject();
    Q_FOREACH(const QString &hookName, hooksObj.keys()) {
        QJsonObject hook = hooksObj.value(hookName).toObject();

        Hook h;

        h.name = hookName;

        const QString &accountApplication = hook.value("account-application").toString();
        const QString &accountService = hook.value("account-service").toString();
        const QString &accountProvider = hook.value("account-provider").toString();
        const QString &accountQmlPlugin = hook.value("account-qml-plugin").toString();
        const QString &appArmor = hook.value("apparmor").toString();
        const QString &scope = hook.value("scope").toString();
        const QString &desktop = hook.value("desktop").toString();
        const QString &contentHub = hook.value("content-hub").toString();
        const QString &urls = hook.value("urls").toString();
        const QString &pushHelper = hook.value("push-helper").toString();

        h.accountApplicationPath = directory + QDir::separator() + accountApplication;
        h.accountServicePath = directory + QDir::separator() + accountService;
        h.accountProviderPath = directory + QDir::separator() + accountProvider;
        h.accountQmlPluginPath = directory + QDir::separator() + accountQmlPlugin;
        h.appArmorPath = directory + QDir::separator() + appArmor;
        h.scopePath = directory + QDir::separator() + scope + QDir::separator() + appId + "_" + scope + ".ini";
        h.desktopPath = directory + QDir::separator() + desktop;
        h.contentHubPath = directory + QDir::separator() + contentHub;
        h.urlsPath = directory + QDir::separator() + urls;
        h.pushHelperPath = directory + QDir::separator() + pushHelper;

        if (!desktop.isEmpty()) {
            h.type = Hook::HookType::App;
            ++containsApp;
        }
        if (!scope.isEmpty()) {
            h.type = Hook::HookType::Scope;
            ++containsScope;
        }
        if (!accountProvider.isEmpty())
            h.type = Hook::HookType::OnlineAccount;
        if (!pushHelper.isEmpty())
            h.type = Hook::HookType::PushHelper;

        packageHooks << h;
    }

    // Search for an icon.
    if (iconPath.isEmpty() || iconPath == "icon" || containsApp > 0) {
        Q_FOREACH(const Hook &hook, packageHooks) {
            if (hook.type == Hook::HookType::App) {
                QSettings appInfo(hook.desktopPath, QSettings::IniFormat);

                iconPath = directory + QDir::separator() + appInfo.value("Desktop Entry/Icon").toString();
                break;
            }
            if (hook.type == Hook::HookType::Scope) {
                QSettings appInfo(hook.scopePath, QSettings::IniFormat);
                QFileInfo fileInfo(hook.scopePath);

                iconPath = fileInfo.absolutePath() + QDir::separator() + appInfo.value("ScopeConfig/Icon").toString();
                break;
            }
        }
    } else {
        // Prepend package directory
        iconPath = directory + QDir::separator() + iconPath;
    }

    // Add package into the model
    bool pkgHasToBeInserted = false;

    if (m_showFilter == ShowAll)
        pkgHasToBeInserted = true;
    else if (m_showFilter == ShowAppsOnly && containsApp > 0)
        pkgHasToBeInserted = true;
    else if (m_showFilter == ShowScopesOnly && containsScope > 0)
        pkgHasToBeInserted = true;

    if (pkgHasToBeInserted) {
        auto package = new Package(appId, directory, removable, architecture,
                                   description, framework, packageHooks,
                                   iconPath, maintainer, title, version);

        return package;
    } else return nullptr;
}

PackagesModel::~PackagesModel()
{
    qDeleteAll(m_packagesList);
    m_packagesList.clear();
}

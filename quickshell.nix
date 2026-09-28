{ config, lib, pkgs, ... }:

let
qs = config.my.quickshell;
userHome = config.users.users.${qs.user}.home;

quickshellPackages = with pkgs; [
brightnessctl
cliphist
foot
gammastep
libnotify
quickshell
wl-clipboard
];

quickshellDevPackages = with pkgs; [
qt6.qtwayland

(symlinkJoin {
name = "qmllint-wrapped";
paths = [qt6.qtdeclarative];
nativeBuildInputs = [pkgs.makeWrapper];
postBuild = ''
wrapProgram $out/bin/qmllint --add-flags "-I ${pkgs.qt6.qtdeclarative}/lib/qt-6/qml" --add-flags "-I ${pkgs.qt6.qtbase}/lib/qt-6/qml" --add-flags "-I ${pkgs.quickshell}/lib/qt-6/qml"
'';
})
];

in
{
options.my.quickshell = {
enable = lib.mkEnableOption "Bundle com configurações e pacotes para o Quickshell";

user = lib.mkOption {
type = lib.types.str;
description = "Usuário NixOS ao qual o Quickshell pertence.";
example = "user";
};

sourceDir = lib.mkOption {
type = lib.types.path;
default = ./quickshell;
description = "Diretório contendo a configuração da shell Quickshell.";
};

dev.enable = lib.mkEnableOption "Ferramentas para desenvolvimento com Quickshell";
};

config = lib.mkIf qs.enable {

my.homemanager.extraDotfiles = [
{
bundles = [ "quickshell" ];
source = ./.config/foot/foot.ini;
target = "${userHome}/.config/foot/foot.ini";
}

{
bundles = [ "quickshell" ];
source = qs.sourceDir;
target = "${userHome}/.config/quickshell";
}
];

users.users.${qs.user}.packages = quickshellPackages ++ lib.optionals qs.dev.enable quickshellDevPackages;

systemd.user.services.cliphist-watch = {
description = "Clipboard";
partOf = [ "graphical-session.target" ];
wantedBy = [ "graphical-session.target" ];
after = [ "graphical-session.target" ];

unitConfig.ConditionUser = qs.user;

serviceConfig = {
ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
Restart = "always";
RestartSec = "3s";
};
};

systemd.user.services.quickshell = {
description = "Quickshell Wayland UI";
partOf = [ "graphical-session.target" ];
wantedBy = [ "graphical-session.target" ];
after = [ "graphical-session.target" ];

path = with pkgs; [
bash
bluez
brightnessctl
cliphist
coreutils
gammastep
libnotify
niri
procps
quickshell
systemd
util-linux
wl-clipboard
];

environment = {
QUICKSHELL_APP_PATH = lib.concatStringsSep ":" [
"/etc/profiles/per-user/%u/bin"
"/run/current-system/sw/bin"
];

QT_LOGGING_RULES = "quickshell.dbus.properties=false;qt.qpa.services=false";
};

unitConfig.ConditionUser = qs.user;

serviceConfig = {
ExecStart = "${pkgs.quickshell}/bin/quickshell";
Restart = "on-failure";
KillMode = "process";
};
};
};
}

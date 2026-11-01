{
  config,
  pkgs,
  ...
}: {
  programs.plasma = {
    enable = true;
    shortcuts = {
      "services/com.mitchellh.ghostty.desktop"._launch = "Meta+Q";
      "services/net.local.layout-switch-2.desktop"._launch = "Ctrl+Shift";
      "services/net.local.layout-switch.desktop"._launch = "Alt+Shift";
      "services/net.local.rofi.desktop"._launch = "Meta";
      "services/vicinae.desktop".toggle = "Meta";
    };
    configFile = {
      kcminputrc.Keyboard.NumLock = 1;
      kcminputrc."Libinput/1133/49305/Logitech G502 X".PointerAcceleration = "-0.200";
      kcminputrc."Libinput/1133/49305/Logitech G502 X".PointerAccelerationProfile = 1;
      kcminputrc.Mouse.X11LibInputXAccelProfileFlat = true;
      kded5rc.Module-browserintegrationreminder.autoload = false;
      kded5rc.Module-device_automounter.autoload = false;
      kdeglobals.General.BrowserApplication = "brave-browser.desktop";
      kdeglobals.General.DeviceLedsAccentColored = false;
      kdeglobals.General.TerminalApplication = "/usr/bin/ghostty --gtk-single-instance=true";
      kdeglobals.General.TerminalService = "com.mitchellh.ghostty.desktop";
      kxkbrc.Layout.DisplayNames = ",,";
      kxkbrc.Layout.LayoutList = "us,bg,us";
      kxkbrc.Layout.Use = true;
      kxkbrc.Layout.VariantList = ",phonetic,intl";
      plasma-localerc.Formats.LANG = "en_US.UTF-8";
    };
    dataFile = {
    };
    panels = [
      {
        screen = 0;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            iconTasks = {
              launchers = [
                "preferred://filemanager"
                "applications:discord.desktop"
                "applications:brave-browser.desktop"
              ];
              behavior.grouping.method = "none";
            };
          }
          "org.kde.plasma.marginsseparator"
          {
            systemTray = {
              items = {
                hidden = [
                  "org.kde.plasma.brightness"
                  "org.kde.plasma.devicenotifier"
                  "org.kde.kscreen"
                  "org.kde.plasma.clipboard"
                ];
              };
            };
          }
          {
            digitalClock = {
              date.format.custom = "dd-MMM-yyyy";
            };
          }
          "org.kde.plasma.showdesktop"
        ];
      }
      {
        screen = 1;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            iconTasks = {
              launchers = [];
              behavior.showTasks.onlyInCurrentScreen = true;
              behavior.grouping.method = "none";
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
  };
}

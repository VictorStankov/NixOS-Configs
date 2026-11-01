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
  };
}

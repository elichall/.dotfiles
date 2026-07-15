{ config, pkgs, ... }:

{
  # ==========================================================================
  # NATIVE WAYBAR MANAGEMENT
  # ==========================================================================
  programs.waybar = {
    enable = true;
    # Let UWSM track execution instead of the baseline Home Manager daemon
    systemd.enable = false; 

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        margin-top = 5;
        margin-left = 5;
        margin-right = 5;
        spacing = 0;
        
        modules-left = [ "custom/nixos" "hyprland/workspaces" ];
        modules-center = [ "clock" "custom/weather" ];
        modules-right = [ "network" "bluetooth" "cpu" "temperature" "memory" "battery" ];

        "custom/nixos" = {
          format = "";
          tooltip = false;
          on-click-right = "ghostty --class=com.waybar.tui -e bash -c 'fastfetch; read -n 1 -p \"Press any key to exit...\"'";
          on-click = "rofi -show p -modi p:'rofi-power-menu'";
        };

        "hyprland/workspaces" = {
          format = "{name}";
          disable-scroll = true;
          all-outputs = true;
        };

        "clock" = {
          format = "{:%A %I:%M}";
          tooltip-format = "<tt><big>{calendar}</big></tt>";
          calendar = {
            mode = "month";
            format = {
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
        };

        "custom/weather" = {
          format = "{}";
          tooltip = true;
          interval = 1800;
          exec = "${pkgs.curl}/bin/curl -s 'wttr.in/?format=1' | ${pkgs.gnused}/bin/sed 's/+//g'";
        };

        "network" = {
          format-wifi = "  {signalStrength}%";
          format-ethernet = "󰈀 Connected";
          format-disconnected = " Offline";
          on-click = "ghostty --class=com.waybar.tui -e wlctl";
          tooltip-format = "    {ifname} via {gwaddr}";
          tooltip-format-wifi = "  {essid}\n    IP: {ipaddr}\n    Signal: {signalStrength}%\n {bandwidthUpBytes}   {bandwidthDownBytes}";
          tooltip-format-disconnected = "Disconnected";
        };

        "bluetooth" = {
          format-on = "";
          format-off = "";
          format-disabled = "";
          format-connected = "";
          on-click = "ghostty --class=com.waybar.tui -e bluetui";
          on-click-right = "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{device_alias}";
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-full = " {capacity}%";
          format-not-charging = " {capacity}%";
          format-icons = [ "" "" "" "" "" ];
          interval = 60;
          tooltip-format = "Time Remaining: {time}\nPower Draw {power}W";
        };

        "cpu" = {
          format = "  {usage}%";
          on-click = "ghostty --class=com.waybar.tui -e btop";
          tooltip-format = "Clock Speed: {avg_frequency} GHz\n\nCore Load Breakdown:\n{usage_per_core}";
        };

        "temperature" = {
          hwmon-path = "/sys/class/hwmon/hwmon7/temp1_input";
          critical-threshold = 80;
          format = " {temperatureC}°C";
          format-critical = " {temperatureC}°C";
          on-click = "ghostty --class=com.waybar.tui -e btop";
        };

        "memory" = {
          format = "  {used}GB";
          on-click = "ghostty --class=com.waybar.tui -e btop";
          tooltip-format = "RAM: {used:0.1f}GB / {total:0.1f}GB ({percentage}%)\nSwap: {swapUsed:0.1f}GB / {swapTotal:0.1f}GB ({swapPercentage}%)";
        };
      };
    };

    # Hardcoded dynamic CSS layout styling sheet string injects cleanly here
    style = ''
      * {
          font-family: "JetBrains Mono", "Font Awesome 6 Free", "FontAwesome", sans-serif;
          font-size: 14px;
          font-weight: bold;
          min-height: 0;
      }

      window#waybar {
          background-color: rgba(0, 0, 0, 0.4);
          border-radius: 20px;
      }

      window#waybar #custom-nixos {
          color: #74c7ec;
          font-size: 24px;
          background-color: transparent;
          border: none;
          padding-left: 12px;
          padding-right: 8px;
          min-width: 32px;
          text-shadow: 
              -2px -2px 0 #000000,  2px -2px 0 #000000,
              -2px  2px 0 #000000,  2px  2px 0 #000000,
               0px -2px 0 #000000,  0px  2px 0 #000000,
              -2px  0px 0 #000000,  2px  0px 0 #000000;
      }

      window#waybar #custom-nixos:hover {
          color: #89dceb;
          font-size: 26px;
          padding-left: 10px;
          padding-right: 10px;
      }

      #workspaces, #clock, #custom-weather, #network, #bluetooth, #battery, #memory, #cpu, #temperature {
          background-color: @theme_bg;
          border-color: @theme_muted;
          color: @theme_accent;
          border-style: solid;
          border-width: 2px;
          border-radius: 14px;
          padding: 2px 12px;
          margin: 4px;
      }

      #workspaces { padding: 2px 6px; }
      #workspaces button { color: @theme_muted; padding: 0 4px; }
      #workspaces button.active { color: @theme_accent; }

      #cpu {
          margin-right: 0px;
          padding-right: 4px;
          border-right-width: 0px;
          border-radius: 14px 0px 0px 14px;
      }
      #temperature {
          margin-left: 0px;
          padding-left: 4px;
          border-left-width: 0px;
          border-radius: 0px 14px 14px 0px;
      }

      #battery.warning { border-color: @theme_accent; }
      #battery.critical, #temperature.critical {
          border-color: #f38ba8;
          animation-name: blink;
          animation-duration: 1s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
      }

      @keyframes blink {
          to { background-color: #f38ba8; color: #000000; }
      }

      tooltip {
          background: @theme_bg;
          border: 2px solid @theme_accent;
          border-radius: 10px;
          padding: 8px;
      }
      tooltip label {
          font-family: "JetBrains Mono";
          color: @theme_fg;
          font-size: 13px;
      }

      @define-color theme_bg #292522;
      @define-color theme_fg #ece1d7;
      @define-color theme_accent #78997a;
      @define-color theme_muted #867462;
    '';
  };

  # ==========================================================================
  # NATIVE ROFI MANAGEMENT (Wayland-Native)
  # ==========================================================================
  programs.rofi = {
    enable = true; 

    plugins = with pkgs; [
      rofi-calc
      rofi-power-menu
    ];

    extraConfig = {
      modi = "drun,calc,p:${pkgs.rofi-power-menu}/bin/rofi-power-menu";
      show-icons = true;
      display-drun = " ";
      display-calc = " ";
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";
      require-input = true;

      hover-select = true;
      me-select-entry = "";
      me-accept-entry = "!MousePrimary";
      kb-cancel = "MousePrimary,Escape";

      kb-remove-to-eol = "";
      kb-accept-entry = "Return,KP_Enter";
      kb-mode-next = "Control+l,Control+Tab";
      kb-mode-previous = "Control+h,Control+Shift+Tab";
      kb-remove-char-back = "BackSpace,Shift+BackSpace";
      kb-mode-complete = "";
      kb-row-up = "Up,Control+k";
      kb-row-down = "Down,Control+j";
    };
  };

  # ==========================================================================
  # STRUCTURAL RASICOMPONENT INJECTION
  # ==========================================================================
  # Writes out your aesthetic structural geometry components directly to rofi
  xdg.configFile."rofi/config.rasi".text = ''
    window {
        transparency:     "real";
        location:         north;
        anchor:           north;
        fullscreen:       false;
        width:            600px;
        x-offset:         0px;
        y-offset:         25%;
        enabled:          true;
        margin:           0px;
        padding:          0px;
        border:           2px solid;
        border-radius:    10px;
        cursor:           "default";
    }

    mainbox {
        enabled:          true;
        spacing:          0px;
        margin:           0px;
        padding:          20px;
        background-color: transparent;
        children:         [ "inputbar", "message", "listview" ];
    }

    inputbar {
        enabled:          true;
        spacing:          10px;
        margin:           0px;
        padding:          10px 14px;
        border-radius:    6px;
        children:         [ "prompt", "entry" ];
    }

    prompt {
        enabled:          true;
        background-color: transparent;
        font:             "JetBrainsMono Nerd Font Bold 13";
    }

    entry {
        enabled:          true;
        background-color: transparent;
        cursor:           text;
        placeholder:      "Search apps or evaluate expressions...";
        font:             "JetBrainsMono Nerd Font 11";
    }

    listview {
        enabled:          true;
        require-input:    true;
        columns:          1;
        lines:            8;
        cycle:            true;
        dynamic:          true;
        scrollbar:        false;
        layout:           vertical;
        reverse:          false;
        fixed-height:     false;
        fixed-columns:    true;
        spacing:          5px;
        margin:           0px;
        padding:          0px;
        background-color: transparent;
        cursor:           "default";
    }

    element {
        enabled:          true;
        spacing:          12px;
        margin:           5px 0px 0px 0px;
        padding:          8px 12px;
        border-radius:    6px;
        background-color: transparent;
        cursor:           pointer;
    }

    element-icon {
        background-color: transparent;
        size:             24px;
        cursor:           inherit;
    }

    element-text {
        background-color: transparent;
        highlight:        inherit;
        cursor:           inherit;
        vertical-align:   0.5;
        horizontal-align: 0.0;
        font:             "JetBrainsMono Nerd Font 11";
    }
  '';
}

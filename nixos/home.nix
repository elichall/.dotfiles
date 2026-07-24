{ config, pkgs, ... }:

{
  imports = [
    ./modules/hyprland.nix
    ./modules/desktop-stable.nix
    ./modules/theme.nix
    ./modules/showoff.nix
  ];

  home.stateVersion = "26.05";

  home.username = "elichall";
  home.homeDirectory = "/home/elichall";

  # ==========================================================================
  # GLOBAL ENVIRONMENT CONFIGURATION
  # ==========================================================================
  home.sessionVariables = {
    EDITOR = "nvim";
    FILEMANAGER = "yazi";
    TERM_FILE_CHOOSER = "yazi";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
  };

  programs.git = {
    enable = true;
    settings.user.name = "elichall";
    settings.user.email = "1elijah.hall@gmail.com";
  };

  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk.iconTheme = {
    package = pkgs.papirus-icon-theme;
    name = "Papirus-Dark";
  };

  # XDG portal + MIME defaults
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "org.mozilla.firefox.desktop";
        "x-scheme-handler/http" = "org.mozilla.firefox.desktop";
        "x-scheme-handler/https" = "org.mozilla.firefox.desktop";
        "x-scheme-handler/about" = "org.mozilla.firefox.desktop";
        "x-scheme-handler/unknown" = "org.mozilla.firefox.desktop";
        "inode/directory" = "yazi.desktop";
      };
    };
    desktopEntries.yazi = {
      name = "Yazi";
      exec = "yazi-open %f";
      terminal = false;
      mimeType = [ "inode/directory" ];
    };
  };

  # Packages managed by home-manager not by the core tty system
  home.packages = with pkgs; [
    # gtk.portal must live in the user profile so the daemon finds it
    xdg-desktop-portal-gtk
    ghostty

    # Global LSP servers (always on PATH)
    nil # nix
    marksman # markdown
    lua-language-server # lua
    texlab # latex
    bash-language-server # bash

    (writeShellScriptBin "yazi-open" ''ghostty -e bash -ci "yazi ''${1:-.}"'')
  ];

  # ==========================================================================
  # PERSISTENT SYSTEM PLUGINS & UTILITIES
  # ==========================================================================
  programs.starship = {
    enable = true;
    enableBashIntegration = false; # ble.sh must load first

    settings = {
      format = "$os$directory$nix_shell$git_branch$git_status$character";
      add_newline = false;
      line_break.disabled = true;
      cmd_duration.disabled = true;

      os = {
        disabled = false;
        format = "[$symbol]($style) ";
        style = "bold #74c7ec";
        symbols.NixOS = "";
      };

      nix_shell = {
        symbol = "❄️";
        format = "via [$symbol$state](bold blue) ";
        pure_msg = "pure";
        impure_msg = "";
        unknown_msg = "";
        heuristic = false;
        disabled = false;
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = false;
    nix-direnv.enable = true;
    silent = true;
    stdlib = ''
      # Load nix-direnv stdlib (provides use_nix, use flake)
      source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
      # Load user lib/*.sh (direnv does not auto-load these)
      direnv_config_dir_home="''${DIRENV_CONFIG_HOME:-''${XDG_CONFIG_HOME:-$HOME/.config}/direnv}"
      for lib in "$direnv_config_dir_home/lib/"*.sh; do
        source "$lib"
      done
      unset direnv_config_dir_home
    '';
  };

  # ==========================================================================
  # DECLARATIVE DOTFILE GENERATION
  # ==========================================================================
  home.file.".blerc".text = ''
    ble-face -s filename_directory 'fg=blue'
    ble-face -s filename_other fg=white,nounderline

    function blerc/emacs-load-hook {
      ble-bind -f 'C-a' accept-line
      return 0
    }
    blehook/eval-after-load keymap_emacs blerc/emacs-load-hook
  '';

  # ==========================================================================
  # INTERACTIVE BASH MANAGEMENT
  # ==========================================================================
  programs.bash = {
    enable = true;

    historyControl = [ "ignoreboth" ];
    historySize = 1000;
    historyFileSize = 2000;

    shellAliases = {
      ll = "ls -alF --color=auto";
      la = "ls -A --color=auto";
      l = "ls -CF --color=auto";
      grep = "grep --color=auto";
      snorbs = "sudo nixos-rebuild switch";
    };

    bashrcExtra = ''
      if [ -f ~/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
        . ~/.nix-profile/etc/profile.d/hm-session-vars.sh
      fi
    '';

    initExtra = ''
      shopt -s histappend
      shopt -s checkwinsize
      # initalize blesh first
      if [[ $- == *i* ]]; then
        source ${pkgs.blesh}/share/blesh/ble.sh --noattach
      fi
      # initialize zoxide
      eval "$(zoxide init bash)"
      # initalize direnv (defines _direnv_hook function)
      eval "$(${pkgs.direnv}/bin/direnv hook bash)"
      # Sync direnv with ble.sh — direnv hook adds to PROMPT_COMMAND
      # but ble.sh replaces it, so we re-register via blehook
      if [[ ''${BLE_VERSION-} ]]; then
        blehook PRECMD+='_direnv_hook'
      fi
      # initalize starship (hooks into blehook PRECMD automatically)
      if [[ $- == *i* ]]; then
        eval "$(${pkgs.starship}/bin/starship init bash --print-full-init)"
      fi
      # attach blesh
      [[ ''${BLE_VERSION-} ]] && ble-attach
    '';
  };

  # ==========================================================================
  # TMUX HOME MANAGEMENT
  # ==========================================================================
  programs.tmux = {
    enable = true;
    shortcut = "Space";
    baseIndex = 1;
    keyMode = "vi";
    escapeTime = 0;
    mouse = true;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      {
        plugin = extrakto;
        extraConfig = ''
          set -g @extrakto_key "f"
          set -g @extrakto_filter_order "line word all"
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-processes "opencode"
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval 10
        '';
      }
      {
        plugin = tmux-fzf;
        extraConfig = ''
          TMUX_FZF_LAUNCH_KEY="tab"
        '';
      }
      {
        plugin = yank;
      }
    ];

    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"
      set-option -g detach-on-destroy off

      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      if-shell '[ -f ~/.config/tmux/colors.tmux ]' 'source-file ~/.config/tmux/colors.tmux'

      unbind [
      bind v copy-mode
      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send-key -X begin-selection
      bind-key -T copy-mode-vi C-v send-key -X rectangle-toggle
      bind-key -T copy-mode-vi y send-key -X copy-selection-and-cancel
      bind-key -T copy-mode-vi Escape send-key -X cancel

      bind p run "wl-paste -n | tmux load-buffer - ; tmux paste-buffer"

      # Pane management
      unbind '"'
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      bind _ split-window -v -c "#{pane_current_path}"
      bind b break-pane -d

      bind -r Left resize-pane -L 10
      bind -r Down resize-pane -D 10
      bind -r Up resize-pane -U 10
      bind -r Right resize-pane -R 10

      bind C-x confirm-before -p "Kill all other panes in window? (y/n)" "kill-pane -a"

      # Window management
      bind n new-window -c "#{pane_current_path}"
      bind -n M-h previous-window
      bind -n M-l next-window
      bind X confirm-before -p "Kill current window? (y/n)" kill-window

      # Session management
      bind N run-shell -b "${pkgs.tmuxPlugins.tmux-fzf}/share/tmux-plugins/tmux-fzf/scripts/session.sh new"
      bind S run-shell "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh"
      bind s run-shell "${pkgs.tmuxPlugins.tmux-fzf}/share/tmux-plugins/tmux-fzf/scripts/session.sh"

      bind -n M-C-h switch-client -p
      bind -n M-C-l switch-client -n

      bind C-X confirm-before -p "Kill current session? (y/n)" "run-shell 'tmux has-session -t main 2>/dev/null || tmux new-session -d -s main; tmux switch-client -t main && tmux kill-session -t \"#{session_name}\"'"
      bind M-C-X confirm-before -p "Clear all sessions except main? (y/n)" "run-shell 'tmux has-session -t main 2>/dev/null || tmux new-session -d -s main; tmux list-sessions -F \"##S\" | grep -v \"^main$\" | xargs -I {} tmux kill-session -t {}'"
    '';
  };

  # ==========================================================================
  # GHOSTTY TERMINAL CONFIGURATION
  # ==========================================================================
  # Managed via xdg.configFile in theme.nix for dynamic theme switching

  # ==========================================================================
  # YAZI FILE MANAGER CONFIGURATION
  # ==========================================================================
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      manager = {
        show_hidden = true;
        sort_by = "natural";
      };
    };

  };

  xdg.configFile."yazi/keymap.toml" = {
    force = true;
    text = ''
      [[mgr.prepend_keymap]]
      on = "<C-d>"
      run = "shell 'ripdrag %s -A -x -i 2>/dev/null &' --confirm"
      desc = "Drag and drop"

      [[mgr.prepend_keymap]]
      on = "y"
      run = [
        ''''shell '{ echo "mode:copy"; for path in %s; do echo "file://$path"; done; } | wl-copy -t text/uri-list' '''',
        "yank"
      ]
      desc = "Yank to Wayland Clipboard"

      [[mgr.prepend_keymap]]
      on = "x"
      run = [
        ''''shell '{ echo "mode:cut"; for path in %s; do echo "file://$path"; done; } | wl-copy -t text/uri-list' '''',
        "yank --cut"
      ]
      desc = "Cut to Wayland Clipboard"

      [[mgr.prepend_keymap]]
      on = "p"
      run = [
        ''''shell --
          clipboard=$(wl-paste -t text/uri-list)
          mode=$(echo "$clipboard" | grep "^mode:" | cut -d: -f2)

          echo "$clipboard" | grep "^file://" | sed 's|^file://||' | while read -r file; do
            if [ "$mode" = "cut" ]; then
              mv "$file" ./
            else
              cp -r "$file" ./
            fi
          done
        '''',
        "unyank"
      ]
      desc = "Paste & Sync from Wayland Clipboard"
    '';
  };

  # ==========================================================================
  # SYSTEMD USER SERVICES
  # ==========================================================================
  systemd.user.services.awww-daemon = {
    Unit = {
      Description = "Awww Wallpaper Management Daemon Engine";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.awww}/bin/awww-daemon";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.waypaper-restore = {
    Unit = {
      Description = "Waypaper Post-Initialization Wallpaper Restoration";
      Requires = [ "awww-daemon.service" ];
      After = [
        "awww-daemon.service"
        "graphical-session.target"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 0.5";
      ExecStart = "${pkgs.waypaper}/bin/waypaper --restore";
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.rclone-box = {
    Unit = {
      Description = "Rclone Box Drive Mount Service";
      AssertPathExists = "${config.home.homeDirectory}/.config/rclone/rclone.conf";
    };
    Service = {
      Type = "notify";
      ExecStartPre = "-${pkgs.coreutils}/bin/mkdir -p ${config.home.homeDirectory}/Box";

      ExecStart = "${pkgs.rclone}/bin/rclone mount boxdrive: ${config.home.homeDirectory}/Box --config=${config.home.homeDirectory}/.config/rclone/rclone.conf --vfs-cache-mode full --vfs-cache-max-age 1h --vfs-cache-max-size 10G --dir-cache-time 1m --poll-interval 1m --allow-other --umask 0022 --buffer-size 32M";

      ExecStop = "/run/wrappers/bin/fusermount3 -u ${config.home.homeDirectory}/Box";

      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # ==========================================================================
  # RUNTIME ENVIRONMENT SPLIT (Experimental Variant Engine)
  # ==========================================================================
  specialisation."quickshell-wip".configuration = {
    disabledModules = [ ./modules/desktop-stable.nix ];
    imports = [ ./modules/desktop-development.nix ];
  };
}

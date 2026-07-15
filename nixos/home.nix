{ config, pkgs, ... }:

{
  imports = [
    ./modules/hyprland.nix
    ./modules/desktop-stable.nix
  ];
  # Set up Home Manager state versioning constraints
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
    VISUAL="nvim";
    SUDO_EDITOR="nvim";
  };

  programs.git = {
    enable = true;
    settings.user.name = "elichall";
    settings.user.email = "1elijah.hall@gmail.com";
  };

  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    
    # Force Home Manager to export configuration layers for all toolkits
    gtk.enable = true;
    x11.enable = true;
  };
  
  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
  };

  # ==========================================================================
  # PERSISTENT SYSTEM PLUGINS & UTILITIES
  # ==========================================================================
  programs.starship = {
    enable = true;
    # blesh and starship have strict initialization orders
    enableBashIntegration = false;

    settings = {
      # Prepend $os to the default layout matrix
      format = "$os$directory$git_branch$git_status$character";
      add_newline = false;

      line_break.disabled = true;

      cmd_duration.disabled = true;

      # --- ISOLATED OS MODULE CONFIGURATION ---
      os.disabled = false;
      os.format = "[$symbol]($style) ";
      os.style = "bold #74c7ec"; # Catppuccin Sapphire / NixOS Blue

      os.symbols.NixOS = ""; 
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    #
    # defaultOptions = [
    #   "--bind 'ctrl-j:down,ctrl-k:up,ctrl-h:preview-up,ctrl-l:preview-down'"
    #   "--color='fg:7,bg:-1,hl:3'"
    #   "--color='fg+:15,bg+:8,hl+:3'"
    #   "--color='info:2,prompt:6,pointer:3'"
    #   "--color='marker:3,spinner:2,header:4'"
    # ];
  };

  # ==========================================================================
  # DECLARATIVE DOTFILE GENERATION
  # ==========================================================================
  home.file.".blerc".text = ''
    ble-face -s filename_directory 'fg=blue'
    ble-face -s filename_other fg=white,nounderline

    function blerc/emacs-load-hook {
      # Instantly accept the line using Ctrl-A
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
      snords = "sudo nixos-rebuild switch";
    };

    # 1. Force the terminal profile environment path hooks to load at the absolute top of the loop
    bashrcExtra = ''
      if [ -f ~/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
        . ~/.nix-profile/etc/profile.d/hm-session-vars.sh
      fi
    '';

    # 2. Run interactive setup components in the strict order required by ble.sh
    initExtra = ''
      shopt -s histappend
      shopt -s checkwinsize

      # Initialize ble.sh before any prompt configuration modifications occur
      if [[ $- == *i* ]]; then
        source ${pkgs.blesh}/share/blesh/ble.sh --noattach
      fi

      # Force Starship to execute its integration bindings *after* ble.sh loads
      if [[ $- == *i* ]]; then
        eval "$(${pkgs.starship}/bin/starship init bash --print-full-init)"
      fi

      # Lock the final ble-attach execution at the absolute end of the shell initialization loop
      [[ ''${BLE_VERSION-} ]] && ble-attach
    '';
  };

  # ==========================================================================
  # TMUX HOME MANAGEMENT
  # ==========================================================================
  programs.tmux = {
    enable = true;
    shortcut = "Space"; # Rewrites 'set -g prefix C-Space' automatically
    baseIndex = 1;      # Rewrites 'set -g base-index 1'
    keyMode = "vi";     # Rewrites 'set-window-option -g mode-keys vi'
    escapeTime = 0;     # Rewrites 'set -s escape-time 0'
    mouse = true;       # Rewrites 'set -g mouse on'

    # NATIVE PLUGIN MANAGEMENT (Replaces TPM declarations)
    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      # tmux-yank
      
      # Plugin configuration blocks use attributes for extra configuration parameters
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
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
      {
        plugin = tmux-fzf;
        extraConfig = ''
          TMUX_FZF_LAUNCH_KEY="tab"
        '';
      }
    ];

    # RAW TEXT CONFIGURATION OVERRIDES
    extraConfig = ''
      # Core Settings for Terminal Compatibility
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"
      set-option -g detach-on-destroy off

      # Start window/pane indexing at 1 instead of 0
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Visual Theme Hook (Kept intact for cross-platform fallback)
      if-shell '[ -f ~/.config/tmux/colors.tmux ]' 'source-file ~/.config/tmux/colors.tmux'

      # # --- YANKING & COPY MODE ---
      # unbind [
      # bind v copy-mode
      # bind-key -T copy-mode-vi v send-key -X begin-selection
      # bind-key -T copy-mode-vi C-v send-key -X rectangle-toggle
      # bind-key -T copy-mode-vi y send-key -X copy-selection-and-cancel
      # bind-key -T copy-mode-vi Escape send-key -X cancel

      bind p run "wl-paste -n | tmux load-buffer - ; tmux paste-buffer"

      # --- 1. PANE MANAGEMENT LAYER ---
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

      # --- 2. WINDOW MANAGEMENT LAYER ---
      bind n new-window -c "#{pane_current_path}"
      bind -n M-h previous-window
      bind -n M-l next-window
      bind X confirm-before -p "Kill current window? (y/n)" kill-window

      # --- 3. SESSION MANAGEMENT LAYER ---
      # INTERPOLATION: Nix extracts the precise path from the package variables
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
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      # Font declarations must be clean arrays or individual option assignments
      font-family = [
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono CJK JP"
      ];
      font-size = 13;
      theme = "Melange Dark";
      window-decoration = false;
      cursor-style = "block";
      background-opacity = 0.90;
      background-blur-radius = 20;
      confirm-close-surface = false;

      # OPTIMIZATION: Dynamic string injection fixes the Nix store path resolution
      command = "${pkgs.bash}/bin/bash";
    };
  };

  # ==========================================================================
  # YAZI FILE MANAGER CONFIGURATION
  # ==========================================================================
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;

    # System utilities needed by your custom ripdrag and wl-copy scripts
    extraPackages = with pkgs; [
      wl-clipboard
      ripdrag
    ];

    # Core system rules matching yazi.toml requirements
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "natural";
      };
    };

    # Declarative conversion of your custom keymaps.toml layout
    keymap = {
      manager.prepend_keymap = [
        {
          on = [ "<C-d>" ];
          run = "shell 'ripdrag \"$@\" -A -x -i 2>/dev/null &' --confirm";
          desc = "Drag and drop";
        }
        {
          on = [ "y" ];
          run = [
            "shell '{ echo \"mode:copy\"; for path in %*; do echo \"file://$path\"; done; } | wl-copy -t text/uri-list'"
            "yank"
          ];
          desc = "Yank to Wayland Clipboard";
        }
        {
          on = [ "x" ];
          run = [
            "shell '{ echo \"mode:cut\"; for path in %*; do echo \"file://$path\"; done; } | wl-copy -t text/uri-list'"
            "yank --cut"
          ];
          desc = "Cut to Wayland Clipboard";
        }
        {
          on = [ "p" ];
          run = [
            ''
              shell -- 
              clipboard=$(wl-paste -t text/uri-list)
              mode=$(echo "$clipboard" | grep "^mode:" | cut -d: -f2)
              
              echo "$clipboard" | grep "^file://" | sed 's|^file://||' | while read -r file; do
                if [ "$mode" = "cut" ]; then
                  mv "$file" ./
                else
                  copy -r "$file" ./
                fi
              done
            ''
            "unyank"
          ];
          desc = "Paste & Sync from Wayland Clipboard";
        }
      ];
    };
  };

  # ==========================================================================
  # STARTUP INITALIZATIONS AND DAEMONS
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
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  systemd.user.services.waypaper-restore = {
    Unit = {
      Description = "Waypaper Post-Initialization Wallpaper Restoration";
      Requires = [ "awww-daemon.service" ];
      After = [ "awww-daemon.service" "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 0.5";
      ExecStart = "${pkgs.waypaper}/bin/waypaper --restore";
      RemainAfterExit = true;
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  # ==========================================================================
  # RUNTIME ENVIRONMENT SPLIT (Experimental Variant Engine)
  # ==========================================================================
  specialisation."quickshell-wip".configuration = {
    # 1. Remove the stable panel layer to prevent layout clashing
    disabledModules = [ ./modules/desktop-stable.nix ];
    
    # 2. Inject your development environment parameters
    imports = [ ./modules/desktop-development.nix ];
  };
}

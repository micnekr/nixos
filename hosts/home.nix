{ config, pkgs, system, localflakes, ... }:

let homeDirectory = "/home/mic";
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mic";
  home.homeDirectory = homeDirectory;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    localflakes.nvim.packages.${system}.nvim

    # TODO: configure these
    pkgs.fzf
    pkgs.fishPlugins.fzf-fish

    pkgs.zip
    pkgs.unzip
    pkgs.trash-cli
    pkgs.gawk
    pkgs.restic
    pkgs.yt-dlp
    pkgs.ripgrep

    pkgs.btop

    pkgs.prismlauncher
    pkgs.obs-studio
    pkgs.discord
    pkgs.signal-desktop
    pkgs.zotero

    pkgs.mangohud
    pkgs.gimp
    pkgs.libreoffice

  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/mic/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };
  home.shellAliases = {
    "vim" = "nvim";
    "p" = "nix-shell -p";
    "switch-os" = "nh os switch";
    "switch-home" = "nh home switch";
    "vimconf" = "vim '+lua cd_and_find_files()'";

    "rm" = "trash -v";
    "mkdir" = "mkdir -p";
    "cls" = "clear";
    "cd-" = "cd -";
    "ps" = "ps auxf";
    "ls" = "ls -aFh --color=always"; # add colours and type of entry
    "ll" = "ls -l | less -F"; # Long listing format
    "lr" = "ls -R | less -F"; # recursive

    "diskspace" = "du -h --max-depth=1 | sort -h -r | less";
    "df" = "df -hT";

    "icat" = "kitten icat";
    "kssh" = "kitten ssh";
  };

  programs.fastfetch = {
    enable = true;
    settings =  
      {
	modules = [
	  {
	    type = "title";
	    color = {
	       user = "green";
	       at = "green";
	       host = "green";
	    };
	  }
	  "separator"
	  "os"
	  "host"
	  "kernel"
	  "uptime"
	  "packages"
	  "shell"
	  "editor"
	  "display"
	  # "de"
	  "wm"
	  # "wmtheme"
	  # "theme"
	  # "icons"
	  "font"
	  # "cursor"
	  # "terminal"
	  "terminalfont"
	  "cpu"
	  "gpu"
	  "memory"
	  "swap"
	  "disk"
	  "localip"
	  "battery"
	  "break"
	];
	# General settings
	"display" = {
	  "color" = {
	    "keys" = "blue";
	    "title" = "red";
	  };
	};
      };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    themeFile = "Catppuccin-Mocha";
    keybindings = {
      "alt+w" = "new_tab_with_cwd";
      "alt+x" = "close_tab";
      "alt+r" = "set_tab_title";
      "alt+shift+w" = "new_window";
      "alt+shift+x" = "close_window";
      "alt+down" = "next_window";
      "alt+up" = "previous_window";
      # let the user pick window by number
      "alt+backspace" = "focus_visible_window";
    } // 
      # Switch to tab with alt+number
      builtins.listToAttrs (builtins.map (num: {
	name = "alt+${toString num}";
	value = "goto_tab ${toString num}";
      } 
    ) (pkgs.lib.range 1 9) );
    settings = {
      "enabled_layouts" = "tall";
      "startup_session" = "${homeDirectory}/.config/nixos/config/kitty_startup_session.conf";
      "tab_bar_style" = "slant";
    };
  };


  programs.fish = {
    enable = true;
    interactiveShellInit=''
      source ~/.config/nixos/config/config.fish
    '';
  };
  programs.command-not-found.enable = false;

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;
      command_timeout = 1300;
      scan_timeout = 50;
      format = "$all$git_branch$git_commit$git_state$git_status\n$username$hostname$directory";
      git_status = {
	format = "$ahead_behind$conflicted";
      };
      character = {
	success_symbol = "[](bold green) ";
	error_symbol = "[✗](bold red) ";
      };
    };
  };

  programs.git = {
  	enable = true;
	userName = "micnekr";
	userEmail = "44928743+micnekr@users.noreply.github.com";
  };

  programs.mpv.enable = true;

  services.mpdris2 = {
    enable = true;
    multimediaKeys = true;
    notifications = true;
  };
  services.mpd = {
    enable = true;
    dbFile = "${homeDirectory}/Music/.mpd/database";
    musicDirectory = "${homeDirectory}/Music/library/";
    playlistDirectory = "${homeDirectory}/Music/.mpd/playlists";
    network = {
      listenAddress = "localhost";
      port = 6600;
    };
    extraConfig = ''
      # Logs to system journal
      log_file           "syslog"
      #pid_file           "~/.local/share/mpd/pid"
      state_file         "~/.local/share/mpd/state"
      sticker_file       "~/Music/.mpd/sticker.sql"

      auto_update "yes"

      restore_paused "yes"
      audio_output {
	      type            "pulse"
	      name            "pulse audio"
      }

      audio_output {
	      type            "fifo"
	      name            "ncmpcpp visualizer"
	      path            "/tmp/mpd.fifo"
	      format          "44100:16:1"
      }
    '';
  };
  programs.ncmpcpp = {
    enable = true;
    mpdMusicDir = "${homeDirectory}/Music/library/";
  };

  programs.thunderbird = {
    enable = true;
    profiles.mic = {
      isDefault = true;
    };
  };
}

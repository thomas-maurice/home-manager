{
  config,
  pkgs,
  lib,
  git ? {
    signingKey = null;
    user = {
      name = "Thomas Maurice";
      email = "thomas@maurice.fr";
    };
  },
  ...
}:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = git.user.name;
        email = git.user.email;
      };

      signing = lib.mkIf (git.signingKey != null) {
        key = git.signingKey;
        signByDefault = true;
      };

      push = {
        default = "simple";
      };

      commit = {
        gpgsign = git.signingKey != null;
      };

      core = {
        whitespace = "fix";
      };

      apply = {
        whitespace = "fix";
      };

      pull = {
        rebase = true;
      };

      init = {
        defaultBranch = "master";
      };

      # URL rewrites for git servers
      url."ssh://gitea@git.maurice.fr/" = {
        insteadOf = "https://git.maurice.fr/";
      };

      url."ssh://gitea@gitea.plil.fr/" = {
        insteadOf = "https://gitea.plil.fr/";
      };

      alias = {
        ci = "commit";
        co = "checkout";
        cob = "checkout -b";
        bs = "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'";
        br = "branch";
        rbi = "!git rebase -i $(git rev-list --first-parent master | head -1)";
        st = "status";
        am = "commit --amend";
        d = "diff";
        ds = "diff --stat";
        dc = "diff --cached";
        gr = "log --pretty=oneline --abbrev-commit --graph";
        lc = "!git gr ORIG_HEAD.. --stat --no-merges";
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        f = "fetch -p";
        ba = "branch -a";
        rank = "shortlog -sn --no-merges";
        sweep = "!git branch --merged | egrep -v '(^\\*|master|devel|stag|prod)' | xargs git branch -d";
        undo = "reset --soft HEAD^";
        alias = "!git config -l | grep ^alias | cut -c 7- | sort";
        amend = "commit --amend";
        pullr = "!BRANCH=$(git branch | grep \\* | cut -d ' ' -f2); git pull --rebase origin $BRANCH";
        pushdev = "!BRANCH=$(git branch | grep \\* | cut -d ' ' -f2); git push origin $BRANCH";
        pushdevf = "!BRANCH=$(git branch | grep \\* | cut -d ' ' -f2); git push -f origin $BRANCH";
      };
    };

    ignores = [
      # macOS
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "._*"

      # Linux
      "*~"
      ".directory"

      # Windows
      "Thumbs.db"
      "ehthumbs.db"
      "Desktop.ini"

      # IDE
      ".vscode/"
      ".idea/"
      "*.swp"
      "*.swo"
      "*~"

      # Misc
      ".envrc"
      ".direnv/"
    ];
  };
}

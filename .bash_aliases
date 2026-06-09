# --- ALIAS DEFINITIONS ---

# general cli llm
askai() {
  # Check if file descriptor 0 (stdin) is NOT a terminal
  if [ ! -t 0 ]; then
    {
      echo "$1"
      echo -e "\n--- File Context ---\n"
      cat
    } | ollama run qwen2.5:7b
  else
    ollama run qwen2.5:7b "$1"
  fi
}
# personal dotfiles bare git repo git call (works the same as normal git commands)
# dotgit add, dotgit commit, dotgit push etc
alias dotgit='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

dotupdate() {
  # Stage all modifications to currently tracked files only
  dotgit add -u

  # Check if a custom commit message was provided
  if [ -z "$1" ]; then
    # Default automated message with timestamp
    dotgit commit -m "System update: $(date +'%Y-%m-%d %H:%M')"
  else
    # Custom message
    dotgit commit -m "$1"
  fi

  # Push to remote
  dotgit push
}

alias nvlean="NVIM_APPNAME=nvim-lean nvim"

set -g fish_greeting

if command -sq nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
end

if status is-interactive
    if command -sq nvim
        alias vim nvim
        abbr --add v nvim
    end

    if command -sq git
        abbr --add g git
        abbr --add gst 'git status --short --branch'
        abbr --add ga 'git add'
        abbr --add gc 'git commit'
        abbr --add gco 'git checkout'
        abbr --add gd 'git diff'
        abbr --add gl 'git pull'
        abbr --add gp 'git push'
    end

    if command -sq docker
        abbr --add d docker
        abbr --add dc 'docker compose'
    end

    if command -sq kubectl
        abbr --add k kubectl
    end

    abbr --add cls clear
    abbr --add .. 'cd ..'
    abbr --add ... 'cd ../..'
end

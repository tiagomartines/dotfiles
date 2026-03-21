set -g fish_greeting

if status is-interactive
    if command -sq mise
        mise activate fish | source
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

    if command -sq mise
        abbr --add m mise
    end

    if command -sq docker
        abbr --add d docker
    end

    if command -sq docker-compose
        abbr --add dc docker-compose
    else if command -sq docker
        abbr --add dc 'docker compose'
    end

    if command -sq kubectl
        abbr --add k kubectl
    end

    abbr --add cls clear
    abbr --add .. 'cd ..'
    abbr --add ... 'cd ../..'
end

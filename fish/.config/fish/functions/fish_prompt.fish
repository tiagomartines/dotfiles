function fish_prompt --description 'Minimal prompt for daily development'
    set -l last_status $status
    set -l normal (set_color normal)
    set -l git_branch

    if command -sq git
        if command git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null
            set git_branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null)

            if test -z "$git_branch"
                set git_branch (command git rev-parse --short HEAD 2>/dev/null)
            end
        end
    end

    printf '%s%s%s' (set_color cyan) (prompt_pwd) $normal

    if test -n "$git_branch"
        printf ' %s(%s)%s' (set_color yellow) $git_branch $normal
    end

    if test $last_status -ne 0
        printf ' %s[%s]%s' (set_color red) $last_status $normal
    end

    printf ' %s>%s ' (set_color green) $normal
end

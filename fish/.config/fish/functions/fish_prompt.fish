function __prompt_git_ref --description 'Resolve the current git ref for the prompt'
    set -l head
    set -l oid

    for line in $argv
        switch $line
            case '# branch.head *'
                set head (string replace '# branch.head ' '' -- $line)
            case '# branch.oid *'
                set oid (string replace '# branch.oid ' '' -- $line)
        end
    end

    if test -z "$head"
        return 1
    end

    if test "$head" = "(detached)"
        if test -n "$oid"; and test "$oid" != "(initial)"
            string sub -s 1 -l 7 -- $oid
            return 0
        end

        return 1
    end

    printf '%s\n' $head
end

function __prompt_git_dirty --description 'Return success when the current git repo has local changes'
    for line in $argv
        if not string match -qr '^# ' -- $line
            return 0
        end
    end

    return 1
end

function __prompt_format_duration --description 'Format CMD_DURATION for the prompt'
    if test (count $argv) -eq 0
        return 1
    end

    set -l duration_ms $argv[1]

    if test $duration_ms -lt 60000
        if test $duration_ms -lt 10000
            printf '%.1fs\n' (math "$duration_ms / 1000")
        else
            printf '%ss\n' (math -s0 "$duration_ms / 1000")
        end

        return 0
    end

    set -l total_seconds (math -s0 "$duration_ms / 1000")
    set -l minutes (math -s0 "$total_seconds / 60")
    set -l seconds (math -s0 "$total_seconds % 60")

    if test $seconds -gt 0
        printf '%sm %ss\n' $minutes $seconds
        return 0
    end

    printf '%sm\n' $minutes
end

function __prompt_current_path --description 'Render the current path without abbreviation'
    set -l cwd $PWD

    if test "$cwd" = "$HOME"
        printf '~\n'
        return 0
    end

    if string match -q -- "$HOME/*" $cwd
        set -l suffix (string sub -s (math (string length -- $HOME) + 1) -- $cwd)
        printf '~%s\n' "$suffix"
        return 0
    end

    printf '%s\n' "$cwd"
end

function fish_prompt --description 'Two-line prompt with git context'
    set -l last_status $status
    set -l normal (set_color normal)
    set -l cwd_color (set_color blue)
    set -l git_color (set_color magenta)
    set -l dirty_color (set_color yellow)
    set -l meta_color (set_color brblack)
    set -l error_color (set_color red)
    set -l prompt_color (set_color green)

    printf '%s%s%s' $cwd_color (__prompt_current_path) $normal

    if command -sq git
        if command git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null
            # Pull git status once so branch and dirty state stay in sync.
            set -l git_status_lines (command git status --porcelain=2 --branch --ignore-submodules=dirty 2>/dev/null)
            set -l git_ref (__prompt_git_ref $git_status_lines)

            if test -n "$git_ref"
                printf ' %sgit:%s%s' $git_color $git_ref $normal

                if __prompt_git_dirty $git_status_lines
                    printf '%s*%s' $dirty_color $normal
                end
            end
        end
    end

    if test $last_status -ne 0
        printf ' %sexit:%s%s' $error_color $last_status $normal
        set prompt_color $error_color
    end

    if set -q CMD_DURATION; and test $CMD_DURATION -ge 3000
        printf ' %s%s%s' $meta_color (__prompt_format_duration $CMD_DURATION) $normal
    end

    printf '\n%s❯%s ' $prompt_color $normal
end

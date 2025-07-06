function fish_greeting
	fastfetch
end

# Map .. to `cd ..`, ... to `cd ../..`, etc
# https://fishshell.com/docs/current/relnotes.html
function dotmulticd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add dotdot --regex '^\.\.+$' --function dotmulticd

function multicd
    set num_repetitions 
    echo cd (string repeat -n (string match --groups-only -r "^cd(\d+)\$" $argv[1]) ../)
end
abbr --add cdnum --regex '^cd\d+$' --function multicd

function cd --description 'Change directory. Modified script to run ls at the end because fish makes it really difficult to call the original function'
    set -l MAX_DIR_HIST 25

    if set -q argv[2]; and begin
            set -q argv[3]
            or not test "$argv[1]" = --
        end
        printf "%s\n" (_ "Too many args for cd command") >&2
        return 1
    end

    # Skip history in subshells.
    if status --is-command-substitution
        builtin cd $argv
        ls -lh
        return $status
    end

    # Avoid set completions.
    set -l previous $PWD

    if test "$argv" = -
        if test "$__fish_cd_direction" = next
            nextd
        else
            prevd
        end
        ls -lh
        return $status
    end

    builtin cd $argv
    set -l cd_status $status

    if test $cd_status -eq 0 -a "$PWD" != "$previous"
        set -q dirprev
        or set -l dirprev
        set -q dirprev[$MAX_DIR_HIST]
        and set -e dirprev[1]

        # If dirprev, dirnext, __fish_cd_direction
        # are set as universal variables, honor their scope.

        set -U -q dirprev
        and set -U -a dirprev $previous
        or set -g -a dirprev $previous

        set -U -q dirnext
        and set -U -e dirnext
        or set -e dirnext

        set -U -q __fish_cd_direction
        and set -U __fish_cd_direction prev
        or set -g __fish_cd_direction prev

        ls -lh
    end

    return $cd_status
end

# If ssh-agent isn't running, create one
if not pgrep ssh-agent > /dev/null
    eval $(ssh-agent -c) > /dev/null
end

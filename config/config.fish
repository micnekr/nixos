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

function cd_and_ls
    builtin cd $argv
    ls
end

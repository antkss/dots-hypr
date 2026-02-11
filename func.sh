choice(){
    local text=$1
    local cmd=$2
    local p 
    local ask=false 

    echo "$text"

    while true; do
        read -p "(y|n) => " p
        case "$p" in
            [yY]) 
                ask=true
                break 
                ;;
            [nN]) 
                ask=false
                break 
                ;;
            *) 
                echo "Invalid input. Please enter 'y' for yes or 'n' for no."
                ;;
        esac
    done

    if [[ "$ask" == true ]]; then
        $cmd
    fi
}

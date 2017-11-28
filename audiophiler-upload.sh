show_usage() {
    echo 'Usage: audiophiler-upload file'
}

if [ $# -eq 0 ]; then
    show_usage
    exit 1
elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_usage
elif [ ! -f $1 ]; then
    echo "File $1 does not exist."
    exit 1
else
    cookies=$(mktemp)
    action=$(curl -c $cookies -Ls https://audiophiler.csh.rit.edu | grep -oP 'action="\K.*" ')
    read -p 'Enter username: ' username
    read -p 'Enter password: ' -s password
    echo
    audiophiler=$(curl -d "username=$username" -d "password=$password" -is ${action%??} | grep -oP 'Location: \K.*')
    if [ -z "$audiophiler" ]; then
        echo 'Incorrect username or password.'
        rm $cookies
        exit 1
    fi
    curl -b $cookies -c $cookies -Ls ${audiophiler%?} > /dev/null
    curl -b $cookies -F "file=@$1" -s https://audiophiler.csh.rit.edu/upload
    rm $cookies
fi

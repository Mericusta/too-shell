echo "cd $GT"
cd $GT

SPECIFY_SCP_FILE=$1

echo "get go or proto files"
MODIFIED_GO_FILE=`git status | egrep -o '[a-zA-Z0-9_/\-]+\.(go|proto)$'`

if [ -n "$SPECIFY_SCP_FILE" ]; then
MODIFIED_GO_FILE=($SPECIFY_SCP_FILE)
fi

pwd
for GO_FILE in ${MODIFIED_GO_FILE[@]}
do
    echo "scp $GO_FILE mericustar@192.168.1.32:\$GT/$GO_FILE"
    scp $GO_FILE mericustar@192.168.1.32:\$GT/$GO_FILE
done

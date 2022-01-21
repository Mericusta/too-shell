#!/bin/bash

FILENAME=
ALL_ENUM_TYPE=

while getopts f:t:h opt
do
    case $opt in
        f)
            echo "NOTE: manually specify file $OPTARG"
            FILENAME=$OPTARG
            if [ ! -f $FILENAME ]; then
                echo "NOTE: file $FILENAME does not exist"
                exit
            fi
            ;;
        t)
            echo "NOTE: manually specify enum type $OPTARG"
            ALL_ENUM_TYPE=($OPTARG)
            ;;
        h)
            echo "NOTE: code format helper"
            echo "NOTE: -f: specify a file to format"
            echo "NOTE: -t: specify an enum type to format in specified file, it will format all enum type when there is no enum type specified"
            echo "NOTE: -h: show help list"
            exit
            ;;
        ?)
            echo "NOTE: unkown option"
            exit
            ;;
    esac
done

if [ -z "$FILENAME" ]; then
    echo "NOTE: filename required, use -f [filename] to specify filename"
    exit
fi

if [ -z "$ENUM_TYPE" ]; then
    for ENUM_TYPE in `cat $FILENAME | grep 'type' | awk '{print $2}'`
    do
        ALL_ENUM_TYPE_LEN=${#ALL_ENUM_TYPE}
        ALL_ENUM_TYPE[$ALL_ENUM_TYPE_LEN]=$ENUM_TYPE
    done

    echo "NOTE: no enum type specified, it will format all enum type including [${ALL_ENUM_TYPE[*]}]"
fi

for ENUM_TYPE in ${ALL_ENUM_TYPE[*]}
do
    echo "NOTE: format ENUM_TYPE = $ENUM_TYPE"

    KEY_STRING="$ENUM_TYPE = "
    COMMENT_STRING="// "

    LINE_INDEX=0
    MAX_STRING_LEN=0
    for KEY_STRING_LINE in `cat $FILENAME | grep "$KEY_STRING" | awk -F "$KEY_STRING" '{print $1}'`
    do
        KEY_STRING_LINE_LEN=${#KEY_STRING_LINE}
        if [ $KEY_STRING_LINE_LEN -gt $MAX_STRING_LEN ]; then
            MAX_STRING_LEN=$KEY_STRING_LINE_LEN
        fi
    done

    # 处理注释的时候需要将 "// " 的长度算上
    MAX_STRING_LEN=`expr $MAX_STRING_LEN + ${#COMMENT_STRING}`

    LINE_INDEX=0
    COMMENT_LINE=
    while read LINE
    do
        LINE_INDEX=`expr $LINE_INDEX + 1`
        if [[ $LINE =~ $KEY_STRING ]]; then
            ENUM_KEY=`echo $LINE | awk '{print $1}'`
            ENUM_VALUE=`echo $LINE | awk '{print $4}'`

            ENUM_KEY_LEN=${#ENUM_KEY}
            INDEX=$ENUM_KEY_LEN
            FORMAT_ENUM_KEY=$ENUM_KEY
            while(( $INDEX<=$MAX_STRING_LEN ))
            do
                FORMAT_ENUM_KEY=$FORMAT_ENUM_KEY' '
                INDEX=`expr $INDEX + 1`
            done
            FORMAT_LINE=$FORMAT_ENUM_KEY$KEY_STRING$ENUM_VALUE
            sed -i "s/$LINE/$FORMAT_LINE/g" $FILENAME

            ENUM_COMMENT_LINE=$COMMENT_LINE
            if [[ $ENUM_COMMENT_LINE =~ $COMMENT_STRING ]]; then
                ENUM_COMMENT_KEY_INDEX=`expr index "$ENUM_COMMENT_LINE" $ENUM_KEY - 1`
                ENUM_COMMENT_LINE_WITHOUT_COMMENT_STRING=${ENUM_COMMENT_LINE:$ENUM_COMMENT_KEY_INDEX}

                ENUM_COMMENT_WITH_SPACE=${ENUM_COMMENT_LINE_WITHOUT_COMMENT_STRING:$ENUM_KEY_LEN}
                ENUM_COMMENT_WITHOUT_SPACE=`echo ${ENUM_COMMENT_LINE_WITHOUT_COMMENT_STRING:$ENUM_KEY_LEN}`

                FORMAT_ENUM_COMMENT_KEY_LEN=`expr ${#FORMAT_ENUM_KEY} - ${#COMMENT_STRING}`
                FORMAT_ENUM_COMMENT_LINE_WITHOUT_COMMENT_STRING=${FORMAT_ENUM_KEY:0:$FORMAT_ENUM_COMMENT_KEY_LEN}$ENUM_COMMENT_WITHOUT_SPACE

                sed -i "s/$ENUM_COMMENT_LINE_WITHOUT_COMMENT_STRING/$FORMAT_ENUM_COMMENT_LINE_WITHOUT_COMMENT_STRING/g" $FILENAME
            fi
        fi
        COMMENT_LINE=$LINE
    done < $FILENAME
    echo "NOTE: format $FILENAME enum type $ENUM_TYPE"
done

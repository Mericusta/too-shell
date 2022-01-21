#!/bin/bash

FILENAME=

INPUT_FILE_LIST=0
while getopts f:l:h opt
do
    case $opt in
        f)
            echo "NOTE: add comment to $OPTARG"
            FILENAME=$OPTARG
            ;;
        l)
            echo "NOTE: use $OPTARG as input file list"
            INPUT_FILE_LIST=1
            FILENAME=$OPTARG
            ;;
        h)
            echo "NOTE: code comment helper"
            echo "NOTE: -f: specify a file to add comment"
            echo "NOTE: -l: specify a file to read file list, then add comment"
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
    echo "NOTE: please use -h to show help list"
    exit
fi

while read INPUT_FILE_LINE
do
    if [ $INPUT_FILE_LIST -eq 1 ]; then
        FILENAME=`echo $INPUT_FILE_LINE`
        echo "INPUT_FILE_LINE = $INPUT_FILE_LINE"
    fi

    if [ ! -f $FILENAME ]; then
        echo "NOTE: $FILENAME does not exist"
        continue
    fi

    FUNC_START_KEY="func "
    FUNC_PARAM_START_KEY="("
    FUNC_PARAM_END_KEY=")"
    # func若干空格(结构体))若干空格函数名
    STRUCT_FUNC_START_KEY1="func\s*("

    echo "cat $FILENAME"

    cat $FILENAME | grep '^func [A-Z].*{\s*$' > tmpFile

    LINE_INDEX=0

    COMMENT_STRING="// "
    COMMENT_STRING_WITH_ESCAPE="\/\/ "
    PARAM_STRING="@param"
    RETURN_STRING="@return"

    while read LINE
    do
        # 获取关键数据
        FUNC_START_KEY_LEN=${#FUNC_START_KEY}
        FUNC_NAME_START_INDEX=$FUNC_START_KEY_LEN
        STRUCT_FUNC_KEY=`echo $LINE | grep -o "$STRUCT_FUNC_START_KEY1"`
        if [ -n "$STRUCT_FUNC_KEY" ]; then
            FUNC_NAME_START_INDEX=`expr index "$LINE" '\)'`
        fi
        FUNC_NAME_WITH_LEFT_CURLY_BRACKET=${LINE:$FUNC_NAME_START_INDEX}
            
        FUNC_NAME=`echo $FUNC_NAME_WITH_LEFT_CURLY_BRACKET | awk -F '(' '{print $1}'`
        FUNC_PARAMS=`echo $FUNC_NAME_WITH_LEFT_CURLY_BRACKET | awk -F '(' '{print $2}' | awk -F ')' '{print $1}'`
        echo "add comment to function $FUNC_NAME($FUNC_PARAMS)"

        OLD_IFS="$IFS"
        IFS=","
        FUNC_PARAMS_LIST=($FUNC_PARAMS)
        IFS="$OLD_IFS"
        PARAM_TYPE=

        MAX_PARAM_NAME_LEN=0
        PARAM_NAME_LIST=()
        for PARAM_INDEX in "${!FUNC_PARAMS_LIST[@]}"; do
            PARAM_NAME=`echo ${FUNC_PARAMS_LIST[PARAM_INDEX]} | awk '{print $1}'`
            PARAM_NAME_LIST[$PARAM_INDEX]=$PARAM_NAME        

            PARAM_LEN=${#PARAM_NAME}
            if [ $PARAM_LEN -gt $MAX_PARAM_NAME_LEN ]; then
                MAX_PARAM_NAME_LEN=$PARAM_LEN
            fi
        done

        # 生成字符串
        FUNC_NAME_COMMENT_STRING=$COMMENT_STRING_WITH_ESCAPE$FUNC_NAME" "

        PARAM_COMMENT_STRING_LIST=()
        for PARAM_INDEX in "${!PARAM_NAME_LIST[@]}"; do
            PARAM_NAME=${PARAM_NAME_LIST[$PARAM_INDEX]}
            PARAM_COMMENT_STRING=$COMMENT_STRING_WITH_ESCAPE$PARAM_STRING"  "$PARAM_NAME
            PARAM_NAME_LEN=${#PARAM_NAME}
            while(( $PARAM_NAME_LEN <= $MAX_PARAM_NAME_LEN ))
            do
                PARAM_COMMENT_STRING=$PARAM_COMMENT_STRING" "
                PARAM_NAME_LEN=`expr $PARAM_NAME_LEN + 1`
            done
            PARAM_COMMENT_STRING_LIST[$PARAM_INDEX]=$PARAM_COMMENT_STRING
        done

        SPACE_INDEX=0
        FUNC_RETURN_COMMENT_STRING=$COMMENT_STRING_WITH_ESCAPE$RETURN_STRING
        while(( $SPACE_INDEX <= $MAX_PARAM_NAME_LEN+1 ));
        do
            FUNC_RETURN_COMMENT_STRING=$FUNC_RETURN_COMMENT_STRING" "
            SPACE_INDEX=`expr $SPACE_INDEX + 1`
        done

        # 组装字符串
        FUNC_WITH_COMMENT=$FUNC_NAME_COMMENT_STRING"\n"
        for PARAM_INDEX in "${!PARAM_COMMENT_STRING_LIST[@]}"; do
            FUNC_WITH_COMMENT=$FUNC_WITH_COMMENT${PARAM_COMMENT_STRING_LIST[$PARAM_INDEX]}"\n"
        done
        FUNC_WITH_COMMENT=$FUNC_WITH_COMMENT$FUNC_RETURN_COMMENT_STRING"\n"
        FUNC_WITH_COMMENT=$FUNC_WITH_COMMENT$LINE

        # 处理特殊符号 "[", "]", "*"
        LINE_AFTER_ESCAPE=${LINE//\[/\\\[}
        LINE_AFTER_ESCAPE=${LINE_AFTER_ESCAPE//\]/\\\]}
        LINE_AFTER_ESCAPE=${LINE_AFTER_ESCAPE//\*/\\\*}

        FUNC_WITH_COMMENT_AFTER_ESCAPE=${FUNC_WITH_COMMENT//\[/\\\[}
        FUNC_WITH_COMMENT_AFTER_ESCAPE=${FUNC_WITH_COMMENT_AFTER_ESCAPE//\]/\\\]}
        FUNC_WITH_COMMENT_AFTER_ESCAPE=${FUNC_WITH_COMMENT_AFTER_ESCAPE//\*/\\\*}

        # echo "LINE_AFTER_ESCAPE = $LINE_AFTER_ESCAPE"
        # echo "FUNC_WITH_COMMENT_AFTER_ESCAPE = $FUNC_WITH_COMMENT_AFTER_ESCAPE"

        sed -i "s/$LINE_AFTER_ESCAPE/$FUNC_WITH_COMMENT_AFTER_ESCAPE/g" $FILENAME
    done < tmpFile
    
    if [ $INPUT_FILE_LIST -eq 0 ]; then
        exit
    fi
done < $FILENAME

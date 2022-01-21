#/bin/bash

CSV_FILENAME=
ALIGNMENT=
MD_FILENAME=

while getopts a:c:m:h opt
do
    case $opt in
        a)
            echo "NOTE: manually specify alignment $OPTARG"
            ALIGNMENT=$OPTARG
            ;;
        c)
            echo "NOTE: input csv file $OPTARG"
            CSV_FILENAME=$OPTARG
            ;;
        m)
            echo "NOTE: output markdown file $OPTARG"
            MD_FILENAME=$OPTARG
            ;;
        h)
            echo "NOTE: code format helper"
            echo "NOTE: -a: specify a type of alignment, default is alignment center"
            echo "NOTE: -c: input a csv file"
            echo "NOTE: -m: output a markdown file, default is markdown.md"
            echo "NOTE: -h: show help list"
            exit
            ;;
        ?)
            echo "NOTE: unkown option"
            exit
            ;;
    esac
done

if [ -z "$ALIGNMENT" ]; then
    echo "NOTE: use default setting: alignment center"
    ALIGNMENT=":-:"
fi

if [ -z "$CSV_FILENAME" ]; then
    echo "NOTE: input csv filename required, use -h to show help list"
    exit
fi

if [ ! -f $CSV_FILENAME ]; then
    echo "NOTE: input csv file does not exist"
    exit
fi

if [ -z "$MD_FILENAME" ]; then
    echo "NOTE: use default output md filename: markdown.md"
    MD_FILENAME="markdown.md"
fi

if [ -f $MD_FILENAME ]; then
    echo "NOTE: output markdown file already exist"
    exit
fi

cp $CSV_FILENAME $MD_FILENAME

# 读取第一行
TITLE_LINE=`head -1 $MD_FILENAME`

# 行首
sed -i "s/^/|/g" $MD_FILENAME
# 分隔
sed -i "s/\s/|/g" $MD_FILENAME
# 行尾
sed -i "s/$/|/g" $MD_FILENAME

TITLE_LINE_LIST=($TITLE_LINE)
COLUMN_INDEX=0
KEY_STRING="|"

while (( $COLUMN_INDEX < ${#TITLE_LINE_LIST[*]} ))
do
    KEY_STRING=$KEY_STRING$ALIGNMENT"|"
    COLUMN_INDEX=`expr $COLUMN_INDEX + 1`
done

# markdown 表格符号
sed -i "1a $KEY_STRING" $MD_FILENAME
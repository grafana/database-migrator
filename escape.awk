BEGIN {
    # Do not add new lines on print
    ORS = ""
}

/^INSERT/ {
    # Match columns definition
    match($0, /\([a-z0-9_"]+(,[a-z0-9_"]+)*\)/)

    # INSERT INTO table(
    prefix = substr($0, 0, RSTART)

    # ) VALUES...
    suffix = substr($0, RSTART+RLENGTH-1)

    # This is where the columns in the INSERT INTO are defined
    middle = substr($0, RSTART+1, RLENGTH-2)

    # strip all quotes from columns and create an array of column
    # names
    gsub(/"/, "", middle)
    split(middle, columns, ",")

    # print INSERT...
    print prefix

    sep = ""
    for(i in columns) {
        print sep "`" columns[i] "`"
        sep = ","
    }

    # print VALUES...
    print suffix "\n"
}

BEGIN {
    # Do not add new lines on print
    ORS = ""

    # Lowercase mySQL keywords and turn them into a dictionary
    split(tolower(reserved), ks, ", ")
    for(i in ks) {
        keywords[ks[i]] = 1
    }
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

    for(i in columns) {
        col = columns[i]
        if(keywords[col] == 1) {
            # column is a mySQL keyword, add backticks
            col = "`" col "`"
        }
        print col

        # Separate with commas; convert i into a number (string
        # otherwise)
        c = 0 + i
        if(c > 0 && c < length(columns)) {
            print ","
        }
    }

    # print VALUES...
    print suffix "\n"
}

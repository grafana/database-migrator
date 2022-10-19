# this script is used to backtick tables and columns for each insert statement
/^INSERT/ {
    # Match columns definition
    match($0, /^INSERT INTO (.+)\(([^\)]+)\) VALUES\((.+)\);$/, matches)

    table = matches[1]
    middle = matches[2]
    values = matches[3]

    # strip all quotes from columns and create an array of column
    # names
    gsub(/"/, "", middle)
    split(middle, columns, ",")

    sep = ""
    cols = ""
    for(i in columns) {
        cols = cols sep "`" columns[i] "`"
        sep = ","
    }

    printf("INSERT INTO `%s` (%s) VALUES (%s);\n", table, cols, values)
}

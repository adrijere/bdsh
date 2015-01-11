dbsh.sh - Shell Project - EPITECH

Emulated database written in shell script

SYNOPSIS
========

./bdsh.sh [-k] [-f <db_file>] (put (<key> | $<value>) (<value> | $<key>) 
                               del (<key> | $<key>) [<value> | $<key>] |
                               select [<expr> | $<key>] |
			       flush)

- put <key> <value> : Add a key <key> that contains the value <value>.
If the key exists already, the value is overwritten.
Nothing appears.
If the key doens't exist, the command "put" create the DB.

- del <key> [<value>] - Delete the key <key>. If the value is omitted, the key
still has no content. If the key does not exist or if the value does not match the key,
It's happening nothing.
If the database does not exist, the command "put" create the db.
Nothing appears.

- select [<expr>] - Display values whose key match <expr>, or all values if no parameters are passed.
This is the matching of the grep command is used. We use for the display the order of the file, which is
the chronological order of insertion or modification.
    
flush - Flush all the entries in the database. The file itself is not deleted.

When a value have to be displayed, it is only on the line. If the [-k] option is enabled, the key have to
also displayed like :
<key>=<value>
No spaces or other characters apart from the '=' between the key and the value.

[-F <db_file] is optional option which use the db_file on the program. If [-f] is not enabled, the program 
use the file "sh.db". 

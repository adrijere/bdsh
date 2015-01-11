#!/bin/sh

A=0
DATABASE=""
ACTION="none"
KEY="NULL"
VALUE="NULL"
TMP="NULL"

checkArg() { 
    if [ -z "$1" ]; then
	echo "Syntax error: USAGE - bdsh.sh [-k] [-f <db_file>] (put (<clef> | $<clef>) (<valeur> | $<clef>) | del (<clef> | $<clef>) [<valeur> | $<clef>] | select [<expr> | $<clef>] | flush)" >&2
	exit 1
    fi
}

main() {
	for var in "$@";
	do
	    if [ "$TMP" = "database" ]; then
		TMP="NULL"
		DATABASE="$var"
		continue
	    elif [ "$TMP" = "key" ]; then
		if [ "$ACTION" = "select" ]; then
		    TMP="NULL"
		else
		    TMP="value"
		fi
		KEY="$var"
		continue
	    elif [ "$TMP" = "value" ]; then
		TMP="NULL"
		VALUE="$var"
		continue
	    fi
	    if [ "$var" = "-k" ]; then
		A=1
	    elif [ "$var" = "put" ]; then
		ACTION="put"
		TMP="key"
	    elif [ "$var" = "del" ]; then
		ACTION="del"
		TMP="key"
	    elif [ "$var" = "select" ]; then
		ACTION="select"
		TMP="key"
	    elif [ "$var" = "-f" ]; then
		TMP="database"
	    elif [ "$var" = "flush" ]; then
		ACTION="flush"
	    else
		echo "Syntax error: Unknown command $var" >&2
		exit 1
	    fi
	done
}

checkKeyName() {
    if [ -z "$DATABASE" ]; then
	DATABASE="sh.db"
    fi
    echo "$KEY" | grep -q -e "^$.*" 
    if [ $? = 0 ]; then
	KEY=$( echo "$KEY" | cut -d"$" -f2- )
	grep -q -e"^$KEY=.*" "$DATABASE"
	if [ $? = 0 ]; then
	    KEY=$( grep -e "^$KEY=" "$DATABASE" | cut -d'=' -f2- )
	else
	    echo "No such key : any $KEY on the DB." >&2
	exit 1
	fi
    fi

    echo "$VALUE" | grep -q -e"^$.*" 
    if [ $? = 0 ]; then
	VALUE=$( echo "$VALUE" | cut -d"$" -f2- )
	grep -q -e"^$VALUE=.*" "$DATABASE"
	if [ $? = 0 ]; then
	    VALUE=$( grep -e "^$VALUE=" "$DATABASE" | cut -d'=' -f2- )
	else
	    echo "No such key : any key have this value : $VALUE ." >&2
	    exit 1
	fi
    fi
}
    
checkKeyValue() {
    if [ ! -e "$DATABASE" ] && [ "$ACTION" != "put" ]; then
	echo "No base found : file $DATABASE doesn't exist." >&2
	exit 1
    fi
    if [ "$ACTION" = "none" ]; then
	echo "No action selected" >&2
	exit 1
    elif [ "$ACTION" = "put" ]; then
	if [ ! -e "$DATABASE" ]; then
	    echo -n "" > "$DATABASE"
	fi
	if [ "$KEY" = "NULL" ] || [ "$VALUE" = "NULL" ]; then
	    echo KEY = "$KEY" -- VALUE = "$VALUE"
	    echo "Syntax error: USAGE - put (<clef> | $<clef>) (<valeur> | $<clef>)" >&2
	    exit 1
	fi
    elif [ "$ACTION" = "del" ]; then
	if [ "$KEY" = "NULL" ]; then
	    echo "Syntax error: USAGE - del (<clef> | $<clef>) [<valeur> | $<clef>] | select [<expr> | $<clef>]" >&2
	    exit 1
	fi
    fi
}


checkAction() {
    case "$ACTION" in
	"put") my_put;;
	"del") my_del;;
	"select") my_select;;
	"flush") my_flush;;
    esac
}

my_put() {
    grep -q -e "^$KEY=.*" "$DATABASE"
    if [ $? = 0 ]; then
	sed -i "$DATABASE" -e "s/^$KEY=.*/$KEY=$VALUE/g"
    else
	echo "$KEY=$VALUE" >> "$DATABASE"
    fi
}

my_del() {
    if [ "$VALUE" = "NULL" ]; then
	sed -i "$DATABASE" -e "s/^$KEY=.*/$KEY=/g"
    else
	sed -i "$DATABASE" -e "/^$KEY=$VALUE/d"
    fi
}

my_select() {
    if [ "$KEY" = "NULL" ]; then
	if [ "$A" = 0 ]; then
	    cut -d '=' -f2 "$DATABASE"
	else
	    cat "$DATABASE"
	fi
    else
	if [ "$A" = 0 ]; then
	    grep -e "^[^=]*$KEY.*=" "$DATABASE" | cut -d'=' -f2-
	else
	    cat "$DATABASE" | grep -e"^[^=]*$KEY.*="
	fi
    fi
    exit 0
}

my_flush() {
    echo -n "" > "$DATABASE"
}

checkArg "$1"
main "$@"
checkKeyName
checkKeyValue
checkAction

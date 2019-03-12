
#
# Compare two directory trees
#

diff <( tree -i "$1" ) <( tree -i "$2" )

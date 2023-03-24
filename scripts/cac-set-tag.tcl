set current_date [lindex [split [xvalue date [server.date]]] 0]

if { ![info exists "tagName"] } {
    puts "ERROR - must pass in tagName"
} elseif  { ![info exists "id"] } {
    puts "ERROR - must pass in id"
} else  {
    puts "running with ${tagName} ${id}"
    set existsResults [xvalue exists [asset.tag.type.exists :name ${tagName}]]
    if {${existsResults}} {
        asset.tag.add :id ${id} :tag "<:name ${tagName} :description 'Added by script on ${current_date}'>"
    } else {
        puts "Tag must already exists ${tagName}"
    }
}
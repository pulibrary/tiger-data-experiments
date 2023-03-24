set current_date [lindex [split [xvalue date [server.date]]] 0]

if { ![info exists "tagName"] } {
    puts "ERROR - must pass in tagName"
} else {
    puts "running with ${tagName}"
    set existsResults [xvalue exists [asset.tag.type.exists :name ${tagName}]]
    if {$existsResults} {
        puts "Tag already exists ${tagName}"
    } else {
        puts "Creating tag ${tagName}"
        asset.tag.type.create :name ${tagName} :description "Created by script on ${current_date}" 
    }
}
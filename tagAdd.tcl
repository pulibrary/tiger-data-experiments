# =======================================================================
# tagAdd - adds a tag (term) to the dictionary
#
# Usage:
#
# script.execute :in file:/Users/correah/src/mediaflux/tagAdd.tcl :arg -name tagName "tagXX" :arg -name tagDescription "this is the tag XX"
#
# =======================================================================

set log_name "homework-2023-03-22"
if { [info exists "tagName"] && [info exists "tagDescription"]} \
{
    server.log :app ${log_name} :event info :msg "Creating tag ${tagName}"
    dictionary.entry.add :term ${tagName} :definition ${tagDescription}
} \
else \
{
    server.log :app ${log_name} :event error :msg "tagAdd - tagName and/or tagDescription was not received"
    error "tagAdd - tagName and/or tagDescription was not received"
}

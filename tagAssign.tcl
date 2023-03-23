# =======================================================================
# tagAssign - assigns an existing tag to an asset.
#
# Usage:
#
# script.execute :in file:/Users/correah/src/mediaflux/tagAssign.tcl :arg -name tagName 'tagXX' :arg -name id 1033
#
# =======================================================================

set log_name "homework-2023-03-22"
if { [info exists "tagName"] && [info exists "id"]} \
{
    server.log :app ${log_name} :event info :msg "Assigning tag ${tagName} to ${id}"
    asset.tag.add :id ${id} :tag < :name ${tagName} >
} \
else \
{
    server.log :app ${log_name} :event error :msg "tagAssign - tagName and/or id was not received"
    error "tagAssign - tagName and/or id was not received"
}

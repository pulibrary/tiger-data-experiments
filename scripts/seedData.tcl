# ============================================================
# Create sample seed data in our local MediaFlux server.
# The sample data is organized as follows:
#
#   /td-hector-root-5/                      [NAMESPACE]
#       /research-computing                 [NAMESPACE]
#           /project-rc-1                   [COLLECTION ASSET]
#               (5 test files go here)      [ASSETS]
#           /project-rc-2                   [COLLECTION ASSET]
#               (5 test files go here)      [ASSETS]
#       /pppl
#           /project-pppl1                  [COLLECTION ASSET]
#               (5 test files go here)      [ASSETS]
#           /project-pppl-2                 [COLLECTION ASSET]
#               (5 test files go here)      [ASSETS]
#
# ============================================================
#
# BEFORE YOU BEGIN...
#
# In one Terminal window
#
# 1. Run the docker container
# docker run --interactive --rm --tty --privileged --init --name mediaflux --publish 0.0.0.0:8888:8888 docker.arcitecta.com:5000/princeton.edu/developer-image:2 /bin/bash
#
# 2. Run MediaFlux server (inside the container)
# /usr/bin/env java -jar /usr/local/mediaflux/bin/aserver.jar application.home=/usr/local/mediaflux nogui
#
# RUNNING THIS SCRIPT
#
# In another Terminal window
#
# 1. Run aterm
# java -jar aterm.jar
#
# 2. Inside aterm run
# script.execute :in file:/Users/correah/src/mediaflux/seedData.tcl
#
# Be sure to change the value of ROOT below if you run this script multiple times.
#

set ROOT "td-hector-root-6"
set LOG_NAME "seeddata-2023-03-23"

proc logMessage { message } \
{
    global LOG_NAME
    server.log :app ${LOG_NAME} :event info :msg "${message}"
}

proc projectId { namespace project } \
{
    set result [asset.query :namespace $namespace :where "name='$project'"]
    set pid [xvalue id $result]
    return $pid
}

proc createSampleAssets { namespace project } \
{
    logMessage "Creating sample assets for ${namespace} {$project}"
    set pid [projectId $namespace $project]
    asset.test.create :base-name "$project-dyn-" :nb 5 :pid $pid
}

# Create our root namespaces and one namespace per-organization
logMessage "Creating namespaces"
asset.namespace.create :namespace ${ROOT}
asset.namespace.create :namespace ${ROOT}/research-computing
asset.namespace.create :namespace ${ROOT}/pppl
asset.namespace.create :namespace ${ROOT}/pul

# Create a few default projects per organization
# (these are created as collection-assets)
logMessage "Creating projects for research-computing"
asset.create :namespace ${ROOT}/research-computing :name project-rc-1 :collection -contained-asset-index true -unique-name-index true true
asset.create :namespace ${ROOT}/research-computing :name project-rc-2 :collection -contained-asset-index true -unique-name-index true true
asset.create :namespace ${ROOT}/research-computing :name project-rc-3 :collection -contained-asset-index true -unique-name-index true true

logMessage "Creating projects for pppl"
asset.create :namespace ${ROOT}/pppl :name project-pppl-1 :collection -contained-asset-index true -unique-name-index true true
asset.create :namespace ${ROOT}/pppl :name project-pppl-2 :collection -contained-asset-index true -unique-name-index true true
asset.create :namespace ${ROOT}/pppl :name project-pppl-3 :collection -contained-asset-index true -unique-name-index true true
asset.create :namespace ${ROOT}/pppl :name project-pppl-4 :collection -contained-asset-index true -unique-name-index true true

logMessage "Creating projects for pul"
asset.create :namespace ${ROOT}/pul :name project-pul-1 :collection -contained-asset-index true -unique-name-index true true
asset.create :namespace ${ROOT}/pul :name project-pul-2 :collection -contained-asset-index true -unique-name-index true true

# Create a few sample files for Research Computing projects
set namespace $ROOT/research-computing
createSampleAssets $namespace project-rc-1
createSampleAssets $namespace project-rc-2
createSampleAssets $namespace project-rc-3

# Create a few sample files for PPPL projects
set namespace $ROOT/pppl
createSampleAssets $namespace project-pppl-1
createSampleAssets $namespace project-pppl-2
createSampleAssets $namespace project-pppl-3
createSampleAssets $namespace project-pppl-4

# Create a few sample files for PUL projects
set namespace $ROOT/pul
createSampleAssets $namespace project-pul-1
createSampleAssets $namespace project-pul-2


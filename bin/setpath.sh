#!/bin/bash

BASE=${HOME}/hpc-collab
CLUSTERS=${BASE}/clusters
provision_bin=${BASE}/bin
clusters_bin=${CLUSTERS}/common/bin
PWD=$(pwd)

export HUSH=@

for e in ${provision_bin} ${clusters_bin}
do
  case "${PATH}" in
    *${e}*)				;;
    *)	export PATH=${PATH}:${e}	;;
  esac
done

# XXX @todo collect enabled clusters (vc,vx) dynamically, similarly to the Makefile,
## that is, they are enabled if a Makefile and a Vagrantfile is present

set nodes=""
for n in $(ls -d ${CLUSTERS}/{vc,vx}/cfg/* | grep -v provision | egrep 'vc|vx' | sort -d | uniq)
do
  nodes="${nodes} $(basename ${n})"
done

# node aliases:
#  <nodename>	==> <nodename> up
#  <nodename>--	==> unprovision <nodename>
#  <nodename>!	==> unprovision and then bring <nodename> up, without regard to its previous state

# cluster aliases:
#  <cluster>	=> <cluster> up
#  <cluster>--	=> unprovision <cluster>
#  <cluster>!	==> unprovision and then bring <cluster> up, without regard to its previous state

for n in ${nodes}
do
  declare -x cl=${n:0:2}

  declare -x cluster_dir=${CLUSTERS}/${cl}
  alias	"${n}"="make -C ${cluster_dir} ${n}"
  alias	"${n}!"="make -C ${cluster_dir} ${n}_UNPROVISION; make -C ${cluster_dir} ${n}"
  alias	"${n}--"="make -C ${cluster_dir} ${n}_UNPROVISION" 

  # yes, this redefines the alias for multiple nodes; that is not costly
  alias	"${cl}"="make -C ${cluster_dir} up"
  alias	"${cl}--"="make -C ${cluster_dir} unprovision"
  alias	"${cl}!"="make -C ${cluster_dir} unprovision; make -C ${cluster_dir} up"
done

# common aliases for all clusters:
for t in help show up pkg prereq provision unprovision down
do
  alias "${t}"="make -C ${BASE} ${t}"
done
alias  "savelogs"="make -C ${CLUSTERS} savelogs"

# when/if needed
# ssh-add ${CLUSTERS}/*/.vag*/machines/*/virtualbox/private_key > /dev/null 2>&1
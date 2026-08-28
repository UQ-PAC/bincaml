


CONT=$(podman run -d ghcr.io/agle/bincaml-ci-containers/ci-simple-5.4:latest sleep infinity)
#podman exec $CONT mkdir /action
podman cp tools/action.sh "$CONT:run.sh"
podman exec $CONT sudo apt-get install libcapstone-dev --yes
podman exec -e "GITHUB_REPOSITORY=uq-pac/bincaml" -e "GITHUB_SHA=main" $CONT bash run.sh
#ex=$?

#podman kill $CONT

#exit $ex

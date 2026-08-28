


CONT=$(podman run -d ghcr.io/agle/bincaml-ci-containers/ci-5.4:latest sleep infinity)
podman exec $CONT mkdir /action
podman cp tools/action.sh $CONT:/action/run.sh
podman exec -e GITHUB_REPOSITORY=agle/bincaml -e GITHUB_SHA=$(git rev-parse HEAD) $CONT bash /action/run.sh
ex=$?

podman kill $CONT

exit $ex

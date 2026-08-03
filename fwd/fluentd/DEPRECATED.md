# DEPRECATED

The `fluentd-10x` image (Fluentd with the 10x Engine baked in, running
**in-process** inside the forwarder container) is **retired**.

Fluentd now runs the 10x Engine as a separate `log10x/edge-10x` **sidecar
container** on the upstream `fluent/fluentd` Helm chart (kustomize post-renderer
overlay), talking over loopback TCP.

This Dockerfile is kept for **legacy rebuilds only**. See the current model:
<https://doc.log10x.com/apps/receiver/deploy/>

## No `:latest` tag, and that is deliberate

`log10x/fluentd-10x` has no `:latest`. Neither does `log10x/fluent-bit-10x`, the
other retired forwarder. `filebeat-10x` does, because Filebeat is the one
forwarder still genuinely embedded.

`:latest` is a mutable convenience pointer at the newest build of one image. On a
retired build path there is nothing to be convenient about: no docs tell anyone to
pull this image, and `charts/fluentd/values.yaml` in `log-10x/fluent-helm-charts`
defaults its tag to `{{ .Chart.AppVersion }}-{{ .Values.tenx.variant }}`, an
explicit version, never `latest`. A `:latest` here would only advertise a path we
have moved off, and it would move under anyone who found it.

Mechanically the tag is withheld by one input, not by a missing job.
`publish_10x_forwarder.yaml` carries `publish_latest_manifest` and every forwarder
routes through that workflow, this one included. The job is gated on
`publish_latest`, and `publish_10x_all_forwarders.yaml` sets that on the
`filebeat` job alone, because the standard and debug builds would otherwise race
for the same tag. So this is not the shape of the `lambda-10x` gap fixed in
[#14](https://github.com/log-10x/docker-images/pull/14), where
`publish_latest_manifest` was absent from the workflow file and had to be added.

If Fluentd ever returns to an embedded build, set `publish_latest: true` on the
`fluentd` job and on no other Fluentd job. Until then, leave it off.

# DEPRECATED

The `fluent-bit-10x` image (Fluent Bit with the 10x Engine baked in, running
**in-process** inside the forwarder container) is **retired**.

Fluent Bit now runs the 10x Engine as a separate `log10x/edge-10x` **sidecar
container** on the upstream `fluent/fluent-bit` Helm chart (`extraContainers`
values overlay), talking over loopback TCP.

This Dockerfile is kept for **legacy rebuilds only**. See the current model:
<https://doc.log10x.com/apps/receiver/deploy/>

## No `:latest` tag, and that is deliberate

`log10x/fluent-bit-10x` has no `:latest`, same as `log10x/fluentd-10x`, the other
retired forwarder. `filebeat-10x` does, because Filebeat is the one forwarder
still genuinely embedded. The full reasoning lives in
[`fwd/fluentd/DEPRECATED.md`](../fluentd/DEPRECATED.md) and applies here
unchanged.

Short version: `:latest` is a mutable convenience pointer at the newest build of
one image, and on a retired build path there is nothing to be convenient about.
The tag is withheld by the `publish_latest` input on the `filebeat` job in
`publish_10x_all_forwarders.yaml`, not by a missing job. Leave it off.

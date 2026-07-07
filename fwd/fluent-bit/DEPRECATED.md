# DEPRECATED

The `fluent-bit-10x` image (Fluent Bit with the 10x Engine baked in, running
**in-process** inside the forwarder container) is **retired**.

Fluent Bit now runs the 10x Engine as a separate `log10x/edge-10x` **sidecar
container** on the upstream `fluent/fluent-bit` Helm chart (`extraContainers`
values overlay), talking over loopback TCP.

This Dockerfile is kept for **legacy rebuilds only**. See the current model:
<https://doc.log10x.com/apps/receiver/deploy/>

Filebeat remains an image swap (`log10x/filebeat-10x`) — it is the one genuinely
embedded forwarder.

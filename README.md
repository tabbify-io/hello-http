# hello-http — multi-target test app

A minimal HTTP server (busybox httpd on :8080, exec-form entrypoint) used to verify
the unified `tabbify.toml` + runtime-at-deploy pipeline. The **same OCI image** is
deployed as `docker` (ec2-prod) AND `firecracker` (thinkpad) — proving you do not
need a separate "FC project": the runtime is chosen at deploy time.

Why busybox httpd:
- exec-form `ENTRYPOINT` (required by the generic-Firecracker OCI→ext4 path, spec D3),
- serves HTTP 200 on :8080 (the Firecracker guest contract + the docker proxy port),
- tiny rootfs, so the OCI→ext4 conversion is fast.

## Deploy via API (runtime chosen per target)

```bash
# from the workspace; node_key auto-fetched from SSM by the helper
NODE=https://api.tabbify.io
KEY=$(aws ssm get-parameter --name /tabbify/node/key --with-decryption \
       --profile tabbify --region eu-central-1 --query Parameter.Value --output text)

# docker on ec2-prod + firecracker on thinkpad, one build, both runtimes:
curl -fsS -XPOST "$NODE/v1/deploy" -H "Authorization: Bearer $KEY" \
  -H 'content-type: application/json' \
  -d '{"repo_url":"https://github.com/tabbify-io/hello-http","ref":"main",
       "tenant":"tabbify","app_uuid":"<uuid>","builder":"ec2-prod",
       "targets":[{"supervisor":"ec2-prod","runtime":"docker"},
                  {"supervisor":"thinkpad","runtime":"firecracker"}]}'
```

Or commit `tabbify.toml` and `git push` (webhook reads `[[deploy]]`).

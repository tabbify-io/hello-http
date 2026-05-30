# Minimal HTTP test app for Tabbify — the SAME image runs as docker OR firecracker
# (runtime is chosen at deploy time). busybox httpd serves /www on :8080.
# EXEC-FORM ENTRYPOINT is required by the generic-Firecracker path (spec D3).
FROM busybox:1.36
COPY index.html /www/index.html
EXPOSE 8080
ENTRYPOINT ["busybox", "httpd", "-f", "-v", "-p", "8080", "-h", "/www"]

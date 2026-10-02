{{/*
Pod spec that forms the Valkey cluster, or re-forms it when it has broken.
Node topology (nodes.conf) lives on emptyDir and nodes announce pod IPs, so a
restarted pod comes back empty with a new IP. The cache holds no durable data,
so instead of repairing membership the script resets every node and creates
the cluster again whenever any node is unhealthy or misses a peer.
Used by the Sync hook Job (first formation) and the CronJob (self-healing).
*/}}
{{- define "validate-email.cacheClusterReconcilePod" -}}
restartPolicy: OnFailure
containers:
  - name: cluster-reconcile
    image: "{{ .Values.cache.image.repository }}:{{ .Values.cache.image.tag }}"
    command: ["/bin/sh", "-c"]
    args:
      - |
        set -e
        NODES={{ .Values.cache.cluster.nodes }}
        REPLICAS={{ .Values.cache.cluster.replicas }}
        SERVICE="{{ include "validate-email.fullname" . }}-cache"
        host() { echo "${SERVICE}-$1.${SERVICE}"; }
        LAST=$((NODES - 1))

        for i in $(seq 0 $LAST); do
          until valkey-cli -h "$(host $i)" -p 6379 ping 2>/dev/null | grep -q PONG; do
            echo "waiting for $(host $i) ..."; sleep 2
          done
        done

        healthy=1
        for i in $(seq 0 $LAST); do
          INFO=$(valkey-cli -h "$(host $i)" -p 6379 cluster info 2>/dev/null || true)
          KNOWN=$(echo "$INFO" | sed -n 's/^cluster_known_nodes:\([0-9]*\).*/\1/p')
          if ! echo "$INFO" | grep -q 'cluster_state:ok' || [ "$KNOWN" != "$NODES" ]; then
            echo "$(host $i): unhealthy (known nodes: ${KNOWN:-?})"
            healthy=0
          fi
        done
        if [ "$healthy" = 1 ]; then
          echo "cluster healthy: $NODES nodes, state ok"
          exit 0
        fi

        echo "re-forming the cluster; cache contents are discarded"
        NODE_LIST=""
        for i in $(seq 0 $LAST); do
          H="$(host $i)"
          valkey-cli -h "$H" -p 6379 flushall >/dev/null 2>&1 || true   # replicas refuse; reset flushes them
          valkey-cli -h "$H" -p 6379 cluster reset hard
          IP=$(getent hosts "$H" | awk '{print $1}')
          [ -n "$IP" ] || { echo "ERROR: could not resolve $H"; exit 1; }
          NODE_LIST="$NODE_LIST $IP:6379"
        done
        valkey-cli --cluster create $NODE_LIST --cluster-replicas "$REPLICAS" --cluster-yes
        valkey-cli -h "$(host 0)" -p 6379 cluster info | grep -E 'cluster_state|cluster_known_nodes'
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

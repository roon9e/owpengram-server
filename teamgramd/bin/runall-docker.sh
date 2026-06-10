#!/usr/bin/env bash
# Logs go to /app/logs/*.log (volume) for filebeat; works on Docker Desktop Mac/Win where
# /var/lib/docker/containers is not visible to filebeat container.

wait_for_tcp() {
	local host="$1"
	local port="$2"
	local label="$3"
	local attempts="${4:-60}"
	local i=1
	while [ "$i" -le "$attempts" ]; do
		if (echo >"/dev/tcp/${host}/${port}") >/dev/null 2>&1; then
			echo "${label} is ready (${host}:${port})"
			return 0
		fi
		echo "waiting for ${label} (${host}:${port})... ${i}/${attempts}"
		sleep 2
		i=$((i + 1))
	done
	echo "timeout waiting for ${label} (${host}:${port})"
	return 1
}

run_service() {
	local name="$1"
	local bin="$2"
	local config="$3"
	local retries="${4:-5}"
	local attempt=1
	while [ "$attempt" -le "$retries" ]; do
		echo "run ${name} (attempt ${attempt}/${retries}) ..."
		"./${bin}" -f="${config}" &
		local pid=$!
		sleep 3
		if kill -0 "$pid" 2>/dev/null; then
			echo "${name} started (pid ${pid})"
			return 0
		fi
		echo "warn: ${name} exited early, retrying ..."
		attempt=$((attempt + 1))
		sleep 2
	done
	echo "error: ${name} failed to start after ${retries} attempts"
	return 1
}

echo "waiting for infrastructure ..."
wait_for_tcp etcd 2379 etcd || exit 1
wait_for_tcp mysql 3306 mysql || exit 1
wait_for_tcp redis 6379 redis || exit 1
wait_for_tcp kafka 9092 kafka || exit 1

run_service idgen idgen ../etc2/idgen.yaml
run_service status status ../etc2/status.yaml
run_service authsession authsession ../etc2/authsession.yaml
run_service dfs dfs ../etc2/dfs.yaml
run_service media media ../etc2/media.yaml
run_service biz biz ../etc2/biz.yaml
run_service msg msg ../etc2/msg.yaml
run_service sync sync ../etc2/sync.yaml
run_service bff bff ../etc2/bff.yaml
run_service session session ../etc2/session.yaml
run_service gnetway gnetway ../etc2/gnetway.yaml

# echo "run httpserver ..."
# ./httpserver -f=../etc/httpserver.yaml &
# sleep 1

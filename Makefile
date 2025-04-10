APP ?= todo
VERSION ?= 0.0.0
KIND-CLUSTER ?= salex
BIN ?= bin
IMAGE ?= $(APP):$(VERSION)
CONTAINER_PORT ?= 8082

ifeq ($(OS),Windows_NT)
	CLEAN_CMD ?= rmdir $(BIN) /s /q
	EXECUTABLE := $(BIN)/$(APP).exe
else
	CLEAN_CMD ?= rm -rf $(BIN)
	EXECUTABLE := $(BIN)/$(APP)
endif

# ===================================
# Build and run local
# ===================================

.PHONY: build
build: | $(BIN)
	go build -o $(EXECUTABLE) cmd/main.go

.PHONY: run
run:
	go run cmd/main.go

.PHONY: clean
clean:
	$(CLEAN_CMD)

$(BIN):
	mkdir $(BIN)

# ===================================
# Build and run docker image
# ===================================

.PHONY: docker-build
docker-build:
	docker build -t ${IMAGE} .

.PHONY: docker-run
docker-run: docker-build
	docker run -p 127.0.0.1:80:${CONTAINER_PORT}/tcp -e SALEX_TODO_APP_PORT=${CONTAINER_PORT} -d --name ${APP} ${IMAGE}

.PHONY: docker-remove
docker-remove:
	docker stop ${APP}
	docker rm ${APP}
	docker image rm ${IMAGE}

# ===================================
# Deploy to local kind
# ===================================

.PHONY: kind-deploy
kind-deploy: kind-load-image
	helm upgrade -i hello chart/hello --set "name=${APP},container.image=${IMAGE}" --kube-context kind-${KIND-CLUSTER}

.PHONY: kind-undeploy
kind-undeploy:
	helm delete ${APP} --kube-context kind-${KIND-CLUSTER} --wait
	docker exec -it sandbox-control-plane crictl rmi ${IMAGE}

.PHONY: kind-load-image
kind-load-image: docker-build
	kind load docker-image ${IMAGE} --name ${KIND-CLUSTER}

# ---- Alternative examples using kubectl instead of helm ---
#.PHONY: kind-deploy
#kind-deploy-image: kind-load-image
#	kubectl config use-context kind-${KIND-CLUSTER}
#	kubectl apply -f config/deployment.yml
#	kubectl apply -f config/service.yml
#
#.PHONY: kind-undeploy
#kind-undeploy:
#	kubectl config use-context kind-${KIND-CLUSTER}
#	kubectl delete -f config/service.yml
#	kubectl delete -f config/deployment.yml

# ===================================
# Inspection targets
# ===================================

.PHONY: show-images-docker
show-images-docker:
	docker image ls | grep ${APP}

.PHONY: show-images-kind
show-images-kind:
	docker exec -it sandbox-control-plane crictl images | grep ${APP}

.PHONY: show-helm-history
show-helm-history:
	helm history ${APP}


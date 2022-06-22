# =============================================================================
# Make variables
# =============================================================================
CONTAINER_REGISTRY=quay.io/corbsmartin
FRONTEND_IMAGE=frontend-ui
FRONTEND_IMAGE_TAG=v1-ocp
BACKEND_IMAGE=backend-api
BACKEND_IMAGE_TAG=v1-ocp
APP_NAMESPACE=sample-app
ISTIO_NAMESPACE=istio-system

init-frontend:
	@cd ./frontend && npm install
# =============================================================================
# Build and run frontend container image for production
# =============================================================================
push-images: frontend-push backend-push

frontend-image:
	@cd ./frontend && REACT_APP_API_HOST=sample-app.apps-crc.testing \
		REACT_APP_API_PORT=443 \
		REACT_APP_API_ENDPOINT=https://sample-app.apps-crc.testing/api \
		REACT_APP_IMAGE=$(FRONTEND_IMAGE):$(FRONTEND_IMAGE_TAG) \
		npm run build
	@podman build -f frontend.Containerfile -t $(FRONTEND_IMAGE):$(FRONTEND_IMAGE_TAG)

frontend-push: frontend-image
	@podman tag $(FRONTEND_IMAGE):$(FRONTEND_IMAGE_TAG) \
		$(CONTAINER_REGISTRY)/$(FRONTEND_IMAGE):$(FRONTEND_IMAGE_TAG)
	@podman push $(CONTAINER_REGISTRY)/$(FRONTEND_IMAGE):$(FRONTEND_IMAGE_TAG)
# =============================================================================
# Build and run backend container image for production
# =============================================================================
backend-image:
	@podman build -f backend.Containerfile -t $(BACKEND_IMAGE):$(BACKEND_IMAGE_TAG)

backend-push: backend-image
	@podman tag $(BACKEND_IMAGE):$(BACKEND_IMAGE_TAG) \
		$(CONTAINER_REGISTRY)/$(BACKEND_IMAGE):$(BACKEND_IMAGE_TAG)
	@podman push $(CONTAINER_REGISTRY)/$(BACKEND_IMAGE):$(BACKEND_IMAGE_TAG)
# =============================================================================
# Deploy targets
# =============================================================================
apply:
	@oc apply -f ./manifests/app-ocp/backend-api.yaml -n $(APP_NAMESPACE)
	@oc apply -f ./manifests/app-ocp/frontend-ui.yaml -n $(APP_NAMESPACE)
	@oc apply -f ./manifests/app-ocp/ingress-route.yaml -n $(APP_NAMESPACE)

delete:
	@oc delete -f ./manifests/app-ocp/ingress-route.yaml -n $(APP_NAMESPACE)
	@oc delete -f ./manifests/app-ocp/frontend-ui.yaml -n $(APP_NAMESPACE)
	@oc delete -f ./manifests/app-ocp/backend-api.yaml -n $(APP_NAMESPACE)

apply-istio:
	@oc apply -f ./manifests/app-istio/backend-api.yaml -n $(APP_NAMESPACE)
	@oc apply -f ./manifests/app-istio/frontend-ui.yaml -n $(APP_NAMESPACE)
	@oc apply -f ./manifests/app-istio/istio-services.yaml -n $(APP_NAMESPACE)
	@oc apply -f ./manifests/app-istio/ingress-route.yaml -n $(ISTIO_NAMESPACE)

delete-istio:
	@oc delete -f ./manifests/app-istio/ingress-route.yaml -n $(ISTIO_NAMESPACE)
	@oc delete -f ./manifests/app-istio/istio-services.yaml -n $(APP_NAMESPACE)
	@oc delete -f ./manifests/app-istio/frontend-ui.yaml -n $(APP_NAMESPACE)
	@oc delete -f ./manifests/app-istio/backend-api.yaml -n $(APP_NAMESPACE)
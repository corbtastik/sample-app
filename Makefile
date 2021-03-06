# =============================================================================
# Make variables
# =============================================================================
CONTAINER_REGISTRY=quay.io/corbsmartin
FRONTEND_IMAGE=frontend-ui
FRONTEND_IMAGE_TAG=v1
BACKEND_IMAGE=backend-api
BACKEND_IMAGE_TAG=v1
APP_NAMESPACE=sample-app
ISTIO_NAMESPACE=istio-system
# =============================================================================
# Build and run frontend container image for production
# =============================================================================
push-images: frontend-push backend-push

frontend-dev-image:
	@cp -r backend/api frontend/public
	@mkdir -p frontend/.build-tmp
	@mv frontend/.env.production frontend/.build-tmp
	@cd frontend
	@podman build -f frontend.Containerfile -t $(FRONTEND_IMAGE):$(FRONTEND_IMAGE_TAG) .
	@cd ..
	@mv frontend/.build-tmp/.env.production frontend/
	@rm -fr frontend/.build-tmp

frontend-prod-image:
	@cd frontend
	@podman build -f frontend.Containerfile -t $(FRONTEND_IMAGE):$(FRONTEND_IMAGE_TAG) .

frontend-push: frontend-prod-image
	@podman tag $(FRONTEND_IMAGE):$(FRONTEND_IMAGE_TAG) \
		$(CONTAINER_REGISTRY)/$(FRONTEND_IMAGE):$(FRONTEND_IMAGE_TAG)
	@podman push $(CONTAINER_REGISTRY)/$(FRONTEND_IMAGE):$(FRONTEND_IMAGE_TAG)
# =============================================================================
# Build and run backend container image for production
# =============================================================================
backend-image:
	@cd backend
	@podman build -f backend.Containerfile -t $(BACKEND_IMAGE):$(BACKEND_IMAGE_TAG) .

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
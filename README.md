# Sample-app

This is a sample application for tinkering with:

1. Frontend UI to backend API connectivity
2. Reactjs environment variable configuration
3. Podman for building container images
4. Multi-stage container image builds
5. OpenShift and Code Ready Containers (aka OpenShift local)
6. OpenShift Service Mesh (aka Istio)

## Components

### Frontend UI

The [frontend](./frontend) directory contains a React App bootstrapped with [Create React App](https://github.com/facebook/create-react-app). The only thing that's been added is an API call to retrieve data and render it on the main view.

```javascript
class App extends Component {
    // code omitted
    componentDidMount() {
        fetch(process.env.REACT_APP_API_ENDPOINT + "/data.json")
            .then(res => res.json())
            .then((result) => { ... }, (error) => { ... })
    }
    // code omitted
    render() {
        // code omitted
        <code>NODE_ENV={process.env.NODE_ENV}</code>
        <code>REACT_APP_VERSION={process.env.REACT_APP_VERSION}</code>
        <code>REACT_APP_API_ENDPOINT={process.env.REACT_APP_API_ENDPOINT}</code>
        <code>data.api.name={data.api.name}</code>
        <code>data.api.version={data.api.version}</code>
        <code>data.api.message={data.api.message}</code>
    }
}
```

### Backend API

The simplest of backend APIs, it's literally an apache-httpd server with a static `data.json` file. Zero-code required.

### Manifests

Application manifests for deploying onto OpenShift two ways:

1. First way ([manifests/app-ocp](manifests/app-ocp)) is using native OpenShift ingress routes.
2. Second way ([manifests/app-istio](manifests/app-istio)) is using OpenShift Service Mesh.

## Build Container Images

The Makefile provided has targets to build container images for the frontend-ui and backend-api.

To build and push container images, run the following target and set your container registry.

```bash
# First you need to login to your registry: podman login quay.io
make push-images CONTAINER_REGISTRY=quay.io/your-org
```

## Deploy

> Note: before deploying change the container images in the manifest with your registry.

### Using OpenShift ingress routing

```bash
oc new-project sample-app
make apply 
```

### Using OpenShift Service Mesh

* Install OpenShift Service Mesh
* Add sample-app namespace to the Service Mesh Member Role

```bash
oc new-project sample-app
make apply-istio
```
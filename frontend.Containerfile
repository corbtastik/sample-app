# -------------------------------------------------------------------------------------------------
# Stage 1 - Create a production build of the reactjs application
# -------------------------------------------------------------------------------------------------
FROM registry.access.redhat.com/ubi8/nodejs-14:1-75.1655143375 AS BUILDER
WORKDIR /opt/app-root/src
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend ./
RUN npm run build
# -------------------------------------------------------------------------------------------------
# Stage 2 - Create a runtime image for the reactjs application using apache-httpd as base image
# -------------------------------------------------------------------------------------------------
FROM registry.redhat.io/ubi8/httpd-24:1-193.1654147964
COPY --from=BUILDER /opt/app-root/src/build /var/www/html
CMD run-httpd
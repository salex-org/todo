FROM node:22.11 AS ANGULAR_BUILD
RUN npm install -g @angular/cli@18.2.17
COPY ui /ui
WORKDIR ui
RUN npm ci  \
RUN npm run build

# Use distroless as minimal base image to package the application
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot
ARG TARGETPLATFORM
WORKDIR /
COPY bin/${TARGETPLATFORM}/server .
COPY --from=ANGULAR_BUILD /ui/dist/salex-todo-ui/browser/* ./ui/
ENTRYPOINT ["/server", "run"]

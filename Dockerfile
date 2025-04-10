FROM node:22.11 AS ANGULAR_BUILD
RUN npm install -g @angular/cli@18.2.17
COPY ui /ui
WORKDIR ui
RUN npm ci  \
RUN npm run build

FROM golang:1.24.1 AS GO_BUILD
COPY cmd /cmd
WORKDIR /
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o server cmd/main.go
RUN chmod +x server

FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=GO_BUILD /server .
COPY --from=ANGULAR_BUILD /ui/dist/salex-todo-ui/browser/* ./ui/
ENTRYPOINT ["/server", "run"]

#TODO build for different target, see observer prod.Dockerfile
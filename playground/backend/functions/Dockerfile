# This Dcokerfile only for local testing

FROM golang:1.20-alpine as build

COPY . /app
WORKDIR /app/functions

RUN ls -la

RUN go mod download

RUN go build -o /app/cloudfunction ./cmd

FROM alpine:3.17

COPY --from=build /app/cloudfunction /app/cloudfunction

EXPOSE 8080

ENTRYPOINT ["/app/cloudfunction"]
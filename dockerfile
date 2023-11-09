FROM golang:1.21 as build

WORKDIR /app

# Download Go modules
COPY ./catgpt/go.mod ./catgpt/go.sum ./
RUN go mod download

COPY ./catgpt ./

RUN CGO_ENABLED=0 go build -o /opt/catgpt .

FROM gcr.io/distroless/static-debian12:latest-amd64
COPY --from=build /opt/catgpt /
EXPOSE 8080
CMD ["/catgpt"]



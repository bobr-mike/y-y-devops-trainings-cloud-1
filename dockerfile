FROM golang:1.21

WORKDIR /app

# Download Go modules
COPY ./catgpt/go.mod ./catgpt/go.sum ./
RUN go mod download

COPY ./catgpt ./

RUN CGO_ENABLED=0 go build -o /opt/catgpt .

EXPOSE 8080

# Run
CMD ["/opt/catgpt"]
workflow "Build and create container on push" {
  on = "push"
  resolves = ["Docker Registry", "Docker Tag"]
}

action "Docker Registry" {
  uses = "actions/docker/login@04185cf"
  secrets = ["DOCKER_USERNAME", "DOCKER_PASSWORD"]
}

action "GitHub Action for Docker" {
  uses = "actions/docker/cli@04185cf"
  needs = ["Docker Registry"]
  args = "build -t PIUBS"
}

action "Docker Tag" {
  uses = "actions/docker/tag@04185cf"
  needs = ["GitHub Action for Docker"]
}

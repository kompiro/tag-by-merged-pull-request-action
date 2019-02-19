# Tag by merged pull request

If you'd like to know when the pull request merged correctly because GitHub doesn't record the merged infomation in your repository. This action create tag when pull request merged event.

## Usage

This Action subscribes to [Pull request events](https://developer.github.com/v3/activity/events/types/#pullrequestevent) which fire whenever users are merged pull requests.

```workflow
workflow "Tag by merged pull request" {
  on = "pull_request"
  resolves = ["Tag_on_pull_request"]
}

action "Tag_on_pull_request" {
  uses = "kompiro/tag-by-merged-pull-request-action@master"
  secrets = [
    "GITHUB_TOKEN"
  ]
}
```

## Demo

TBD

## License

The Dockerfile and associated scripts and documentation in this project are released under the [MIT License](LICENSE).

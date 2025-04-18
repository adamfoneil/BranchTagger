This is a GitHub action for tagging branches with an incrementing version number, intended as a simpler alternative to something like [Semantinc Release](https://github.com/semantic-release/semantic-release).

To use this, create a file in the root of your repo called `next-version.json` like this:

```json
{
  "<your branch name>": { "next": <int>, "commitId": "<commit id>" }
}
```

Example:

```json
{
  "main": { "next": 232, "commitId": "7d6fe69" },
  "dev": { "next": 240, "commitId": "294ab45" }
}
```

In your workflow

This is a GitHub action for tagging branches with an incrementing version number, intended as a simpler alternative to something like [Semantic Release](https://github.com/semantic-release/semantic-release). The version tag is written as `v{number}-{branch}` where `number` is just an incrementing integer, not a semantic version.

To use this, create a file in the root of your repo called `version.json` like this:

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

In your workflow, make sure you have
- `fetch-depth: 2` in your checkout step. This has to do with ensuring the detection of true changes vs merely a change to the version tracker has occurred.
- runs with `permissions, contents: write` because this action will push a tag to your repo
- a step like this

```yaml
- name: Set version tag
  uses: adamfoneil/branch-tagger@main
  with:
    branch: ${{ github.ref_name }}
    filename: next-version.json
```

See full example from a project of mine: [LiteInvoice/setversion.yml](https://github.com/adamfoneil/LiteInvoice/blob/master/.github/workflows/setversion.yml)

I had a lot of ChatGPT help on this since I've never done anything like this before:

https://chatgpt.com/share/68025295-54c8-8011-abbb-7cf6e24f1499

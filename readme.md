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

In your workflow, have a step like this:

```yaml
- name: Set version tag
  uses: adamfoneil/branch-tagger@main
  with:
    branch: ${{ github.ref_name }}
    filename: next-version.json
```

For some reason I have changed the filename to `next-version.json`. You can have any filename.

I had a lot of ChatGPT help on this since I've never done anything like this before:
https://chatgpt.com/share/68025295-54c8-8011-abbb-7cf6e24f1499

This is a GitHub action for tagging branches with an incrementing version number, intended as a simpler alternative to something like [Semantic Release](https://github.com/semantic-release/semantic-release), and resembling TFS changeset numbers. The version tag is written as `v{number}` where `number` is just an incrementing integer, not a semantic version.

To use this, create a file in the root of your repo called `version.json` like this:

```json
{
    "next": <number>,
    "commitId": "some value",
    "outputPaths": [
        "path1",
        "path2", ...
    ]
}
```

Example:

```json
{
    "next": 107,
    "commitId": "f0b92642342015d41ed059ad0c715cf72f23216c",
    "outputPaths": [
        "BlazorApp"
    ]
}
```

In your workflow, make sure you have
- `fetch-depth: 2` in your checkout step. This has to do with ensuring the detection of true changes vs merely a change to the version tracker has occurred.
- runs with `permissions, contents: write` because this action will push a tag to your repo
- a step like this

```yaml
- name: Set version tag
  uses: adamfoneil/set-version@main  
```

See full example from a project of mine: [LiteInvoice/setversion.yml](https://github.com/adamfoneil/LiteInvoice/blob/master/.github/workflows/setversion.yml)

I had a lot of ChatGPT help on this since I've never done anything like this before:

https://chatgpt.com/share/68025295-54c8-8011-abbb-7cf6e24f1499

# Sample output

Here's what the version tagging looks like in git history:

![image](https://github.com/user-attachments/assets/a7fb9008-29a8-4505-9eed-0b05a7e88f96)

Note, I had an earlier iteration of this that included the branch name in the tag, but I've removed this.

# What this is not
I had an earlier iteration of this that used the GitHub Actions `run_number` as a tag. That was the wrong approach because the run number increments even if there's no code change. This action looks at your commit history to determine if there's an actual change. It's not dependent on the run number.

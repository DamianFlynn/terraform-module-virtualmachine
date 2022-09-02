# Create a pull request

[Create a pull request](https://help.github.com/articles/creating-a-pull-request/) with your changes. Please make sure to include the following:

1. A description of the change, including a link to your GitHub issue.
1. The output of your automated test run, preferably in a [GitHub Gist](https://gist.github.com/). We cannot run automated tests for pull requests automatically due to [security concerns](https://circleci.com/docs/fork-pr-builds/#security-implications), so we need you to manually provide this test output so we can verify that everything is working.
1. Any notes on backwards incompatibility or downtime.

## Merge and release

The maintainers for this repo will review your code and provide feedback. If everything looks good, they will merge the code and release a new version, which you'll be able to find in the [releases page](https://github.com/damianflynn/terraform-scaffold/releases).

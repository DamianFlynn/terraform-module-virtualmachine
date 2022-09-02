# Update the code

At this point, make your code changes and use your new test case to verify that everything is working. As you work, keep in mind two things:

1. Backwards compatibility
1. Downtime

## Backwards compatibility

Please make every effort to avoid unnecessary backwards incompatible changes. With Terraform code, this means:

1. Do not delete, rename, or change the type of input variables.
1. If you add an input variable, it should have a `default`.
1. Do not delete, rename, or change the type of output variables.
1. Do not delete or rename a module in the `modules` folder.

**If** a backwards incompatible change cannot be avoided, please make sure to call that out when you submit a pull request, explaining why the change is absolutely necessary.

## Downtime

Bear in mind that the Terraform code in this Module is used by real companies to run real infrastructure in production, and certain types of changes could cause downtime. For example, consider the following:

1. If you rename a resource (e.g. `azure_storage_container_instance "foo"` -> `azure_storage_container_instance "bar"`), Terraform will see that as deleting the old resource and creating a new one.
1. If you change certain attributes of a resource (e.g. the `name` of an `azure_compute_instance`), the cloud provider (e.g. Azure) may treat that as an instruction to delete the old resource and a create a new one.

Deleting certain types of resources (e.g. virtual servers, load balancers) can cause downtime, so when making code changes, think carefully about how to avoid that. For example, can you avoid downtime by using [create_before_destroy](https://www.terraform.io/docs/configuration/resources.html#create_before_destroy)? Or via the `terraform state` command? If so, make sure to note this in our pull request. If downtime cannot be avoided, please make sure to call that out when you submit a pull request.

## Formatting and pre-commit hooks

You must run `terraform fmt` on the code before committing. You can configure your computer to do this automatically using pre-commit hooks managed using [pre-commit](http://pre-commit.com/):

## MacOS / Linux - Brew

1. [Install pre-commit](http://pre-commit.com/#install). E.g.: `brew install pre-commit`.
1. Install the hooks: `pre-commit install`.

## Windows - Python PIP

1. `pip install pre-commit`
1. Install the hooks: `pre-commit install --install-hooks -t commit-msg`

That's it! Now just write your code, and every time you commit, `terraform fmt` and a other [pre-commit checks](./docs/markdown/pre-commit.md) will be run on the files you're committing.

> If you are curious how this happens, in the root of the reposiotry we have a file called ```.pre-commit-config.yaml``` which contains a link to the repository hosting the checks, along with the release version to use, and the tests to execute.

## Commit Hygiene

This repository enforces [conventional commit messages.](https://www.conventionalcommits.org/)

Consider carefully, commits will be rejected, and will require the committer to edit the commits and/or their messages in the following conditions:

- do more than what is described
- do not do what is described
- or that contains multiple unrelated changes

> Please install and make use of the pre-commit git hooks using pre-commit.

### Writing Commit Messages

Structure your commit message like this:

```text
One line summary (less than 50 characters)
Longer description (wrap at 72 characters)
```

- Summary
  - Less than 50 characters
  - What was changed
  - Imperative present tense (fix, add, change)
    - Fix bug 123
    - Add 'foobar' command
    - Change default timeout to 123
  - No period

- Description
  - Wrap at 72 characters
  - Why, explain intention and implementation approach
  - Present tense

- Atomicity
  - Break up logical changes
  - Make whitespace changes separately

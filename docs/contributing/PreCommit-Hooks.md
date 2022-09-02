# Pre-Commit Hooks

## Configuring your Development Station

### Install dependencies

* [`pre-commit`](https://pre-commit.com/#install)
* [`checkov`](https://github.com/bridgecrewio/checkov) required for `checkov` hook.
* [`terraform-docs`](https://github.com/terraform-docs/terraform-docs) required for `terraform_docs` hook.
* [`terragrunt`](https://terragrunt.gruntwork.io/docs/getting-started/install/) required for `terragrunt_validate` hook.
* [`terrascan`](https://github.com/tenable/terrascan) required for `terrascan` hook.
* [`TFLint`](https://github.com/terraform-linters/tflint) required for `terraform_tflint` hook.
* [`TFSec`](https://github.com/liamg/tfsec) required for `terraform_tfsec` hook.
* [`infracost`](https://github.com/infracost/infracost) required for `infracost_breakdown` hook.
* [`jq`](https://github.com/stedolan/jq) required for `infracost_breakdown` hook.
* [`tfupdate`](https://github.com/minamijoyo/tfupdate) required for `tfupdate` hook.
* [`hcledit`](https://github.com/minamijoyo/hcledit) required for `terraform_wrapper_module_for_each` hook.

#### MacOS

```bash
brew install pre-commit terraform-docs tflint tfsec checkov terrascan infracost tfupdate minamijoyo/hcledit/hcledit jq
```

#### Windows 10/11

We highly recommend using [WSL/WSL2](https://docs.microsoft.com/en-us/windows/wsl/install) with Ubuntu and following the Ubuntu installation guide. Or use Docker.

Otherwise, you can follow [this gist](https://gist.github.com/etiennejeanneaurevolve/1ed387dc73c5d4cb53ab313049587d09):

1. Install [`git`](https://git-scm.com/downloads) and [`gitbash`](https://gitforwindows.org/)
2. Install [Python 3](https://www.python.org/downloads/)
3. Install all prerequisites needed (see above)

Ensure your PATH environment variable looks for `bash.exe` in `C:\Program Files\Git\bin` (the one present in `C:\Windows\System32\bash.exe` does not work with `pre-commit.exe`)

For `checkov`, you may need to also set your `PYTHONPATH` environment variable with the path to your Python modules.  E.g. `C:\Users\USERNAME\AppData\Local\Programs\Python\Python39\Lib\site-packages`

#### Ubuntu 18.04

```bash
sudo apt update
sudo apt install -y unzip software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install -y python3.7 python3-pip
python3 -m pip install --upgrade pip
pip3 install --no-cache-dir pre-commit
python3.7 -m pip install -U checkov
curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz && tar -xzf terraform-docs.tgz && rm terraform-docs.tgz && chmod +x terraform-docs && sudo mv terraform-docs /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | grep -o -E -m 1 "https://.+?tfsec-linux-amd64")" > tfsec && chmod +x tfsec && sudo mv tfsec /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E -m 1 "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz && tar -xzf terrascan.tar.gz terrascan && rm terrascan.tar.gz && sudo mv terrascan /usr/bin/ && terrascan init
sudo apt install -y jq && \
curl -L "$(curl -s https://api.github.com/repos/infracost/infracost/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > infracost.tgz && tar -xzf infracost.tgz && rm infracost.tgz && sudo mv infracost-linux-amd64 /usr/bin/infracost && infracost register
curl -L "$(curl -s https://api.github.com/repos/minamijoyo/tfupdate/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.tar.gz")" > tfupdate.tar.gz && tar -xzf tfupdate.tar.gz tfupdate && rm tfupdate.tar.gz && sudo mv tfupdate /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/minamijoyo/hcledit/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.tar.gz")" > hcledit.tar.gz && tar -xzf hcledit.tar.gz hcledit && rm hcledit.tar.gz && sudo mv hcledit /usr/bin/
```

#### Ubuntu 20.04

```bash
sudo apt update
sudo apt install -y unzip software-properties-common python3 python3-pip
python3 -m pip install --upgrade pip
pip3 install --no-cache-dir pre-commit
pip3 install --no-cache-dir checkov
curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz && tar -xzf terraform-docs.tgz terraform-docs && rm terraform-docs.tgz && chmod +x terraform-docs && sudo mv terraform-docs /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E -m 1 "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz && tar -xzf terrascan.tar.gz terrascan && rm terrascan.tar.gz && sudo mv terrascan /usr/bin/ && terrascan init
curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | grep -o -E -m 1 "https://.+?tfsec-linux-amd64")" > tfsec && chmod +x tfsec && sudo mv tfsec /usr/bin/
sudo apt install -y jq && \
curl -L "$(curl -s https://api.github.com/repos/infracost/infracost/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > infracost.tgz && tar -xzf infracost.tgz && rm infracost.tgz && sudo mv infracost-linux-amd64 /usr/bin/infracost && infracost register
curl -L "$(curl -s https://api.github.com/repos/minamijoyo/tfupdate/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.tar.gz")" > tfupdate.tar.gz && tar -xzf tfupdate.tar.gz tfupdate && rm tfupdate.tar.gz && sudo mv tfupdate /usr/bin/
curl -L "$(curl -s https://api.github.com/repos/minamijoyo/hcledit/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.tar.gz")" > hcledit.tar.gz && tar -xzf hcledit.tar.gz hcledit && rm hcledit.tar.gz && sudo mv hcledit /usr/bin/
```

### Install the pre-commit hook globally

Change your working directory to the active Git repository you are working in, before you execute the following commands

```bash
pre-commit install --install-hooks -t commit-msg
```

### First Run Verification

Execute this command to run `pre-commit` on all files in the repository (not only changed files):

```bash
pre-commit run -a
```

## Standard Checks

### No Commit To Branch

Protect specific branches from direct checkins.

* Using `args: [--branch, staging, --branch, main]` to set the branch to be protected.    Both `main` and `master` are protected by default if no branch argument is set.

```yaml
  - id: no-commit-to-branch
```

### Forbid New Submodules

Prevent addition of new git submodules.

```yaml
  - id: forbid-new-submodules
```

### Detect Private Key

Checks for the existence of private keys.

```yaml
  - id: detect-private-key
```

### Check Case Conflict

Check for files with names that would conflict on a case-insensitive filesystem like MacOS HFS+ or Windows FAT.

```yaml
  - id: check-case-conflict
```

### Check Added Large Files

Prevent giant files from being committed.

* Specify what is "too large" to be 500Kb
* Limits checked files to those indicated as staged for addition by git.

```yaml
  - id: check-added-large-files
    args: ['--maxkb=500']
```

### Check Yaml

Attempts to load all yaml files to verify syntax.

```yaml
  - id: check-yaml
```

### Ceck Json

Attempts to load all json files to verify syntax.

```yaml
  - id: check-json
```

### Petty Format Json

Checks that all your JSON files are pretty.  ***Pretty*** here means that keys are sorted and indented.  Configure this with the following commandline options:

* `--autofix` automatically format json files
* `--indent 2` Control the indentation (either a number for a number of spaces or a string of whitespace).  Defaults to 2 spaces.

```yaml
  - id: pretty-format-json
    args: ['--autofix']
```

### Mixed Line Ending

Replaces or checks mixed line ending.

* `auto` Replaces automatically the most frequent line ending.

```yaml
  - id: mixed-line-ending
    args: ['--fix=auto']
```

### Trailing Whitespace

Trims trailing whitespace.

* To preserve Markdown hard linebreaks we are using the argument [--markdown-linebreak-ext=md] (for extensions used by our markdownfiles).
* By default, this hook trims all whitespace from the ends of lines.

```yaml
  - id: trailing-whitespace
    args: [--markdown-linebreak-ext=md]
```

### End Of File Fixer

Makes sure files end in a newline and only a newline.

```yaml
  - id: end-of-file-fixer
```

## Terraform Checks

### Terraform Checkov

[checkov](https://github.com/bridgecrewio/checkov) static analysis of terraform templates to spot potential security issues.

### Terraform FMT

Reformat all Terraform configuration files to a canonical format.

### Terraform Validate

Validates all Terraform configuration files.

### Terraform TFlint

Validates all Terraform configuration files with [TFLint](https://github.com/terraform-linters/tflint). [Available TFLint rules](https://github.com/terraform-linters/tflint/tree/master/docs/rules#rules).

### Terraform TFSec

[TFSec](https://github.com/aquasecurity/tfsec) static analysis of terraform templates to spot potential security issues.

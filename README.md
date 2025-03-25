# The new wave of Python packaging

Binder environment to follow along workshop.

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/gaborbernat/new-wave-of-python-packaging-binder/HEAD)

[![Docker Image](https://github.com/gaborbernat/new-wave-of-python-packaging-binder/actions/workflows/docker-image.yaml/badge.svg)](https://github.com/gaborbernat/new-wave-of-python-packaging-binder/actions/workflows/docker-image.yaml)
[![pre-commit](https://github.com/gaborbernat/new-wave-of-python-packaging-binder/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/gaborbernat/new-wave-of-python-packaging-binder/actions/workflows/pre-commit.yaml)

To run it:

1. In Binder, [click here](https://mybinder.org/v2/gh/gaborbernat/new-wave-of-python-packaging-binder/HEAD).
1. locally, make sure you have [Docker](https://www.docker.com) installed and then run:

   ```shell
   docker build -t my-image . --progress=plain
   docker run -it --rm -p 8888:8888 my-image jupyter lab --ip='*' --NotebookApp.token=''
   ```

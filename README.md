# The new wave of Python packaging

Binder environment to follow along workshop.

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/gaborbernat/new-wave-of-python-packaging-binder/HEAD)

[![Docker Image](https://github.com/gaborbernat/new-wave-of-python-packaging-binder/actions/workflows/docker-image.yaml/badge.svg)](https://github.com/gaborbernat/new-wave-of-python-packaging-binder/actions/workflows/docker-image.yaml)
[![pre-commit](https://github.com/gaborbernat/new-wave-of-python-packaging-binder/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/gaborbernat/new-wave-of-python-packaging-binder/actions/workflows/pre-commit.yaml)

To run it:

1. locally, make sure you have [Docker](https://www.docker.com) installed and then run:

   ```shell
   docker build -t my-image . --progress=plain
   docker run -it --rm -p 8888:8888 my-image jupyter lab --ip='*' --NotebookApp.token=''
   ```

   Visit http://127.0.0.1:8888/lab and make sure the page loads with success.
   
2. locally, by loading the pre-built image:
   ```
   docker pull gaborjbernat/new-wave-of-python-packaging-binder:latest
   docker run -it --rm -p 8888:8888 gaborjbernat/new-wave-of-python-packaging-binder:latest jupyter lab --ip='*' --NotebookApp.token=''
   ```

   Visit http://127.0.0.1:8888/lab and make sure the page loads with success.

3. In Binder, [click here](https://mybinder.org/v2/gh/gaborbernat/new-wave-of-python-packaging-binder/HEAD).

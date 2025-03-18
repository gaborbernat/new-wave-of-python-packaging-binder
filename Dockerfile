FROM fedora:latest

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER=${NB_USER}
ENV NB_UID=${NB_UID}
ENV HOME=/home/${NB_USER}
ENV PATH=$HOME/.local/bin:${PATH}
ENV SHELL=/usr/bin/fish

# create user
RUN useradd -c "Default user" --uid ${NB_UID} ${NB_USER}

# install OS Python
RUN dnf -y update && dnf -y install python3 fish which clear && dnf clean all

# install uv python with jupyter notebook
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    uv python install 3.13 && uv tool install jupyterlab

# copy repo content so is available within the image
WORKDIR ${HOME}
COPY . ${HOME}
RUN echo $PATH && ls /home/jovyan/.local/bin
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

# Set the default command to start JupyterLab
CMD ["jupyter-lab", "--ip=0.0.0.0", "--port=8888"]

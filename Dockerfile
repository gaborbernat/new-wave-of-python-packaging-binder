FROM fedora:latest

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER=$NB_USER
ENV NB_UID=$NB_UID
ENV HOME=/home/$NB_USER
ENV PATH=$HOME/.local/bin:$PATH
ENV SHELL=/usr/bin/fish
ENV UV_NATIVE_TLS=1
ENV CC=gcc

# faster dnf
RUN echo -e "fastestmirror=True\nmax_parallel_downloads=10" >> /etc/dnf/dnf.conf

# Install OS dependencies with custom certificate support - cert.pem at project root
COPY *.pem /etc/pki/ca-trust/source/anchors/
RUN set -x && if [ -f "/etc/pki/ca-trust/source/anchors/cert.pem" ]; then \
    update-ca-trust && \
    echo -e "sslcacert=/etc/pki/ca-trust/source/anchors/cert.pem\n" >> /etc/dnf/dnf.conf; \
    fi &&\
    dnf -y update && \
    dnf -y install python3 python3-pip \
    nodejs cargo \
    gcc \
    fish \
    hyperfine lsd bat \
    which clear tree vim unzip diffutils git tig && \
    dnf clean all && \
    if [ -f "/etc/pki/ca-trust/source/anchors/cert.pem" ]; then \
    pip config set global.cert /etc/pki/ca-trust/source/anchors/cert.pem; \
    fi

# Install uv python with jupyter notebook
RUN set -x && curl -LsSf https://astral.sh/uv/install.sh | sh && \
    uv python install 3.13 && \
    uv tool install --no-cache jupyter-core  \
    --with jupyter \
    --with jupyter-resource-usage \
    --with jupyterlab-execute-time && \
    uv tool install pypiserver && \
    mkdir -p $HOME/packages

# Install npm dependencies
WORKDIR $HOME
COPY package.json $HOME/
RUN $HOME/.local/share/uv/tools/jupyter-core/bin/jlpm install && \
    rm $HOME/yarn.lock $HOME/package.json

# Install starship and cargo
RUN set -x && \
    curl -sSO https://starship.rs/install.sh && \
    sh install.sh --yes && \
    rm install.sh && \
    cargo install vivid && \
    cp $HOME/.cargo/bin/vivid $HOME/.local/bin/vivid && \
    rm -rf $HOME/.cargo

# Expose python3 with jupyter-lab onto the PATH (from uv tool env)
RUN cat <<EOF >> $HOME/.local/bin/python3
#!/bin/bash
$HOME/.local/share/uv/tools/jupyter-core/bin/python "\$@"
EOF
RUN chmod a+x $HOME/.local/bin/python3 && \
    ln -s $HOME/.local/share/uv/tools/jupyter-core/bin/jupyter-lab $HOME/.local/bin/jupyter-lab

# disable jupyterlab announcements and set dark theme
RUN set -x && jupyter labextension disable "@jupyterlab/apputils-extension:announcements" && \
    mkdir -p $HOME/.local/share/uv/tools/jupyter-core/share/jupyter/lab/settings && \
    cat <<EOF >> $HOME/.local/share/uv/tools/jupyter-core/share/jupyter/lab/settings/overrides.json
    {
    "@jupyterlab/apputils-extension:themes": {
        "theme": "JupyterLab Dark"
    },
    "@jupyterlab/terminal-extension:plugin": {
        "lineHeight": 1.2,
        "scrollback": 10000
    },
    "@jupyterlab/fileeditor-extension:plugin": {
        "editorConfig": {
            "highlightActiveLine": true,
            "highlightTrailingWhitespace": true,
            "highlightWhitespace": true,
            "rulers": [
                120
            ]
        }
    }
    }
EOF

RUN mkdir -p $HOME/.config/fish/ && cat <<EOF >> $HOME/.config/fish/config.fish
starship init fish | source
set fish_greeting
set LS_COLORS (vivid generate snazzy)
abbr --add g git
abbr --add t tig
abbr --add lt lsd --tree -a --depth 2
abbr --add l lsd -a
EOF

RUN cat <<EOF >> $HOME/.config/starship.toml
add_newline = false
[line_break]
disabled = true
[cmd_duration]
min_time = 250
show_milliseconds = true
[directory]
truncation_length = 8
truncate_to_repo = false
[docker_context]
disabled = true
[package]
disabled = true
[container]
disabled = true
EOF

# use unicode icons for lsd (as default fonts don't support fancy theme)
RUN cat <<EOF >> $HOME/merge-starship.py
# /// script
# dependencies = [
#   "tomli-w"
# ]
# ///
from tomllib import load
from tomli_w import dump
from pathlib import Path

d = Path("$HOME/.config")
val = {}
for file in d.glob("starship*.toml"):
    with file.open("rb") as file_handler:
        val |= load(file_handler)
with (d / "starship.toml").open("wb") as file_handler:
    dump(val, file_handler)
EOF
RUN starship preset no-nerd-font -o $HOME/.config/starship.1.toml && \
    starship preset no-empty-icons >> $HOME/.config/starship.2.toml && \
    uv run $HOME/merge-starship.py && \
    rm $HOME/.config/starship.*.toml $HOME/merge-starship.py && \
    mkdir -p $HOME/.config/lsd && \
    echo -e 'icons:\n  theme: unicode' >>$HOME/.config/lsd/config.yaml
ENV BAT_THEME="TwoDark"

# copy repo content so is available within the image
WORKDIR $HOME/w
COPY . $HOME/w
RUN rm -rf *.pem

# create user
RUN useradd -c "Default user" --uid $NB_UID $NB_USER
# Allow the user to run sudo without a password
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chown -R $NB_UID $HOME
USER $NB_USER

# Set the default command to start JupyterLab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888"]

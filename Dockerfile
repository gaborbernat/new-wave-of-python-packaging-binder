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

# create user
RUN useradd -c "Default user" --uid $NB_UID $NB_USER
# faster dnf
RUN echo -e "max_parallel_downloads=10\nrpmverbosity=debug\n" >> /etc/dnf/dnf.conf

# Install OS dependencies with custom certificate support - cert.pem at project root
COPY *.pem /etc/pki/ca-trust/source/anchors/
RUN set -x && if [ -f "/etc/pki/ca-trust/source/anchors/cert.pem" ]; then \
    update-ca-trust && \
    echo -e "sslcacert=/etc/pki/ca-trust/source/anchors/cert.pem\n" >> /etc/dnf/dnf.conf; \
    fi &&\
    dnf -y update && \
    dnf -y install gcc python3 nodejs \
    fish hyperfine lsd bat \
    which clear fontconfig && \
    dnf clean all

# Install starship prompt
RUN set -x && \
    curl -sSO https://starship.rs/install.sh && \
    sh install.sh --yes && \
    rm install.sh && \
    mkdir -p  $HOME/.config/fish/ && \
    echo -e "\nstarship init fish | source\nset fish_greeting\n" >> $HOME/.config/fish/config.fish && \
    cat <<EOF >> $HOME/.config/starship.toml
add_newline = false

[cmd_duration]
min_time = 500
show_milliseconds = true

[directory]
truncation_length = 8
truncate_to_repo = false

[docker_context]
disabled = true

[package]
disabled = true

[python]
disabled = true
EOF

# Install uv python with jupyter notebook
RUN set -x && curl -LsSf https://astral.sh/uv/install.sh | sh && \
    uv python install 3.13 && \
    uv tool install --no-cache jupyter-core  \
    --with jupyter \
    --with jupyter-resource-usage \
    --with jupyterlab-execute-time

# Install npm dependencies
WORKDIR $HOME
COPY package.json $HOME/
RUN $HOME/.local/share/uv/tools/jupyter-core/bin/jlpm install && \
    rm $HOME/yarn.lock $HOME/package.json

# Expose python3 with jupyter-lab onto the PATH (from uv tool env)
RUN cat <<EOF >> $HOME/.local/bin/python3
#!/bin/bash
$HOME/.local/share/uv/tools/jupyter-core/bin/python "\$@"
EOF
RUN chmod a+x $HOME/.local/bin/python3 && \
    ln -s $HOME/.local/share/uv/tools/jupyter-core/bin/jupyter-lab $HOME/.local/bin/jupyter-lab && \
    python3 -c 'import jupyterlab; print(jupyterlab)'

# disable jupyterlab announcements and set dark theme
RUN set -x && jupyter labextension disable "@jupyterlab/apputils-extension:announcements" && \
    mkdir -p /home/jovyan/.local/share/uv/tools/jupyter-core/share/jupyter/lab/settings && \
    cat <<EOF >> /home/jovyan/.local/share/uv/tools/jupyter-core/share/jupyter/lab/settings/overrides.json
    {
    "@jupyterlab/apputils-extension:themes": {
        "theme": "JupyterLab Dark"
    },
    "@jupyterlab/terminal-extension:plugin": {
        "fontFamily": "Inconsolata Nerd Font",
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

# Install Nerd Font
RUN set -x && \
    mkdir -p /usr/share/fonts/nerd-fonts && \
    curl -fLo "/usr/share/fonts/nerd-fonts/Inconsolata.tar.xz" \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Inconsolata.tar.xz" && \
    tar -xvf /usr/share/fonts/nerd-fonts/Inconsolata.tar.xz -C /usr/share/fonts/nerd-fonts/ && \
    fc-cache -fv

# copy repo content so is available within the image
COPY . $HOME/workdir
RUN rm -rf package.json *.pem
USER root
RUN chown -R $NB_UID $HOME
USER $NB_USER

# Set the default command to start JupyterLab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888"]

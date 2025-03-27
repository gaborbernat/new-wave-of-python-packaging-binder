FROM fedora:latest

ENV PATH=/root/.local/bin:/w/.venv/bin:$PATH UV_NATIVE_TLS=1

# faster dnf
RUN echo -e "fastestmirror=True\nmax_parallel_downloads=10" >> /etc/dnf/dnf.conf

# Install custom certificate if needed
COPY *.pem /etc/pki/ca-trust/source/anchors/
RUN set -x && if [ -f "/etc/pki/ca-trust/source/anchors/cert.pem" ]; then \
    update-ca-trust && \
    echo -e "sslcacert=/etc/pki/ca-trust/source/anchors/cert.pem\n" >> /etc/dnf/dnf.conf; \
    fi

WORKDIR /w
COPY uv.lock pyproject.toml /w/
COPY primes/ /w/primes/
RUN set -x && curl -LsSf https://astral.sh/uv/install.sh | sh && \
    uv venv && \
    uv sync --locked --no-editable --no-default-groups && \
    uv cache clean && \
    rm -rf "\$(uv python dir)" ~/.local/bin/uv ~/.local/bin/uvx uv.lock pyproject.toml primes

ENTRYPOINT ["primes"]

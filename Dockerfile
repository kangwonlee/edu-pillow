# begin : Dockerfile for turtle graphics grader
FROM python:3.11.11-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        fontconfig \
        fonts-dejavu-core \
        ghostscript \
        git \
        libfreetype6-dev \
        libjpeg-dev \
        liblcms2-dev \
        libopenjp2-7-dev \
        libtiff5-dev \
        libx11-6 \
        libxext6 \
        libxi6 \
        libxrender1 \
        libxtst6 \
        python3-tk \
        tcl-dev \
        tk-dev \
        xauth \
        xvfb \
        zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix

# Download the latest installer
ADD https://astral.sh/uv/install.sh /uv-installer.sh
# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh
# Ensure the installed binary is on the `PATH`
ENV PATH="/root/.local/bin/:$PATH"

WORKDIR /app/
WORKDIR /turtle

COPY requirements.txt /turtle/requirements.txt

RUN git clone --depth=1 --branch v0.1.9 https://github.com/kangwonlee/gemini-python-tutor /app/temp/

RUN uv pip install --no-cache-dir --system --requirement /turtle/requirements.txt \
    && uv pip install --no-cache-dir --system --requirement /app/temp/requirements.txt \
    && mkdir -p /app/ai_tutor/ \
    && mv /app/temp/*.py /app/ai_tutor \
    && mv /app/temp/locale/ /app/ai_tutor/locale/ \
    && rm -rf /app/temp

RUN useradd -u 1001 -m runner

# Switch to the non-root user
USER runner

# Test before push
RUN which xvfb-run \
    && python3 -c "import turtle; import PIL; import tkinter"

WORKDIR /app/
# end : Dockerfile for turtle graphics grader

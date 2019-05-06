ARG pyversion=3.5
FROM python:${pyversion}-slim-stretch

ARG pyversion
ENV PYTHON_VERSION=${pyversion}

RUN echo PYTHON_VERSION=${PYTHON_VERSION}
RUN apt-get update \
    && apt-get install -y \
        bash curl sudo man git \
        apt-transport-https \
        ca-certificates \
        gnupg2 \
        software-properties-common \
    && pip install argcomplete

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

RUN apt-get update \
    && apt-get install -y docker-ce-cli

WORKDIR /requirements

COPY ansible/requirements.txt .
RUN pip install -r requirements.txt
COPY ansible/test/runner/requirements/*.txt ./test/runner/requirements/
RUN pip install -r ./test/runner/requirements/sanity.txt

# COPY ansible/hacking/ ./hacking/
# COPY ansible/setup.py .
# RUN bash -c "source hacking/env-setup"

# ENV PATH       /test/ansible/bin:$PATH
# ENV PYTHONPATH /test/ansible/lib
# ENV MANPATH    /test/ansible/docs/man:$MANPATH
# # PATH=/test/ansible/bin:/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# # PYTHONPATH=/test/ansible/lib
# # MANPATH=/test/ansible/docs/man:/usr/local/man:/usr/local/share/man:/usr/share/man

WORKDIR /
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

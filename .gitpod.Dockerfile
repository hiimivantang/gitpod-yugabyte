FROM gitpod/workspace-full

ARG YB_VERSION=2.18.0.1
ARG YB_BUILD=4
ARG YB_BIN_PATH=/usr/local/yugabyte
ARG ROLE=gitpod
ARG PYTHON_VERSION=3.9

USER $ROLE
# create bin and data path
RUN sudo mkdir -p $YB_BIN_PATH \
  && sudo mkdir -p /var/ybdp
# set permission
RUN sudo chown -R $ROLE:$ROLE /var/ybdp \
  && sudo chown -R $ROLE:$ROLE /usr/local/yugabyte

# fetch the binary
RUN curl -sSLo ./yugabyte.tar.gz https://downloads.yugabyte.com/releases/${YB_VERSION}/yugabyte-${YB_VERSION}-b${YB_BUILD}-linux-x86_64.tar.gz \
  && tar -xvf yugabyte.tar.gz -C $YB_BIN_PATH --strip-components=1 \
  && chmod +x $YB_BIN_PATH/bin/* \
  && rm ./yugabyte.tar.gz

RUN brew install libpq
RUN brew link --force libpq

RUN brew install python@3.9
RUN echo "export PATH=/home/linuxbrew/.linuxbrew/opt/python@3.9/libexec/bin/:$PATH" >> /home/gitpod/.bashrc 

# configure the interpreter
RUN ["/usr/local/yugabyte/bin/post_install.sh"]


# re-initialization is automatically handled
RUN echo "\n# yugabytedb start command" >> /home/gitpod/.bashrc.d/100-yugabyedb-launch
RUN echo "[[ -f \${GITPOD_REPO_ROOT}/.nopreload ]] || yugabyted start --base_dir=$STORE --listen=$HOST > /dev/null" >> /home/gitpod/.bashrc.d/100-yugabyedb-launch

RUN chmod +x /home/gitpod/.bashrc.d/100-yugabyedb-launch

# set the execution path and other env variables
ENV PATH="$YB_BIN_PATH/bin/:$PATH"
ENV HOST=127.0.0.1
ENV STORE=/var/ybdp
ENV YSQL_PORT=5433
ENV YCQL_PORT=9042
ENV WEB_PORT=7000
ENV TSERVER_WEB_PORT=9000
ENV YSQL_API_PORT=13000
ENV YCQL_API_PORT=12000

EXPOSE ${YSQL_PORT} ${YCQL_PORT} ${WEB_PORT} ${TSERVER_WEB_PORT} ${YSQL_API_PORT} ${YCQL_API_PORT}

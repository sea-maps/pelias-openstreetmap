# base image
FROM pelias/baseimage

# downloader apt dependencies
# note: this is done in one command in order to keep down the size of intermediate containers
RUN apt-get update && apt-get install -y bzip2 unzip && rm -rf /var/lib/apt/lists/*

# change working dir
ENV WORKDIR /code/pelias/openstreetmap
WORKDIR ${WORKDIR}

# copy package.json first to prevent npm install being rerun when only code changes
COPY ./package.json ${WORKDIR}
COPY ./package-lock.json ${WORKDIR}
COPY ./.npmrc ${WORKDIR}

RUN --mount=type=secret,id=GITHUB_TOKEN \
	GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN) npm ci

# add local code
ADD . ${WORKDIR}

# run tests, clean up LevelDB lockfile
RUN npm test && rm -rf /tmp/*

# run as the pelias user
USER pelias

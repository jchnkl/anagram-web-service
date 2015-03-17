FROM jotrk/haskell-base
MAINTAINER Jochen Keil

# for unix-compat
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y zlib1g-dev

RUN cabal update

RUN mkdir /anagram-web-service
WORKDIR /anagram-web-service

RUN mkdir /anagram-web-service/cabal-sandbox
WORKDIR /anagram-web-service/cabal-sandbox
RUN cabal sandbox init --sandbox .
RUN cabal install scotty dawg
# \
#         aeson \
#         bytestring \
#         dawg \
#         dlist \
#         hashable \
#         scotty \
#         text \
#         unordered-containers

RUN cabal install wai-cors

ADD rest-service /anagram-web-service/rest-service
WORKDIR /anagram-web-service/rest-service
RUN cabal sandbox init --sandbox ../cabal-sandbox
RUN cabal build

ADD completion-engine /anagram-web-service/completion-engine
WORKDIR /anagram-web-service/completion-engine
RUN cabal sandbox init --sandbox ../cabal-sandbox
RUN cabal build

ADD completion-service /anagram-web-service/completion-service
WORKDIR /anagram-web-service/completion-service
RUN cabal sandbox init --sandbox ../cabal-sandbox
RUN cabal sandbox add-source /anagram-web-service/rest-service
RUN cabal sandbox add-source /anagram-web-service/completion-engine
RUN cabal install --dependencies-only
RUN cabal build

ADD anagram-solver /anagram-web-service/anagram-solver
WORKDIR /anagram-web-service/anagram-solver
RUN cabal sandbox init --sandbox ../cabal-sandbox
RUN cabal build

ADD anagram-service /anagram-web-service/anagram-service
WORKDIR /anagram-web-service/anagram-service
RUN cabal sandbox init --sandbox ../cabal-sandbox
RUN cabal sandbox add-source /anagram-web-service/rest-service
RUN cabal sandbox add-source /anagram-web-service/anagram-solver
RUN cabal install --dependencies-only
RUN cabal build

ADD webui-service /anagram-web-service/webui-service
WORKDIR /anagram-web-service/webui-service
RUN cabal sandbox init --sandbox ../cabal-sandbox
RUN cabal build
RUN cp index.html /anagram-web-service/webui-service/dist/build/webui-service/

# anagram-service
EXPOSE 1525:1525
# completion-service
EXPOSE 1880:1880
# webui-service
EXPOSE 8888:8888

WORKDIR /anagram-web-service
ADD entrypoint.sh /anagram-web-service/entrypoint.sh
RUN chmod +x /anagram-web-service/entrypoint.sh

RUN apt-get install -y cracklib-runtime
RUN cp /anagram-web-service/webui-service/index.html /anagram-web-service/
ENTRYPOINT /anagram-web-service/entrypoint.sh

# ADD webui-service /anagram-web-service/webui-service
# ADD anagram-solver /anagram-web-service/anagram-solver
# ADD anagram-service /anagram-web-service/anagram-service
# ADD completion-service /anagram-web-service/completion-service
# ADD completion-engine /anagram-web-service/completion-engine


# RUN wget -O rest-service.zip "https://github.com/jotrk/rest-service/archive/master.zip"
# RUN unzip rest-service.zip
# RUN mv rest-service-master rest-service
# WORKDIR /anagram-web-service/rest-service
# RUN cabal sandbox init --sandbox ../cabal-sandbox
# RUN cabal install --dependencies-only
# RUN cabal build
#
# WORKDIR /anagram-web-service
# RUN wget -O completion-engine.zip "https://github.com/jotrk/completion-engine/archive/master.zip"
# RUN unzip completion-engine.zip
# RUN mv completion-engine-master completion-engine
# WORKDIR /anagram-web-service/completion-engine
# RUN cabal sandbox init --sandbox ../cabal-sandbox
# RUN cabal install --dependencies-only
# RUN cabal build
#
# WORKDIR /anagram-web-service
# RUN wget -O completion-service.zip "https://github.com/jotrk/completion-service/archive/master.zip"
# RUN unzip completion-service.zip
# RUN mv completion-service-master completion-service
# WORKDIR /anagram-web-service/completion-service
# RUN cabal sandbox init --sandbox ../cabal-sandbox
# RUN cabal install --dependencies-only
# RUN cabal build
#
# WORKDIR /anagram-web-service
# RUN wget -O anagram-solver.zip "https://github.com/jotrk/anagram-solver/archive/master.zip"
# RUN unzip anagram-solver.zip
# RUN mv anagram-solver-master anagram-solver
# WORKDIR /anagram-web-service/anagram-solver
# RUN cabal sandbox init --sandbox ../cabal-sandbox
# RUN cabal install --dependencies-only
# RUN cabal build
#
# WORKDIR /anagram-web-service
# RUN wget -O anagram-service.zip "https://github.com/jotrk/anagram-service/archive/master.zip"
# RUN unzip anagram-service.zip
# RUN mv anagram-service-master anagram-service
# WORKDIR /anagram-web-service/anagram-service
# RUN cabal sandbox init --sandbox ../cabal-sandbox
# RUN cabal install --dependencies-only
# RUN cabal build
#
# WORKDIR /anagram-web-service
# RUN wget -O webui-service.zip "https://github.com/jotrk/webui-service/archive/master.zip"
# RUN unzip webui-service.zip
# RUN mv webui-service-master webui-service
# WORKDIR /anagram-web-service/webui-service
# RUN cabal sandbox init --sandbox ../cabal-sandbox
# RUN cabal install --dependencies-only
# RUN cabal build


# RUN git clone --depth 1 "git@github.com:jotrk/rest-service"
# WORKDIR /anagram-web-service/rest-service
# RUN cabal sandbox init --sandbox ../cabal-sandbox
#
# RUN git clone --depth 1 "git@github.com:jotrk/webui-service"
# WORKDIR /anagram-web-service/webui-service
# RUN cabal sandbox init --sandbox ../cabal-sandbox
#
# RUN git clone --depth 1 "git@github.com:jotrk/anagram-service"
# WORKDIR /anagram-web-service/anagram-service
# RUN cabal sandbox init --sandbox ../cabal-sandbox
#
# RUN git clone --depth 1 "git@github.com:jotrk/anagram-solver"
# WORKDIR /anagram-web-service/anagram-solver
# RUN cabal sandbox init --sandbox ../cabal-sandbox
#
# RUN git clone --depth 1 "git@github.com:jotrk/completion-engine"
# WORKDIR /anagram-web-service/completion-engine
# RUN cabal sandbox init --sandbox ../cabal-sandbox
#
# RUN git clone --depth 1 "git@github.com:jotrk/completion-service"
# WORKDIR /anagram-web-service/completion-service
# RUN cabal sandbox init --sandbox ../cabal-sandbox



# RUN cabal install dlist text warp scotty aeson unordered-containers



# RUN useradd --system --shell /bin/nologin reddit
# RUN git clone http://github.com/reddit/reddit.git /reddit
# RUN chown -R reddit:reddit /reddit
#
# WORKDIR /reddit/r2
#
# USER reddit
# RUN python setup.py build
#
# USER root
# RUN python setup.py develop
#
# USER reddit
# RUN make
#
# ADD gs.update /reddit/r2/gs.update
# RUN make ini
#
# EXPOSE 8081
# ENTRYPOINT paster serve gs.ini http_port=8081

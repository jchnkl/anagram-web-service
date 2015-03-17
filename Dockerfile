FROM jotrk/haskell-base
MAINTAINER Jochen Keil

# for unix-compat
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y cracklib-runtime zlib1g-dev

RUN cabal update

RUN mkdir /anagram-web-service
WORKDIR /anagram-web-service

RUN mkdir /anagram-web-service/cabal-sandbox
WORKDIR /anagram-web-service/cabal-sandbox
RUN cabal sandbox init --sandbox .
RUN cabal install dawg wai-cors scotty

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
RUN cp index.html /anagram-web-service/

# anagram-service
EXPOSE 1525:1525
# completion-service
EXPOSE 1880:1880
# webui-service
EXPOSE 8888:8888

WORKDIR /anagram-web-service
ADD entrypoint.sh /anagram-web-service/entrypoint.sh
RUN chmod +x /anagram-web-service/entrypoint.sh

ENTRYPOINT /anagram-web-service/entrypoint.sh
